#Include "Protheus.ch"
#Include "ATFA126.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ATFA126  ³ Autor ³ Marcos R. Pires       ³ Data ³ 19/07/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ATFA126                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATF                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFA126()

Local aCores := {}
Local lA126Brwt 	:= ExistBlock("AF126BRWT")
Local cFiltro := Nil

Private cCadastro := STR0007	//"Análise das solicitações de baixa e transferência de Ativo"
Private aRotina   := MenuDef()

If SuperGetMv( "MV_ATFSOLD", .F., "2" ) == "2"
	Help(" ",1,"AFA126SOLD",,STR0008,1,0) //"Controle de solicitações desativado, verifique parâmetro 'MV_ATFSOLD'." 
	Return Nil
EndIf

///Ponto de Entrada - MBROWSE //ACRESCENTAR FILTRO NA BROWSE
If lA126Brwt
	cFiltro := ExecBlock( "AF126BRWT", .F., .F. )
	cFiltro := If(ValType(cFiltro) == "C", cFiltro, Nil )
Endif

lCtbInTran := CtbInTran( 1, .F. )

aAdd( aCores, { "NM_SITSOL == '2'", "BR_VERDE"    } ) //Aprovada
aAdd( aCores, { "NM_SITSOL == '3'", "BR_VERMELHO" } ) //Rejeitada
aAdd( aCores, { "NM_SITSOl == '1'", "BR_AMARELO"  } ) //Pendente

dbSelectArea("SE1")
SE1->(dbSetOrder(1))

mBrowse( 6, 1, 22, 75, "SNM", ,/*cCpo*/,/*nPar08*/,/*cFun*/,/*nClickDef*/,aCores,/*cTopFun*/,/*cBotFun*/,/*nPar14*/,/*bInitBloc*/,/*lNoMnuFilter*/,/*lSeeAll*/,/*lChgAll*/,cFiltro)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA126Apr ºAutor  ³Microsiga          º Data ³  08/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFA126Apr( cAlias, nReg, nOpc )

Local aArea    := GetArea()
Local aButtons := {}

//Propriedades da Enchoice
Local aFieldsEnc 		:= {}
Local aEncAlterFields	:= {}

//Propriedades da GetDados
Local nX
Local aHeaderEx			:= {}
Local aColsEx			:= {}
Local aFieldsGet		:= {}
Local aGetAlterFields	:= {}

//Dimensao tela
Local aSize		:= MsAdvSize()
Local aObjects 	:= {}
Local aPosObj  	:= {}

Local aInfo		:= {}

//Variaveis diversas
Local cCodSol	:= SNM->NM_CODIGO
Local nRecnoSNM := SNM->(Recno())

Static oEnchoice1
Static oGetValores
Static oDlg

Private INCLUI := .F.
Private ALTERA := .T.
Private EXCLUI := .F.

If SNM->NM_SITSOL != "1"
	Help(" ",1,"AFA126REJ",,STR0026,1,0) //"Solicitação já está aprovada/rejeitada. A operação não poderá ser efetuada"
	Return Nil
EndIf

Aadd( aObjects, { 100, 100, .T., .T. } )
Aadd( aObjects, { 315,  70, .T., .T. } )

aInfo	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj	:= MsObjSize( aInfo, aObjects, .F. )

If SNM->NM_TIPOSOL == "1" //Baixa
	//Enchoice
	aFieldsEnc		:= {"NM_CODIGO" ,"NM_DATSOL" ,"NM_HORSOL","NM_USRSOL" ,"NM_NMUSSOL","NM_HISTSOL","NM_DTAPVRE",;
	"NM_HRAPVRE","NM_USRAPV","NM_NMUSAPV","NM_HISTREJ","NM_MOTBX"  ,"NM_VLVENDA","NM_GERANF" ,;
	"NM_NOTA"  ,SerieNfId('SNM',3,'NM_SERIE') ,"NM_TESNFS" ,"NM_CONDPG" ,"NM_CLIENTE","NM_LOJA"}
	//Getdados
	aFieldsGet		:= {"NM_CBASE","NM_ITEM","NM_TIPO","NM_DESCBEM"}
Elseif SNM->NM_TIPOSOL == "2" //Transferencia
	//Enchoice
	aFieldsEnc		:= {"NM_CODIGO" ,"NM_DATSOL" ,"NM_HORSOL" ,"NM_CDHSOL" ,"NM_HISTSOL","NM_CDHREJ" ,"NM_HISTREJ",;
	"NM_USRSOL" ,"NM_NMUSSOL","NM_USRAPV" ,"NM_NMUSAPV","NM_DTAPVRE","NM_HRAPVRE","NM_FILDEST",;
	"NM_GRUPO"  ,"NM_MOTBX"  ,"NM_CCUSTO" ,"NM_LOCAL"  ,"NM_CCONTAB","NM_CCORREC","NM_CDEPREC",;
	"NM_CDDEPR" ,"NM_CDESP"  ,"NM_CUSTBEM","NM_CCCORR" ,"NM_CCDESP" ,"NM_CCCDEP" ,"NM_CCCDES" ,;
	"NM_ITBEM"  ,"NM_ITCORR" ,"NM_ITDESP" ,"NM_ITCDEP" ,"NM_ITCDES" ,"NM_CLVLBEM","NM_CLVLCOR",;
	"NM_CLVLDEP","NM_CLVLCDE","NM_CLVLDES","NM_GERANF" ,"NM_NOTA"   ,SerieNfId('SNM',3,'NM_SERIE')  ,"NM_TESNFS" ,;
	"NM_CLASNFE","NM_TESNFE" ,"NM_CLIENTE","NM_LOJA","NM_ARMAZEM"}
	//Getdados
	aFieldsGet		:= {"NM_CBASE","NM_ITEM","NM_TIPO","NM_DESCBEM"}
EndIf

If nOpc == 4 // Rejeição
	aEncAlterFields := {"NM_HISTREJ"}
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processos da GetDados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Define field properties
DbSelectArea( "SX3" )
SX3->(DbSetOrder(2))
For nX := 1 to Len(aFieldsGet)
	If SX3->(DbSeek(aFieldsGet[nX]))
		aAdd( aHeaderEx, { AllTrim( X3Titulo() ), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID,;
		SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT, SX3->X3_CBOX, SX3->X3_RELACAO } )
	Endif
Next nX

// Define field values
dbSelectArea("SNM")
SNM->( dbSetOrder(1) )
SNM->( dbSeek( xFilial("SNM") + cCodSol ) )
While SNM->(!EOF()) .And. xFilial("SNM") + cCodSol == SNM->NM_FILIAL + SNM->NM_CODIGO
	aAdd( aColsEx, { SNM->NM_CBASE, SNM->NM_ITEM, SNM->NM_TIPO,;
	POSICIONE( "SN1", 1, xFilial("SN1") + SNM->NM_CBASE + SNM->NM_ITEM, "N1_DESCRIC"), .F. } )
	SNM->(dbSkip())
