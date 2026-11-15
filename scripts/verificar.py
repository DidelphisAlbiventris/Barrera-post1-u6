"""Prueba real de los COM en CPU x86 16-bit Unicorn; no sustituye DOSBox/DEBUG."""
from pathlib import Path
import json
from unicorn import Uc, UC_ARCH_X86, UC_MODE_16, UC_HOOK_INTR, UC_HOOK_CODE
from unicorn.x86_const import *
p=Path(__file__).resolve().parents[1]
maps=json.loads((p/'docs/simbolos.json').read_text())
regs={'AX':UC_X86_REG_AX,'BX':UC_X86_REG_BX,'CX':UC_X86_REG_CX,'DX':UC_X86_REG_DX,'SI':UC_X86_REG_SI,'BP':UC_X86_REG_BP,'SP':UC_X86_REG_SP,'FLAGS':UC_X86_REG_EFLAGS}
report=[]
for name,symbols in maps.items():
 u=Uc(UC_ARCH_X86,UC_MODE_16); u.mem_map(0,0x10000); u.mem_write(0x100,(p/'bin'/f'{name}.COM').read_bytes()); u.reg_write(UC_X86_REG_SP,0xFFFE)
 states={}; out=[]; ended=[]
 def intr(uc,n,data):
  if n==0x20: ended.append(True); uc.emu_stop(); return
  assert n==0x21,n
  ah=uc.reg_read(UC_X86_REG_AH)
  if ah==9:
   addr=uc.reg_read(UC_X86_REG_DX)
   while uc.mem_read(addr,1)!=b'$': out.append(chr(uc.mem_read(addr,1)[0])); addr+=1
  elif ah==2: out.append(chr(uc.reg_read(UC_X86_REG_DL)))
  else: raise AssertionError(ah)
 def hook(uc,addr,size,data):
  for label,offset in symbols.items():
   if addr==offset and (label.startswith('cp_') or label=='fin'):
    states[label]={r:uc.reg_read(k) for r,k in regs.items()}
    if label=='cp_pila': states[label]['locales']=bytes(uc.mem_read(uc.reg_read(UC_X86_REG_BP)-4,4)).hex()
 u.hook_add(UC_HOOK_INTR,intr); u.hook_add(UC_HOOK_CODE,hook)
 u.emu_start(0x100,0x10000,count=100000); assert ended
 def check(label,reg,val): assert states[label][reg]==val,(name,label,reg,states[label][reg],val)
 if name in ('INSTR','FACT'):
  for label,val in [('cp_add',57),('cp_sub',65503),('cp_mul',70),('cp_div',0x020E),('cp_bucle',120 if name=='FACT' else 15)]: check(label,'AX',val)
  for label,val in [('cp_and',7),('cp_test',0xB7),('cp_nibbles',0x5A)]: assert states[label]['AX']&255==val
  for label in ['cp_shl','cp_rol','cp_shr','cp_ror']: assert states[label]['FLAGS']&1
  assert states['cp_ror']['BX']==0xC002
  assert states['cp_ror']['CX']&255==3
  assert states['cp_ror']['DX']&255==0x40
  for label,flags in [('cp_add',0),('cp_sub',0x81),('cp_and',0),('cp_test',0),('cp_cmp',0)]: assert states[label]['FLAGS']&0x8C1==flags
 else:
  check('cp_indirecto','AX',79);check('cp_elemento','AX',30);check('cp_array','AX',150);check('cp_pila','AX',349);check('cp_matriz','DX',6);check('cp_matriz','SI',10)
  check('cp_restaurado','BP',0);check('cp_restaurado','SP',0xFFFE)
  assert states['cp_pila']['locales']=='fa006300'
  assert states['cp_reserva_antes']['SP']-states['cp_reserva_despues']['SP']==4
  assert bytes(u.mem_read(symbols['promedio'],2))==b'\x4f\x00'
 # Comprueba que cada linea impresa coincide con los registros antes de mostrar.
 lines=''.join(out).splitlines()[2:]
 printed=[v for k,v in states.items() if k not in ['cp_cmp','cp_reserva_antes','cp_reserva_despues','cp_locales','cp_restaurado','fin']]
 assert len(lines)==len(printed),(name,len(lines),len(printed))
 for line,s in zip(lines,printed):
  expected=f"AX/BX/CX/DX: A={s['AX']:04X} B={s['BX']:04X} C={s['CX']:04X} D={s['DX']:04X}  SI BP SP FLAGS: {s['SI']:04X} {s['BP']:04X} {s['SP']:04X} {s['FLAGS']:04X} "
  assert line==expected,(line,expected)
 report.append(f'{name}: OK; resultados, flags definidos, pila e impresion comprobados.\n'+''.join(out))
 (p/'docs'/f'estados_{name}.json').write_text(json.dumps(states,indent=2))
(p/'docs/verificacion.txt').write_text('Entorno: Unicorn 2.1.4, x86 16 bits; INT 21h simulado para salida; INT 20h para terminar.\nNo es una sesion de DOSBox ni una captura de DEBUG.\n\n'+'\n'.join(report))
print('\n'.join(x.splitlines()[0] for x in report))
