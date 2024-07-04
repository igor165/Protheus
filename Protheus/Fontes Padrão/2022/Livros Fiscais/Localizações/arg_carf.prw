#INCLUDE "PROTHEUS.CH"
#INCLUDE "ARG_CARF.CH"

#DEFINE CGETFILE_TYPE GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE
#DEFINE _SEPARADOR ";"
/*Estrutura do registro do arquivo de contribuintes*/
#DEFINE PUBLICACAO		1		//Fecha de Publicacion
#DEFINE INICIOVIGENCIA	2		//Fecha Vigencia Desde
#DEFINE FIMVIGENCIA		3		//Fecha Vigencia Hasta
#DEFINE CUIT	   		4		//Numero de Cuit
#DEFINE TIPOCONTRINSC	5		//Tipo-Contr_Insc
#DEFINE MARCAALTASUJ	6		//Marca-alta-sujeto
#DEFINE MARCAALIQUOTA	7		//Marca-alicuota
#DEFINE ALIQPERCEPCION	8		//Alicuota- Percepcion
#DEFINE ALIQRETENCION	9		//Alicuota- Retencion 
#DEFINE GRPPERCEPCION	10		//Nro-Grupo-Percepcion
#DEFINE GRPRETENCION	11		//Nro-Grupo-Retencion
#DEFINE RAZAOSOCIAL		12		//Razon Social
/*Codigos para situacao dos clientes/fornecedores */
#DEFINE  SIT_NORMAL			"1"
#DEFINE  SIT_RISCO			"2"
#DEFINE  SIT_PERCEPCAO		"3"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ARGCARF   ºAutor  ³Marcello Gabriel    ºFecha ³ 26/11/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processa os arquivo com contribuintes considerados de alto º±±
±±º          ³ risco. Esse contribuintes terao aliquotas diferenciadas    º±±
±±º          ³ para percepcao e retencao de impostos.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Argentina                                                  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³08/07/15³PCREQ-4256³Se elimina la funcion AjustaSX1() que ³±±
±±³            ³        ³          ³hace modificacion a SX1 por motivo de ³±±
±±³            ³        ³          ³adecuacion a fuentes a nuevas estruc- ³±±
±±³            ³        ³          ³turas SX para Version 12.             ³±±
±±³M.Camargo   ³09.11.15³          ³Merge sistemico v12.1.8		          ³±±
±±³Marco A. Glz³13/02/17³  MMI-274 ³Se realiza Replica para V12.1.14 que  ³±±
±±³            ³        ³          ³incluyen los cambios de los issues    ³±±
±±³            ³        ³          ³MMI-217 y MMI-130. (ARG)              ³±±
±±³Oscar G.    ³27/02/19³DMINA-6158³En Fun. CARFProArq se realiza tratami-³±±
±±³            ³        ³          ³ento para fechas y alicuotas importa- ³±±
±±³            ³        ³          ³dos desde TXT. (ARG)                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ArgCARF()
	
	Local cMensaje := ""

	Private cPerg	:= "ARCARF"
	Private cItPerg	:= "01,02
	Private nNuevosReg := 0
	Private nModifReg := 0

	If CARFVerif()
		If Pergunte(cPerg,.T.)
			Arg_CARF()
			If nNuevosReg > 0
				cMensaje += Iif( nNuevosReg == 1, OemToAnsi(Strtran(STR0029, "#nRegistros#", AllTrim(Str(nNuevosReg)))), OemToAnsi(Strtran(STR0030, "#nRegistros#", AllTrim(Str(nNuevosReg))))) //"Se creó #nRegistros# registro nuevo" ## "Se crearon #nRegistros# registros nuevos"
			EndIf
			cMensaje += Iif(nNuevosReg > 0 .And. nModifReg > 0, CRLF, "")
			If nModifReg > 0
				cMensaje += Iif( nModifReg == 1, OemToAnsi(Strtran(STR0038, "#nRegistros#", AllTrim(Str(nModifReg)))), OemToAnsi(Strtran(STR0039, "#nRegistros#", AllTrim(Str(nModifReg))))) //"Se actualizó #nRegistros# registro" ## "Se actualizaron #nRegistros# registros"
			EndIf
			If Empty(cMensaje)
				Aviso( OemToAnsi(STR0028), OemToAnsi(STR0033), {STR0032}) //"Importación de Contribuyentes" - "No se realizaron cambios." - "OK"
			Else
				Aviso( OemToAnsi(STR0028), cMensaje, {STR0032}) //"Importación de Contribuyentes" ## "OK"
			EndIf
		Else
			Aviso( OemToAnsi(STR0028), OemToAnsi(STR0033), {STR0032}) //"Importación de Contribuyentes" - "No se realizaron cambios." - "OK"
		Endif
	Else
		Aviso(OemToAnsi(STR0028), OemToAnsi(STR0034), {STR0032}) //"Importación de Contribuyentes" - "Proceso cancelado." - "OK"
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CARFVERIF ºAutor  ³Marcello Gabriel    ºFecha ³ 11/12/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o ambiente foi alterado para uso do CARF.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ARGCARF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CARFVerif()

	Local lRet	:= .T.
	Local cItem	:= cItPerg
	Local nPos	:= 0

	//Verifica se os novos campos foram criados.
	lRet := SFH->(FieldPos("FH_INIVIGE")) > 0
	lRet := SFH->(FieldPos("FH_FIMVIGE")) > 0
	If lRet
		SX1->(DbSetORder(1))
		SX1->(DbSeek(cPerg))
		While lRet  .And. !(SX1->(Eof())) .And. AllTrim(SX1->X1_GRUPO) == Alltrim(cPerg)
			nPos := At(SX1->X1_ORDEM,cItem)
			If nPos > 0
				cItem := AllTrim(Substr(cItem,nPos+3))
			Else
				lRet := .F.
			Endif
			SX1->(DbSkip())
		Enddo
		lRet := Empty(cItem)
	Endif
	If !lRet
		MsgStop(STR0002, STR0001)	//"Este proceso debe ser ejecutado desde el servidor que contiene la base de datos de Protheus y además debe ser SQL Server." - "Importación de Padrón de Contribuyentes con alto Riesgo Fiscal"
		lRet := .F.
	Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ARG_CARF  ºAutor  ³Marcello Gabriel    ºFecha ³ 26/11/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processa os arquivo com contribuintes considerados de alto º±±
