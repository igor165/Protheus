#Include "Protheus.ch"
#Include "OFIOC320.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC320 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 07/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pecas Importadas do Orcamento e nao Requisitadas na OS     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPAROrc = Filtra o Orcamento                               ³±±
±±³          ³ cPAROrd = Filtra a Ordem de Servico                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC320(cPAROrc,cPAROrd)
Local lAltera := .t.
Private lImprimir := .t.
Private cFilOrc := space(8)
Private cFilOrd := space(8)
Private aPecImpOS := {}
Private aRotina := {{"", "",0,1},;
                    {"", "",0,2},;
                    {"", "",0,3},;
                    {"", "",0,4} }
Default cPAROrc := cFilOrc
Default cPAROrd := cFilOrd
If !Empty(cPAROrc+cPAROrd)
	lAltera := .f.
EndIf
cFilOrc := cPAROrc
cFilOrd := cPAROrd
#IFDEF TOP
	If !FS_VERBASE() // Verifica a existencia dos arquivos envolvidos na Consulta
		MsgAlert(STR0002,STR0001)  //Nao existem dados para esta Consulta ! # Atencao
		Return
	EndIf
	Processa( {|| FS_LEVANT(0) } ) // Levantamento das Pecas.
	DbSelectArea("VS1")
	DbSelectArea("VO1")
	DEFINE MSDIALOG oPecImpOS FROM 000,000 TO 29,80 TITLE (STR0003) OF oMainWnd //Pecas Importadas do Orcamento e nao Requisitadas na OS
		@ 017,001 LISTBOX oLbPecIOS FIELDS HEADER OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi("Descricao"),OemToAnsi(STR0009) COLSIZES 30,30,25,65,110,50 SIZE 315,201 OF oPecImpOS PIXEL  //Orcamento # OS # Grupo # Codigo do Item # Descricao # Qtde
		oLbPecIOS:SetArray(aPecImpOS)                                    
		oLbPecIOS:bLine := { || { aPecImpOS[oLbPecIOS:nAt,1] , aPecImpOS[oLbPecIOS:nAt,2] , aPecImpOS[oLbPecIOS:nAt,3] , aPecImpOS[oLbPecIOS:nAt,4] , aPecImpOS[oLbPecIOS:nAt,5] , FG_AlinVlrs(Transform(aPecImpOS[oLbPecIOS:nAt,6],"@E 99999,999")) }}
		@ 000,001 TO 016,168 LABEL STR0020 OF oPecImpOS PIXEL  //Filtrar
	   @ 006,005 SAY STR0011 SIZE 35,06 OF oPecImpOS PIXEL COLOR CLR_BLUE  //Orcamento:
   	@ 005,035 MSGET oFilOrc VAR cFilOrc F3 "VS1" PICTURE "99999999" VALID (If(!Empty(cFilOrc),cFilOrc:=strzero(val(cFilOrc),8),.t.),FS_REFRIMP(.F.)) SIZE 40,06 OF oPecImpOS PIXEL COLOR CLR_BLUE WHEN lAltera
	   @ 006,082 SAY STR0012 SIZE 35,06 OF oPecImpOS PIXEL COLOR CLR_BLUE  //OS:
   	@ 005,093 MSGET oFilOrd VAR cFilOrd F3 "VO1" PICTURE "99999999" VALID (If(!Empty(cFilOrd),cFilOrd:=strzero(val(cFilOrd),8),.t.),FS_REFRIMP(.F.)) SIZE 40,06 OF oPecImpOS PIXEL COLOR CLR_BLUE WHEN lAltera
		@ 005,140 BUTTON oOk PROMPT STR0016 OF oPecImpOS SIZE 22,10 PIXEL ACTION Processa( {|| FS_LEVANT(1) } ) WHEN lAltera //< OK >
		@ 004,182 BUTTON oVis PROMPT STR0017 OF oPecImpOS SIZE 37,10 PIXEL ACTION FS_VISUAL() WHEN lAltera  //Visualizar
		@ 004,227 BUTTON oImp PROMPT STR0018 OF oPecImpOS SIZE 37,10 PIXEL ACTION FS_IMPRIMIR() WHEN lImprimir   //Imprimir
		@ 004,272 BUTTON oSAIR PROMPT STR0019 OF oPecImpOS SIZE 37,10 PIXEL ACTION oPecImpOS:End()    //SAIR
	ACTIVATE MSDIALOG oPecImpOS CENTER                                 
#ENDIF
Return()
                                                                          
Static Function FS_LEVANT(nx) // Levantamento das Pecas no VSJ //
Local cQuery  := ""
Local cQAlias := "SQLVSJ"
aPecImpOS := {}
cQuery := "SELECT VSJ.VSJ_NUMORC , VSJ.VSJ_NUMOSV , VSJ.VSJ_GRUITE , VSJ.VSJ_CODITE , VSJ.VSJ_QTDITE , SB1.B1_DESC FROM "+RetSqlName("VSJ")+" VSJ , "+RetSqlName("SB1")+" SB1 "
cQuery += "WHERE VSJ.VSJ_FILIAL='"+xFilial("VSJ")+"' AND SB1.B1_FILIAL='"+xFilial("SB1")+"' AND VSJ.VSJ_GRUITE=SB1.B1_GRUPO AND VSJ.VSJ_CODITE=SB1.B1_CODITE AND "
If !Empty(cFilOrc)
	cQuery += "VSJ.VSJ_NUMORC='"+cFilOrc+"' AND "
EndIf
If !Empty(cFilOrd)
	cQuery += "VSJ.VSJ_NUMOSV='"+cFilOrd+"' AND "
