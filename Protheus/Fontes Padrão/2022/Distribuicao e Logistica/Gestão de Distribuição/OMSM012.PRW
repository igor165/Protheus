#INCLUDE "PROTHEUS.CH"	
#INCLUDE "OMSM010.CH"	
#INCLUDE "FWMVCDEF.CH"
	
#DEFINE CRMARCA 1
#DEFINE CRNOTA 2
#DEFINE CRSERIE 3
#DEFINE CRCLIENTE 4
#DEFINE CRLOJA 5
#DEFINE CRTENTA 6
#DEFINE CRMEMO 7
#DEFINE CRCHAVE 8
#DEFINE CRDESMEM 9

//-----------------------------------------------------
/*/ Idem OMSM010 restrio ao SIGAGFE
@author Felipe Machado de Oliveira
@version P11
@since 18/04/2013
/*/
//------------------------------------------------------
Function OMSM012()
Local aSize     := {}
Local aObjects  := {}
Local aListBox  := {}
Local aInfo     := {}
Local aPosObj   := {}

Local oBtn01
Local oBtn02
Local lAtiva := .T.
Local lIntGFE := SuperGetMv("MV_INTGFE",.F.,.F.)
Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")
Local cIntNFS := SuperGetMv("MV_GFEI11",.F.,"2")

Private oOk       := LoadBitMap(GetResources(),"LBOK")
Private oNo       := LoadBitMap(GetResources(),"LBNO")
Private oListBox	:= Nil
Private oDlg		:= Nil
Private oQtdDoc	:= Nil
Private oQtdMrk	:= Nil
Private nQtdDoc	:= 0
Private nQtdMrk	:= 0
Private lExecAuto	:= .F.
                             
//-- Checkbox
Private lAllMark:= .F.   // Usado para o controle da marca de todos os documentos
//-- Rotinas Marcadas
Private aRotMark:= {}

If lIntGFE <> .T. 
	Help( ,, STR0035,,STR0036, 1, 0) //"Atenção"##"ERP não possui integração com SIGAGFE (MV_INTGFE)."
	lAtiva := .F.
Else
	If !cIntGFE2 $ "1"
		Help( ,, STR0035,,STR0037, 1, 0) //"Atenção"##"A integração direta, sem o uso de EAI e TOTVSESB, não está ativa (MV_INTGFE2). Utilize o programa de Carga Inicial (OMSM010)."
		lAtiva := .F.
	ElseIf cIntNFS == "2"
		Help( ,, STR0035,,"Integração com Documento de Saída não está ativa (MV_GFEI11).", 1, 0) //"Atenção"##"Integração com Documento de Saída não está ativa (MV_GFEI11)."
		lAtiva := .F.
	EndIf
EndIf