±±º          ³ risco. Esses contribuintes terao aliquotas diferenciadas   º±±
±±º          ³ para "percepcao" e retencao de impostos.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Argentina                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Arg_CARF()

	Local cArq	:= Space(200)
	Local aArea	:= {}
	Local oDlg
	Local oPnlTopo
	Local oPnlBase
	Local oPnlCentro
	Local oPnlArq
	Local oPnl1
	Local oPnl2
	Local oPnl3
	Local oPnl4
	Local oPnl5
	Local oPnl6
	Local oPnlSepar
	Local oPnlSepar1
	Local oPnlBotao
	Local oFonte
	Local oArq
	Local lRet	:= .F.

	If !VldContSim(2)
		Return
	EndIf

	aArea := GetArea()
	oFonte := TFont():New("Arial",,,,.T.,,,8,.F.,,,,,,,)
	oDlg:=TDialog():New(0,0,110,500,STR0001,,,,,,,,,.T.,,,,,)		//"Importación de Padrón de Contribuyentes con alto Riesgo Fiscal"
	oPnl5:= TPanel():New(01,01,,oDlg,,,,,RGB(221,221,221),5,5,.F.,.F.)
	oPnl5:Align := CONTROL_ALIGN_LEFT
	oPnl5:nWidth := 5
	oPnl6:= TPanel():New(01,01,,oDlg,,,,,RGB(221,221,221),5,5,.F.,.F.)
	oPnl6:Align := CONTROL_ALIGN_RIGHT
	oPnl6:nWidth := 5
	oPnlTopo := TPanel():New(01,01,,oDlg,,,,,RGB(221,221,221),5,30,.F.,.F.)
	oPnlTopo:Align := CONTROL_ALIGN_TOP
	oPnlTopo:nHeight := 50
	oPnlArq := TPanel():New(01,01,,oPnlTopo,,,,,RGB(221,221,221),5,5,.F.,.F.)
	oPnlArq:Align := CONTROL_ALIGN_BOTTOM
	oPnlArq:nHeight := 20
	oPnl1:= TPanel():New(01,01,,oPnlArq,,,,,RGB(221,221,221),5,5,.F.,.F.)
	oPnl1:Align := CONTROL_ALIGN_LEFT
	oPnl1:nWidth := 5
	oPnlBotao:= TPanel():New(01,01,,oPnlArq,,,,,RGB(221,221,221),5,5,.F.,.F.)
	oPnlBotao:Align := CONTROL_ALIGN_RIGHT
	oPnlBotao:nWidth := 45
	oBtnArq := TBtnBmp2():New(003,091,25,28,"folder6","folder6" ,,,{|| CARFSelArq(oArq)},oPnlBotao,STR0004,,.T.)	//"Seleção do arquivo"
	oBtnArq:Align := CONTROL_ALIGN_LEFT
	oBtnPar := TBtnBmp2():New(003,091,25,28,"parametros","parametros" ,,,{|| Pergunte(cPerg,.T.)},oPnlBotao,STR0005,,.T.)		//"Parâmetros"
	oBtnPar:Align := CONTROL_ALIGN_RIGHT
	oBtnParlVisible := .T.
	@00,00 MSGET oArq VAR cArq SIZE 5,5 PIXEL OF oPnlArq
	oArq:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlTit := TPanel():New(01,01,"  " + STR0006,oPnlTopo,oFonte,,,,RGB(221,221,221),5,30,.F.,.F.)		//"Arquivo de contribuintes"
	oPnlTit:Align := CONTROL_ALIGN_BOTTOM
	oPnlTit:nHeight := 15
	oPnl3:= TPanel():New(01,01,,oDlg,,,,,RGB(221,221,221),5,5,.F.,.F.)
	oPnl3:Align := CONTROL_ALIGN_TOP
	oPnl3:nHeight := 20
	oPnlBase := TPanel():New(01,01,,oDlg,,,,,RGB(221,221,221),5,30,.F.,.F.)
	oPnlBase:Align := CONTROL_ALIGN_BOTTOM
	oPnlBase:nHeight := 25
	DEFINE SBUTTON oBtnCan FROM 013,350 TYPE 2 ACTION (If(MsgYesNo(STR0007,STR0001),(lProcessar := .F.,oPnlTopo:lActive := .T.,oBtnSai:lVisible := .T.,oBtnProc:lVisible := .T.,oBtnCan:lVisible := .T.,oPnlSepar1:lVisible := .F.,oArq:SetFocus()),lProcessar := .T.)) ENABLE PIXEL OF oPnlBase	//"¿Desea anular el procesamiento del archivo de contribuyentes ?" - "Importación de Padrón de Contribuyentes con alto Riesgo Fiscal"
	oPnlSepar1 := TPanel():New(01,01,,oPnlBase,,,,,RGB(221,221,221),5,30,.F.,.F.)
	oPnlSepar1:Align := CONTROL_ALIGN_RIGHT
	oPnlSepar1:lVisible := .T.
	DEFINE SBUTTON oBtnSai FROM 010,40 TYPE 2 ACTION (oDlg:End()) ENABLE PIXEL OF oPnlBase
	oBtnSai:cToolTip:=STR0009		//"Sair"
	oBtnSai:Align := CONTROL_ALIGN_RIGHT
	oPnlSepar := TPanel():New(01,01,,oPnlBase,,,,,RGB(221,221,221),5,30,.F.,.F.)
	oPnlSepar:Align := CONTROL_ALIGN_RIGHT
	DEFINE SBUTTON oBtnProc FROM 010,40 TYPE 1 ACTION If(CARFValArq(oArq),(oBtnSai:lVisible := .F.,oPnlTopo:lActive := .F.,oBtnProc:lVisible := .F.,oBtnCan:lVisible := .T.,oPnlSepar1:lVisible := .T.,If(CARFProArq(AllTrim(cArq),oPnlCentro),oDlg:End(),)),) ENABLE PIXEL OF oPnlBase
	oBtnProc:cToolTip:=STR0010		//"Processar arquivo informado"
	oBtnProc:Align := CONTROL_ALIGN_RIGHT
	oPnlCentro := TPanel():New(01,01,,oDlg,,,,,RGB(221,221,221),5,5,.F.,.F.)
	oPnlCentro:Align := CONTROL_ALIGN_ALLCLIENT
	oDlg:lCentered := .T.
	oDlg:Activate()
	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CARFSELARQºAutor  ³Marcello Gabriel    ºFecha ³ 26/11/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ativa o seletor de arquivos                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CARFSelArq(oArq)

	Local cArquivo := ""

	cArquivo := cGetFile("Texto (*.txt) |*.TXT|Todos (*.*) |*.*|","Seleciona arquivo",0,"C:\",.T.,CGETFILE_TYPE)
	If !Empty(cArquivo)
		oArq:cText := cArquivo
		oArq:Refresh()
	Endif
	oArq:SetFocus()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CARFVALARQºAutor  ³Marcello Gabriel    ºFecha ³ 26/11/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o arquivo informado para processamento              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CARFValArq(oArq)

	Local lRet	:= .T.
	Local cArq	:= ""

	cArq := AllTrim(oArq:cText)
	If Empty(cArq)
		lRet := .F.
		MsgAlert(STR0011,STR0001)	//"Informe el archivo de contribuyentes" - "Importación de Padrón de Contribuyentes con alto Riesgo Fiscal"
		oArq:SetFocus()
	Else
		If !File(cArq)
			lRet := .F.
			MsgAlert(STR0012 + "  " + cArq + " " + STR0013, STR0001)	//"Archivo" - "no encontrado" - "Importación de Padrón de Contribuyentes con alto Riesgo Fiscal"
			oArq:SetFocus()
		Endif
	Endif

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CARFPROArqºAutor  ³Marcello Gabriel    ºFecha ³ 26/11/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processa o arquivo de contribuintes atualizando os arquivos º±±
±±ºDesc.     ³de fornecedores, clientes e aliquotas.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CARFProArq(cArq,oDlg)

	Local cCUITEmp		:= ""
	Local cAliasSA1	:= ""
	Local cAliasSA2	:= ""
	Local nRTot		:= 0
	Local nReg			:= 0
	Local nNrReg		:= 0
	Local nContReg		:= 0
	Local lRet			:= .T.
	Local lImpSql		:= .F.
	Local lExfile		:= .F.
	Local lProcesa	:= .F.
	local lcTipo		:= ""
	Local aReg			:= {}
	Local aArea			:= {}
	Local oMeter
	Local oPnlCon
	Local oPnlMtr
	Local oFonte
	Local oSay
	Local lVBanco	:= "MSSQL"$Upper(TCGetDB())
	Local dInVig := Ctod("//")
	Local dFiVig := Ctod("//")
	Local nAliqRP:=  0

	Private lProcessar	:= .F.		//Controla o processamento
	Private aEstrTxt	:= {}		//Estrutura do registro do arquivo de contribuintes
	Private	 cPercepcao	:= "IBP"	//Imposto "percepcao" que sera considerado no processo
	Private	 cRetencao	:= "IBR"	//Impostos "retencao" que sera considerado no processo
	Private cZonaFis	:= "CF"		//Zona fiscal qu			e sera considerada no processo
	Private cAliasFor	:= ""		//Alias para o arquivo com os fornecedores que estao em "risco fiscal"
	Private cArqFor		:= ""		//Arquivo temporario com os fornecedores que estao em "risco fiscal"
	Private cAliasCli	:= ""		//Alias para o arquivo com os clientes que estao em "risco fiscal"
	Private cArqCli		:= ""		//Arquivo temporario com os clientes que estao em "risco fiscal"
	Private cAliasSFH	:= ""		//Alias do arquivo temporario para verificar se ja existem registros processados do arquivo txt
	Private cArqSFH		:= ""		//Arquivo temporario para verificar se ja existem registros processados do arquivo txt
	Private lProcCli	:= .F.		//Indica se serao processados clientes
	Private lProcFor	:= .F.		//Indica se serao processados fornecedores
	Private lProcPer	:= .F.		//Indica se serao atualizadas as aliquotas para "percepcao"
	Private lProcRet	:= .F.		//Indica se serao atualizadas as aliquotas para "retencao"
	Private lProcSim    := .F.		//Indica se será processado o arquivo de Contribuintes de Regime Simplificado

	Private nAlqPerFor	:= 0
	Private dIniVig		:= Ctod("//")
	Private dFimVig		:= Ctod("//")
	Private cContInsc	:= ""
	Private aEstSFH		:= {}
	Private lCUITEMP	:= .F.
	Private dFchIniV	:= CTOD("//")
	Private nMes		:= 0
	Private nAno		:= 0
	Private dFchVenc    := Ctod("//")

	Default cArq := ""

	//Estrutura do registro do arquivo de contribuintes
	Aadd(aEstrTxt,{"DTPUBLIC","D",8,0})					//Fecha de Publicacion
	Aadd(aEstrTxt,{"DTINIVIG","D",8,0})					//Fecha Vigencia Desde
	Aadd(aEstrTxt,{"DTFIMVIG","D",8,0})					//Fecha Vigencia Hasta
	Aadd(aEstrTxt,{"NRCUIT","C",TamSX3("A1_CGC")[1],0})	//Numero de Cuit
	Aadd(aEstrTxt,{"TIPCONTINS","C",1,0})				//Tipo-Contr_Insc
	Aadd(aEstrTxt,{"MARCALTSUJ","C",1,0})				//Marca-alta-sujeto
	Aadd(aEstrTxt,{"MARCAALIQ","C",1,0})				//Marca-alicuota
	Aadd(aEstrTxt,{"ALIQPERC","N",5,2})					//Alicuota- Percepcion
	Aadd(aEstrTxt,{"ALIQRETE","N",5,2})					//Alicuota- Retencion
	Aadd(aEstrTxt,{"GRPPERCE","N",2,0})					//Nro-Grupo-Percepcion
	Aadd(aEstrTxt,{"GRPRETEN","N",2,0})					//Nro-Grupo-Retencion
	Aadd(aEstrTxt,{"RAZAOSOC","C",60,0})					//Razon Social

	cArq := AllTrim(cArq)
	If File(cArq)
		If MsgYesNo(STR0014  + " " + cArq + " ?", STR0001)		//"Confirma o processamento do arquivo de contribuintes" - "Importación de Padrón de Contribuyentes con alto Riesgo Fiscal"

			//contribuinte a processar
			lProcCli := (MV_PAR01 == 2 .Or. MV_PAR01 == 3)		//processar clientes
			lProcFor := (MV_PAR01 == 1 .Or. MV_PAR01 == 3)		//processar fornecedores
			//aliquota a processar
			lProcRet := (MV_PAR02 == 1 .Or. MV_PAR02 == 3)		//processar retencoes
			lProcPer := (MV_PAR02 == 2 .Or. MV_PAR02 == 3)		//processar percepcoes
			//Tipo do Contribuinte de Regime Simplificado
			lProcSim := (MV_PAR03 == 2)

			If lVBanco .AND. !lProcSim 
				lExfile := ImpASql(cArq) 
			Endif

			If lProcSim
				dFchIniV := (MV_PAR04)
				nAno := Year(MV_PAR04)//Substr(DTOS(MV_PAR04),1,4)
				nMes := Month(MV_PAR04)//Substr(DTOS(MV_PAR04),5,2)
				dFchVenc := RetFecha(nMes, nAno)
			EndIf              

			cCUITEmp := AllTrim(SM0->M0_CGC)

			aArea := GetArea()
			aReg := {} 

			If lVBanco
				// Proceso SQL //
				If lProcSim
					If FT_FUse(cArq) > 0
						MsAguarde({ | | ProcSimpl(cArq)},OemToAnsi(STR0015)) //"Procesando el archivo de contribuyentes"
					EndIf
				ElseIf lExfile
					If lProcCli .or. lProcFor
						oFonte := TFont():New("Arial",,,,.T.,,,8,.F.,,,,,,,)
						oPnlCon := TPanel():New(01,01,STR0015 + ".",oDlg,oFonte,,,,RGB(221,221,221),5,30,.F.,.F.)		//"Processando o arquivo de contribuintes"
						oPnlCon:Align := CONTROL_ALIGN_TOP
						oPnlCon:nHeight := 15
						oSay := TSay():New(0,0,{|| ""},oDlg,,,,,,.T.,,,10,10)
						oSay:Align := CONTROL_ALIGN_TOP
						oSay:nHeight := 15
						oPnlMtr := TPanel():New(01,01,,oDlg,,,,,RGB(221,221,221),5,30,.F.,.F.)
						oPnlMtr:Align := CONTROL_ALIGN_TOP
						oPnlMtr:nHeight := 40
						oMeter:=TMeter():New(60,05,,100,oPnlMtr,150,10,,.T.,,STR0016,.T.,,,,,.F.)		//"Contribuintes"
						oMeter:Align := CONTROL_ALIGN_TOP
						oMeter:nHeight := 15
						oMeter:Set(0)
						nReg := 0
						nContReg := 0
						oDlg:Refresh()
						ProcessMessages()
					Endif 

					If lProcCli // Tabla temporal con los registros de clientes que existen en el padron 
						cAliasSA1:= GetNextAlias()
						lProcessar := CtesSql(cAliasSA1)
						DbSelectArea(cAliasSA1)
						Count to nRTot
						(cAliasSA1)->(DbGoTop())
					Endif 
					If	lProcFor // Tabla temporal con los registros de proveedores que existen en el padron
						cAliasSA2 := GetNextAlias()
						lProcessar := ProvSql(cAliasSA2)
						DbSelectArea(cAliasSA2)
						Count to nNrReg
						nNrReg += nRTot 
						(cAliasSA2)->(DbGoTop())
					Endif

					If lProcCli .and. (cAliasSA1)->(!EOF()) // Procesamiento Clientes
						While (cAliasSA1)->(!EOF())
							oSay:cCaption := AllTrim((cAliasSA1)->NRCUIT) + " - " + Alltrim((cAliasSA1)->RAZAOSOC)
							//Processamento de clientes
							If lProcPer		// Verifica/cria a aliquota de "percepcao" para o cliente
								dInVig := Ctod(Substr((cAliasSA1)->DTINIVIG,1,2) + "/" + Substr((cAliasSA1)->DTINIVIG,3,2) + "/" + Substr((cAliasSA1)->DTINIVIG,5)) 
								dFiVig := Ctod(Substr((cAliasSA1)->DTFIMVIG,1,2) + "/" + Substr((cAliasSA1)->DTFIMVIG,3,2) + "/" + Substr((cAliasSA1)->DTFIMVIG,5)) 
								nAliqRP := Val(StrTran((cAliasSA1)->ALIQPERC,",","."))

								If !lProcSim //Importante
									If (cAliasSA1)->TIPCONTINS == "D"
										lcTipo := "I"
									ElseIf (cAliasSA1)->TIPCONTINS == "C"
										lcTipo := "V"
									EndIf
								Else
									lcTipo := "M"
								EndIf

								CARFCliPer((cAliasSA1)->NRCUIT ,nAliqRP,dInVig,dFiVig,lcTipo)
							Endif
							(cAliasSA1)->(DbSkip())

							nContReg++
							nReg := Int((100 * nContReg) / nNrReg)

							oMeter:Set(nReg)
							ProcessMessages()
						Enddo
					Endif 

					If	lProcFor .and. (cAliasSA2)->(!EOF()) // Procesamiento proveedores							
						While (cAliasSA2)->(!EOF())  
							oSay:cCaption := AllTrim((cAliasSA2)->NRCUIT) + " - " + Alltrim((cAliasSA2)->RAZAOSOC)
							dInVig := Ctod(Substr((cAliasSA2)->DTINIVIG,1,2) + "/" + Substr((cAliasSA2)->DTINIVIG,3,2) + "/" + Substr((cAliasSA2)->DTINIVIG,5)) 
							dFiVig := Ctod(Substr((cAliasSA2)->DTFIMVIG,1,2) + "/" + Substr((cAliasSA2)->DTFIMVIG,3,2) + "/" + Substr((cAliasSA2)->DTFIMVIG,5)) 
							nAliqRP := Val(StrTran((cAliasSA2)->ALIQRETE,",","."))

							If !lProcSim //Importante
								If (cAliasSA2)->TIPCONTINS == "D"
									lcTipo := "I"
								ElseIf (cAliasSA2)->TIPCONTINS == "C"
									lcTipo := "V"
								EndIf
							Else
								lcTipo := "M"
							EndIf

							If lProcPer		// Verifica/cria a aliquota de "percepcao" para o cliente siga
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Caso o cliente siga esteja no arquivo de contribuintes de ³
								//³alto risco, os dados sao guardados para a atualizacao da  ³
								//³aliquota de "percepcao" dos fornecedores.                 ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If AllTrim((cAliasSA2)->NRCUIT) == cCUITEmp
									nAlqPerFor	:= (cAliasSA2)->ALIQPERC
									dIniVig	:= dInVig
									dFimVig	:= dFiVig
									cContInsc  := lcTipo
								Endif
							Endif

							If lProcRet		// Verifica/cria a aliquota de retencao para o fornecedor
								CARFForRet((cAliasSA2)->NRCUIT ,nAliqRP, dInVig, dFiVig, lcTipo)
							Endif
							(cAliasSA2)->(DbSkip())
							
							nContReg++
							nReg := Int((100 * nContReg) / nNrReg)
							oMeter:Set(nReg)
							ProcessMessages()
						Enddo
						//Processamento de fornecedores
						If lProcFor
							If lProcPer
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Caso o cliente siga esteja no arquivo de contribuintes de alto³
								//³risco ou de Regime simplificado atualiza aliquota de 		 ³
								//³"percepcao" dos fornecedores.     						     ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If nAlqPerFor <> 0
									CARFForPer(cCUITEmp,nAlqPerFor,dIniVig,dFimVig,oDlg,cContInsc)
								Endif
							Endif
						Endif
					Endif 

					If lProcCli
						If Select(cAliasSA1) > 0
							DbSelectArea(cAliasSA1)
							DbCloseArea()
						Endif
					Endif 

					If lProcFor
						If Select(cAliasSA2) > 0
							DbSelectArea(cAliasSA2)
							DbCloseArea()
						Endif
					Endif 

					lRet := .T.
				EndIf
				//FIN DE PROCESO SQL //	   	
			ElseIf FT_FUse(cArq) > 0
				If lProcSim
					MsAguarde({ | | ProcSimpl(cArq)},OemToAnsi(STR0015)) //"Procesando el archivo de contribuyentes"
				Else
					FT_FGotop()
					nNrReg := FT_FLastRec()
					If nNrReg > 0  .and. (";"$(FT_FREADLN()))
						oFonte := TFont():New("Arial",,,,.T.,,,8,.F.,,,,,,,)
						oPnlCon := TPanel():New(01,01,STR0015 + ".",oDlg,oFonte,,,,RGB(221,221,221),5,30,.F.,.F.)		//"Processando o arquivo de contribuintes"
						oPnlCon:Align := CONTROL_ALIGN_TOP
						oPnlCon:nHeight := 15
						oSay := TSay():New(0,0,{|| ""},oDlg,,,,,,.T.,,,10,10)
						oSay:Align := CONTROL_ALIGN_TOP
						oSay:nHeight := 15
						oPnlMtr := TPanel():New(01,01,,oDlg,,,,,RGB(221,221,221),5,30,.F.,.F.)
						oPnlMtr:Align := CONTROL_ALIGN_TOP
						oPnlMtr:nHeight := 40
						oMeter:=TMeter():New(60,05,,100,oPnlMtr,150,10,,.T.,,STR0016,.T.,,,,,.F.)		//"Contribuintes"
						oMeter:Align := CONTROL_ALIGN_TOP
						oMeter:nHeight := 15
						oMeter:Set(0)
						nReg := 0
						nContReg := 0
						lProcessar := .T.
						oDlg:Refresh()
						ProcessMessages()
						While lProcessar .And. !(FT_FEof())
							aReg := CARFLeReg()
							dInVig := aReg[INICIOVIGENCIA] 
							dFiVig := aReg[FIMVIGENCIA]

							oSay:cCaption := AllTrim(aReg[CUIT]) + " - " + Iif(Len(aReg)< RAZAOSOCIAL," ", Alltrim(aReg[RAZAOSOCIAL]))
							//Processamento de clientes
							If lProcCli
								If lProcPer		// Verifica/cria a aliquota de "percepcao" para o cliente
									CARFCliPer(aReg[CUIT],aReg[ALIQPERCEPCION],dInVig,dFiVig,aReg[TIPOCONTRINSC])
								Endif
							Endif
							//Processamento de fornecedores
							If lProcFor
								If lProcPer		// Verifica/cria a aliquota de "percepcao" para o cliente siga
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Caso o cliente siga esteja no arquivo de contribuintes de ³
									//³alto risco, os dados sao guardados para a atualizacao da  ³
									//³aliquota de "percepcao" dos fornecedores.                 ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If AllTrim(aReg[CUIT]) == cCUITEmp
										nAlqPerFor		:= aReg[ALIQPERCEPCION]
										dIniVig		:= dInVig
										dFimVig		:= dFiVig
										cContInsc   := aReg[TIPOCONTRINSC]
									Endif
								Endif
								If lProcRet		// Verifica/cria a aliquota de retencao para o fornecedor
									CARFForRet(aReg[CUIT],aReg[ALIQRETENCION],dInVig,dFiVig,aReg[TIPOCONTRINSC])
								Endif
							Endif
							nContReg++
							nReg := Int((100 * nContReg) / nNrReg)
							oMeter:Set(nReg)
							FT_FSkip()
							ProcessMessages()
						Enddo
						//Processamento de fornecedores
						If lProcFor
							If lProcPer
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Caso o cliente siga esteja no arquivo de contribuintes de alto³
								//³risco ou de Regime simplificado atualiza aliquota de 		 ³
								//³"percepcao" dos fornecedores.     						     ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If nAlqPerFor <> 0
									CARFForPer(cCUITEmp,nAlqPerFor,dIniVig,dFimVig,oDlg,cContInsc)
								Endif
							Endif
						Endif
					Endif 
				EndIf

				lRet := .F.  
				FT_FUse() 

				If lRet
					oSay:Free() 

					ProcessMessages()
					If lProcessar
						CARFNormais(oDlg)
						MsgAlert(STR0017, STR0001)	//"Processo encerrado" - "Importación de Padrón de Contribuyentes con alto Riesgo Fiscal"
					Else
						lRet := .F.
					Endif

					MsUnLockAll()
					DbCommitAll()
					If lProcCli
						If Select(cAliasCli) > 0
							DbSelectArea(cAliasCli)
							DbCloseArea()
							If File(cArqCli + GetDBExtension())
								Ferase(cArqCli + GetDBExtension())
							EndIf
							If File(cArqCli + OrdBagExt())
								Ferase(cArqCli + OrdBagExt())
							EndIf
						Endif
					Endif
					If lProcFor
						If Select(cAliasFor) > 0
							DbSelectArea(cAliasFor)
							DbCloseArea()
							If File(cArqFor + GetDBExtension())
								Ferase(cArqFor + GetDBExtension())
							EndIf
							If File(cArqFor + OrdBagExt())
								Ferase(cArqFor + OrdBagExt())
							EndIf
						Endif
					Endif
					If Select(cAliasSFH) > 0
						DbSelectArea(cAliasSFH)
						DbCloseArea()
						If File(cArqSFH + GetDBExtension())
							Ferase(cArqSFH + GetDBExtension())
						EndIf
						If File(cArqSFH + OrdBagExt())
							Ferase(cArqSFH + OrdBagExt())
						EndIf
					Endif
					oPnlCon:Free()
					oMeter:Free()
					oPnlMtr:Free()
				Else  
					lRet := .T.
				Endif

			Else
				MsgStop(STR0018,STR0001)	//"Não foi possível abrir o arquivo de contribuintes" - "Importación de Padrón de Contribuyentes con alto Riesgo Fiscal"
			Endif
			RestArea(aArea)
		Endif
	Else
		lRet := .F.
		MsgAlert(STR0012 + " " + cArq + " " + STR0013, STR0001)	//"Archivo" - "no encontrado" - "Importación de Padrón de Contribuyentes con alto Riesgo Fiscal"
	Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ARGCARFLEREGºAutor  ³Marcello Gabriel    ºFecha ³ 26/11/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Le uma linha do arquivo texto e separa os campos no array     º±±
±±º          ³aReg, recebido como paramento. Este array deve possuir tantos º±±
±±º          ³elementos quantos forem o numero de campos do registro no txt.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CARFLeReg(aReg)

	Local cReg		:= ""
	Local cAux		:= ""
	Local cSepar	:= ";"
	Local nPos		:= 0
	Local nContCpo	:= 0
	Local aRet		:= {}
	Local nCountSep := 0

	cReg := FT_FReadLn()
	aRet := Separa(FT_FREADLN(),_SEPARADOR)

	While !Empty(cReg) .And. nCountSep <= 11
		nCountSep++
		nContCpo++
		nPos := At(cSepar,cReg)
		If nPos == 0
			nPos := Len(cReg) + 1
		Endif
		cAux := Substr(cReg,1,nPos-1)
		cReg := Substr(cReg,nPos+1)
		Do Case
			Case aEstrTxt[nContCpo,2] == "D"
			Aadd(aRet,Ctod(Substr(cAux,1,2) + "/" + Substr(cAux,3,2) + "/" + Substr(cAux,5)))
			Case aEstrTxt[nContCpo,2] == "N"
			Aadd(aRet,Val(StrTran(cAux,",",".")))
			Case aEstrTxt[nContCpo,2] == "C"
			Aadd(aRet,AllTrim(cAux))
		EndCase
	Enddo

	If !lProcSim .and. Len(aRet) > 5
		If aRet[TIPOCONTRINSC] == "D"
			aRet[TIPOCONTRINSC] := "I"
		ElseIf aRet[TIPOCONTRINSC] == "C"
			aRet[TIPOCONTRINSC] := "V"
		EndIf
	Else
		aRet[TIPOCONTRINSC] := "M"
	EndIf

Return (aClone(aRet))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CARFFORRET  ºAutor  ³Marcello Gabriel    ºFecha ³ 01/12/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processa o registro atual do arquivo de contribuintes.        º±±
±±º          ³Verifica se o contribuinte esta no cadastro de fornecedores e º±±
±±º          ³se necessario, cria o registro na tabela SFH com a aliquota   º±±
±±º          ³para retencao.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CARFForRet(cCuit,nAlqRet,dInicio,dFim,cContInsc)

	Local lExSFH	:= .F.

	SA2->(DbSetOrder(3))
	//Verifica se o contribuinte esta no arquivo de fornecedores
	cCuit := PadR(cCuit,TamSX3("A2_CGC")[1])
	If SA2->(DbSeek(xFilial("SA2") + cCuit))
		//cria-se ou altera-se o registro no arquivo SFH para a "aliquota de risco" para retencao
		While  cCuit==SA2->A2_CGC  .And. !SA2->(EOF())
			If lProcSim
				SA2->(DbSkip())
				Loop
			EndIf
			lExSFH := .F.
			If SA2->A2_RETIB == "S"
				SFH->(DbSetOrder(1)) //FH_FILIAL+FH_FORNECE+FH_LOJA+FH_IMPOSTO+FH_ZONFIS                                                                                                               
				If SFH->(DbSeek(xFilial("SFH") + SA2->A2_COD + SA2->A2_LOJA + cRetencao + cZonaFis))
					While SFH->(!EOF()) .and. SFH->FH_FORNECE == SA2->A2_COD .and. SFH->FH_IMPOSTO == cRetencao .and. SFH->FH_ZONFIS == cZonaFis
						If SFH->FH_INIVIGE == dInicio .and. SFH->FH_FIMVIGE == dFim
							lExSFH := .T.
							exit  
						Endif
						SFH->(DbSkip())
					Enddo
				Endif
				If lExSFH
					RecLock("SFH",.F.)
					Replace SFH->FH_PERCIBI	With "S"
					Replace SFH->FH_ISENTO	With "N"
					Replace SFH->FH_APERIB	With "S"
					Replace SFH->FH_INIVIGE	With dInicio
					Replace SFH->FH_FIMVIGE	With dFim
					Replace SFH->FH_TIPO    With cContInsc
					nModifReg++
				Else
					RecLock("SFH",.T.)
					Replace SFH->FH_FILIAL	With xFilial("SFH")
					Replace SFH->FH_AGENTE	With "S"
					Replace SFH->FH_ZONFIS	With cZonaFis
					Replace SFH->FH_FORNECE	With SA2->A2_COD
					Replace SFH->FH_LOJA	With SA2->A2_LOJA
					Replace SFH->FH_IMPOSTO	With cRetencao
					Replace SFH->FH_PERCIBI	With "S"
					Replace SFH->FH_ISENTO	With "N"
					Replace SFH->FH_APERIB	With "S"
					Replace SFH->FH_INIVIGE	With dInicio
					Replace SFH->FH_FIMVIGE	With dFim
					Replace SFH->FH_TIPO    With cContInsc
					Replace SFH->FH_NOME    With SA2->A2_NOME
					nNuevosReg++
				Endif
				Replace SFH->FH_ALIQ With nAlqRet
				If SFH->(FieldPos("FH_SITUACA")) > 0
					If lProcSim                                               
						Replace SFH->FH_SITUACA	With "3"	//cliente de Monotributista   - Tipo do Contribuinte de Regime Simplificado
					Else
						Replace SFH->FH_SITUACA	With "2"	//cliente de risco fiscal
					EndIf       
				EndIf
				SFH->(MsUnLock())   	
			Endif
			SA2->(DbSkip())
		EndDo
	Endif
	
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CARFFORPER  ºAutor  ³Marcello Gabriel    ºFecha ³ 10/12/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria a aliquota de risco para  "percepcao" dos fornecedores.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CARFForPer(cCuit,nAlqPer,dInicio,dFim,oDlg,cContInsc)

	Local cQuery	:= ""
	Local cAliasSA2	:= ""
	Local oFonte
	Local oPnlCon
	Local lExSFH	:= .F.

	If lProcessar
		oFonte := TFont():New("Arial",,,,.T.,,,8,.F.,,,,,,,)
		oPnlCon := TPanel():New(01,01,STR0019 + ".",oDlg,oFonte,,,,RGB(221,221,221),5,30,.F.,.F.)		//"Atualizando a alíquota de percepção dos fornecedores"
		oPnlCon:Align := CONTROL_ALIGN_TOP
		oPnlCon:nHeight := 40
		#IFDEF TOP
		cAliasSA2 := GetNextAlias()
		cQuery := "select A2_COD,A2_LOJA,A2_CGC,A2_NOME  from " + RetSqlName("SA2")
		cQuery += " where A2_FILIAL = '" + xFilial("SA2") + "'"
		cQuery += " and A2_PERCIB = 'S'"
		cQuery += " and D_E_L_E_T_=''"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA2,.T.,.T.)
		#ELSE
		cQuery += "A2_FILIAL = '" + xFilial("SA2") + "'"
		cQuery += " .And. A2_PERCIB == 'S'"
		SA2->(DbSetFilter({|| &cQuery},cQuery))
		cAliasSA2 := "SA2"
		#ENDIF
		(cAliasSA2)->(DbGoTop())
		While lProcessar .And. !((cAliasSA2)->(Eof()))
			lExSFH := .F.
			SFH->(DbSetOrder(1)) //FH_FILIAL+FH_FORNECE+FH_LOJA+FH_IMPOSTO+FH_ZONFIS                                                                                                               
			If SFH->(DbSeek(xFilial("SFH") + (cAliasSA2)->A2_COD + (cAliasSA2)->A2_LOJA + cPercepcao + cZonaFis))
				While SFH->(!EOF()) .and. SFH->FH_FORNECE == (cAliasSA2)->A2_COD .and. SFH->FH_IMPOSTO == cPercepcao .and. SFH->FH_ZONFIS == cZonaFis
					If SFH->FH_INIVIGE == dInicio .and. SFH->FH_FIMVIGE == dFim
						lExSFH := .T.
						exit  
					Endif
					SFH->(DbSkip())
				Enddo
			Endif

			//cria-se ou altera-se o registro no arquivo SFH para a "aliquota do arquivo" para percepcao
			If lExSFH
				RecLock("SFH",.F.)
				Replace SFH->FH_PERCIBI	With "S"
				Replace SFH->FH_ISENTO	With "N"
				Replace SFH->FH_APERIB	With "S"
				Replace SFH->FH_INIVIGE	With dInicio
				Replace SFH->FH_FIMVIGE	With dFim
				Replace SFH->FH_TIPO    With cContInsc
				nModifReg++
			Else
				RecLock("SFH",.T.)
				Replace SFH->FH_FILIAL	With xFilial("SFH")
				Replace SFH->FH_AGENTE	With "S"
				Replace SFH->FH_ZONFIS	With cZonaFis
				Replace SFH->FH_FORNECE	With (cAliasSA2)->A2_COD
				Replace SFH->FH_LOJA	With (cAliasSA2)->A2_LOJA
				Replace SFH->FH_IMPOSTO	With cPercepcao
				Replace SFH->FH_PERCIBI	With "S"
				Replace SFH->FH_ISENTO	With "N"
				Replace SFH->FH_APERIB	With "S"
				Replace SFH->FH_INIVIGE	With dInicio
				Replace SFH->FH_FIMVIGE	With dFim
				Replace SFH->FH_TIPO    With cContInsc
				Replace SFH->FH_NOME    With (cAliasSA2)->A2_NOME
				nNuevosReg++
			Endif
			If SFH->(FieldPos("FH_SITUACA")) > 0
				If lProcSim                                               
					Replace SFH->FH_SITUACA	With "3"	//cliente de Monotributista   - Tipo do Contribuinte de Regime Simplificado
				Else
					Replace SFH->FH_SITUACA	With "2"	//cliente de risco fiscal
				EndIf        
			EndIf
			Replace SFH->FH_ALIQ With nAlqPer
			SFH->(MsUnLock())
			(cAliasSA2)->(DbSkip())
		Enddo

		oPnlCon:cCaption := STR0019 + ".  OK" //"Actualizando la alicuota de percepcion para proveedores"
		#IFDEF TOP
		DbSelectArea(cAliasSA2)
		DbCloseArea()
		#ELSE
		SA2->(DbClearFilter())
		#ENDIF
	Endif
	
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CARFCLIPER  ºAutor  ³Marcello Gabriel    ºFecha ³ 01/12/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processa o registro atual do arquivo de contribuintes.        º±±
±±º          ³Verifica se o contribuinte esta no cadastro de clientes e     º±±
±±º          ³se necessario, cria o registro na tabela SFH com a aliquota   º±±
±±º          ³para "percepcao".                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CARFCliPer(cCuit,nAlqPer,dInicio,dFim,cContInsc)
	
	Local lExSFH	:= .F.
	Local lIntSynt 	:= SuperGetMV("MV_LJSYNT",,"0") == "1"	 // Informa se a integracao Synthesis esta ativa
	Local lPosFlag 	:= SA1->(FieldPos("A1_POSFLAG")) > 0
	Local lPosDtEx 	:= SA1->(FieldPos("A1_POSDTEX")) > 0

	SA1->(DbSetOrder(3))
	//Verifica se o contribuinte esta no arquivo de clientes
	cCuit := PadR(cCuit,TamSX3("A1_CGC")[1])
	If SA1->(DbSeek(xFilial("SA1") + cCuit))
		While  cCuit==SA1->A1_CGC  .And. !SA1->(EOF())
			If lProcSim
				SA1->(DbSkip())	
				Loop
			EndIf		
			//cria-se ou altera-se o registro no arquivo SFH para a "aliquota de risco" para percepcao
			lExSFH := .F.
			SFH->(DbSetOrder(3))//FH_FILIAL+FH_CLIENTE+FH_LOJA+FH_IMPOSTO+FH_ZONFIS                                                                                                               
			If SFH->(DbSeek(xFilial("SFH") + SA1->A1_COD + SA1->A1_LOJA + cPercepcao + cZonaFis))
				While SFH->(!EOF()) .and. SFH->FH_CLIENTE == SA1->A1_COD .and. SFH->FH_IMPOSTO == cPercepcao .and. SFH->FH_ZONFIS == cZonaFis
					If SFH->FH_INIVIGE == dInicio .and. SFH->FH_FIMVIGE == dFim
						lExSFH := .T.
						exit  
					Endif
					SFH->(DbSkip())
				Enddo
			Endif 
			If lExSFH
				RecLock("SFH",.F.)
				Replace SFH->FH_PERCIBI	With "S"
				Replace SFH->FH_ISENTO	With "N"
				Replace SFH->FH_APERIB	With "S"
				Replace SFH->FH_INIVIGE	With dInicio
				Replace SFH->FH_FIMVIGE	With dFim
				Replace SFH->FH_TIPO    With cContInsc
				nModifReg++
			Else
				RecLock("SFH",.T.)
				Replace SFH->FH_FILIAL	With xFilial("SFH")
				Replace SFH->FH_AGENTE	With "S"
				Replace SFH->FH_ZONFIS	With cZonaFis
				Replace SFH->FH_CLIENTE	With SA1->A1_COD
				Replace SFH->FH_LOJA	With SA1->A1_LOJA
				Replace SFH->FH_IMPOSTO	With cPercepcao
				Replace SFH->FH_PERCIBI	With "S"
				Replace SFH->FH_ISENTO	With "N"
				Replace SFH->FH_APERIB	With "S"
				Replace SFH->FH_INIVIGE	With dInicio
				Replace SFH->FH_FIMVIGE	With dFim
				Replace SFH->FH_TIPO    With cContInsc
				Replace SFH->FH_NOME    With SA1->A1_NOME
				nNuevosReg++
			Endif
			Replace SFH->FH_ALIQ With nAlqPer
			If SFH->(FieldPos("FH_SITUACA")) > 0
				If lProcSim                                               
					Replace SFH->FH_SITUACA	With "3"	//cliente de Monotributista   - Tipo do Contribuinte de Regime Simplificado
				Else
					Replace SFH->FH_SITUACA	With "2"	//cliente de risco fiscal
				EndIf        
			EndIf

			SFH->(MsUnLock())

			//Coloca o cliente como "alto risco" no cadastro de clientes        
			RecLock("SA1",.F.)
			If lProcSim                                               
				If lIntSynt .AND. lPosFlag .AND. lPosDtEx //Envia o cliente e a SFH para Synthesis quando integracao Synthesis esta ativa
					If SA1->A1_POSFLAG == "1"
						Replace SA1->A1_POSDTEX	With ""
					EndIf
				EndIf					 
			Else
				If lIntSynt .AND. lPosFlag .AND. lPosDtEx //Envia o cliente e a SFH para Synthesis quando integracao Synthesis esta ativa
					If SA1->A1_POSFLAG == "1"
						Replace SA1->A1_POSDTEX	With ""
					EndIf
				EndIf					 
			EndIf
			SA1->(MsUnLock())
			SA1->(DbSkip())	          		
		EndDo
	Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CARFNORMAIS ºAutor  ³Marcello Gabriel    ºFecha ³ 08/12/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica os clientes e fornecedores que sairam da condicao de º±±