EndDo

SNM->(dbGoTo(nReg))

DEFINE MSDIALOG oDlg TITLE STR0007 FROM 000, 000  TO aSize[6], aSize[5] OF oMainWnd PIXEL	//"Análise das solicitações de baixa e transferência de Ativo"

RegToMemory( "SNM", .F. )

oEnchoice1      := MsMGet():New( "SNM", nReg, nOpc, , , , aFieldsEnc, aPosObj[1], aEncAlterFields, , , , , oDlg, , , , , , )
oGetValores     := MsNewGetDados():New( aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], 0, "AllwaysTrue", "AllwaysTrue", /*"+Field1+Field2"*/, aGetAlterFields, ,999 ,"AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx )
EnchoiceBar( oDlg, { || If( ATFA126Grava( nOpc ), oDlg:End(), .F. ) }, { || oDlg:End()}, , aButtons )

ACTIVATE MSDIALOG oDlg

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ATFA126Grava ºAutor  ³Microsiga         º Data ³  08/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFA126Grava( nOpc, lWFProc )

Local lRet := .T.

Default lWFProc := .F.

If !lWFProc
	MsgRun( STR0013, , { || lRet := Af126Grv( nOpc, lWFProc ) } )	//"Aguarde! Efetivando operação..."
Else
	lRet := Af126Grv( nOpc, lWFProc )
Endif

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF126Grv  ºAutor  ³Microsiga           º Data ³  07/26/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a gravação da nota fiscal de saida e entrada        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF126Grv( nOpc, lWFProc )

Local aArea      := GetArea()
Local lRet		   := .T.
Local aBaixa	   := {}
Local cNota	   := SNM->NM_NOTA
Local cSerie		:= SerieNfId('SNM',2,'NM_SERIE')
Local lGeraNota  := SNM->NM_GERANF == "1"
Local cCodigo	   := SNM->NM_CODIGO
Local nRecnoSNM  := SNM->(Recno())
Local cSitSol    := SNM->NM_SITSOL
Local cTipoSol   := SNM->NM_TIPOSOL
Local dDtApvRej  := dDataBase
Local dHrApvRej  := StrTran( Left( Time(), 5), ':', '' )
Local cCodApvRej := ""
Local cUsrSol	   := ""
Local cMotGeraNF := SuperGetMV( "MV_ATFMBNF", .F., "01/10" )		//Motivos de baixa que permitem gerar NF
Local aParam030  := {}
Local aNotaSai	:= {}
Local aNotaEnt	:= {} 
Local aBxAux     := {}
Local lTransFil  := .T.
Local xCab := {}
Local xAtivo := {}
Local nWFID := Val(SNM->NM_WFID)
Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .F.

Default lWFProc	:= .F.

// Carrega os arrays com os parametros mostra tela de contabilização desligado
AADD(aParam030, { "MV_PAR01", 2		   			, Nil } )

If ExistBlock("AF126TOK")
	lRet := ExecBlock("AF126TOK", .F., .F.,{nOpc,cTipoSol,cCodigo})
EndIf 