If lAtiva
	
	lAtiva := SelDados(@aListBox,,.F.)
	
	If lAtiva
	
		aSize    := MsAdvSize(.F. )
		aObjects := {}
	
		AAdd( aObjects, { 100, 020, .T., .F., .T.  } )
		AAdd( aObjects, { 100, 100, .T., .T. } )
		AAdd( aObjects, { 100, 020, .F., .F. } )

		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3, .T.  }
		aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
		DEFINE MSDIALOG oDlg TITLE "Notas Fiscais de Saída Pendentes" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL //"Notas Fiscais de Saída Pendentes"
	
			oPanel := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oDlg,,,,,CLR_WHITE,(aPosObj[1,3]), (aPosObj[1,4]), .T.,.T.)
		
			@ 005,005 CHECKBOX oAllMark VAR lAllMark PROMPT STR0009 SIZE 168, 08; //-- Marca/Desmarca Todos
			ON CLICK(OsM012All(aListBox)) OF oPanel PIXEL              
		
			//-- Cabecalho dos campos do Monitor.                                                        
			@ aPosObj[2,1],aPosObj[2,2] LISTBOX oListBox Fields HEADER;
		  	"","Numero","Serie","Cliente","Loja","Tentativas","Mensagem" SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL 
		   
			oListBox:SetArray( aListBox )
			oListBox:bLDblClick := { |x,nCol| IIF(nCol == 7, FIELDMEMO(aListBox[oListBox:nAT][CRDESMEM]), OsM012Mrk(aListBox) ) }
			oListBox:bLine      := { || {	Iif(aListBox[ oListBox:nAT,CRMARCA ] == '1',oOk,oNo),;
												aListBox[ oListBox:nAT,CRNOTA ],;
												aListBox[ oListBox:nAT,CRSERIE],;
												aListBox[ oListBox:nAT,CRCLIENTE],;
												aListBox[ oListBox:nAT,CRLOJA],;
												aListBox[ oListBox:nAT,CRTENTA],;
												aListBox[ oListBox:nAT,CRMEMO]}}
		                                                    
			//-- Botoes da tela do monitor.
			@ aPosObj[3,1],aPosObj[3,4] - 100 BUTTON oBtn01 	PROMPT STR0014 ACTION Iif(MsgYesNo(STR0015,STR0008),;        //--"Confirma o Processamento",Carga Inicial
					Processa( { || OsM012Proc(aListBox), IIF( SelDados(@aListBox,oListBox,.T.),,oDlg:End() ) }, , STR0041, .T. ),'')       OF oDlg PIXEL SIZE 035,011 //"Transmitindo para o SIGAGFE"
			@ aPosObj[3,1],aPosObj[3,4] - 060 BUTTON oBtn04 	PROMPT STR0020 ACTION oDlg:End()  OF oDlg PIXEL SIZE 035,011 //-- "Sair" 
		
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
	
Endif
	