±±º          ³"alto risco fiscal".                                          º±±
±±º          ³Para esses fornecedores, o campo _SITUACA e alterado para "N".º±±
±±º          ³A aliquota padrao passa a ser a que esta no arquivos SFF.     º±±
±±º          ³Para fornecedores que "percebem" IB, e criado um registro no  º±±
±±º          ³arquivo SFH para que lhe sejam calculado o IB.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CARFNormais(oDlg)

	Local nReg		:= 0
	Local nContReg	:= 0
	Local nNrReg	:= 0
	Local cFilSA	:= ""
	Local cFilSFH	:= xFilial("SFH")
	Local oMtrCli
	Local oMtrFor
	Local oPnlCli
	Local oPnlFor
	Local oPnlMtrCli
	Local oPnlMtrFor
	Local oFonte
	Local lIntSynt 	 := SuperGetMV("MV_LJSYNT",,"0") == "1"	 // Informa se a integracao Synthesis esta ativa
	Local lPosFlag 	 := SA1->(FieldPos("A1_POSFLAG")) > 0
	Local lPosDtEx 	 := SA1->(FieldPos("A1_POSDTEX")) > 0

	SA1->(DbSetOrder(3))
	SA2->(DbSetOrder(3))
	oFonte := TFont():New("Arial",,,,.T.,,,8,.F.,,,,,,,)

	//Verificando clientes
	If lProcCli
		oPnlCli := TPanel():New(01,01,STR0024 + ".",oDlg,oFonte,,,,RGB(221,221,221),5,30,.F.,.F.)	//"Verificação dos clientes que deixaram a condição de alto risco fiscal"
		oPnlCli:Align := CONTROL_ALIGN_TOP
		oPnlCli:nHeight := 15
		oPnlMtrClil := TPanel():New(01,01,,oDlg,,,,,RGB(221,221,221),5,30,.F.,.F.)
		oPnlMtrCli:Align := CONTROL_ALIGN_TOP
		oPnlMtrCli:nHeight := 40
		oMtrCli:=TMeter():New(60,05,,100,oPnlMtrCli,150,10,,.T.,,,.T.,,,,,.F.)
		oMtrCli:Align := CONTROL_ALIGN_TOP
		oMtrCli:nHeight := 15
		DbSelectArea(cAliasCli)
		(cAliasCli)->(DbGoTop())
		nNrReg := (cAliasCli)->(RecCount()) + 1
		nContReg := 0
		cFilSA := xFilial("SA1")
		While !((cAliasCli)->(Eof()))
			If (cAliasCli)->ESTADO == SIT_NORMAL
				If SA1->(DbSeek(cFilSA + (cAliasCli)->NRCUIT))
					While !(SA1->(EoF())) .And. (SA1->A1_CGC == (cAliasCli)->NRCUIT) .And. (SA1->A1_FILIAL == cFilSA)
						RecLock("SA1",.F.)
						If lIntSynt .AND. lPosFlag .AND. lPosDtEx //Envia o cliente e a SFH para Synthesis quando integracao Synthesis esta ativa
							If SA1->A1_POSFLAG == "1"
								Replace SA1->A1_POSDTEX	With ""
							EndIf
						EndIf
						SA1->(MsUnLock())
						SA1->(DbSkip())
					Enddo
				Endif
			Endif
			nContReg++
			nReg := Int((100 * nContReg) / nNrReg)
			oMtrCli:Set(nReg)
			(cAliasCli)->(DbSkip())
		Enddo
		nContReg++
		nReg := Int((100 * nContReg) / nNrReg)
		oMtrCli:Set(nReg)
	Endif
	//Verificando fornecedores
	If lProcFor
		oPnlFor := TPanel():New(01,01,STR0025 + ".",oDlg,oFonte,,,,RGB(221,221,221),5,30,.F.,.F.)		//"Verificação dos fornecedores que deixaram a condição de alto risco fiscal"
		oPnlFor:Align := CONTROL_ALIGN_TOP
		oPnlFor:nHeight := 15
		oPnlMtrFor := TPanel():New(01,01,,oDlg,,,,,RGB(221,221,221),5,30,.F.,.F.)
		oPnlMtrFor:Align := CONTROL_ALIGN_TOP
		oPnlMtrFor:nHeight := 40
		oMtrFor:=TMeter():New(60,05,,100,oPnlMtrFor,150,10,,.T.,,,.T.,,,,,.F.)
		oMtrFor:Align := CONTROL_ALIGN_TOP
		oMtrFor:nHeight := 15
		DbSelectArea(cAliasFor)
		(cAliasFor)->(DbGoTop())
		nNrReg := (cAliasFor)->(RecCount()) + 1
		nContReg := 0
		cFilSA := xFilial("SA2")
		While !((cAliasFor)->(Eof()))
			If (cAliasFor)->ESTADO == SIT_NORMAL
				If SA2->(DbSeek(cFilSA + (cAliasFor)->NRCUIT))
					While !(SA2->(Eof())) .And. (SA2->A2_CGC == (cAliasFor)->NRCUIT) .And. (SA2->A2_FILIAL == cFilSA)
						//Se o fornecedor "percebe" IB, cria o registro correspondente no SFH, com aliquota zero, para que seja
						//considerada a aliquota padrao que esta no arquivo SFF.
						If lProcPer
							If SA2->A2_PERCIB == 'S'"
								If (cAliasSFH)->(DbSeek(SA2->A2_COD + Space(TamSX3("A1_COD")[1]) + SA2->A2_LOJA + cPercepcao + cZonaFis + Space(8) + Space(8)))
									SFH->(DbGoto((cAliasSFH)->REGISTRO))
									RecLock("SFH",.F.)
									nModifReg++
								Else
									RecLock("SFH",.T.)
									nNuevosReg++
								Endif
								Replace SFH->FH_FILIAL	With cFilSFH
								Replace SFH->FH_AGENTE	With "S"
								Replace SFH->FH_ZONFIS	With cZonaFis
								Replace SFH->FH_FORNECE	With SA2->A2_COD
								Replace SFH->FH_LOJA	With SA2->A2_LOJA
								Replace SFH->FH_IMPOSTO	With cPercepcao
								Replace SFH->FH_PERCIBI	With "S"
								Replace SFH->FH_ISENTO	With "N"
								Replace SFH->FH_APERIB	With "S"
								Replace SFH->FH_INIVIGE	With Ctod("//")
								Replace SFH->FH_FIMVIGE	With Ctod("//")
								Replace SFH->FH_TIPO    With ""
								Replace SFH->FH_ALIQ 	With 0
								Replace SFH->FH_NOME    With SA2->A2_NOME
								SFH->(MsUnLock())
							Endif
						Endif
						SA2->(DbSkip())
					Enddo
				Endif
			Endif
			nContReg++
			nReg := Int((100 * nContReg) / nNrReg)
			oMtrFor:Set(nReg)
			(cAliasFor)->(DbSkip())
		Enddo
		nContReg++
		nReg := Int((100 * nContReg) / nNrReg)
		oMtrFor:Set(nReg)
	Endif
	ProcessMessages()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpASql  ³ Autor ³ Emanuel Villicaña   ³ Data ³ 22.01.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ejecuta la importacion de archivo a travez de comandos     ³±±
