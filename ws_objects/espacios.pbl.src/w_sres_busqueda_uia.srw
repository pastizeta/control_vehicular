$PBExportHeader$w_sres_busqueda_uia.srw
forward
global type w_sres_busqueda_uia from window
end type
type rb_empleado from radiobutton within w_sres_busqueda_uia
end type
type cb_seleccionar from commandbutton within w_sres_busqueda_uia
end type
type st_inscrito from statictext within w_sres_busqueda_uia
end type
type rb_alumno from radiobutton within w_sres_busqueda_uia
end type
type st_actividad from statictext within w_sres_busqueda_uia
end type
type st_nombre from statictext within w_sres_busqueda_uia
end type
type st_tipo from statictext within w_sres_busqueda_uia
end type
type sle_cuenta from singlelineedit within w_sres_busqueda_uia
end type
type ole_credencial from olecustomcontrol within w_sres_busqueda_uia
end type
type ole_foto from olecustomcontrol within w_sres_busqueda_uia
end type
end forward

global type w_sres_busqueda_uia from window
integer width = 1545
integer height = 1604
boolean titlebar = true
string title = "Búsqueda de Usuarios"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 29534863
rb_empleado rb_empleado
cb_seleccionar cb_seleccionar
st_inscrito st_inscrito
rb_alumno rb_alumno
st_actividad st_actividad
st_nombre st_nombre
st_tipo st_tipo
sle_cuenta sle_cuenta
ole_credencial ole_credencial
ole_foto ole_foto
end type
global w_sres_busqueda_uia w_sres_busqueda_uia

type variables
n_transportar uo_parametros
end variables

forward prototypes
public function long wf_busca_cuenta (string as_nchip)
public subroutine wf_carga_foto (long li_cuenta, integer li_tipo)
public function boolean wf_busca_empleado ()
public function boolean wf_busca_alumno ()
end prototypes

public function long wf_busca_cuenta (string as_nchip);long ll_cuenta


//PRIMERO BUSCAMOS LOS ALUMNOS
  SELECT v_sce_alumnos.cuenta  
    INTO :ll_cuenta  
    FROM v_sce_alumnos  
   WHERE v_sce_alumnos.nchip = :as_nchip using gtr_sumuia  ;

	if gtr_sumuia.sqlcode<>0 then
		//BUSCAMOS EN EMPLEADOS
	    SELECT empl_uia1.empleado  
	    INTO :ll_cuenta  
	    FROM empl_uia1  
	   WHERE empl_uia1.nchip = :as_nchip   using gtr_personal;	
		if gtr_personal.sqlcode<>0 then
			ll_cuenta=0
		else
			rb_empleado.checked=true
		end if
	else
		rb_alumno.checked=true
	end if
if ll_cuenta<>0 then
	sle_cuenta.text=string(ll_cuenta)
end if
return ll_cuenta


end function

public subroutine wf_carga_foto (long li_cuenta, integer li_tipo);Blob lbl_foto
String ls_arch_ruta
SetNull(ls_arch_ruta)
lbl_foto = f_foto_alumno(li_cuenta)
if not isnull(lbl_foto) then
	if li_tipo=0 then
		ls_arch_ruta = f_archivo_gvbox(f_foto_alumno(li_cuenta))
	else
		ls_arch_ruta = f_archivo_gvbox(f_foto_profesor(li_cuenta))
	end if
	IF IsNull(ls_arch_ruta) THEN 
		ole_foto.Object.FileName = ''
		messagebox('Aviso','El Alumno no tiene foto') 
	ELSE 
		ole_foto.Object.FileName = ls_arch_ruta
		ole_foto.visible=true
		ole_foto.object.autosize=2
	END IF
end if
end subroutine