Return ( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OsM012Mrk³  Autor ³ Leandro Paulino      ³ Data ³05.05.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca as rotinas no listbox                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OsM012Mrk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OMSM012                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OsM012Mrk(aListBox,nItem,lRefresh,lUmItem,lRetMark)
Local   nPosMrk := 0
Local	  nDocMrk := 0

Default nItem   := oListBox:nAt
Default lRefresh:= .T.
Default lUmItem := .T.
Default lRetMark:= .F.

If lUmItem
	aListBox[nItem,CRMARCA] := Iif(aListBox[nItem,CRMARCA] == '1','2','1')
	If(aListBox[nItem,CRMARCA]) == '1'
		nQtdMrk += 1
	ElseIf(aListBox[nItem,CRMARCA]) == '2'		
		nQtdMrk -= 1
	EndIf	
Else
	If lAllMark
		aListBox[nItem,CRMARCA] := '1'
		nQtdMrk += 1
	Else
		aListBox[nItem,CRMARCA] := '2'
		nQtdMrk := 0
	EndIf                                                                      
EndIf
nPosMrk := Ascan(aRotMark,{ | e | e[1]+e[2] == aListBox[nItem,CRNOTA]+aListBox[nItem,CRCLIENTE] })
If nPosMrk == 0
	Aadd(aRotMark,{ aListBox[nItem,CRCLIENTE], aListBox[nItem,CRNOTA], '' })
	nPosMrk := Len(aRotMark)
EndIf
aRotMark[nPosMrk,3] := aListBox[nItem,CRMARCA]
If lRefresh
	oListBox:Refresh()
EndIf
	 
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OsM012All³  Autor ³ Leandro Paulino     ³ Data ³05.05.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca todas as rotinas                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OsM012All()    		                                      ³±±           		
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OMSM012                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OsM012All(aListBox)
Local nI      := 0
Local lRefresh:= .T.
Local lUmItem := .F.

CursorWait()
nQtdMrk := 0

For nI := 1 To Len(aListBox)
	OsM012Mrk(aListBox,nI,lRefresh,lUmItem)
Next nI	

CursorArrow()

oListBox:Refresh()

Return Nil
               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OsM012Proc  ³ Autor ³Leandro Paulino      ³ Data ³15.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina responsavel por enviar as tabelas para MaEnvEAI      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Param[1] - Array contendo as rotinas da tela                ³±±
±±³         ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/            
Static Function OsM012Proc(aListBox)
Local nI			:= 0                     
Local aCargaIni	:= {}
Local aGetArea	:= GetArea() 
Local ArqvLog   := GFELog():New(STR0042, STR0040+" - "+STR0043, SuperGetMV('MV_GFEEDIL',.F.,'1')) //"Carga_Inicial_GFE"##"Carga Inicial GFE - Relatório de Erros de Integração"
Local cFiltro := ""
	
Local cDrtLog := SuperGetMv("MV_DRTLOG",.F.,"")
	
Default aListBox  := {}

aCargaIni := OsM012Rot(aListBox)
	
ArqvLog:Add("------------------------------------------------------------------------------------------------------------------------")
ArqvLog:Add("| "+STR0044+" |              "+STR0045+"              | "+STR0046+" |                         "+STR0047+"                        ")//"ROTINA"##"CAMPOS CHAVE"##"CAMPO GFE"##"PROBLEMA"
ArqvLog:Add("------------------------------------------------------------------------------------------------------------------------")

For nI := 1 To Len(aCargaIni)

	dbSelectArea("SF2")
  	dbGoTop()
	
	cIndAlias := CriaTrab( Nil, .F. )
			
	cFiltro := "F2_DOC=='"+PadR(aCargaIni[nI][CRNOTA],TamSX3("F2_DOC")[1] )+"' .AND. "
	cFiltro += "F2_SERIE=='"+PadR(aCargaIni[nI][CRSERIE], TamSX3("F2_SERIE")[1] )+"' .AND. "
 	cFiltro += "F2_CLIENTE=='"+PadR(aCargaIni[nI][CRCLIENTE], TamSX3("F2_CLIENTE")[1] )+"' .AND. "
 	cFiltro += "F2_LOJA=='"+PadR(aCargaIni[nI][CRLOJA], TamSX3("F2_LOJA")[1] )+"'"
 	
	IndRegua("SF2", cIndAlias, IndexKey(), , cFiltro ,STR0024) //--"Selecionando Registros..."
	
	nIndAlias := RetIndex("SF2")
	
	DbSetOrder( nIndAlias + 1 )
	ProcRegua( SF2->( RecCount() ) )
  	While (!SF2->(Eof()))         
	
		If aCargaIni[nI,CRNOTA] == "SF2"
			If Empty(SF2->F2_FILIAL) .OR. SF2->F2_FILIAL == xFilial("SF2")
				lFilial := .T.
			Else
				lFilial := .F.
			EndIf
		Else 
			lFilial := .T.
		EndIf
		
		If lFilial
			IncProc()
			If FindFunction( "GFEM011IPG")
				GFEM011IPG("SF2",ArqvLog)
			EndIf
			SF2->(dbSkip())  
		EndIf
		
  	EndDo
 
 	If	File( cIndAlias + OrdBagExt() )
		DbSelectArea("SF2")
		DbClearFilter()
		Ferase( cIndAlias + OrdBagExt() )
	EndIf
	
	RetIndex("SF2")
	
Next nI 

ArqvLog:EndLog()

MsgInfo(STR0048+": "+cDrtLog) //"Visualizar arquivo log"
	
RestArea(aGetArea)
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OsM012Rot ³ Autor ³ Leandro Paulino       ³ Data ³05.05.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preparar rotinas para processamento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorna as rotinas selecionadas.                           ³±±
±±³          ³ Array dos documentos                                       ³±±
±±³          ³ [1] - Marca/Desmarca                                       ³±±
±±³          ³ [2] - Cor Legenda    		                                ³±±
±±³          ³ [3] - Alias                                                ³±±
±±³          ³ [4] - Nome do Alias                                        ³±±
±±³          ³ [5] - Rotina                                               ³±±
±±³          ³ [6] - Model        			                                ³±±
±±³          ³ [7] - Filtro       			                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/            

Static Function OsM012Rot(aListBox)
Local   nI         := 0
Local   aRotProc 	 := {}

For nI := 1 To Len(aListBox)
	If aListBox[nI,CRMARCA] == '1'
		Aadd(aRotProc, {aListBox[nI,CRMARCA],aListBox[nI][CRNOTA],aListBox[nI][CRSERIE], aListBox[nI][CRCLIENTE], aListBox[nI][CRLOJA] } )
	EndIf	
Next nI

Return ( aRotProc )

Static Function FIELDMEMO(cTexto)
Local oDlg

DEFINE MSDIALOG oDlg TITLE "Mensagem do Model" From 0,0 To 18,70 OF oMainWnd
	@ 4, 006 SAY "Mensagem de retorno do SIGAGFE:" SIZE 130,7 PIXEL OF oDlg

    oTMultiget1 := TMultiget():New(13,06,{|u|If(Pcount()>0,cTexto:=u,cTexto)},;
                           oDlg,265,105,,,,,,.T.,,,,,,.T.)

	oButtonOK   := tButton():New(125,5,'OK',oDlg,{|| oDlg:End()},25,10,,,,.T.)

ACTIVATE MSDIALOG oDlg CENTER

Return
//-----------------------------------------------------
/*/Monta a lista de notas fiscais que nao foram integradas
@author Felipe Machado de Oliveira
@version P11
@since 17/07/2013
/*/
//------------------------------------------------------
Static Function MontaList(aListBox)
Local aAreaGW0 := GW0->( GetArea() )
Local nTenta := 1
Local cNota := ""
Local cSerie := ""
Local cCliente := ""
Local cLoja := ""

aListBox := {}

dbSelectArea("GW0")
GW0->( dbSetOrder(1) )
GW0->( dbSeek(xFilial("SF2")+PadR( "F2PEND", TamSX3("GW0_TABELA")[1] )) )
While !GW0->( EOF() ) .And. GW0->GW0_FILIAL == xFilial("SF2") ;
						 .And. AllTrim(GW0->GW0_TABELA) == "F2PEND"
	
	nTenta := PadR( GW0->GW0_NUM01 , 3 )
	cNota := PadR( GW0->GW0_CHAR01 , TamSX3("F2_DOC")[1] )
	cSerie := PadR( GW0->GW0_CHAR02 , TamSX3("F2_SERIE")[1] )
	cCliente := PadR( GW0->GW0_CHAR03 , TamSX3("F2_CLIENTE")[1] )
	cLoja := PadR( GW0->GW0_CHAR04 , TamSX3("F2_LOJA")[1] )

	Aadd(aListBox,{'2',;
					cNota,;
					cSerie,;
					cCliente,;
					cLoja,;
					nTenta,;
					"MEMO",;
					GW0->GW0_CHAVE,;
					GW0->GW0_MEMO01})
	
	GW0->( dbSkip() )
EndDo

RestArea( aAreaGW0 )

Return
//-----------------------------------------------------
/*/ Seleciona as notas fiscais de saida
@author Felipe Machado de Oliveira
@version P11
@since 17/07/2013
/*/
//------------------------------------------------------
Static Function SelDados(aListBox,oListBox,lRefresh)
Local lRet := .T.

//-- Array com as notas a serem integradas no GFE
CursorWait()
MontaList(@aListBox)
CursorArrow()

If Empty(aListBox)
	Help( ,, STR0035,,"Não há Notas Fiscais de Saída pendentes.", 1, 0) //"Atenção"##"Não há Notas Fiscais de Saída pendentes."
	lRet := .F.
EndIf

If lRefresh
	oListBox:SetArray( aListBox )
	oListBox:bLine      := { || {	Iif(aListBox[ oListBox:nAT,CRMARCA ] == '1',oOk,oNo),;
										aListBox[ oListBox:nAT,CRNOTA ],;
										aListBox[ oListBox:nAT,CRSERIE ],;
										aListBox[ oListBox:nAT,CRCLIENTE ],;
										aListBox[ oListBox:nAT,CRLOJA ],;
										aListBox[ oListBox:nAT,CRTENTA ],;
										aListBox[ oListBox:nAT,CRMEMO ]}}
	oListBox:Refresh()
EndIf

Return lRet