If lRet .AND. cSitSol == "1"	//Verifica se a solicitação está pendente
	
	If nOpc == 3 //Aprovação
		
		If cTipoSol == "1" 	//Tratamento se for baixa de Ativo
			
			BEGIN TRANSACTION
			dbSelectArea("SNM")
			SNM->( dbSetOrder(1) )
			SNM->( dbSeek( xFilial("SNM") + cCodigo ) )
			
			If lRet .AND. lGeraNota
				//Gera Pedido/Libera/GeraNF
				lRet := ATF126Nota( cSerie, @aNotaSai, @aNotaEnt , cCodigo )
			EndIf
			
			If lRet
				While SNM->(!EOF()) .And. xFilial("SNM") + cCodigo == SNM->NM_FILIAL + SNM->NM_CODIGO
					If Len(aNotaSai) > 0
						nPosNota := aScan(aNotaSai,{|x| x[1] + x[2] + x[3] == SNM->NM_CODIGO + SNM->NM_CBASE +SNM->NM_ITEM  })
						If nPosNota > 0
							cNota  := aNotaSai[nPosNota][4]
							cSerie := aNotaSai[nPosNota][5]
						EndIf
					Else
						cNota  := ""
						cSerie := ""
					EndIf
										
					xCab :={ 	{"FN6_FILIAL"	,xFilial("FN6")			,NIL},;
								{"FN6_CBASE"	,SNM->NM_CBASE		,NIL},;
								{"FN6_CITEM"	,SNM->NM_ITEM		,NIL},;
								{"FN6_MOTIVO"	,SNM->NM_MOTBX		,NIL},;
								{"FN6_QTDATU"	,Posicione("SN1",1,xFilial("SN1")+SNM->NM_CBASE+SNM->NM_ITEM,"N1_QUANTD")	,NIL},;
								{"FN6_BAIXA"	,SNM->NM_PERCBX					,NIL},;
								{"FN6_QTDBX"	,SNM->NM_QTDBX 		,NIL},;
								{"FN6_DTBAIX"	,dDatabase			,NIL},;
								{"FN6_NUMNF"	, cNota				,NIL},;
								{"FN6_SERIE"	, cSerie				,NIL},;
								{"FN6_PERCBX"	, SNM->NM_PERCBX		,NIL},;
								{"FN6_VALNF"	, SNM->NM_VLVENDA	,NIL},;
								{"FN6_DEPREC"	, GETMV('MV_ATFDPBX')	,NIL}	 }
							
					xAtivo:={ 	{"N3_FILIAL"	, xFilial("SN3")		,NIL},;
								{"N3_CBASE"	, SNM->NM_CBASE	,NIL},;
								{"N3_ITEM"		, SNM->NM_ITEM	,NIL},;
					   	   		{"N3_TIPO"		, SNM->NM_TIPO	,NIL},;
								{"N3_BAIXA"  	 , "0"				,NIL} }
								
					aBxAux := {}
					aBxAux := Array(2)
					aBxAux[1] := AClone(xCab)
					aBxAux[2] := AClone(xAtivo)
   					
   					If ExistBlock("A126EDGRV")
						aBxAux := ExecBlock("A126EDGRV", .F., .F.,{aBxAux})
	   					
	   					If ValType(aBxAux) == "A"
							xCab 	:= aBxAux[1] 
							xAtivo := aBxAux[2]					
						EndIf
						
					EndIf 
									
					//³Executa a Baixa do Bem ³

					MsExecAuto({|a,b,c|ATFA036(a,b,c)},xCab,xAtivo,3)
					
					If lMsErroAuto
						If !lWFProc
							MostraErro()
						Endif
						lRet := .F.
						Exit
					EndIf
					
					aBaixa 		:= {}
					SNM->(dbSkip())
				EndDo
				
				If lRet .And. !lMsErroAuto
					dbSelectArea( "SNM" )
					SNM->( dbSetOrder(1) )
					SNM->( dbSeek( xFilial( "SNM" ) + cCodigo ) )
					
					While SNM->(!EOF()) .AND. xFilial( "SNM" ) + cCodigo == SNM->NM_FILIAL + SNM->NM_CODIGO
						RecLock( "SNM", .F. )
						
						SNM->NM_USRAPV	:= __cUserID
						SNM->NM_DTAPVRE	:= dDtApvRej
						SNM->NM_HRAPVRE	:= dHrApvRej
						SNM->NM_NOTA    := cNota
						SerieNfId('SNM',1,'NM_SERIE',dDataBase,"",cSerie)
						SNM->NM_SITSOL	:= "2"
						SNM->NM_DTBAIXA	:= dDtApvRej						
						
						SNM->( MsUnlock() )
						SNM->( dbSkip() )
					EndDo
				EndIf
			EndIf
			
			If !lRet
				DisarmTransaction()
			EndIf
			
			END TRANSACTION
			//Fim da Baixa
		ElseIf cTipoSol == "2" //Tratamento se for transferência de Ativo
			
			lTransFil := xFilial("SN1",SNM->NM_FILDEST) !=  xFilial("SN1") 
			BEGIN TRANSACTION
			
			If lGeraNota .And. lTransFil 
				//Gera Pedido/Libera/GeraNF
				lRet := ATF126Nota( cSerie, @aNotaSai, @aNotaEnt , cCodigo )
			EndIf
			
			//Grava movimentação
			If lRet
				
				dbSelectArea("SNM")
				SNM->( dbSetOrder(1) )
				SNM->( dbSeek( xFilial("SNM") + cCodigo ) )
				
				//Grava movimentação de todos os itens da transferência
				While lRet .And. SNM->(!Eof()) .And. SNM->NM_FILIAL + SNM->NM_CODIGO == xFilial("SNM") + cCodigo
					If Len(aNotaEnt) > 0
						nPosNota := aScan(aNotaEnt,{|x| x[1] + x[2] + x[3] == SNM->NM_CODIGO + SNM->NM_CBASE +SNM->NM_ITEM  })
						If nPosNota > 0
							cNota  := aNotaEnt[nPosNota][4]
							cSerie := aNotaEnt[nPosNota][5]
						Else
							cNota  := ""
							cSerie := ""
						EndIf
					Else
						cNota  := ""
						cSerie := ""
					EndIf
					
					lRet := AF126Trans(SNM->NM_CODIGO,SNM->NM_CBASE,SNM->NM_ITEM,cNota,cSerie,SNM->NM_TIPO,lWFProc)
										
					//Trata erro na gravação da movimentação
					If !lRet
						If !lWFProc
							MostraErro()
						Endif
						DisarmTransaction()
					Else
						//Se não houve erro atualiza histórico de solicitação
						If !lWFProc
							RecLock( "SNM", .F. )
							SNM->NM_SITSOL 	:= "2" //Status Aprovada
							SNM->NM_USRAPV 	:= __cUserID
							SNM->NM_DTAPVRE := dDataBase
							SNM->NM_HRAPVRE := StrTran( Left( Time(), 5 ), ":", "" )
							If Empty(SNM->NM_NOTA)
								SNM->NM_NOTA := cNota
							Endif
							If Empty(SNM->NM_SERIE)
								SerieNfId('SNM',1,'NM_SERIE',dDataBase,,cSerie)
							Endif
							MSMM( SNM->NM_CDHREJ, , , M->NM_HISTREJ, 1, , ,"SNM", "NM_CDHREJ" )
							SNM->(MsUnlock())
						Else
							RecLock( "SNM", .F. )
							SNM->NM_USRAPV	:= __cUserID
							SNM->NM_DTAPVRE	:= dDtApvRej
							SNM->NM_HRAPVRE	:= dHrApvRej
							SNM->NM_NOTA    := cNota
							SNM->NM_SITSOL	:= "2"
							SNM->( MsUnlock() )
						EndIf
					Endif
					
					SNM->(dbSkip())
				EndDo	//Fim da gravação de Itens
			EndIf
			END TRANSACTION
		Else
			DisarmTransaction()
		EndIf
		//Fim da transferência
	ElseIf nOpc == 4 //Rejeição
		dbSelectArea("SNM")
		SNM->( dbSetOrder(1) )
		SNM->( dbSeek( xFilial("SNM") + cCodigo ) )
				
		While SNM->(!Eof()) .And. xFilial("SNM") + cCodigo == SNM->NM_FILIAL + SNM->NM_CODIGO
			RecLock("SNM", .F.)
			SNM->NM_SITSOL 	:= "3" //Rejeitada
			SNM->NM_USRAPV 	:= __cUserID
			SNM->NM_DTAPVRE := dDataBase
			SNM->NM_HRAPVRE := StrTran(Left(Time(),5),":","")
			MSMM(SNM->NM_CDHREJ, , , M->NM_HISTREJ, 1, , , "SNM", "NM_CDHREJ" )
			SNM->(MsUnlock())								
			SNM->(dbSkip())
		EndDo
		lRet := .T.
	EndIf
EndIf   

If lRet .And. !Empty(nWFID) .And. !lWFProc
	cUserFluig := FWWFColleagueId(__cUserID)
	CancelProcess(nWFID,cUserFluig,STR0029)//"Excluido pelo sistema"
EndIf           
  
IF lRet .AND. ExistBlock ("ATF126GRV")
	ExecBlock("ATF126GRV",.F.,.F.,{NOPC})
EndIf

RestArea( aArea )

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ ATF126Nota                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor     ³ Alvaro Camillo Neto                       ³ Data ³ 26/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Processa a geracao de nota fiscal de saida e de entrada    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ATF126Nota( cSerie, aNotaSai, aNotaEnt , cCodigo )