EndIf
cQuery += "VSJ.D_E_L_E_T_=' ' AND SB1.D_E_L_E_T_=' ' ORDER BY VSJ.VSJ_NUMORC , VSJ.VSJ_NUMOSV , VSJ.VSJ_GRUITE , VSJ.VSJ_CODITE "
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
Do While !( cQAlias )->( Eof() )
	aadd(aPecImpOS,{ ( cQAlias )->( VSJ_NUMORC ) , ( cQAlias )->( VSJ_NUMOSV ) , ( cQAlias )->( VSJ_GRUITE ) , ( cQAlias )->( VSJ_CODITE ) , left(( cQAlias )->( B1_DESC ),20) , ( cQAlias )->( VSJ_QTDITE ) })
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
If len(aPecImpOS) <= 0
	Aadd(aPecImpOS,{ "" , "" , "" , "" , "" , 0 })
EndIf
If nx > 0
	FS_REFRIMP(.T.)
	oLbPecIOS:nAt := 1
	oLbPecIOS:SetArray(aPecImpOS)
	oLbPecIOS:bLine := { || { aPecImpOS[oLbPecIOS:nAt,1] , aPecImpOS[oLbPecIOS:nAt,2] , aPecImpOS[oLbPecIOS:nAt,3] , aPecImpOS[oLbPecIOS:nAt,4] , aPecImpOS[oLbPecIOS:nAt,5] , FG_AlinVlrs(Transform(aPecImpOS[oLbPecIOS:nAt,6],"@E 99999,999")) }}
	oLbPecIOS:SetFocus()
	oLbPecIOS:Refresh()
EndIf
Return(.t.)

Static Function FS_REFRIMP(lTipo) // WHEN do Botao Imprimir // 
lImprimir := lTipo
oImp:Refresh()
return(.t.)

Static Function FS_VERBASE() // Verifica a Base da Empresa para realizar a Consulta //
Local cQuery  := ""
Local cQAlias := "SQLERRO"
Local lOk     := .t.
Private bBlock:= ErrorBlock()
Private bErro := ErrorBlock( { |e| lOk := .f. } )
cQuery := ChangeQuery( "SELECT VSJ.VSJ_NUMORC FROM "+RetSqlName("VSJ")+" VSJ WHERE VSJ.VSJ_NUMORC='1'" )
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
( cQAlias )->( dbCloseArea() )
cQuery := ChangeQuery( "SELECT SB1.B1_COD FROM "+RetSqlName("SB1")+" SB1 WHERE SB1.B1_COD='1'" )
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
( cQAlias )->( dbCloseArea() )
ErrorBlock(bBlock)
Return(lOk)

Static Function FS_VISUAL() // Visualizar
Local x := 0
Private aRotina := { { "" ,"axPesqui", 0 , 1},;   && Pesquisar
                   { "" ,"OC060"   , 0 , 2}}    && Visualizar
Private cCadastro := OemToAnsi("Consulta OS")
Private cCampo, nOpc := 2 , inclui := .f.
x := Aviso(STR0010,STR0011+aPecImpOS[oLbPecIOS:nAt,1]+CHR(13)+CHR(10)+STR0012+aPecImpOS[oLbPecIOS:nAt,2],{STR0004,STR0005})    //  Visualizar ? # Orcamento: # OS: # Orcamento # "OS"
If x == 1 // Orcamento
	FG_ORCVER(aPecImpOS[oLbPecIOS:nAt,1])
ElseIf x == 2 // OS
	DbSelectArea("VO1")
	DbSetOrder(1)
	If DbSeek( xFilial("VO1") + aPecImpOS[oLbPecIOS:nAt,2] )
		OC060("VO1",VO1->(RECNO()),2)
	EndIf
EndIf
Return

Static Function FS_IMPRIMIR() // Imprimir
	Local ni := 0
	Private cDesc1 := ""
	Private cDesc2 := ""
	Private cDesc3 := ""
	Private tamanho:= "P"
	Private limite := 80
	Private cString:= "VSJ"
	Private titulo := STR0013 //Pecas Importadas e nao Requisitadas
	Private cabec1 := IIF(!Empty(cFilOrc+cFilOrd),STR0015+IIF(!Empty(cFilOrc),STR0011+cFilOrc+"   ","")+IIF(!Empty(cFilOrd),STR0012+cFilOrd,""),"")  //Filtro =  # Orcamento: # OS:
	Private cabec2 := STR0014    //Orcamto  OS       Item                             Descricao                Qtde
	Private aReturn:= {"",1,"",1,2,1,"",1}  
   Private nomeprog:= "OFIOC320"
	Private nLastKey:= 0
	If Empty(cabec1)
	   cabec1 := cabec2
	   cabec2 := ""
	EndIf
	nomeprog := SetPrint(cString,nomeprog,nil,titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
	If nLastKey == 27
		Return
	EndIf     
	SetDefault(aReturn,cString)
	nLin  := 0
	m_pag := 1
	Set Printer to &nomeprog
	Set Printer On
	Set Device  to Printer
	nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) + 1
	For ni := 1 to len(aPecImpOS)
		If nLin >= 60
			nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) + 1
		EndIf
		@ nLin++, 00 PSAY aPecImpOS[ni,1]+" "+aPecImpOS[ni,2]+" "+aPecImpOS[ni,3]+" "+aPecImpOS[ni,4]+" "+aPecImpOS[ni,5]+Transform(aPecImpOS[ni,6],"@E 99999,999")
	Next
	Set Printer to
	Set Device to Screen
	If aReturn[5] == 1
	   OurSpool( nomeprog )
	EndIf
	MS_Flush()
Return