±±³          ³ MSSQL.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Local e nome do arquivo a ser importado.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True (Si extrajo la informacion con exito                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Capital Federal - MSSQL                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ImpASql(cFiles)

	Local lImpSql := .F.
	Local cQry  := ""

	If TCCanOpen("PADRONCF")
		If TCSqlExec( "DROP TABLE PADRONCF"  ) <> 0
			UserException( "DROP table error PADRONCF" + CRLF + TCSqlError() )
		EndIf
	EndIf

	cQry := "CREATE TABLE dbo.PADRONCF "
	cQry += "(" 
	cQry += " DTPUBLIC varchar(8) , "					//Fecha de Publicacion
	cQry += " DTINIVIG varchar(8) , "					//Fecha Vigencia Desde
	cQry += " DTFIMVIG varchar(8) , "					//Fecha Vigencia Hasta
	cQry += " NRCUIT varchar(" + Alltrim(Str(TamSX3("A1_CGC")[1],0)) + ") , " 	//Numero de Cuit
	cQry += " TIPCONTINS varchar(1) , "				//Tipo-Contr_Insc
	cQry += " MARCALTSUJ varchar(1) , "				//Marca-alta-sujeto
	cQry += " MARCAALIQ varchar(1) , "					//Marca-alicuota
	cQry += " ALIQPERC varchar(7) , "					//Alicuota- Percepcion
	cQry += " ALIQRETE varchar(7) , "					//Alicuota- Retencion
	cQry += " GRPPERCE varchar(2) , "					//Nro-Grupo-Percepcion
	cQry += " GRPRETEN varchar(2) , "					//Nro-Grupo-Retencion
	cQry += " RAZAOSOC varchar(60) , "					//Razon Social
	cQry += ")"

	If TCSqlExec( cQry ) <> 0
		UserException(STR0035 + " PADRONCF" + CRLF + TCSqlError()) //"Error en la creacion de tabla"
	Else 
		lImpSql := .T.
	EndIf

	cQry := "BULK INSERT dbo.PADRONCF FROM '" + cFiles + "' WITH ( BATCHSIZE = 30000 , DATAFILETYPE = 'char', FIELDTERMINATOR = '"+_SEPARADOR+"',ROWTERMINATOR = '\n' )"

	If  TCSqlExec( cQry ) <> 0
		MsgStop(STR0002) //"Este proceso debe ser ejecutado desde el servidor que contiene la base de datos de Protheus y además debe ser SQL Server."
		lImpSql := .F.
	Endif 

Return lImpSql

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CtesSql  ³ Autor ³ Emanuel Villicaña   ³ Data ³ 23.01.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Seleccion de Clientes que existen en el padron             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                 .          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True (Si extrajo la informacion con exito)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Capital Federal - MSSQL                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CtesSql(cAliasSA)

	Local lExicte := .F.
	Local cQry	:= ""

	cQry := "SELECT PADR.*"
	cQry += " FROM dbo.PADRONCF PADR"
	cQry += " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cQry += " ON PADR.NRCUIT = SA1.A1_CGC" 

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasSA,.T.,.T.)
	(cAliasSA)->(DbGoTop())
	lExicte := !((cAliasSA)->(Eof()))