Local aArea 	:= GetArea()
Local aAreaSNM  := SNM->(GetArea())
// Variavel com a filial origem
Local cFilOri	:= cFilAnt
// Array com os parametros do programa
Local aParam460	:= Array(30)
Local cPedido   := ""
Local cWhile    := ""
Local cNotaFeita:= ""
Local cPedidos  := ""
Local cSeekD1   := ""
Local aCabec    := {}
Local aItens    := {}
Local aPvlNfs   := {}
Local aBloqueio := {{"","","","","","","",""}}
Local aNotas    := {}
Local aDadosAux := {}
Local nItemNf   := 0
Local nSaveSX8  := 0
Local nAchoSerie:= 0
Local nPrcVen   := 0
Local nPosLocal := 0
Local nBloqueio := 0
Local ni        := 1
Local nx        := 1
Local nZ        := 1
Local aSeries   := {}
Local nTamSD2	:= TamSX3("D2_DOC")[1]
Local lContinua := .T.
Local cCliente	:=	""
Local cLoja		:=  ""
Local cIdNota	:= ""
Local nQtdBx	:=  0
Local nRecnoSNM :=  0

// Array com notas geradas
Local aNotaFeita:= {}

// Variaveis para rotina automatica
Local lMostraErro   := .F.
Local lReferencia   := .F.
Local cGrade        := "N"
Local aColsAux      := { }
Local nItGrd        := 0
Local cProduto		:= ""
Local nRecnoSM0		:= SM0->(Recno())
Local cCNPJCli		:= ""
Local cCNPJFor		:= ""
Local cFornece		:= ""
Local cLojaFornece	:= ""
Local aParam103 := {}
Local aParam410 := {}
Local aParam140 := {}

Private lMsErroAuto:= .F.
// Variavel utilizada para verificar 1se o numero da nota foi alterado pelo usuario (notas de saida e entrada
// com formulario proprio).
Private lMudouNum := .F.
// Variavel utilizada para tratamento especifico para poder de terceiros
Private l310PODER3:= .F.

dbSelectArea("SNM")
SNM->(dbSetOrder(1))//NM_FILIAL+NM_CODIGO+NM_CBASE+NM_ITEM+NM_TIPO
If !SNM->(dbSeek(xFilial("SNM") + cCodigo ))
	HELP(" ",1,"REGNOIS")
	lContinua := .F.
EndIf

nRecnoSNM := SNM->(Recno())

AADD(aParam103, { "MV_PAR01", 2		   			, Nil } )
AADD(aParam410, { "MV_PAR07", 2		   			, Nil } )
AADD(aParam140, { "MV_PAR01", 2		   			, Nil } )

SaveInter()
//Grupo de pergunta de geracao de nota
Pergunte("MT460A",.F.)

For nx := 1 to 30
	aParam460[nx] := &("mv_par" + StrZero(nx, 2) )
Next nx

If !AF126VlNf(cCodigo)
	lContinua := .F.
	lMostraErro := .T.
EndIf