public function boolean wf_busca_empleado ();string ls_nombrecompleto,ls_costo,ls_depto
long ll_nomina
integer li_status
boolean lb_error=true

  if isnumber(sle_cuenta.text) then
    ll_nomina=long(sle_cuenta.text)
    SELECT  nombre+''+isnull(appaterno,'')+' '+ isnull(apmaterno,'') as nombrecompleto,   
         empl_uia1.ccosto,   
         empl_uia1.nombredepto,
			empl_uia1.status
    INTO :ls_nombrecompleto,   
         :ls_costo,   
         :ls_depto,
			:li_status
    FROM empl_uia1  
   WHERE empl_uia1.empleado = :ll_nomina   using gtr_personal;
		if gtr_personal.sqlcode=0 then
			if li_status >= 2 then
				st_inscrito.text="Empleado dado de baja"
				st_inscrito.textcolor = RGB (255,1,1)
			else
				st_inscrito.text="Empleado activo"
				st_inscrito.textcolor = RGB ( 0, 0, 0 )
			end if
			//TODO OK
			st_nombre.text=ls_nombrecompleto
			st_actividad.text=ls_depto
			uo_parametros.il_parm1=ll_nomina
			uo_parametros.is_parm2=ls_nombrecompleto
			uo_parametros.is_parm3=ls_depto
			uo_parametros.is_parm4=ls_costo
			lb_error=false
		else
			messagebox("Mensaje del Sistema","La cuenta ingresada no existe",stopsign!)
			sle_cuenta.setfocus()
		end if			
else
	messagebox("Mensaje del Sistema","Ingrese el numero de cuenta correctamente",stopsign!)
	sle_cuenta.setfocus()
end if

return lb_error
end function

public function boolean wf_busca_alumno ();string ls_nombrecompleto,ls_carrera
long ll_cuenta
long ll_cuenta_inscrito
boolean lb_error=true

  if isnumber(sle_cuenta.text) then
    ll_cuenta=long(sle_cuenta.text)
  SELECT v_sce_banderas_inscrito.cuenta,   
	         v_sce_alumnos.nombre+ ' ' + v_sce_alumnos.apaterno+' ' +v_sce_alumnos.amaterno as nombre_completo  ,
			v_sce_carreras.carrera
   INTO :ll_cuenta_inscrito,   
	       :ls_nombrecompleto,
		   :ls_carrera
FROM		v_sce_alumnos INNER JOIN
		v_sce_academicos ON v_sce_alumnos.cuenta = v_sce_academicos.cuenta INNER JOIN
		v_sce_carreras ON v_sce_academicos.cve_carrera = v_sce_carreras.cve_carrera LEFT OUTER JOIN
		v_sce_banderas_inscrito ON v_sce_alumnos.cuenta = v_sce_banderas_inscrito.cuenta
	WHERE v_sce_alumnos.cuenta = :ll_cuenta
	using gtr_sumuia;
		if gtr_sumuia.sqlcode=0 then
			//TODO OK
			st_nombre.text=ls_nombrecompleto
			st_actividad.text=ls_carrera
			uo_parametros.is_parm2=ls_nombrecompleto
			uo_parametros.is_parm3=ls_carrera
			uo_parametros.il_parm1=ll_cuenta
			if not isnull(ll_cuenta_inscrito) then
				st_inscrito.text="Alumno Inscrito"
				st_inscrito.textcolor = RGB ( 0, 0, 0 )
			else
				st_inscrito.text="Alumno NO Inscrito"
				st_inscrito.textcolor = RGB ( 255, 5, 5 )
			end if
			lb_error=false
		else
			messagebox("Mensaje del Sistema","La cuenta ingresada no existe",stopsign!)
			sle_cuenta.setfocus()
		end if			
else
	messagebox("Mensaje del Sistema","Ingrese el numero de cuenta correctamente",stopsign!)
	sle_cuenta.setfocus()
end if

return lb_error
end function

on w_sres_busqueda_uia.create
this.rb_empleado=create rb_empleado
this.cb_seleccionar=create cb_seleccionar
this.st_inscrito=create st_inscrito
this.rb_alumno=create rb_alumno
this.st_actividad=create st_actividad
this.st_nombre=create st_nombre
this.st_tipo=create st_tipo
this.sle_cuenta=create sle_cuenta
this.ole_credencial=create ole_credencial
this.ole_foto=create ole_foto
this.Control[]={this.rb_empleado,&
this.cb_seleccionar,&
this.st_inscrito,&
this.rb_alumno,&
this.st_actividad,&
this.st_nombre,&
this.st_tipo,&
this.sle_cuenta,&
this.ole_credencial,&
this.ole_foto}
end on

on w_sres_busqueda_uia.destroy
destroy(this.rb_empleado)
destroy(this.cb_seleccionar)
destroy(this.st_inscrito)
destroy(this.rb_alumno)
destroy(this.st_actividad)
destroy(this.st_nombre)
destroy(this.st_tipo)
destroy(this.sle_cuenta)
destroy(this.ole_credencial)
destroy(this.ole_foto)
end on

event open;ole_credencial.object.tlector=gs_tlector
ole_credencial.object.inicializa()
timer(1.5)
if uo_parametros.is_parm1="BUSQUEDA" then cb_seleccionar.visible = true
uo_parametros.is_parm5=Message.StringParm	
end event

