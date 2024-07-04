#include "protheus.ch"
#include "Birtdataset.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR472ds³ Autor ³Jesus Peñaloza         ³ Data ³ 08/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Data set de Remision de venta en formato birt              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
dataset SM0ds
	title "Datos de la Empresa"
	description "Datos de la empresa"
	
columns
	define column NOMBRE  type character size 20 label "Nombre"
	define column DIRECC  type character size 30 label "Direccion"
	define column COLONIA type character size 30 label "Colonia"
	define column CIUDAD  type character size 30 label "Ciudad"
	define column ESTADO  type character size 30 label "Estado"
	define column CODIGOP type character size 6  label "Codigo Postal"
	define column RFC     type character size 13 label "RFC"
	define column TELEFON type character size 20 label "Telefono"

define query "SELECT NOMBRE, DIRECC, COLONIA, CIUDAD, ESTADO, CODIGOP, RFC, TELEFON "+;
            "FROM %WTable:1% "
            
process dataset
	Local cWTabAlias
	Local lRet := .F.
	
		if ::isPreview()
		endif
		
		cWTabAlias := ::createWorkTable()
		chkFile("SM0")
		
		Processa({|_lEnd| lRet := DatosEmp(cWTabAlias)}, ::title())
		
		if !lRet
			alert("Sin datos")
		endif

return .T.


Static Function DatosEmp(cWTabAlias)
	Local aAreaSM0:= SM0->(GetArea())
	
		RecLock(cWTabAlias, .T.)
			(cWTabAlias)->NOMBRE  := Alltrim(SM0->M0_NOME)
			(cWTabAlias)->DIRECC  := Alltrim(SM0->M0_ENDCOB)
			(cWTabAlias)->COLONIA := Alltrim(SM0->M0_BAIRCOB)
			(cWTabAlias)->CIUDAD  := Alltrim(SM0->M0_CIDCOB)
			(cWTabAlias)->ESTADO  := Alltrim(SM0->M0_ESTCOB)
			(cWTabAlias)->CODIGOP := Alltrim(SM0->M0_CEPCOB)
			(cWTabAlias)->RFC     := Alltrim(SM0->M0_CGC)
			(cWTabAlias)->TELEFON := Alltrim(SM0->M0_TEL)
		(cWTabAlias)->(MsUnlock())
	
	RestArea(aAreaSM0)
Return .T.