// Processamento das Transferencias
If lContinua
	If SNM->NM_TIPOSOL == "1" //Baixa
		cCliente := SNM->NM_CLIENTE
		cLoja	 := SNM->NM_LOJA
	Else  //Transferencia
		If SM0->( MsSeek( cEmpAnt + SNM->NM_FILDEST ) )
			cCNPJCli := SM0->M0_CGC
		EndIf
		SM0->(DbGoTo(nRecnoSM0))
		
		dbSelectArea("SA1")
		SA1->( dbSetOrder(3) )
		If SA1->( !dbSeek( xFilial("SA1") + Substr( cCNPJCli, 1, Len(SA1->A1_CGC) ) ) )
			// Nao existem dados da filial destino cadastrados como cliente na filial origem. A transferencia nao sera realizada
			Help( " ",1, "A310DATFL1" )
			lMostraErro	:=.T.
			lContinua   :=.F.
		Else
			cCliente := SA1->A1_COD
			cLoja	 := SA1->A1_LOJA
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa geracao de documentos de saida                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Variavel para rotina automatica
	lMsErroAuto := .F.
	// Array auxiliar
	aDadosAux   := {}
	// Atualiza para a filial origem
	cFilant:=IIF(!Empty(SNM->NM_FILIAL),SNM->NM_FILIAL,cFilAnt)
	// Array para geracao de notas
	aNotas   := {}
	// Arrays com itens e bloqueios
	aPvlNfs  := {}
	aBloqueio:= {}
	// Cabecalho do pedido
	aCabec   := {}
	// Itens do pedido
	aItens   := {}
	// Variavel que controla numeracao
	nSaveSX8 := GetSx8Len()
	// Caso tenha selecionado serie para esta filial
	If !Empty(cSerie)
		// Cabecalho do pedido
		cPedido := GetSxeNum( "SC5", "C5_NUM" )
		RollBAckSx8()
		
		aAdd( aCabec, { "C5_NUM"	 , cPedido		 , Nil } )
		aAdd( aCabec, { "C5_TIPO"	 , "N"			 , Nil } )
		aAdd( aCabec, { "C5_CLIENTE" , cCliente		 , Nil } )
		aAdd( aCabec, { "C5_LOJACLI" , cLoja		 , Nil } )
		aAdd( aCabec, { "C5_LOJAENT" , cLoja		 , Nil } )
		aAdd( aCabec, { "C5_CONDPAG" , SNM->NM_CONDPG, Nil } )
		aAdd( aCabec, { "C5_NATUREZ" , SA1->A1_NATUREZ, Nil } )
		
		// Contador dos itens
		nx     := 0
		nItGrd := 0
		// ATENCAO - VARIAVEL CRIADAS POR CAUSA DA QUEBRA NO FATURAMENTO
		aNotaFeita := {}
		
		// Incrementa regua de processamento
		IncProc()
		
		dbSelectArea( "SN1" )
		SN1->(dbSetOrder(1))
		
		dbSelectArea( "SN3" )
		SN3->(dbSetOrder(1))
		
		dbSelectArea("SNM")
		SNM->( dbSetOrder(1) )
		SNM->( dbSeek( xFilial("SNM") + cCodigo ) )
		
		While SNM->(!Eof()) .And. xFilial("SNM") + cCodigo == SNM->NM_FILIAL + SNM->NM_CODIGO
			
			If SNM->NM_TIPOSOL == "1" //Baixa
				SN1->(dbSeek( xFilial("SN1") + SNM->NM_CBASE + SNM->NM_ITEM ) )
				cProduto := SN1->N1_PRODUTO
				nQtdBx	 := SNM->NM_QTDBX
				nPrcVen	 := SNM->NM_VLVENDA
			Else  //Transferencia
				SN1->(dbSeek( xFilial("SN1") + SNM->NM_CBASE + SNM->NM_ITEM ) )
				SN3->(dbSeek( xFilial("SN3") + SNM->NM_CBASE + SNM->NM_ITEM ) )
				
				cProduto := SN1->N1_PRODUTO
				nQtdBx	 := SN1->N1_QUANTD
				nPrcVen	 := SN3->N3_VORIG1 * nQtdBx
			EndIf
			
			aLinha   := {}
			// Senao encontrou nenhum valor assume 1
			nX++
			If QtdComp( nPrcVen, .T. ) == QtdComp( 0, .T. )
				nPrcVen := 1
			EndIf
			aAdd( aLinha, { "C6_ITEM"	 , StrZero( nx, 2 )				    , Nil } )
			aAdd( aLinha, { "C6_PRODUTO" , cProduto						    , Nil } )
			aAdd( aLinha, { "C6_QTDVEN"	 , nQtdBx							, Nil } )
			aAdd( aLinha, { "C6_PRCVEN"	 , ( nPrcVen / nQtdBx )	            , Nil } )
			aAdd( aLinha, { "C6_VALOR"	 , nPrcVen						    , Nil } )
			aAdd( aLinha, { "C6_TES"	 , SNM->NM_TESNFS				    , Nil } )
			aAdd( aLinha, { "C6_CONTA"	 , SN3->N3_CCONTAB				    , Nil } )
			aAdd( aLinha, { "C6_CC"	     , SN3->N3_CUSTBEM				    , Nil } ) 
			aAdd( aLinha, { "C6_CLVL"	 , SN3->N3_CLVLCON				    , Nil } )
			aAdd( aLinha, { "C6_ITEMCTA" , SN3->N3_SUBCCON				    , Nil } )

			aAdd( aItens, aLinha )
			aAdd( aDadosAux, { cPedido, StrZero( nx, 2 ), SNM->NM_ARMAZEM,SNM->NM_CODIGO,SNM->NM_CBASE,SNM->NM_ITEM } )
			
			SNM->(dbSkip())
		EndDo
		
		SNM->(dbGoto(nRecnoSNM))
		// Inclusao do pedido
		lMsErroAuto := .F.
		MSExecAuto( { |x, y, z, p| mata410(x, y, z,,,,,,, p) }, aCabec, aItens, 3, aParam410 ) //Inclusao
		// Checa erro de rotina automatica
		If lMsErroAuto
			lMostraErro	:=.T.
			lContinua   :=.F.
		Else
			
			// Confirma SX8
			While ( GetSx8Len() > nSaveSX8 )
				ConfirmSX8()
			Enddo
			// Liberacao de pedido
			Ma410LbNfs( 2, @aPvlNfs, @aBloqueio )
			// Checa itens liberados
			Ma410LbNfs( 1, @aPvlNfs, @aBloqueio )
			
			// Caso tenha itens liberados manda faturar
			If Empty(aBloqueio) .And. !Empty(aPvlNfs)
				nItemNf  := a460NumIt(cSerie)
				aadd(aNotas,{})
				// Efetua as quebras de acordo com o numero de itens
				For nX := 1 To Len(aPvlNfs)
					If Len(aNotas[Len(aNotas)])>=nItemNf
						aadd(aNotas,{})
					EndIf
					aadd(aNotas[Len(aNotas)],aClone(aPvlNfs[nX]))
				Next nX
				// Gera as notas de acordo com a quebra
				If cPaisLoc == "BRA"
					For nX := 1 To Len(aNotas)
						cNotaFeita:=MaPvlNfs(aNotas[nX],cSerie,.F. ,.F. ,.T. ,aParam460[04]==1,aParam460[05]==1,aParam460[07],aParam460[08],aParam460[16]==1,aParam460[16]==2)
						AADD(aNotaFeita,PADR(cNotaFeita,nTamSD2))
					Next nX
				Else
					Ma410PvNFs("SC5",SC5->(Recno()),9)
					AADD(aNotaFeita,PADR(SF2->F2_DOC,nTamSD2))
				Endif
				
				// Carrega os arrays com o numero das notas fiscais de saida para baixa do ativo
				dbSelectArea("SD2")
				SD2->(dbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				For nx:=1 to Len( aNotaFeita )
					cIdNota := SerieNfId('SNM',4,'NM_SERIE',dDataBase,"",cSerie)
					If SD2->( dbSeek( xFilial("SD2") + PadR( aNotaFeita[nx], TamSX3("D2_DOC")[1] ) + cIdNota ) )
						While SD2->(!Eof()) .And. xFilial("SD2") + aNotaFeita[nx] + cIdNota == SD2->(D2_FILIAL + D2_DOC + D2_SERIE)
							nPosNota:= Ascan(aDadosAux,{|x| x[1]+x[2] == SD2->D2_PEDIDO+SD2->D2_ITEMPV})
							If nPosNota > 0
								aadd(aNotaSai,{aDadosAux[nPosNota,4],aDadosAux[nPosNota,5],aDadosAux[nPosNota,6]	, SD2->D2_DOC, SD2->D2_SERIE} )
							EndIf
							SD2->(dbSkip())
						End
					EndIf
				Next nx
				
				// Varre notas fiscais de saida geradas para gerar notas fiscais de entrada
				// se for transferência
				If SNM->NM_TIPOSOL == "2"
					
					dbSelectArea("SM0")
					If SM0->( MsSeek( cEmpAnt + SNM->NM_FILIAL ) )
						cCNPJFor := SM0->M0_CGC
					EndIf
					SM0->(DbGoTo(nRecnoSM0))
					
					cFilAnt := SNM->NM_FILDEST
					dbSelectArea("SA2")
					SA2->(dbSetOrder(3))
					If SA2->( !dbSeek( xFilial("SA2") + Substr( cCNPJFor, 1, Len(SA2->A2_CGC) ) ) )
						Help( " ", 1, "A310DATFL2" )
						lMostraErro	:=.T.
						lContinua   :=.F.
					Else
						cFornece	 := SA2->A2_COD
						cLojaFornece := SA2->A2_LOJA
					EndIf
					// Valida TES de entrada na filial destino
					If lContinua
						SF4->(dbSetOrder(1))
						lContinua := SF4->( MsSeek( xFilial("SF4") + SNM->NM_TESNFE ) )
						If !lContinua
							Help( " ", 1, "A310TESENT" )
							lMostraErro	:=.T.
							lContinua   :=.F.
						EndIf
					EndIf
					// Valida condicao de pagamento na filial destino
					If lContinua
						SE4->(dbSetOrder(1))
						lContinua := SE4->( MsSeek( xFilial("SE4") + SNM->NM_CONDPG  ))
						If !lContinua
							Help( " ", 1, "A310CONENT" )
							lMostraErro	:=.T.
							lContinua   :=.F.
						EndIf
					EndIf
					// Restaura filial original
					cFilAnt := cFilOri
					
					For nx:=1 to Len( aNotaFeita )
						aColsAux := {}
						nItem    := 0
						nItGrd   := 0
						dbSelectArea("SD2")
						SD2->(dbSetOrder(3))
						cIdNota := SerieNfId('SNM',4,'NM_SERIE',dDataBase,"",cSerie)
						If SD2->( dbSeek( xFilial("SD2") + PadR( aNotaFeita[nx], TamSX3("D2_DOC")[1] ) + cIdNota + cCliente + cLoja ) )
							// Cabecalho da nota fiscal de entrada
							aCabec   := {}
							aadd(aCabec,{"F1_TIPO"   	,"N"})
							aadd(aCabec,{"F1_FORMUL" 	,"N"})
							aadd(aCabec,{"F1_DOC"    	,aNotaFeita[nx]})
							aadd(aCabec,{"F1_SERIE"  	,cSerie})
							aadd(aCabec,{"F1_EMISSAO"	,dDataBase})
							aadd(aCabec,{"F1_FORNECE"	,cFornece})
							aadd(aCabec,{"F1_LOJA"   	,cLojaFornece})
							aadd(aCabec,{"F1_ESPECIE"	,"NFE"})
							aadd(aCabec,{"F1_COND"		,SNM->NM_CONDPG})
							aadd(aCabec,{"F1_EST"		,""})
							// Itens da nota fiscal de entrada
							aItens   := {}
							While SD2->(!Eof()) .And. xFilial("SD2") + aNotaFeita[nx] + cSerie + cCliente + cLoja == SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA)
								// Incrementa regua de processamento
								IncProc()
								cGrade   := "N"
								aLinha   := {}
								cProdRef := SD2->D2_COD
								nItem++
								aadd(aLinha,{"D1_ITEM"	, Strzero(nItem,4), Nil})
								aadd(aLinha,{"D1_COD"	, SD2->D2_COD		, Nil})
								aadd(aLinha,{"D1_QUANT"	, SD2->D2_QUANT	, Nil})
								aadd(aLinha,{"D1_VUNIT"	, SD2->D2_PRCVEN	, Nil})
								aadd(aLinha,{"D1_TOTAL"	, SD2->D2_TOTAL	, Nil})
								aadd(aLinha,{"D1_CONTA"	, SNM->NM_CCONTAB	, Nil}) 
								aadd(aLinha,{"D1_CC"	, SNM->NM_CUSTBEM	, Nil})
								aadd(aLinha,{"D1_CLVL"	, SNM->NM_CLVLBEM		, Nil})
								aadd(aLinha,{"D1_ITEMCTA", SNM->NM_ITBEM	, Nil})

								//-- Pesquisa armazem destino
								nPosLocal := Ascan(aDadosAux,{|x| x[1]+x[2] == SD2->D2_PEDIDO+SD2->D2_ITEMPV})
								If nPosLocal > 0
									aadd(aLinha,{"D1_LOCAL"	, aDadosAux[nPosLocal,3]	, Nil})
								Else
									aadd(aLinha,{"D1_LOCAL"	, SNM->NM_ARMAZEM , Nil})
								EndIf
								aadd(aLinha,{"D1_TES", SNM->NM_TESNFE, Nil})
								
								nPosNota:= Ascan(aDadosAux,{|x| x[1]+x[2] == SD2->D2_PEDIDO+SD2->D2_ITEMPV})
								If nPosNota > 0
									aadd(aNotaEnt,{aDadosAux[nPosNota,4],aDadosAux[nPosNota,5],aDadosAux[nPosNota,6] , SD2->D2_DOC, SD2->D2_SERIE} )
								EndIf
								
								// Checa geracao de documento
								If SNM->NM_CLASNFE == "2"
									// Checa se utiliza rastreabilidade
									If Rastro(SD2->D2_COD,"L")
										aadd(aLinha,{"D1_LOTECTL", SD2->D2_LOTECTL, Nil})
										aadd(aLinha,{"D1_DTVALID", SD2->D2_DTVALID, Nil})
									EndIf
									If Rastro(SD2->D2_COD,"S")
										aadd(aLinha,{"D1_NUMLOTE", SD2->D2_NUMLOTE, Nil})
										aadd(aLinha,{"D1_DTVALID", SD2->D2_DTVALID, Nil})
									EndIf
								EndIf
								aadd(aItens,aLinha)
								SD2->(dbSkip())
							End
							// Caso tenha itens e cabecalho definidos
							If Len(aItens) > 0 .And. Len(aCabec) > 0
								// Atualiza para a filial destino
								cFilant:=SNM->NM_FILDEST
								// Reinicializa ambiente para o fiscal
								If MaFisFound()
									MaFisEnd()
								EndIf
								// Checa geracao de documento     |MATA103->MATA101N|  |MATA140->|
								lMsErroAuto := .F.
								If SNM->NM_CLASNFE == "2"
									MSExecAuto( { |x, y, z, p| MATA103(x, y, z,,,,p) }, aCabec,aItens,3,aParam103 ) //Inclusao
								Else
									// Inclui pre-nota
									MSExecAuto( { |x, y, z| MATA140(x, y, z) }, aCabec,aItens,3 ) //Inclusao
								EndIf
								// Checa erro de rotina automatica
								If lMsErroAuto
									lMostraErro	:=.T.
									lContinua := .F.
									Exit
								EndIf
								// Atualiza para a filial origem
								cFilant := SNM->NM_FILIAL
							EndIf
						EndIf
					Next nx
				EndIf
			Else
				cPedidos := ""
				For nBloqueio := 1 To Len(aBloqueio)
					If nBloqueio # 1 .And. aBloqueio[nBloqueio,1] == aBloqueio[nBloqueio-1,1]
						Loop
					EndIf
					cPedidos += aBloqueio[nBloqueio,1]+"/"
				Next nBloqueio
				Help( "", 1, "PVBLOQ", , STR0015 + CRLF + ;	//"Pedido de venda bloqueado, trasferência interrompida."
				STR0016 + ": " + SubStr( cPedidos, 1, Len(cPedidos)-1 ), 1, 10 )	//"Pedido"
				lMostraErro	:=.T.
				lContinua   :=.F.
			EndIf
		EndIf
	Else
		// A filial XX nao teve uma serie de nota fiscal de saida selecionada para geracao
		Help( " ", 1, "A310SERERR", , cFilAnt, 1, 10 )
		lMostraErro	:=.T.
		lContinua   :=.F.
	EndIf