Return lExicte

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CtesSql  ³ Autor ³ Emanuel Villicaña   ³ Data ³ 23.01.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Seleccion de Clientes que existen en el padron             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                 .          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True (Si extrajo la informacion con exito)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Capital Federal - MSSQL                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProvSql(cAliasSA)

	Local lExicte := .F.
	Local cQry	:= ""

	cQry := "SELECT PADR.*"
	cQry += " FROM dbo.PADRONCF PADR"
	cQry += " INNER JOIN " + RetSqlName("SA2") + " SA2"
	cQry += " ON PADR.NRCUIT = SA2.A2_CGC" 

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasSA,.T.,.T.)
	(cAliasSA)->(DbGoTop())
	lExicte := !((cAliasSA)->(Eof()))

Return lExicte

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ProcSimpl³ Autor ³ Luis Samaniego      ³ Data ³ 04.04.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Procesa archivo padron regimen simplificado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcSimpl(cArq)

	Local cTemp     := ""
	private oTmpTable

	aEstSFH := SFH->(DBSTRUCT())
	
	cTemp:= "TRB"
	oTmpTable:= FWTemporaryTable():New(cTemp) 
	oTmpTable:SetFields( aEstrTxt ) 
	oTmpTable:AddIndex("1", {'NRCUIT'})
	//Creacion de la tabla
	oTmpTable:Create()
	
	lImp := ImpFile(cArq,cTemp)

	If lImp
		lCUITEMP := ProcEmp(cTemp, @nAlqPerFor, @dIniVig, @dFimVig, @cContInsc)

		If lProcFor
			ProcRegs(cTemp, "SA2", @lProcCli, @lProcFor, @lProcRet, @lProcPer)
		Endif

		If lProcCli // Verifica/cria a aliquota de "percepcao" para o cliente	
			ProcRegs(cTemp, "SA1", @lProcCli, @lProcFor, @lProcRet, @lProcPer)
		Endif

	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Excluindo o arquivo temporario criado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If oTmpTable <> Nil  
		oTmpTable:Delete() 	
		oTmpTable := Nil 
	Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ProcEmp  ³ Autor ³ Luis Samaniego      ³ Data ³ 04.04.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica si CUIT de empresa existe en padron               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcEmp(cAliasTRD, nAlqPerFor, dIniVig, dFimVig, cContInsc)

	Local lRet := .F.

	dbSelectArea(cAliasTRD)
	dbSetOrder(1)
	If (cAliasTRD)->(dbSeek(Alltrim(SM0->M0_CGC)))
		nAlqPerFor := (cAliasTRD)->ALIQPERC
		dIniVig    := (cAliasTRD)->DTINIVIG
		dFimVig    := (cAliasTRD)->DTFIMVIG
		cContInsc  := (cAliasTRD)->TIPCONTINS
		lRet       := .T.
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ProcRegs ³ Autor ³ Luis Samaniego      ³ Data ³ 04.04.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Crea tabla temporal de cliente / proveedor                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegs(cAliasTRD, cTblCliFor, lProcCli, lProcFor, lProcRet, lProcPer)

	Local aArea		:= getArea()
	Local cQuery	:= ""	
	Local cSA		:= ""
	Local cTmp		:= ""                              
	Local aTmp		:= {}
	Local nReg		:= 0
	Local nI		:= 0
	Local cClave	:= ""
	Local cPref		:= Substr(cTblCliFor,2,2)
	Local lExiste	:= .F.

	cSA 	:= InitSqlName(cTblCliFor)
	cTmp 	:= criatrab(nil,.F.)    
	cQuery := "SELECT " + cPref + "_COD, " 
	cQuery +=			  cPref + "_LOJA, "
	cQuery +=			  cPref + "_CGC, "
	cQuery +=			  cPref + "_NOME "
	cQuery += "FROM "
	cQuery +=		cSA + " S"+ cPref + " " 
	cQuery += 	"WHERE "
	cQuery += cPref + "_CGC <> ' ' AND "
	//cQuery += cPref + "_SITUACA = '3' AND "
	cQuery +=	"D_E_L_E_T_ = ' ' "
	cQuery	+=	"ORDER BY " + cPref + "_CGC "

	cQuery := ChangeQuery(cQuery)                    

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 

	Count to nCont
	(cTmp)->(dbGoTop())

	ProcRegua(nCont) 
	While (cTmp)->(!eof())

		cClave := (cTmp)->&(cPref+"_CGC")
		cClave := Replace(cClave, "-", "")

		dbSelectArea(cAliasTRD)
		dbSetOrder(1)

		If (cAliasTRD)->(dbSeek(cClave))
			lExiste := .T.	  					
		End If    	

		If cTblCliFor == "SA1"
			If lProcCli .And. lProcPer
				CarfSFH("C",cClave,(cAliasTRD)->ALIQPERC,(cAliasTRD)->DTINIVIG,(cAliasTRD)->DTFIMVIG,(cAliasTRD)->TIPCONTINS,lExiste,(cTmp)->A1_COD,(cTmp)->A1_LOJA,(cTmp)->A1_NOME)
			EndIf
		ElseIf cTblCliFor == "SA2"
			If lProcFor .And. lProcRet
				CarfSFH("P",cClave,(cAliasTRD)->ALIQRETE,(cAliasTRD)->DTINIVIG,(cAliasTRD)->DTFIMVIG,(cAliasTRD)->TIPCONTINS,lExiste,(cTmp)->A2_COD,(cTmp)->A2_LOJA,(cTmp)->A2_NOME)
			EndIf
			If lProcFor .And. lProcPer .And. cTblCliFor == "SA2"
				CarfSFH("E",cClave,nAlqPerFor,dIniVig,dFimVig,cContInsc,lCUITEMP,(cTmp)->A2_COD,(cTmp)->A2_LOJA,(cTmp)->A2_NOME)
			EndIf
		EndIf

		lExiste := .F.
		(cTmp)->(dbSkip())	    
	End Do
	(cTmp)->(dbCloseArea()) 
	RestArea(aArea)
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CarfSFH  ³ Autor ³ Luis Samaniego      ³ Data ³ 04.04.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta tabla SFH y crea registro                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CarfSFH(cOrigen,cCuit,nAliq,dIni,dFim,cContInsc,lExistPadr,cCodCliFor,cLojCliFor,cNome)
	
	Local aArea		:= getArea()
	Local cQuery	:= ""	
	Local cSFH		:= InitSqlName("SFH")
	Local cTmp		:= Criatrab(Nil,.F.)                                
	Local nReg		:= 0
	Local cAliasSA	:= IIf(cOrigen == "C", "SA1", "SA2")
	Local nX		:= 0
	Local dVigV		:= CTOD("//")

	cQuery := "SELECT * "
	cQuery += "FROM "
	cQuery +=		cSFH + " SFH " 
	cQuery += 	"WHERE "
	cQuery += 	"FH_FILIAL ='" + xFilial("SFH") + "' AND "
	If cOrigen == "C"		
		cQuery += "FH_CLIENTE='" + cCodCliFor + "' AND "
		cQuery += "FH_LOJA   ='" + cLojCliFor + "' AND "
	Else
		cQuery += "FH_FORNECE='" + cCodCliFor + "' AND "
		cQuery += "FH_LOJA   ='" + cLojCliFor + "' AND "
	EndIf
	If cOrigen == "C"	.Or. cOrigen == "E"	
		cQuery += "FH_IMPOSTO = 'IBP' AND "
		cQuery += "FH_ZONFIS = 'CF' AND " 
	ElseIf cOrigen == "P"		
		cQuery += "FH_IMPOSTO = 'IBR' AND "
		cQuery += "FH_ZONFIS = 'CF' AND " 
	End If 
	cQuery +=	"D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY FH_FIMVIGE DESC"  

	cQuery := ChangeQuery(cQuery)                    
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 
	TCSetField(cTmp,"FH_INIVIGE","D")
	TCSetField(cTmp,"FH_FIMVIGE","D")

	Count to nCont
	(cTmp)->(dbGoTop())
	nReg := (cTmp)->R_E_C_N_O_

	If lExistPadr
		If (cOrigen $ "C|E|P") .And. nAliq == 0
			If nCont > 0
				SFH->(DBGOTO(nReg))
				If SFH->FH_ALIQ == nAliq
					Reclock("SFH",.F.)
					SFH->FH_FIMVIGE := dFim
					SFH->FH_SITUACA := "1"
					nModifReg++
					Msunlock()
				ElseIf SFH->FH_ALIQ <> nAliq .And. (SFH->FH_FIMVIGE < dFim .Or. SFH->FH_FIMVIGE == CTOD("//"))
					If (SFH->FH_FIMVIGE >= dIni) .Or. (SFH->FH_FIMVIGE == CTOD("//"))
						Reclock("SFH",.F.)
						SFH->FH_FIMVIGE := dFchVenc
						Msunlock()
					EndIf
					actRegSFH()
					Reclock("SFH",.F.)
					SFH->FH_ALIQ     := nAliq
					SFH->FH_PERCENT  := 0
					SFH->FH_PERCIBI  := "N"
					SFH->FH_APERIB   := "N"
					SFH->FH_INIVIGE  := dIni
					SFH->FH_FIMVIGE  := dFim
					SFH->FH_ISENTO   := "N"
					SFH->FH_SITUACA  := "1"
					nModifReg++
					Msunlock()
				ElseIf SFH->FH_ALIQ <> nAliq .And. SFH->FH_FIMVIGE == dFim
					Reclock("SFH",.F.)
					SFH->FH_ALIQ      := nAliq
					SFH->FH_PERCENT   := 0
					SFH->FH_PERCIBI   := "N"
					SFH->FH_APERIB    := "N"
					SFH->FH_ISENTO    := "N"
					SFH->FH_SITUACA   := "1"
					nModifReg++
					Msunlock()
				EndIf   	
			ElseIf  "P|C" $ cOrigen   
				Reclock("SFH",.T.)
				SFH->FH_FILIAL   := xFilial("SFH")
				SFH->FH_AGENTE   := "N"
				SFH->FH_NOME     := cNome
				If cOrigen == "C"
					SFH->FH_CLIENTE  := cCodCliFor
					SFH->FH_LOJA     := cLojCliFor
					SFH->FH_IMPOSTO  := "IBP"
				Else
					SFH->FH_FORNECE  := cCodCliFor
					SFH->FH_LOJA     := cLojCliFor
					//If cOrigen == "E"
					//SFH->FH_IMPOSTO  := "IBP"
					//Else
					SFH->FH_IMPOSTO  := "IBR"
				EndIf
				SFH->FH_ALIQ     := nAliq
				SFH->FH_PERCIBI  := "N"
				SFH->FH_ISENTO   := "N"
				SFH->FH_APERIB   := "N"
				SFH->FH_ZONFIS  := "CF"
				SFH->FH_SITUACA  := "1"
				SFH->FH_TIPO     := cContInsc
				SFH->FH_PERCENT  := 0
				SFH->FH_INIVIGE  := dIni
				SFH->FH_FIMVIGE  := dFim
				Msunlock()
				nNuevosReg++
			EndIf
		ElseIf (cOrigen $ "C|E|P") .And. nAliq <> 0
			If nCont > 0
				SFH->(DBGOTO(nReg))
				If SFH->FH_ALIQ == nAliq
					Reclock("SFH",.F.)
					SFH->FH_FIMVIGE := dFim
					SFH->FH_SITUACA := "3"
					nModifReg++
					Msunlock()
				ElseIf SFH->FH_ALIQ <> nAliq .And. (SFH->FH_FIMVIGE < dFim .Or. SFH->FH_FIMVIGE == CTOD("//"))
					If (SFH->FH_FIMVIGE >= dIni) .Or. (SFH->FH_FIMVIGE == CTOD("//"))
						Reclock("SFH",.F.)
						SFH->FH_FIMVIGE := dFchVenc
						nModifReg++
						Msunlock()
					EndIf
					actRegSFH()
					Reclock("SFH",.F.)
					SFH->FH_ALIQ     := nAliq
					SFH->FH_PERCENT  := 0
					If cOrigen $ "E|C"
						SFH->FH_PERCIBI  := "S"
						SFH->FH_APERIB   := "S"
					ElseIf cOrigen == "P"
						SFH->FH_PERCIBI  := "N"
						SFH->FH_APERIB   := "N"
					EndIf
					SFH->FH_INIVIGE  := dIni
					SFH->FH_FIMVIGE  := dFim
					SFH->FH_ISENTO   := "N"
					SFH->FH_SITUACA  := "3"
					nModifReg++
					Msunlock()
				ElseIf SFH->FH_ALIQ <> nAliq .And. SFH->FH_FIMVIGE == dFim
					Reclock("SFH",.F.)
					SFH->FH_ALIQ      := nAliq
					SFH->FH_PERCENT   := 0
					If cOrigen $ "E|C"
						SFH->FH_PERCIBI   := "S"
						SFH->FH_APERIB    := "S"
					ElseIf cOrigen == "P"
						SFH->FH_PERCIBI  := "N"
						SFH->FH_APERIB   := "N"
					EndIf
					SFH->FH_ISENTO    := "N"
					SFH->FH_SITUACA   := "3"
					nModifReg++
					Msunlock()
				EndIf	
			ElseIf !(cOrigen == "E")
				Reclock("SFH",.T.)
				SFH->FH_FILIAL   := xFilial("SFH")
				SFH->FH_AGENTE   := "S"
				SFH->FH_NOME     := cNome
				If cOrigen == "C"
					SFH->FH_CLIENTE  := cCodCliFor
					SFH->FH_LOJA     := cLojCliFor
					SFH->FH_IMPOSTO  := "IBP"
				ElseIf cOrigen = "P"
					SFH->FH_FORNECE  := cCodCliFor
					SFH->FH_LOJA     := cLojCliFor
					//If cOrigen == "E"
					//SFH->FH_IMPOSTO  := "IBP"
					//Else
					SFH->FH_IMPOSTO  := "IBR"
				EndIf
				SFH->FH_ALIQ     := nAliq
				If cOrigen == "P"
					SFH->FH_PERCIBI  := "N"
					SFH->FH_APERIB   := "N"
				Else
					SFH->FH_PERCIBI  := "S"
					SFH->FH_APERIB   := "S"
				EndIf
				SFH->FH_ISENTO   := "N"
				SFH->FH_ZONFIS  := "CF"
				SFH->FH_SITUACA  := "3"
				SFH->FH_TIPO     := cContInsc
				SFH->FH_PERCENT  := 0
				SFH->FH_INIVIGE  := dIni
				SFH->FH_FIMVIGE  := dFim
				Msunlock()
				nNuevosReg++
			EndIf
		EndIf
	Else
		If (cOrigen $ "C|E|P") .And. nCont > 0
			SFH->(DBGOTO(nReg))
			If (SFH->FH_FIMVIGE >= dFchIniV) .Or. (SFH->FH_FIMVIGE == CTOD("//"))
				Reclock("SFH",.F.)
				SFH->FH_FIMVIGE := dFchVenc
				nModifReg++
				Msunlock()
			EndIf
		EndIf
	EndIf

	(cTmp)->(dbCloseArea())
	RestArea(aArea)
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ actRegSFH³ Autor ³ Luis Samaniego      ³ Data ³ 11.02.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Actualiza registro en tabla SFH                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function actRegSFH()
	
	Local i := 0
	Local j := 0
	Local aSFHTemp := {}

	For i:=1 to len(aEstSFH)
		aADD(aSFHTemp,{aEstSFH[i],SFH->&(aEstSFH[i][1])}) 
	Next i

	Reclock("SFH",.T.)
	For j := 1 to Len(aSFHTemp)
		SFH->&(aSFHTemp[j][1][1]) := aSFHTemp[j][2]
	Next j
	nNuevosReg++
	Msunlock()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpFile  ³ Autor ³ Luis Samaniego      ³ Data ³ 04.04.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Importa archivo de texto en tabla temporal                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpFile(cFile,cAliasTRD)
	
	Local lRet 	:= .F.
	Local aLinea  := {}
	Local cLinea  := ""

	dbSelectArea(cAliasTRD)
	(cAliasTRD)->(dbGoTop())	

	FT_FGoTop()

	While !FT_FEOF()   

		cLinea	:= ""
		aLinea	:= {}

		cLinea	:= FT_FReadLn()
		aLinea	:= Separa(cLinea,_SEPARADOR)

		If dFchIniV != STOD(Substr(aLinea[2], 5,4) + Substr(aLinea[2], 3,2) + Substr(aLinea[2], 1,2))
			MsgAlert(STR0027) //"La fecha de inicio de vigencia informada no coincide con la fecha del archivo"
			Return .F.
		EndIf
		
		If !Empty(aLinea)
			Reclock(cAliasTRD,.T.)
			(cAliasTRD)->DTPUBLIC   := STOD(Substr(aLinea[1], 5,4) + Substr(aLinea[1], 3,2) + Substr(aLinea[1], 1,2))
			(cAliasTRD)->DTINIVIG   := STOD(Substr(aLinea[2], 5,4) + Substr(aLinea[2], 3,2) + Substr(aLinea[2], 1,2))
			(cAliasTRD)->DTFIMVIG   := STOD(Substr(aLinea[3], 5,4) + Substr(aLinea[3], 3,2) + Substr(aLinea[3], 1,2))
			(cAliasTRD)->NRCUIT     := aLinea[4]
			(cAliasTRD)->TIPCONTINS	:= IIf(Alltrim(aLinea[5]) == "D", "I", "V" )
			(cAliasTRD)->MARCALTSUJ := aLinea[6]
			(cAliasTRD)->MARCAALIQ 	:= aLinea[7]
			(cAliasTRD)->ALIQPERC 	:= Val(Replace(aLinea[8], ',', '.'))
			(cAliasTRD)->ALIQRETE 	:= Val(Replace(aLinea[9], ',', '.'))
			(cAliasTRD)->GRPPERCE 	:= Val(aLinea[10])
			(cAliasTRD)->GRPRETEN 	:= Val(aLinea[11])
			(cAliasTRD)->RAZAOSOC  	:= REPLACE(aLinea[12],'"',"")
			(cAliasTRD)->(MsUnLock())
			lRet := .T.
		Endif
		FT_FSKIP()
	EndDo
	
	FT_FUSE()

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VldContSim³ Autor ³ Luis Samaniego      ³ Data ³ 04.04.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica fecha de inicio de vigencia                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VldContSim(nOpc)
	
	Local lRet := .T.
	Default nOpc := 1

	If MV_PAR03  == 2
		If Empty(MV_PAR04)
			lRet := .F.	
			If nOpc == 2
				MsgAlert(STR0026) //"Debe informar fecha de inicio de vigencia"
			EndIf
		EndIf
	EndIf
	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RetFecha ³ Autor ³ Luis Samaniego      ³ Data ³ 04.04.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida dias y meses                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Libros Fiscales                			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetFecha(nMes, nAno)

	Local nDia		:= 0
	Local nMesAnt	:= 0
	Local nAnio		:= 0
	Local dFecha	:= CTOD("//")
	Local cMes		:= ""
	Local cDia		:= ""

	nMesAnt := IIF(nMes == 1, 12, nMes)
	nAnio := IIf(nMesAnt == 12, nAno - 1, nAno)

	Do Case
		Case nMesAnt == 2
		If (nAnio%4) == 0
			If (nAnio%100) == 0
				If (nAnio%400) == 0
					nDia := 29
				Else
					nDia := 28
				EndIf
			Else
				nDia := 29
			EndIf	
		Else
			nDia := 28
		EndIf	
		Case nMesAnt == 4 .Or. nMesAnt == 6 .Or. nMesAnt == 9 .Or. nMesAnt == 11
			nDia := 30
		Case nMesAnt == 1 .Or. nMesAnt == 3 .Or. nMesAnt == 5 .Or. nMesAnt == 7 .Or. nMesAnt == 8 .Or. nMesAnt == 10 .Or. nMesAnt == 12
			nDia := 31
	EndCase
	
	cMes := IIf(nMesAnt > 0 .And. nMesAnt < 10, StrZero(nMesAnt, 2), Str(nMesAnt))
	cDia := IIf(nDia > 0 .And. nDia < 10, StrZero(nDia, 2), Str(nDia))

	dFecha := STOD(AllTrim(STR(nAnio)) + AllTrim(cMes) + AllTrim(cDia))

Return dFecha
