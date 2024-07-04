#INCLUDE "Tmsa330.ch" 
#INCLUDE "Protheus.CH"
#INCLUDE "FOLDER.CH" 

Static aFolder    := {}
Static lTMAGRVDU9 := Existblock('TMAGRVDU9')  //-- Executado apos a gravacao do DU9 (Itens de fechamento de Seguro)
Static lTMGRVDU8  := Existblock('TMGRVDU8')   //-- Executado apos a gravacao do DU8 (Fechamento de Seguro)
Static lEAIFunOK  := (FindFunction("GETROTINTEG") .And. FindFunction("FwHasEAI") .And. Len(GetSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0)
Static cTmsErp    := SuperGetMV("MV_TMSERP",,'0') //  // Parametro assume 0=Integração Nativa TMS Protheus; ou '1'- TMS X DATASUL


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSA330  ³ Autor ³Patricia A. Salomao    ³ Data ³01.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Fechamento de Seguro                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA330()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                  ATUALIZACOES - VIDE SOURCE SAFE                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA330()

Local aCores   := {}

AAdd(aCores,{ 'DU8_STATUS == "1"','BR_VERDE'		}) //-- Em Aberto
AAdd(aCores,{ 'DU8_STATUS == "2"','BR_VERMELHO'	}) //-- Confirmado

Private cCadastro	:= STR0001 //"Fechamento de Seguro"
Private aRotina	:= MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse(6,1,22,75,"DU8",,,,,,aCores)                  

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA330Mnt  ³ Autor ³ Patricia A. Salomao ³ Data ³01.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao do Fechamento de Seguro                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA330Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA330Mnt(cAlias, nReg, nOpcx)

Local nLoop
Local oEnchoice, nCntFor
Local nOpca	   := 0
Local aAreaAnt := GetArea()
Local aObjects := {}
Local aPosObj  := {}
Local aPosGetD := {}
Local aInfo	   := {}
Local aSize    := MsAdvSize()
Local aAlter
Local lRet     := .T.
Local nUsado   := 0
Local aPages   := {}
Local aTitles  := {}
Local nOpcxTms := nOpcx
Local cForSeg  := AllTrim(GetMV('MV_FORSEG',,''))
Local oFont    := TFont():New("Courier New",20,30,,.T.)
Local cSeekSE2 := ""
Local lDu7Doc  := DU7->( FieldPos("DU7_DOCSEG")) > 0
Local aRetInt  := {}
Local oXML     := NIL
Local cXmlResp := ""

Private aSetKey  := {}
Private aHeader  := {}
Private aCols    := {}
Private aTela[0][0],aGets[0]
Private aSvFolder := {}
Private o1Get, o2Get, oDlg, oFolder, oTotPremio
Private cDescTab := "", __lDelOk := .F.
Private oDTClass   := NIL

//|
//| Valida se existe a classe de integração EAI Contas Pagar
If Len(GetSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0
   oDTClass := TransportDocumentClass():New()
EndIf 


Pergunte("TMA330",.F.)

If nOpcx == 2 .And. lDu7Doc
	AAdd(aSetKey , { VK_F5   ,{||TMS330Avr(nOpcx) } }  )
ElseIf nOpcx == 3 //-- Fechar

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria a Trava com o Nome 'SEGURO'. Se algum usuario estiver fechando seguro ³
	//³ a rotina de nao podera ser executada               						   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !LockByName("SEGURO",.T.,.F.)
		Help("",1 , "TMSA33008")
		Return
	EndIf

	SA2->( DbSetOrder( 1 ) )
	If cForSeg == Nil .Or. Empty(cForSeg) .Or. SA2->( !MsSeek( xFilial('SA2')+cForSeg ) ) 
	   Help("",1 , "TMSA33001") // Parâmetro MV_FORSEG invalido
	   Return 
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as perguntas selecionadas                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ mv_par01 - Fil.Origem De  ?                                  ³
	//³ mv_par02 - Fil.Origem Ate ?                                  ³
	//³ mv_par03 - De Emissao  ?                                     ³
   //³ mv_par04 - Ate Emissao ?                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Pergunte("TMA330",.T.)
		Processa({||TMSA330Fech( cForSeg )},cCadastro)
	EndIf		
	
	UnLockByName("SEGURO",.T.,.F.) // Libera Lock
	
	Return
ElseIf nOpcx == 4 .And. DU8->DU8_STATUS != StrZero( 1, Len( DU8->DU8_STATUS ) ) //-- Alterar
	Help("",1,"TMSA33003") // A Alteracao so sera permitida se o Fechamento de Seguro estiver em Aberto.
	Return 
ElseIf nOpcx == 5 //-- Estornar
	If DU8->DU8_STATUS == StrZero( 2, Len( DU8->DU8_STATUS ) ) //-- Confirmado
		
		Pergunte("TMA330",.F.)	
		
		SE2->( DbSetOrder( 6 ) )
		DU3->( DbSetOrder( 1 ) )
		DU9->( DbSetOrder( 2 ) )
		DU3->( DbGoTop() )
		
		//+----------------------------------------------------------------------
		//| Integração EAI ligada valida se o titulo existe na outra ponta antes
		//| e faz a exclusão de acordo com o retorno.
		//+----------------------------------------------------------------------
		If cTMSERP == "1"
            //| Rotinas de Integração e Configuração do Adapter Ok, faz a chamada da rotina de integração TMSI330ABP
            If lEAIFunOK 
                If FwHasEAI("TMSA330",.T.,,.T.) 
                    oDTClass:reset() // Limpa os atributos
                    oDTClass:cVIAGEM      := ""
                    oDTClass:cFILORI      := cFilAnt
                    oDTClass:cTITULO      := DU8->DU8_DOCSEG
                    oDTClass:cCODCLIENTE  := DU8->DU8_CODFOR
                    oDTClass:cLOJCLIENTE  := DU8->DU8_LOJFOR
                    oDTClass:dTRANSACAO   := Date()
                    oDTClass:cEventType   := "delete"
                    oDTClass:cTipoMsg     := "4"
                    oDTClass:cSubTipoMsg  := "401"

                    SetRotInteg("TMSA330")
                    aRetInt := FwIntegDef("TMSA330")
                    lRet    := Iif(ValType(aRetInt)=="U",.F.,aRetInt[1])
                              
                    If !lRet
                        Help('', 1, 'TMSA33006' ) //-- Erro ao localizar título a pagar do fechamento
                        Return
                    Else
                        Aviso(STR0019,STR0024,{STR0004})
                    EndIF
                EndIf
     	   EndIf//|[fecha If lEAIFunOk == .T.

		//+----------------------------------------------------------------------
		//| Integração Nativa TMS Protheus X Financeiro
		//+----------------------------------------------------------------------
		Else
			While DU3->( !Eof() )
			
				If DU9->( MsSeek( xFilial( 'DU9' ) + DU8->DU8_DOCSEG + DU8->DU8_SERTMS + DU8->DU8_TIPTRA + DU3->DU3_COMSEG + 'TP' ) )
					
					//-- Localiza o titulo 
					If SE2->( !MsSeek( cSeekSE2 := xFilial("SE2")+DU8->DU8_CODFOR+DU8->DU8_LOJFOR+DU3->DU3_PRETPG+DU8->DU8_DOCSEG ) )
						Help('', 1, 'TMSA33006' ) //-- Erro ao localizar título a pagar do fechamento  
						Return
					EndIf	
					
					While SE2->(!Eof()) .And. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == cSeekSE2
						//-- Verifica se o titulo ja foi baixado
						If SaldoTit(DU3->DU3_PRETPG,DU8->DU8_DOCSEG,SE2->E2_PARCELA,DU3->DU3_TIPTPG,,"P",DU8->DU8_CODFOR,,,,DU8->DU8_LOJFOR) == 0
							Help('', 1, 'TMSA33005') //-- Baixa do título a pagar do fechamento ja efetuada
							Return 
						EndIf
						SE2->(dbSkip())
					EndDo										
				EndIf
				
				DU3->( DbSkip() )					
			EndDo
		EndIf
		
	EndIf		
ElseIf nOpcx == 6 //-- Confirmar
	Pergunte("TMA330",.F.)	
	If DU8->DU8_STATUS == StrZero( 2, Len( DU8->DU8_STATUS ) ) 
		Help("",1,"TMSA33002") //Este Fechamento de Seguro Ja foi Confirmado ...
		Return		
	EndIf
	nOpcxTms := 2
EndIf

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Inclui := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as posicoes da Getdados a partir do folder    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aObjects, { 000, 90, .T., .F. } )
AAdd( aObjects, { 100, 50, .T., .T. } )
AAdd( aObjects, { 000, 20, .T., .F. } )

aInfo	:= { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }

aPosObj := MsObjSize( aInfo, aObjects)

nGd1 := 2
nGd2 := 2
nGd3 := aPosObj[2,3]-aPosObj[2,1]-15
nGd4 := aPosObj[2,4]-aPosObj[2,2]-4

RegToMemory("DU8", .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Folder   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TMSA330Fol( nOpcx )

If Len(aFolder) == 0
	Help("",1,"TMSA30004") //-- Nao Existem componentes cadastrados para a tabela de seguro ...
	Return( Nil )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona Titles e Pages ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Aeval( aFolder, { | aFolderLine | 	AAdd( aTitles, aFolderLine[2] ), AAdd( aPages,  "AHEADER" ) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem da Tela  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desenha Enchoice ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oEnchoice := MsMGet():New( cAlias ,nReg, nOpcxTms, , , , , aPosObj[1], aAlter, 3,,,,,, .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desenha Folders  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oFolder := TFolder():New(	aPosObj[2,1],aPosObj[2,2],aTitles,aPages, oDlg,,,,.T.,.F.,;
aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as GetDados na Ordem INVERSA de Apresentacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nLoop := Len( aFolder ) TO 1 STEP - 1
	aHeader := aClone( aFolder[nLoop][4] )
	aCols   := aClone( aFolder[nLoop][5] )
	n := 1
	aFolder[nLoop][8] := MSGetDados():New(	nGd1,nGd2,nGd3,nGd4,nOpcxTms ,;
	aFolder[nLoop][6],aFolder[nLoop][7],"+DU9_ITEM",nOpcx!=2 ,,,,,,,,"TMSA330Del()",oFolder:aDialogs[nLoop]	)
	
	aFolder[nLoop][8]:oBrowse:lDisablePaint := .T.
	
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita o Trocador de Folder³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oFolder:bSetOption:={|nAtu| TMSA330Chg( nAtu, oFolder:nOption ) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Total do Premio              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel := TPanel():New(aPosObj[3,1],aPosObj[3,2],"",oDlg,,,,,CLR_WHITE,(aPosObj[3,4]-aPosObj[3,2]), (aPosObj[3,3]-aPosObj[3,1]), .T.)

//TSay():New( 05, 05, {|| STR0016 },oPanel,,oFont,,,,.T.,CLR_HBLUE,CLR_WHITE)

@ 05,005 SAY   STR0016 OF oPanel PIXEL FONT oDlg:oFont COLOR CLR_HBLUE //--TOTAL DO PRÊMIO 
@ 05,280 MSGET oTotPremio VAR aFolder[ oFolder:nOption ][ 10 ] PICTURE '@E 999,999,999.99' WHEN .F. OF oPanel PIXEL RIGHT SIZE 75,09 
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama Localizador de Folder Ativo ³
//³ Desenha a EnchoiceBar             ³
//³ Ativa Obrigat da Enchoice         ³
//³ Ativa Obrigat das GetDados        ³
//³ Ativa Dialog  Principal           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ACTIVATE MSDIALOG oDlg ON INIT ( TMSA300Loc( nOpcx, oFolder,aFolder),;
											TMSA330Bar(oDlg, {||nOpca:=1,If(TMSA330Ok(oFolder:nOption,nOpcx) ,;
											Iif(!Obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()}, nOpcx) )

If	nOpca == 1
	If nOpcx == 6 //-- Confirmar
		Processa({|| TMSA330Conf()},cCadastro)
	Else 
		Processa({|| TMSA330Grv(nOpcx)},cCadastro)
	EndIf		
EndIf

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

RestArea(aAreaAnt)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA330Grv    ³ Autor ³ Patricia A. Salomao  ³ Data ³01.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava o Fechamento de Seguro                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA330Grv(nOpcx)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Opcao Selecionada (Inclusao/Alteracao/Exclusao/...)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC FUNCTION TMSA330Grv(nOpcx, cMasterAlias, cSlaveAlias, nSlaveOrder, ;
									cSlaveSeek, bSlaveFor, bSlaveWhile, bMasterRec, cbSlaveRec  )
Local ni
Local aArea      :=	GetArea()
Local lRetorno   :=	.T. 
Local lRet       := .T. 
Local cSeek
Local i,nIndex,cArqDT6, cKeyDT6, cFilDT6, aNoEmptyField	
Local cAliasQry  := ''
Local cQuery     := ''
Local aDadExcSE2 := {}
Local lExibeLanc := Iif(mv_par06 == 2,.F.,.T.)
Local lOnline    := Iif(mv_par07 == 2,.F.,.T.)
Local lDu7Doc    := DU7->( FieldPos("DU7_DOCSEG")) > 0
Private lMsErroAuto := .F.

Default cMasterAlias :=	"DU8"
Default cSlaveAlias	 :=	"DU9"
Default nSlaveOrder	 :=	1
Default cSlaveSeek	 :=	M->DU8_FILIAL + M->DU8_DOCSEG  + M->DU8_SERTMS + M->DU8_TIPTRA 

Default bSlaveFor    := { || .T. } 
Default bSlaveWhile	 := { || 	xFilial() + DU9->DU9_DOCSEG+ DU9->DU9_SERTMS + DU9->DU9_TIPTRA +DU9->DU9_COMSEG }
Default bMasterRec   := { || Nil } 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos a serem gravados alem do ACOLS ( Slave )  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Default cbSlaveRec   := "{ || " + ; 
								"DU9->DU9_DOCSEG := M->DU8_DOCSEG , DU9->DU9_SERTMS := M->DU8_SERTMS, " + ;
								"DU9->DU9_TIPTRA := M->DU8_TIPTRA , " +;
								"DU9->DU9_COMSEG := '" 

If nOpcx == 5 // Estornar

	Do Case
		Case DU8->DU8_STATUS == StrZero( 1, Len( DU8->DU8_STATUS ) ) //-- Em Aberto

			//-- Exclui o fechamento de seguro
		  	RecLock("DU8", .F.)
		   	dbDelete()
		   	MsUnLock()    
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta Observacao do Fechmaneto.                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MSMM(DU8->DU8_CODOBS,,,,2)


			//-- Estorna Itens do Fechamento
			cQuery := " UPDATE " + RetSqlName("DU9") + " SET D_E_L_E_T_ = '*' "
			cQuery += "   WHERE DU9_FILIAL = '" + xFilial("DU9") + "' "
			cQuery += "     AND DU9_DOCSEG = '" + DU8->DU8_DOCSEG + "' "
			cQuery += "     AND D_E_L_E_T_ = ' ' "
			TCSqlExec( cQuery ) 
			If lDu7Doc
				//-- Estorna Averbacao
				cQuery := " UPDATE " + RetSqlName("DU7") + " SET D_E_L_E_T_ = '*' "
				cQuery += "   WHERE DU7.DU7_FILIAL = '" + xFilial("DU7") + "' "
				cQuery += "       AND DU7.DU7_DOCSEG = '" + DU8->DU8_DOCSEG + "' "
				cQuery += "       AND DU7.D_E_L_E_T_ = ' '  "
	         //-- Limpa o numero do documento de seguro no conhecimento
				cQuery := " UPDATE " + RetSqlName("DT6") + " SET DT6_DOCSEG = '" + Space(Len(DT6->DT6_DOCSEG)) +"' "
				cQuery += "   WHERE R_E_C_N_O_ IN ( "
				cQuery += "     SELECT DT6.R_E_C_N_O_ "
				cQuery += " 	  FROM " + RetSqlName("DT6") + " DT6 "
				cQuery += "       JOIN " + RetSqlName("DU7") + " DU7 "
				cQuery += "       ON DU7.DU7_FILIAL = '" + xFilial("DU7") + "' "
				cQuery += "       AND DU7.DU7_FILDOC = DT6.DT6_FILDOC "
				cQuery += "       AND DU7.DU7_DOC    = DT6.DT6_DOC "
				cQuery += "       AND DU7.DU7_SERIE  = DT6.DT6_SERIE "
				cQuery += "       AND DU7.D_E_L_E_T_ = ' ' "
				cQuery += "       WHERE DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
				cQuery += "       AND DU7.DU7_DOCSEG = '" + DU8->DU8_DOCSEG + "'"
				cQuery += "       AND DT6.D_E_L_E_T_ = ' ' )"
				TCSqlExec( cQuery ) 
			Else
				//-- Estorna Averbacao
				cQuery := " UPDATE " + RetSqlName("DU7") + " SET D_E_L_E_T_ = '*' "
				cQuery += "   WHERE R_E_C_N_O_ IN ( "
				cQuery += "     SELECT DU7.R_E_C_N_O_ "
				cQuery += " 	  FROM " + RetSqlName("DT6") + " DT6 "
				cQuery += "       JOIN " + RetSqlName("DU7") + " DU7 "
				cQuery += "       ON  DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
				cQuery += "       AND DT6.DT6_DOCSEG = '" + DU8->DU8_DOCSEG + "' "
				cQuery += "       AND DT6.D_E_L_E_T_ = ' ' "
				cQuery += "       AND DU7.DU7_FILIAL = '" + xFilial("DU7") + "' "
				cQuery += "       AND DU7.DU7_FILDOC = DT6.DT6_FILDOC "
				cQuery += "       AND DU7.DU7_DOC = DT6.DT6_DOC "
				cQuery += "       AND DU7.DU7_SERIE = DT6.DT6_SERIE "
				cQuery += "       AND DU7.D_E_L_E_T_ = ' ' ) "
				TCSqlExec( cQuery ) 
	         //-- Limpa o numero do documento de seguro no conhecimento
				cQuery := " UPDATE " + RetSqlName("DT6") + " SET DT6_DOCSEG = ' ' "
				cQuery += "   WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
				cQuery += "     AND DT6_DOCSEG = '" + DU8->DU8_DOCSEG + "' "
				cQuery += "     AND D_E_L_E_T_ = ' ' "
				TCSqlExec( cQuery ) 
			EndIf	
	
		Case DU8->DU8_STATUS == StrZero( 2, Len( DU8->DU8_STATUS ) ) //-- Confirmado
			DU9->( DbSetOrder( 2 ) )
			DU3->( DbSetOrder( 1 ) )
			DU3->( DbGoTop() )
			While DU3->( !Eof() )   
			
				If DU9->( MsSeek( xFilial( 'DU9' ) + DU8->DU8_DOCSEG + DU8->DU8_SERTMS + DU8->DU8_TIPTRA + DU3->DU3_COMSEG + 'TP' ) )
				
					dbSelectArea("SE2")
					dbSetOrder(6)
					If MsSeek( cSeek:= xFilial("SE2")+DU8->DU8_CODFOR+DU8->DU8_LOJFOR+DU3->DU3_PRETPG+DU8->DU8_DOCSEG )
						While SE2->( !Eof() ) .And. SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == cSeek
							//-- Apagar titulo                                                      
							aDadExcSE2 := {}
							AAdd(aDadExcSE2,{"E2_FILIAL" ,  SE2->E2_FILIAL ,Nil})
							AAdd(aDadExcSE2,{"E2_PREFIXO" , SE2->E2_PREFIXO,Nil})
							AAdd(aDadExcSE2,{"E2_NUM"     , SE2->E2_NUM    ,Nil})
							AAdd(aDadExcSE2,{"E2_PARCELA" , SE2->E2_PARCELA,Nil})
							AAdd(aDadExcSE2,{"E2_TIPO"    , SE2->E2_TIPO   ,Nil})
							AAdd(aDadExcSE2,{"E2_FORNECE" , SE2->E2_FORNECE,Nil})
							AAdd(aDadExcSE2,{"E2_LOJA"    , SE2->E2_LOJA   ,Nil})
							MSExecAuto({| a,b,c,d,e,f,g| FINA050(a,b,c,d,e,f,g)} ,aDadExcSE2, , 5,,,lExibeLanc,lOnline) //Na exclusao nao mostra a tela de Lancamentos
							If lMsErroAuto         
								MostraErro()
								//--Devolve o valor para lMsErroAuto para avaliar o proximo titulo (se houver)
								lMsErroAuto := .F. 
							EndIf
							SE2->(DbSkip())
						Enddo
					Endif	
				EndIf
				
				DU3->( DbSkip() )
				
			EndDo			
		
			//-- Exclui itens de fechamento de seguro
			RecLock("DU8",.F.)
			DU8->DU8_STATUS := StrZero( 1, Len( DU8->DU8_STATUS ) ) //-- Em Aberto
			MsUnLock()
	      
	EndCase	      

Else //Alterar

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao das Getdados ( Slave )³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aeval( aFolder, { |aFolderGetDados, nI, cFolder | cFolder := aFolderGetDados[1], bRecFields := &(cbSlaveRec + cFolder + "' }"), ;
																		TMSRecGetDados( 	cSlaveAlias, aFolderGetDados[3], aFolderGetDados[4], ;
																		aFolderGetDados[5], bRecFields, aNoEmptyFields ) } )
																		
	//-- Atualiza total do premio por ramo de seguro
	DU9->( DbSetOrder( 2 ) )
	For nI := 1 To Len( aFolder )
		If DU9->( MsSeek( xFilial( 'DU9' ) + M->DU8_DOCSEG + M->DU8_SERTMS + M->DU8_TIPTRA + aFolder[ nI ][ 1 ] + 'TP' ) )
			RecLock( 'DU9', .F. )
			DU9->DU9_VALOR := aFolder[ nI ][ 10 ]
			MsUnLock()
		EndIf
	Next					

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao da Enchoice ( Master )³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	RecLock( cMasterAlias, nOpcx== 3 )
	
	If nOpcx <> 5
		Aeval( dbStruct(), { |	aFieldName, nI | 	FieldPut( nI, ;
																If( 	'FILIAL' $ aFieldName[1],;
																		xFilial( cMasterAlias ), ;
																		M->&( aFieldName[1] ) ) ) } ) 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravacao Adicional da Enchoice se houver ( Master )³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Eval( bMasterRec )
		
	EndIf
	
	MsUnLockAll()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao Observacao do Fechmaneto.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSMM(DU8->DU8_CODOBS,,,M->DU8_OBSERV,1,,,'DU8','DU8_CODOBS')
	
	RestArea( aArea )
EndIf
	
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA330LOK ³ Autor ³ Patricia A. Salomao     ³ Data ³01.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia da Linha digitada.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA330LOK()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Logico                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA330                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA330LOK()

Local lRet := .T.

If !GDdeleted(n) 
   lRet := MaCheckCols(aHeader,aCols,n)
EndIf   

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA330Fol ³ Autor ³ Patricia A. Salomao  ³ Data ³01.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega todos os Folder no aFolder                         ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA330Fol(nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile,;   ³±±
±±³          ³			bSeekFor, aNoFields, aYesFields, cLinhaOk, ;      ³±±
±±³          ³			cTudoOk )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1      - Opcao Selecionada                              ³±±
±±³          ³ExpC1      - Alias                                          ³±±
±±³          ³ExpN2      - Ordem                                          ³±±
±±³          ³ExpC2      - Chave de Seek para montar aCols                ³±±
±±³          ³ExpB1      - Condicao While                                 ³±±
±±³          ³ExpB2      - Condicao For                                   ³±±
±±³          ³ExpA1      - Campos a serem excluidos                       ³±±
±±³          ³ExpA2      - Campos a serem incluidos                       ³±±
±±³          ³ExpC3      - Valida Linha                                   ³±±
±±³          ³ExpC4      - Valida Tudo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³ Possui Ponto de Entrada p/ Mudanca de Folders pelo usuario ³±±
±±³          ³                                                            ³±±
±±³          ³ Estrutura do Array de Folders                              ³±±
±±³          ³                                                            ³±±
±±³          ³   [1] -> Tipo "N" , Numero do Folder ( DT3_CODPAS )        ³±±
±±³          ³   [2] -> Tipo "C" , Titulo do Folder                       ³±±
±±³          ³   [3] -> Tipo "A" , aColsRecno ( Recno() de cada aCols )   ³±±
±±³          ³   [4] -> Tipo "A  , aHeader   da GetDados do Folder        ³±±
±±³          ³   [5] -> Tipo "A" , aCols     da GetDados do Folder        ³±±
±±³          ³   [6] -> Tipo "C" , cLinhaOk  da GetDados do Folder        ³±±
±±³          ³   [7] -> Tipo "C" , cTudoOk   da GetDados do Folder        ³±±
±±³          ³   [8] -> Tipo "O" , oGetDados deste Folder                 ³±±
±±³          ³   [9] -> Tipo "A" , Campos que podem ser alterados         ³±±
±±³          ³                                                            ³±±
±±³          ³  Estrutura do Array aFillGetDados                          ³±±
±±³          ³                                                            ³±±
±±³          ³   [1] -> Tipo "C" , cAlias do Arquivo                      ³±±
±±³          ³   [2] -> Tipo "N" , nOrder	do Indice                     ³±±
±±³          ³   [3] -> Tipo "C" , cSeekKey, chave de Pesquisa            ³±±
±±³          ³   [4] -> Tipo "B" , bSeekWhile, Pesquisa  While            ³±±
±±³          ³   [5] -> Tipo "B" , bSeekFor, Pesquisa  For                ³±±
±±³          ³   [6] -> Tipo "A" , aNoFields, NAO vao aparecer no aHeader ³±±
±±³          ³   [7] -> Tipo "A" , aYesFields, VAO aparecer no aHeader    ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA330Fol( nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, bSeekFor, ;
									aNoFields, aYesFields, cLinhaOk, cTudoOk, aAlter )

Local nAtalho	   := 1
Local nTotPremio   := 0

Default cAlias 	   := "DU9"
Default nOrder     := 1
Default cSeekKey   := xFilial( "DU9" ) + M->DU8_DOCSEG + M->DU8_SERTMS + M->DU8_TIPTRA 
Default bSeekWhile := { || DU9->DU9_FILIAL + DU9->DU9_DOCSEG +DU9->DU9_SERTMS + DU9->DU9_TIPTRA + DU9->DU9_COMSEG }
Default bSeekFor   := { || DU9->DU9_CODHIS != "TP" } 
Default aNoFields  := { "DU9_COMSEG", "DU9_DOCSEG", "DU9_SERTMS", "DU9_TIPTRA", "DU9_COMSEG" }
Default cLinhaOk   := "TMSA330LOk"
Default cTudoOk    := "TMSA330LOk"

aFolder := {}

DU3->( dbSetOrder( 1 ) )
DU3->( dbGoTop() )

Do While ! DU3->( Eof() )

	DU9->( DbSetOrder( 2 ) )
	If DU9->( MsSeek( cSeekKey + DU3->DU3_COMSEG + 'TP' ) )
		nTotPremio := DU9->DU9_VALOR
	Else
		DU3->( DbSkip() )
		Loop		
	EndIf
	
	aHeader := {}
	aCols   := {}
	nAtalho := 1
	
	AAdd( aFolder, {	DU3->DU3_COMSEG, ;
							AllTrim( DU3->DU3_DESCRI ), 	;							
							TMSFillGetDados(	nOpcx, ;
													cAlias,	;
													nOrder,	;
													cSeekKey + DU3->DU3_COMSEG, ; 
													bSeekWhile, ;
													bSeekFor , ;
													aNoFields,	;
													aYesFields ;
												 ), ;
							aClone( aHeader ), ;
							aClone( aCols ), ;
							cLinhaOk, ;
							cTudoOk, ;
							Nil, ;
							aAlter, ;
							nTotPremio } )

	//-- Define letra de atalho para acessar o folder
	If	!Empty( DU3->DU3_ATALHO )
		nAtalho := At( DU3->DU3_ATALHO, UPPER(aFolder[ Len(aFolder), 2 ]) )
		If Empty( nAtalho )
			nAtalho := 1
		EndIf
	EndIf

	aFolder[ Len(aFolder), 2 ] := Stuff( aFolder[ Len(aFolder), 2 ], nAtalho, 0, '&' )

	DU3->( dbSkip() )
EndDo	

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA330Bar ³ Autor ³Patricia A.Salomao  ³ Data ³ 01/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Enchoice bar especifica                                     ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA330Bar(ExpO1,ExpB1,ExpB2,ExpN1)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpB1  - Dialog do Window                                   ³±±
±±³          ³ExpB2  - Evento Ok                                          ³±±
±±³          ³ExpB3  - Evento Cancel                                      ³±±
±±³          ³ExpN1  - Opcao da Mbrowse                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Objeto EnchoiceBar                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA330                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static FUNCTION TMSA330Bar( oDlg, bOk, bCancel, nOpcx )

Local nCont        := 0
Local aSomaButtons := {}
Local aButtons     := {}
Local lDu7Doc      := DU7->( FieldPos("DU7_DOCSEG")) > 0
If nOpcx == 2 .And. lDu7Doc
	AAdd(aButtons, {'DEVOLNF',{||TMS330Avr(nOpcx)}, STR0017 , STR0018 }) //'Averbacao'
EndIf
//-- Ponto de entrada para incluir botoes na enchoicebar
If	ExistBlock('TM330BUT')
	aSomaButtons:=ExecBlock('TM330BUT',.F.,.F.,{nOpcx})
	If	ValType(aSomaButtons) == 'A'
		For nCont:=1 To Len(aSomaButtons)
			AAdd(aButtons,aSomaButtons[nCont])
		Next
	EndIf
EndIf

Return( EnchoiceBar( oDlg, bOK, bCancel,, aButtons ) )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA330Chg ³ Autor ³Patricia A. Salomao ³ Data ³ 01/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Troca de Folder                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA330Chg(ExpN1,ExpN2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - nTargetFolder - Folder Destino                      ³±±
±±³          ³ExpC2 -  nSourceFolder - Folder Atual                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. se a Troca de Folder foi permitida                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA330                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³ Checa a validacao da Getdados Atual e copia corretamente   ³±±
±±³          ³ aHeader e Acols dos Folders Atual e Destino                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION TMSA330Chg( nTargetFolder, nSourceFolder )

Local nI
Local lRetorno
Local lEmpty 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a GetDados nao esta deletada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Acols[1][Len(aHeader)+1]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VerIfica se os campos obrigatorios estao vazios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Aeval( aFolder[nSourceFolder][8]:aPosCol, { |aPosCol| 	If ( !lEmpty .AND. ;
																						Empty( aCols[1][aPosCol[2]] ), ;
																						lEmpty := .T.	, Nil ) } )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se TODOS estiverem vazios e nao sofre modIficacao ³
	//³ deleta para passar no 'OBRIGAT' 						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lEmpty .AND. ! aFolder[nSourceFolder][8]:lChgField
		aCols[1][Len(aHeader)+1] := .T.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a Validacao da GetDados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ( lRetorno := aFolder[nSourceFolder][8]:TudoOk() ) 

	aFolder[nSourceFolder][8]:oBrowse:lDisablePaint := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava aHeader e Acols do Afolder com as mudancas     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFolder[nSourceFolder][4] := aClone( aHeader )
	aFolder[	nSourceFolder][5] := aClone( aCols )
	n := Max( aFolder[nTargetFolder][8]:oBrowse:nAt,1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava aHeader e Acols a partir do aFolder            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := aClone( aFolder[nTargetFolder][4] )
	aCols   := aClone( aFolder[nTargetFolder][5] )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VerIfica se os campos obrigatorios estao vazios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   lEmpty := .F.
	Aeval( aFolder[nTargetFolder][8]:aPosCol, { |aPosCol| 	If ( !lEmpty .AND. ;
																						Empty( aCols[1][aPosCol[2]] ), ;
																						lEmpty := .T.	, Nil ) } )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se TODOS estiverem vazios e nao sofre modIficacao ³
	//³ dah RECALL porque esta funcao DELETOU !!          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aCols[1][Len(aHeader)+1] .AND. lEmpty .AND. ;
      ! aFolder[nTargetFolder][8]:lChgField
		aCols[1][Len(aHeader)+1] := .F.
	EndIf

	aFolder[nTargetFolder][8]:oBrowse:lDisablePaint := .F.
	aFolder[nTargetFolder][8]:oBrowse:Refresh(.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seta Variavel Private nFolder para o Folder Target ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nFolder := nTargetFolder
                         
   If Type('oTotPremio') == 'O'           
		@ 05,280 MSGET oTotPremio VAR aFolder[ nTargetFolder ][ 10 ] PICTURE '@E 999,999,999.99' WHEN .F. OF oPanel PIXEL RIGHT SIZE 75,09 
		oTotPremio:Refresh()
	EndIf	
	
EndIf

Return( lRetorno )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA330Ok  ³ Autor ³Patricia A. Salomao ³ Data ³ 01/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Tudo antes da Gravacao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA330Ok(ExpN1,ExpN2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1  - Folder Atual                                       ³±±
±±³          ³ExpN2  - Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA330                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³Valida Folder a Folder comecando pelo atual                 ³±±
±±³          ³Checa se existe PELO MENOS UM Folder preenchido             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA330Ok( nSourceFolder, nOpcx )

Local lReturn  := .F.
Local aSavHead := aClone(aHeader)
Local aSavCols := aClone(aCols)
Local nSavN    := N
Local nLoop    := 0 
Local lEmpty   := .F.     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VerIfica se existe algum campo obrigatorio em Branco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aeval( aFolder[nSourceFolder][8]:aPosCol, { |aPosCol| 	If ( !lEmpty .AND. ;
																					Empty( aCols[1][aPosCol[2]] ), ;
																					lEmpty := .T.	, Nil ) } )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se estah vazio e nao sofreu modIficacao deleta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lEmpty .AND. ! aFolder[nSourceFolder][8]:lChgField
	aCols[1][Len(aHeader)+1] := .T.
EndIf

lEmpty := .T.

If ( aFolder[nSourceFolder][8]:TudoOk() ) 

	aFolder[nSourceFolder][4] 	:= aClone( aHeader )
	aFolder[	nSourceFolder][5] 	:= aClone( aCols )
	n := Max(aFolder[nSourceFolder][8]:oBrowse:nAt,1)

	lEmpty  := If( lEmpty, Ascan( aFolder[nSourceFolder][5], { |e| e[Len(e)] == .F. } ) = 0, lEmpty )

	lReturn := .T.

	For nLoop := 1 TO Len( aFolder )

		If nLoop == nSourceFolder
			Loop
		EndIf
		
		aHeader := aClone( aFolder[nLoop][4] )
		aCols   := aClone( aFolder[nLoop][5] )
		n := Max(aFolder[nLoop][8]:oBrowse:nAt,1)
		If !( aFolder[nLoop][8]:TudoOk() ) 
			lReturn := .F.
			Exit
      Else
			lEmpty  := If( lEmpty, Ascan( aCols, { |e| e[Len(e)] == .F. }  ) = 0, lEmpty )
		EndIf			

	Next nLoop
	
EndIf

If lReturn .And. lEmpty
	Help(" ",1,"TMSA01006") //"Todas as 'Pastas' estao vazias !!"
	lReturn := .F.
EndIf
           
aHeader := aClone(aSavHead)
aCols   := aClone(aSavCols)
N       := nSavN      

Return( lReturn )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA330Fech³ Autor ³Patricia A. Salomao ³ Data ³ 01/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava o Fechamento de Seguro                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA330Fech(ExpN1,ExpN2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA330Fech( cForSeg )

Local cForn      := Left(Alltrim(cForSeg),Len(SA2->A2_COD))
Local cLoja      := Right(Alltrim(cForSeg),Len(SA2->A2_LOJA))
Local nValorDT6  :=  0
Local aArrayDU7  := {}
Local aMsgErr    := {}
Local cCdHisAp   := Padr( GetMv( 'MV_CDHISAP',, '' ), Len( DVI->DVI_CODHIS ) )
Local cSerTms    := ''
Local cQuery     := '' 
Local lTMA330Fil := ExistBlock('TMA330FIL')
Local cArqDT6
Local cKeyDT6
Local cFilDT6
Local cTipTra
Local lGravou
Local cComSeg
Local nValPre
Local nX
Local nCnt
Local lRet
Local nI
Local aValSeg    := {}
Local cCliDev    := ''
Local cLojDev    := ''
Local cCdrOri    := ''
Local cCdrCal    := ''
Local cTabSeg    := ''
Local cTpTSeg    := ''
Local aAreaDT6   := DT6->(GetArea())
Local cAliasQry  := GetNextAlias()
Local aInfDoc    := {}
Local lFilFec    := ( DU8->(FieldPos("DU8_FILFEC")) > 0 .And. mv_par05 == 1 )
Local aDocSeg    := {}
Local nPos       := 0
Local cDocNAvb   := GetMv("MV_DOCNAVB",.F.,"A,B")
Local cNDocTms   := ""
Local cRetPE	 := ""
Local lTM330PEQ	 := Existblock('TM330PEQ')  //-- Ponto de entrada para que seja possível alterar
											//-- a query que seleciona os DT6.

//-- Ocorrencias que deveram ser consideradas
While !Empty(cDocNAvb)
	nPos:= At(",",cDocNAvb)
	If nPos > 0
		cNDocTms += "'" + SubStr(cDocNAvb,1,nPos-1) + "',"
		cDocNAvb := SubStr(cDocNAvb,nPos+1)
	Else
		cNDocTms += "'" + SubStr(cDocNAvb,1) + "',"
		cDocNAvb   := ""
	EndIf
EndDo
cNDocTms := SubStr(cNDocTms,1,Len(cNDocTms)-1)

DVI->( DbSetOrder( 1 ) )

If Empty( cCdHisAp ) .Or. DVI->( !MsSeek( xFilial( 'DVI' ) + cCdHisAp ) )
	Help( '', 1, 'TMSA33007' ) //-- Conteudo do parametro MV_CDHISAP (Codigo do Historico de apuracao de premio), invalido
	Return
EndIf	

cQuery := " SELECT DISTINCT DT6_SERTMS, DT6_TIPTRA, DT6_SERVIC, DT6_FILDOC, DT6_DOC   , DT6_SERIE , "
cQuery += "        DT6_VALMER, DT6_CLIDEV, DT6_LOJDEV, DT6_CDRORI, DT6_CDRCAL, DC5_TABSEG, "
cQuery += "        DC5_TPTSEG, DT6_DOCSEG, DT6_CLIREM, DT6_LOJREM, DT6_CLIDES, DT6_LOJDES, "
cQuery += "        DT6.R_E_C_N_O_ RECNO "
cQuery += "   FROM " 
cQuery += RetSqlName("DT6") + " DT6, "
cQuery += RetSqlName("DC5") + " DC5  "
cQuery += "   WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "     AND DT6_DATEMI BETWEEN '" + DtoS(mv_par03) + "' AND '" + DtoS(mv_par04) + "' "
cQuery += "     AND DT6_FILDOC BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
cQuery += "     AND DT6_SERIE  <> 'PED' "
cQuery += "     AND DT6_SERTMS IN ('2','3') "
If !Empty(cNDocTms)
	cQuery += "     AND DT6_DOCTMS NOT IN (" + cNDocTms + ") "
EndIf
cQuery += "     AND DT6_DOCSEG = ' ' "
cQuery += "     AND DT6.D_E_L_E_T_ = ' ' "
cQuery += "     AND DC5_FILIAL = '" + xFilial("DC5") + "' "
cQuery += "     AND DC5_SERVIC = DT6_SERVIC"
cQuery += "     AND DC5.D_E_L_E_T_ = ' ' "
cQuery += "   ORDER BY DT6_FILDOC, DT6_SERTMS, DT6_TIPTRA, DT6_SERVIC, DT6_CLIDEV, DT6_LOJDEV, DT6_CDRORI, DT6_CDRCAL "

If (lTM330PEQ)
	//-- Ponto de entrada para montagem da query que faz a seleção de DT6 para geração do seguro
	//-- Só é possível alterar a query a partir do WHERE.
	cRetPE := ExecBlock('TM330PEQ',.F.,.F.,{ cQuery })
	If ValType(cRetPE) == 'C'
		cQuery := cRetPE
	EndIf
EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

If (cAliasQry)->( Eof() )
	Help( '', 1, 'REGNOIS' ) //Nao existe registro relacionado a este codigo. 
Else
	While (cAliasQry)->(!Eof())
		cFilDoc := (cAliasQry)->DT6_FILDOC

		Begin Transaction
			While (cAliasQry)->(!Eof()) .And. cFilDoc == (cAliasQry)->DT6_FILDOC

				//-- Localiza o documento reservado para o tipo de servico e transporte
				If !lFilFec
					If ( nPos := Ascan( aDocSeg, { |x| x[1]+x[2] == (cAliasQry)->DT6_SERTMS + (cAliasQry)->DT6_TIPTRA } ) ) == 0
						cDoc := CriaVar("DU8_DOCSEG")
						AAdd( aDocSeg, { (cAliasQry)->DT6_SERTMS, (cAliasQry)->DT6_TIPTRA, cDoc } )
					Else
						cDoc := aDocSeg[nPos,3]
					EndIf
				Else
					cDoc := CriaVar("DU8_DOCSEG")
				EndIf

				nValorDT6 := 0
				aArrayDU7 := {}
				cTipTra   := (cAliasQry)->DT6_TIPTRA
				cSerTms   := (cAliasQry)->DT6_SERTMS
				cCliDev   := (cAliasQry)->DT6_CLIDEV
				cLojDev   := (cAliasQry)->DT6_LOJDEV
				cCdrOri   := (cAliasQry)->DT6_CDRORI
				cCdrCal   := (cAliasQry)->DT6_CDRCAL
				cServic   := (cAliasQry)->DT6_SERVIC
				cTabSeg   := (cAliasQry)->DC5_TABSEG
				cTpTSeg   := (cAliasQry)->DC5_TPTSEG
				lGravou   := .F.
				aValSeg   := {}
				
				While (cAliasQry)->(!Eof()) .And. cFilDoc == (cAliasQry)->DT6_FILDOC .And. cSerTms == (cAliasQry)->DT6_SERTMS .And. cTipTra == (cAliasQry)->DT6_TIPTRA
		
					//-- Zera o array aValSeg qdo o cliente / regiao for diferente do anterior.
					If (cAliasQry)->DT6_CLIDEV <> cCliDev .Or. (cAliasQry)->DT6_LOJDEV <> cLojDev .Or. ;
						(cAliasQry)->DT6_CDRORI <> cCdrOri .Or. (cAliasQry)->DT6_CDRCAL <> cCdrCal .Or. ;
						cTabSeg + cTpTSeg <> (cAliasQry)->(DC5_TABSEG+DC5_TPTSEG)
						cCliDev := (cAliasQry)->DT6_CLIDEV
						cLojDev := (cAliasQry)->DT6_LOJDEV
						cCdrOri := (cAliasQry)->DT6_CDRORI
						cCdrCal := (cAliasQry)->DT6_CDRCAL
						cServic := (cAliasQry)->DT6_SERVIC
						cTabSeg := (cAliasQry)->DC5_TABSEG
						cTpTSeg := (cAliasQry)->DC5_TPTSEG
						aValSeg := {}
					EndIf	
		
					If lTMA330Fil
						lRet := ExecBlock('TMA330FIL',.F.,.F.,{ (cAliasQry)->DT6_FILDOC, (cAliasQry)->DT6_DOC, (cAliasQry)->DT6_SERIE })
						If ValType(lRet) <> 'L'
							lRet := .T.
						EndIf
						dbSelectArea(cAliasQry)
						If !lRet
							dbSkip()
							Loop
						EndIf
					EndIf
					
					aInfDoc := {}
					AAdd(aInfDoc, (cAliasQry)->DT6_DOCSEG )  //-- Doc. Seguro
					AAdd(aInfDoc, (cAliasQry)->DT6_CDRORI )  //-- Codigo regiao de origem
					AAdd(aInfDoc, (cAliasQry)->DT6_CDRCAL )  //-- Codigo regiao de destino
					AAdd(aInfDoc, (cAliasQry)->DT6_VALMER )  //-- Valor da mercadoria
					AAdd(aInfDoc, (cAliasQry)->DT6_CLIREM )  //-- Remetente
					AAdd(aInfDoc, (cAliasQry)->DT6_LOJREM )  //-- Loja do Remetente
					AAdd(aInfDoc, (cAliasQry)->DT6_CLIDES )  //-- Destinatario
					AAdd(aInfDoc, (cAliasQry)->DT6_LOJDES )  //-- Loja do Destinatario
					AAdd(aInfDoc, (cAliasQry)->DT6_CLIDEV )  //-- Devedor
					AAdd(aInfDoc, (cAliasQry)->DT6_LOJDEV )  //-- Loja do Devedor
					
					aSeguro := TMSSeguro( (cAliasQry)->DT6_FILDOC, (cAliasQry)->DT6_DOC, (cAliasQry)->DT6_SERIE, .T., @aMsgErr, cTabSeg, cTpTSeg, @aValSeg, aInfDoc , cDoc )
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Formato do vetor aSeguro                                             ³
					//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
					//³ aSeguro[1] = Codigo do componente de seguro		                      ³
					//³ aSeguro[2] = Valor do premio de seguro a ser pago                    ³
					//³ aSeguro[3] = Codigo do cliente que efetuara a averbacao              ³
					//³ aSeguro[4] = Loja do cliente que efetuara a averbacao                ³
					//³ aSeguro[5] = Percentual de averbacao de seguro a ser paga p/ Cliente ³
					//³ aSeguro[6] = Percentual de agravacao de risco                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Len( aSeguro ) > 0
						nValorDT6 += (cAliasQry)->DT6_VALMER
						
						For nI := 1 To Len( aSeguro )
							cComSeg := aSeguro[ nI ][ 1 ]
							nValPre := Round(aSeguro[ nI ][ 2 ],2)
							nPosCom := Ascan( aArrayDU7, { | e | e[1] == cComSeg  } )
							If nPosCom == 0
								AAdd(aArrayDU7, { cComSeg, nValPre } )
							Else
								aArrayDU7[ nPosCom ][ 2 ] += nValPre
							EndIf
						Next
						//-- Atualiza o campo documento do seguro no conhecimento
						lGravou := .T.
						cQuery  := " UPDATE " + RetSqlName("DT6") + " SET DT6_DOCSEG = '" + cDoc + "' "
						cQuery  += " WHERE R_E_C_N_O_ = " + AllTrim(Str((cAliasQry)->RECNO)) 
						TCSqlExec( cQuery ) 
					EndIf
					dbSelectArea(cAliasQry)
					(cAliasQry)->(dbSkip())
				EndDo
				
				If Len( aArrayDU7 ) > 0
					If lFilFec .Or. DU8->(!MsSeek(xFilial("DU8")+cDoc+cSerTms+cTipTra))
						RecLock("DU8", .T.)
						DU8->DU8_FILIAL := xFilial("DU8")
						DU8->DU8_DOCSEG := cDoc
						DU8->DU8_SERTMS := cSerTms
						DU8->DU8_TIPTRA := cTipTra
						DU8->DU8_CODFOR := cForn
						DU8->DU8_LOJFOR := cLoja
						DU8->DU8_DATFEC := dDataBase
						DU8->DU8_HORFEC := Left(StrTran(Time(),":",""),4)
						DU8->DU8_VALMER := nValorDT6
						DU8->DU8_STATUS := "1"
						If lFilFec
							DU8->DU8_FILFEC := cFilDoc
						EndIf
						MsUnLock()
					Else
						RecLock("DU8", .F.)
						DU8->DU8_VALMER += nValorDT6
						MsUnLock()
					EndIf              
					If lTMGRVDU8
					   ExecBlock('TMGRVDU8',.F.,.F.,{DU8->DU8_DOCSEG,DU8->DU8_SERTMS,DU8->DU8_TIPTRA,DU8->DU8_CODFOR,DU8->DU8_LOJFOR })
					EndIf

					DU9->(DbSetOrder(2))
					For nX := 1 To Len( aArrayDU7 )
						For nCnt := 1 To 2
							If lFilFec .Or. DU9->(!MsSeek(xFilial("DU9")+cDoc+cSerTms+cTipTra+aArrayDU7[nX,1]+If(nCnt == 1,cCdHisAp,"TP")))
								RecLock("DU9", .T.)
								DU9->DU9_FILIAL := xFilial("DU9")
								DU9->DU9_DOCSEG := cDoc
								DU9->DU9_SERTMS := cSerTms
								DU9->DU9_TIPTRA := cTipTra
								DU9->DU9_ITEM   := If(nCnt == 1,StrZero( 1, Len( DU9->DU9_ITEM ) ), StrZero( 99, Len( DU9->DU9_ITEM ) ) )
								DU9->DU9_CODHIS := If(nCnt == 1,cCdHisAp,"TP")
								DU9->DU9_TIPCAL := Posicione( 'DVI', 1, xFilial( 'DVI' ) + cCdHisAp, 'DVI_TIPCAL' )
								DU9->DU9_COMSEG := aArrayDU7[ nX ][ 1 ]
								DU9->DU9_VALOR  := aArrayDU7[ nX ][ 2 ]
								DU9->DU9_GERAUT := "1"
								MsUnLock()
							Else
								RecLock("DU9", .F.)
								DU9->DU9_VALOR += aArrayDU7[nX,2]
								MsUnLock()
							EndIf
							If lTMAGRVDU9
							   ExecBlock('TMAGRVDU9',.F.,.F.,{DU9->DU9_CODHIS,DU9->DU9_COMSEG,DU9->DU9_VALOR,cFilDoc })
							EndIf
						Next
					Next
				EndIf
				If ( lGravou .And. __lSX8 )
					ConfirmSX8()
				EndIf
				If ((!lGravou) .And. ( __lSx8 ))
					RollBackSx8()
				EndIf
				DbSelectArea(cAliasQry)
			EndDo
		End Transaction
	EndDo
EndIf

// Exibe log dos conhecimentos nao encontrados.
If Len(aMsgErr) > 0
	TmsMsgErr( aMsgErr )
EndIf

(cAliasQry)->(DbCloseArea())
RestArea(aAreaDT6)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA330Conf³ Autor ³Patricia A. Salomao ³ Data ³ 01/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera Contas a Pagar do Fechamento de Seguro                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA330Conf()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA330Conf()

Local cCondPag   := ''
Local lOk        := .F.
Local cParcela   := StrZero(1, Len(SE2->E2_PARCELA))
Local lExibeLanc := Iif(mv_par06 == 2,.F.,.T.)
Local lOnline    := Iif(mv_par07 == 2,.F.,.T.)
Local aRetInt    := {}
Local lDU9Match  := .F.
Local nValor 	 := 0

SA2->( DbSetOrder( 1 ) )
SA2->( MsSeek( xFilial('SA2') + DU8->DU8_CODFOR + DU8->DU8_LOJFOR ) )
cCondPag := SA2->A2_COND

DU9->( DbSetOrder( 2 ) )
DU3->( DbSetOrder( 1 ) )
DU3->( DbGoTop() )

If Empty(cCondPag)
	Help(" ",1,"REGNOIS",,AllTrim(RetTitle("A1_COND"))+": "+ "Fornecedor",3,0)
	Return .F.
EndIf

While DU3->( !Eof() )

	//
	// posiciona no DU9 para obter o valor do prêmio do seguro em seguida verifica se haverá integração
	// financeira para outras Marcas ou se usa integração nativa com o modulo financeiro.
 	// 
	lDU9Match := DU9->( MsSeek( xFilial( 'DU9' ) + DU8->DU8_DOCSEG + DU8->DU8_SERTMS + DU8->DU8_TIPTRA + DU3->DU3_COMSEG + 'TP' ) )
	If cTMSERP == "0"
	    If lDU9Match
		    lOk := A050ManSE2(	,DU9->DU9_DOCSEG,DU3->DU3_PRETPG,DU3->DU3_TIPTPG,cParcela,DU9->DU9_VALOR,0,;
		     					DU8->DU8_CODFOR,DU8->DU8_LOJFOR,DU3->DU3_NATTPG,1,cCondPag,"SIGATMS",Date(),;
			    				,,,,,lExibeLanc,lOnline )
	    EndIf

	Else
        If lDU9Match 
			nValor += DU9->DU9_VALOR
        EndIf
	EndIf	
	
	DU3->( DbSkip() )
EndDo

If nValor > 0
	//|
	//| Chama Integração Financeira via EAI - MENSAGEM UNICA para a Marca cadastrada no Adapter
	//| Dados do Adapter
	//| Nome da Transação : TRANSPORTDOCUMENTS
	//| Programa          : TMSA330 
	//| Descrição         : Cadastro de Titulos no Contas à Pagar - Premio de  Seguro
	//|
	 If FindFunction("GETROTINTEG") .And. FindFunction("FwHasEAI")
        If FwHasEAI("TMSA330",.T.,,.T.)

            oDTClass:cVIAGEM      := ""
            oDTClass:cFILORI      := cFilAnt
            oDTClass:cTITULO      := DU8->DU8_DOCSEG
            oDTClass:nVALORDOC    := nValor
            oDTClass:cCODCLIENTE  := DU8->DU8_CODFOR
            oDTClass:cLOJCLIENTE  := DU8->DU8_LOJFOR
            oDTClass:cFILDEBITO   := cFilAnt
            oDTClass:dEMISSAO     := dDataBase
            //oDTClass:dVENCIMENTO    :=
            oDTClass:dTRANSACAO   := dDataBase
            oDTClass:cHISTORICO   := "Titulo Ref. Premiacao de seguro."
            oDTClass:cEventType   := "upsert"
            oDTClass:cTipoMsg     := "4"
            oDTClass:cSubTipoMsg  := "401"

            //FWIntegDef( cSourceCode, cTypeMessage, cType, cXml, cFunName, lOnlyReturn, cVersion
            SetRotInteg("TMSA330")
            aRetInt := FwIntegDef("TMSA330",,,,"TMSA330") //[1] logico(integrou ou não);[2] XML Retorno Erro; [3]-Nome Transacao
            lOK     := Iif( ValType(aRetInt) != "U",aRetInt[1],.F.)
        Else
            lOk := .F.
            Aviso(STR0009,STR0022,{STR0004},2) //| Nao Foi localizada a configuração da Mensagem Unica para a Rotina TMSA330, verifique no cadastro de Adapter EAI no configurador antes de continuar.
         EndIf
    EndIf

EndIf

If lOk
	RecLock("DU8", .F.)
	DU8->DU8_STATUS := StrZero( 2, Len( DU8->DU8_STATUS ) ) //-- Confirmado
	MsUnLock()
	
	If cTMSERP == "1"
          Aviso(STR0009,STR0023,{STR0004})
	EndIf
Else
	//-- Apresenta o Log na Tela
	If cTMSERP == "0" // Integração EAI NAO Habilitado para outra Marca?
	   MostraErro()
	Else
       //Aviso(STR0009,STR0021,{STR0004})// "Atenção";"Não foi possível efetuar a Integrar Financeira.";"Fechar"
       Help( " " , 1 , "TMSA330-EAI01",,STR0021 + " " + chr(13)+chr(10) + IIf(Len(aRetInt)>1,aRetInt[2],""),3,0) 
	EndiF
EndIf	

Return( lOk )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA330Vld ³ Autor ³Patricia A. Salomao ³ Data ³ 01/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao dos Campos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA330Vld()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Conteudo dos Campos                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA330Vld()
Local ni
Local lRet       := .T.
Local cCampo     := ReadVar()
Local nTotPremio := 0
Local nValor     := 0
Local cTipCal    := GDFieldGet( 'DU9_TIPCAL', n )

If AllTrim( cCampo ) == 'M->DU9_CODHIS'
	//-- Limpa o valor do historico anterior
	GDFieldPut( 'DU9_PERCEN', CriaVar( 'DU9_PERCEN' ), n )
	GDFieldPut( 'DU9_VALOR' , CriaVar( 'DU9_VALOR'  ), n )
	//-- Totaliza premio
	TMSA330Tot()

ElseIf AllTrim( cCampo ) == 'M->DU9_PERCEN'

	If Empty( M->DU9_PERCEN )
		GDFieldPut( 'DU9_VALOR', CriaVar( 'DU9_VALOR' ), n )
	Else

		//-- Valor Total do Premio
		For nI := 1 To Len( aCols )
			If !GDdeleted( nI ) .And. nI <> n
				cTipCal := GDFieldGet( 'DU9_TIPCAL', nI )
				nValor  := GDFieldGet( 'DU9_VALOR' , nI )
				If cTipCal == StrZero( 1, Len( DVI->DVI_TIPCAL ) ) //-- Soma
					nTotPremio += nValor
				ElseIf cTipCal == StrZero( 2, Len( DVI->DVI_TIPCAL ) ) //-- Subtrai
					nTotPremio -= nValor
				EndIf
			EndIf
		Next

		nValor := nTotPremio * ( M->DU9_PERCEN / 100 )
		GDFieldPut( 'DU9_VALOR' , nValor, n )
		GDFieldPut( 'DU9_PERCEN', M->DU9_PERCEN, n )
	EndIf		

	//-- Recalculo do percentual do premio
	TMSA330Rec()

	//-- Totaliza premio
	TMSA330Tot()

ElseIf AllTrim( cCampo ) == 'M->DU9_VALOR'
	//-- Forca valor para utilizar funcao de totalizacao
	GDFieldPut( 'DU9_VALOR', M->DU9_VALOR, n )          

	//-- Recalculo do percentual do premio
	TMSA330Rec()

	//-- Totaliza premio
	TMSA330Tot()
EndIf

Return( lRet )	
		
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA330Whe ³ Autor ³Patricia A. Salomao ³ Data ³ 01/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao antes de editar o Campo (X3_WHEN)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA330Whe()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA330Whe( cCampo )

Local   lRet   := .T.

Default cCampo := ReadVar() 

lRet := If( GDFieldGet( 'DU9_GERAUT', n ) == '1', .F., .T. )

If lRet
	lRet := !GDDeleted( n )
EndIf	

If lRet .And. AllTrim( cCampo ) $ 'M->DU9_VALOR'
	//-- Somente informa o valor se o percentual for zero
	lRet := Empty( GdFieldGet( 'DU9_PERCEN', n ) )
EndIf	

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA330Del ³ Autor ³Patricia A. Salomao ³ Data ³ 01/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se a Linha da GetDados podera ou nao ser Deletada    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA330Del()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA330Del()

Local lRet       := .T.
Local nTotPremio := 0

//-- Consistencia para nao chamar a funcao duas vezes
If __lDelOk
	__lDelOk := .F.
	Return( lRet )
Else	
	__lDelOk := .T.
EndIf	

lRet := If( GDFieldGet( 'DU9_GERAUT', n ) == '1', .F. , .T. ) 

If lRet
	If GDdeleted( n )
		//-- Recalculo do percentual do premio, na habilitacao da linha deletada
		nTotPremio := TMSA330Rec(2)
	Else
		//-- Recalculo do percentual do premio, na delecao da linha
		nTotPremio := TMSA330Rec(1)
	EndIf		
	aFolder[ oFolder:nOption ][ 10 ] := nTotPremio
	oTotPremio:Refresh()
EndIf		

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA330Tot ³ Autor ³Richard Anderson    ³ Data ³ 02/06/2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Totalizacao do premio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA330Tot()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA330Tot()

Local nI         := 0
Local nTotPremio := 0
Local cTipCal    := ''
Local nValor     := 0

For nI := 1 To Len( aCols )
	If !GDdeleted( nI )
		cTipCal := GDFieldGet( 'DU9_TIPCAL', nI )
		nValor  := GDFieldGet( 'DU9_VALOR' , nI )
		If cTipCal == StrZero( 1, Len( DVI->DVI_TIPCAL ) ) //-- Soma
			nTotPremio += nValor
		ElseIf cTipCal == StrZero( 2, Len( DVI->DVI_TIPCAL ) ) //-- Subtrai
			nTotPremio -= nValor
		EndIf
	EndIf
Next
			
aFolder[ oFolder:nOption ][ 10 ] := nTotPremio
oTotPremio:Refresh()

Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA330Leg³ Autor ³ Patricia A. Salomao   ³ Data ³17.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a legenda do Browse                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA330Leg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA330Leg()

BrwLegenda( STR0001,STR0013	,; //"Fechamento de Seguro. //"Status"
{	{ "BR_VERDE"    , STR0014 },; //"Em Aberto"
	{ "BR_VERMELHO" , STR0015 }})   //"Confirmado"

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA330Rec ³ Autor ³ Eduardo de Souza   ³ Data ³  18/08/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Recalculo do percentual do premio                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA330Rec(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - (1=Deletando Linha / 2=Habilitando Linha Deletada) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA330                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA330Rec(nDel)

Local nI         := 0
Local aPerc      := {}
Local cTipCal    := ""
Local nValor     := 0
Local nTotPremio := 0
Local nPerc      := 0
Local lTMSFSL    := GetMV("MV_TMSFSL",.F.,.F.) //Calcula Seguro Linha a Linha?

Default nDel := 0 

If (lTMSFSL == .F.)
	
	For nI := 1 To Len(aCols)
		//-- Verifica se esta deletado ou habilitando a linha deletada
		If (!GDdeleted( nI ) .And. !(nDel == 1 .And. nI == N)) .Or. (nDel == 2 .And. nI == N)
			If (nPerc:= GDFieldGet( 'DU9_PERCEN', nI )) > 0
				cTipCal := GDFieldGet( 'DU9_TIPCAL', nI )
				AAdd( aPerc, { nPerc, nI, cTipCal } )
			Else
				cTipCal := GDFieldGet( 'DU9_TIPCAL', nI )
				nValor  := GDFieldGet( 'DU9_VALOR' , nI )
				If cTipCal == StrZero( 1, Len( DVI->DVI_TIPCAL ) ) //-- Soma
					nTotPremio += nValor
				ElseIf cTipCal == StrZero( 2, Len( DVI->DVI_TIPCAL ) ) //-- Subtrai
					nTotPremio -= nValor
				EndIf
			EndIf
		EndIf
	Next nI
	
	For nI := 1 To Len(aPerc)
		
		//-- Calcula se nao estiver sendo deletada a linha
		If !(nDel == 1 .And. aPerc[nI,2] == N)
			
			nValor  := nTotPremio * ( aPerc[nI,1] / 100 )
			cTipCal := aPerc[nI,3]
			
			If cTipCal == StrZero( 1, Len( DVI->DVI_TIPCAL ) ) //-- Soma
				nTotPremio += nValor
			ElseIf cTipCal == StrZero( 2, Len( DVI->DVI_TIPCAL ) ) //-- Subtrai
				nTotPremio -= nValor
			EndIf
			
			GDFieldPut( "DU9_VALOR", nValor, aPerc[nI,2] )
			
		EndIf
		
	Next nI
	
Else //MV_TMSFSL == .T.
	
	For nI := 1 To Len(aCols)
		//-- Verifica se esta deletado ou habilitando a linha deletada
		If (!GDdeleted( nI ) .And. !(nDel == 1 .And. nI == N)) .Or. (nDel == 2 .And. nI == N)
			If (nPerc:= GDFieldGet( 'DU9_PERCEN', nI )) > 0
				//Calculo por Porcentagem
				cTipCal := GDFieldGet( 'DU9_TIPCAL', nI )
				nValor  := nTotPremio * ( nPerc / 100 )
				If cTipCal == StrZero( 1, Len( DVI->DVI_TIPCAL ) ) //-- Soma
					nTotPremio += nValor
				ElseIf cTipCal == StrZero( 2, Len( DVI->DVI_TIPCAL ) ) //-- Subtrai
					nTotPremio -= nValor
				EndIf
				GDFieldPut( "DU9_VALOR", nValor, nI )
			Else
				//Calculo por Valor
				cTipCal := GDFieldGet( 'DU9_TIPCAL', nI )
				nValor  := GDFieldGet( 'DU9_VALOR' , nI )
				If cTipCal == StrZero( 1, Len( DVI->DVI_TIPCAL ) ) //-- Soma
					nTotPremio += nValor
				ElseIf cTipCal == StrZero( 2, Len( DVI->DVI_TIPCAL ) ) //-- Subtrai
					nTotPremio -= nValor
				EndIf
			EndIf
		EndIf
	Next nI
	
Endif
Return( nTotPremio )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMS330Avr  ³ Autor ³Wellington A Santos ³ Data ³  14/09/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta dos dados da averbacao de seguro (DU7)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA330Avr()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA330                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMS330Avr(nOpcx)
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local nItem     := 0
Local nCount    := 0
Local cTexto    := ''
Local nPremio   := 0
Local cTCampo   := ''
Local cPremio   := ''
Local nQtdDoc   := 0
Local aButtons  := {}
Local nPosFil   := 0
Local nPosDoc   := 0
Local nPosSer   := 0
Local aNoFields := {} //-- Array com nome dos campos que serão [EXCLUÍDOS] na montagem do aHeader
Local aYesFields:= {} //-- Array com nome dos campos que serão [INCLUÍDOS] na montagem do aHeader
Local aYesUsado := {} //-- Nome dos campos que deverão ser apresentados na (Ms)Getdados.
Local lFillOk   := .T. 
Local aDU7Stru  := FwFormStru(2,"SA1")
Local i         := 1
Private aHeader := {}
Private aCols   := {}
Private oDlgCmp
Private oGetCmp
//-- Preenche aHeader

	SaveInter()

	//-- Define os campos que não devem ser usados...
	For i:= 1 To Len(aDU7Stru:aFields)
		If GetSx3Cache(aDU7Stru:aFields[i][1],"X3_NIVEL") < cNivel .And. !X3Uso(GetSx3Cache(aDU7Stru:aFields[i][1],"X3_USADO"))
			Aadd(aNoFields,aDU7Stru:aFields[i][1])
		EndIf
	Next i

	//-- Query pesquisa dos dados...
	cQuery := " SELECT * FROM " + RetSqlName("DU7") + " DU7 "
	cQuery += " WHERE DU7_FILIAL = '" + xFilial("DU7") + "' "
	cQuery += " AND DU7_DOCSEG = '" + DU8->DU8_DOCSEG + "' "
	cQuery += " AND DU7.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY DU7_FILDOC,DU7_DOC,DU7_SERIE "
	cQuery := ChangeQuery(cQuery)

	//-- Monta aCols e aHeader
	//-- FillGetDados ( < nOpc>, < cAlias>, [ nOrder], [ cSeekKey], [ bSeekWhile], [ uSeekFor], [ aNoFields], [ aYesFields], [ lOnlyYes], [ cQuery], [ bMontCols], [ lEmpty], [ aHeaderAux], [ aColsAux], [ bAfterCols], [ bBeforeCols], [ bAfterHeader], [ cAliasQry], [ bCriaVar], [ lUserFields], [ aYesUsado] )

	//-- Order: 
	//-- 1: DU7_FILIAL+DU7_FILDOC+DU7_DOC+DU7_SERIE
	//-- 2: DU7_FILIAL+DU7_FILDOC+DU7_DOC+DU7_SDOC                                                                                                                          
	lFillOk := FillGetDados(nOpcx,"DU7",/*nOrder*/,/*cSeekKey*/,/*bSeekWhile*/,,aNoFields,/*aYesFields*/,,cQuery,,.F.,,,,,,"qtxDU7"/*cAliasQry*/)//,,,aYesUsado)

	//-- Guarda a posição dos campos de pesquisa utilizados pela rotina TMSA330psq
	nPosFil := DU7->(ColumnPos("DU7_FILDOC"))
	nPosDoc := DU7->(ColumnPos("DU7_DOC"   ))
	nPosSer := DU7->(ColumnPos("DU7_SERIE" ))

	//-- Soma o valor do Premio do Seguro e total de documentos
	cQuery := " SELECT Sum(DU7_PREMIO) DU7_PREMIO, Count(*) QTD_DOC FROM " + RetSqlName("DU7") + " DU7 "
	cQuery += " WHERE DU7_FILIAL = '" + xFilial("DU7") + "' "
	cQuery += " AND DU7_DOCSEG = '" + DU8->DU8_DOCSEG + "' "
	cQuery += " AND DU7.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	nPremio := (cAliasQry)->DU7_PREMIO
	nQtdDoc := (cAliasQry)->QTD_DOC

	(cAliasQry)->( DbCloseArea() )
	DbSelectArea("DU7")

	//-- Monta uma linha em branco
	If	Empty(aCols)
		AAdd(aCols,Array(Len(aHeader)+1))
		For nCount := 1 To Len(aHeader)
			aCols[1,nCount] := CriaVar(aHeader[nCount,2])
		Next
		aCols[1,Len(aHeader)+1] := .F.
	EndIf

	cPremio   := Space(5) + AllTrim( Transform( nPremio, PesqPict('DU7','DU7_PREMIO') ) )
	cQtdDoc   := Space(5) + AllTrim( Transform( nQtdDoc, PesqPictQt('DTC_QTDVOL') ) )
	cCadastro := STR0019
	cTexto    := STR0016 + ":" + cPremio + " / " + STR0020 + ":" + cQtdDoc
	cTexto    := AllTrim(cTexto)

	//--Adiciona botão de pesquisa por filial + documento + série
	AAdd(aButtons,{'PESQUISA' , {|| TMSA330psq(nPosFil,nPosDoc,nPosSer)},STR0002,STR0002})	//'Pesquisa'

	DEFINE MSDIALOG oDlgCmp TITLE cCadastro FROM 094,104 TO 310,590 PIXEL

		@ 018, 003 SAY cTexto SIZE 127 ,9 OF oDlgCmp PIXEL

		oGetCmp := MSGetDados():New( 30, 02, 105, 243, Iif(nOpcx>3,2,nOpcx),'','',,.T.)
		oGetCmp:Refresh(.T.)

	ACTIVATE MSDIALOG oDlgCmp ON INIT EnchoiceBar(oDlgCmp,{||Iif( oGetCmp:TudoOk(), (nOpca := 1,oDlgCmp:End()), nOpca :=0 )},{||nOpca:=0,oDlgCmp:End()},,aButtons)

	RestInter()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA330Psq³ Autor ³Wellington A Santos    ³ Data ³ 15/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa documentos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA330Psq(aCols)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA330                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA330Psq(nPosFil,nPosDoc,nPosSer)

Local aCbx		:= {}
Local cCampo	:= ''
Local cOrd
Local cData		:= ''
Local lSeek		:= .F.
Local nOrdem	:= 1
Local nSeek		:= 0
Local oCbx
Local oDlg
Local oPsqGet

	//-- (01) Fil.Docto. + No.Docto. + Serie
	cCampo := AllTrim(GetSx3Cache("DU7_FILDOC","X3_TITULO")) + " + " + AllTrim(GetSx3Cache("DU7_DOC","X3_TITULO")) + " + " + AllTrim(GetSx3Cache("DU7_SERIE","X3_TITULO"))
	AAdd( aCbx, cCampo )

	cCampo := Space( 40 )

	DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0002 //"Pesquisa"

		@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg ON CHANGE nOrdem := oCbx:nAt

		@ 22,05 MSGET oPsqGet VAR cCampo SIZE 206,10 PIXEL

		DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
		DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED

	If	lSeek
		//-- (01) Fil.Docto. + No.Docto. + Serie
		cCampo := AllTrim( cCampo )
		nSeek := Ascan( aCols,{ | x | PadR( x[nPosFil] + x[nPosDoc] + x[nPosSer], Len( cCampo ) ) == cCampo } )
	EndIf

	If	nSeek > 0
		oGetCmp:oBrowse:nAT := nSeek
		n := nSeek
		oGetCmp:Refresh()                                              								 
	EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()
     
Private aRotina	:=  {	{STR0002,"AxPesqui"  ,0,1,0,.F.},; //-- Pesquisar
						{STR0003,"TMSA330Mnt",0,2,0,Nil},; //-- Visualizar
						{STR0004,"TMSA330Mnt",0,3,0,Nil},; //-- Fechar
						{STR0005,"TMSA330Mnt",0,4,0,Nil},; //-- Alterar
						{STR0006,"TMSA330Mnt",0,5,0,Nil},; //-- Estornar
						{STR0007,"TMSA330Mnt",0,6,0,Nil},; //-- Confirmar
						{STR0012,"TMSA330Leg",0,7,0,.F.} }	//-- Legenda


If ExistBlock("TMA330MNU")
	ExecBlock("TMA330MNU",.F.,.F.)
EndIf

Return( aRotina )


/*
================================================================================
/{Protheus.doc} TMSA330EAI
//TODO Rotina Utilizada para realizar a integração de geração de titulos a Pagar
@author tiago.dsantos
@since 22/09/2016
@version 1.000
@type function
/================================================================================
*/
Static Function IntegDef(cXml,nType,cTypeMessage,cVersion)
Local  aResult := {}
       aResult := TMSI330ABP(cXml,nType,cTypeMessage,cVersion)
   
Return aResult