event timer;string nchip=""
long ll_cuenta
nchip=ole_credencial.object.AutorizaChip()

if nchip<>"" then
	//INSERTO CREDENCIAL
	cb_seleccionar.enabled=false
	ole_foto.visible=false
	ll_cuenta=wf_busca_cuenta(nchip)
	if ll_cuenta=0 then	
		messagebox("Mensaje del Sistema","Credencial Inválida",stopsign!)	
	else
		sle_cuenta.triggerevent(modified!)
	end if
end if
end event

event closequery;ole_credencial.object.desconectar()
end event

type rb_empleado from radiobutton within w_sres_busqueda_uia
integer x = 645
integer y = 188
integer width = 635
integer height = 80
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29534863
string text = "Profesor/Empleado"
end type

type cb_seleccionar from commandbutton within w_sres_busqueda_uia
integer x = 1088
integer y = 1032
integer width = 407
integer height = 112
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean enabled = false
string text = "&Seleccionar"
end type

event clicked;

uo_parametros.is_parm1="BUSQUEDA"
if rb_alumno.checked then
	uo_parametros.ii_parm2=1
else
	uo_parametros.ii_parm2=2
end if
closewithreturn(parent,uo_parametros)
end event

type st_inscrito from statictext within w_sres_busqueda_uia
integer x = 18
integer y = 1204
integer width = 1467
integer height = 64
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29534863
alignment alignment = center!
boolean focusrectangle = false
end type

type rb_alumno from radiobutton within w_sres_busqueda_uia
integer x = 174
integer y = 188
integer width = 343
integer height = 80
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29534863
string text = "Alumno"
boolean checked = true
end type

event getfocus;st_tipo.text="Número de Cuenta"
sle_cuenta.text=""
ole_foto.visible=false
cb_seleccionar.enabled=false
st_inscrito.text=""
st_actividad.text=""
st_nombre.text=""
end event

type st_actividad from statictext within w_sres_busqueda_uia
integer x = 18
integer y = 1416
integer width = 1467
integer height = 64
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29534863
alignment alignment = center!
boolean focusrectangle = false
end type

type st_nombre from statictext within w_sres_busqueda_uia
integer x = 18
integer y = 1344
integer width = 1467
integer height = 64
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29534863
alignment alignment = center!
boolean focusrectangle = false
end type

type st_tipo from statictext within w_sres_busqueda_uia
integer x = 50
integer y = 324
integer width = 690
integer height = 64
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29534863
string text = "Número de Cuenta"
alignment alignment = right!
boolean focusrectangle = false
end type

type sle_cuenta from singlelineedit within w_sres_busqueda_uia
integer x = 763
integer y = 312
integer width = 375
integer height = 88
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

event modified;if rb_alumno.checked then
	if not(wf_busca_alumno() ) then 
		wf_carga_foto(long(sle_cuenta.text),0)
		cb_seleccionar.enabled=true
	end if
else
	if not(wf_busca_empleado() ) then 
		wf_carga_foto(long(sle_cuenta.text),1)
		cb_seleccionar.enabled=true
	end if
end if
end event

event getfocus;this.text=""
cb_seleccionar.enabled=false
ole_foto.visible=false
st_inscrito.text=""
st_actividad.text=""
st_nombre.text=""
end event

type ole_credencial from olecustomcontrol within w_sres_busqueda_uia
integer x = 82
integer y = 28
integer width = 1317
integer height = 92
integer taborder = 20
borderstyle borderstyle = stylelowered!
boolean focusrectangle = false
string binarykey = "w_sres_busqueda_uia.win"
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
end type

type ole_foto from olecustomcontrol within w_sres_busqueda_uia
event paint ( )
event resize ( )
event click ( )
event dblclick ( )
event keydown ( integer keycode,  integer shift )
event keyup ( integer keycode,  integer shift )
event keypress ( integer keyascii )
event mousedown ( integer button,  integer shift,  long ocx_x,  long ocx_y )
event mouseup ( integer button,  integer shift,  long ocx_x,  long ocx_y )
event mousemove ( integer button,  integer shift,  long ocx_x,  long ocx_y )
boolean visible = false
integer x = 453
integer y = 444
integer width = 622
integer height = 572
integer taborder = 10
borderstyle borderstyle = styleraised!
boolean focusrectangle = false
string binarykey = "w_sres_busqueda_uia.win"
integer binaryindex = 1
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
end type