EndIf
// Restaura filial original
cFilAnt := cFilOri
// Mostra erro em rotina automatica
If lMostraErro
	Mostraerro()
EndIf

RestInter()
RestArea( aAreaSNM )
RestArea( aArea )
Return (lContinua)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ATFA125Leg  ³ Autor ³ Marcos R. Pires     ³ Data ³ 19.07.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse ou retorna a ³±±
±±³          ³ para o BROWSE                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA620                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ATFA126Leg()

BrwLegenda( cCadastro, STR0007, { { "BR_VERDE"	 , STR0011},; 	//"Legenda"###"Aprovada"
{ "BR_VERMELHO", STR0012},; 	//"Rejeitada"
{ "BR_AMARELO" , STR0017} } ) //"Pendente"

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF126VlNf ºAutor  ³Alvaro Camillo Neto º Data ³  24/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza as validações da criação das notas fiscais de saidaº±±
±±º          ³ e entrada                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF126VlNf(cCodigo)
Local lRet 		:= .T.
Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSA2	:= SA2->(GetArea())
Local aAreaSE4	:= SE4->(GetArea())
Local aAreaSF4	:= SE4->(GetArea())
Local aAreaSN1	:= SN1->(GetArea())
Local aAreaSNM	:= SNM->(GetArea())
Local cFilX		:= cFilAnt
Local cFilOri	:= ""
Local cFilDest	:= ""
Local cCNPJCli	:= ""
Local cCNPJFor	:= ""

