#include "PROTHEUS.ch"
#include "TMSAI70.ch"

Static TMI70Col := ExistBlock('TMI70COL') 
Static lTMI70DTC:= ExistBlock('TMI70DTC')

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º  TMSAI70   º Autor º Richard Anderson   º Data º 22/11/06 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º             	Geração do CRT                              		   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º  TMSAI70()                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º                                         			       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º NIL                                                       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º SIGATMS - Gestao de Transportes                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º                                                           º±±
±±º            º                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º  Data  º BOPS º             Motivo da Alteracao           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ºxx/xx/02ºxxxxxxº                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAI70()

Local   aCores    := {}
Local   aAreaSM0  := SM0->(GetArea())
Private cCadastro	:= STR0001 //-- Geração do CRT

Private aImpRotina:= {{ STR0013  , "TMAI70I1"  , 0, 6 },; //"CRT"
 				          { STR0014  , "TMAI70I2"  , 0, 6 }}  //"CRT Gráfico"
 				          
Private aRotina	:= {}                                                

If ExistBlock('TMI70ROT')
	ExecBlock('TMI70ROT',.F.,.F.)
EndIf	

If Len(aRotina) == 0
	aRotina	:= {{ STR0002  , "AxPesqui"   , 0, 1 },;  //"Pesquisar"
				{ STR0003  , "TMAI70Mnt"  , 0, 2 },;  //"Visualizar"
				{ STR0004  , "TMAI70Mnt"  , 0, 3 },;  //"Incluir"  
				{ STR0005  , "TMAI70Mnt"  , 0, 4 },;  //"Alterar"  
				{ STR0006  , "TMAI70Mnt"  , 0, 5 },;  //"Excluir                                               
				{ STR0021  , "TMAI70Mnt"  , 0, 6 },;  //"Cancelar"
				{ STR0071  , "TMAI70Mnt"  , 0, 4 },;  //"Regerar"
				{ STR0072	, "TMAI70Mnt"  , 0, 4 },; //"Copiar"
				{ STR0007  , aImpRotina   , 0, 8 },;  //"Imprimir"
				{ STR0015  , "TMAI70Leg"  , 0 ,9 } }  //"Legenda"
EndIf

Aadd(aCores,{"DIK_STATUS=='1'",'BR_AMARELO'	})	// Em Aberto
Aadd(aCores,{"DIK_STATUS=='2'",'BR_VERDE'   	})	// Gerado
Aadd(aCores,{"DIK_STATUS=='3'",'BR_VERMELHO'	})	// Alterado
Aadd(aCores,{"DIK_STATUS=='4'",'BR_AZUL' 		})	// Regerado
Aadd(aCores,{"DIK_STATUS=='9'",'BR_PRETO'		})	// Cancelado
    
dbSelectArea("DIK")
dbSetOrder(1)
dbGoTop()

mBrowse(6,1,22,75,'DIK',,,,,,aCores)

RestArea(aAreaSM0)

Return .T.  

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70Mnt³ Autor ³ Richard Anderson      ³ Data ³19.03.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Interface da Rotina de geracao de CRT                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Alias da tabela                                      ³±±
±±³          ³ ExpN2: Numero do Registro                                   ³±±
±±³          ³ ExpN3: Opcao do aRotina                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAI70Mnt(cAlias, nReg, nOpcx)

Local nI          := 0
Local nCnt        := 1
Local nTLinhas    := 0
Local cSerieDoc   := Padr('LOT',Len(DIB->DIB_SERIE))
Local lFilAut     := .F.
Local dDatFTMS    := GetMv("MV_DATATMS",.F.,CtoD(''))
Local cTMSMFat    := GetMV("MV_TMSMFAT",,"") //-- Modo de Faturamento:1-Faturamento a partir do SE1;2=Faturamento a partir do DT6
Local aDadCli     := {}
Local aDadCRT     := {}
Local	cFilSF2     := ''
Local	cFilSE1     := ''		
Local	aPerfil     := {}
Local	cDocFat     := ''
Local	cPrefixo    := ''
Local dDtdigit    := Ctod('')
Local cQuery      := ''
Local cAliasQry   := GetNextAlias()
Local aAreaDIK    := {}
Local nTam        := 0
Local aAreaDT6 	  := DT6->(GetArea())
Local lRet			:= .T.

//-- Enchoicer
Local aVisEnch1   := {}
Local aAltEnch1   := {}
Local aVisEnch2   := {}
Local aAltEnch2   := {}
Local aVisEnch3   := {}
Local aAltEnch3   := {}
Local nOpcA			:= 0
Local nOpcB       := aRotina[nOpcx,4]
Local aButtons    := {}

//-- Dialog
Local oDlg
Local oFolder
Local aNoFields	:= {}
Local aYesFields	:= {}
Local oFont       := TFont():New( "Courier New", 6, 15 )

//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}
Local aColsAnt    := {}
Local aHeadAnt    := {}

//-- GetDados
Local nNumLinhas  := 999
Local lTMAI70CPO  := ExistBlock('TMAI70CPO') 
Local nCntFor     := 0
Local aCpos       := {}     

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]
Private oTmsEnch
Private oTmsEnch2
Private oTmsEnch3
Private aCRTCamp  := {}

//-- GetDados
Private oGetD
Private aHeader	 := {}
Private aCols	    := {}
Private aHeaderDI9 := {}
Private aColsDI9   := {}
Private aHeaderDIA := {}
Private aColsDIA   := {}
Private aTmsPosObj := {}
Private aSvHeader	 := {{},{}}
Private aSvCols	 := {{},{}}
Private oFolFrt    := NIL     
Private nControGD	 := 0    // variavel para controle da ultima GETDADOS editada devido ao problema de que quando se esta editando a getdados e depois clica direto no OK nao e' executado o CODBLOCK de LOSTFOCUS da GETDADOS.
Private oGetDIA    := {}
Private oGetDI9    := {}

//-- Objeto LISTBOX
Private oLbx1
Private cLbx1

//-- Gerais
Private lTmsCFec   := TmsCFec()
Private aFrete     := {}
Private aItContrat := {}
Private aSetKey    := {}
Private __lAtzFrt  := .F.
Private __lAltFrt  := .F.
Private __nTotFrt  := 0
Private nOpcao     := nOpcx //Esta opcao e importante para o Regerar, no When
Private aValInf	   := {} 

If nOpcx == 4 .Or. nOpcx == 7 //-- Alteracao ou Regerar
	If DIK->DIK_STATUS == '9' //-- Cancelado
		MsgAlert(STR0025) //-- "Não é possível alterar CRT cancelado!"
		Return NIL
	EndIf
		
	If nOpcx == 7 .And. Empty(DIK->DIK_DOC)
		MsgAlert(STR0073) //--"Nao e permitido Regerar um CRT que nao foi calculado"
		Return Nil
	EndIf
	DT6->(dbSetOrder(1))
	If !Empty(DIK->DIK_DOC) .And. DT6->(dbSeek(xFilial('DT6')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE)))
		//-- Nao permite emissao/estorno de documentos com data menor que o fechamento do estoque
		If DT6->DT6_DATEMI <= If(FindFunction("MVUlmes"),MVUlmes(),GetMV("MV_ULMES"))
			Help(" ",1,"FECHTO") //"Nao pode ser digitado movimento com data anterior a ultima data de fechamento (virada de saldos)"
			Return NIL
		EndIf
		If !Empty(dDatFTMS) .And. DT6->DT6_DATEMI <= dDatFTMS
			Help(" ",1,"FECHATMS")
			Return NIL
		EndIf
		//--Nao pode regerar um CRT que tenha carregamento parcial, precisa estornar todo o processo
		If nOpcx == 7 .And. DT6->DT6_QTDVOL != DT6->DT6_VOLORI
			MsgAlert(STR0074) //--"Nao e permitido Regerar um CRT com Carregamento Parcial"
			Return NIL
		EndIf
		If Empty(DT6->DT6_NUMVGA)
			If DT6->DT6_FILORI != cFilAnt
				MsgAlert(STR0026) //-- "Filial não autorizada para alterar esse CRT"
				Return NIL
			EndIf
		Else
			lFilAut := .F.
			DTQ->(dbSetOrder(2))
			If DTQ->(dbSeek(xFilial('DTQ')+DT6->(DT6_FILVGA+DT6_NUMVGA)))
				DI5->(dbSetOrder(1))
				DI5->(dbSeek(cSeekDI5 := xFilial('DI5')+DTQ->DTQ_ROTA)) 
				While DI5->(!Eof()) .And. DI5->(DI5_FILIAL+DI5_ROTA) == cSeekDI5
					If DI5->DI5_FILDCA == cFilAnt
						lFilAut := .T.
						Exit
					EndIf
					DI5->(dbSkip())
				EndDo
			EndIf
			If !lFilAut
				If DT6->DT6_FILORI == cFilAnt
					lFilAut := .T.
				EndIf
			EndIf											
			If !lFilAut
				MsgAlert(STR0026) //-- "Filial não autorizada para alterar esse CRT"
				Return NIL
			EndIf
		EndIf
		cFilSF2 := Iif(Empty(xFilial('SF2')), xFilial('SF2'), DT6->DT6_FILDOC)
		SF2->(dbSetOrder(1))
		SF2->(dbSeek(cFilSF2+DT6->DT6_DOC+DT6->DT6_SERIE))
		//-- Verifica se o documento esta faturado
		If cTMSMFat == '2'
			//-- Obtem o perfil do cliente para verificar quais documentos possuem tratamento diferenciado no 
			//-- faturamento:
			aPerfil := TmsPerfil(DT6->DT6_CLICAL,DT6->DT6_LOJCAL,,,DT6->DT6_CLIREM,DT6->DT6_LOJREM,DT6->DT6_CLIDES,DT6->DT6_LOJDES)
			cDocFat := aPerfil[47]
			If AllTrim(cDocFat) <> '*' .And. !(DT6->DT6_DOCTMS $ cDocFat) .And. !Empty(DT6->DT6_NUM)
				Help(' ', 1, 'TMSA20030',,DT6->DT6_FILDOC+ "/" + DT6->DT6_DOC+ "/" + DT6->DT6_SERIE + CHR(13) + CHR(10) + 'CRT já faturado',2,1) 
				Return NIL
			EndIf
		Else
			cFilSE1 := Iif(Empty(xFilial('SE1')), xFilial('SE1'), DT6->DT6_FILDOC)		
			cPrefixo:= Padr( If(Empty(SF2->F2_PREFIXO),&(GETMV("MV_1DUPREF")),SF2->F2_PREFIXO),  Len( SE1->E1_PREFIXO ) )
			//-- Verifica se o documento tem titulo baixado ou que nao esteja mais em carteira 
			SE1->(DbSetOrder(1))
			If SE1->(MsSeek(cFilSE1+cPrefixo+DT6->DT6_DOC))
				If Round(SE1->E1_SALDO,2) <> Round(SE1->E1_VALOR,2) .Or. SE1->E1_SITUACA <> StrZero(0,Len(SE1->E1_SITUACA))
					Help(" ",1,"TMSA20026",,STR0024 + DT6->DT6_DOC + '/' + DT6->DT6_SERIE, 4,01) //-- O titulo do documento esta baixado ou nao esta em Carteira ...
					Return NIL
				 EndIf
			EndIf
		EndIf
		dDtdigit := IIf(SF2->(FieldPos('F2_DTDIGIT')) > 0 .And. !Empty(SF2->F2_DTDIGIT),SF2->F2_DTDIGIT,SF2->F2_EMISSAO)
		If !FisChkDt(dDtDigit)
			Return NIL
		EndIf
	EndIf
ElseIf nOpcx == 5 //--Exclusao de CRT
	If DIK->DIK_STATUS != '1'
		MsgAlert(STR0027) //-- "Exclusão permitida somente para documentos com status [Em Aberto]"
		Return NIL
	EndIf
	If DIK->DIK_FILORI <> cFilAnt
		MsgAlert(STR0075) //--"Nao e permitido excluir um CRT em outra filial"
		Return NIL
	EndIf