Start of PowerBuilder Binary Data Section : Do NOT Edit
01w_sres_busqueda_uia.bin 
2100000c00e011cfd0e11ab1a1000000000000000000000000000000000003003e0009fffe000000060000000000000000000000010000000100000000000010000000000200000001fffffffe0000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd00000004fffffffefffffffefffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff006f00520074006f004500200074006e00790072000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050016ffffffffffffffff00000003000000000000000000000000000000000000000000000000000000005999205001c89e5700000003000001000000000000500003004c004200430049004e0045004500530045004b000000590000000000000000000000000000000000000000000000000000000000000000000000000002001cffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000fffffffe000000000000000000500003004f0042005800430054005300450052004d0041000000000000000000000000000000000000000000000000000000000000000000000000000000000002001affffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000004800000000004200500043004f00530058004f00540041005200450047000000000000000000000000000000000000000000000000000000000000000000000000000000000101001a0000000200000001000000042285cca64c9e25b2176297a97729b8c1000000005999205001c89e575999205001c89e5700000000000000000000000000000001fffffffe00000003fffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
2Effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000b29300000048000800034757f20b000000200065005f00740078006e00650078007400001dc4000800034757f20affffffe00065005f00740078006e0065007900740000026100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b29300000048000800034757f20b000000200065005f00740078006e00650078007400001dc4000800034757f20affffffe00065005f00740078006e00650079007400000261000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004f00430054004e004e00450053005400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001020012ffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000200000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e00e011cfd0e11ab1a1000000000000000000000000000000000003003e0009fffe000000060000000000000000000000010000000100000000000010000000000200000001fffffffe0000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd00000005fffffffe00000004fffffffefffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
2Effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff006f00520074006f004500200074006e00790072000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050016ffffffffffffffff00000003000000000000000000000000000000000000000000000000000000005999205001c89e5700000003000003800000000000500003004c004200430049004e0045004500530045004b000000590000000000000000000000000000000000000000000000000000000000000000000000000002001cffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000006a0000000000500003004f0042005800430054005300450052004d0041000000000000000000000000000000000000000000000000000000000000000000000000000000000002001affffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000020000029100000000004200500043004f00530058004f00540041005200450047000000000000000000000000000000000000000000000000000000000000000000000000000000000101001a000000020000000100000004e7edc30011cf766f20004fa65d4237af000000005999205001c89e575999205001c89e5700000000000000000000000000000001fffffffe000000030000000400000005000000060000000700000008000000090000000a0000000b0000000cfffffffefffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00560047004f0042002e00580043004f00200058006f00430079007000690072006800670020007400630028002000290039003100360039002d0020003100200039003900200037006f004a00200065002e0043004f00200069006c00680070006e0061002000740000000100000000000000000000000000000000000000000000fffe00020105e7edc30011cf766f20004fa65d4237af00000001fb8f0821101b01640008ed8413c72e2b000000300000026100000012000001000000009800000101000000a000000102000000a800000103000000b000000104000000b800000105000000c000000106000000c800000107000000d000000108000000d800000109000000e00000010a000000ec0000010b000000f40000010c000000fc0000010d000001040000010e0000010c0000010f00000114000001100000011c000000000000012400000003000200000000000300000e0e0000000300000ec8000000030000006900000002000000010000000200000000000000020000000100000002000000000000000b000000000000000800000001000000000000000200000001000000020000000000000002000000000000000200000000000000043f800000000000043f8000000000000b0000000000000012000000000000000100010a0000000b0065706a007469646700726568000001060000000a6d7463646f687465010900640009000069660000616e656c1000656d100000017400000061706f777571737369746e610d00657a0a00000174000000626d75686c69616e00010e00000005006f6f7a000108006d00100000616600007579636e6d6173706e696c7001030067000c0000735f00006b636f74706f7270010700730007000069640000726568740001050000000900747561007a69736f01040065000c00006f620000726564726c797473010b0065000700007270000078746e69000101000000090078655f00746e6574010c0078000700007270000079746e69000102000000090078655f00746e6574010f0079000a0000727000007a746e69006d6f6f00000100000000097265765f6e6f69730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000e0e00000ec8000000690000000000ffffff00010001
2E00000100010000000000000000000000003f8000003f80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006f00430074006e006e00650073007400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001020012ffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000d00000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11w_sres_busqueda_uia.bin 
End of PowerBuilder Binary Data Section : No Source Expected After This Point