SNM->(dbSetOrder(1))//NM_FILIAL+NM_CODIGO+NM_CBASE+NM_ITEM+NM_TIPO
SA1->(dbSetOrder(3))
SN1->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SA2->(dbSetOrder(3))
SF4->(dbSetOrder(1))
SE4->(dbSetOrder(1))

SNM->(dbSeek( xFilial("SNM") + cCodigo ))
If SNM->NM_TIPOSOL == "2" //Transferencia
	cFilOri		:= IIF(!Empty(SNM->NM_FILIAL ),SNM->NM_FILIAL ,cFilAnt)
	cFilDest	:= IIF(!Empty(SNM->NM_FILDEST),SNM->NM_FILDEST,cFilAnt)
	
	If SM0->( MsSeek( cEmpAnt + cFilDest ) )
		cCNPJCli := SM0->M0_CGC
	EndIf
	If SM0->( MsSeek( cEmpAnt + cFilOri ) )
		cCNPJFor := SM0->M0_CGC
	EndIf
	
	//Verifica se a filial de destino esta cadastrada como cliente
	If SA1->( !dbSeek( xFilial("SA1",cFilOri) + Substr( cCNPJCli, 1, Len(SA1->A1_CGC) ) ) )
		// Nao existem dados da filial destino cadastrados como cliente na filial origem. A transferencia nao sera realizada
		Help( " ",1, "A310DATFL1" )
		lRet   :=.F.
	EndIf
	
	If lRet .And. !Empty(SA1->A1_RISCO) .And.  Alltrim(SA1->A1_RISCO) != "A"
		// Cliente cadastrado deve possuir Risco A para efetuar a transferencia.
		Help( " ",1, "A126DATRIS" )
		lRet   :=.F.
	EndIf
	
	//Verifica se a filial de origem esta cadastrada como fornecedor na filial de destino
	If SA2->( !dbSeek( xFilial("SA2",cFilDest) + Substr( cCNPJFor, 1, Len(SA2->A2_CGC) ) ) )
		Help( " ", 1, "A310DATFL2" )
		lRet   :=.F.
	EndIf
	
	// Valida TES de entrada na filial Origem
	If SF4->( !MsSeek( xFilial("SF4",cFilOri) + SNM->NM_TESNFS ) )
		Help( " ", 1, "A310TESSAI" )
		lRet :=.F.
	EndIf
	
	// Valida TES de entrada na filial destino
	If SF4->( !MsSeek( xFilial("SF4",cFilDest) + SNM->NM_TESNFE ) )
		Help( " ", 1, "A310TESENT" )
		lRet :=.F.
	EndIf
	
	// Valida condicao de pagamento na filial origem
	If SE4->( !MsSeek( xFilial("SE4",cFilOri) + SNM->NM_CONDPG  ))
		Help( " ", 1, "A310CONSAI" )
		lRet :=.F.
	EndIf
	
	// Valida condicao de pagamento na filial destino
	If SE4->( !MsSeek( xFilial("SE4",cFilDest) + SNM->NM_CONDPG  ))
		Help( " ", 1, "A310CONENT" )
		lRet :=.F.
	EndIf
	
	While SNM->(!Eof()) .And. xFilial("SNM") + cCodigo == SNM->NM_FILIAL + SNM->NM_CODIGO
		SN1->(dbSeek( xFilial("SN1") + SNM->NM_CBASE + SNM->NM_ITEM ) )
		cProduto := SN1->N1_PRODUTO
		// Valida o produto na filial de origem
		If SB1->( !MsSeek( xFilial("SB1",cFilOri) + cProduto  ))
			Help( "", 1, "A126PRODORI", , STR0023+cProduto+STR0024 ,1, 10 )	//"Produto: "##" não cadastrado na filial de origem"
			lRet :=.F.
		EndIf
		// Valida o produto na filial de destino
		If SB1->( !MsSeek( xFilial("SB1",cFilDest) + cProduto  ))
			Help( "", 1, "A126PRODORI", , STR0023+cProduto+STR0025 ,1, 10 )//"Produto: "##	" não cadastrado na filial de destino"
			lRet :=.F.
		EndIf
		SNM->(dbSkip())
	EndDo
	
EndIf


cFilAnt := cFilX
RestArea(aAreaSNM)
RestArea(aAreaSN1)
RestArea(aAreaSF4)
RestArea(aAreaSE4)
RestArea(aAreaSA2)
RestArea(aAreaSA1)
RestArea(aAreaSM0)
RestArea(aArea)
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva    ³ Data ³28/11/06  ³±±
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
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { { STR0018, "AxPesqui"  , 0 , 1, ,.F.	},; //"Pesquisar"
{ STR0019, "AxVisual"  , 0 , 2		},; //"Visualizar"
{ STR0020, "ATFA126Apr", 0 , 4		},; //"Aprovar"
{ STR0021, "ATFA126Apr", 0 , 4		},; //"Rejeitar"
{ STR0022, "ATFA126Leg", 0 , 5, ,.F.	} }	//"Legenda"

Return( aRotina )
                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA126   ºAutor  ³Microsiga           º Data ³  03/14/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF126Trans(cSolict,cBase,cItem,cNota,cSerie,cTipo,lWFProc)
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaSN3   := SN3->(GetArea())
Local aAreaSNM   := SNM->(GetArea())
Local aDadosAuto := {}
Local aParam060  := {}
Local lTransFil  := .F.
Local bWhile	 := {||.T.}
Local cSeek		 := ''
Local cLogTxt    := ''

Default cErrExcA060 := ''
Default lWFProc  := .F.

AADD(aParam060, { "MV_PAR02", 2		   			, Nil } )