ElseIf nOpcx == 6
	If DIK->DIK_STATUS != '2' .And. DIK->DIK_STATUS != '3'
		MsgAlert(STR0028) //-- "Cancelamento permitido somente para documentos com status [Gerado] ou [Alterado]"
		Return NIL
	EndIf
	aAreaDT6 := DT6->(GetArea())
	DT6->(dbSetOrder(8))
	If DT6->(dbSeek(xFilial("DT6")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
		MsgAlert(STR0076) //--"Nao e permitido Cancelar um CRT que tenha um CRT Complementar relacionado"
		RestArea(aAreaDT6)
		Return NIL
	EndIf
	RestArea(aAreaDT6)
EndIf

Aadd(aSetKey , { VK_F5 ,{|| TMAI70Frt(Iif(nOpcx == 5,2,nOpcx)) } } )
Aadd(aButtons,	{'PRECO',{|| TMAI70Frt(Iif(nOpcx == 5,2,nOpcx)) } , STR0008 , STR0009 })  //'Calcula Frete - <F5>'

If nOpcx == 2 .Or. nOpcx == 5 .And. !Empty(DIK->DIK_DOC)
	DT6->(dbSetOrder(1))
	DT6->(dbSeek(xFilial('DT6')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE)))
	
	Aadd(aSetKey , { VK_F7   ,{|| 	TMAI70Vis() }} )
	Aadd(aButtons,	{'BMPPARAM',{|| 	TMAI70Vis() }, STR0085 , STR0086 })  //'Carta Correcao - <F7>'

	Aadd(aSetKey , { VK_F8   ,{|| TMAI70Doc()  } })
	AAdd(aButtons, {'DEVOLNF',{|| TMAI70Doc()  } , STR0083     , STR0084   }) //--'Documento - <F8>'
	AAdd(aSetKey , { VK_F9    ,{|| I070ValInf(nOpcx,GdFieldGet('DIN_NUMNFC',n),GdFieldGet('DIN_SERNFC',n),GdFieldGet('DIN_CODPRO',n)) } } )
	AAdd(aButtons, {'COMPTITL',{|| I070ValInf(nOpcx,GdFieldGet('DIN_NUMNFC',n),GdFieldGet('DIN_SERNFC',n),GdFieldGet('DIN_CODPRO',n)) }, STR0088 , STR0089 }) //"Valor Informado - <F9>"###"Val.Inf."
ElseIf nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx == 7 .Or. nOpcx == 8
	Aadd(aSetKey , { VK_F6   ,{|| TMAI70Rec(nOpcx) }} )
	Aadd(aButtons,	{'BUDGET',{|| TMAI70Rec(nOpcx) }, STR0022 , STR0023 })  //'Recalcula Frete - <F6>'
	AAdd(aSetKey , { VK_F9    ,{|| I070ValInf(nOpcx,GdFieldGet('DIN_NUMNFC',n),GdFieldGet('DIN_SERNFC',n),GdFieldGet('DIN_CODPRO',n)) } } )
	AAdd(aButtons, {'COMPTITL',{|| I070ValInf(nOpcx,GdFieldGet('DIN_NUMNFC',n),GdFieldGet('DIN_SERNFC',n),GdFieldGet('DIN_CODPRO',n)) }, STR0088 , STR0089 }) //"Valor Informado - <F9>"###"Val.Inf."
EndIf

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

//-- Configura variaveis da Enchoice                                                                                
RegToMemory( cAlias, INCLUI )
                                                            
//-- Variavel para controle da composicao do frete
M->DIK_CMPFRE := ''

If nOpcx != 3
	TmsValInf(aValInf,'4',cFilAnt,,M->DIK_LOTNFC,M->DIK_CLIREM,M->DIK_LOJREM,M->DIK_CLIDES,M->DIK_LOJDES,M->DIK_SERVIC)
	aAreaDIK := DIK->(GetArea()) //--A Funcao TMSDadCRT desposiciona o DIK, quando visualiza o CRT em outra filial
	If Empty(M->DIK_DOC)
		//-- Campo 01: Dados do Remetente
		aDadCli:= TMSDadCRT('01',M->DIK_FILORI,M->DIK_LOTNFC,cSerieDoc,.T.)
		
		lDVazio:= .T.
		Aeval(aDadCli,{ | e | Iif(!Empty(e),lDVazio := .F.,'') })
		If lDVazio
			aDadCli:= TMSDadCli(M->DIK_CLIREM,M->DIK_LOJREM,1)
		EndIf			
		cDados := ''
		For nI := 1 To Len(aDadCli)
			cDados += aDadCli[nI]+Chr(13)+Chr(10)
		Next nI                                                                 
		M->DIK_DADREM := cDados
		
		//-- Campo 04: Dados do Destinatario
		aDadCli:= TMSDadCRT('04',M->DIK_FILORI,M->DIK_LOTNFC,cSerieDoc,.T.)
		lDVazio:= .T.
		Aeval(aDadCli,{ | e | Iif(!Empty(e),lDVazio := .F.,'') }) 
		If lDVazio
			aDadCli:= TMSDadCli(M->DIK_CLIDES,M->DIK_LOJDES,2)
		EndIf			
		cDados := ''
		For nI := 1 To Len(aDadCli)
			cDados += aDadCli[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADDES := cDados
      
		//-- Campo 05: Localidade e país
		M->DIK_LCPAIS := Padr(TMSDadReg(M->DIK_CDRORI),Len(M->DIK_LCPAIS))
		If Empty(AllTrim(M->DIK_LCPAIS))
			M->DIK_LCPAIS := Padr(TMSDadCRT('05',M->DIK_FILORI,M->DIK_LOTNFC,cSerieDoc,.T.)[1],Len(M->DIK_LCPAIS))
		EndIf
		
		//-- Campo 06: Dados do Consignatario
		aDadCli:= TMSDadCRT('06',M->DIK_FILORI,M->DIK_LOTNFC,cSerieDoc,.T.)
		lDVazio:= .T.
		Aeval(aDadCli,{ | e | Iif(!Empty(e),lDVazio := .F.,'') }) 
		If lDVazio
			aDadCli:= TMSDadCli(M->DIK_CLICON,M->DIK_LOJCON,2)
		EndIf
		cDados := ''
		For nI := 1 To Len(aDadCli)
			cDados += aDadCli[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADCON := cDados
		
		//-- Campo 07: Localidade Mercadoria
		M->DIK_LCMERC := Padr(TMSDadLMe(M->DIK_DATENT,M->DIK_FILCFS,M->DIK_NUMSOL,M->DIK_CLIREM,M->DIK_LOJREM),Len(M->DIK_LCMERC))
		If Empty(M->DIK_LCMERC)
			M->DIK_LCMERC := Padr(TMSDadCRT('07',M->DIK_FILORI,M->DIK_LOTNFC,cSerieDoc,.T.)[1],Len(M->DIK_LCMERC))
		EndIf
		
		//-- Campo 08: Localidade de Entrega
		M->DIK_LCENTR := Padr(TMSDadLEt(M->DIK_CLIDES,M->DIK_LOJDES),Len(M->DIK_LCENTR))
		If Empty(M->DIK_LCENTR)
			M->DIK_LCENTR := Padr(TMSDadCRT('08',M->DIK_FILORI,M->DIK_LOTNFC,cSerieDoc,.T.)[1],Len(M->DIK_LCENTR))
		EndIf
	   
		//-- Campo 09: Cliente a Notificar
		aDadCli:= TMSDadCRT('09',M->DIK_FILORI,M->DIK_LOTNFC,cSerieDoc,.T.)
		lDVazio:= .T.
		Aeval(aDadCli,{ | e | Iif(!Empty(e),lDVazio := .F.,'') }) 
		If lDVazio
			aDadCli:= TMSDadCli(M->DIK_CLINOT,M->DIK_LOJNOT,2)
	   EndIf
		cDados := ''
		For nI := 1 To Len(aDadCli)
			cDados += aDadCli[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADNOT := cDados
		
		//-- Campo 11: Descricao das Mercadorias
		aDadCRT:= TMSDadCRT('11',M->DIK_FILORI,M->DIK_LOTNFC,cSerieDoc,.T.)
		cDados := ''
		For nI := 1 To Len(aDadCRT)
			cDados += aDadCRT[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADMER := cDados

		//-- Campo 17: Documentos Anexos
		aDadCRT:= TMSDadCRT('17',M->DIK_FILORI,M->DIK_LOTNFC,cSerieDoc,.T.)
		cDados := ''
		For nI := 1 To Len(aDadCRT)
			cDados += aDadCRT[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DOCANE := cDados 
		
		//-- Campo 18: Instrucoes de Alfandega
		aDadCRT:= TMSDadCRT('18',M->DIK_FILORI,M->DIK_LOTNFC,cSerieDoc,.T.)
		cDados := ''
		For nI := 1 To Len(aDadCRT)
			cDados += aDadCRT[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADIAF := cDados		
		
		//-- Campo 21: Nome e assinatura do remetente
		aDadCRT:= TMSDadCRT('21',M->DIK_FILORI,M->DIK_LOTNFC,cSerieDoc,.T.)
		cDados := ''
		For nI := 1 To Len(aDadCRT)
			cDados += aDadCRT[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_NOMREM := cDados
		If Empty(AllTrim(M->DIK_NOMREM)) .OR. AllTrim(M->DIK_NOMREM) == Chr(13)+Chr(10)
			M->DIK_NOMREM := Posicione('SA1',1,xFilial('SA1')+M->DIK_CLIREM+M->DIK_LOJREM,'A1_NOME')
		EndIf
		//-- Campo 22: Declaracoes e Observacoes
		aDadCRT:= TMSDadCRT('22',M->DIK_FILORI,M->DIK_LOTNFC,cSerieDoc,.T.)
		cDados := ''
		For nI := 1 To Len(aDadCRT)
			cDados += aDadCRT[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADDCL := cDados
		
	ElseIf DIK->DIK_STATUS == '9' //--Crt Cancelado
		
		//-- Campo 01: Dados do Remetente
		aDadCli:= TMSDadCRT('01',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE,.F.)
		lDVazio:= .T.
		Aeval(aDadCli,{ | e | Iif(!Empty(e),lDVazio := .F.,'') }) 
		If lDVazio
			aDadCli:= TMSDadCli(M->DIK_CLIREM,M->DIK_LOJREM,1)
		EndIf			
		cDados := ''
		For nI := 1 To Len(aDadCli)
			cDados += aDadCli[nI]+Chr(13)+Chr(10)
		Next nI                                                                 
		M->DIK_DADREM := cDados
		
		//-- Campo 04: Dados do Destinatario
		aDadCli:= TMSDadCRT('04',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE,.F.)
		lDVazio:= .T.
		Aeval(aDadCli,{ | e | Iif(!Empty(e),lDVazio := .F.,'') }) 
		If lDVazio
			aDadCli:= TMSDadCli(M->DIK_CLIDES,M->DIK_LOJDES,2)
		EndIf			
		cDados := ''
		For nI := 1 To Len(aDadCli)
			cDados += aDadCli[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADDES := cDados
      
		//-- Campo 05: Localidade e país
		M->DIK_LCPAIS := Padr(TMSDadCRT('05',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE,.F.)[1],Len(M->DIK_LCPAIS))
      If Empty(M->DIK_LCPAIS)
			M->DIK_LCPAIS := Padr(TMSDadReg(M->DIK_CDRORI),Len(M->DIK_LCPAIS))
      EndIf
		
		//-- Campo 06: Dados do Consignatario
		aDadCli:= TMSDadCRT('06',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE,.F.)
		lDVazio:= .T.
		Aeval(aDadCli,{ | e | Iif(!Empty(e),lDVazio := .F.,'') }) 
		If lDVazio
			aDadCli:= TMSDadCli(M->DIK_CLICON,M->DIK_LOJCON,2)
    	EndIf
		cDados := ''
		For nI := 1 To Len(aDadCli)
			cDados += aDadCli[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADCON := cDados
		
		//-- Campo 07: Localidade Mercadoria
		M->DIK_LCMERC := Padr(TMSDadCRT('07',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE,.F.)[1],Len(M->DIK_LCMERC))
		If Empty(M->DIK_LCMERC)
			M->DIK_LCMERC := Padr(TMSDadLMe(M->DIK_DATENT,M->DIK_FILCFS,M->DIK_NUMSOL,M->DIK_CLIREM,M->DIK_LOJREM),Len(M->DIK_LCMERC))
		EndIf
		
		//-- Campo 08: Localidade de Entrega
		M->DIK_LCENTR := Padr(TMSDadCRT('08',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE,.F.)[1],Len(M->DIK_LCENTR))
		If Empty(M->DIK_LCENTR)
			M->DIK_LCENTR := Padr(TMSDadLEt(M->DIK_CLIDES,M->DIK_LOJDES),Len(M->DIK_LCENTR))		
	   EndIf
	   
		//-- Campo 09: Cliente a Notificar
		aDadCli:= TMSDadCRT('09',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE,.F.)
		lDVazio:= .T.
		Aeval(aDadCli,{ | e | Iif(!Empty(e),lDVazio := .F.,'') }) 
		If lDVazio
			aDadCli:= TMSDadCli(M->DIK_CLINOT,M->DIK_LOJNOT,2)
	   EndIf
		cDados := ''
		For nI := 1 To Len(aDadCli)
			cDados += aDadCli[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADNOT := cDados
		
		//-- Campo 11: Descricao das Mercadorias
		aDadCRT:= TMSDadCRT('11',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE,.F.)
		cDados := ''
		For nI := 1 To Len(aDadCRT)
			cDados += aDadCRT[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADMER := cDados

		//-- Campo 17: Documentos Anexos
		aDadCRT:= TMSDadCRT('17',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE,.F.)
		cDados := ''
		For nI := 1 To Len(aDadCRT)
			cDados += aDadCRT[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DOCANE := cDados 
		
		//-- Campo 18: Instrucoes de Alfandega
		aDadCRT:= TMSDadCRT('18',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE,.F.)
		cDados := ''
		For nI := 1 To Len(aDadCRT)
			cDados += aDadCRT[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADIAF := cDados
		
		//-- Campo 21: Nome e assinatura do remetente
		aDadCRT:= TMSDadCRT('21',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE,.F.)
		cDados := ''
		For nI := 1 To Len(aDadCRT)
			cDados += aDadCRT[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_NOMREM := cDados
		
		//-- Campo 22: Declaracoes e Observacoes
		aDadCRT:= TMSDadCRT('22',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE,.F.)
		cDados := ''
		For nI := 1 To Len(aDadCRT)
			cDados += aDadCRT[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADDCL := cDados
	
	Else
		//-- Campo 01: Dados do Remetente
		aDadCli:= TMSDadCRT('01',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE,,.F.)
		cDados := ''
		For nI := 1 To Len(aDadCli)
			cDados += aDadCli[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADREM := cDados
		
		//-- Campo 04: Dados do Destinatario
		aDadCli:= TMSDadCRT('04',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE,,.F.)
		cDados := ''
		For nI := 1 To Len(aDadCli)
			cDados += aDadCli[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADDES := cDados
		
		//-- Campo 05: Localidade e país
		M->DIK_LCPAIS := Padr(TMSDadCRT('05',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE)[1],Len(M->DIK_LCPAIS))
		
		//-- Campo 06: Dados do Consignatario
		aDadCli:= TMSDadCRT('06',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE,,.F.)
		cDados := ''
		For nI := 1 To Len(aDadCli)
			cDados += aDadCli[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADCON := cDados
		
		//-- Campo 07: Localidade Mercadoria
		M->DIK_LCMERC := Padr(TMSDadCRT('07',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE)[1],Len(M->DIK_LCMERC))
		
		//-- Campo 08: Localidade de Entrega
		M->DIK_LCENTR := Padr(TMSDadCRT('08',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE)[1],Len(M->DIK_LCENTR))

		//-- Campo 09: Cliente a Notificar
		aDadCli:= TMSDadCRT('09',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE)
		cDados := ''
		For nI := 1 To Len(aDadCli)
			cDados += aDadCli[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADNOT := cDados
		
		//-- Campo 11: Descricao das Mercadorias
		aDadCRT:= TMSDadCRT('11',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE)
		cDados := ''
		For nI := 1 To Len(aDadCRT)
			cDados += aDadCRT[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADMER := cDados

		//-- Campo 17: Documentos Anexos
		aDadCRT:= TMSDadCRT('17',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE)
		cDados := ''
		For nI := 1 To Len(aDadCRT)
			cDados += aDadCRT[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DOCANE := cDados 
		
		//-- Campo 18: Instrucoes de Alfandega
		aDadCRT:= TMSDadCRT('18',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE)
		cDados := ''
		For nI := 1 To Len(aDadCRT)
			cDados += aDadCRT[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADIAF := cDados
		
		//-- Campo 21: Nome e assinatura do remetente
		aDadCRT:= TMSDadCRT('21',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE)
		cDados := ''
		nTam := TamSX3('DIK_NOMREM')[1]
		For nI := 1 To Len(aDadCRT)
			cDados += aDadCRT[nI]+Replicate(' ',nTam-Len(aDadCRT[nI])) +Chr(13)+Chr(10)
		Next nI
		M->DIK_NOMREM := cDados
		
		//-- Campo 22: Declaracoes e Observacoes
		aDadCRT:= TMSDadCRT('22',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE)
		cDados := ''
		For nI := 1 To Len(aDadCRT)
			cDados += aDadCRT[nI]+Chr(13)+Chr(10)
		Next nI
		M->DIK_DADDCL := cDados		
	EndIf
	//-- Controle de alteraçoes
	//-- Campo 01: Dados do Remetente
	Aadd(aCRTCamp,{"DIK_DADREM","01",.F.,M->DIK_DADREM}) 
	
	//-- Campo 04: Dados do Destinatario
	Aadd(aCRTCamp,{"DIK_DADDES","04",.F.,M->DIK_DADDES})
	
	//-- Campo 05: Localidade e pais
	Aadd(aCRTCamp,{"DIK_LCPAIS","05",.F.,M->DIK_LCPAIS}) 
	
	//-- Campo 06: Dados do Consignatario
	Aadd(aCRTCamp,{"DIK_DADCON","06",.F.,M->DIK_DADCON})
	
	//-- Campo 07: Localidade Mercadoria
	Aadd(aCRTCamp,{"DIK_LCMERC","07",.F.,M->DIK_LCMERC}) 
	
	//-- Campo 08: Localidade de Entrega
	Aadd(aCRTCamp,{"DIK_LCENTR","08",.F.,M->DIK_LCENTR}) 

	//-- Campo 09: Cliente a Notificar
	Aadd(aCRTCamp,{"DIK_DADNOT","09",.F.,M->DIK_DADNOT}) 
	
	//-- Campo 11: Descricao das Mercadorias
	Aadd(aCRTCamp,{"DIK_DADMER","11",.F.,M->DIK_DADMER})
	
	//-- Campo 12: Peso bruto em Kg
	Aadd(aCRTCamp,{"DIK_PESO"  ,"12",.F.,M->DIK_PESO  ,PesqPict('DIK','DIK_PESO')  })							
	Aadd(aCRTCamp,{"DIK_PESLIQ","12",.F.,M->DIK_PESLIQ,PesqPict('DIK','DIK_PESLIQ')})

	//-- Campo 13: Metro 3
	Aadd(acrtCamp,{"DIK_METRO3","13",.F.,M->DIK_METRO3,PesqPict('DIK','DIK_METRO3')})
	
	//-- Campo 14: Valor
	Aadd(aCRTCamp,{"DIK_VALOR" ,"14",.F.,M->DIK_VALOR ,PesqPict('DIK','DIK_VALOR' )})
 
	//-- Campo 16: Declaracao do valor das mercadorias
	Aadd(aCRTCamp,{"DIK_INCOTE","16",.F.,M->DIK_INCOTE})
	Aadd(aCRTCamp,{"DIK_VALMER","16",.F.,M->DIK_VALMER,PesqPict('DIK','DIK_VALMER')})

	//-- Campo 17: Documentos Anexos
	Aadd(aCRTCamp,{"DIK_DOCANE","17",.F.,M->DIK_DOCANE}) 
	
	//-- Campo 18: Instrucoes de Alfandega
	aDadCRT:= TMSDadCRT('18',M->DIK_FILDOC,M->DIK_DOC,M->DIK_SERIE)
	Aadd(aCRTCamp,{"DIK_DADIAF","18",.F.,M->DIK_DADIAF})  
	
	//-- Campo 19: Frete Externo
	Aadd(aCRTCamp,{"DIK_VALFEX","19",.F.,M->DIK_VALFEX,PesqPict('DIK','DIK_VALFEX')}) 

	//-- Campo 20: Reembolso contra entrega
	Aadd(aCRTCamp,{"DIK_VALRBE","20",.F.,M->DIK_VALRBE,PesqPict('DIK','DIK_VALRBE')}) 
	
	//-- Campo 21: Nome e assinatura do remetente
	Aadd(aCRTCamp,{"DIK_NOMREM","21",.F.,M->DIK_NOMREM}) 
	
	//-- Campo 22: Declaracoes e Observacoes
	Aadd(aCRTCamp,{"DIK_DADDCL","22",.F.,M->DIK_DADDCL}) 
	RestArea(aAreaDIK)
EndIf

If nOpcx == 8 //--Copia
	M->DIK_FILDOC := CriaVar('DIK_FILDOC'	, .F.)
	M->DIK_DOC    := CriaVar('DIK_DOC'		, .F.)
	M->DIK_SERIE  := CriaVar('DIK_SERIE'	, .F.)
	M->DIK_STATUS := "1" //--Em Aberto
EndIf

//-- Determina campos dos Folders
//-- Enchoice 01
If (nOpcx != 3 .Or. nOpcx !=8) .And. !Empty(M->DIK_DOC)
	Aadd(aVisEnch1,'DIK_FILDOC')
	Aadd(aVisEnch1,'DIK_DOC'   )
	Aadd(aVisEnch1,'DIK_SERIE' )
EndIf	
Aadd(aVisEnch1,'DIK_DATENT')
Aadd(aVisEnch1,'DIK_MOENFC')
Aadd(aVisEnch1,'DIK_STATUS')
If nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx == 7 .Or. nOpcx == 8 //--Incluir/Alterar/Regerar/Copia
	aAltEnch1 := AClone(aVisEnch1)
EndIf

If nOpcao == 7 //--Regerar
	Aadd(aAltEnch1,'DIN_NUMNFC')
EndIf

//-- Enchoice 02
Aadd(aVisEnch2,'DIK_CPO001')
Aadd(aVisEnch2,'DIK_CLIREM')
Aadd(aVisEnch2,'DIK_LOJREM')
Aadd(aVisEnch2,'DIK_DADREM')
Aadd(aVisEnch2,'DIK_CPO004')
Aadd(aVisEnch2,'DIK_CLIDES')
Aadd(aVisEnch2,'DIK_LOJDES')
Aadd(aVisEnch2,'DIK_DADDES')
Aadd(aVisEnch2,'DIK_CPO005')
Aadd(aVisEnch2,'DIK_LCPAIS')
Aadd(aVisEnch2,'DIK_CPO006')
Aadd(aVisEnch2,'DIK_CLICON')
Aadd(aVisEnch2,'DIK_LOJCON')
Aadd(aVisEnch2,'DIK_DADCON')
Aadd(aVisEnch2,'DIK_CPO007')
Aadd(aVisEnch2,'DIK_LCMERC')
Aadd(aVisEnch2,'DIK_CPO008')
Aadd(aVisEnch2,'DIK_LCENTR')
Aadd(aVisEnch2,'DIK_CPO009')
Aadd(aVisEnch2,'DIK_CLINOT')
Aadd(aVisEnch2,'DIK_LOJNOT')
Aadd(aVisEnch2,'DIK_DADNOT')
Aadd(aVisEnch2,'DIK_CPO011')
Aadd(aVisEnch2,'DIK_DADMER')
Aadd(aVisEnch2,'DIK_CPO012')
Aadd(aVisEnch2,'DIK_PESO  ')
Aadd(aVisEnch2,'DIK_PESLIQ')
Aadd(aVisEnch2,'DIK_CPO013')
Aadd(aVisEnch2,'DIK_METRO3')
Aadd(aVisEnch2,'DIK_CPO014')
Aadd(aVisEnch2,'DIK_VALOR' )
Aadd(aVisEnch2,'DIK_CPO015')
Aadd(aVisEnch2,'DIK_VALFRT')
Aadd(aVisEnch2,'DIK_CPO016')
Aadd(aVisEnch2,'DIK_INCOTE')                          
Aadd(aVisEnch2,'DIK_VALMER')
Aadd(aVisEnch2,'DIK_CPO017')
Aadd(aVisEnch2,'DIK_DOCANE')
Aadd(aVisEnch2,'DIK_CPO018')
Aadd(aVisEnch2,'DIK_DADIAF')
Aadd(aVisEnch2,'DIK_CPO019')
Aadd(aVisEnch2,'DIK_VALFEX')
Aadd(aVisEnch2,'DIK_CPO020')
Aadd(aVisEnch2,'DIK_VALRBE')
Aadd(aVisEnch2,'DIK_CPO021')
Aadd(aVisEnch2,'DIK_NOMREM')
Aadd(aVisEnch2,'DIK_CPO022')
Aadd(aVisEnch2,'DIK_DADDCL')
Aadd(aVisEnch2,'DIK_CODADU')
Aadd(aVisEnch2,'DIK_ADUANA')

If nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx == 7 .Or. nOpcx == 8 //--Incluir/Alterar/Regerar/Copia
	aAltEnch2 := AClone(aVisEnch2)
EndIf	

//-- Enchoice 03
Aadd(aVisEnch3,'DIK_FILCFS')
Aadd(aVisEnch3,'DIK_NUMSOL')
Aadd(aVisEnch3,'DIK_SERTMS')
Aadd(aVisEnch3,'DIK_DESSVT')
Aadd(aVisEnch3,'DIK_DEVFRE')
Aadd(aVisEnch3,'DIK_TIPFRE')
Aadd(aVisEnch3,'DIK_CLIDEV')
Aadd(aVisEnch3,'DIK_LOJDEV')
Aadd(aVisEnch3,'DIK_NOMDEV')
Aadd(aVisEnch3,'DIK_SERVIC')
Aadd(aVisEnch3,'DIK_DESSER')
Aadd(aVisEnch3,'DIK_SELORI')
Aadd(aVisEnch3,'DIK_CDRORI')
Aadd(aVisEnch3,'DIK_REGORI')
Aadd(aVisEnch3,'DIK_CDRDES')
Aadd(aVisEnch3,'DIK_REGDES')
Aadd(aVisEnch3,'DIK_CDRCAL')
Aadd(aVisEnch3,'DIK_REGCAL')
Aadd(aVisEnch3,'DIK_ROTA'  )
Aadd(aVisEnch3,'DIK_DESROT')
Aadd(aVisEnch3,'DIK_VALSEG')
Aadd(aVisEnch3,'DIK_MOEDA' )
If lTMSCFec
	Aadd(aVisEnch3,'DIK_DATCOL')
	Aadd(aVisEnch3,'DIK_HORCOL')
EndIf
Aadd(aVisEnch3,'DIK_CODNEG')
Aadd(aVisEnch3,'DIK_DESNEG')
If (nOpcx == 2 .And. DIK->DIK_STATUS == '9') .Or. (nOpcx == 6 .And. !Empty(DIK->DIK_DOC))
	Aadd(aVisEnch3,'DIK_DATCAN')
	Aadd(aVisEnch3,'DIK_OBSCAN')
EndIf
If nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx == 7 .Or. nOpcx == 8 //--Incluir/Alterar/Regerar/Copia
	aAltEnch3 := AClone(aVisEnch3)
ElseIf nOpcx == 6
   M->DIK_DATCAN := dDataBase
	Aadd(aAltEnch3,'DIK_DATCAN')
	Aadd(aAltEnch3,'DIK_OBSCAN')
EndIf	


//-- Ponto de Entrada que permite a inclusao de campos na Enchoice 3- Dados Complementares
If lTMAI70CPO
	aCpos := ExecBlock("TMAI70CPO",.F.,.F.)
	For nCntFor := 1 To Len( aCpos )
		AAdd(aAltEnch3,aCpos[nCntFor])         
	Next nCntFor          
	// Identifica se existe algum campo criado pelo usuario e nao exibe na enchoice 1 e 2
	AAdd(aVisEnch1,'NOUSER')
	AAdd(aVisEnch2,'NOUSER')
EndIf
//-- Composicao do Frete CIF/FOB
aHeader   := {}
aCols     := {}
Aadd(aNoFields,'DIA_FILORI')
Aadd(aNoFields,'DIA_LOTNFC')
Aadd(aNoFields,'DIA_FILDOC')
Aadd(aNoFields,'DIA_DOC'   )
Aadd(aNoFields,'DIA_SERIE' )

If !Empty(M->DIK_DOC)
	TMSFillGetDados( nOpcx,;
   	              'DIA',;
  	   	           2    ,;
	     	           xFilial('DIA')+M->DIK_FILDOC+M->DIK_DOC+M->DIK_SERIE,;
   	     	        { || DIA->(DIA_FILIAL+DIA_FILDOC+DIA_DOC+DIA_SERIE) },;
						  { || .T. },;
						  aNoFields ,;
					  	  aYesFields )
					  	  
	DIA->(dbSetOrder(2))
	If DIA->(!dbSeek(xFilial('DIA')+M->DIK_FILDOC+M->DIK_DOC+M->DIK_SERIE))
		cQuery := " SELECT DT8_CODPAS, SUM(DT8_VALTOT) DT8_VALTOT "
		cQuery += "   FROM " + RetSqlName("DT8")
		cQuery += "  WHERE DT8_FILIAL = '"+xFilial("DT8")+"'"
		cQuery += " 	AND DT8_FILDOC = '"+M->DIK_FILDOC+"'"
		cQuery += " 	AND DT8_DOC    = '"+M->DIK_DOC+"'"
		cQuery += " 	AND DT8_SERIE  = '"+M->DIK_SERIE+"'"
		cQuery += "  GROUP BY DT8_CODPAS"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		TcSetField(cAliasQry,"DT8_VALTOT","N",TamSX3('DT8_VALTOT')[1],TamSX3('DT8_VALTOT')[2])
		While (cAliasQry)->(!Eof())
			If nCnt > 1
				//-- Inclui nova linha no aCols
				TMSA210Cols()
			EndIf
			If (cAliasQry)->DT8_CODPAS == 'TF'
				__nTotFrt := (cAliasQry)->DT8_VALTOT
				__lAtzFrt := .T.
			EndIf				
			GDFieldPut('DIA_CODPAS',(cAliasQry)->DT8_CODPAS,nCnt)
			GDFieldPut('DIA_DESPAS',Posicione('DT3',1,xFilial('DT3')+(cAliasQry)->DT8_CODPAS,'DT3_DESCRI'),nCnt)
			If M->DIK_TIPFRE == '1' //-- CIF
				GDFieldPut('DIA_PERCIF',100,nCnt)
				GDFieldPut('DIA_VALCIF',(cAliasQry)->DT8_VALTOT,nCnt)
			Else				
				GDFieldPut('DIA_PERFOB',100,nCnt)
				GDFieldPut('DIA_VALFOB',(cAliasQry)->DT8_VALTOT,nCnt)
			EndIf
			nCnt += 1
			(cAliasQry)->(dbSkip())
		EndDo			
		(cAliasQry)->(dbCloseArea())
		dbSelectArea('DIK')
	EndIf
	//-- Retorna composicao do frete para o campo 15
	TMAI70Cmp()
Else
	TMSFillGetDados( nOpcx,;
   	              'DIA',;
  	   	           1    ,;
	     	           xFilial('DIA')+M->DIK_FILORI+M->DIK_LOTNFC,;
   	     	        { || DIA->(DIA_FILIAL+DIA_FILORI+DIA_LOTNFC) },;
						  { || .T. },;
						  aNoFields ,;
					  	  aYesFields )
EndIf					  	  
	   
nSeek   := Ascan(aCols,{|x| !x[Len(x)] .And. x[GdFieldPos('DIA_CODPAS')] = "TF" })
If nSeek > 0
	GDFieldPut('DIA_DESPAS',"Total do Frete",nSeek)
EndIf					
							  	  
aHeaderDIA := AClone(aHeader)
aColsDIA   := AClone(aCols)
If nOpcx != 3
	If Empty(M->DIK_DOC)
		DIA->(dbSetOrder(1))
		__lAtzFrt := DIA->(dbSeek(xFilial('DIA')+M->DIK_FILORI+M->DIK_LOTNFC+'TF'))
		If __lAtzFrt
			__nTotFrt := DIA->DIA_VALCIF+DIA->DIA_VALFOB
		EndIf
	ElseIf !__lAtzFrt
		cQuery := " SELECT SUM(DT8_VALTOT) DT8_VALTOT "
		cQuery += "   FROM " + RetSqlName("DT8")
		cQuery += "  WHERE DT8_FILIAL = '"+xFilial("DT8")+"'"
		cQuery += " 	AND DT8_FILDOC = '"+M->DIK_FILDOC+"'"
		cQuery += " 	AND DT8_DOC    = '"+M->DIK_DOC+"'"
		cQuery += " 	AND DT8_SERIE  = '"+M->DIK_SERIE+"'"
		cQuery += " 	AND DT8_CODPAS = 'TF'"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		TcSetField(cAliasQry,"DT8_VALTOT","N",TamSX3('DT8_VALTOT')[1],TamSX3('DT8_VALTOT')[2])
		If (cAliasQry)->(!Eof())
			__lAtzFrt := .T.
			__nTotFrt := (cAliasQry)->DT8_VALTOT
		EndIf
		(cAliasQry)->(dbCloseArea())
		dbSelectArea('DIK')
	EndIf
EndIf

//-- Frete por pais
DI9->(dbSetOrder(1))
aHeader    := {}
aCols      := {}
aNoFields  := {}
Aadd(aNoFields,'DI9_FILORI')
Aadd(aNoFields,'DI9_LOTNFC')
Aadd(aNoFields,'DI9_FILDOC')
Aadd(aNoFields,'DI9_DOC'   )
Aadd(aNoFields,'DI9_SERIE' )
If !Empty(M->DIK_DOC)
	TMSFillGetDados( nOpcx,;
	                 'DI9',;
   	              2    ,;
      	           xFilial('DI9')+M->DIK_FILDOC+M->DIK_DOC+M->DIK_SERIE,;
	                 { || DI9->(DI9_FILIAL+DI9_FILDOC+DI9_DOC+DI9_SERIE) },;
						  { || .T. },;
						  aNoFields ,;
						  aYesFields )
Else
	TMSFillGetDados( nOpcx,;
	                 'DI9',;
   	              1    ,;
      	           xFilial('DI9')+M->DIK_FILORI+M->DIK_LOTNFC ,;
	                 { || DI9->(DI9_FILIAL+DI9_FILORI+DI9_LOTNFC) },;
						  { || .T. },;
						  aNoFields ,;
						  aYesFields )
EndIf
aHeaderDI9 := AClone(aHeader)
aColsDI9   := AClone(aCols)
  	  
//-- Determina campos que não aparecem na GETDADOS Faturas do CRT
aHeader    := {}
aCols      := {}
aNoFields  := {}
Aadd(aNoFields,'DIN_FILORI')
Aadd(aNoFields,'DIN_LOTNFC')
Aadd(aNoFields,'DIN_FILDOC')
Aadd(aNoFields,'DIN_DOC')
Aadd(aNoFields,'DIN_SERIE')

//-- Configura variaveis da GetDados
If nOpcao == 7 .Or. nOpcao == 8 //--Regerar ou Copiar
	TMSFillGetDados( 4, 'DIN', 1, xFilial( 'DIN' ) + M->DIK_FILORI+M->DIK_LOTNFC, { ||  DIN->(DIN_FILIAL+DIN_FILORI+DIN_LOTNFC) },;
																			 { || .T. }, aNoFields,	aYesFields )
Else
	TMSFillGetDados( nOpcx, 'DIN', 1, xFilial( 'DIN' ) + M->DIK_FILORI+M->DIK_LOTNFC, { ||  DIN->(DIN_FILIAL+DIN_FILORI+DIN_LOTNFC) },;
																			 { || .T. }, aNoFields,	aYesFields )
EndIf
	
If nOpcx == 4 .Or. nOpcx == 8     //nOpcx == 7  , regerar deve liberar
	nNumLinhas := Len(aCols)
EndIf	

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 020, .T., .T. } )
AAdd( aObjects, { 100, 070, .T., .T. } )
AAdd( aObjects, { 100, 010, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL OF oMainWnd

	oFolder:= TFolder():New(13,,{STR0067,STR0068,STR0069},{STR0067,STR0068,STR0069},oDlg,,,,.T.,.F.,oDlg:nWidth,oDlg:nHeight) //"&Fatura"###"&Dados do C R T"###"Dados &Complementares"###"&Fatura"###"&Dados do C R T"###"Dados &Complementares"
	oFolder:bSetOption := {|| TMAI70Fol(oFolder:nOption)}
	oFolder:Align:= CONTROL_ALIGN_ALLCLIENT
	
	//-- Monta a enchoice 1.
	If nOpcao == 7 .Or. nOpcao == 8 //--Regerar ou Copiar
		oTmsEnch1:= MsMGet():New( cAlias, nReg ,3,,,,aVisEnch1,aTmsPosObj[1],aAltEnch1,,,,,oFolder:aDialogs[1])
	Else
		oTmsEnch1:= MsMGet():New( cAlias, nReg ,Iif(nOpcx == 5,4,nOpcx),,,,aVisEnch1,aTmsPosObj[1],aAltEnch1,,,,,oFolder:aDialogs[1], , .T.)
	EndIf
	
	//--       MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	If nOpcao == 7 .Or. nOpcao == 8 //--Regerar ou Copiar
		oGetD:= MSGetDados():New(aTmsPosObj[ 2, 1 ], aTmsPosObj[ 2, 2 ],aTmsPosObj[ 2, 3 ], aTmsPosObj[ 2, 4 ], 3,"TMAI70LOk(1)","TMAI70TOk(1)",,.T.,nil,nil,nil,nNumLinhas,,,,,oFolder:aDialogs[1])					
	Else
		oGetD:= MSGetDados():New(aTmsPosObj[ 2, 1 ], aTmsPosObj[ 2, 2 ],aTmsPosObj[ 2, 3 ], aTmsPosObj[ 2, 4 ], nOpcx,"TMAI70LOk(1)","TMAI70TOk(1)",,.T.,nil,nil,nil,nNumLinhas,,,,,oFolder:aDialogs[1])
	EndIf
	
	
	oGetD:oBrowse:SetFocus()
	If nOpcx == 4	
		oGetD:oBrowse:bDelete := { || .F. }     // Nao Permite a deletar Linhas
	EndIf		

	//-- Monta a enchoice 2.
	aTela := {}
	aGets := {}
	
	If nOpcao == 7 .Or. nOpcao == 8 //--Regerar ou Copiar
		oTmsEnch2:= MsMGet():New( cAlias, nReg, 3,,,,aVisEnch2,aTmsPosObj[1],aAltEnch2,,,,,oFolder:aDialogs[2])
	Else
		oTmsEnch2:= MsMGet():New( cAlias, nReg, Iif(nOpcx == 5,4,nOpcx),,,,aVisEnch2,aTmsPosObj[1],aAltEnch2,,,,,oFolder:aDialogs[2], , .T.)
	EndIf
	
	oTmsEnch2:oBox:Align:= CONTROL_ALIGN_ALLCLIENT
	
	//-- Muda o fonte dos gets de campo Memo
	For nI := 1 To Len(oTmsEnch2:aEntryCtrls)
		If oTmsEnch2:aEntryCtrls[nI]:ClassName() == "TMULTIGET"
			oTmsEnch2:aEntryCtrls[nI]:oFont := oFont
		EndIf
	Next nI
	
	//-- Monta a enchoice 3.
	aTela := {}
	aGets := {}
	
	If nOpcao == 7 .Or. nOpcao == 8 //--Regerar ou Copiar
		oTmsEnch3:= MsMGet():New( cAlias, nReg, 3,,,,aVisEnch3,aTmsPosObj[1],aAltEnch3,,,,,oFolder:aDialogs[3])
	Else
		oTmsEnch3:= MsMGet():New( cAlias, nReg, Iif(nOpcx == 5,4,nOpcx),,,,aVisEnch3,aTmsPosObj[1],aAltEnch3,,,,,oFolder:aDialogs[3], , .T.)
	EndIf
	
	oTmsEnch3:oBox:Align:= CONTROL_ALIGN_ALLCLIENT
	//-- Muda o fonte dos gets de campo Memo
	For nI := 1 To Len(oTmsEnch3:aEntryCtrls)
		If oTmsEnch3:aEntryCtrls[nI]:ClassName() == "TMULTIGET"
			oTmsEnch3:aEntryCtrls[nI]:oFont := oFont
		EndIf
	Next nI
	
If nOpcx == 3 .Or. nOpcx == 4	.Or. nOpcx == 6 .Or. nOpcx == 7 .Or. nOpcx == 8
	
	If nOpcx == 7 //--Regerar
		//--No regerar preciso de alguns dados anteriores, pois pode alterar campos chave (Numero da nota, Produto, entre outros).
		aColsAnt := aClone(aCols)
		aHeadAnt := aClone(aHeader)
	EndIf
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,{|| Iif(Obrigatorio(oTmsEnch1:aGets,oTmsEnch1:aTela) .And. ;
																			   Obrigatorio(oTmsEnch2:aGets,oTmsEnch2:aTela) .And. ;
																			   Obrigatorio(oTmsEnch3:aGets,oTmsEnch3:aTela) .And. oGetD:TudoOk(),;
																			  (nOpcA := 1, oDlg:End()),'') },{|| nOpcA := 0, oDlg:End() },, aButtons) 
Else
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,{|| nOpcA := 1,oDlg:End() },{|| nOpcA := 0, oDlg:End() },, aButtons) 
EndIf                                                    

If lRet .And. nOpcA <> 0 .And. nOpcx != 2
	lRet := TMAI70LOk()
EndIf

If nOpcx != 2 .And. nOpcA == 1 .And. lRet
	TMAI70Grv(nOpcx,aColsAnt,aHeadAnt)
EndIf

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

RestArea(aAreaDT6)

Return nOpcA

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70LOk ³ Autor ³ Richard Anderson     ³ Data ³19.11.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de digitacao de linha                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAI70                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAI70LOk(nGetD)

Local lRet     := .T.
Local nSeek    := 0
Local cCodPro  := '' 
Local aAreaDTC := {}
Local cChave   := ""
Local cSeekDTC := ""

Default nGetD   := 1

//-- Nao avalia linhas deletadas.
If	!GDDeleted( n )
   If lRet := MaCheckCols(aHeader,aCols,n)
      If nGetD == 1
		   //-- Analisa se ha itens duplicados na GetDados.
		   lRet  := GDCheckKey( { 'DIN_NUMNFC', 'DIN_SERFNC', 'DIN_CODPRO' }, 4 )
		   If lRet
				cCodPro := GDFieldGet('DIN_CODPRO',n)
				nSeek   := Ascan(aCols,{|x| !x[Len(x)] .And. x[GdFieldPos('DIN_CODPRO')] <> cCodPro })
				If nSeek > 0 .And. nSeek <> n
					MsgAlert(STR0029) //-- "Não é permitido informar produtos diferentes para o transporte Internacional!"
					lRet := .F.
				EndIf
			EndIf
			//--Para validar o DIN, e necessario ter o cliente remetente informado, nao existe documento ou lote neste momento
			//--E necessario validar na Inclusao e na Copia
			If !Empty(M->DIK_CLIREM) .And. !Empty(M->DIK_LOJREM) .And. (Inclui .Or. nOpcao == 8)
				cChave := GDFieldGet('DIN_NUMNFC',n)+GDFieldGet('DIN_SERNFC',n)+M->DIK_CLIREM+M->DIK_LOJREM+GdFieldGet('DIN_CODPRO',n)
				If lRet .And. !Empty(cChave)
					DTC->(dbSetOrder(2))
					aAreaDTC := DTC->(GetArea())
					If DTC->( dbSeek( cSeekDTC := xFilial('DTC')+ cChave)) 
			      	Do While !DTC->(Eof()) .And. DTC->(DTC_FILIAL+DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM+DTC_CODPRO) == cSeekDTC
				      	If DTC->DTC_FILORI == cFilAnt
								MsgAlert(STR0077) //--"Nota Fiscal ja cadastrada"
								lRet := .F.
							EndIf	
							DTC->(dbSkip())
						EndDo	
					EndIf	           
					RestArea(aAreaDTC)
				EndIf
			EndIf
		EndIf		   
	EndIf   
EndIf

If Len(AllTrim(M->DIK_DADIAF)) > 240 .Or. MLCount(M->DIK_DADIAF,80) > 3
	MsgAlert("Campo Instruções Alfândega deve ser menor que 240 caracteres e 3 linhas.")
	lRet := .F.
EndIf 

If lRet .And. (Len(Trim(M->DIK_DOCANE)) > 400 .Or. MLCount(M->DIK_DOCANE,80) > 5)
	MsgAlert("Campo Dados Doc.Anexo deve ser menor que 400 posições e 5 linhas.")
	lRet := .F.
EndIf 

If lRet .And. (Len(AllTrim(M->DIK_DADREM)) > 400 .Or. MLCount(M->DIK_DADREM,80) > 5)
	MsgAlert("Campo Dados Remetente deve ser menor que 400 posições e 5 linhas.")
	lRet := .F.
EndIf 

If lRet .And. (Len(Trim(M->DIK_DADCON)) > 400 .Or. MLCount(M->DIK_DADCON,80) > 5)
	MsgAlert("Campo Dados Consignatário deve ser menor que 400 posições e 5 linhas.")
	lRet := .F.
EndIf 

If lRet .And. (Len(Trim(M->DIK_DADDES)) > 400 .Or. MLCount(M->DIK_DADDES,80) > 5)
	MsgAlert("Campo Dados Destinatário deve ser menor que 400 posições e 5 linhas.")
	lRet := .F.
EndIf 

If lRet .And. (Len(Trim(M->DIK_DADNOT)) > 400 .Or. MLCount(M->DIK_DADNOT,80) > 5)
	MsgAlert("Campo Dados Doc.Anexo deve ser menor que 400 posições e 5 linhas.")
	lRet := .F.
EndIf 

If lRet .And. (Len(Trim(M->DIK_DADMER)) > 960 .Or. MLCount(M->DIK_DADMER,80) > 12)
	MsgAlert("Campo Dados da Mercadoria deve ser menor que 960 posições e 12 linhas.")
	lRet := .F.
EndIf

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70TOk³ Autor ³ Richard Anderson      ³ Data ³19.11.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de confirmacao para gravacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAI70                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAI70TOk(nGetD)

Local lRet     := .T.
Local nPPerc   := 0
Local nTPerc   := 0
Local cNumNFC  := ''
Local cSerNFC  := ''
Local cCodPro  := ''
Local cSeek    := ''
Local nI       := 0
Local nPCodPas := 0
Local nPValCIF := 0
Local aFrtPais := {}
Local lTMI70TOK := ExistBlock("TMI70TOK",.F.,.F.)

Default nGetD   := 1

//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet  
	If nGetD == 1
		lRet := oGetD:ChkObrigat( n )
	Else		
		lRet := oGetDI9:ChkObrigat( n ) .And. oGetDIA:ChkObrigat( n )
	EndIf		
EndIf

//-- Analisa o linha ok.
If lRet
	lRet := TMAI70LOk(nGetD)
EndIf

//-- Analisa se todas os itens da GetDados estao deletados.
If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
	Help( ' ', 1, 'OBRIGAT2') //Um ou alguns campos obrigatorios nao foram preenchidos no Browse.
	lRet := .F.
EndIf

If lRet 
	If nGetD == 1
		If Inclui
			aFrtPais := TMSFrtPais(M->DIK_ROTA,M->DIK_INCOTE)
			If Len(aFrtPais) == 0
				MsgAlert(STR0078 +CHR(13)+CHR(10)+ STR0079) //--"Cadastrar o Percentual de Frete por País," ## "antes de prosseguir com o cálculo."
				lRet := .F.
			EndIf
		   If lRet
				DTC->(dbSetOrder(2))
				For nI := 1 To Len(aCols)
					cNumNFC := GdFieldGet('DIN_NUMNFC',nI)
					cSerNFC := GdFieldGet('DIN_SERNFC',nI)		   		   
					cCodPro := GdFieldGet('DIN_CODPRO',nI)
				   If DTC->( MsSeek( cSeek := xFilial('DTC')+cNumNFC+cSerNFC+M->DIK_CLIREM+M->DIK_LOJREM+cCodPro )) 
				      While DTC->(!Eof()) .And. DTC->(DTC_FILIAL+DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM+DTC_CODPRO) == cSeek
					      If DTC->DTC_FILORI == cFilAnt
					      	MsgAlert(STR0030+AllTrim(cNumNFC)+STR0031+AllTrim(cCodPro)+STR0032) //-- "Documento de transporte ", " com o produto ", " já cadastrado!"
		                  lRet := .F.
		                  Exit
							EndIf	                      
							DTC->(dbSkip())
						EndDo	
					EndIf
					If !lRet
						Exit
					EndIf	
				Next nI
			EndIf
		EndIf			
		If lRet				           
			//-- Atualiza os totais
			TMAI70Tot()
			If !__lAtzFrt
				lRet := TMAI70Atz()
				If lRet
					TMAI70Dcl()
				EndIf
			EndIf
		EndIf
	ElseIf nGetD == 2
		aAtuHeader := Iif(Type('aHeader') == 'A',aHeader,{})
		aAtuCols   := Iif(Type('aCols')   == 'A',aCols  ,{})
		If nControGD == 2
			aHeader := AClone(aSvHeader[1])
			aCols	  := AClone(aSvCols[1])
		EndIf			
		If (M->DIK_INCOTE == 'DAF' .Or. M->DIK_INCOTE == 'DDU')
			nPCodPas:= GDFieldPos('DIA_CODPAS')
			nPValCIF:= GDFieldPos('DIA_VALCIF')
			If Ascan(aCols,{ | e | e[nPCodPas] == 'TF' .And. e[nPValCIF] == 0}) > 0
				MsgAlert(STR0034) //-- "Total do frete CIF não pode ser zero!"
				lRet := .F.
			EndIf
		EndIf			
		If nControGD == 1
			aHeader := AClone(aSvHeader[2])
			aCols	  := AClone(aSvCols[2])
		Else
			aHeader := AClone(aAtuHeader)
			aCols	  := AClone(aAtuCols)
		EndIf			
		nPPerc  := GDFieldPos('DI9_PERFRE')
		If Ascan(aCols,{ | e | e[nPPerc] != 0 }) > 0                                                                                                 
			Aeval(aCols,{ | e | nTPerc += e[nPPerc] })
			If nTPerc <> 100
				MsgAlert(STR0035) //-- "Percentual total do frete por pais diferente de 100%"
				lRet := .F.
			EndIf
		EndIf	
		aHeader := AClone(aAtuHeader)
		aCols	  := AClone(aAtuCols)
	EndIf	
EndIf	

//-- Ponto de entrada para efetuar validacoes na funcao TudoOK.
If lRet .And. lTMI70TOK
	lRet := ExecBlock("TMI70TOK",.F.,.F.)
	If ValType(lRet) <> "L"
		lRet := .T.
	EndIf
EndIf
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70Tot³ Autor ³ Richard Anderson      ³ Data ³19.11.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Somatoria dos totais                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAI70                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAI70Tot()

Local nI       := 0
Local nPValor  := GDFieldPos('DIN_VALOR' )
Local nPPeso   := GDFieldPos('DIN_PESO'  )
Local nPPesoM3 := GDFieldPos('DIN_PESOM3')
Local nPPesLiq := GDFieldPos('DIN_PESLIQ')
Local nPMetro3 := GDFieldPos('DIN_METRO3')
Local	nTPeso   := 0
Local	nTPesoM3 := 0
Local	nTPesLiq := 0
Local nTValor  := 0
Local nTMetro3 := 0

For nI := 1 To Len(aCols)
	If	!GDDeleted( nI )                                                  
		nTValor  += Iif(nPValor  > 0,aCols[nI,nPValor] ,0)
		nTPeso   += Iif(nPPeso   > 0,aCols[nI,nPPeso]  ,0)
		nTPesoM3 += Iif(nPPesoM3 > 0,aCols[nI,nPPesoM3],0)
		nTPesLiq += Iif(nPPesLiq > 0,aCols[nI,nPPesLiq],0)
		nTMetro3 += Iif(nPMetro3 > 0,aCols[nI,nPMetro3],0)
	EndIf
Next nI

If Type('M->DIK_VALOR' ) != 'U'
	M->DIK_VALOR  := nTValor
EndIf
	
If Type('M->DIK_PESO'  ) != 'U'
	M->DIK_PESO   := nTPeso
EndIf

If Type('M->DIK_PESOM3') != 'U'
	M->DIK_PESOM3 := nTPesoM3
EndIf

If Type('M->DIK_PESLIQ') != 'U'
	M->DIK_PESLIQ := nTPesLiq
EndIf
	
If Type('M->DIK_METRO3') != 'U'
	M->DIK_METRO3 := nTMetro3
EndIf	

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70Vld³ Autor ³ Richard Anderson      ³ Data ³22/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida antes de editar o campo.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI70Vld(cCampo)

//-- Gerais
Local   lRet     := .T.
Local   aAreaSA1 := SA1->(GetArea())
Local   aAreaSB1 := SB1->(GetArea())
Local   aAreaDC5 := DC5->(GetArea())
Local   nSeek    := 0
Local   nI       := 0
Local   cDados   := ''
Local   aDadCli  := {}
Local   aDadIAF  := {}
Local   cTipTra  := '4' //-- Rodoviario Internacional
Local   nPos     := 0
Local   cFilDT5  := xFilial('DT5')
Local   cSeek    := ''
Local   cQuery   := ''
Local   cStatus  := ''
Local   cAliasQry:= ''
Local  aItContrat:= {}
//-- Composição do Frete
Local	nValCIF  := 0
Local   nValFOB  := 0
Local   nPerCIF  := 0
Local   nPerFOB  := 0
Local   nPCodPas := 0
Local   nPValCIF := 0
Local   nPValFOB := 0                                
Local   nPValTot := 0
Local   nTValTot := 0
Local   nTF      := 0
Local   nTotPas  := 0
Local   nSalFrt  := 0
Local   cTipFre  := ""
//-- Valores Default
Default cCampo   := AllTrim(ReadVar())

If cCampo $ 'M->DIN_CODPRO'
	SB1->(dbSetOrder(1))
	If SB1->(!dbSeek(xFilial('SB1')+M->DIN_CODPRO))
		Help('',1,'REGNOIS')
		lRet := .F.
	Else
		GDFieldPut('DIN_DESPRO',SB1->B1_DESC)
	EndIf
	
ElseIf cCampo $ 'M->DIN_CODEMB'
	lRet := ExistCpo('SX5','MG'+M->DIN_CODEMB,1)
	If lRet
		GDFieldPut('DIN_DESEMB',Tabela('MG',M->DIN_CODEMB,.F.))
	EndIf
	
ElseIf cCampo $ 'M->DIN_EMINFC'
	lRet := M->DIN_EMINFC <= dDataBase

ElseIf cCampo $ 'M->DIN_PESO'
	lRet := Positivo()
	If lRet
		lRet := M->DIN_PESO >= GDFieldGet('DIN_PESLIQ')
	EndIf		
	If __lAtzFrt
		__lAtzFrt := .F.
	EndIf

ElseIf cCampo $ 'M->DIN_PESLIQ'
	lRet := Positivo()
	If lRet
		lRet := M->DIN_PESLIQ <= GDFieldGet('DIN_PESO')
	EndIf		

ElseIf cCampo $ 'M->DIN_QTDVOL;M->DIN_METRO3'
	lRet := Positivo()

ElseIf cCampo $ 'M->DIN_VALOR'
	lRet := Positivo()
	If __lAtzFrt
		__lAtzFrt := .F.
	EndIf

ElseIf cCampo $ 'M->DIK_DATENT'
	lRet := M->DIK_DATENT <= dDataBase
	
ElseIf cCampo $ 'M->DIK_CLIREM.M->DIK_LOJREM'
	If !Empty(M->DIK_CLIREM) .And. !Empty(M->DIK_LOJREM)
		If !TMSVldCli(M->DIK_CLIREM,M->DIK_LOJREM) //-- Valida se o Codigo Informado e' de Cliente Generico
			lRet := .F.
		EndIf
		If lRet
			lRet := ExistCpo('SA1',M->DIK_CLIREM+M->DIK_LOJREM,1)
			If lRet
				aDadCli:= TMSDadCli(M->DIK_CLIREM,M->DIK_LOJREM,1)
				cDados := ''
				For nI := 1 To Len(aDadCli)
					cDados += aDadCli[nI]+Chr(13)+Chr(10)
				Next nI
				M->DIK_NOMREM := Posicione('SA1',1,xFilial('SA1')+M->DIK_CLIREM+M->DIK_LOJREM,'A1_NOME')
				M->DIK_DADREM := cDados
				M->DIK_LCPAIS := Padr(TMSDadReg(M->DIK_CDRORI),Len(M->DIK_LCPAIS))
				M->DIK_LCMERC := Padr(TMSDadLMe(M->DIK_DATENT,M->DIK_FILCFS,M->DIK_NUMSOL,M->DIK_CLIREM,M->DIK_LOJREM),Len(M->DIK_LCMERC))
				If M->DIK_DEVFRE == '1' //-- Remetente
					M->DIK_CLIDEV := M->DIK_CLIREM
					M->DIK_LOJDEV := M->DIK_LOJREM
					M->DIK_NOMDEV := SA1->A1_NOME
				EndIf
				If (nPos := Ascan(aCRTCamp,{ | e | e[1] == 'DIK_DADREM' })) == 0
					Aadd(aCRTCamp,{'DIK_DADREM','01',.F.,cDados})
				Else
					aCRTCamp[nPos,3] := .F.
					aCRTCamp[nPos,4] := cDados
				EndIf
			EndIf
		EndIf
	Else	
		M->DIK_NOMREM := CriaVar('DIK_NOMREM', .F.)
		M->DIK_DADREM := CriaVar('DIK_DADREM', .F.)
	EndIf
	
ElseIf cCampo $ 'M->DIK_CLIDES.M->DIK_LOJDES'
	If !Empty(M->DIK_CLIDES) .And. !Empty(M->DIK_LOJDES)
		If !TMSVldCli(M->DIK_CLIDES,M->DIK_LOJDES) //-- Valida se o Codigo Informado e' de Cliente Generico
			lRet := .F.
		EndIf
		If lRet
			lRet := ExistCpo('SA1',M->DIK_CLIDES+M->DIK_LOJDES,1)
			If lRet
				aDadCli:= TMSDadCli(M->DIK_CLIDES,M->DIK_LOJDES,2)
				cDados := ''
				For nI := 1 To Len(aDadCli)
					cDados += aDadCli[nI]+Chr(13)+Chr(10)
				Next nI
				M->DIK_DADDES := cDados
				M->DIK_CDRDES := Posicione('SA1',1,xFilial('SA1')+M->DIK_CLIDES+M->DIK_LOJDES,'A1_CDRDES')
				M->DIK_REGDES := Posicione('DUY',1,xFilial('DUY')+M->DIK_CDRDES,'DUY_DESCRI')
				M->DIK_LCENTR := Padr(TMSDadLEt(M->DIK_CLIDES,M->DIK_LOJDES),Len(M->DIK_LCENTR))
				If M->DIK_DEVFRE == '2' //-- Destinatario
					M->DIK_CLIDEV := M->DIK_CLIDES
					M->DIK_LOJDEV := M->DIK_LOJDES
					M->DIK_NOMDEV := SA1->A1_NOME
				EndIf					
				If (nPos := Ascan(aCRTCamp,{ | e | e[1] == 'DIK_DADDES' })) == 0
					Aadd(aCRTCamp,{'DIK_DADDES','04',.F.,cDados})
				Else
					aCRTCamp[nPos,3] := .F.
					aCRTCamp[nPos,4] := cDados
				EndIf
				If !TmsChkDTN( M->DIK_SERTMS, cTipTra, M->DIK_CDRDES ) 			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida se a regiao de Destino esta habilitada para o Servico de Transporte³
					//³e Tipo de Transporte Informados.      	                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					M->DIK_CDRDES := CriaVar('DIK_CDRDES',.F.)
					lRet := .F.
				EndIf
			EndIf				
		EndIf
	Else
		M->DIK_DADDES := CriaVar('DIK_DADDES',.F.)
	EndIf
	
ElseIf cCampo $ 'M->DIK_CLICON.M->DIK_LOJCON'
	If !Empty(M->DIK_CLICON) .And. !Empty(M->DIK_LOJCON)
		If !TMSVldCli(M->DIK_CLICON,M->DIK_LOJCON) //-- Valida se o Codigo Informado e' de Cliente Generico
			lRet := .F.
		EndIf
		If lRet
			lRet := ExistCpo('SA1',M->DIK_CLICON+M->DIK_LOJCON,1)
			If lRet
				aDadCli:= TMSDadCli(M->DIK_CLICON,M->DIK_LOJCON,2)
				cDados := ''
				For nI := 1 To Len(aDadCli)
					cDados += aDadCli[nI]+Chr(13)+Chr(10)
				Next nI
				M->DIK_DADCON := cDados
				If M->DIK_DEVFRE == '3' //-- Consignatario
					M->DIK_CLIDEV := M->DIK_CLICON
					M->DIK_LOJDEV := M->DIK_LOJCON
					M->DIK_NOMDEV := SA1->A1_NOME
				EndIf					
				If (nPos := Ascan(aCRTCamp,{ | e | e[1] == 'DIK_DADCON' })) == 0
					Aadd(aCRTCamp,{'DIK_DADCON','06',.F.,cDados})
				Else
					aCRTCamp[nPos,3] := .T.
					aCRTCamp[nPos,4] := cDados
				EndIf
			EndIf				
		EndIf
	Else		
		M->DIK_DADCON := CriaVar('DIK_DADCON', .F.)	
	EndIf
	
ElseIf cCampo $ 'M->DIK_CLINOT.M->DIK_LOJNOT'
	If !Empty(M->DIK_CLINOT) .And. !Empty(M->DIK_LOJNOT)
		If !TMSVldCli(M->DIK_CLINOT,M->DIK_LOJNOT) //-- Valida se o Codigo Informado e' de Cliente Generico
			lRet := .F.
		EndIf
		If lRet
			lRet := ExistCpo('SA1',M->DIK_CLINOT+M->DIK_LOJNOT,1)
			If lRet
				aDadCli:= TMSDadCli(M->DIK_CLINOT,M->DIK_LOJNOT,2)
				cDados := ''
				For nI := 1 To Len(aDadCli)
					cDados += aDadCli[nI]+Chr(13)+Chr(10)
				Next nI
				M->DIK_DADNOT := cDados
				If (nPos := Ascan(aCRTCamp,{ | e | e[1] == 'DIK_DADNOT' })) == 0
					Aadd(aCRTCamp,{'DIK_DADNOT','09',.F.,cDados})
				Else
					aCRTCamp[nPos,3] := .T.
					aCRTCamp[nPos,4] := cDados
				EndIf
			EndIf
		EndIf
	Else		
		M->DIK_DADNOT := CriaVar('DIK_DADNOT',.F.)
	EndIf
	
ElseIf cCampo $ 'M->DIK_CLIDEV.M->DIK_LOJDEV'
	If !Empty(M->DIK_CLIDEV) .And. !Empty(M->DIK_LOJDEV)
		If !TMSVldCli(M->DIK_CLIDEV,M->DIK_LOJDEV) //-- Valida se o Codigo Informado e' de Cliente Generico
			lRet := .F.
		EndIf
		If lRet
			lRet := ExistCpo('SA1',M->DIK_CLIDEV+M->DIK_LOJDEV,1)
			If lRet
				SA1->(dbSetOrder(1))
				If	SA1->(dbSeek(xFilial('SA1')+M->DIK_CLIDEV+M->DIK_LOJDEV))
					M->DIK_NOMDEV := SA1->A1_NOME
				EndIf
				M->DIK_CDRCAL := TMSDestCal( M->DIK_CLIDEV, M->DIK_LOJDEV, M->DIK_CDRDES )
				If Empty(M->DIK_CDRCAL)
					M->DIK_CDRCAL := M->DIK_CDRDES
				EndIf
				M->DIK_REGCAL := Posicione('DUY',1,xFilial('DUY')+M->DIK_CDRCAL,'DUY_DESCRI')
				M->DIK_SERVIC := CriaVar('DIK_SERVIC',.F.)
				M->DIK_DESSER := CriaVar('DIK_DESSER',.F.)
				M->DIK_CODNEG := CriaVar('DIK_CODNEG',.F.)
				M->DIK_DESNEG := CriaVar('DIK_DESNEG',.F.)
						
				If M->DIK_TIPFRE == '3' //-- CIF/FOB
					If M->DIK_DEVFRE == '2' //-- Destinatario
						cTipFre := '2' //-- FOB
					Else
						cTipFre := '1' //-- CIF
					EndIf
				Else
					cTipFre := M->DIK_TIPFRE
				EndIf	
					
				TMSPesqServ('DIK', M->DIK_CLIDEV, M->DIK_LOJDEV, M->DIK_SERTMS, cTipTra, @aItContrat,,; 
								cTipFre,,,,,,,,M->DIK_CDRORI, M->DIK_CDRDES,,,,,,,, M->DIK_CODNEG)

				M->DIK_DESSER := Tabela('L4',M->DIK_SERVIC,.F.)
			EndIf
		EndIf
	EndIf
	
ElseIf cCampo $ 'M->DIK_INCOTE'
	lRet := ExistCpo('SX5','MP'+M->DIK_INCOTE,1)
	If lRet .And. !Empty(M->DIK_DEVFRE) 
		If (M->DIK_INCOTE == 'DAF' .Or. M->DIK_INCOTE == 'DDU')
			M->DIK_TIPFRE := '3'
		Else
			M->DIK_TIPFRE := Iif(M->DIK_DEVFRE == '2','2','1')
		EndIf
	EndIf								
	
ElseIf cCampo $ 'M->DIK_SERTMS'
	If M->DIK_SERTMS == StrZero( 1, Len(DIK->DIK_SERTMS))
		Help("",1, "TMSA05002") //Nesta Opcao não sera possivel utilizar um servico do tipo "Coleta".
		lRet := .F.
	EndIf
	If lRet
		If !TmsChkDTN( M->DIK_SERTMS, cTipTra, M->DIK_CDRORI )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se a regiao de Origem esta habilitada para o Servico de Transporte ³
			//³e Tipo de Transporte Informados.      	                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRet := .F.
		EndIf			
		If lRet .And. !TmsChkDTN( M->DIK_SERTMS, cTipTra, M->DIK_CDRDES ) 			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se a regiao de Destino esta habilitada para o Servico de Transporte³
			//³e Tipo de Transporte Informados.      	                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRet := .F.
		EndIf
	EndIf					

ElseIf cCampo $ 'M->DIK_DEVFRE'
	lRet := Pertence('1235')
	If lRet          
		If __lAtzFrt
			__lAtzFrt := .F.
		EndIf
		If M->DIK_DEVFRE == '1' //-- Remetente
			M->DIK_CLIDEV := M->DIK_CLIREM
			M->DIK_LOJDEV := M->DIK_LOJREM
			M->DIK_TIPFRE := Iif((M->DIK_INCOTE == 'DAF' .Or. M->DIK_INCOTE == 'DDU'),'3','1') //-- CIF
		ElseIf M->DIK_DEVFRE == '2' //-- Destinatario
			M->DIK_CLIDEV := M->DIK_CLIDES
			M->DIK_LOJDEV := M->DIK_LOJDES
			M->DIK_TIPFRE := Iif((M->DIK_INCOTE == 'DAF' .Or. M->DIK_INCOTE == 'DDU'),'3','2') //-- FOB
		ElseIf M->DIK_DEVFRE == '3' //-- Consignatário
			M->DIK_CLIDEV := M->DIK_CLICON
			M->DIK_LOJDEV := M->DIK_LOJCON
			M->DIK_TIPFRE := Iif((M->DIK_INCOTE == 'DAF' .Or. M->DIK_INCOTE == 'DDU'),'3','1') //-- CIF
		ElseIf M->DIK_DEVFRE == '5' //-- Outros
			M->DIK_CLIDEV := CriaVar('DIK_CLIDEV',.F.)
			M->DIK_LOJDEV := CriaVar('DIK_LOJDEV',.F.)
			M->DIK_TIPFRE := Iif((M->DIK_INCOTE == 'DAF' .Or. M->DIK_INCOTE == 'DDU'),'3','1') //-- CIF
		EndIf
		M->DIK_NOMDEV := Posicione('SA1',1,xFilial('SA1')+M->DIK_CLIDEV+M->DIK_LOJDEV,'A1_NOME')			
		If !Empty(M->DIK_CLIDEV)
			M->DIK_CDRCAL := TMSDestCal( M->DIK_CLIDEV, M->DIK_LOJDEV, M->DIK_CDRDES )
			If Empty(M->DIK_CDRCAL)
				M->DIK_CDRCAL := M->DIK_CDRDES
			EndIf
			M->DIK_REGCAL := Posicione('DUY',1,xFilial('DUY')+M->DIK_CDRCAL,'DUY_DESCRI')
			M->DIK_SERVIC := CriaVar('DIK_SERVIC',.F.)
			M->DIK_DESSER := CriaVar('DIK_DESSER',.F.)
			M->DIK_CODNEG := CriaVar('DIK_CODNEG',.F.)
			M->DIK_DESNEG := CriaVar('DIK_DESNEG',.F.)
			
			If M->DIK_TIPFRE == '3' //-- CIF/FOB
				If M->DIK_DEVFRE == '2' //-- Destinatario
					cTipFre := '2' //-- FOB
				Else
					cTipFre := '1' //-- CIF
				EndIf
			Else
				cTipFre := M->DIK_TIPFRE
			EndIf	
			
			TMSPesqServ('DIK', M->DIK_CLIDEV, M->DIK_LOJDEV, M->DIK_SERTMS, cTipTra, @aItContrat,,; 
							cTipFre,,,,,,,,M->DIK_CDRORI,M->DIK_CDRDES,,,,,,,, M->DIK_CODNEG)

			M->DIK_DESSER := Tabela('L4',M->DIK_SERVIC,.F.)
		EndIf
	EndIf		
	
ElseIf cCampo $ 'M->DIK_ROTA'
	DA8->(dbSetOrder(1))
	If DA8->(dbSeek(xFilial('DA8')+M->DIK_ROTA))
		lRet:= TMSRotDes(M->DIK_CDRCAL,M->DIK_ROTA)
		If lRet
			M->DIK_DESROT := DA8->DA8_DESC
		EndIf
	Else
		Help('',1,'REGNOIS')
		lRet := .F.
	EndIf
	If lRet
		//So traz a descricao da primeira vez, depois que o usuario complementou nao pode
		If Empty(M->DIK_DADIAF)
			M->DIK_DADIAF := ''
			aDadIAF:= TMSDadIAF(M->DIK_ROTA)
			For nI := 1 To Len(aDadIAF)
				If !Empty(aDadIAF[nI])
					If nI >= 2
						M->DIK_DADIAF += Chr(13)+Chr(10)
					EndIf
					M->DIK_DADIAF += aDadIAF[nI]
				EndIf	
			Next nI
			If (nPos := Ascan(aCRTCamp,{ | e | e[1] == 'DIK_DADIAF' })) == 0
				Aadd(aCRTCamp,{'DIK_DADIAF','18',.F.,M->DIK_DADIAF})
			Else
				aCRTCamp[nPos,3] := .F.
				aCRTCamp[nPos,4] := M->DIK_DADIAF
			EndIf
		EndIf
			
	EndIf
	
ElseIf cCampo $ 'M->DIK_SERVIC'
	//-- Valida o codigo do servico digitado.
	If !Empty(M->DIK_SERVIC)
		DC5->(dbSetOrder(1))
		If DC5->(!dbSeek(xFilial('DC5')+M->DIK_SERVIC))
			Help('',1,'TMSA04013')	//-- Codigo do servico nao encontrado (DC5). 
			lRet := .F.
	   ElseIf DC5->DC5_DOCTMS == '7' .Or. DC5->DC5_DOCTMS == '8' //Não permite a digitação dos serviços com complemento tipo "7=CTRC Reentrega" e "8=CTRC Complemento"		
			Help('',1,'TMSA05040') // Servico Invalido ...
			lRet := .F.
		EndIf
		If lRet
			nSeek := Ascan(aItContrat, { |x| x[3] == &(ReadVar()) })
			If nSeek == 0
				Help("",1,"TMSA05040") // Servico Invalido ...
				lRet := .F.
			Else
				M->DIK_DESSER := Tabela('L4',M->DIK_SERVIC,.F.)
			EndIf
		EndIf
	EndIf						
	
ElseIf cCampo == 'M->DIK_CDRCAL'	
	lRet := ExistCpo('DUY',M->DIK_CDRCAL,1)
	If lRet
		M->DIK_REGCAL := Posicione('DUY',1,xFilial('DUY')+M->DIK_CDRCAL,'DUY_DESCRI')
	EndIf		
	
ElseIf cCampo == 'M->DI9_PERFRE'
	If M->DI9_PERFRE < 0 .Or. M->DI9_PERFRE > 100
		lRet := .F.
	EndIf
	If lRet		
		GDFieldPut('DI9_VALTOT',((__nTotFrt * M->DI9_PERFRE) / 100))
	EndIf		

ElseIf cCampo == 'M->DI9_VALTOT'
	GDFieldPut('DI9_PERFRE',((M->DI9_VALTOT / __nTotFrt) * 100))
	
ElseIf cCampo $ 'M->DIA_PERCIF;M->DIA_PERFOB;M->DIA_VALCIF;M->DIA_VALFOB'
	If cCampo == 'M->DIA_PERCIF'
		If M->DIA_PERCIF < 0 .Or. M->DIA_PERCIF > 100
			lRet := .F.
		EndIf		
		If lRet 
			nTotPas := GDFieldGet('DIA_VALCIF')+GDFieldGet('DIA_VALFOB')
			nValCIF := (M->DIA_PERCIF * nTotPas) / 100
			nValFOB := nTotPas - nValCIF
			GDFieldPut('DIA_VALCIF',nValCIF)
			GDFieldPut('DIA_VALFOB',nValFOB)
			GDFieldPut('DIA_PERCIF',M->DIA_PERCIF)
			GDFieldPut('DIA_PERFOB',(nValFOB / nTotPas) * 100)
		EndIf			
	ElseIf cCampo == 'M->DIA_PERFOB'
		If M->DIA_PERFOB < 0 .Or. M->DIA_PERFOB > 100
			lRet := .F.
		EndIf		
		If lRet
			If M->DIK_TIPFRE == '3' //-- CIF/FOB
				nTotPas := GDFieldGet('DIA_VALCIF')+GDFieldGet('DIA_VALFOB')
				nValFOB := (M->DIA_PERFOB * nTotPas) / 100
				nValCIF := nTotPas - nValFOB
				GDFieldPut('DIA_VALCIF',nValCIF)
				GDFieldPut('DIA_VALFOB',nValFOB)
				GDFieldPut('DIA_PERCIF',(nValCIF / nTotPas) * 100)
				GDFieldPut('DIA_PERFOB',M->DIA_PERFOB)
			EndIf
		EndIf			
	ElseIf cCampo == 'M->DIA_VALCIF'
		lRet := Positivo()
		If lRet
			If M->DIK_TIPFRE == '3' //-- CIF/FOB - IncoTerm DAF
				nTotPas := M->DIA_VALCIF+GDFieldGet('DIA_VALFOB')
				
				nValCIF := M->DIA_VALCIF
				nValFOB := GDFieldGet('DIA_VALFOB')
				
				//--Usuario digita os valores, e nos calculamos o percentual
				nPerCIF := Round((nValCIF * 100) / nTotPas,2)
				nPerFOB := Round((nValFOB * 100) / nTotPas,2)
			
				GDFieldPut('DIA_PERCIF',nPerCIF)
				GDFieldPut('DIA_PERFOB',nPerFOB)
				
				GDFieldPut('DIA_VALCIF',nValCIF)
				GDFieldPut('DIA_VALFOB',nValFOB)
			Else
				GDFieldPut('DIA_VALCIF',M->DIA_VALCIF)
			EndIf				
		EndIf			                                                         
		
	ElseIf cCampo == 'M->DIA_VALFOB'                                        
		lRet := Positivo()
		If lRet
			If M->DIK_TIPFRE == '3' //-- CIF/FOB - IncoTerm DAF
				nTotPas := M->DIA_VALFOB+GDFieldGet('DIA_VALCIF')
				
				nValCIF := GDFieldGet('DIA_VALCIF')
				nValFOB := M->DIA_VALFOB
				//--Usuario digita os valores, e nos calculamos o percentual
				nPerCIF := Round((nValCIF * 100) / nTotPas,2)
				nPerFOB := Round((nValFOB * 100) / nTotPas,2)

				GDFieldPut('DIA_PERCIF',nPerCIF)
				GDFieldPut('DIA_PERFOB',nPerFOB)
				
				GDFieldPut('DIA_VALCIF',nValCIF)
				GDFieldPut('DIA_VALFOB',nValFOB)
			Else
				GDFieldPut('DIA_VALFOB',M->DIA_VALFOB)
			EndIf
		EndIf			
	EndIf				                                                         
	nValCIF  := 0
	nValFOB  := 0
	nPCodPas := GDFieldPos('DIA_CODPAS')
	nPValCIF := GDFieldPos('DIA_VALCIF')
	nPValFOB := GDFieldPos('DIA_VALFOB')
	
	Aeval(aCols,{ | e | nValCIF += Iif(e[nPCodPas] != "TF",e[nPValCIF],0), nValFOB += Iif(e[nPCodPas] != "TF",e[nPValFOB],0) })
	nTF := Ascan(aCols,{ | e | e[nPCodPas] == "TF" })
	If nTF > 0                        
		GDFieldPut('DIA_VALCIF',nValCIF,nTF)
		GDFieldPut('DIA_VALFOB',nValFOB,nTF)
		If 'TMSAI70' $ FunName()
			__nTotFrt  := nValCIF+nValFOB
			nSalFrt    := __nTotFrt
			aSvCols[1] := AClone(aCols)
			aHeader    := AClone(aSvHeader[2])
			aCols	     := AClone(aSvCols[2])
			For nI := 1 To Len(aCols)
				If nI == Len(aCols)
					GDFieldPut('DI9_VALTOT',nSalFrt,nI)
				Else
					GDFieldPut('DI9_VALTOT',((__nTotFrt * GDFieldGet('DI9_PERFRE',nI)) / 100),nI)
					nSalFrt -= ((__nTotFrt * GDFieldGet('DI9_PERFRE',nI)) / 100)
				EndIf				 				
			Next nI
			aSvCols[2] := AClone(aCols)
			aHeader    := AClone(aSvHeader[1])
			aCols	     := AClone(aSvCols[1])
		EndIf		
	EndIf
	
ElseIf cCampo $ 'M->DIK_NUMSOL'

	DT5->(dbSetOrder(1))           
	If !Empty(M->DIK_FILCFS)		
	   cFilDT5 := IIf(Empty(cFilDT5), cFilDT5, M->DIK_FILCFS)
		cSeek   := cFilDT5+M->DIK_FILCFS+M->DIK_NUMSOL
	Else       
		cSeek   := cFilDT5+M->DIK_FILORI+M->DIK_NUMSOL	
	EndIf					
	If DT5->(MsSeek(cSeek)) 
		If !lTMSCFec
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Nao permite Solicitacao de Coleta com Status diferente de 'Encerrada'    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If DT5->DT5_STATUS <> StrZero(4, Len(DT5->DT5_STATUS)) // Encerrada
		 		Help("",1,"TMSA05045") // So' serao aceitas Solicitacoes de Coleta Encerradas !!!
				lRet := .F.
			EndIf         
		Else
		   cStatus := '1;5;6;9' //-- 1=Em Aberto / 5=Documento Informado / 6=Bloqueada / 9=Cancelado
			If TMI70COL	//-- Valida o Status da Solicitacao de Coleta que nao podera ser utilizado na NF
				cStatus := ExecBlock('TMI70COL',.F.,.F.)
				If ValType(cStatus) <> 'C' 
					cStatus := '1;5;6;9'
				EndIf
			EndIf
		   If DT5->DT5_STATUS $ cStatus
		 		Help("",1,"TMSA05060") // So' serao aceitas Solicitacoes de Coleta com status diferente de 'Em Aberto', 'Documento informado' e 'Cancelado' !!!
				lRet := .F.
			EndIf
		EndIf
	Else
		Help("",1,"REGNOIS")
		lRet := .F. 	
	EndIf	
	   
ElseIf cCampo $ 'M->DIK_DATCOL' .And. !Empty(M->DIK_DATCOL)

	If Empty(M->DIK_NUMSOL)
		Help(" ",1,"TMSA05061") // Somente sera permitido informar a data e hora da coleta quando o campo numero da solicitacao de coleta estiver preenchido.
		lRet := .F.		
	EndIf
	
	If lRet
		DT5->(dbSetOrder(1))
		If !Empty(M->DIK_FILCFS)		
			cFilDT5 := IIf(Empty(cFilDT5), cFilDT5, M->DIK_FILCFS)
			cSeek   := cFilDT5+M->DIK_FILCFS+M->DIK_NUMSOL
		Else       
			cSeek   := cFilDT5+M->DIK_FILORI+M->DIK_NUMSOL		
		EndIf						
		If DT5->(MsSeek(cSeek))		
			DF6->(DbSetOrder(2))
			If DF6->(MsSeek(xFilial('DF6')+DT5->(DT5_FILDOC+DT5_DOC+DT5_SERIE)))
				Help('',1,'TMSA05071') //-- 'Existe conferencia de coleta lancada para esta solicitacao de coleta. A digitacao da data/hora de coleta nao sera permitida.'
				lRet := .F.
			EndIf
		EndIf
	EndIf

	//-- Nao permite informar data/hora de coleta para solicitacao de coleta encerrada.
	DT5->(dbSetOrder(1))
	If !Empty(M->DIK_FILCFS)		
	   cFilDT5 := IIf(Empty(cFilDT5), cFilDT5, M->DIK_FILCFS)
		cSeek   := cFilDT5+M->DIK_FILCFS+M->DIK_NUMSOL
	Else       
		cSeek   := cFilDT5+M->DIK_FILORI+M->DIK_NUMSOL		
	EndIf						
	If lRet .And. DT5->(MsSeek(cSeek))
		If DT5->DT5_STATUS == StrZero(4,Len(DT5->DT5_STATUS)) //-- Encerrada
			Help(" ",1,"TMSA05064") // Nao sera permitido informar a data e hora da coleta quando solicitacao de coleta estiver encerrada.
			lRet := .F.
		EndIf
	EndIf
	If lRet .And. DT5->(MsSeek(cSeek))
		cAliasQry := GetNextAlias()
		cQuery := " SELECT MIN(DTQ_DATGER) DATGER "
		cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
		cQuery += "   JOIN " + RetSqlName("DTQ") + " DTQ "
		cQuery += "     ON  DTQ_FILIAL = '" + xFilial("DTQ") + "' "
		cQuery += "     AND DTQ_FILORI = DUD_FILORI "
		cQuery += "     AND DTQ_VIAGEM = DUD_VIAGEM "
		cQuery += "     AND DTQ.D_E_L_E_T_ = ' ' "
		cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "     AND DUD_FILDOC = '" + DT5->DT5_FILDOC + "' "
		cQuery += "     AND DUD_DOC    = '" + DT5->DT5_DOC    + "' "
		cQuery += "     AND DUD_SERIE  = '" + DT5->DT5_SERIE  + "' "
		cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		TcSetField(cAliasQry,"DATGER","D",8,0)
		If (cAliasQry)->(!Eof()) .And. (cAliasQry)->DATGER > M->DIK_DATCOL
			Help("",1,"TMSA05068")  //-- Data da Coleta inferior a data da viagem
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
	
ElseIf cCampo $ 'M->DIK_SELORI'
	lRet := TMSSelOri("DIK",M->DIK_SELORI,M->DIK_CLIREM,M->DIK_LOJREM,,M->DIK_FILORI,M->DIK_NUMSOL)

ElseIf cCampo $ 'M->DIK_HORCOL' .And. !Empty(M->DIK_HORCOL)
	lRet := AtVldHora(M->DIK_HORCOL)

ElseIf cCampo $ 'M->DIK_CODNEG'

	If M->DIK_TIPFRE == '3' //-- CIF/FOB
		If M->DIK_DEVFRE == '2' //-- Destinatario
			cTipFre := '2' //-- FOB
		Else
			cTipFre := '1' //-- CIF
		EndIf
	Else
		cTipFre := M->DIK_TIPFRE
	EndIf	
	
	If Empty(M->DIK_CODNEG)
		Help(' ',1,'TMSA050A3')	//-- Não é permitido que o código da negociação fique em branco.
		lRet := .F.
	Else
		If !TMSPesqServ('DIK', M->DIK_CLIDEV, M->DIK_LOJDEV, M->DIK_SERTMS, cTipTra, @aItContrat,,; 
							cTipFre,,,,,,,,M->DIK_CDRORI, M->DIK_CDRDES,,,,,,,, M->DIK_CODNEG)
			Help("",1,"TMSAI7002")// Contrato do cliente não foi localizado.
			lRet := .F.
		Endif
	Endif

EndIf
	
RestArea(aAreaSA1)
RestArea(aAreaSB1)
RestArea(aAreaDC5)
		          
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70Whe³ Autor ³ Richard Anderson      ³ Data ³22/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida antes de editar o campo.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI70Whe(cCampo)

Local   lRet    := .T.
Local   cCliGen := GetMV('MV_CLIGEN',,'')

Default cCampo  := AllTrim(ReadVar())
                      
//--Esta validacao so precisa ser realizada dentro deste fonte, na chamada da carta de correcao nao
If 'TMSAI70' $ FunName()
	If nOpcao == 7 .Or. nOpcao == 8 //--Regerar ou Copiar pode alterar todos os campos
		If cCampo $ 'M->DIK_TIPFRE'
			If M->DIK_DEVFRE == '5' //--Outros
				Return .T.
			Else
				Return .F.
			EndIf
		Else
			Return lRet
		EndIf
	EndIf
EndIf

If cCampo $ 'M->DIK_FILCFS;M->DIK_NUMSOL;M->DIK_DATCOL;M->DIK_HORCOL;M->DIK_CLIREM;M->DIK_LOJREM;M->DIK_CLIDES;M->DIK_LOJDES;M->DIK_SERTMS'
	lRet := Inclui

ElseIf cCampo $ 'M->DIK_DEVFRE'
	lRet := !Empty(M->DIK_CLIREM) .And. !Empty(M->DIK_LOJREM) .And. !Empty(M->DIK_CLIDES) .And. ;
	        !Empty(M->DIK_LOJDES) .And. !Empty(M->DIK_INCOTE) .And. Inclui 

ElseIf cCampo $ 'M->DIK_TIPFRE'
	lRet := (M->DIK_DEVFRE == '5') //-- Outros, se for este devedor podera ser alterado o tipo de frete

ElseIf cCampo $ 'M->DIK_CLIDEV;M->DIK_LOJDEV'
	lRet := (M->DIK_DEVFRE == '5') //-- Outros

ElseIf cCampo $ 'M->DIK_CLICON;M->DIK_LOJCON'
	//--Nao permite alterar o Consignatario, se ele for o Pagador do Frete
	lRet := (M->DIK_DEVFRE != '3') //-- Consignatario
	
ElseIf cCampo $ 'M->DIK_CDRCAL'
	lRet := !Empty(M->DIK_CLIDEV) .And. !Empty(M->DIK_LOJDEV)
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao Permite Alterar o Campo se Existir Destino de Calculo definido para o ³
		//³Cliente Devedor e a Regiao de Destino.                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DTH->(dbSetOrder(1))
		If DTH->(dbSeek(xFilial('DTH')+M->DIK_CLIDEV+M->DIK_LOJDEV+M->DIK_CDRDES)) .Or. ;
			DTH->(dbSeek(xFilial('DTH')+cCliGen+M->DIK_CDRDES) )
			lRet := .F.
		EndIf
	EndIf		

ElseIf cCampo $ 'M->DIK_ROTA'
	lRet := !Empty(M->DIK_CDRORI) .And. !Empty(M->DIK_CDRDES) .And. !Empty(M->DIK_CDRCAL)
	
ElseIf cCampo $ 'M->DIK_SERVIC'
	lRet := !Empty(M->DIK_CLIDEV) .And. !Empty(M->DIK_LOJDEV) .And. !Empty(M->DIK_TIPFRE)
	
ElseIf cCampo $ 'M->DIA_PERCIF;M->DIA_PERFOB'
	lRet := .F.

ElseIf cCampo $ 'M->DIA_VALCIF'
	lRet := M->DIK_TIPFRE $ '13'
	If lRet
		lRet := GDFieldGet('DIA_CODPAS') != 'TF'
	EndIf
	
ElseIf cCampo $ 'M->DIA_VALFOB'
	lRet := M->DIK_TIPFRE $ '23'
	If lRet
		lRet := GDFieldGet('DIA_CODPAS') != 'TF'
	EndIf 
	
ElseIf cCampo $ 'M->DIN_NUMNFC;M->DIN_SERNFC;M->DIN_CODPRO'
	lRet := Inclui 

EndIf	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70Ini³ Autor ³ Richard Anderson      ³ Data ³14/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializacao de campos                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAI45                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI70Ini(cCampo)

Local xRet  := ''
Local cPais := ''

If cCampo $ 'M->DIK_CPO001'
	xRet := STR0048 //-- "NOME E ENDEREÇO DO EMETENTE"
ElseIf cCampo $ 'M->DIK_CPO004'
	xRet := STR0049 //-- "NOME E ENDEREÇO DO DESTINATARIO"
ElseIf cCampo $ 'M->DIK_CPO005'
	xRet := STR0050 //-- "LOCALIDADE E PAIS DE EMISSAO"
ElseIf cCampo $ 'M->DIK_CPO006'
	xRet := STR0051 //-- "NOME E ENDEREÇO DO CONSIGNATARIO"
ElseIf cCampo $ 'M->DIK_CPO007'
	xRet := STR0052 //-- "LOCALIDADE DE RESPONSABILIDADE DA MERCADORIA"
ElseIf cCampo $ 'M->DIK_CPO008'
	xRet := STR0053 //-- "LOCALIDADE, PAÍS E PRAZO DE ENTREGA"
ElseIf cCampo $ 'M->DIK_CPO009'
	xRet := STR0054 //-- "NOTIFICAR A"
ElseIf cCampo $ 'M->DIK_CPO011'
	xRet := STR0055 //-- "QUANTIDADE E CATEGORIA DE VOLUMES, MARCAS, NUMEROS"
ElseIf cCampo $ 'M->DIK_CPO012'
	xRet := STR0056 //-- "PESO BRUTO EM Kg"
ElseIf cCampo $ 'M->DIK_CPO013'
	xRet := STR0057 //-- "VOLUME EM m3"
ElseIf cCampo $ 'M->DIK_CPO014'
	xRet := STR0058 //-- "VALOR"
ElseIf cCampo $ 'M->DIK_CPO015'
	xRet := STR0059 //-- "GASTOS A PAGAR - FRETE"
ElseIf cCampo $ 'M->DIK_CPO016'
	xRet := STR0060 //-- "DECLARACAO DO VALOR DAS MERCADORIAS"
ElseIf cCampo $ 'M->DIK_CPO017'
	xRet := STR0061 //-- "DOCUMENTOS ANEXOS"
ElseIf cCampo $ 'M->DIK_CPO018'
	xRet := STR0062 //-- "INSTRUCOES SOBRE FORMALIDADES DE ALFANDEGA"
ElseIf cCampo $ 'M->DIK_CPO019'
	xRet := STR0063 //-- "VALOR DO FRETE EXTERNO"
ElseIf cCampo $ 'M->DIK_CPO020'
	xRet := STR0064 //-- "VALOR DO REEMBOLSO CONTRA ENTREGA"
ElseIf cCampo $ 'M->DIK_CPO021'
	xRet := STR0065 //-- "NOME E ASSINATURA DO REMETENTE"
ElseIf cCampo $ 'M->DIK_CPO022'
	xRet := STR0066 //-- "DECLARAÇÕES E OBSERVAÇÕES"
ElseIf cCampo $ 'M->DIK_VALFRT'
	xRet := Padl('< F5 >',10)
ElseIf cCampo $ 'M->DIK_DOCANE'
	cPais := Posicione('DUY',1,xFilial('DUY')+GetMv('MV_CDRORI',,''),'DUY_PAIS')
	DI3->(dbSetOrder(1))
	If DI3->(dbSeek(xFilial('DI3')+cPais))
		xRet := MSMM(DI3->DI3_CODDCA,80)
	EndIf
EndIf	

Return xRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70Imp³ Autor ³ Richard Anderson      ³ Data ³22/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preparacao para chamada da rotina de impressao do CRT      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAI45                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI70Imp()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70Fol³ Autor ³ Richard Anderson      ³ Data ³19/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação dos Folders                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAI70                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI70Fol(nFolder)

If nFolder == 1
	//-- Atualiza os totais
	TMAI70Tot()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70Atz³ Autor ³ Richard Anderson      ³ Data ³21/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Frete                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAI70                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI70Atz()

Local aAreaAnt	  := GetArea()
Local aMsgErr	  := {}
Local aTipVei	  := {} 
Local aContrt    := {}
Local cTabFre    := ''
Local cTipTab    := ''
Local cSeqTab    := ''
Local cCliDev    := M->DIK_CLIDEV
Local cLojDev    := M->DIK_LOJDEV
Local nFatCub    := 0
Local lAjuste    := .F.
Local cDocTms    := ''
Local lPrcProd   := GetMV('MV_PRCPROD',,.T.) //-- Calcula Preco do Frete por Produto ?
Local cCodPro    := Space(Len(DIN->DIN_CODPRO))
Local nQtdVol	  := 0
Local nQtdUni	  := 0
Local nPeso		  := 0
Local nPesoM3	  := 0
Local nPesLiq	  := 0
Local nValMer	  := 0
Local nBasSeg	  := 0
Local nMetro3    := 0
Local nKm        := 0
Local nCntFor	  := 0
Local cTipTra    := '4' //-- Rodoviario Internacional
Local lTMSCalFre := .F.
Local lCliGen    := .T.
Local nSldFrt    := 0
Local nFrtPais   := 0
Local nCnt       := 0
Local aFrtPais   := {}
Local aFrtDAF    := {}
Local cCodPas    := ''
Local nTotPas    := 0
Local nValCIF    := 0
Local nValFOB    := 0
Local nTF        := 0
Local aSavCols   := Iif(Type('aCols')   == 'A',aCols  ,{})
Local aSavHeader := Iif(Type('aHeader') == 'A',aHeader,{})
Local aNoFields  := {}
Local aYesFields := {}                                                                            
Local nOpcx      := 3
Local	nMoedaTb   := 0
Local cTipFre    := ''
Local aColsCalc  := {}
Local aHeadCalc  := {}

If Empty(M->DIK_CLIDEV) .Or. Empty(M->DIK_SERVIC) .Or. Empty(M->DIK_SERVIC) .Or. Empty(M->DIK_TIPFRE) .Or. Empty(M->DIK_ROTA)
	MsgAlert(STR0036) //-- "Dados complementares não informados!"
	Return(.F.)                                     
EndIf

CursorWait()

If M->DIK_TIPFRE == '3' //-- CIF/FOB
	If M->DIK_DEVFRE == '2' //-- Destinatario
		cTipFre := '2' //-- FOB
	Else
		cTipFre := '1' //-- CIF
	EndIf
Else
	cTipFre := M->DIK_TIPFRE
EndIf	

//-- Localiza contrato do cliente
aContrt := TMSContrat( M->DIK_CLIDEV, M->DIK_LOJDEV,, M->DIK_SERVIC,, cTipFre,,,,,,,,,,,,,,,,M->DIK_CODNEG)

If	!Empty( aContrt )
	nFatCub := aContrt[ 1, 2 ]
	cTabFre := aContrt[ 1, 3 ]
	cTipTab := aContrt[ 1, 4 ]
	//-- Verifica a Abragencia do Contrato quando nao e cliente generico
	If !aContrt[ 1,17 ] 
		If Posicione("AAM",1,xFilial("AAM")+aContrt[ 1, 1 ],"AAM_ABRANG") == "2"
			cLojDev := AAM->AAM_LOJA					
		EndIf
	EndIf
	//-- Verifica se o cliente possue ajuste obrigatorio.	
	lAjuste := Iif(aContrt[1,18]=="1",.T.,.F.)
	nMoedaTb:= Posicione("DTL",1,xFilial("DTL")+cTabFre+cTipTab,"DTL_MOEDA")
	//-- Atualiza Moeda
	If Empty(M->DIK_MOEDA)
		M->DIK_MOEDA := nMoedaTb
	EndIf	
Else
	//-- Inicializa Teclas de Atalhos
	CursorArrow()
	Return(.F.)
EndIf
	
DC5->(dbSetOrder(1))
If	DC5->(dbSeek(xFilial('DC5')+M->DIK_SERVIC))
	cDocTms := DC5->DC5_DOCTMS
Else
	Help(' ', 1, 'TMSA04013', , STR0010 + M->DIK_SERVIC , 4, 1 )	//-- Codigo do servico nao encontrado (DC5).  //'Servico: '
	//-- Inicializa Teclas de Atalhos
	CursorArrow()
	Return(.F.)
EndIf

//-- Calcula a composicao do frete
For nCntFor := 1 To Len(aCols)
	aColsCalc := aClone(aCols)
	aHeadCalc := aClone(aHeader)
	If !GDDeleted( nCntFor ) .And. !Empty(GDFieldGet('DIN_CODPRO',nCntFor))
		nPeso		:= GDFieldGet('DIN_PESO'  ,nCntFor)
		nPesoM3 	:= GDFieldGet('DIN_PESOM3',nCntFor)
		nPesLiq		:= GDFieldGet('DIN_PESLIQ',nCntFor)
		nValMer		:= GDFieldGet('DIN_VALOR' ,nCntFor)
		nMetro3  	:= GDFieldGet('DIN_METRO3',nCntFor)
		nQtdVol     := GDFieldGet('DIN_QTDVOL',nCntFor)
	    cCodPro     := If(lPrcProd, GDFieldGet('DIN_CODPRO',nCntFor),Space(Len(DVF->DVF_CODPRO)))
		lTMSCalFre := .T.
		//-- Calcula a composicao do frete, baseado na tabela de frete especificada no contrato do cliente.
		If lTmsCalFre
			aFrete := {}
			aFrete := TmsCalFret(	cTabFre      	,;
											cTipTab      	,;
											@cSeqTab			,;
											M->DIK_CDRORI	,;
											M->DIK_CDRCAL	,;
											cCliDev			,;                              
											cLojDev			,;
											cCodPro			,;
											M->DIK_SERVIC	,;
											M->DIK_SERTMS	,;
											cTipTra      	,;
											aContrt[ 1, 1 ],;
											aMsgErr			,;
											,;
											xMoeda(nValMer, M->DIK_MOENFC, nMoedaTb),;
											nPeso				,;
											nPesoM3 		   ,;
											0			  		,;
											nQtdVol  		,;
											0	 				,;
											nBasSeg			,;
											nMetro3			,;
											0					,;
											0					,;
											nKm				,;
											0					,;
											.T.				,;
											lCliGen			,;
											lAjuste	 		,;
											0					,;
											nQtdUni 			,;
											0					,;
											0					,;
											0					,;
											aValInf,,,,,,,,,,,,,,,,;
											M->DIK_MOEDA,,,,,,,,,,,,,M->DIK_CODNEG,, )

			nSeek := Ascan( aFrete,{|x| x[3] == 'TF' })
			If	Empty( nSeek ) .Or. Empty( aFrete[ nSeek, 2 ] ) .Or. nSeek != Len(aFrete)
				If !Empty( nSeek ) .And. Empty( aFrete[ nSeek, 2 ] )
					AAdd(aMsgErr,{ STR0011 ,'00',''}) //Valor do frete zerado
				ElseIf nSeek != Len(aFrete)
					AAdd(aMsgErr,{ STR0012 ,'00',''}) //Falha na linha totalizadora da composicao do frete
				EndIf
				If	!Empty( aMsgErr )
					TmsMsgErr( aMsgErr )
				EndIf
				//-- Inicializa Teclas de Atalhos
				CursorArrow()
				aFrete := {}
				Return(.F.)
			EndIf
			
			If nSeek > 0
				//-- Frete por pais
				aHeader := {}
				aCols   := {}
				Aadd(aNoFields,'DI9_FILORI')
				Aadd(aNoFields,'DI9_LOTNFC')
				Aadd(aNoFields,'DI9_FILDOC')
				Aadd(aNoFields,'DI9_DOC'   )
				Aadd(aNoFields,'DI9_SERIE' )
				TMSFillGetDados( nOpcx,;
				                 'DI9',;
				                 1    ,;
				                 xFilial('DI9')+M->DIK_FILDOC+M->DIK_DOC+M->DIK_SERIE ,;
				                 { || DI9->(DI9_FILIAL+DI9_FILDOC+DI9_DOC+DI9_SERIE) },;
									  { || .T. },;
									  aNoFields ,;
									  aYesFields )
									  
				__nTotFrt:= aFrete[ nSeek, 2 ]
				nSldFrt  := __nTotFrt
				aFrtPais := TMSFrtPais(M->DIK_ROTA,M->DIK_INCOTE)
				For nCnt := 1 To Len(aFrtPais)
					If nCnt == Len(aFrtPais) .And. nSldFrt > 0
						nFrtPais := nSldFrt
					Else								
						nFrtPais := (aFrtPais[nCnt,4] * __nTotFrt) / 100
						nSldFrt  -= nFrtPais
					EndIf
					aFrtPais[nCnt,5] := nFrtPais   
					If nCnt > 1
						//-- Inclui nova linha no aCols
						TMSA210Cols()
					EndIf
					GDFieldPut('DI9_ITEM'  ,StrZero(nCnt,Len(DI9->DI9_ITEM)),nCnt)
					GDFieldPut('DI9_PAIS'  ,aFrtPais[nCnt,2],nCnt)
					GDFieldPut('DI9_DEPAIS',aFrtPais[nCnt,3],nCnt)
					GDFieldPut('DI9_PERFRE',aFrtPais[nCnt,4],nCnt)
					GDFieldPut('DI9_VALTOT',aFrtPais[nCnt,5],nCnt)
				Next nCnt 
				aHeaderDI9 := AClone(aHeader)
				aColsDI9   := AClone(aCols)

				//-- Composicao do Frete CIF/FOB
				aHeader    := {}
				aCols      := {}
				Aadd(aNoFields,'DIA_FILORI')
				Aadd(aNoFields,'DIA_LOTNFC')
				Aadd(aNoFields,'DIA_FILDOC')
				Aadd(aNoFields,'DIA_DOC'   )
				Aadd(aNoFields,'DIA_SERIE' )
				TMSFillGetDados( nOpcx,;
				                 'DIA',;
			   	              1    ,;
			      	           xFilial('DIA')+M->DIK_FILDOC+M->DIK_DOC+M->DIK_SERIE ,;
			         	        { || DIA->(DIA_FILIAL+DIA_FILDOC+DIA_DOC+DIA_SERIE) },;
									  { || .T. },;
									  aNoFields ,;
								  	  aYesFields )
								  	  
			   If (M->DIK_INCOTE == 'DAF' .Or. M->DIK_INCOTE == 'DDU') //-- Ate a Fronteira
					aFrtDAF := TMSFrtDAF(M->DIK_CLIREM,M->DIK_LOJREM,M->DIK_CLIDES,M->DIK_LOJDES)
					For nCnt:= 1 To Len(aFrtDAF)
						//-- Calcula o valor do frete CIF/FOB (Incoterm DAF)
						cCodPas := aFrtDAF[nCnt,1]
						If cCodPas == "TF"
							Loop
						EndIf
						nSeek := Ascan( aFrete,{|x| x[3] == cCodPas })
						If nSeek > 0  
							nTotPas := aFrete[ nSeek, 2 ]
							aFrtDAF[nCnt,5] := (aFrtDAF[nCnt,3] * nTotPas) / 100
							aFrtDAF[nCnt,6] := (aFrtDAF[nCnt,4] * nTotPas) / 100
							nValCIF += aFrtDAF[nCnt,5]
							nValFOB += aFrtDAF[nCnt,6]
						EndIf							
					Next nCnt	
					If nValCIF > 0 .Or. nValFOB > 0
						nTF := Ascan(aFrtDAF,{ | e | e[1] == "TF" })
						If nTF > 0  
							aFrtDAF[nTF,5] := nValCIF
							aFrtDAF[nTF,6] := nValFOB
						EndIf
					EndIf
					For nCnt := 1 To Len(aFrtDAF)
						If nCnt > 1
							//-- Inclui nova linha no aCols
							TMSA210Cols()
						EndIf
						GDFieldPut('DIA_CODPAS',aFrtDAF[nCnt,1],nCnt)
						GDFieldPut('DIA_DESPAS',aFrtDAF[nCnt,2],nCnt)
						GDFieldPut('DIA_PERCIF',aFrtDAF[nCnt,3],nCnt)
						GDFieldPut('DIA_PERFOB',aFrtDAF[nCnt,4],nCnt)
						GDFieldPut('DIA_VALCIF',aFrtDAF[nCnt,5],nCnt)
						GDFieldPut('DIA_VALFOB',aFrtDAF[nCnt,6],nCnt)
					Next nCnt							
				Else
					For nCnt := 1 To Len(aFrete)
						If nCnt > 1
							//-- Inclui nova linha no aCols
							TMSA210Cols()
						EndIf
						GDFieldPut('DIA_CODPAS',aFrete[nCnt,3],nCnt)
						GDFieldPut('DIA_DESPAS',aFrete[nCnt,1],nCnt)
						If M->DIK_TIPFRE == '1' //-- CIF
							GDFieldPut('DIA_PERCIF',100,nCnt)
							GDFieldPut('DIA_VALCIF',aFrete[ nCnt, 2 ],nCnt)
							GDFieldPut('DIA_PERFOB',0,nCnt)
							GDFieldPut('DIA_VALFOB',0,nCnt)
						Else
							GDFieldPut('DIA_PERCIF',0,nCnt)
							GDFieldPut('DIA_VALCIF',0,nCnt)
							GDFieldPut('DIA_PERFOB',100,nCnt)
							GDFieldPut('DIA_VALFOB',aFrete[ nCnt, 2 ],nCnt)
						EndIf							
					Next nCnt
				EndIf
				aHeaderDIA := AClone(aHeader)
				aColsDIA   := AClone(aCols)
			EndIf
		EndIf
		aCols   := aClone(aColsCalc)
		aHeader := aClone(aHeadCalc)
	EndIf
Next nCntFor

RestArea( aAreaAnt )

CursorArrow()

//-- Restaura aCols original
aHeader := AClone(aSavHeader)
aCols   := AClone(aSavCols)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70Frt³ Autor ³ Richard Anderson      ³ Data ³21/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manipula valores do frete calculado                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAI70                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI70Frt(nOpcx)

Local nI         := 0
Local nTPais     := 0
Local oDlg       := {}
Local nOpcA      := 0
Local aAtuCols   := Iif(Type('aCols')   == 'A',aCols  ,{})
Local aAtuHeader := Iif(Type('aHeader') == 'A',aHeader,{})
If Len(aValInf) > 0
	If __lAtzFrt
		__lAtzFrt := .F.
	EndIf
EndIf

If !__lAtzFrt .And. (nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx == 7 .Or. nOpcx == 8)
	If TMAI70Atz()
		__lAtzFrt := .T.
	Else
	   Return NIL
	EndIf	
EndIf	

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

aSvHeader[1] := AClone(aHeaderDIA)
aSvCols[1]   := AClone(aColsDIA)  

aSvHeader[2] := AClone(aHeaderDI9)
aSvCols[2]   := AClone(aColsDI9)

nControGD    := 1

DEFINE MSDIALOG oDlg TITLE STR0045 Of oMainWnd PIXEL  FROM 94 ,104 TO 330,825 //-- Composição do Frete

	oFolFrt:= TFolder():New(13,,{STR0046,STR0047},{STR0046,STR0047},oDlg,,,,.T.,.F.,oDlg:nWidth,oDlg:nHeight) //-- 'Frete &CIF/FOB', 'Frete por &País'
	oFolFrt:Align := CONTROL_ALIGN_ALLCLIENT
	
	aHeader:= AClone(aHeaderDIA)
	aCols  := AClone(aColsDIA)
	n      := 1
	
	oGetDIA:= MsGetDados():New(15,2,90,360,nOpcx,"TMAI70LOk(2)","TMAI70TOk(2)",,.T.,,,,99,,,,,oFolFrt:aDialogs[1])
	oGetDIA:nMax := Len(aCols)
	oGetDIA:oBrowse:bDelete    := {|| .F. }  //-- Nao Permite a deletar Linhas
	oGetDIA:oBrowse:bGotFocus 	:= {|| TMAI70FdE(1)} 	
	oGetDIA:oBrowse:bLostFocus	:= {|| TMAI70FdS(1)}
	oGetDIA:oBrowse:Default()	
	oGetDIA:oBrowse:Refresh()	
	
	aHeader:= AClone(aHeaderDI9)
	aCols  := AClone(aColsDI9)
	n      := 1
	oGetDI9:= MsGetDados():New(15,2,90,360,nOpcx,"AllWaysTrue()","AllWaysTrue()",,.T.,,,,99,,,,,oFolFrt:aDialogs[2])
	oGetDI9:nMax := Len(aCols)
	oGetDI9:oBrowse:bDelete    := {|| .F. }  //-- Nao Permite a deletar Linhas
	oGetDI9:oBrowse:bGotFocus 	:= {|| TMAI70FdE(2)}
	oGetDI9:oBrowse:bLostFocus	:= {|| TMAI70FdS(2)}
	oGetDI9:oBrowse:Default()	
	oGetDI9:oBrowse:Refresh()	
			
ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,{|| nOpcA := 1, If(oGetDIA:TudoOk() .And. oGetDI9:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()}),TMAI70FdI())

If nOpcA == 1  
	aSvHeader[nControGD] := AClone(aHeader)
	aSvCols[nControGD]   := AClone(aCols)
	
   __lAltFrt  := .T.
	aHeaderDIA := AClone(aSvHeader[1])
	aColsDIA   := AClone(aSvCols[1])

	aHeaderDI9 := AClone(aSvHeader[2])
	aColsDI9   := AClone(aSvCols[2])

	//-- Composicao do frete
	TMAI70Cmp()

	//-- Declaracao das mercadorias
	TMAI70Dcl(nOpcx)
EndIf

aHeader := AClone(aAtuHeader)
aCols   := AClone(aAtuCols)                                  
n       := 1 

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70Rec³ Autor ³ Richard Anderson      ³ Data ³21/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recalcula o frete                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAI70                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI70Rec(nOpcx)

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

If !__lAtzFrt
	MsgAlert(STR0037) //-- "Frete ainda não foi calculado !"
ElseIf MsgYesNo(STR0038) //-- "Deseja recalcular o frete?"
	If TMAI70Atz()
		TMAI70Dcl(nOpcx)
		MsgAlert(STR0041) //-- "Frete recalculado com sucesso!"
		__lAtzFrt := .F.
	EndIf		
EndIf	

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70Doc³ Autor ³ Richard Anderson      ³ Data ³21/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta Documento                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAI70                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI70Doc()

Local aAreaAtu := GetArea()
Local aAreaDTC := DTC->(GetArea())
Local aAreaDT6 := DT6->(GetArea())
Local nRecno   := 0

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

SaveInter() //-- Salva Area

cCadastro := STR0042 //-- "Manutenção de Documentos - Visualizar"

nRecno := DT6->(Recno())

If DIK->DIK_STATUS == "9" //--Cancelado
	dbSelectArea("DT6")
	SET DELETED OFF
	DT6->(dbSetOrder(1))	
	DT6->(dbSeek(xFilial('DT6')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE)))
	nRecno := DT6->(Recno())
	dbSelectArea("DT6")
	SET DELETED ON
EndIf


TMSA500Mnt("DT6",nRecno,2)


RestInter() //-- Restaura Area

RestArea( aAreaDTC )
RestArea( aAreaDT6 )
RestArea( aAreaAtu )

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return NIL

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMAI70Dcl ³Autor ³ Richard Anderson      ³ Data ³ 25/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Declaracoes da mercadoria                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAI70                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAI70Dcl(nOpcao)

Local nI         := 0
Local	nTPais     := 0
Local cSimbMd    := GetMv('MV_SIMB'+Str(M->DIK_MOEDA,1),,1)
Local aSavCols   := Iif(Type('aCols')   == 'A',aCols  ,{})
Local aSavHeader := Iif(Type('aHeader') == 'A',aHeader,{})

Default nOpcao   := 0

//--Na visualizacao nao precisa recalcular este campo
If nOpcao == 2 //--Visualizacao
	Return
EndIf

If !Empty(Alltrim(M->DIK_DADDCL)) .And. nOpcao <> 0  //-- Prevalece a digitacao do usuario.
	If !MsgYesNo(STR0070) //"O Recalculo do Frete mudara o conteudo do campo 22"
		Return
	EndIf
EndIf

aHeader:= AClone(aHeaderDI9)
aCols  := AClone(aColsDI9)

For nI := 1 To Len(aCols)
	If nI == 1
		If (M->DIK_INCOTE == 'DAF' .Or. M->DIK_INCOTE == 'DDU')
			M->DIK_DADDCL := 'FLETE PAGADERO EN ORIGEM E DESTINO'
		ElseIf M->DIK_TIPFRE == '1' //-- CIF
			M->DIK_DADDCL := 'FLETE PAGO EN ORIGEM'
		Else
			M->DIK_DADDCL := 'FLETE PAGADERO EN DESTINO'
		EndIf
		M->DIK_DADDCL += Chr(13)+Chr(10)
	EndIf                                                    
	If !Empty(GDFieldGet('DI9_PAIS',nI))
		M->DIK_DADDCL += Padr(AllTrim(Posicione('DI3',1,xFilial('DI3')+GDFieldGet('DI9_PAIS',nI),'DI3_DESFRT')),Len(DI3->DI3_DESFRT),'.')
		M->DIK_DADDCL += cSimbMd+' '+Transform(GDFieldGet('DI9_VALTOT',nI),'@E 999,999.99')
		M->DIK_DADDCL += Chr(13)+Chr(10)
	EndIf			
	nTPais += GDFieldGet('DI9_VALTOT',nI)
Next nI
If Len(aCols) > 0
	M->DIK_DADDCL += Replicate(".",Len(DI3->DI3_DESFRT)+Len(cSimbMd)+11)
	M->DIK_DADDCL += Chr(13)+Chr(10)
	M->DIK_DADDCL += Padr('TOTAL DEL FLETE',Len(DI3->DI3_DESFRT),'.')
	M->DIK_DADDCL += cSimbMd+' '+Transform(nTPais,'@E 999,999.99')
	M->DIK_DADDCL += Chr(13)+Chr(10)
EndIf

//-- Restaura aCols original
aHeader := AClone(aSavHeader)
aCols   := AClone(aSavCols)

Return 	

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMAI70FdI ³Autor ³ Richard Anderson      ³ Data ³ 25/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para inicio do dialogo                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAI70                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TMAI70FdI()

aHeader:= AClone(aSvHeader[1])
aCols  := AClone(aSvCols[1])
n		 := 1

oGetDIA:oBrowse:Default()
oGetDIA:oBrowse:Refresh()	
oGetDIA:oBrowse:SetFocus()	

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMAI70FdE ³Autor ³ Richard Anderson      ³ Data ³ 25/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna aCols e aHeader quando se foca a GETDADOS          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nE - Numero da GetDados.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAI70                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TMAI70FdE(nE)

aHeader	:= AClone(aSvHeader[nE])
aCols		:= AClone(aSvCols[nE])
n			:= 1

oFolFrt:SetOption(nE)
oFolFrt:Refresh()

If nE == 1
	oGetDIA:oBrowse:Refresh()
ElseIf nE == 2
	oGetDI9:oBrowse:Refresh()
EndIf	

nControGD := nE

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMAI70FdS ³Autor ³ Richard Anderson      ³ Data ³ 25/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Guarda aCols e aHeader quando se sai da GETDADOS           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nE - Numero da GetDados.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAI70                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TMAI70FdS(nE)
aSvHeader[nE] := AClone(aHeader)
aSvCols[nE]	  := AClone(aCols)
n				  := 1
                   

Return NIL

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70Grv ³ Autor ³ Richard Anderson     ³ Data ³26.11.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Gravacao dos Dados                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAI70                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAI70Grv(nOpcx,aColsAnt,aHeadAnt)

Local   aCab        := {}
Local   cRet        := ''
Local   nQtdFat     := 0
Local   lRet        := .T.
Local   nI          := 0                   
Local   nCnt        := 0
Local   aCabDTC     := {}
Local   aCabxDTC    := {}
Local   aItemDTC    := {}
Local   aItem       := {}
Local   aAtuHeader  := AClone(aHeader)
Local   aAtuCols    := AClone(aCols)
Local   cCodPro     := GDFieldGet('DIN_CODPRO',1)
Local   cCodEmb     := GDFieldGet('DIN_CODEMB',1)
Local   cPrdImp     := ''
Local   cTipTra     := '4' //-- Rodoviario Internacional
Local	  aExcUsr     := {}
Local   cCpoDTC     := ''
Local   cSeek       := ''
Local   cSeekDIK    := ''
Local   cSeekDIN    := ''
Local   cSeekDTC    := ''
Local   cSerieDoc   := Padr('LOT',Len(DIB->DIB_SERIE))
Local   nRecnoDIB   := 0 
Local   nValCIF     := 0
Local   nValFOB     := 0

//-- Alteração Incoterm DAF
Local   aAreaDT6    := {}
Local   aAreaDT8    := {}
Local   cNumCMP     := ''
Local   lDocDeb     := .F.
Local   cSeekDT6    := ''
Local   cSeekDT8    := ''
Local   cSerDeb     := 'D01'
Local   aCampos     := {}
Local   aCompPrd    := {}
Local   nPosComp    := 0
Local   nValPas     := 0
Local   nValImp     := 0
Local   nValTot     := 0
Local   nPos        := 0
Local   nPQtdVol    := 0
Local   nQuant      := 0
Local   nPosNumNf   := 0
Local   nPosSerie   := 0
Local   nPosProd    := 0    
Local   nQtdDig     := 0    
Local   aCopValInf	:= {}
Local 	cItem		:= 0
Local 	lIdentDoc   := DTC->(ColumnPos("DTC_DOCTMS")) > 0
Local 	oStructDTC	:= Nil
Local 	aFldDTC		:= {}
Local 	nJ			:= 0

Private lMsErroAuto := .F.

Default aColsAnt    := {}
Default aHeadAnt    := {}

CursorWait()

If nOpcx == 3 .Or. nOpcx == 8 //-- Incluir
	//-- Soma a quantidade de faturas
	For nI := 1 To Len(aCols)
		If	!GDDeleted( nI )
			nQtdFat += 1
		EndIf			
  	Next nI			
	Aadd(aCab,{'DTP_QTDLOT',nQtdFat,NIL})
	Aadd(aCab,{'DTP_STATUS','1'    ,NIL}) //-- Status 1 Em Aberto
	MsExecAuto({|x,y|cRet := TmsA170(x,y)},aCab,3)
	If lMsErroAuto
		MostraErro()
		lRet := .F.
	Else
		M->DIK_FILORI := cFilAnt
		M->DIK_LOTNFC := cRet
	EndIf
Else
	DTP->(dbSetOrder(2))
	DTP->(dbSeek(xFilial('DTP')+M->DIK_FILORI+M->DIK_LOTNFC))
EndIf
If lRet .And. (nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx == 7 .Or. nOpcx == 8)
	Begin Transaction //--Esta transacao nao pode finalizar depois do calculo do frete, trava a numeracao
	
	RecLock( "DIK", nOpcx == 3 .Or. nOpcx == 8 )
	Aeval( dbStruct(), { |aFieldName, nI | FieldPut( nI, If('FILIAL' $ aFieldName[1],;
														   xFilial( "DIK" ), M->&(aFieldName[1]) ) ) } )
	DIK->(MsUnLock())
	//--Forcando o comando devido a problemas com binario antigo EAL
	DIK->(dbCommit())
	
	//-- Grava DIN
	DIN->(dbSetOrder(1))
	For nI := 1 To Len(aCols)
		nPQtdVol := Ascan(aHeader,{ | x | x[2] == 'DIN_QTDVOL' })
		If	!GDDeleted( nI )
		    nQtdDig += 1 
			nQuant += aCols[nI,nPQtdVol]
			If nI == 1
				nPosNumNf := GDFieldPos('DIN_NUMNFC')
				nPosSerie := GDFieldPos('DIN_SERNFC')
				nPosProd  := GDFieldPos('DIN_CODPRO')
			EndIf
			
			If nOpcx == 7 .And. (nI <= Len(aColsAnt)) .And. (aCols[nI,nPosNumNf] != aColsAnt[nI,nPosNumNf] .Or. aCols[nI,nPosSerie] != aColsAnt[nI,nPosSerie] .Or.;
				aCols[nI,nPosProd] != aColsAnt[nI,nPosProd]) //Se um destes foi alterado precisa alterar o registro
				cSeekDIN := xFilial('DIN')+M->DIK_FILORI+M->DIK_LOTNFC+aColsAnt[nI,nPosNumNf]+aColsAnt[nI,nPosSerie]+aColsAnt[nI,nPosProd]
			Else
				cSeekDIN := xFilial('DIN')+M->DIK_FILORI+M->DIK_LOTNFC+GDFieldGet('DIN_NUMNFC',nI)+GDFieldGet('DIN_SERNFC',nI)+GDFieldGet('DIN_CODPRO',nI)
			EndIf

			If DIN->(dbSeek(cSeekDIN))
				RecLock('DIN',.F.)
			Else	
				RecLock('DIN',.T.)
				DIN->DIN_FILIAL := xFilial('DIN')
				DIN->DIN_FILORI := M->DIK_FILORI
				DIN->DIN_LOTNFC := M->DIK_LOTNFC
			EndIf
		
			For nCnt := 1 To Len(aHeader)
				If	aHeader[nCnt,10] != 'V'
					FieldPut(FieldPos(aHeader[nCnt,2]), aCols[nI,nCnt])
				EndIf
			Next			
			DIN->(MsUnLock())
			DIN->(dbCommit())
		ElseIf DIN->(dbSeek(xFilial('DIN')+M->DIK_FILORI+M->DIK_LOTNFC+GDFieldGet('DIN_NUMNFC',nI)+GDFieldGet('DIN_SERNFC',nI)+GDFieldGet('DIN_CODPRO',nI))) 
			RecLock('DIN',.F.)
		   dbDelete()
		   MsUnLock()
		EndIf				
	Next nI			
	//-- Grava DI9
	aHeader:= AClone(aHeaderDI9)
	aCols  := AClone(aColsDI9)
	For nI := 1 To Len(aCols)
		If Empty(GDFieldGet('DI9_PAIS',nI))
			Loop
		EndIf
		If !Empty(M->DIK_DOC)
			DI9->(dbSetOrder(2))
			If DI9->(dbSeek(xFilial('DI9')+M->DIK_FILDOC+M->DIK_DOC+M->DIK_SERIE+GDFieldGet('DI9_ITEM',nI)))
				RecLock('DI9',.F.)
			Else					
				RecLock('DI9',.T.)
				DI9->DI9_FILIAL := xFilial('DI9')
				DI9->DI9_FILORI := M->DIK_FILORI
				DI9->DI9_LOTNFC := M->DIK_LOTNFC
				DI9->DI9_FILDOC := M->DIK_FILDOC
				DI9->DI9_DOC    := M->DIK_DOC
				DI9->DI9_SERIE  := M->DIK_SERIE
			EndIf						
		Else
			DI9->(dbSetOrder(1))
			If DI9->(dbSeek(xFilial('DI9')+M->DIK_FILORI+M->DIK_LOTNFC+GDFieldGet('DI9_ITEM',nI)))
				RecLock('DI9',.F.)
			Else
				RecLock('DI9',.T.)
				DI9->DI9_FILIAL := xFilial('DI9')
				DI9->DI9_FILORI := M->DIK_FILORI
				DI9->DI9_LOTNFC := M->DIK_LOTNFC
			EndIf
		EndIf
		For nCnt := 1 To Len(aHeader)
			If	aHeader[nCnt,10] != 'V'
				FieldPut(FieldPos(aHeader[nCnt,2]), aCols[nI,nCnt])
			EndIf
		Next
		DI9->(MsUnLock())
		DI9->(dbCommit())
	Next nI							
	//-- Grava DIA
	aHeader:= AClone(aHeaderDIA)
	aCols  := AClone(aColsDIA)
	For nI := 1 To Len(aCols)
		If !Empty(M->DIK_DOC)
			DIA->(dbSetOrder(2))
			If DIA->(dbSeek(xFilial('DIA')+M->DIK_FILDOC+M->DIK_DOC+M->DIK_SERIE+GDFieldGet('DIA_CODPAS',nI)))
				RecLock('DIA',.F.)
			Else
				RecLock('DIA',.T.)
				DIA->DIA_FILIAL := xFilial('DIA')
				DIA->DIA_FILORI := M->DIK_FILORI
				DIA->DIA_LOTNFC := M->DIK_LOTNFC
				DIA->DIA_FILDOC := M->DIK_FILDOC
				DIA->DIA_DOC    := M->DIK_DOC
				DIA->DIA_SERIE  := M->DIK_SERIE
			EndIf
		Else
			DIA->(dbSetOrder(1))
			If DIA->(dbSeek(xFilial('DIA')+M->DIK_FILORI+M->DIK_LOTNFC+GDFieldGet('DIA_CODPAS',nI)))
				RecLock('DIA',.F.)
			Else
				RecLock('DIA',.T.)
				DIA->DIA_FILIAL := xFilial('DIA')
				DIA->DIA_FILORI := M->DIK_FILORI
				DIA->DIA_LOTNFC := M->DIK_LOTNFC
			EndIf
		EndIf			
		For nCnt := 1 To Len(aHeader)
			If	aHeader[nCnt,10] != 'V'
				FieldPut(FieldPos(aHeader[nCnt,2]), aCols[nI,nCnt])
			EndIf
		Next
		DIA->(MsUnLock())
		DIA->(dbCommit())
	Next nI
	//-- Grava DTC
	aCabXDTC := {	{"DTC_FILORI" ,M->DIK_FILORI, Nil},;
					{"DTC_LOTNFC" ,M->DIK_LOTNFC, Nil},;    
					{"DTC_FILCFS" ,M->DIK_FILCFS, Nil},; 
					{"DTC_NUMSOL" ,M->DIK_NUMSOL, Nil},; 
					{"DTC_DATENT" ,M->DIK_DATENT, Nil},; 
					{"DTC_CLIREM" ,M->DIK_CLIREM, Nil},; 
					{"DTC_LOJREM" ,M->DIK_LOJREM, Nil},; 
					{"DTC_CLIDES" ,M->DIK_CLIDES, Nil},; 
					{"DTC_LOJDES" ,M->DIK_LOJDES, Nil},; 
					{"DTC_CLICON" ,M->DIK_CLICON, Nil},; 
					{"DTC_LOJCON" ,M->DIK_LOJCON, Nil},; 
					{"DTC_DEVFRE" ,M->DIK_DEVFRE, Nil},; 
					{"DTC_CLIDEV" ,M->DIK_CLIDEV, Nil},; 
					{"DTC_LOJDEV" ,M->DIK_LOJDEV, Nil},; 
					{"DTC_TIPFRE" ,M->DIK_TIPFRE, Nil},;
					{"DTC_TIPNFC" ,'0'          , Nil},;
					{"DTC_CLICAL" ,M->DIK_CLIDEV, Nil},; 
					{"DTC_LOJCAL" ,M->DIK_LOJDEV, Nil},; 
					{"DTC_SERTMS" ,M->DIK_SERTMS, Nil},; 
					{"DTC_TIPTRA" ,cTipTra      , Nil},;
					{"DTC_SERVIC" ,M->DIK_SERVIC, Nil},;
					{"DTC_SELORI" ,M->DIK_SELORI, Nil},;
					{"DTC_CDRORI" ,M->DIK_CDRORI, Nil},;
					{"DTC_CDRDES" ,M->DIK_CDRDES, Nil},;
					{"DTC_CDRCAL" ,M->DIK_CDRCAL, Nil},;
					{"DTC_INCOTE" ,M->DIK_INCOTE, Nil},;              
					{"DTC_MOEDA " ,M->DIK_MOEDA , Nil},;
					{"DTC_MOENFC" ,M->DIK_MOENFC, Nil},;
					{"DTC_CLINOT" ,M->DIK_CLINOT, Nil},;
					{"DTC_LOJNOT" ,M->DIK_LOJNOT, Nil},;
					{"DTC_OBS   " ,M->DIK_DADMER, Nil},;
					{"DTC_DOCANE" ,M->DIK_DOCANE, Nil},;
					{"DTC_ROTA  " ,M->DIK_ROTA  , Nil},;
					{"DTC_VALSEG" ,M->DIK_VALSEG, Nil}}
	              
   If lTMSCFec
		Aadd(aCabXDTC,{"DTC_DATCOL" ,M->DIK_DATCOL, Nil})
		Aadd(aCabXDTC,{"DTC_HORCOL" ,M->DIK_HORCOL, Nil})
   EndIf
	
	Aadd(aCabXDTC,{"DTC_CODNEG" ,M->DIK_CODNEG, Nil})

   If lIdentDoc
		Aadd(aCabXDTC,{"DTC_DOCTMS" ,"J", Nil})
   EndIf   

	DTC->(dbSetOrder(2))
	aHeader:= AClone(aAtuHeader)
	aCols  := AClone(aAtuCols)
	For nI := 1 To Len(aCols)
		If	!GDDeleted( nI )
		
			If nI == 1
				nPosNumNf := GDFieldPos('DIN_NUMNFC')
				nPosSerie := GDFieldPos('DIN_SERNFC')
				nPosProd  := GDFieldPos('DIN_CODPRO')
			EndIf
			
			If nOpcx == 7 .And. (nI <= Len(aColsAnt)) .And. (aCols[nI,nPosNumNf] != aColsAnt[nI,nPosNumNf] .Or. aCols[nI,nPosSerie] != aColsAnt[nI,nPosSerie] .Or.;
				aCols[nI,nPosProd] != aColsAnt[nI,nPosProd]) //Se um destes foi alterado precisa alterar o registro
				cSeekDTC := xFilial('DTC')+aColsAnt[nI,nPosNumNf]+aColsAnt[nI,nPosSerie]+M->DIK_CLIREM+M->DIK_LOJREM+aColsAnt[nI,nPosProd]+M->DIK_FILORI+M->DIK_LOTNFC
			Else
				cSeekDTC := xFilial('DTC')+GDFieldGet('DIN_NUMNFC',nI)+GDFieldGet('DIN_SERNFC',nI)+M->DIK_CLIREM+M->DIK_LOJREM+GDFieldGet('DIN_CODPRO',nI)+M->DIK_FILORI+M->DIK_LOTNFC
			EndIf
		
			If DTC->(!dbSeek(cSeekDTC))
			   If Len(aCabDTC) == 0
					oStructDTC := FWFormStruct(1, "DTC")
					aFldsDTC := oStructDTC:aFields
					For nJ := 1 To Len(aFldsDTC)
						If (nPos := Ascan(aCabXDTC,{|x| AllTrim(x[1]) == AllTrim(aFldsDTC[nJ][3])})) > 0
							Aadd(aCabDTC,AClone(aCabXDTC[nPos]))
						EndIf
					Next
					FreeObj(oStructDTC)

					aSize(aFldsDTC, 0)
					aFldsDTC := Nil
				EndIf														
				aItem := { {"DTC_NUMNFC" ,GDFieldGet('DIN_NUMNFC',nI), Nil},; 
				           {"DTC_SERNFC" ,GDFieldGet('DIN_SERNFC',nI), Nil},;
			   	        {"DTC_CODPRO" ,GDFieldGet('DIN_CODPRO',nI), Nil},;
						 	  {"DTC_CODEMB" ,GDFieldGet('DIN_CODEMB',nI), Nil},;
							  {"DTC_EMINFC" ,GDFieldGet('DIN_EMINFC',nI), Nil},;
							  {"DTC_QTDVOL" ,GDFieldGet('DIN_QTDVOL',nI), Nil},;
							  {"DTC_PESO"   ,GDFieldGet('DIN_PESO'  ,nI), Nil},;
							  {"DTC_PESOM3" ,GDFieldGet('DIN_PESOM3',nI), Nil},;
							  {"DTC_PESLIQ" ,GDFieldGet('DIN_PESLIQ',nI), Nil},;
							  {"DTC_METRO3" ,GDFieldGet('DIN_METRO3',nI), Nil},;
							  {"DTC_VALOR"  ,GDFieldGet('DIN_VALOR' ,nI), Nil},;
							  {"DTC_EDI"    ,'2' , Nil},;
							  {"DTC_NFENTR" ,'2' , Nil} }
				Aadd(aItemDTC,AClone(aItem))
			Else
				RegToMemory('DTC',.F.)
		
				//--Atualiza os dados do cabecalho que foram alterados
				For nCnt := 1 To Len(aCabXDTC)
					cCpoDTC := aCabXDTC[nCnt,1]
					M->&(cCpoDTC) := aCabXDTC[nCnt,2]
				Next nCnt
				
				//--Atualiza os itens que foram alterados
				aItem := { {"DTC_CODEMB" ,GDFieldGet('DIN_CODEMB',nI), Nil},;
							  {"DTC_EMINFC" ,GDFieldGet('DIN_EMINFC',nI), Nil},;
							  {"DTC_NUMNFC" ,GDFieldGet('DIN_NUMNFC',nI), Nil},;
							  {"DTC_SERNFC" ,GDFieldGet('DIN_SERNFC',nI), Nil},;
							  {"DTC_CODPRO" ,GDFieldGet('DIN_CODPRO',nI), Nil},;
							  {"DTC_QTDVOL" ,GDFieldGet('DIN_QTDVOL',nI), Nil},;
							  {"DTC_PESO"   ,GDFieldGet('DIN_PESO'  ,nI), Nil},;
							  {"DTC_PESOM3" ,GDFieldGet('DIN_PESOM3',nI), Nil},;
							  {"DTC_PESLIQ" ,GDFieldGet('DIN_PESLIQ',nI), Nil},;
							  {"DTC_METRO3" ,GDFieldGet('DIN_METRO3',nI), Nil},;
							  {"DTC_VALOR"  ,GDFieldGet('DIN_VALOR' ,nI), Nil}}
							  
				//--Atualiza os itens da nota - DIN X DTC
				For nCnt := 1 To Len(aItem)
					cCpoDTC := aItem[nCnt,1]
					M->&(cCpoDTC) := aItem[nCnt,2]
				Next nCnt				
			
				RecLock( "DTC", .F. )
				Aeval( dbStruct(), { |aFieldName, nI | FieldPut( nI, If('FILIAL' $ aFieldName[1],;
														 		   xFilial( "DTC" ), M->&(aFieldName[1]) ) ) } )
				DTC->(MsUnLock())
				DTC->(dbCommit())
			EndIf
				aCopValInf := aClone(aValInf)		
				TmsGrvInf(aValInf, '2', M->DIK_FILORI, , M->DIK_LOTNFC, M->DIK_CLIREM, M->DIK_LOJREM, M->DIK_CLIDES, M->DIK_LOJDES, M->DIK_SERVIC, nOpcx, , IIf(nOpcx == 3, aValInf, aCopValInf), M->DIK_SERVIC)
		ElseIf DTC->(dbSeek(xFilial('DTC')+GDFieldGet('DIN_NUMNFC',nI)+GDFieldGet('DIN_SERNFC',nI)+M->DIK_CLIREM+M->DIK_LOJREM+GDFieldGet('DIN_CODPRO',nI)+M->DIK_FILORI+M->DIK_LOTNFC))
			RecLock('DTC',.F.)
			dbDelete()
			DTC->(MsUnLock())
			DTC->(dbCommit())
		EndIf			
	Next nI
	// Parametros da TMSA050 (notas fiscais do cliente)
	// xAutoCab - Cabecalho da nota fiscal
	// xAutoItens - Itens da nota fiscal
	// xItensPesM3 - acols de Peso Cubado
	// xItensEnder - acols de Enderecamento
	// nOpcAuto - Opcao rotina automatica
	If Len(aCabDTC) > 0
		If lTMI70DTC
			aExcUsr := ExecBlock('TMI70DTC',.F.,.F.,{ aCabDTC, aItemDTC })
			If ValType(aExcUsr) == 'A' .And. Len(aExcUsr) == 2
				aCabDTC  := AClone(aExcUsr[1])
				aItemDTC := AClone(aExcUsr[2])
			EndIf
		EndIf
		
		//--Se for alteracao, e nao existir o DTC, antes de chamar esta rotina automatica eu preciso
		//--mudar o status do dtp pra 1, mudar o qtddig para 0 e passar a opcao 3, senao a rotina automatica nao inclui este DTC
		//--Se existir o DTC, e so passar a opcao 4 e nao precisa mexer no lote
		If nOpcx == 3 .Or. nOpcx == 8 //--Inclusao ou Copia
			MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aItemDTC,,,3)
			If	!lMsErroAuto
				TmsGrvInf(aValInf, '2', M->DIK_FILORI, , M->DIK_LOTNFC, M->DIK_CLIREM, M->DIK_LOJREM, M->DIK_CLIDES, M->DIK_LOJDES, M->DIK_SERVIC, nOpcx, , IIf(nOpcx == 3, aValInf, aCopValInf), M->DIK_SERVIC)
			EndIf
		ElseIf nOpcx == 4 .Or. nOpcx == 7 //Alteracao ou Regerar de CRT
			aAreaDTC := DTC->(GetArea())
			DTC->(dbSetOrder(1))
			If !DTC->(dbSeek(xFilial('DTC')+M->DIK_FILORI+M->DIK_LOTNFC)) .Or. nOpcx == 7  //Regerar, precisar regravar o DTC
				RecLock("DTP",.F.)
				DTP->DTP_STATUS := "1"
				DTP->DTP_QTDDIG := 0
				DTP->(MsUnLock())
				RestArea(aAreaDTC)
				MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aItemDTC,,,3)  							
			Else    			
				RestArea(aAreaDTC)
				MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aItemDTC,,,nOpcx)
			EndIf
			If	!lMsErroAuto
				TmsGrvInf(aValInf, '4', M->DIK_FILORI, , M->DIK_LOTNFC, M->DIK_CLIREM, M->DIK_LOJREM, M->DIK_CLIDES, M->DIK_LOJDES, M->DIK_SERVIC, nOpcx, , IIf(nOpcx == 3, aValInf, aCopValInf), M->DIK_SERVIC)
			EndIf
		EndIf
				
		If lMsErroAuto
			lRet := .F.
			MostraErro()
		EndIf
	EndIf

	End Transaction //--Se esta transacao terminar apos o calculo trava a numeracao, verificar outra forma
	
	If lRet
		//--Se for Regerar, volta o Lote para digitado e forca um novo calculo
		If nOpcx == 7
			TMAI70Reg(DIK->DIK_FILORI,DIK->DIK_LOTNFC,DIK->DIK_FILDOC,DIK->DIK_DOC,DIK->DIK_SERIE)
		EndIf
		
		//-- Gera DT6
		If Empty(DIK->DIK_DOC) .And. DTC->DTC_SERIE <> 'PED' //-- Digitado
			//--Este tratamento foi incluido na rotina para quando o usuario digita o CRT e da problemas nas validacoes da nota, 
			//ele nao grava o DTC. Desta forma o usuario corrige os problemas e manda alterar. A rotina gera o DTC e recalcula
			RecLock("DTP",.F.)
			DTP->DTP_STATUS := "2" //--Muda para digitado para recalcular o lote
			DTP->(MsUnLock())
			TMSA200Mnt('DTP',DTP->(Recno()),2,,.F.) //--Chama a rotina de calculo novamente, ela so recalcula se tiver DTC
		ElseIf DTP->DTP_STATUS == '2' //-- Digitado
			TMSA200Mnt('DTP',DTP->(Recno()),2,,.F.)
		ElseIf DTP->DTP_STATUS == '4' .Or. DTC->DTC_SERIE == 'PED' //-- Bloqueado
			TMSA200Rec('DTP',DTP->(Recno()),6,.F.,.T.)
		EndIf			
	EndIf
	If lRet .And. (nOpcx == 3 .Or. nOpcx == 7 .Or. nOpcx == 8)  //--Inclusao ou Copiar
	   //-- Efetua as gravacoes para quando o memo e corrigido na inclusao, antes de gravar
		If (nPos := Ascan(aCRTCamp,{ | e | e[1] == 'DIK_DADDCL' })) == 0
			Aadd(aCRTCamp,{"DIK_DADDCL","22",.T.,M->DIK_DADDCL}) //--
		Else
			aCRTCamp[nPos,3] := .T.
			aCRTCamp[nPos,4] := M->DIK_DADDCL
		EndIf		
		If (nPos := Ascan(aCRTCamp,{ | e | e[1] == 'DIK_LCPAIS' })) == 0
			Aadd(aCRTCamp,{"DIK_LCPAIS","05",.T.,M->DIK_LCPAIS}) //--Localidade e Pais
		Else
			aCRTCamp[nPos,3] := .T.
			aCRTCamp[nPos,4] := M->DIK_LCPAIS
		EndIf
		If (nPos := Ascan(aCRTCamp,{ | e | e[1] == 'DIK_DADIAF' })) == 0
			Aadd(aCRTCamp,{"DIK_DADIAF","18",.T.,M->DIK_DADIAF}) //--Informaçoes da Alfandega
		Else
			aCRTCamp[nPos,3] := .T.
			aCRTCamp[nPos,4] := M->DIK_DADIAF
		EndIf				
		If (nPos := Ascan(aCRTCamp,{ | e | e[1] == 'DIK_LCMERC' })) == 0
			Aadd(aCRTCamp,{"DIK_LCMERC","07",.T.,M->DIK_LCMERC}) //-- Localidade Mercadoria
		Else
			aCRTCamp[nPos,3] := .T.
			aCRTCamp[nPos,4] := M->DIK_LCMERC
		EndIf		
		//-- Forca a gravacao do Campo 08: Localidade de Entrega
		If (nPos := Ascan(aCRTCamp,{ | e | e[1] == 'DIK_LCENTR' })) == 0
			Aadd(aCRTCamp,{"DIK_LCENTR","08",.T.,M->DIK_LCENTR}) 
		Else
			aCRTCamp[nPos,3] := .T.
			aCRTCamp[nPos,4] := M->DIK_LCENTR
		EndIf		
		//-- Forca a gravacao do Campo 21: Nome e assinatura do remetente
		If (nPos := Ascan(aCRTCamp,{ | e | e[1] == 'DIK_NOMREM' })) == 0
			Aadd(aCRTCamp,{"DIK_NOMREM","21",.T.,M->DIK_NOMREM}) 
		Else
			aCRTCamp[nPos,3] := .T.
			aCRTCamp[nPos,4] := M->DIK_NOMREM
		EndIf
		
		If (nPos := Ascan(aCRTCamp,{ | e | e[1] == 'DIK_DADREM' })) == 0
			Aadd(aCRTCamp,{"DIK_DADREM","01",.T.,M->DIK_DADREM}) 
		Else
			aCRTCamp[nPos,3] := .T.
			aCRTCamp[nPos,4] := M->DIK_DADREM
		EndIf
		
		If (nPos := Ascan(aCRTCamp,{ | e | e[1] == 'DIK_DOCANE' })) == 0
			Aadd(aCRTCamp,{"DIK_DOCANE","17",.T.,M->DIK_DOCANE}) 
		Else
			aCRTCamp[nPos,3] := .T.
			aCRTCamp[nPos,4] := M->DIK_DOCANE
		EndIf        
		If (nPos := Ascan(aCRTCamp,{ | e | e[1] == 'DIK_DADDES' })) == 0
			Aadd(aCRTCamp,{"DIK_DADDES","04",.T.,M->DIK_DADDES}) 
		Else
			aCRTCamp[nPos,3] := .T.
			aCRTCamp[nPos,4] := M->DIK_DADDES
		EndIf     

		If (nPos := Ascan(aCRTCamp,{ | e | e[1] == 'DIK_DADCON' })) == 0
			Aadd(aCRTCamp,{"DIK_DADCON","6",.T.,M->DIK_DADCON}) 
		Else
			aCRTCamp[nPos,3] := .T.
			aCRTCamp[nPos,4] := M->DIK_DADCON
		EndIf                    
		
		If (nPos := Ascan(aCRTCamp,{ | e | e[1] == 'DIK_DADNOT' })) == 0
			Aadd(aCRTCamp,{"DIK_DADNOT","9",.T.,M->DIK_DADNOT}) 
		Else
			aCRTCamp[nPos,3] := .T.
			aCRTCamp[nPos,4] := M->DIK_DADNOT
		EndIf  
	EndIf

	//-- Verifica dados alterados
	For nI := 1 To Len(aCRTCamp) 
		If aCRTCamp[nI,4] != M->(&(aCRTCamp[nI,1]))
			aCRTCamp[nI,3] := .T.                      
			If aCRTCamp[nI,1] == 'DIK_INCOTE' .And. !__lAltFrt
				__lAltFrt := .T.
			EndIf
		EndIf
	Next nI
	
	Begin Transaction
	
	If !Empty(DIK->DIK_DOC)
		If nOpcx == 3 .Or. nOpcx == 8
			RecLock('DIK',.F.)
			DIK->DIK_STATUS := '2' //-- Gerado
			MsUnLock()    
			
			//-- Atualiza o valor no SF2, devido a TES nao gerar duplicata. (Este valor é utilizado na consulta do manifesto)
			DT6->(dbSetOrder(1))
			If DT6->(dbSeek(xFilial('DT6')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE)))         
				SF2->(dbSetOrder(1))
		 		If SF2->(dbSeek(Iif(!Empty(xFilial('SF2')),DIK->DIK_FILDOC,Space(FWGETTAMFILIAL))+DIK->(DIK_DOC+DIK_SERIE)))
					RecLock('SF2',.F.)		
					SF2->F2_VALFAT  := DT6->DT6_VALFAT
					SF2->(MsUnLock())
	 			EndIf
			EndIf
				
		ElseIf nOpcx == 4 .Or. nOpcx == 7 //--Alterar ou Regerar
			RecLock('DIK',.F.)
			If nOpcx == 4 //--Alterar
				DIK->DIK_STATUS := '3' //-- Alterado
			ElseIf nOpcx == 7  //--Regerar
				DIK->DIK_STATUS := '4' //-- Regerado
			EndIf
			__lAltFrt := .T. //--Alterar ou Regerar e necessario atualizar o Frete
			DIK->(MsUnLock())
			If __lAltFrt
				DUI->(dbSetOrder(1))
				DT8->(dbSetOrder(2))
				SD2->(dbSetOrder(3))
				If DUI->(dbSeek(xFilial('DUI')+Posicione('DT6',1,xFilial('DT6')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE),'DT6_DOCTMS'))) 
					If DIK->DIK_TIPFRE == '1' .And. !Empty(DUI->DUI_PRDCIF)
						cPrdImp := DUI->DUI_PRDCIF
					Else
						cPrdImp := DUI->DUI_CODPRO
					EndIf
				EndIf																	
				aHeader:= AClone(aHeaderDIA)
				aCols  := AClone(aColsDIA)
				nValCIF:= 0
				nValFOB:= 0
				For nI := 1 To Len(aCols)
					If DT8->(dbSeek(xFilial('DT8')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE)+cCodPro+GDFieldGet('DIA_CODPAS',nI)))
						RecLock('DT8',.F.)
						DT8->DT8_VALPAS := GDFieldGet('DIA_VALCIF',nI)+GDFieldGet('DIA_VALFOB',nI)
						DT8->DT8_VALTOT := GDFieldGet('DIA_VALCIF',nI)+GDFieldGet('DIA_VALFOB',nI)
						MsUnLock()
						If GDFieldGet('DIA_CODPAS',nI) == 'TF'
							nValCIF := GDFieldGet('DIA_VALCIF',nI)
							nValFOB := GDFieldGet('DIA_VALFOB',nI)
						Else							
							If	SD2->(dbSeek(Iif(!Empty(xFilial('SD2')),DT8->DT8_FILDOC,Space(FWGETTAMFILIAL))+DT8->(DT8_DOC+DT8_SERIE)+DIK->(DIK_CLIDEV+DIK_LOJDEV)+cPrdImp+DT8->DT8_ITEMD2))
								RecLock('SD2',.F.)
								SD2->D2_PRCVEN  := DT8->DT8_VALTOT
								SD2->D2_TOTAL   := DT8->DT8_VALTOT
								SD2->D2_PRUNIT  := DT8->DT8_VALTOT
								SD2->D2_VALBRUT := DT8->DT8_VALTOT
								MsUnLock()
							EndIf
						EndIf				 																						
					Else
                        
                        cItem := nI   
                        cItem := STRZERO(cItem, 2, 0)
                                         
                   		aAreaSD2 := SD2->(GetArea())
						dbSelectArea("SD2")
						dbSetOrder(3)
                        If SD2->(dbSeek(xFilial('SD2')+DIK->(DIK_DOC+DIK_SERIE+DIK_CLIDEV+DIK_LOJDEV+cPrdImp)))
							aCampos  := {}
							AAdd( aCampos, { 'D2_ITEM'		, cItem } )
							AAdd( aCampos, { 'D2_PRCVEN'	, aFrete[nI][2] } )
							AAdd( aCampos, { 'D2_PRUNIT'	, aFrete[nI][2] } )
							AAdd( aCampos, { 'D2_TOTAL'		, aFrete[nI][2] } )
							AAdd( aCampos, { 'D2_VALBRUT'	, aFrete[nI][2] } )
							TmsCopyReg(aCampos)
						EndIf
						RestArea(aAreaSD2) 
					
                   		aAreaDT8 := DT8->(GetArea())
						dbSelectArea("DT8")
						dbSetOrder(2)

						If DT8->(dbSeek(xFilial('DT8')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE)+cCodPro))
							aCampos  := {}
							AAdd( aCampos, { 'DT8_CODPAS', aFrete[nI][3] } )
							AAdd( aCampos, { 'DT8_VALPAS', aFrete[nI][2] } )
							AAdd( aCampos, { 'DT8_VALTOT', aFrete[nI][2] } )
							AAdd( aCampos, { 'DT8_ITEMD2', cItem } )
							TmsCopyReg(aCampos)     
						EndIf							
						RestArea(aAreaDT8) 
					EndIf
				Next nI
			Else				
				nValCIF := Posicione('DIA',2,xFilial('DIA')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE)+'TF','DIA_VALCIF')
				nValFOB := Posicione('DIA',2,xFilial('DIA')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE)+'TF','DIA_VALFOB')
			EndIf
			//-- Atualiza DT6
			DT6->(dbSetOrder(1))
			If DT6->(dbSeek(xFilial('DT6')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE)))
				RecLock('DT6',.F.)
				DT6->DT6_PESO   := DIK->DIK_PESO
				DT6->DT6_PESLIQ := DIK->DIK_PESLIQ
				DT6->DT6_METRO3 := DIK->DIK_METRO3
				DT6->DT6_VALMER := DIK->DIK_VALOR
				DT6->DT6_VOLORI := nQuant //--Qtd de Volumes dos Totais das Faturas
				DT6->DT6_QTDVOL := nQuant //--Qtd de Volumes dos Totais das Faturas
				DT6->DT6_CLICON := DIK->DIK_CLICON
				DT6->DT6_LOJCON := DIK->DIK_LOJCON
				DT6->DT6_TIPFRE := DIK->DIK_TIPFRE
				DT6->DT6_VALFRE := IIf(Empty(nValCIF),nValFOB,nValCIF)
				DT6->DT6_VALTOT := IIf(Empty(nValCIF),nValFOB,nValCIF)
				DT6->DT6_VALFAT := IIf(Empty(nValCIF),nValFOB,nValCIF)      
				DT6->DT6_MOEDA  := DIK->DIK_MOEDA			
				DT6->(MsUnLock())     
			EndIf
			nValFOB := Posicione('DIA',2,xFilial('DIA')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE)+'TF','DIA_VALFOB')
			//-- Atualiza SF2                                                                            
			SF2->(dbSetOrder(1))
			If SF2->(dbSeek(Iif(!Empty(xFilial('SF2')),DIK->DIK_FILDOC,Space(FWGETTAMFILIAL))+DIK->(DIK_DOC+DIK_SERIE)))
				RecLock('SF2',.F.)
				SF2->F2_PLIQUI  := DIK->DIK_PESO
				SF2->F2_PBRUTO  := DIK->DIK_PESO   
				SF2->F2_VOLUME1 := nQuant //--Qtd de Volumes dos Totais das Faturas
				SF2->F2_VALFAT  := IIf(Empty(nValCIF),nValFOB,nValCIF)
				SF2->F2_VALMERC := IIf(Empty(nValCIF),nValFOB,nValCIF)
				SF2->F2_VALBRUT := IIf(Empty(nValCIF),nValFOB,nValCIF)      
				SF2->F2_MOEDA   := DIK->DIK_MOEDA
				SF2->(MsUnLock())
			EndIf
			If __lAltFrt   
				If nValFOB > 0 .And. (M->DIK_INCOTE == 'DAF' .Or. M->DIK_INCOTE == 'DDU')
					aAreaDT6 := DT6->(GetArea())
					cNumCMP  := DT6->DT6_NUMCMP
					lDocDeb  := .F.
					DT6->(dbSetOrder(8))
					DT6->(dbSeek(cSeekDT6 := xFilial('DT6')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE)))
					While DT6->(!Eof()) .And. DT6->(DT6_FILIAL+DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO) == cSeekDT6
						If DT6->DT6_DOCTMS == 'J' .And. DT6->DT6_NUMCMP == cNumCMP .And. DT6->DT6_TIPFRE == '2' //-- Fob
							lDocDeb := .T.
							Exit
						EndIf
						DT6->(dbSkip())
					EndDo
					If lDocDeb
						aHeader:= AClone(aHeaderDIA)
						aCols  := AClone(aColsDIA)
						For nI := 1 To Len(aCols)
							If DT8->(dbSeek(xFilial('DT8')+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)+cCodPro+GDFieldGet('DIA_CODPAS',nI)))
								RecLock('DT8',.F.)
								DT8->DT8_VALPAS := GDFieldGet('DIA_VALFOB',nI)
								DT8->DT8_VALTOT := GDFieldGet('DIA_VALFOB',nI)
								DT8->(MsUnLock())
							EndIf
						Next nI
						RecLock('DT6',.F.)
						DT6->DT6_PESO   := DIK->DIK_PESO
						DT6->DT6_PESLIQ := DIK->DIK_PESLIQ
						DT6->DT6_METRO3 := DIK->DIK_METRO3
						DT6->DT6_VALMER := DIK->DIK_VALOR
						DT6->DT6_VALFRE := nValFOB
						DT6->DT6_VALTOT := nValFOB
						DT6->DT6_VALFAT := nValFOB
						DT6->(MsUnLock())
					Else   	  
									    
						DT6->(dbSetOrder(1))
						cSerDeb := 'D01'
						While .T.
							If DT6->(!dbSeek(xFilial('DT6')+DIK->(DIK_FILDOC+DIK_DOC)+cSerDeb))
								Exit
							EndIf
							cSerDeb := Soma1(cSerDeb)
						EndDo
						RestArea(aAreaDT6) 
						aCampos  := {}
						Aadd( aCampos, { 'DT6_SERIE' , cSerDeb } )
						Aadd( aCampos, { 'DT6_FILVGA', CriaVar('DT6_FILVGA',.F.) } )
						Aadd( aCampos, { 'DT6_NUMVGA', CriaVar('DT6_NUMVGA',.F.) } )
						Aadd( aCampos, { 'DT6_TIPFRE', '2' } )
						Aadd( aCampos, { 'DT6_FILDCO', DIK->DIK_FILDOC } )
						Aadd( aCampos, { 'DT6_DOCDCO', DIK->DIK_DOC    } )
						Aadd( aCampos, { 'DT6_SERDCO', DIK->DIK_SERIE  } )
						Aadd( aCampos, { 'DT6_VALFRE', nValFOB } )
						Aadd( aCampos, { 'DT6_VALIMP', 0 } )
						Aadd( aCampos, { 'DT6_VALTOT', nValFOB } )
						Aadd( aCampos, { 'DT6_VALFAT', nValFOB } )
						Aadd( aCampos, { 'DT6_CLIDEV', DT6->DT6_CLIDES } )
						Aadd( aCampos, { 'DT6_LOJDEV', DT6->DT6_LOJDES } )
						Aadd( aCampos, { 'DT6_STATUS', '7'  } ) //-- Entregue
						DT6->(TmsCopyReg(aCampos))
						RestArea(aAreaDT6)
						//-- Atualiza composicao de frete do novo documento
						aCompPrd := {}
						DBSelectArea('DT8')
						DT8->(dbSetOrder(2))
						If DT8->(dbSeek(cSeekDT8 := xFilial('DT8')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE)))
							While DT8->(!Eof()) .And. DT8->(DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE) == cSeekDT8
								If (nPosComp:= Ascan(aCompPrd,{ | e | e[1] == DT8->DT8_CODPRO })) == 0
									Aadd(aCompPrd,{ DT8->DT8_CODPRO, 0, 0, 0 })
									nPosComp := Len(aCompPrd)
								EndIf								
								aAreaDT8 := DT8->(GetArea())
								aCampos  := {}                                               
								nValImp  := 0
								If DT8->DT8_CODPAS == 'TF'
									nValPas := 0
									nValTot := 0
								Else								
									nValPas := Posicione('DIA',2,xFilial('DIA')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE),'DIA_VALFOB')
									nValTot := nValPas
								EndIf								
								aCompPrd[nPosComp,2] += nValPas
								aCompPrd[nPosComp,3] += nValImp
								aCompPrd[nPosComp,4] += nValTot
								Aadd( aCampos, { 'DT8_SERIE'  , cSerDeb } )
								Aadd( aCampos, { 'DT8_VALPAS' , nValPas } )
								Aadd( aCampos, { 'DT8_VALIMP' , nValImp } )
								Aadd( aCampos, { 'DT8_VALTOT' , nValTot } )
								DT8->(TmsCopyReg(aCampos))
								RestArea(aAreaDT8)
								DT8->(dbSkip())
							EndDo
							For nCnt := 1 To Len(aCompPrd)
								If DT8->(dbSeek(xFilial('DT8')+DIK->(DIK_FILDOC+DIK_DOC)+cSerDeb+aCompPrd[nCnt,1]+'TF'))
									RecLock('DT8',.F.)
									DT8->DT8_VALPAS := aCompPrd[nCnt,2]
									DT8->DT8_VALIMP := aCompPrd[nCnt,3]
									DT8->DT8_VALTOT := aCompPrd[nCnt,4]
								EndIf									
							Next nCnt													
						EndIf					
					EndIf
				EndIf
				cNumCMP := DT6->DT6_NUMCMP
				lDocDeb := .F.
				DT6->(dbSetOrder(8))
				DT6->(dbSeek(cSeekDT6 := xFilial('DT6')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE)))
				While DT6->(!Eof()) .And. DT6->(DT6_FILIAL+DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO) == cSeekDT6
					If DT6->DT6_DOCTMS == 'J' .And. DT6->DT6_NUMCMP == cNumCMP .And. DT6->DT6_TIPFRE == '2' //-- Fob
						lDocDeb := .T.
						Exit
					EndIf
					DT6->(dbSkip())
				EndDo
				/*
				If lDocDeb
					//-- Apaga DT8
					DT8->(dbSetOrder(2))
					DT8->(dbSeek(cSeekDT8 := xFilial('DT8')+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)))
					While DT8->(!Eof()) .And. DT8->(DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE) == cSeekDT8
						RecLock('DT8',.F.)
						dbDelete()
						MsUnLock()
						DT8->(dbSkip())
					EndDo														
					//-- Apaga DT6
					RecLock('DT6',.F.)
					dbDelete()
					MsUnLock()
				EndIf
				*/
			EndIf
		EndIf			
		//-- Atualiza DIB (Histórico de alterações)			
		DIB->(dbSetOrder(1))
		If DIB->(dbSeek(cSeek := xFilial('DIB')+DIK->DIK_FILORI+DIK->DIK_LOTNFC+cSerieDoc))
			While DIB->(!Eof()) .And. DIB->(DIB_FILIAL+DIB_FILDOC+DIB_DOC+DIB_SERIE) == cSeek
				DIB->(dbSkip())					
				nRecnoDIB := DIB->(Recno())
				DIB->(dbSkip(-1))
				RecLock('DIB',.F.)
				DIB->DIB_FILDOC := DIK->DIK_FILDOC
				DIB->DIB_DOC    := DIK->DIK_DOC
				DIB->DIB_SERIE  := DIK->DIK_SERIE
				DIB->(MsUnLock())
				DIB->(dbGoTo(nRecnoDIB))
			EndDo
		EndIf
		TMAI70DIB(DIK->DIK_FILDOC,DIK->DIK_DOC,DIK->DIK_SERIE)
		//-- Pesquisa MIC/DTA para regerar
		DII->(dbSetOrder(2))
		If DII->(dbSeek(xFilial('DII')+DIK->DIK_FILDOC+DIK->DIK_DOC+DIK->DIK_SERIE))
			DII->(dbSetOrder(1))		
			DID->(dbSetOrder(1))		
			If DID->(dbSeek(xFilial('DID')+DII->(DII_FILMIC+DII_NUMMIC+DII_CODVEI)))
				TMAI45Rge()
			EndIf				
		EndIf
	Else
		TMAI70DIB(DIK->DIK_FILORI,DIK->DIK_LOTNFC,cSerieDoc)
	EndIf
	End Transaction  
ElseIf lRet .And. nOpcx == 5
	
	Begin Transaction
	   
	cSeekDIK := DIK->DIK_FILORI+DIK->DIK_LOTNFC
	   
	//-- Tabela DIK
	RecLock('DIK',.F.)
	dbDelete()
	MsUnLock()
	//-- Tabela DIN
	DIN->(dbSetOrder(1))
	DIN->(dbSeek(cSeek := xFilial('DIN')+cSeekDIK))
	While DIN->(!Eof()) .And. DIN->(DIN_FILIAL+DIN_FILORI+DIN_LOTNFC) == cSeek
		DTC->(dbSetOrder(2))
		DTC->(dbSeek(cSeekDTC := xFilial('DTC')+DIN->(DIN_NUMNFC+DIN_SERNFC)+M->DIK_CLIREM+M->DIK_LOJREM+DIN->(DIN_CODPRO+DIN_FILORI+DIN_LOTNFC)))
		While DTC->(!Eof()) .And. DTC->(DTC_FILIAL+DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM+DTC_CODPRO+DTC_FILORI+DTC_LOTNFC) == cSeekDTC
			RecLock('DTC',.F.)
			dbDelete()
			MsUnLock()
			DTC->(dbSkip())
		EndDo
		RecLock('DIN',.F.)
		dbDelete()
		MsUnLock()
		DIN->(dbSkip())
	EndDo		
	//-- Tabela DI9
	DI9->(dbSetOrder(1))
	DI9->(dbSeek(cSeek := xFilial('DI9')+cSeekDIK))
	While DI9->(!Eof()) .And. DI9->(DI9_FILIAL+DI9_FILORI+DI9_LOTNFC) == cSeek
		RecLock('DI9',.F.)
		dbDelete()                                                                                                  
		MsUnLock()                                                                                                   
		DI9->(dbSkip())
	EndDo
	//-- Tabela DIA
	DIA->(dbSetOrder(1))
	DIA->(dbSeek(cSeek := xFilial('DIA')+cSeekDIK))
	While DIA->(!Eof()) .And. DIA->(DIA_FILIAL+DIA_FILORI+DIA_LOTNFC) == cSeek
		RecLock('DIA',.F.)
		dbDelete()
		MsUnLock()
		DIA->(dbSkip())
	EndDo
	//-- Tabela DTP
	DTP->(dbSetOrder(2))
	DTP->(dbSeek(xFilial('DTP')+cSeekDIK))
	RecLock('DTP',.F.)
	dbDelete()
	MsUnLock()
	
	End Transaction	
	
ElseIf lRet .And. nOpcx == 6
	RecLock('DIK',.F.)
	DIK->DIK_STATUS := '9' //-- Cancelado
	MsUnLock()
	DIK->(dbCommit())

	If TMSA200Est('DTP',DTP->(Recno()),5,.F.)
	   RecLock('DIK',.F.)
	   DIK->DIK_DATCAN := M->DIK_DATCAN
	   DIK->DIK_STATUS := '9' //-- Cancelado
	   MSMM(DIK->DIK_CODOBC,,,M->DIK_OBSCAN,1,,,"DIK","DIK_CODOBC")
	   MsUnLock()
	   DIK->(dbCommit())
	Else
	   RecLock('DIK',.F.)
	   DIK->DIK_STATUS := M->DIK_STATUS //-- Mantem o Status atual
	   MsUnLock()
	   DIK->(dbCommit())
	EndIf                                                                                                       
EndIf

CursorArrow()

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMAI70DIB ºAutor  ³ Richard Anderson   º Data ³  23/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gravacao das Alteracoes no campos do CRT                   º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMAI70DIB(cFilDoc,cDoc,cSerie)
Local aARea		 := GetArea()
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local cSeq      := ''
Local nI			 := 0 

//-- Tratar os campos do tipo numero e data
TMAI70Tmm()

dbSelectArea("DIB")
cQuery := "SELECT MAX(DIB_SEQUEN) SEQ FROM "
cQuery += RetSqlName("DIB")+" DIB "
cQuery += " WHERE DIB.DIB_FILIAL = '"+xFilial("DIB")+"'"
cQuery += "   AND DIB.DIB_FILDOC = '"+cFilDoc+"' "
cQuery += "   AND DIB.DIB_DOC    = '"+cDoc+"' "
cQuery += "   AND DIB.DIB_SERIE  = '"+cSerie+"' "
cQuery += "   AND DIB.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
cSeq := StrZero(1,Len(DIB->DIB_SEQUEN))
If !Empty((cAliasQry)->SEQ)
	cSeq := Soma1((cAliasQry)->SEQ)
EndIf
(cAliasQry)->(dbCloseArea())

For nI := 1 To Len(aCRTCamp)
	If aCRTCamp[nI,3]
		RegToMemory('DIB',.T.)
		RecLock('DIB',.T.)
		DIB->DIB_FILIAL := xFilial('DIB')
		DIB->DIB_FILDOC := cFilDoc
		DIB->DIB_DOC    := cDoc
		DIB->DIB_SERIE  := cSerie
		DIB->DIB_FILORI := M->DIB_FILORI
		DIB->DIB_DATALT := M->DIB_DATALT
		DIB->DIB_HORALT := M->DIB_HORALT
		DIB->DIB_USER   := M->DIB_USER
		DIB->DIB_CPODOC := aCRTCamp[nI,2]
		DIB->DIB_SEQUEN := cSeq
		MSMM(DIB->DIB_CODINF,,,M->(&(aCRTCamp[nI,1])),1,,,"DIB","DIB_CODINF")
		MsUnlock()		
	EndIf
Next

RestArea(aArea)

Return(Nil) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMAI70Tmm ºAutor  ³Richard Anderson    º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Conversao de Dados para a gravacao do memo                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSAI70                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMAI70Tmm()
Local ic      	:= 0
Local cTexto   := ''
Local cxPict   := '@!'

For ic := 1 To Len(aCRTCamp)
	If ValType(M->(&(aCRTCamp[ic,1]))) == 'N'
	   If Len(aCRTCamp[ic]) == 5
			cxPict := aCRTCamp[ic,5]
		Else
			cxPict := '@!'		
		EndIf
		cTexto := Transform(M->(&(aCRTCamp[ic,1])),cxPict)
	ElseIf ValType(M->(&(aCRTCamp[ic,1]))) == 'D'
		cTexto := DTOC(M->(&(aCRTCamp[ic,1])))
	Else
		cTexto := M->(&(aCRTCamp[ic,1]))
	EndIf
	
	M->(&(aCRTCamp[ic,1])) := cTexto
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70Cmp³ Autor ³ Richard Anderson      ³ Data ³30.11.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna composicao do Frete para o controle de alterações  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMAI70Cmp()

Local nI         := 0
Local cDescri    := '' 
Local aSavCols   := Iif(Type('aCols')   == 'A',aCols  ,{})
Local aSavHeader := Iif(Type('aHeader') == 'A',aHeader,{}) 

If !Empty(aSvHeader[1])
	aHeader:= AClone(aSvHeader[1])
	aCols  := AClone(aSvCols[1])
EndIf	

//-- Campo 15: Frete
M->DIK_CMPFRE := STR0043+Chr(13)+Chr(10) //-- "Componente                      Valor CIF   Valor FOB"
//--              X--------------30------------X 999,999.99  999,999.99

For nI := 1 To Len(aCols)
	If GDFieldGet('DIA_CODPAS',nI) == 'TF'
		cDescri := Padr(STR0044,Len(DT3->DT3_DESCRI)) //-- "TOTAL DO FRETE"
	Else
		cDescri := Posicione('DT3',1,xFilial('DT3')+GDFieldGet('DIA_CODPAS',nI),'DT3_DESCRI')			
	EndIf		
	M->DIK_CMPFRE += cDescri+' '+;
				        TransForm(GDFieldGet('DIA_VALCIF',nI),'@E 999,999.99')+' '+;
				        TransForm(GDFieldGet('DIA_VALFOB',nI),'@E 999,999.99')+' '+;
				        Chr(13)+Chr(10)
Next nI				        

If Ascan(aCRTCamp,{ | e | e[1] == 'DIK_CMPFRE' }) == 0
	Aadd(aCRTCamp,{"DIK_CMPFRE","15",.F.,M->DIK_CMPFRE})
EndIf

//-- Restaura aCols original
aHeader := AClone(aSavHeader)
aCols   := AClone(aSavCols)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70Leg³ Autor ³ Richard Anderson      ³ Data ³30.11.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a legenda do status do CRT                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMAI70Leg()

BrwLegenda( cCadastro,  STR0016 	,;  	//'Status'
{	{  'BR_AMARELO'	,  STR0017 	},;  	//'Em Aberto'
{ 		'BR_VERDE'   	,  STR0018 	},;  	//'Gerado'   
{ 		'BR_VERMELHO'  ,  STR0019 	},;  	//'Alterado'
{ 		'BR_AZUL'  		,  STR0080  },; 	//'Regerado'
{ 		'BR_PRETO'		,  STR0020 	}})  	//'Cancelado'

Return NIL


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70Reg³ Autor ³ Rodolfo K. Rosseto    ³ Data ³06.03.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Regerar o CRT                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1- Filial de Origem                                     ³±±
±±³          ³ExpC2- Numero do Lote                                       ³±±
±±³          ³ExpC3- Filial do Documento                                  ³±±
±±³          ³ExpC4- Num. do Documento                                    ³±±
±±³          ³ExpC5- Serie do Documento                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMAI70Reg(cFilOri,cNumLote,cFilDoc,cDoc,cSerie)

Local cFilSF2   := xFilial('SF2')
Local cFilSD2   := xFilial('SD2')
Local cSeekDIN  := ""
Local cSeekDTC  := ""
Local cCliente  := ""
Local cLoja     := ""
Local lTMSUFPAG := SuperGetMv("MV_TMSUFPG",.F.,.F.) //-- Define se grava o estado do pagador do frete.
Local cFilVge   := ""
Local cNumVge   := ""
Local cCodPro   := ""
Local nCnt      := 0
Local cAliasQry := ""
Local cQuery    := ""

SA1->(dbSetOrder(1))

// Este parametro MV_TMSUFPG e usado somente para efeito de gravacao do estado / tipo do cliente 
// ( Consumidor Final / Revendedor ) para o Livro Fiscal , nao deve ser utilizado para gravacao
// dos clientes pois a figura de cliente no SD2/SF2 sera sempre o cliente devedor obedecendo as
// regras CIF/FOB determinadas na geracao do conhecimento. "DIK->DIK_CLIDEV + DIK_LOJDEV"

If lTMSUFPAG //Cliente Pagador do Frete
	SA1->(dbSeek(xFilial('SA1')+DIK->DIK_CLIDEV+DIK->DIK_LOJDEV))
Else //Cliente Destinatario
	SA1->(dbSeek(xFilial('SA1')+DIK->DIK_CLIDES+DIK->DIK_LOJDES))
EndIf

//--Atualizar SF2
SF2->(dbSetOrder(1))
If SF2->(dbSeek(IIf(Empty(cFilSF2),cFilSF2,cFilDoc)+cDoc+cSerie))
	RecLock("SF2",.F.)
	SF2->F2_CLIENTE := DIK->DIK_CLIDEV
	SF2->F2_LOJA    := DIK->DIK_LOJDEV
	SF2->F2_PLIQUI  := DIK->DIK_PESO
	SF2->F2_PBRUTO  := DIK->DIK_PESO
	SF2->F2_EST     := SA1->A1_EST
	SF2->F2_TIPOCLI := SA1->A1_TIPO
	SF2->(MsUnLock())
EndIf

//--Atualizar SD2
cAliasQry   := GetNextAlias()
cQuery := " SELECT R_E_C_N_O_ RECSD2 "
cQuery += "   FROM " + RetSqlName("SD2")
cQuery += "  WHERE D2_FILIAL = '"+IIf(Empty(cFilSD2),cFilSD2,cFilDoc)+"'"
cQuery += " 	AND D2_DOC    = '"+cDoc+"'"
cQuery += " 	AND D2_SERIE  = '"+cSerie+"'"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
While (cAliasQry)->(!Eof())
	SD2->(dbGoTo((cAliasQry)->RECSD2))
	RecLock("SD2",.F.)
   SD2->D2_CLIENTE := DIK->DIK_CLIDEV
   SD2->D2_LOJA    := DIK->DIK_LOJDEV
	SD2->D2_SERVIC  := DIK->DIK_SERVIC
	SD2->D2_EST     := SA1->A1_EST
	SD2->(MsUnLock())
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())

//--Guardo o Cliente Remetente do DT6(cCliente,cLoja), pois ele pode ter sido alterado, entao preciso pesquisar a nota fiscal
//--com o cliente antes da alteracao.
//--Atualizar o DT6
DT6->(dbSetOrder(1))
If DT6->(dbSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie))
	RecLock("DT6",.F.)
	cFilVge          := DT6->DT6_FILVGA
	cNumVge          := DT6->DT6_NUMVGA
	cCliente         := DT6->DT6_CLIREM
	cLoja            := DT6->DT6_LOJREM
	DT6->DT6_CLIREM := DIK->DIK_CLIREM
	DT6->DT6_LOJREM := DIK->DIK_LOJREM
	DT6->DT6_CLIDES := DIK->DIK_CLIDES
	DT6->DT6_LOJDES := DIK->DIK_LOJDES
	DT6->DT6_CLICON := DIK->DIK_CLICON
	DT6->DT6_LOJCON := DIK->DIK_LOJCON
	DT6->DT6_CLIDEV := DIK->DIK_CLIDEV
	DT6->DT6_LOJDEV := DIK->DIK_LOJDEV
	DT6->DT6_CLICAL := DIK->DIK_CLIDEV
	DT6->DT6_LOJCAL := DIK->DIK_LOJDEV
	DT6->(MsUnLock())
EndIf

//--Atualizar o DTA
DTA->(dbSetOrder(1))
If DTA->(dbSeek(xFilial('DTA')+cFilDoc+cDoc+cSerie+cFilVge+cNumVge))
	RecLock("DTA",.F.)
	DTA->DTA_QTDVOL := DT6->DT6_VOLORI
	DTA->DTA_VALFRE := DT6->DT6_VALFRE
	DTA->(MsUnLock())
EndIf

//--Atualizar o DUD
DUD->(dbSetOrder(1))	
If DUD->(dbSeek(xFilial('DUD')+DIK->DIK_FILDOC+DIK->DIK_DOC+DIK->DIK_SERIE))
	RecLock("DUD",.F.)
	DUD->DUD_CDRCAL := DIK->DIK_CDRCAL
	DUD->(MsUnlock())
EndIf

//Preciso pegar todos os DIN's deste documento, posicionar no DTC e atualizar.
//--No internacional nao precisa usar cliente remetente pois o lote e automatico, e nao pode ter clientes diferentes como o nacional
//--Pode ser que o produto ja esta alterado no DIN, e no DTC nao, precisa pesquisar pelo produto anterior
DIN->(dbSetOrder(1))	
DTC->(dbSetOrder(2))	
If DIN->( dbSeek(cSeekDIN := xFilial('DIN')+DIK->DIK_FILORI+DIK->DIK_LOTNFC))	
	//--Como nao pode informar dois produtos, pega o primeiro produto, que sera o mesmo em todos os itens
	cCodPro := DIN->DIN_CODPRO
	While DIN->(!Eof()) .And. DIN->(DIN_FILIAL+DIN_FILORI+DIN_LOTNFC) == cSeekDIN
		//--Temos um DIN para cada linha do aCols ou aColsAnt, por isso nao precisa de For no aCols
		nCnt += 1

		cSeekDTC := xFilial('DTC')+GDFieldGet('DIN_NUMNFC',nCnt)+GDFieldGet('DIN_SERNFC',nCnt)+cCliente+cLoja+;
						GDFieldGet('DIN_CODPRO',nCnt)+DIN->DIN_FILORI+DIN->DIN_LOTNFC
	
		//--Atualizar DTC, caso ainda nao tenha feito pela rotina automatica
		If DTC->( dbSeek(cSeekDTC))
			RecLock("DTC",.F.)
			DTC->DTC_CLIREM := DIK->DIK_CLIREM
			DTC->DTC_LOJREM := DIK->DIK_LOJREM
			DTC->DTC_CLIDES := DIK->DIK_CLIDES
			DTC->DTC_LOJDES := DIK->DIK_LOJDES
			DTC->DTC_CLICON := DIK->DIK_CLICON
			DTC->DTC_LOJCON := DIK->DIK_LOJCON
			DTC->DTC_CLIDEV := DIK->DIK_CLIDEV
			DTC->DTC_LOJDEV := DIK->DIK_LOJDEV
			DTC->DTC_CLICAL := DIK->DIK_CLIDEV
			DTC->DTC_LOJCAL := DIK->DIK_LOJDEV
			DTC->DTC_CLINOT := DIK->DIK_CLINOT
			DTC->DTC_LOJNOT := DIK->DIK_LOJNOT
			DTC->DTC_SERVIC := DIK->DIK_SERVIC
			DTC->DTC_CDRCAL := DIK->DIK_CDRCAL
			DTC->DTC_SELORI := DIK->DIK_SELORI
			DTC->DTC_ROTA   := DIK->DIK_ROTA
			DTC->DTC_INCOTE := DIK->DIK_INCOTE
			DTC->DTC_SERTMS := DIK->DIK_SERTMS
			DTC->DTC_DEVFRE := DIK->DIK_DEVFRE
			DTC->DTC_TIPFRE := DIK->DIK_TIPFRE
			DTC->DTC_FILCFS := DIK->DIK_FILCFS
			DTC->DTC_NUMSOL := DIK->DIK_NUMSOL
			DTC->DTC_DATCOL := DIK->DIK_DATCOL
			DTC->DTC_HORCOL := DIK->DIK_HORCOL
			DTC->DTC_VALSEG := DIK->DIK_VALSEG
			DTC->(MsUnLock())
		EndIf
		DIN->(dbSkip())
	EndDo
EndIf     

//--Atualizar o DT8, com o produto da nota, nao pode incluir dois produtos no internacional
cAliasQry   := GetNextAlias()
cQuery := " SELECT R_E_C_N_O_ RECDT8 "
cQuery += "   FROM " + RetSqlName("DT8")
cQuery += "  WHERE DT8_FILIAL = '"+xFilial("DT8")+"'"
cQuery += " 	AND DT8_FILDOC = '"+cFilDoc+"'"
cQuery += " 	AND DT8_DOC    = '"+cDoc+"'"
cQuery += " 	AND DT8_SERIE  = '"+cSerie+"'"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
While (cAliasQry)->(!Eof())
	DT8->(dbGoTo((cAliasQry)->RECDT8))
	RecLock("DT8",.F.)
	DT8->DT8_CODPRO := cCodPro
	DT8->(MsUnLock())
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())
//--Posicionar em alguma area, devido a fechar a query
dbSelectArea('DT8')   

//-- Atualizar DTP, quando ocorrer a inclusao de mais NFCs 
DTP->(dbSetOrder(2))
If DTP->(dbSeek(xFilial('DTP')+DIK->DIK_FILORI+DIK->DIK_LOTNFC))
	RecLock('DTP',.F.)
	DTP->DTP_QTDDIG := nCnt  
	DTP->DTP_QTDLOT := nCnt
	MsUnLock()
EndIf	   
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70Vis³ Autor ³ Rodolfo K. Rosseto    ³ Data ³12.03.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza a Carta de Correcao, atraves do CRT				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMAI70Vis()

Local cFiltraSub := ""
Local aCampos    := {'DIC_FILDOC','DIC_DOC','DIC_SERIE','DIC_SEQUEN'}
Local aRot       := {}

Private nOpcSel  := 0

Aadd( aRot, { STR0081 ,"TMSConfSel",0,2,,,.T.} ) // "&Confirmar"

cFiltraSub := '"'+xFilial("DIC")+DIK->DIK_FILDOC+DIK->DIK_DOC+DIK->DIK_SERIE+'"'

MaWndBrowse(0,0,300,600,STR0082,"DIC",aCampos,aRot,,cFiltraSub,cFiltraSub,.T.,,,,,) //--"Carta de Correcao"

If nOpcSel == 1 //Confirmar
	TMAI40Mnt("DIC", DIC->(Recno()), 2)
EndIf
	
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70I1 ³ Autor ³ Alex Egydio           ³ Data ³31.10.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao do CRT 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
*/
Function TMAI70I1()      

If	ExistBlock("RTMSR17")     
	
	ExecBlock("RTMSR17",.F.,.F.)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI70I1 ³ Autor ³ Alex Egydio           ³ Data ³31.10.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao do CRT Grafico  											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
*/

Function TMAI70I2()  

If	ExistBlock("RTMSR20") 
	 
	ExecBlock("RTMSR20",.F.,.F.)
EndIf                                     

Return      

                                                                             
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³I070ValInf³ Autor ³ Fabio M Sampaio       ³ Data ³ 22/01/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valor Informado da nota fiscal / cotacao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050ValInf(ExpN1,ExpC1,ExpC2,ExpC3)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±³          ³ ExpC1 - Nota Fiscal                                        ³±±
±±³          ³ ExpC2 - Serie                                              ³±±
±±³          ³ ExpC3 - Produto                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAI070                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function I070ValInf(nOpcx,cNumNfc,cSerNfc,cCodPro)

Local nCnt      := 0
Local aTabFre   := {}
Local cTabFre   := ''
Local cTipTab   := ''
Local lContinua := .T.
Local cFilOri   := cFilAnt
Local nI		:= 0
Local cItemD2	:= ''
Local cPrdImp	:= ''

If Empty(cNumNfc) .Or. Empty(cCodPro)
	Help("",1,"TMSA05066") //Para apresentar o valor informado, devera ser digitada a nota fiscal e o produto
Else

	//-- Na inclusao, verifica se existe valor informado na cotacao.
	If nOpcx == 3
		For nCnt := 1 To Len(aValInf)
			//-- Atualiza a nota fiscal do valor informado para o produto atual.
			If	aValInf[nCnt,6] == cCodPro .And. aValInf[nCnt,4] <> cNumNfc .And. aValInf[nCnt,5] <> cSerNfc
				aValInf[nCnt,4] := cNumNfc
				aValInf[nCnt,5] := cSerNfc
				aValInf[nCnt,3] := .F.
			EndIf
		Next nCnt
	EndIf                                            	

	//-- Pesquisa a tabela de frete do cliente
	If (nOpcx == 3 .Or. nOpcx == 4)
		lContinua := .F.
		aTabFre := TmsTabFre(M->DIK_CLIDEV,M->DIK_LOJDEV,M->DIK_SERVIC,M->DIK_TIPFRE)
		If !Empty(aTabFre)
			cTabFre   := aTabFre[1]
			cTipTab   := aTabFre[2]
			lContinua := .T. 
		EndIf

		If !lContinua .And. (Empty(cTabFre) .Or. Empty(cTipTab))
			If MsgYesNo( STR0090 ) //"Tabela de Frete não localizada, deseja apresentar todos componentes do tipo valor informado ?"
				lContinua := .T.
			EndIf
		EndIf
	EndIf

	//-- Valor Informado da nota fiscal
	If lContinua
		TmsValInf(aValInf,'2',cFilAnt,,M->DIK_LOTNFC,M->DIK_CLIREM,M->DIK_LOJREM,M->DIK_CLIDES,M->DIK_LOJDES,M->DIK_SERVIC,cNumNfc,cSerNfc,cCodPro,nOpcx,,cTabFre,cTipTab,,M->DIK_CODNEG)
		__lAtzFrt := .F.
		
		For nI := 1 To Len(aValInf)
			If aValInf[nI][3] = .T.

			//-- Apaga DT8
				aAreaDT8 := DT8->(GetArea())
				dbSelectArea("DT8")
				dbSetOrder(2)
				If DT8->(dbSeek(xFilial('DT8')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE)+cCodPro+aValInf[nI][1]))
					cItemD2 := DT8->DT8_ITEMD2
					RecLock('DT8',.F.)
					dbDelete()
					MsUnLock()
			   	EndIf         
			   	RestArea(aAreaDT8)

			//-- Apaga DIA
				aAreaDIA := DIA->(GetArea())
				dbSelectArea("DIA") //DIA_FILIAL+DIA_FILDOC+DIA_DOC+DIA_SERIE+DIA_CODPAS                                                                                                              
				dbSetOrder(2)
				If DIA->(dbSeek(xFilial('DIA')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE)+aValInf[nI][1]))
					RecLock('DIA',.F.)
					dbDelete()
					MsUnLock()
			   	EndIf         
			   	RestArea(aAreaDIA)
			//-- Apgada SD2	

				DUI->(dbSetOrder(1))
				If DUI->(dbSeek(xFilial('DUI')+Posicione('DT6',1,xFilial('DT6')+DIK->(DIK_FILDOC+DIK_DOC+DIK_SERIE),'DT6_DOCTMS'))) 
					If DIK->DIK_TIPFRE == '1' .And. !Empty(DUI->DUI_PRDCIF)
						cPrdImp := DUI->DUI_PRDCIF
					Else
						cPrdImp := DUI->DUI_CODPRO
					EndIf
				EndIf																	

	            aAreaSD2 := SD2->(GetArea())
				dbSelectArea("SD2")
				dbSetOrder(3) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM                                                                                                     
	   			If SD2->(dbSeek(xFilial('SD2')+DIK->(DIK_DOC+DIK_SERIE+DIK_CLIDEV+DIK_LOJDEV+cPrdImp+cItemD2)))
					RecLock('SD2',.F.)
					dbDelete()
					MsUnLock()
				EndIf
				RestArea(aAreaSD2) 
			EndIf
		Next nI                                                                 
	EndIf
EndIf

Return