SNM->(DbSetOrder(1)) //NM_FILIAL+NM_CODIGO+NM_CBASE+NM_ITEM+NM_TIPO
SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

SNM->(DbSeek(xFilial("SNM") + cSolict + cBase + cItem))

lTransFil := xFilial("SN1",SNM->NM_FILDEST) !=  xFilial("SN1")

If lTransFil
	bWhile := {|| SN3->(N3_FILIAL+N3_CBASE+N3_ITEM) == xFilial("SN3") + cBase + cItem}
	cSeek :=  xFilial("SN3") + cBase + cItem
Else
	bWhile := {|| SN3->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO) == xFilial("SN3") + cBase + cItem + cTipo } 
	cSeek :=  xFilial("SN3") + cBase + cItem + cTipo
EndIf 

SN3->(DbSeek(cSeek))
      
While SN3->(!EOF()) .And. Eval(bWhile) 
	
	If Empty(SN3->N3_BAIXA) .Or. SN3->N3_BAIXA == '0'
	
		aDadosAuto := {}
		
   		aAdd( aDadosAuto, { 'N1_FILIAL' , SNM->NM_FILDEST , Nil } )		
		aAdd( aDadosAuto, { 'N3_CBASE'  , SNM->NM_CBASE   , Nil } )	// Codigo base do ativo
		aAdd( aDadosAuto, { 'N3_ITEM'   , SNM->NM_ITEM	, Nil } )	// Item sequencial do codigo bas do ativo
	   
		If !lTransFil
	   		aAdd( aDadosAuto, { 'N3_TIPO'   , SN3->N3_TIPO	, Nil } )		
	   		aAdd( aDadosAuto, { 'N3_BAIXA'  , SN3->N3_BAIXA	, Nil } )		
	   		aAdd( aDadosAuto, { 'N3_SEQ'    , SN3->N3_SEQ	, Nil } )		
		EndIf
		
		aAdd( aDadosAuto, { 'N3_CCUSTO' , SNM->NM_CCUSTO  , Nil } )	// Centro de Custo de Despesa
		aAdd( aDadosAuto, { 'N3_CCONTAB', SNM->NM_CCONTAB , Nil } )	// Conta Contabil
		aAdd( aDadosAuto, { 'N3_CCORREC', SNM->NM_CCORREC , Nil } )	// Conta de Correcao do Bem
		aAdd( aDadosAuto, { 'N3_CDEPREC', SNM->NM_CDEPREC , Nil } )	// Conta Despesa Depreciacao
		aAdd( aDadosAuto, { 'N3_CCDEPR' , SNM->NM_CDDEPR  , Nil } )	// Conta Depreciacao Acumulada
		aAdd( aDadosAuto, { 'N3_CDESP'  , SNM->NM_CDESP   , Nil } )	// Conta Correcao Depreciacao
		aAdd( aDadosAuto, { 'N3_CUSTBEM', SNM->NM_CUSTBEM , Nil } )	// Centro de Custo da Conta do Bem
		aAdd( aDadosAuto, { 'N3_CCCORR' , SNM->NM_CCCORR  , Nil } )	// Centro Custo Correcao Monetaria
		aAdd( aDadosAuto, { 'N3_CCDESP' , SNM->NM_CCDESP  , Nil } )	// Centro Custo Despesa Depreciacao
		aAdd( aDadosAuto, { 'N3_CCCDEP' , SNM->NM_CCCDEP  , Nil } )	// Centro Custo Despesa Acumulada
		aAdd( aDadosAuto, { 'N3_CCCDES' , SNM->NM_CCCDES  , Nil } )	// Centro Custo Correcao Depreciacao
		aAdd( aDadosAuto, { 'N3_SUBCCON', SNM->NM_ITBEM   , Nil } )	// Item contabil da Conta do Bem
		aAdd( aDadosAuto, { 'N3_SUBCCOR', SNM->NM_ITCORR  , Nil } )	// Item contabil da Correcao Monetaria
		aAdd( aDadosAuto, { 'N3_SUBCDEP', SNM->NM_ITDESP  , Nil } )	// Item contabil da Despesa Depreciacao
		aAdd( aDadosAuto, { 'N3_SUBCCDE', SNM->NM_ITCDEP  , Nil } )	// Item contabil da Despesa Acumulada
		aAdd( aDadosAuto, { 'N3_SUBCDES', SNM->NM_ITCDES  , Nil } )	// Item contabil da Correcao Depreciacao
		aAdd( aDadosAuto, { 'N3_CLVLCON', SNM->NM_CLVLBEM , Nil } )	// Classe de Valor da Conta do Bem
		aAdd( aDadosAuto, { 'N3_CLVLCOR', SNM->NM_CLVLCOR , Nil } )	// Classe de Valor da Correcao Monetaria
		aAdd( aDadosAuto, { 'N3_CLVLDEP', SNM->NM_CLVLDEP , Nil } )	// Classe de Valor da Despesa Depreciacao
		aAdd( aDadosAuto, { 'N3_CLVLCDE', SNM->NM_CLVLCDE , Nil } )	// Classe de Valor da Despesa Acumulada
		aAdd( aDadosAuto, { 'N3_CLVLDES', SNM->NM_CLVLDES , Nil } )	// Classe de Valor da Correcao Depreciacao
		aAdd( aDadosAuto, { 'N1_GRUPO'  , SNM->NM_GRUPO   , Nil } )	// Codigo do Grupo do Bem
		aAdd( aDadosAuto, { 'N1_LOCAL'  , SNM->NM_LOCAL   , Nil } )	// Localizacao do Bem
		aAdd( aDadosAuto, { 'N1_NFISCAL', cNota		   , Nil } )	// Numero da NF
		aAdd( aDadosAuto, { 'N1_NSERIE' , cSerie		   , Nil } )	// Serie da NF
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso deseje passar valores para os campos, Grupo, Local, NF/Serie Taxa padrao, considerar ³
		//³ como no exemplo acima utilizando os campos correspondentes da tabela SN1.                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		lMsErroAuto    := .F.
		lMSHelpAuto    := .T.
		lAutoErrNoFile := lWFProc

		MSExecAuto( { |x, y, z| AtfA060( x, y, z ) }, aDadosAuto, 4, aParam060 )
			
		If lMsErroAuto
			AEval(GetAutoGRLog(), {|x| cLogTxt += x + CRLF})
			cErrExcA060 := cLogTxt
			lRet := .F.	
		EndIf
		
		If lTransFil
			Exit
		EndIf
	EndIf
		
	SN3->(dbSkip())
EndDo

RestArea(aAreaSN3)
RestArea(aAreaSNM)
RestArea(aArea)
Return lRet
