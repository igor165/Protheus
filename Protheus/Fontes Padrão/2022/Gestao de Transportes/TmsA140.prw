#Include 'Protheus.ch'
#Include 'TmsA140.ch' 
#INCLUDE "FWMVCDEF.CH"

// Diretivas indicando as colunas dos documentos da viagem
#Define CTSTATUS		1
#Define CTSTROTA		2
#Define CTMARCA			3
#Define CTSEQUEN		4
#Define CTARMAZE		5
#Define CTLOCALI		6
#Define CTFILDOC		7
#Define CTDOCTO			8
#Define CTSERIE			9
#Define CTREGDES		10
#Define CTDATEMI		11
#Define CTPRZENT		12
#Define CTNOMREM		13
#Define CTNOMDES		14
#Define CTQTDVOL		15
#Define CTVOLORI		16
#Define CTPLIQUI		17
#Define CTPESOM3		18
#Define CTVALMER		19
#Define CTVIAGEM		20
#Define CTSEQDA7		21
#Define CTSOLICI		22			//-- DUE_NOME
#Define CTENDERE		23			//-- DUE_END
#Define CTBAIRRO		24			//-- DUE_BAIRRO
#Define CTMUNICI		25			//-- DUE_MUN
#Define CTDATSOL		26			//-- DT5_DATSOL
#Define CTHORSOL		27			//-- DT5_HORSOL
#Define CTDATPRV		28			//-- DT5_DATPRV
#Define CTHORPRV		29			//-- DT5_HORPRV
#Define CTDOCROT		30			//-- Codigo que identifica a q rota pertence o documento
#Define CTBLQDOC		31			//-- Tipos de bloqueio do documento
#Define CTNUMAGE		32			//-- Numero do Agendamento( Carga Fechada ).
#Define CTITEAGE		33			//-- Item do Agendamento( Carga Fechada ).
#Define CTSERTMS		34			//-- Tipo do Servico.
#Define CTDESSVT		35			//-- Descricao do Servico.
#Define CTESTADO		36
#Define CTDATENT		37
#Define CTUNITIZ		38
#Define CTCODANA		39
/*-- 
Defines abaixo precisam ser ajustados conforme TMSA141 
#Define CT40     		40			
#Define CT41     		41			
#Define CT42     		42			
#Define CT43     		43			
#Define CT44     		44			
#Define CT45       	45			
*/
//--- Estrutura da Integracao TMS x GFe 
#Define CTUFORI      46        //-- UF Origem (Integracao GFE)
#Define CTCDMUNO     47        //-- Cod.Municipio Origem (Integracao GFE)
#Define CTCEPORI     48        //-- Cep Origem (Integracao GFE)
#Define CTUFDES      49        //-- UF Destino (Integracao GFE)
#Define CTCDMUND     50        //-- Cod.Municipio Destino (Integracao GFE)
#Define CTCEPDES     51        //-- Cep Destino (Integracao GFE)
#Define CTTIPVEI     52        //-- Tipo Veiculo (Integracao GFE)
#Define CTCDCLFR     53        //-- Cod.Classificacao Frete (Integracao GFE)
#Define CTCDTPOP     54        //-- Tipo de Operação (Integraçao GFE)
#Define CTORIGEM	 55			//-- Origem Carregamento.

Static lViagem3   := FindFunction("TMSAF60") .And. AliasInDic("DM3")

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA140  ³ Autor ³ Alex Egydio           ³ Data ³28.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Geracao de Viagens                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = String com expressao inicial para mbrowse.         ³±±
±±³          ³ ExpC2 = String com expressao final   para mbrowse.         ³±±
±±³          ³ ExpC3 = Tipo de Servico TMS.                               ³±±
±±³          ³ ExpC4 = Tipo de Transporte TMS.                            ³±±
±±³          ³ ExpN1 = Indice do DTQ que interage com ExpC1 e ExpC2.      ³±±
±±³          ³ ExpN2 = Nr. da Opcao se chamado do Manifesto de cargas.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140(cSer140,cTra140,nInd140,nOpc140,cFil140,cVge140)

Local aAreaAnt		:= GetArea()
Local aAreaDTQ		:= DTQ->(GetArea())
Local aCores		:= {}
Local cFilMbrow  	:= ""
Local aRet          := {}
Local cProgCall  := ''

Private cFiltro   	:= ""

Private aIndex  	:= {}
Private bFiltraBrw
Private cCadastro	:= STR0007 //'Geracao de Viagens'
Private cSerTms		:= cSer140
Private cTipTra		:= cTra140
Private aRotina     := MenuD140(cTipTra)

DEFAULT cSer140		:= ''
DEFAULT cTra140		:= ''
DEFAULT nInd140		:= 3
DEFAULT nOpc140		:= 0
DEFAULT cFil140		:= ''
DEFAULT cVge140		:= ''

aCores := TMSa140Cor()

DbSelectArea('DTQ')

If nOpc140 > 0
	//-- Viagem jah deve estar posicionada
	aRet := TMSA140Mnt( 'DTQ', Recno(), nOpc140 )
Else
	If !Empty(cFil140)
		DbSetOrder( 2 )
		cFilMbrow := "DTQ_FILIAL = '" + xFilial("DTQ") + "' AND DTQ_FILORI = '" + cFil140 +"' AND DTQ_VIAGEM = '" + cVge140 +"'"  
	Else
		DbSetOrder( nInd140 )
		cFilMbrow := "DTQ_FILIAL = '" + xFilial("DTQ") + "' AND DTQ_SERTMS = '" + cSerTms + "' AND DTQ_TIPTRA = '" + cTipTra + "'"
	EndIf
	
	//Determina qual a rotina que deve ter a restricao de privilegios validada no menu.
	If 		cSer140 == StrZero(2,Len(DC5->DC5_SERTMS))	//TRANSPORTE
		If 		cTra140 == StrZero(1,Len(DC5->DC5_TIPTRA))//RODOVIARIO
				cProgCall := 'TMSA140A'
		ElseIf cTra140 == StrZero(2,Len(DC5->DC5_TIPTRA))//AEREO
				cProgCall := 'TMSA140B'
		ElseIf cTra140 == StrZero(3,Len(DC5->DC5_TIPTRA))//FLUVIAL
				cProgCall := 'TMSA140C'
		ElseIf cTra140 == StrZero(4,Len(DC5->DC5_TIPTRA))//INTERNACIONAL
				cProgCall := 'TMSA140D'								
		EndIf
	EndIf
	
	//-- Endereca a funcao de BROWSE
	mBrowse(6,1,22,75,'DTQ',,,,,,aCores,,,,,,,,cFilMbrow,,,,,{|oBrowse| oBrowse:SetMainProc(cProgCall)})  			
EndIf

SetKey( VK_F12, Nil )

RestArea( aAreaDTQ )
RestArea( aAreaAnt )

Return Aclone(aRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA140Mnt³ Autor ³ Alex Egydio           ³ Data ³28.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao de Viagens                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA140Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140Mnt( cAlias, nReg, nOpcx )

Local aAreaAnt		:= GetArea()
Local aAreaDUY		:= DUY->(GetArea())
Local aAreaDTA		:= DTA->(GetArea())
Local aAreaDTY		:= DTY->(GetArea())
Local aAreaDTQ		:= DTQ->(GetArea())
Local xRet			:= Nil
//-- Controle de dimensoes de objetos
Local aSize			:= {}
Local aObjects		:= {}
Local aInfo			:= {}
Local aPosObjH		:= {}
//-- EnchoiceBar
Local aButtons		:= {}
Local aUsButtons	:= {}
Local aHRota		:= {}
Local cHDlgEsp		:= ''
Local cLbx1			:= ''
Local nOpca			:= 0
Local nSeek			:= 0
Local nCount		:= 0
Local nPosDTQ    := 0
Local cMay 			:= ""
Local cFilOri   	:= ""
Local cViagem     	:= ""
Local cSeek    		:= ""
Local lRet       	:= .T.
Local lAberto     	:= .T.
Local lManViag    	:= GetNewPar("MV_MANVIAG",.F.) //-- Permite configurar se e possível manifestar uma viagem que ainda nao esta disponivel na filial corrente                       
Local cAtivSai	   	:= GetMV('MV_ATIVSAI',,'') //-- Atividade de Saida de Viagem
Local aPosicao    	:= {}
Local nCnt        	:= 0
Local lContVei    	:= GetMv("MV_CONTVEI")
Local lMV_EmViag   	:= GetMV('MV_EMVIAG',,.F.)
Local cStatus     	:= ''
Local cCodUser  	:= RetCodUsr()

//-- Variaveis p/controle generico
Local aSx3Box		:= {}
Local oPanel

Local lTercRbq      := DTR->(ColumnPos("DTR_CODRB3")) > 0

Local nCntFor1      := 0
Local nPos          := 0
Local cMV_TMSRRE    := SuperGetMv("MV_TMSRRE",.F.,"") //1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
Private aRota		:= {}
Private aDocto		:= {}
Private aBkpDocto	:= {}
Private aMemos    	:= { { 'DTQ_CODOBS', 'DTQ_OBS' }, { 'DTQ_CODCAN', 'DTQ_OBSCAN' } }
Private aGrpProd	:= {}
Private aRegiao		:= {}
Private aAllDocto	:= {}
Private aSRota		:= {}
Private cGrpProd  	:= ''
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura do Array aCompViag (Complemento de Viagem):             ³
//³ aCompViag[1] - aHeader Complemento de Viagem                      ³
//³ aCompViag[2] - aCols Complemento de Viagem                        ³
//³ aCompViag[3] - aHeader Auxiliar Getdados de Motoristas da Viagem  ³
//³ aCompViag[4] - Array contendo os Motoristas da Viagem             ³
//³ aCompViag[5] - aHeader Auxiliar Getdados de Ajudantes da Viagem   ³
//³ aCompViag[6] - Array contendo os Ajudantes da Viagem              ³
//³ aCompViag[7] - aHeader Auxiliar Getdados de Lacres de veiculos    ³
//³ aCompViag[8] - Array contendo os Lacres dos veiculos			  ³
//³ aCompViag[9] - aHeader Auxiliar Getdados de Adiantamentos         ³
//³ aCompViag[10]- Array contendo os Adiantamentos da Viagem          ³
//³ aCompViag[11]- Data/Hora Inicial e Final da Viagem                ³
//³ aCompViag[12]- Array contendo os componentes com 'Valor Informado'³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCompViag 	:= {}
Private aRetRbq     := {} //-- Retorno de Reboques
Private _cCdrOri	:= PadR(GetMv('MV_CDRORI'),Len(DA8->DA8_CDRORI))
Private oDlgEsp
Private oLbx1
Private oLbxDocto
Private oNoMarked	:= LoadBitmap( GetResources() ,'LBNO'			)
Private oMarked		:= LoadBitmap( GetResources() ,'LBOK'			)
Private oVerde		:= LoadBitmap( GetResources() ,'BR_VERDE'		)
Private oAmarelo  	:= LoadBitmap( GetResources() ,'BR_AMARELO'	  	)
Private oVermelho 	:= LoadBitmap( GetResources() ,'BR_VERMELHO'	)
Private oAzul     	:= LoadBitmap( GetResources() ,'BR_AZUL'		)
Private oPreto		:= LoadBitmap( GetResources() ,'BR_PRETO'		)
Private lTmsA1401	:= ExistBlock('TMSA1401') //-- Permite ao usuario, incluir botoes na enchoicebar
Private lTM141COL 	:= ExistBlock('TM141COL') //-- Permite ao usuario, incluir colunas nos itens.
Private lLocaliz	:= GetMv('MV_LOCALIZ') == 'S'
Private lColeta		:= .F.
Private lChkRtVar 	:= .T.
Private lContDCA  	:= GetMv('MV_CONTDCA',,.F.)
//-- Variaveis do Rodape da Tela (Dados dos Doctos.)
Private nVolumes  	:= 0
Private nPesReal  	:= 0
Private nPesCub   	:= 0
Private nValMerc  	:= 0
Private nDoctos   	:= 0
Private oVolumes  	:= 0
Private oPesReal  	:= 0
Private oPesCub   	:= 0
Private oValMerc  	:= 0
Private oDoctos   	:= 0
//-- Checkbox
Private oAllMark
Private lAllMark
//-- Pergunte
Private nCarreg		:= 0
Private nTipVia		:= 0
Private cRotaDe		:= ''
Private cRotaAte	:= ''
Private cCdrDesDe	:= ''
Private cCdrDesAte	:= ''
Private lDoctoEnd
Private lAllRota  	:= .F.
Private lPagSald  	:= .F.

/* Verifica se o registro n„o est  em uso por outra esta‡„o. */   
If nOpcx == 4 .Or. nOpcx == 5 //-- 4=Alteracao ; 5=Exclusao
	If !SoftLock("DTQ")
		Return( Nil )
	EndIf
EndIf

If Type('aIndex') <> 'U'
	EndFilBrw("DTQ",aIndex)//Limpa o filtro no DTQ para que o usuario possa trabalhar com viagem de todos os tipos de transporte
EndIf
//-- Inclui colunas do usuario
If lTM141COL
	If ValType( aUsHDocto := ExecBlock( 'TM141COL', .F., .F. ) ) <> 'A'
		aUsHDocto := {}
	EndIf
EndIf

AAdd( aPosicao ,CTMARCA  )
AAdd( aPosicao ,CTFILDOC )
AAdd( aPosicao ,CTDOCTO  )
AAdd( aPosicao ,CTSERIE  )

RegToMemory(cAlias,nOpcx==3)

If nOpcx != 3
	nTipVia := Val(M->DTQ_TIPVIA)
EndIf

If nOpcx == 2
	TmsA140Par(.F.,nOpcx)	//-- Informacoes para filtragem
ElseIf nOpcx == 3//-- Se inclusao
	// Ajusta SXE e SXF caso estejam corrompidos.
	cFilOri := M->DTQ_FILORI
	cViagem := M->DTQ_VIAGEM
	cMay 	:= AllTrim(xFilial('DTQ'))+cFilOri+cViagem
	FreeUsedCode()
	DTQ->( DbSetOrder( 2 ) )
	While DTQ->(MsSeek(xFilial('DTQ')+cFilOri+cViagem)) .Or. !MayIUseCode(cMay)
		ConfirmSx8()
		cViagem := CriaVar("DTQ_VIAGEM")
		FreeUsedCode()
		cMay := AllTrim(xFilial('DTQ'))+cFilOri+cViagem
	EndDo
	M->DTQ_FILORI := cFilOri
	M->DTQ_VIAGEM := cViagem
	RestArea( aAreaDTQ )

	If	Empty(_cCdrOri)
		Help(' ', 1, 'TMSA14002')	//-- O parametro MV_CDRORI esta vazio !
		lRet := .F.
	EndIf

	If lRet .And. !TmsA140Par(.T.,nOpcx) //-- Informacoes para filtragem
		lRet := .F.
	EndIf

	M->DTQ_SERTMS := cSerTms
	M->DTQ_TIPTRA := cTipTra

	DTQ->(DbSetOrder(2))
	If	lRet .And. DTQ->(MsSeek(xFilial('DTQ') + M->DTQ_FILORI + M->DTQ_VIAGEM))
		Help(' ', 1, 'TMSA14010',,STR0051 + M->DTQ_FILORI + STR0045 + M->DTQ_VIAGEM,4,1)	//-- Viagem ja cadastrada. (DTQ)###"Filial Origem: "###"Viagem: "
		lRet := .F.
	EndIf
	RestArea( aAreaDTQ )
	If	lRet .And. ( nTipVia == 1 .Or. nTipVia == 3 .Or. (nTipVia == 4 .And. nOpcx != 3) )
		//-- Se encontrar e selecionar grupos de produtos, a viagem sera montada somente com produtos que pertencem a estes
		//-- grupos
		xRet := TmsGrpProd()
		If	ValType(xRet) == 'L'
			lRet := .F.
		Else
			aGrpProd := AClone(xRet)
			For nCount := 1 To Len(aGrpProd)
			   cGrpProd += "'" + aGrpProd[nCount][1] + "',"
			Next
			cGrpProd := Substr(cGrpProd,1,Len(cGrpProd) - 1)
		EndIf
	EndIf

	//-- RollBack (SXE / SXF)
	If !lRet
		If	__lSX8
			RollBackSX8()
		EndIf
		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea( aAreaDTQ )
		Return( { nOpca, "", "" } )
	EndIf

ElseIf nOpcx == 4       

	//--Verifica se existe um contrato aberto para a viagem junto a Operadora de Frota
	//--Existindo este contrato tentará fazer a exclusão do mesmo
	DTR->(dbSetOrder(1))	
	If 	DTR->(MsSeek(FwxFilial('DTR')+M->DTQ_FILORI+M->DTQ_VIAGEM)) .And. DTR->DTR_CODOPE == '01' .And. ;
	   	DTR->(ColumnPos('DTR_PRCTRA')) .And. !Empty(DTR->DTR_PRCTRA) .And. ;
		DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) 
		If !TmsVldOper(nOpcX, DTR->DTR_FILORI, DTR->DTR_VIAGEM, DTR->DTR_PRCTRA, DTR->DTR_CODOPE)
			Return(.F.)
		EndIf
	EndIf
	//-- Se o parametro MV_MANVIAG (Permite configurar se e possivel manifestar uma viagem que ainda nao esta disponivel na filial corrente)
	//-- estiver habilitado, permitir manutencoes na viagem com Status 'Em Transito'
	cStatus := StrZero(2,Len(DTQ->DTQ_STATUS)) + ";" + StrZero(4,Len(DTQ->DTQ_STATUS))
	If lManViag .And. Posicione('DTQ',2,xFilial('DTQ')+M->DTQ_FILORI + M->DTQ_VIAGEM, "DTQ_STATUS") $ cStatus
	   	lAberto := .F. 
		DTW->(DbSetOrder(4))
		If DTW->(MsSeek(cSeek := xFilial("DTW") + M->DTQ_FILORI + M->DTQ_VIAGEM + cAtivSai + cFilAnt))
			Do While !DTW->(Eof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI) == cSeek
		      //-- Se for operacao de 'Saida' e o Status da Operacao de Saida da Viagem estiver  'Encerrado'
		 		If DTW->DTW_CATOPE == StrZero(1,Len(DTW->DTW_CATOPE)) .And. ;
		   			DTW->DTW_STATUS == StrZero(2,Len(DTW->DTW_STATUS))
               		lAberto := .T. //-- Nao permite alterar a Viagem
               		Exit
				EndIf
				DTW->(dbSkip())
			EndDo
      	EndIf
	EndIf

	//-- Somente permite manutencoes em viagens em aberto, em transito ou chegada parcial
	If	! TMSChkViag(M->DTQ_FILORI,M->DTQ_VIAGEM,lAberto,.F.,.F.,.T.,.F.,.F.,.F.)
		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea( aAreaDTQ )
		MsUnLockAll()
		Return( { nOpca, "", "" } )
	EndIf
	RestArea( aAreaDTQ )
	//-- Informacoes para filtragem
	If !TmsA140Par(.T.,nOpcx,IsInCallStack("TMSF76VIA"))
		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea( aAreaDTQ )
		MsUnLockAll()
		Return( { nOpca, "", "" } )
	EndIf
	nTipVia := Val(M->DTQ_TIPVIA)
//-- Se exclusao
ElseIf nOpcx == 5
	//--Verifica se existe um contrato aberto para a viagem junto a Operadora de Frota
	//--Existindo este contrato tentará fazer a exclusão do mesmo
	DTR->(dbSetOrder(1))	
	If 	DTR->(MsSeek(FwxFilial('DTR')+M->DTQ_FILORI+M->DTQ_VIAGEM)) .And. DTR->DTR_CODOPE == '01' .And. ;
		DTR->(ColumnPos('DTR_PRCTRA')) .And. !Empty(DTR->DTR_PRCTRA) .And. ;
		DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) 
		If !TmsVldOper(nOpcx, DTR->DTR_FILORI, DTR->DTR_VIAGEM, DTR->DTR_PRCTRA, DTR->DTR_CODOPE)
			Return(.F.)
		EndIf
	EndIf
	//Valida a exclusão de uma viagem caso haja outra viagem coligada a ela.
	dbSelectArea("DTR")
	DTR->( DbSetOrder( 2 ) )
	If	DTR->(MsSeek(xFilial('DTR') + M->DTQ_FILORI + M->DTQ_VIAGEM))
		Help('',1,'TMSA14028',,STR0051 + DTR->DTR_FILORI + " " + STR0029 + " " +  DTR->DTR_VIAGEM,4,1)
		RestArea( aAreaDTQ )
		MsUnLockAll()
		Return( Nil )
	EndIf
	//-- Somente permite manutencoes em viagens em aberto, em transito ou chegada parcial
	If	! TMSChkViag(M->DTQ_FILORI,M->DTQ_VIAGEM,,.F.,.T.,,,,,,,,.F.,.F.,,.T.)
		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea( aAreaDTQ )
		MsUnLockAll()
		Return( { nOpca, "", "" } )
	EndIf
	RestArea( aAreaDTQ )
	//-- Se houver documentos carregados, a exclusao da viagem sera permitida apos o
	//-- estorno do carregamento
	DTA->(DbSetOrder(2))
	If	DTA->(MsSeek(xFilial('DTA') + M->DTQ_FILORI + M->DTQ_VIAGEM))
		Help(' ', 1, 'TMSA14009',,STR0051 + M->DTQ_FILORI + STR0045 + M->DTQ_VIAGEM,4,1)	//-- Ha documentos carregados nesta viagem
		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea( aAreaDTQ )
		RestArea( aAreaDTA )
		MsUnLockAll()
		Return( { nOpca, "", "" } )
	EndIf
	RestArea( aAreaDTA )
EndIf

aRota := {}
//-- Viagem normal
If	nTipVia == 1 .Or. nTipVia == 3  .Or. (nTipVia == 4 .And. nOpcx != 3)
	If nOpcx == 3 
		MsgRun(STR0044,,{|| xRet := TmsA140Qry( 3 ) })  // "Aguarde, verificando rotas"
	ElseIf nOpcx == 4
		MsgRun(STR0044,,{|| xRet := TmsA140Qry( 4 ) })  // "Aguarde, verificando rotas"
	Else
		CursorWait()
		xRet := TmsA140Qry( 2 )
		CursorArrow()
	EndIf

	If !xRet
		If	nOpcx == 3  .And. __lSX8
			RollBackSX8()
		EndIf
		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea( aAreaDTQ )
		MsUnLockAll()
		Return( { nOpca, "", "" } )
	EndIf

	AAdd(aButtons,{'CARGA',{||nSeek:=TmsA140ChkRot('1',,.T.), Iif(nSeek > 0,(aCompViag := TmsA240Mnt( , , nOpcx, M->DTQ_FILORI, M->DTQ_VIAGEM, aCompViag,;
	aRota[nSeek,2],cSerTms,cTipTra,@M->DTQ_OBS,,,,,,aDocto,aPosicao)),.F.) }, STR0008, STR0053 }) //'Complemento de Viagem'

	If nOpcx != 5
		If nOpcx == 2 .And. M->DTQ_STATUS == StrZero(9,Len(DTQ->DTQ_STATUS))
			//-- Se consultar uma viagem cancelada, apresenta a observacao do cancelamento
			AAdd(aButtons,{'EDIT',{||TmsA140Obs(5)}, STR0046, STR0054 })	//'Observacao do Cancelamento'
	   	EndIf
		AAdd(aButtons,{'EDIT',{||TmsA140Obs(nOpcx)}, STR0028 , STR0065 })	//'Observacao'
		AAdd(aButtons,{'EDIT',{|| TMSA140Id(nOpcx) }, STR0108 , STR0108 }) //'Id.Ope.Vge.'
	EndIf
	AAdd( aButtons ,{ 'PESQUISA'  ,{||TmsA140Psq()},STR0031})		//'Pesquisa'
	AAdd( aButtons ,{ 'NOCHECKED' ,{||TmsA140Leg( { {'BR_VERDE'    , STR0009 },;							//'Em Aberto'
													 {'BR_VERMELHO' , STR0010 },;							//'Carregado'
													 {'BR_AMARELO'  , STR0020 },;							//'Em Transito'
													 {'BR_AZUL'     , STR0048 },;							//'Encerrado'
													 {'BR_PRETO'    , STR0047 }})}, STR0011, STR0055 })	//'Cancelado' / 'Legenda de Documentos'

	AAdd( aButtons ,{ 'PLNPROP'   ,{||TmsA140Leg( { {'BR_VERDE'	, STR0052 },; //'Da Rota'
													 {'BR_AMARELO'	, STR0024 },; //'Sem Rota Definida'
													 {'BR_AZUL'		, STR0064 }})}, STR0056, STR0057 }) //'De Outra Rota' / 'Legenda de Rota Variavel'
	
	AAdd( aButtons ,{ 'BMPVISUAL' ,{||TmsA140Lim()} ,STR0058 ,STR0058 }) //"Limite"
	AAdd( aButtons ,{ 'WEB'       ,{||TmsA140VRt()} ,STR0059 ,STR0059 }) //"Rota"
	AAdd( aButtons ,{ 'DEVOLNF'   ,{||TmsA140Dco()} ,STR0060 ,STR0061 }) //"Documento"
	
	If	nOpcx == 3 .Or. nOpcx == 4
		AAdd(aButtons, {'RPMNEW',{||TmsA140Var(nOpcx)}, STR0066 , STR0067 }) //"Doctos. sem Rota Definida"
		AAdd(aButtons, {'CARGASEQ',{||TmsA140DSR(nOpcx)}, STR0068 , STR0069 }) //"Doctos. de Outras Rotas"
	EndIf
   	
   	AAdd(aButtons,	{'EDIT',{|| TmsA141Prd(aDocto[oLbxDocto:nAt,CTFILDOC],aDocto[oLbxDocto:nAt,CTDOCTO],aDocto[oLbxDocto:nAt,CTSERIE]) }, STR0062 , STR0063 }) //"Produtos do Documento"
    
   If nOpcx == 2 .And. AliasInDic('DFM')
		AAdd(aButtons,{'CUSTOS'  ,{|| TM99CViag() } , STR0111 , STR0111 }) // Custo da Viagem
	EndIf 
    //-- Controle de permissao de acesso a manut. de doctos
	If TmsAcesso(,"TMSA500",cCodUser,,.F.)
    	If	nOpcx == 3 .Or. nOpcx == 4
	   		//-- Botao para realizar manutencao nos documentos
	   		AAdd(aButtons, {'PEDIDO', {||Tm140MntDc()}, STR0074, STR0107 }) //-- Doctos. , Manut. Doctos. 
    	EndIf
 	EndIf
    
//-- Viagem vazia OU Socorro
ElseIf nTipVia == 2 .OR. (nTipVia == 4 .And. nOpcx == 3 )
	If	nOpcx == 4
		TmsA140Qr1(nOpcx,.T.)
	EndIf
	If ! TmsA140Qr1(nOpcx)
		If	nOpcx == 3 .And. __lSX8
			RollBackSX8()
		EndIf
		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea( aAreaDTQ )  
		MsUnLockAll()
		Return( { nOpca, "", "" } )
	EndIf
	AAdd(aButtons,{'CARGA',{||nSeek:=TmsA140ChkRot('1',,.T.), Iif(nSeek > 0,(aCompViag := TmsA240Mnt( , , nOpcx, M->DTQ_FILORI, M->DTQ_VIAGEM, aCompViag,;
	aRota[nSeek,2],cSerTms,cTipTra,@M->DTQ_OBS,,,,,,aDocto,aPosicao)),.F.)}, STR0008 , STR0053 }) //'Complemento de Viagem'

	If nOpcx != 5
		If nOpcx == 2 .And. M->DTQ_STATUS == StrZero(9,Len(DTQ->DTQ_STATUS))
			//-- Se consultar uma viagem cancelada, apresenta a observacao do cancelamento
			AAdd(aButtons,{'EDIT',{||TmsA140Obs(5)}, STR0046 , STR0054 })	//'Observacao do Cancelamento'
	   	EndIf
		AAdd(aButtons,{'EDIT',{||TmsA140Obs(nOpcx)}, STR0028, STR0065 })	//'Observacao'
		AAdd(aButtons,{'EDIT',{|| TMSA140Id(nOpcx) }, STR0108 , STR0108 }) //'Id.Ope.Vge.'
	EndIf
	AAdd(aButtons,{'WEB',{||TmsA140VRt()}, STR0059 , STR0059 }) //'Rota'
EndIf
If "3" $ cMV_TMSRRE .And. nOpcx == 2 .And. FindFunction('TMSA144RRE') //cMV_TMSRRE $ ("2|3")  .And. nOpcx == 2 .And. FindFunction('TMSA144RRE')
	AAdd(aButtons, {'RRE',{|| TMSA144RRE() },STR0109, STR0109	}) //RRE- Check List
EndIf
//-- Inclui botoes do usuario
If lTmsA1401
	If ValType(aUsButtons:=ExecBlock('TMSA1401',.F.,.F.))=='A'
		AEval(aUsButtons,{|x|AAdd(aButtons,x)})
	EndIf
EndIf
AAdd( aHRota ,' ' )
AAdd( aHRota ,Posicione('SX3' ,2 ,'DA8_COD'    ,'X3Titulo()'))
AAdd( aHRota ,Posicione('SX3' ,2 ,'DA8_DESC'   ,'X3Titulo()'))
AAdd( aHRota ,STR0014) //"Tipo da Rota"
AAdd( aHRota ,Posicione('SX3' ,2 ,'DT6_QTDVOL' ,'X3Titulo()'))
AAdd( aHRota ,Posicione('SX3' ,2 ,'DT6_PESO'   ,'X3Titulo()'))
AAdd( aHRota ,Posicione('SX3' ,2 ,'DT6_PESOM3' ,'X3Titulo()'))
AAdd( aHRota ,Posicione('SX3' ,2 ,'DT6_VALMER' ,'X3Titulo()'))
//-- Monta o cabecalho da dialog. Geracao de Viagens 000001 - Transporte - Rodoviario
cHDlgEsp := Subs(aRotina[nOpcx,1],IIF(Subs(aRotina[nOpcx,1],1,1)=="&",2,1))+' - '+cCadastro
cHDlgEsp += ' '+M->DTQ_FILORI+' '+M->DTQ_VIAGEM+' - '+AllTrim(TmsValField('cSerTms',.F.))
cHDlgEsp += ' - '+AllTrim(TmsValField('cTipTra',.F.))
aSx3Box	:= RetSx3Box(Posicione('SX3',2,'DTQ_TIPVIA','X3CBox()'),,,1)
If	( nSeek := Ascan(aSx3Box,{|x|x[2]==StrZero(nTipVia,Len(DTQ->DTQ_TIPVIA))}))>0
	cHDlgEsp += ' - '+AllTrim(aSx3Box[nSeek,3])
EndIf
cHDlgEsp += '.'
//-- Se veio do painel marca documentos selecionados
If IsInCallStack("TMSAF76")
	If Type("aVetReg") == "U"
		aVetReg := {}
	EndIf
	For nCntFor1 := 1 To Len(aVetReg)
		DT6->(DbGoTo(aVetReg[nCntFor1]))
		If (nPos := Ascan(aDocto,{|x| x[CTFILDOC] + x[CTDOCTO] + x[CTSERIE] == DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)})) > 0
			aDocto[nPos,CTMARCA] := .T.
		EndIf
	Next nCntFor1
EndIf
//-- Calcula as dimensoes dos objetos
aSize  := MsAdvSize( .T. )

aObjects	:= {}
AAdd( aObjects ,{ 100 ,40 ,.T. ,.T. ,.T. 	})			//-- Horizontal superior
AAdd( aObjects ,{ 100 ,60 ,.T. ,.T. ,.T. 	})			//-- Horizontal central
AAdd( aObjects ,{ 100 ,05 ,.T. ,.T.		}) 			//-- Horizontal Inferior.

aInfo		:= {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
aPosObjH	:= MsObjSize(aInfo,aObjects,.T.,.F.)
//--Ordenacao nas Rotas
aSort(aRota,,,{|x,y| x[2] < y[2]})
DEFINE MSDIALOG oDlgEsp FROM aSize[7],00 TO aSize[6],aSize[5] TITLE cHDlgEsp	OF oMainWnd PIXEL
	//-- Apresenta as rotas da viagem
	@ aPosObjH[1,1], aPosObjH[1,2] LISTBOX oLbx1 VAR cLbx1 FIELDS HEADER aHRota[1],aHRota[2],aHRota[3],aHRota[4],aHRota[5],;
	aHRota[6],aHRota[7],aHRota[8]  SIZE aPosObjH[1,3], aPosObjH[1,4] OF oDlgEsp ON DBLCLICK (TmsA140Mrk( 1,nOpcx )) PIXEL
	oLbx1:SetArray( aRota )
	nSeek := TmsA140ChkRot('1')
	If nSeek > 0
		oLbx1:nAT := nSeek
	EndIf
	//-- Monta o bLine do listbox
	TmsA140bLi( 1 )
	//-- Apresenta os documentos da viagem
	TmsA140VisDoc(aPosObjH,,nOpcx)
	
	//-- Campos do Rodape
	oPanel := TPanel():New(aPosObjH[3,1],aPosObjH[3,2],"",oDlgEsp,,,,,CLR_WHITE,(aPosObjH[3,4]), (aPosObjH[3,3]), .T.)

	@ 005,005 SAY STR0070 SIZE 40,9 OF oPanel PIXEL //--Volumes:
	@ 003,030 MSGET oVolumes VAR nVolumes WHEN .F. SIZE 30,9 OF oPanel PIXEL

	@ 005,070 SAY STR0071 SIZE 40,9 OF oPanel PIXEL //--Peso Real
	@ 003,100 MSGET oPesReal VAR nPesReal PICTURE PesqPict("DT6","DT6_PESO") WHEN .F. SIZE 50,9 OF oPanel PIXEL

	@ 005,160 SAY STR0072 SIZE 40,9 OF oPanel PIXEL //--Peso Cubado
	@ 003,195 MSGET oPesCub VAR nPesCub PICTURE PesqPict("DT6","DT6_PESOM3") WHEN .F. SIZE 50,9 OF oPanel PIXEL

	@ 005,255 SAY STR0073 SIZE 40,9 OF oPanel PIXEL //--Vlr. Merc.
	@ 003,285 MSGET oValMerc VAR nValMerc PICTURE PesqPict("DT6","DT6_VALMER") WHEN .F. SIZE 50,9 OF oPanel PIXEL

	@ 005,345 SAY STR0074 SIZE 50,9 OF oPanel PIXEL //--Doctos.
	@ 003,365 MSGET oDoctos VAR nDoctos WHEN .F. SIZE 20,9 OF oPanel PIXEL

	//-- Atualizando o Rodape
	TMSA140Rdp()
	
ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||oDlgEsp:cCaption := cCadastro, oDlgEsp:Refresh(),Iif(TmsA140TOk(nOpcx),(nOpca := 1,oDlgEsp:End()),.F.)},{|| oDlgEsp:cCaption := cCadastro, oDlgEsp:Refresh(), nOpca == 0, oDlgEsp:End()},, aButtons )
If nOpca == 1
	TmsA140Grv(nOpcx,,,,,@nPosDTQ)
	If nPosDTQ >0
		aAreaDTQ[3] := nPosDTQ
	EndIf
Else
	If	__lSX8
		RollBackSX8()
	EndIf
	
		//Destravar os documentos no cancelamento
	If Len(aDocto) > 0
		ASort( aDocto,,,{|x,y| x[CTMARCA] > y[CTMARCA] } ) //Deixar os documentos selecionados primeiro no array
		For nCnt := 1 To Len(aDocto)
			If !aDocto[nCnt,CTMARCA]
				Exit
			ElseIf aDocto[nCnt,CTMARCA]
				TmsConTran( aDocto[nCnt,CTFILDOC], aDocto[nCnt,CTDOCTO] , aDocto[nCnt,CTSERIE])
			EndIf
		Next nCnt
	EndIf

	If Len(aCompViag) > 0 //-- Se foi preenchido o Complemento de Viagem
		If lContVei .Or. lMV_EmViag //--Controle de Veiculos ligado
			//--Destravar os veiculos e reboques no cancelamento
			If Len(aCompViag[2]) > 0
				For nCnt := 1 To Len(aCompViag[2])
					UnLockByName("VGEVEI" + aCompViag[2][nCnt][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODVEI'})],.T.,.F.)
					UnLockByName("VGERB1" + aCompViag[2][nCnt][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODRB1'})],.T.,.F.)
					UnLockByName("VGERB2" + aCompViag[2][nCnt][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODRB2'})],.T.,.F.)
					If lTercRbq
						UnLockByName("VGERB3" + aCompViag[2][nCnt][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODRB3'})],.T.,.F.)
					EndIf	
				Next nCnt
			EndIf
			//--Destravar os motoristas no cancelamento
			If Len(aCompViag[4]) > 0
				For nCnt := 1 To Len(aCompViag[4])
					For nCount := 1 To Len(aCompViag[4][nCnt][2])
						UnLockByName("VGEMOT" + aCompViag[4][nCnt][2][nCount][Ascan(aCompViag[3],{|x| x[2] == 'DUP_CODMOT'})],.T.,.F.)
					Next nCount	
				Next nCnt
			EndIf
		EndIf
		//--Destravar os ajudantes no cancelamento
		If Len(aCompViag[6]) > 0
			For nCnt := 1 To Len(aCompViag[6])
				For nCount := 1 To Len(aCompViag[6][nCnt][2])
					UnLockByName("VGEAJU" + aCompViag[6][nCnt][2][nCount][Ascan(aCompViag[5],{|x| x[2] == 'DUQ_CODAJU'})],.T.,.F.)
				Next nCount
			Next nCnt
		EndIf
	EndIf
EndIf

//-- Retorna o ambiente original
RestArea( aAreaDTY )
RestArea( aAreaDUY )
RestArea( aAreaDTQ )
RestArea( aAreaAnt )

//-- Nao chama novamente a tela, qd for inclusao
MBRCHGLoop()

If Type('bFiltraBrw') <> 'U'
	Eval(bFiltraBrw)
EndIf

MsUnLockAll()

Return( { nOpca, M->DTQ_FILORI, M->DTQ_VIAGEM } )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA140Par³ Autor ³ Alex Egydio           ³ Data ³17.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Informacoes para filtragem.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA140Par()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 -> Editar os parametros. 							  ³±±
±±³          ³ ExpN1 -> Opcao da viagem                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS.                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140Par(lEdita,nOpcx,lPainel)

Local lRet      := .F.
Local lTM140PAR := ExistBlock("TM140PAR")
Local lRetPE    := .T.   

Default lEdita  := .T.
Default lPainel := .F.
Default nOpcx   := 3  

If lTM140PAR
	lRetPE := ExecBlock("TM140PAR",.F.,.F.)
    If ValType(lRetPE) <> "L"
    	lRetPE := .T.
    EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas como parametros                                  ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ mv_par01	// Carregamento       ?      Manual                       ³
//³                                         Automatico                    ³
//³                                         Manifesto                     ³
//³                                         Manifesto/Contrato            ³
//³                                         Contrato                      ³
//³                                                                       ³
//³ mv_par02	// Tipo Viagem        ?      Normal                       ³
//³                                         Vazia                         ³
//³                                         Planejada                     ³
//³                                                                       ³
//³ mv_par03   // Rota De            ?                                    ³
//³ mv_par04   // Rota Ate           ?                                    ³
//³ mv_par05   // Regiao Destino De  ?                                    ³
//³ mv_par06   // Regiao Destino Ate ?                                    ³
//³ mv_par07   // Somente Doctos Enderecados ? Sim / Nao                  ³
//³ mv_par08   // Apresenta Todas Rotas ? Sim / Nao                       ³
//³ mv_par09   // Pagar Saldo Contrato  ?  Sim / Nao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Pergunte('TMA144',lEdita .And. lRetPE .and. !lPainel) .Or. !lRetPE .Or. lPainel
	lRet        := .T.
	nCarreg		:= mv_par01
	nTipVia		:= mv_par02
	cRotaDe		:= mv_par03
	cRotaAte	:= mv_par04
	cCdrDesDe	:= mv_par05
	cCdrDesAte	:= mv_par06
	lDoctoEnd   := mv_par07 == 1 //Mostra somente documentos enderecados? 1- Sim 2- Nao
	lAllRota    := mv_par08 == 1 //Apresenta Todas Rotas ? 1- Sim 2- Nao
	lPagSald    := mv_par09 == 1 //Pagar Saldo Contrato  ?  Sim / Nao    
	If nOpcx == 3
		M->DTQ_TIPVIA := StrZero( nTipVia, Len( DTQ->DTQ_TIPVIA ) )
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA140Leg³ Autor ³ Alex Egydio           ³ Data ³28.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a legenda do status da viagem                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA140Leg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 -> Status da legenda                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA140Leg( aStatus , lExibe )

Local cTitulo := ''

Default	lExibe	:= .T. 

If	ValType( aStatus ) != 'A'
	aStatus := {	{ 'BR_VERDE'	,STR0019 },; 	//'Em Aberto'
					{ 'BR_VERMELHO'	,STR0049 },; 	//"Fechada"
					{ 'BR_AMARELO'	,STR0020 },; 	//'Em Transito'
					{ 'BR_LARANJA' 	,STR0113 },; 	//"Chegada em Filial"
					{ 'BR_AZUL'    	,STR0021 },; 	//'Encerrada'
					{ 'BR_PRETO'	,STR0022 } } 	//'Cancelada'
	cTitulo := STR0029		//'Viagem'
Else
	cTitulo := STR0023		//'Documentos'
EndIf

If lExibe
	BrwLegenda( cTitulo, STR0015, aStatus ) //'Status'
EndIf

Return  aStatus 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA140Obs³ Autor ³ Alex Egydio           ³ Data ³04.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Observacao da viagem                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA140Obs()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA140Obs(nOpcx)

Local oDlgObs

DEFINE MSDIALOG oDlgObs TITLE STR0028 FROM 15,20 TO 25,62 //"Observacao"
	If	nOpcx == 5
		@ 0.5,0.7  GET oGet VAR M->DTQ_OBSCAN OF oDlgObs MEMO size 150,40
	Else
		@ 0.5,0.7  GET oGet VAR M->DTQ_OBS OF oDlgObs MEMO size 150,40
	EndIf
	DEFINE SBUTTON FROM 52,128 TYPE 1 ACTION (oDlgObs:End()) ENABLE OF oDlgObs
ACTIVATE MSDIALOG oDlgObs CENTERED

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA140Id³ Autor ³ Alex Amaral           ³ Data ³02.06.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³    "Id.Ope.Vge."                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA140Id()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA140Id(nOpcx)

Local oDlgId

DEFINE MSDIALOG oDlgId TITLE STR0108 FROM 15,20 TO 24,61 //"Id.Ope.Vge."
	
		@ 1.5,3.0  GET oGet VAR M->DTQ_IDOPE WHEN .F. OF oDlgId size 100,10
	
	DEFINE SBUTTON FROM 52,128 TYPE 1 ACTION (oDlgId:End()) ENABLE OF oDlgId
ACTIVATE MSDIALOG oDlgId CENTERED

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA140Psq³ Autor ³ Alex Egydio           ³ Data ³17.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa documentos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA140Psq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140Psq()

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

cCampo := AllTrim(Posicione('SX3', 2, 'DUD_FILDOC'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_DOC'		, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_SERIE'	, 'X3Titulo()'))
AAdd( aCbx, cCampo )
cCampo := AllTrim(Posicione('SX3', 2, 'DTC_NOMREM'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DTC_NOMDES'	, 'X3Titulo()'))
AAdd( aCbx, cCampo )
cCampo := AllTrim(Posicione('SX3', 2, 'DTC_NOMDES'	, 'X3Titulo()'))
AAdd( aCbx, cCampo )
cCampo := AllTrim(Posicione('SX3', 2, 'DT6_PRZENT'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_FILDOC'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_DOC'		, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_SERIE'	, 'X3Titulo()'))
AAdd( aCbx, cCampo )
cCampo := AllTrim(Posicione('SX3', 2, 'DTC_DATENT'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_FILDOC'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_DOC'		, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_SERIE'	, 'X3Titulo()'))
AAdd( aCbx, cCampo )
If	lLocaliz .And. ! lColeta
	cCampo := AllTrim(Posicione('SX3', 2, 'DUH_LOCAL'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUH_LOCALI'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_FILDOC'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_DOC'		, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_SERIE'	, 'X3Titulo()'))
	AAdd( aCbx, cCampo )
EndIf

cCampo := Space( 40 )

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0031		//'Pesquisa'

@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg ON CHANGE nOrdem := oCbx:nAt

@ 22,05 MSGET oPsqGet VAR cCampo SIZE 206,10 PIXEL

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If lSeek
	cCampo := AllTrim( cCampo )
	If nOrdem == 1
		//-- Fil.Docto + Docto + Serie
		ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] < y[CTSEQUEN] + y[ CTFILDOC ] + y[ CTDOCTO ] + y[ CTSERIE ] })
		nSeek := Ascan( aDocto,{ | x | PadR( x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ], Len( cCampo ) ) == cCampo } )
	ElseIf nOrdem == 2
		//-- Remetente + Destinatario
		ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[ CTNOMREM ] + x[ CTNOMDES ] < y[CTSEQUEN] + y[ CTNOMREM ] + y[ CTNOMDES ] } )
		nSeek := Ascan( aDocto,{ | x | PadR( x[ CTNOMREM ] + x[ CTNOMDES ], Len( cCampo ) ) == cCampo } )
	ElseIf nOrdem == 3
		//-- Destinatario
		ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[ CTNOMDES ] < y[CTSEQUEN] + y[ CTNOMDES ] } )
		nSeek := Ascan( aDocto,{ | x | PadR( x[ CTNOMDES ], Len( cCampo ) ) == cCampo } )
	ElseIf nOrdem == 4
		//-- Prazo de Entrega + Fil.Docto + Docto + Serie
		ASort( aDocto,,,{|x,y| x[CTSEQUEN] + DtoS(x[ CTPRZENT ]) + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] < y[CTSEQUEN] + DtoS(y[ CTPRZENT ]) + y[ CTFILDOC ] + y[ CTDOCTO ] + y[ CTSERIE ] } )

		cData := Left( cCampo, 6 )
		cData := DtoS( CtoD(Left(cData,2)+'/'+Subs(cData,3,2)+'/'+Right(cData,2)) )
		
		If Len( cCampo ) > 6
			cCampo := cData + Subs( cCampo, 7, Len( cCampo ) )
		Else
			cCampo := cData
		EndIf
		
		nSeek := Ascan( aDocto,{ | x | PadR( DtoS( x[ CTPRZENT ] ) + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ], Len( cCampo ) ) == cCampo  } )

	ElseIf nOrdem == 5
		//-- Data de Emissao + Fil.Docto + Docto + Serie
		ASort( aDocto,,,{|x,y| x[CTSEQUEN] + DtoS(x[ CTDATENT ]) + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] < y[CTSEQUEN] + DtoS(y[ CTDATENT ]) + y[ CTFILDOC ] + y[ CTDOCTO ] + y[ CTSERIE ] } )

		cData := Left( cCampo, 6 )
		cData := DtoS( CtoD(Left(cData,2)+'/'+Subs(cData,3,2)+'/'+Right(cData,2)) )
		
		If Len( cCampo ) > 6
			cCampo := cData + Subs( cCampo, 7, Len( cCampo ) )
		Else
			cCampo := cData
		EndIf
		
		nSeek := Ascan( aDocto,{ | x | PadR( DtoS( x[ CTDATENT ] ) + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ], Len( cCampo ) ) == cCampo  } )
	ElseIf nOrdem == 6
		//-- Armazem + Endereco + Fil.Docto + Docto + Serie
		ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[ CTARMAZE ] + x[ CTLOCALI ] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] < y[CTSEQUEN] + y[ CTARMAZE ] + y[ CTLOCALI ] + y[ CTFILDOC ] + y[ CTDOCTO ] + y[ CTSERIE ] } )
		nSeek := Ascan( aDocto,{ | x | PadR( x[ CTARMAZE ] + x[ CTLOCALI ] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ], Len( cCampo ) ) == cCampo } )
	EndIf
EndIf

If nSeek > 0
	oLbxDocto:nAT := nSeek
	oLbxDocto:Refresh()
EndIf
oLbxDocto:SetFocus()

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140Lim³ Autor ³ Alex Egydio           ³ Data ³05.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa informacoes dos documentos selecionados para a     ³±±
±±³          ³ consulta de limites                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140Lim()

Local na,nb
Local aLimite	 := {}
Local nCntFor	 := 0
Local nCapaCm    := 0
Local nCapCav    := 0
Local nValFrePag := 0
Local nTotFrePag := 0
Local nTotFreRec := 0 
Local nRota      := 0
Local aValSeg    := {}
Local cCliente   := Space( Len( DTC->DTC_CLIREM ) )
Local cLoja      := Space( Len( DTC->DTC_LOJREM ) )
Local cProduto   := Space( Len( DTC->DTC_CODPRO ) )
Local aBlqAnoVei := {}
Local aBlqCarPer := {}
Local aBlqFrtCar := {}
Local aVeiculos  := {}
Local aFretCar   := {}
Local cCatVei    := ''
Local cChave     := ''
Local cCodFor    := ''
Local cLojFor    := ''
Local cVeiRas    := ''
Local cCodVei    := ''
Local cCodReb    := ''
Local cCodRb1    := ''
Local cCodRb2    := ''
Local cCodRb3	   := ''
Local lTMSOPdg   := SuperGetMV( 'MV_TMSOPDG',, '0' ) <> '0'
Local aBlqDoctos := {{},{},{}}
Local nReboque   := 2
Local lTercRbq   := DTR->(ColumnPos("DTR_CODRB3")) > 0
Local lTipOpVg   := DTQ->(ColumnPos("DTQ_TPOPVG")) > 0

SaveInter()

Private aHeader  := {}
Private aCols    := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formato do vetor aLimite                                              ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ [01] = Codigo do cliente remetente                                    ³
//³ [02] = Loja                                                           ³
//³ [03] = Codigo do produto                                              ³
//³ [04] = Valor da Mercadoria                                            ³
//³ [05] = Peso Real                                                      ³
//³ [06] = Peso Cubado                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DTC->(DbSetOrder(3)) //Fil.Docto. + No.Docto. + Serie Docto. + Servico + Cod. Produto
For nCntFor := 1 To Len( aDocto )	
	If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(aDocto[ nCntFor, CTFILDOC ], aDocto[ nCntFor, CTDOCTO ], aDocto[ nCntFor, CTSERIE ])
		If DTC->(MsSeek( xFilial('DTC') + aDocto[ nCntFor, CTFILDOC ] + aDocto[ nCntFor, CTDOCTO ] + aDocto[ nCntFor, CTSERIE ] ))
			While DTC->(!Eof()) .And. DTC->DTC_FILIAL + DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE == xFilial('DTC') + aDocto[ nCntFor, CTFILDOC ] + aDocto[ nCntFor, CTDOCTO ] + aDocto[ nCntFor, CTSERIE ]
				cCliente := DTC->DTC_CLIREM
				cLoja    := DTC->DTC_LOJREM
				cProduto := DTC->DTC_CODPRO
				If (nPos := Ascan( aLimite, { |x| x[1] + x[2] + x[3] == cCliente + cLoja + cProduto } )) == 0
					If	aDocto[ nCntFor, CTMARCA ]
						AAdd( aLimite,{ cCliente, cLoja, cProduto, DTC->DTC_VALOR, DTC->DTC_PESO, DTC->DTC_PESOM3 } )
					Else
						AAdd( aLimite,{ cCliente, cLoja, cProduto, 0, 0, 0 } )
					EndIf
				Else
					If aDocto[ nCntFor, CTMARCA ]
						aLimite[nPos,4] += DTC->DTC_VALOR
						aLimite[nPos,5] += DTC->DTC_PESO
						aLimite[nPos,6] += DTC->DTC_PESOM3
					EndIf
				EndIf
				DTC->(DbSkip())
			EndDo
		EndIf
	Else
		dbSelectArea("DY4")
		DbSetOrder(1) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
		If DY4->(MsSeek( xFilial('DY4') + aDocto[ nCntFor, CTFILDOC ] + aDocto[ nCntFor, CTDOCTO ] + aDocto[ nCntFor, CTSERIE ] ))
			While DY4->(!Eof()) .And. DY4->DY4_FILIAL + DY4->DY4_FILDOC + DY4->DY4_DOC + DY4->DY4_SERIE == xFilial('DY4') + aDocto[ nCntFor, CTFILDOC ] + aDocto[ nCntFor, CTDOCTO ] + aDocto[ nCntFor, CTSERIE ]
				DbSelectArea("DTC")
				dbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto
				If DTC->(MsSeek(xFilial("DTC") + DY4->DY4_NUMNFC + DY4->DY4_SERNFC + DY4->DY4_CLIREM + DY4->DY4_LOJREM + DY4->DY4_CODPRO))
					cCliente := DTC->DTC_CLIREM
					cLoja    := DTC->DTC_LOJREM
					cProduto := DTC->DTC_CODPRO
					If (nPos := Ascan( aLimite, { |x| x[1] + x[2] + x[3] == cCliente + cLoja + cProduto } )) == 0
						If	aDocto[ nCntFor, CTMARCA ]
							AAdd( aLimite,{ cCliente, cLoja, cProduto, DTC->DTC_VALOR, DTC->DTC_PESO, DTC->DTC_PESOM3 } )
						Else
							AAdd( aLimite,{ cCliente, cLoja, cProduto, 0, 0, 0 } )
						EndIf
					Else
						If aDocto[ nCntFor, CTMARCA ]
							aLimite[nPos,4] += DTC->DTC_VALOR
							aLimite[nPos,5] += DTC->DTC_PESO
							aLimite[nPos,6] += DTC->DTC_PESOM3
						EndIf
					EndIf					
				Endif	
				DY4->(DbSkip())
			EndDo
		EndIf	
	Endif	
	If aDocto[ nCntFor, CTMARCA ]
		DT6->(DbSetOrder(1))
		If DT6->(MsSeek(xFilial('DT6')+aDocto[ nCntFor, CTFILDOC ] + aDocto[ nCntFor, CTDOCTO ] + aDocto[ nCntFor, CTSERIE ] ))
			nTotFreRec += DT6->DT6_VALFRE // Total do Frete a Receber dos Documentos da viagem
		EndIf
	EndIf
Next nCntFor

//-- Verifica se o complemento de viagem foi efetuado
If Len(aCompViag) > 0 .And. !Empty(aCompViag[1]) .And. !Empty(aCompViag[2])
	aHeader  := AClone(aCompViag[1])  // aHeader DTR(Veiculos da Viagem)
	aCols    := AClone(aCompViag[2])  // aCols DTR(Veiculos da Viagem)

	DA3->( DbSetOrder( 1 ) )
	For nA := 1 To Len(aCols)
		If !GDDeleted( nA )
			cCodVei    := GdFieldGet( "DTR_CODVEI", nA )			
			nValFrePag := GdFieldGet( "DTR_VALFRE", nA )	// Valor do Frete a Pagar informado no Complemento da Viagem		
			nTotFrePag += nValFrePag    // Total do Frete a Pagar (todos os veiculos do complemento)
			If	DA3->( MsSeek( xFilial('DA3') + cCodVei ) ) .And. DA3->DA3_ATIVO == StrZero( 1, Len( DA3->DA3_ATIVO ) )
				cChave 	:= DA3->DA3_TIPVEI
				cCodFor	:= DA3->DA3_CODFOR
				cLojFor := DA3->DA3_LOJFOR
				cVeiRas := DA3->DA3_VEIRAS
				AAdd(aVeiculos, { cCodVei,	GdFieldGet("DTR_QTDEIX",nA), GdFieldGet("DTR_QTEIXV",nA) } )
				
		      	cCatVei:= Posicione('DUT',1,xFilial('DUT')+DA3->DA3_TIPVEI,'DUT_CATVEI') 
			   	If cCatVei == StrZero(2, Len(DUT->DUT_CATVEI)) //-- Se o Tipo do Veiculo for 'Cavalo'
			   		nCapCav += DA3->DA3_CAPACM
			   	Else			   			
					nCapaCm += DA3->DA3_CAPACM
				EndIf	
				AAdd( aBlqAnoVei, { DA3->DA3_COD, DA3->DA3_ANOFAB } )
			EndIf
			/* Obtem a capacidade do Reboque 1/Reboque 2. */
			cCodRb1 := Space(Len(DA3->DA3_COD))
			cCodRb2 := Space(Len(DA3->DA3_COD))
			
			If lTercRbq
				cCodRb3 := Space(Len(DA3->DA3_COD))
				nReboque:= 3
			EndIf
				
			For nB := 1 To nReboque
				cCodReb := Space(Len(DA3->DA3_COD))						   			
				If nB == 1 .And. !Empty( GdFieldGet("DTR_CODRB1", nA) )				
					cCodRb1 := GdFieldGet("DTR_CODRB1", nA)
					cCodReb := cCodRb1
					AAdd(aVeiculos, { cCodRB1,	0, 0 } )
				ElseIf nB == 2 .And. !Empty( GdFieldGet("DTR_CODRB2", nA) )
					cCodRb2 := GdFieldGet("DTR_CODRB2", nA)
					cCodReb := cCodRb2		 
					AAdd(aVeiculos, { cCodRB2,	0, 0 } )
				ElseIf nB == 3 .And. !Empty( GdFieldGet("DTR_CODRB3", nA) )
					cCodRb3 := GdFieldGet("DTR_CODRB3", nA)
					cCodReb := cCodRb3		 
					AAdd(aVeiculos, { cCodRB3,	0, 0 } )
				EndIf
				If	!Empty(cCodReb) .And. DA3->( MsSeek( xFilial('DA3') + cCodReb ) ) .And. DA3->DA3_ATIVO == StrZero( 1, Len( DA3->DA3_ATIVO ) )
					nCapaCm += DA3->DA3_CAPACM
					cChave+= DA3->DA3_FROVEI
				Else
					cChave+= StrZero(0, Len(DA3->DA3_FROVEI))
				EndIf				
			Next nB
			cChave += cVeiRas
			cChave += Str(nTipVia,1)

			If Empty(M->DTQ_ROTA) .And. ( nRota := Ascan( aRota, {|x| x[1] == .T.}) ) > 0
				M->DTQ_ROTA := aRota[nRota][2]
			EndIf						
			
			//-- Verifica se existe a Tabela de Carreteiro por Rota
			aFretCar := TMSFretCar(M->DTQ_ROTA, cCodFor, cLojFor, aVeiculos, cChave,;
                                M->DTQ_SERTMS, M->DTQ_TIPTRA,,,IIF(lTMSOPdg, aCompViag[11, 7], ''),,,Iif(lTipOpVg,M->DTQ_TPOPVG,'') )
			
			//-- Bloqueia a Viagem se o Valor do Frete a Pagar for Maior que o valor do frete Calculado                          
			If !Empty(aFretCar) .And. !Empty(aFretCar[2]) .And. nValFrePag > aFretCar[2]
				AAdd( aBlqFrtCar, { nValFrePag, aFretCar[2] } )				
			EndIf							
		EndIf			
	Next nA          
			
EndIf

/* Verifica se o complemento de viagem foi efetuado(Motoristas). */
If Len(aCompViag) > 0 .And. !Empty(aCompViag[3]) .And. !Empty(aCompViag[4][1][2])
	aHeader  := AClone(aCompViag[3]) // aHeader DUP(Motorista da Viagem).
	For nB := 1 To Len(aCompViag[4])
		aCols    := AClone(aCompViag[4][nB][2]) // aCols DUP(Motorista da Viagem).	
		DA4->( DbSetOrder( 1 ) )
		For nA := 1 To Len(aCols)
			If !GDDeleted( nA )
				If DA4->( MsSeek( xFilial("DA4") + GdFieldGet("DUP_CODMOT", nA), .F. ) ) .And.;
					DA4->DA4_BLQMOT == StrZero( 2, Len( DA4->DA4_BLQMOT ) )
					/* Obtem o valor de marcadoria que o motorista tem permissao para carregar. */
					AAdd( aValSeg    ,{ DA4->DA4_COD, DA4->DA4_VALSEG } )
					AAdd( aBlqCarPer ,{ DA4->DA4_COD, DA4->DA4_CARPER } )
				EndIf
			EndIf			
		Next nA
	Next nB
EndIf
    
If Empty(M->DTQ_ROTA) .And. ( nRota := Ascan( aRota, {|x| x[1] == .T.}) ) > 0
	M->DTQ_ROTA := aRota[nRota][2]
EndIf

/* Tratamento para o Bloqueio - Controle de Documentos */
If Len(aCompViag) > 0 .And. !Empty(aCompViag[1]) .And. !Empty(aCompViag[2])
	aHeader  := AClone(aCompViag[1])  // aHeader DTR(Veiculos da Viagem).
	aCols    := AClone(aCompViag[2])  // aCols DTR(Veiculos da Viagem).
	For nA := 1 To Len(aCols)
		If !GDDeleted( nA )
			AAdd( aBlqDoctos[1], GDFieldGet('DTR_CODVEI', nA ) )
			If !Empty(GDFieldGet('DTR_CODRB1'))
				AAdd( aBlqDoctos[1], GDFieldGet('DTR_CODRB1', nA ) )
			EndIf
			If !Empty(GDFieldGet('DTR_CODRB2'))
				AAdd( aBlqDoctos[1], GDFieldGet('DTR_CODRB2', nA ) )
			EndIf
			If lTercRbq
				If !Empty( GDFieldGet( 'DTR_CODRB3', nA ) )
					AAdd( aBlqDoctos[1], GDFieldGet('DTR_CODRB3', nA ) )
				EndIf
			EndIf	
		EndIf
	Next
EndIf
		
If Len(aCompViag) > 0 .And. Len(aCompViag[4]) > 0.And. !Empty(aCompViag[3]) .And. !Empty(aCompViag[4][1][2])
	aHeader  := AClone(aCompViag[3]) // aHeader DUP(Motorista da Viagem).
	For nB := 1 To Len(aCompViag[4])
		aCols    := AClone(aCompViag[4][nB][2]) // aCols DUP(Motorista da Viagem).	
		For nA := 1 To Len(aCols)
			If !GDDeleted( nA )
				AAdd( aBlqDoctos[2], GdFieldGet("DUP_CODMOT", nA) )
			EndIf
		Next nA
	Next nB
EndIf

If Len(aCompViag) > 0 .And. Len(aCompViag[6]) > 0 .And. !Empty(aCompViag[5]) .And. !Empty(aCompViag[6][1][2])
	aHeader  := AClone(aCompViag[5]) // aHeader DUP(Motorista da Viagem).
	For nB := 1 To Len(aCompViag[6])
		aCols    := AClone(aCompViag[6][nB][2]) // aCols DUP(Motorista da Viagem).	
		For nA := 1 To Len(aCols)
			If !GDDeleted( nA )
				AAdd( aBlqDoctos[3], GdFieldGet("DUQ_CODAJU", nA) )
			EndIf
		Next nA
	Next nB
EndIf				

TmsBlqViag( M->DTQ_FILORI, M->DTQ_VIAGEM, aLimite, nCapacM, aValSeg, cSerTms,, aBlqAnoVei, aBlqCarPer, nCapCav, aBlqFrtCar, nTotFrePag, nTotFreRec, aBlqDoctos )

RestInter()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140VRt³ Autor ³ Alex Egydio           ³ Data ³25.04.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualisa Rotas                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140VRt()

Local aAreaAnt	:= GetArea()
Local aAreaDA8	:= DA8->(GetArea())
Local cCadOld	:= cCadastro
Local nSeek		:= 0
Local lInclAux	:= Inclui

Inclui := .F.
nSeek  := TmsA140ChkRot('1')
If nSeek > 0
	DbSelectArea('DA8')
	DbSetOrder(1)
	If	DA8->(MsSeek(xFilial('DA8')+aRota[nSeek,2]))
		cCadastro := STR0043 // 'Cadastro de Rotas'
		FWExecView (, "OMSA100" , 1 , ,{|| .T. }, , , , , , , )
	EndIf
EndIf
cCadastro := cCadOld
Inclui    := lInclAux
RestArea( aAreaDA8 )
RestArea( aAreaAnt )

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140Dco³ Autor ³ Alex Egydio           ³ Data ³25.04.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualisa Documentos                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140Dco()

Local aAreaAnt	:= GetArea()
Local aAreaDT6	:= DT6->(GetArea())

DbSelectArea('DT6')
DbSetOrder(1)
If	DT6->(MsSeek(xFilial('DT6') + aDocto[oLbxDocto:nAT,CTFILDOC] + aDocto[oLbxDocto:nAT,CTDOCTO] + aDocto[oLbxDocto:nAT,CTSERIE]))
	TmsA500Mnt('DT6',Recno(),2)
EndIf

RestArea( aAreaDT6 )
RestArea( aAreaAnt )

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140TOk³ Autor ³ Alex Egydio           ³ Data ³14.05.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes gerais                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao de manutencao                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140TOk(nOpcx)

Local aAreaAnt	:= GetArea()
Local aAreaDTR	:= DTR->(GetArea())
Local lRet		:= .T.
Local lPontoVld := ExistBlock("TMS140VLD")
Local lTMSOPdg  := SuperGetMV( 'MV_TMSOPDG',, '0' ) <> '0'
Local lMotAux   := DUP->( FieldPos( "DUP_CONDUT" ) ) > 0 .And. lTMSOPdg
Local nCntFor   := 0
Local aCodigos  := {}
Local laCodigo  := .F.
Local aDocsDUA	:= {}
Local aAreaDA3  := {}
Local cCodVei   := ''
Local cCodRbq1  := ''
Local cCodRbq2  := ''
Local cCodRbq3  := ''
Local cCodMot   := ''

If	nOpcx == 3 .Or. nOpcx == 4
	//-- Verifica se selecionou ao menos uma rota
	If	TmsA140ChkRot('1',,.T.) <= 0
		lRet := .F.
	EndIf
	//-- Carregamento automatico	
	If	lRet .And. ( nCarreg > 1) 
		If	nOpcx == 3
			If Len(aCompViag) <= 0
				Help( ' ', 1, 'TMSA24002', , STR0045 + M->DTQ_FILORI + ' ' + M->DTQ_VIAGEM, 4, 1 ) //-- Complemento de viagem nao encontrado (DTR)
				lRet := .F.
			EndIf	
		Else		
			DTR->( DbSetOrder( 1 ) )
			If  DTR->( ! MsSeek( xFilial('DTR') + M->DTQ_FILORI + M->DTQ_VIAGEM ) ) .And. Len(aCompViag) <= 0
				Help( ' ', 1, 'TMSA24002', , STR0045 + M->DTQ_FILORI + ' ' + M->DTQ_VIAGEM, 4, 1 ) //-- Complemento de viagem nao encontrado (DTR)
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf	

//Verifica se existe uma ocorrência apontada para os documentos.
If lRet .AND. (nOpcX == 4 .OR. nOpcX == 5)
	For nCntFor := 1 To Len(aDocto)
		If nOpcX == 4 .AND. !aDocto[nCntFor, 3]
			aAdd(aDocsDUA, {aDocto[nCntFor,CTFILDOC], aDocto[nCntFor,CTDOCTO], aDocto[nCntFor,CTSERIE]})
		ElseIf nOpcX == 5
			aAdd(aDocsDUA, {aDocto[nCntFor,CTFILDOC], aDocto[nCntFor,CTDOCTO], aDocto[nCntFor,CTSERIE]})
		EndIf
	Next
	If ExistFunc("TMSDocOcor") .AND. !TMSDocOcor(aDocsDUA, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)
		lRet := .F.
	EndIf
EndIf
//-- Quando for ulitizada Operadoras de Frota/Vale-Pedagio,
//-- atualiza os dados da base de dados da Opeardora.
If nOpcx == 3 .Or. nOpcx == 4
	If lRet .And. lTMSOPdg .And. !Empty(aCompViag)
		If Len(aCompViag[11]) >= 7.And. !Empty(aCompViag[11,7])
			aAreaDA3:= DA3->(GetArea())

			For nCntFor := 1 To Len(aCompViag[2])
				If !aCompViag[2][nCntFor][Len(aCompViag[1])+1]

					cCodVei  := aCompViag[2][nCntFor][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODVEI'})]
					cCodMot  := aCompViag[4][nCntFor][2][1][Ascan(aCompViag[3],{|x| x[2] == 'DUP_CODMOT'})]		
					cCodRbq1 := aCompViag[2][nCntFor][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODRB1'})]
					cCodRbq2 := aCompViag[2][nCntFor][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODRB2'})]
					cCodRbq3 := aCompViag[2][nCntFor][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODRB3'})]

					DA3->(DbSetOrder(1))
					If DA3->(MsSeek(xFilial('DA3')+cCodVei))
						laCodigo := .F.
						If lMotAux .And. aCompViag[4][nCntFor][2][1][Ascan(aCompViag[3],{|x| x[2] == 'DUP_CONDUT'})]  == "1"
							laCodigo := .T.
						ElseIf !lMotAux
							laCodigo := .T.
						EndIf
						If laCodigo
							If ExistFunc('RepRetCod')
								RepRetCod(cCodVei, cCodRbq1, cCodRbq2, cCodRbq3, cCodMot, @aCodigos)
							Else
								lRet:= .F.
								Exit
							EndIf
						EndIf
					EndIf
				EndIf
			Next
			RestArea(aAreaDA3)
			If !lRet
				Help( ,, 'HELP',, 'Favor atualizar o Fonte TMSREPOM.PRW !' , 1, 0)	
			Else
				CursorWait()
				MsgRun( STR0076,; //-- "Atualizando dados da Operadora. Por favor Aguarde..."
						STR0075,; //-- "Aguarde comunicacao com a Operadora..."
						{||  lRet := TMSAtualOp( aCompViag[11, 7], '5', aCodigos )})
				CursorArrow()
			EndIf	
		EndIf
	EndIf
EndIf

If lRet .AND. nOpcx == 5  // Excluindo um Viagem , verificar se existe despesas para este documento // caso exista nao excluir viagem
   If TMSDespCx(M->DTQ_FILORI,M->DTQ_VIAGEM) 
  	  Help('',1,'TMSA14026') //-- "Viagem contem despesas lançadas",Favor excluir a(s) operação(ões)","no Movimento do Caixinha"
      lRet := .F.
   EndIf
EndIf

// Executa ponto de entrada para validacao
If lRet .And. lPontoVld
	lRet:=ExecBlock("TMS140VLD",.F.,.F.,{nOpcx})
	If Valtype(lRet) # "L"
		lRet:=.T.
	EndIf
EndIf
RestArea( aAreaDTR )
RestArea( aAreaAnt )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA140bLi³ Autor ³ Alex Egydio           ³ Data ³31.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o bLine dos objetos listbox                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA140bLi()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = 1 = Listbox de Rotas ; 2 = Docto                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA140bLi( nLbx )
If nLbx == 1

	oLbx1:bLine	:= { || { Iif(aRota[oLbx1:nAT,1] , oMarked, oNoMarked ), aRota[oLbx1:nAT,2],;
								 aRota[oLbx1:nAT,3], aRota[oLbx1:nAT,4] ,;
								 Transform(aRota[oLbx1:nAT,5],PesqPictQt('DT6_QTDVOL')),;
								 Transform(aRota[oLbx1:nAT,6],PesqPictQt('DT6_VOLORI')),;
								 Transform(aRota[oLbx1:nAT,7],PesqPict('DT6','DT6_PESO'  )),;
								 Transform(aRota[oLbx1:nAT,8],PesqPict('DT6','DT6_PESOM3')),;
								 Transform(aRota[oLbx1:nAT,9],PesqPict('DT6','DT6_VALMER')) } }

Else
	oLbxDocto:bLine := &('{ || TMSA140Line(oLbxDocto:nAT) }')
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tms140RetB³ Autor ³ Robson Alves          ³ Data ³10.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o bitmap do status.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Status do documento(DUD_STATUS)                    ³±±
±±³          ³ ExpC2 = 1 = Legenda de documentos                          ³±±
±±³          ³         2 = Legenda da rota do documento                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tms140RetBitmap(cStatus,cAcao)

Local aStatus := {}
Local nPosBMP := 0
Local nStatus := Len(DUD->DUD_STATUS)

If cStatus == Nil
	Return( oVerde )
EndIf
//-- Status do documento
If	cAcao == '1'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Array contendo status do documento e bitmap do status.             ³
	//³ Elementos contidos por dimensao :                                         ³
	//³ 1. Status do Documento:                                                   ³
	//³    '1' - Em Aberto                                                        ³
	//³    '2' - Em Transito                                                      ³
	//³    '3' - Carregado                                                        ³
	//³    '4' - Encerrado                                                        ³
	//³    '9' - Cancelado                                                        ³
	//³ 2. Bitmap do Status                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aStatus ,{ StrZero(1 ,nStatus) ,oVerde    } )
	AAdd( aStatus ,{ StrZero(2 ,nStatus) ,oAmarelo  } )
	AAdd( aStatus ,{ StrZero(3 ,nStatus) ,oVermelho } )
	AAdd( aStatus ,{ StrZero(4 ,nStatus) ,oAzul     } )
	AAdd( aStatus ,{ StrZero(9 ,nStatus) ,oPreto    } )

//-- Status da rota do documento
ElseIf cAcao == '2'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Array contendo status da rota do documento e bitmap do status.     ³
	//³ Elementos contidos por dimensao :                                         ³
	//³ 1. Status da rota do documento:                                           ³
	//³    '1' - Da rota                                                          ³
	//³    '2' - Sem rota definida                                                ³
	//³    '3' - De outra rota                                                    ³
	//³ 2. Bitmap do Status.                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aStatus ,{ StrZero(1 ,Len(DUD->DUD_STROTA)) ,oVerde   })
	AAdd( aStatus ,{ StrZero(2 ,Len(DUD->DUD_STROTA)) ,oAmarelo })
	AAdd( aStatus ,{ StrZero(3 ,Len(DUD->DUD_STROTA)) ,oAzul    })
EndIf
nPosBMP := Ascan(aStatus, {|x| x[1] == cStatus})
If nPosBMP == 0
	nPosBMP := 1
EndIf

Return( aStatus[nPosBMP, 2] )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA140Mrk³ Autor ³ Alex Egydio           ³ Data ³29.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca itens do listbox                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA140Mrk(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Identifica o listbox                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA140Mrk( nLbx, nOpcx )

Local aFilDca	:= {}
Local cChave	:= ''
Local nCntFor	:= 0
Local n1Cnt		:= 0
Local nSeek		:= 0
Local nReturn  	:= 0
Local lRet		:= .T.
Local lRetPE	:= .T.
Local cFilDF8 := ""
Local cNumDF8 := ""
//-- Selecionou a Rota no listbox
If nLbx == 1
	
	If nOpcx == 2 .Or. nOpcx == 5
		Return( Nil )
	EndIf
	nSeek := TmsA140ChkRot('1')

	If	nSeek > 0
		//-- Alteracoes de rotas sao permitidas somente na filial de origem
		If	M->DTQ_FILORI != cFilAnt
			Help('',1,'TMSA14021')		//-- Alteracao da rota permitida somente na filial de origem da viagem
			Return( Nil )
		EndIf
		//-- Verifica se ha manifesto
		DTX->(DbSetOrder(3))
		If	DTX->(MsSeek(cChave := xFilial('DTX') + M->DTQ_FILORI + M->DTQ_VIAGEM))
			//-- Permite alterar a rota de uma viagem manifestada, somente se essa rota contemplar todas as filiais de 
			//-- descarga do manifesto
			If	! aRota[oLbx1:nAT,1]
				//-- Obtem as filiais de descarga da rota
				aFilDca := TMSRegDca(aRota[oLbx1:nAT,2])
				nSeek   := 0
				//-- Avalia todos os manifestos da viagem
				While DTX->(!Eof() .And. DTX->DTX_FILIAL + DTX->DTX_FILORI + DTX->DTX_VIAGEM == cChave)
					nSeek := AScan(aFilDca,{|x|x[3]==DTX->DTX_FILDCA})
					If	nSeek <= 0
						Exit
					EndIf
					DTX->(DbSkip())
				EndDo
				//-- A rota nao atende uma das filiais de descarga do manifesto
				If	nSeek <= 0
					Help('',1,'TMSA14020')		//-- Ha manifesto de carga para esta viagem
					Return( Nil )
				EndIf
			EndIf
		EndIf
		cChave := ''
   	EndIf

	aRota[ oLbx1:nAT, 1 ] := !aRota[ oLbx1:nAT, 1 ]
	
	For nCntFor := 1 To Len( aRota )
		If	nCntFor != oLbx1:nAT
			aRota[ nCntFor, 1 ] := .F.
		EndIf
	Next
	oLbx1:Refresh()
	
	If	aRota[oLbx1:nAT,1] .And. (nTipVia == 1 .Or. nTipVia == 3 .Or. (nTipVia == 4 .And. nOpcx != 3 ))
		//-- Se marcou a rota, mostrar seus documentos
		MsgRun(STR0042,,{|| Tmsa140Adc(oLbx1:nAT,nOpcx,"1") })  // "Aguarde, verificando documentos "
 		TmsA140Doc(nOpcx)
	Else
		//-- Se desmarcou a rota, deixe o vetor de documentos em branco.
		TmsA140ZCt(.T.)
	EndIf

	TmsA140All(lAllMark,,nOpcx , nLbx )
	
ElseIf nLbx == 2
	//-- Condicoes nas quais nao deve alterar a marca do documento
	If	!TmsA140MOk(oLbxDocto:nAT,nOpcx)
		Return( Nil )
	EndIf
	If	nTipVia == 2 .OR. (nTipVia == 4 .And. nOpcx == 3)				//-- Viagem Vazia ou Socorro
		Help(' ', 1, 'TMSA14011')	//-- Selecao de documentos nao permitida para viagem vazia.
		Return( Nil )
	EndIf
	//-- Verifica se houve enderecamento
	If	! TmsSldDist(aDocto[oLbxDocto:nAT, CTFILDOC ],aDocto[oLbxDocto:nAT, CTDOCTO ],aDocto[oLbxDocto:nAT, CTSERIE ])
		Return( Nil )
	EndIf
	//-- Selecionar documento, somente se a operacao de descarregamento foi executada
	If lContDCA //parametro MV_CONTDCA Controle de descarga
		If	aDocto[oLbxDocto:nAT,CTBLQDOC]==StrZero(3,Len(DT6->DT6_BLQDOC))
			Help(' ', 1, 'TMSA14014')	//-- Operacao de descarregamento nao executada. (DTW)
		EndIf
	EndIf
	
	If lRet
		If FindFunction("TMSA146Prg") .And. !IsInCallStack(AllTrim('TMSA146'))
			DbSelectArea("DF8")
			If DF8->(ColumnPos("DF8_SEQPRG")) > 0
				lRet:= TMSA146Prg(aDocto[oLbxDocto:nAT, CTFILDOC ] ,aDocto[oLbxDocto:nAT, CTDOCTO ] ,aDocto[oLbxDocto:nAT, CTSERIE ],@cFilDF8,@cNumDF8)
				If !lRet
					Help("",1,"TMSA21061",,cFilDF8 + ' - ' + cNumDF8 ,2,18) // Documento já está em uma Programação de Carregamento: 					
				EndIf
			EndIf	
		EndIf
	EndIf   
	If ExistBlock("TM140COK")
		lRetPE := ExecBlock("TM140COK",.F.,.F.,{aDocto[oLbxDocto:nAT]})
		If ValType(lRetPE) == "L"
			lRet := lRetPE
		EndIf
	EndIf
	If lRet
		//-- Sem endereco.
		//-- Marca/desmarca por nfc.
		If Empty( aDocto[oLbxDocto:nAT, CTLOCALI ] )

			cChave := aDocto[oLbxDocto:nAT, CTFILDOC ] + aDocto[oLbxDocto:nAT, CTDOCTO ] + aDocto[oLbxDocto:nAT, CTSERIE ]

			For nCntFor := 1 To Len( aDocto )
				If	cChave == aDocto[nCntFor, CTFILDOC ] + aDocto[nCntFor, CTDOCTO ] + aDocto[nCntFor, CTSERIE ]
					aDocto[ nCntFor, CTMARCA ]:=!aDocto[ nCntFor, CTMARCA ]
				EndIf
			Next
			For n1Cnt := oLbxDocto:nAT  To Len( aDocto )
				If	cChave <> aDocto[n1Cnt, CTFILDOC ] + aDocto[n1Cnt, CTDOCTO ] + aDocto[n1Cnt, CTSERIE ] .And. !aDocto[ n1Cnt, CTMARCA ]
					nReturn := n1Cnt
					Exit
				EndIf
			Next                   

		//-- Com endereco.
		Else
			//-- Se estiver marcado, desmarcar por nfc.
			If	aDocto[oLbxDocto:nAT, CTMARCA ]

				cChave := aDocto[oLbxDocto:nAT, CTFILDOC ] + aDocto[oLbxDocto:nAT, CTDOCTO ] + aDocto[oLbxDocto:nAT, CTSERIE ]

				For nCntFor := 1 To Len( aDocto )
					If	cChave == aDocto[nCntFor, CTFILDOC ] + aDocto[nCntFor, CTDOCTO ] + aDocto[nCntFor, CTSERIE ]
						aDocto[ nCntFor, CTMARCA ]:=.F.
					EndIf
				Next

			//-- Se estiver desmarcado, marcar por endereco.
			Else

				cChave := aDocto[oLbxDocto:nAT, CTARMAZE ] + aDocto[oLbxDocto:nAT, CTLOCALI ]

				For nCntFor := 1 To Len( aDocto )
					If	cChave == aDocto[nCntFor, CTARMAZE ] + aDocto[nCntFor, CTLOCALI ]
						aDocto[ nCntFor, CTMARCA ] := .T.
					EndIf
				Next

				//-- Se o documento estiver distribuido em mais de um endereco, marcar os enderecos.
				For nCntFor := 1 To Len( aDocto )

					If aDocto[nCntFor, CTMARCA ]

						cChave := aDocto[nCntFor, CTARMAZE ] + aDocto[nCntFor, CTFILDOC ] + aDocto[nCntFor, CTDOCTO ] + aDocto[nCntFor, CTSERIE ]

						For n1Cnt := 1 To Len( aDocto )
							If	cChave == aDocto[n1Cnt, CTARMAZE ] + aDocto[n1Cnt, CTFILDOC ] + aDocto[n1Cnt, CTDOCTO ] + aDocto[n1Cnt, CTSERIE ] .And. ! aDocto[ n1Cnt, CTMARCA ]
								aDocto[ n1Cnt, CTMARCA ] := .T.
							EndIf
						Next
						For n1Cnt := oLbxDocto:nAT  To Len( aDocto )
							If	cChave <> aDocto[n1Cnt, CTARMAZE ] + aDocto[n1Cnt, CTFILDOC ] + aDocto[n1Cnt, CTDOCTO ] + aDocto[n1Cnt, CTSERIE ] .And. !aDocto[ n1Cnt, CTMARCA ]
								nReturn := n1Cnt
								Exit
							EndIf
						Next
							
   					EndIf

				Next

			EndIf

		EndIf
		
	EndIf
	If nReturn <> 0
		oLbxDocto:nAT := nReturn
	EndIf
	oLbxDocto:Refresh()  
EndIf
//-- Atualizando o Rodape
TMSA140Rdp()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA140ZCt³ Autor ³ Alex Egydio           ³ Data ³28.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Zera o listbox de documentos ao desmarcar a rota.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA140ZCt(ExpL1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 =                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA140ZCt(lAtzLbx)

Local aLinha := Array(54)                         
DEFAULT lAtzLbx := .F.

//-- Zera o listbox documentos.
aDocto := {}

aLinha[CTSTATUS] := ''
aLinha[CTSTROTA] := '' 
aLinha[CTMARCA ] := .F. 
aLinha[CTSEQUEN] := Space(Len(DUD->DUD_SEQUEN)) 
aLinha[CTARMAZE] := Space(Len(DUH->DUH_LOCAL)) 
aLinha[CTLOCALI] := Space(Len(DUH->DUH_LOCALI))
aLinha[CTFILDOC] := Space(Len(DUD->DUD_FILDOC)) 
aLinha[CTDOCTO]  := Space(Len(DUD->DUD_DOC)) 
aLinha[CTSERIE]  := Space(Len(DUD->DUD_SERIE)) 
aLinha[CTREGDES] := Space(Len(DUY->DUY_DESCRI)) 
aLinha[CTDATEMI] := CtoD('') 
aLinha[CTPRZENT] := CtoD('') 
aLinha[CTNOMREM] := Space(Len(SA1->A1_NREDUZ)) 
aLinha[CTNOMDES] := Space(Len(SA1->A1_NREDUZ)) 
aLinha[CTESTADO] := Space(Len(DUY->DUY_EST) ) 
aLinha[CTDATENT] := CtoD('') 
aLinha[CTQTDVOL] := 0 
aLinha[CTVOLORI] := 0 
aLinha[CTPLIQUI] := 0 
aLinha[CTPESOM3] := 0 
aLinha[CTVALMER] := 0 
aLinha[CTVIAGEM] := .F. 
aLinha[CTSEQDA7] := '' 
aLinha[CTSOLICI] := Space(Len(DUE->DUE_NOME))   	//-- DUE_NOME
aLinha[CTENDERE] := Space(Len(SA1->A1_END))     	//-- DUE_END
aLinha[CTBAIRRO] := Space(Len(SA1->A1_BAIRRO))  	//-- DUE_BAIRRO
aLinha[CTMUNICI] := Space(Len(SA1->A1_MUN))     	//-- DUE_MUN
aLinha[CTDATSOL] := CtoD('')						//-- DT5_DATSOL
aLinha[CTHORSOL] := Space(Len(DT5->DT5_HORSOL))  	//-- DT5_HORSOL 
aLinha[CTDATPRV] := CtoD('') 						//-- DT5_DATPRV
aLinha[CTHORPRV] := Space(Len(DT5->DT5_HORPRV))	//-- DT5_HORPRV
aLinha[CTDOCROT] := '' 								//-- Codigo que identifica a q rota pertence o documento
aLinha[CTBLQDOC] := '' 								//-- Tipos de bloqueio do documento
aLinha[CTNUMAGE] := '' 								//-- Numero do Agendamento( Carga Fechada ).
aLinha[CTITEAGE] := '' 								//-- Item do Agendamento( Carga Fechada ).
aLinha[CTSERTMS] := '' 								//-- Tipo do Servico.
aLinha[CTDESSVT] := ''								//-- Descricao do Servico.
aLinha[CTUNITIZ] := Space(Len(DUH->DUH_UNITIZ))
aLinha[CTCODANA] := Space(Len(DUH->DUH_CODANA))

aLinha[CTUFORI ]:= ''
aLinha[CTCDMUNO]:= ''
aLinha[CTCEPORI]:= ''
aLinha[CTUFDES ]:= ''
aLinha[CTCDMUND]:= ''
aLinha[CTCEPDES]:= ''
aLinha[CTTIPVEI]:= ''
aLinha[CTCDCLFR]:= ''
aLinha[CTCDTPOP]:= ''
AAdd(aDocto,AClone(aLinha))

If lAtzLbx .And. type("oLbxDocto") == 'O'

	oLbxDocto:SetArray( aDocto )
	
	//-- Monta o bLine do listbox.
	TMSA140bLi( 2 )

	oLbxDocto:Refresh()

EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140VisDoc³ Autor ³ Alex Egydio        ³ Data ³25.04.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta listbox para selecao de documentos da viagem,    ³±±
±±³          ³ documentos sem rota definida e documentos de outras rotas  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Coordenadas para o listbox qd executada da funcao  ³±±
±±³          ³         TmsA140Mnt()                                       ³±±
±±³          ³ ExpC1 = Titulo da dialog, qd rota variavel                 ³±±
±±³          ³ ExpN1 = Opcoes de manutencao                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140VisDoc(aPosObjH,cTitDocto,nOpcx)

Local nCnt
Local nCntFor
Local aHDocto	:= {}
Local aButtons	:= {}
Local lTela		:= .F.
Local lRet		:= .F.
Local nLinha	:= 0
Local nColuna	:= 0
Local nSize1	:= 0
Local nSize2	:= 0
Local oDlgAnt	:= oDlgEsp
//-- Controle de dimensoes de objetos
Local aInfo		:= {}
Local aObjects	:= {}
Local aPosObj	:= {}
Local aSize		:= {}

If	ValType(aPosObjH)=='A'
	nLinha	:= aPosObjH[2,1]
	nColuna	:= aPosObjH[2,2]
	nSize1	:= aPosObjH[2,3]
	nSize2	:= aPosObjH[2,4]-8
Else
	//-- Dimensoes padroes
	aSize 	:= MsAdvSize()
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	nLinha	:= aPosObj[1,1]
	nColuna	:= aPosObj[1,2]
	nSize1	:= aPosObj[1,4]-aPosObj[1,2]
	nSize2	:= aPosObj[1,3]-aPosObj[1,1]-15
	lTela	:= .T.
EndIf

AAdd(aButtons,	{'PESQUISA',{|| TMSA140Psq() }, STR0031 })	//'Pesquisa'

//-- Cabecalho do listbox de documentos
AAdd( aHDocto, ' ' )
AAdd( aHDocto, ' ' )
AAdd( aHDocto, ' ' )

If lLocaliz
	AAdd( aHDocto, Posicione('SX3', 2, 'DUH_LOCAL'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DUH_LOCALI'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DUH_UNITIZ'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DUH_CODANA'	, 'X3Titulo()') )	
EndIf

AAdd( aHDocto ,Posicione('SX3' ,2 ,'DUD_FILDOC' ,'X3Titulo()') )
AAdd( aHDocto ,Posicione('SX3' ,2 ,'DUD_DOC'    ,'X3Titulo()') )
AAdd( aHDocto ,Posicione('SX3' ,2 ,'DUD_SERIE'  ,'X3Titulo()') )
AAdd( aHDocto ,Posicione('SX3' ,2 ,'DTC_REGDES' ,'X3Titulo()') )
AAdd( aHDocto ,Posicione('SX3' ,2 ,'DUY_EST'    ,'X3Titulo()') )
AAdd( aHDocto ,Posicione('SX3' ,2 ,'DTC_DATENT' ,'X3Titulo()') )
AAdd( aHDocto ,Posicione('SX3' ,2 ,'DT6_PRZENT' ,'X3Titulo()') )
AAdd( aHDocto ,Posicione('SX3' ,2 ,'DTC_NOMREM' ,'X3Titulo()') )
AAdd( aHDocto ,Posicione('SX3' ,2 ,'DTC_NOMDES' ,'X3Titulo()') )
AAdd( aHDocto ,Posicione('SX3' ,2 ,'DT6_QTDVOL' ,'X3Titulo()') )
AAdd( aHDocto ,Posicione('SX3' ,2 ,'DT6_VOLORI' ,'X3Titulo()') )
AAdd( aHDocto ,Posicione('SX3' ,2 ,'DT6_PESO'   ,'X3Titulo()') )
AAdd( aHDocto ,Posicione('SX3' ,2 ,'DT6_PESOM3' ,'X3Titulo()') )
AAdd( aHDocto ,Posicione('SX3' ,2 ,'DT6_VALMER' ,'X3Titulo()') )
//-- Inclui colunas do usuario
If lTM141COL
	For nCnt := 1 To Len(aUsHDocto)
		AAdd( aHDocto, aUsHDocto[nCnt,1] )
	Next nCnt
EndIf

If	lTela
	DEFINE MSDIALOG oDlgEsp TITLE cTitDocto FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
EndIf

@ nLinha, nColuna Say STR0017 OF oDlgEsp PIXEL //' Documentos '
	
oLbxDocto := TWBrowse():New( nLinha+7, nColuna, nSize1, nSize2, Nil, ;
                                 aHDocto, Nil, oDlgEsp, Nil, Nil, Nil,,,,,,,,,, "ARRAY", .T. )
oLbxDocto:bLDblClick  := { || { TMSA140Mrk(2,nOpcx) }}
oLbxDocto:SetArray( aDocto )
TMSA140bLi( 2 )

If	nOpcx == 3 .Or. nOpcx == 4
	//-- Marca/desmarca documentos
	@ nLinha - 2, nColuna + 60 CHECKBOX oAllMark VAR lAllMark PROMPT STR0018 SIZE 68, 05;  //'Marca/Desmarca todos '
	ON CLICK( TmsA140All(lAllMark,,nOpcx) ) OF oDlgEsp PIXEL
EndIf

If	lTela
	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||lRet := .T.,oDlgEsp:End()},{||oDlgEsp:End()},,aButtons)
EndIf

oDlgEsp := oDlgAnt

//-- Na alteracao, guardo os documentos da viagem no vetor aBkpDocto
If	nOpcx == 4 .And. Empty( aBkpDocto )
	For nCntFor := 1 To Len( aDocto )
		If	aDocto[ nCntFor, CTVIAGEM ]
			AAdd( aBkpDocto, aDocto[ nCntFor ] )
		EndIf
	Next
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140All³ Autor ³ Alex Egydio           ³ Data ³05.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/desmarca todos os documentos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140All(lAllMark,lEntrega,nOpcx, nLbx)

Local aAreaDT6	:= DT6->(GetArea())
Local nCntFor	:= 0
Local lRet		:= .T.

DEFAULT lEntrega := .F.
Default nLbx	 := 2 

If ! lColeta
	For nCntFor := 1 To Len( aDocto )
		If	! lEntrega .Or. (lEntrega .And. nRotPor != 2)
			//-- Verifica se houve enderecamento
			If	!TmsSldDist(aDocto[nCntFor, CTFILDOC ],aDocto[nCntFor, CTDOCTO ],aDocto[nCntFor, CTSERIE ])
				lRet := .F.
				Exit
			EndIf
		EndIf
		If lContDCA
			//-- Selecionar documento, somente se a operacao de descarregamento foi executada
			DT6->( DbSetOrder( 1 ) )
			If	DT6->( MsSeek( xFilial('DT6') + aDocto[nCntFor, CTFILDOC ] + aDocto[nCntFor, CTDOCTO ] + aDocto[nCntFor, CTSERIE ] ) ) .And.;
				DT6->DT6_BLQDOC == StrZero(3,Len(DT6->DT6_BLQDOC))
				Help(' ', 1, 'TMSA14014')	//-- Operacao de descarregamento nao executada. (DTW)
				//-- Se for viagem de entrega, envia mensagem e deixa marcar.
				lRet := Iif( lEntrega, .T., .F. )
				Exit
			EndIf
		EndIf
	Next
EndIf

If	lRet
	For nCntFor := 1 To Len( aDocto )
		//-- Condicoes nas quais nao deve alterar a marca do documento
		If	TmsA140MOk(nCntFor,nOpcx,nLbx)
			aDocto[nCntFor,CTMARCA] := lAllMark
		EndIf
	Next
	oLbxDocto:Refresh()
	//-- Atualizando o Rodape
	TMSA140Rdp()
EndIf
RestArea( aAreaDT6 )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA140Grv³ Autor ³ Alex Egydio           ³ Data ³31.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava / Estorna Viagens                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA140Grv()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao selecionada                                  ³±± 
±±³          ³ ExpL1 - indica que esta usando o modo de viagem express    ³±± 
±±³          ³ ExpL2 - indica que está sendo gerado pela primeira vez     ³±± 
±±³          ³         na rotina da viagem EXPRESS para controle do SDG   ³±± 
±±³          ³ ExpD1 = Data de início da viagem                           ³±±
±±³          ³ ExpC1 = Hora de início da viagem                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA140Grv( nOpcx, lVgeExpr, lGrvExpr, dDatGer, cHorGer, nPosDTQ, lValBlq )
Local cRatItC    := ''
Local aAreaAnt   := GetArea()
Local aAreaDTQ   := DTQ->(GetArea())
Local aAreaDUD   := DUD->(GetArea())
Local bCampo     := { |nCpo| Field(nCpo) }
Local cMemo      := ''
Local lCarreg    := .F.
Local nRota      := 0
Local nDocto     := 0
Local nCntFor    := 0
Local nCntFor1   := 0
Local aRegioes   := {}
Local cSeekDUD   := ''
Local lTM140GRV  := ExistBlock("TM140GRV") //-- PE chamado apos a inclusao, alteracao ou exclusao da Viagem de Transferencia
Local lTM141EST  := ExistBlock("TM141EST") //-- PE chamado apos a confirmacao de exclusão da viagem
Local lTM140DUD  := ExistBlock('TM140DUD')
Local lRet       := .T.
Local lTMSOPdg   := SuperGetMV( 'MV_TMSOPDG',, '0' ) <> '0' //-- Operadoras de Frota/Vale-Pedagio
Local lDTRTPSPDG := DTR->(ColumnPos("DTR_TPSPDG")) > 0
Local aAvaliaBlq := {}
Local nOpcDF7    := nOpcX
Local nPosCodVei := 0
Local lAltRota   := .F.
Local lAltFilDca := .F.
Local nX         := 0
Local lVgeMod2   := (Left(FunName(),7) == 'TMSA144' .Or. Left(FunName(),7) == 'TMSA143')
Local aPosicao   := {}
Local lRotAut    := FindFunction("F11RotRote") .AND. F11RotRote(M->DTQ_ROTA) 
Local lTabDF8    :=  AliasIndic("DF8") 
Local lTmsa029   := FindFunction("TMSA029USE")
Local lTMS3GFE   := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local lExstMemos := Iif(Type('aMemos') == 'A', .T., .F.)
Local nRegDTQ		:= 0
Local aAreaBkp	    := {} 
Local lTMSDCol := SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitaï¿½ï¿½o de coleta.
Local lAltTipOpVg   := .F.
Local lTipOpVg      := DTQ->(ColumnPos("DTQ_TPOPVG")) > 0

If Type('aBkpDocto') == 'U'
	Private aBkpDocto := {}
EndIf

If Type('cRotaInf') == 'U'  
	cRotaInf := ''
EndIf

If Type('cTipOpVgAnt') == 'U'
	cTipOpVgAnt := ''
EndIf

Default lVgeExpr := .F.
Default lGrvExpr := .F.
Default dDatGer  := dDataBase
Default cHorGer  := StrTran(Left(Time(),5),':','')
Default nPosDTQ  := 0
Default lValBlq  := .T.

AAdd( aPosicao ,CTMARCA  )
AAdd( aPosicao ,CTFILDOC )
AAdd( aPosicao ,CTDOCTO  )
AAdd( aPosicao ,CTSERIE  )

If Type('aRetRbq') == 'U'
	aRetRbq := {}
EndIf

If lTabDF8
	DbSelectARea("DF8")
	lTabDF8:= DF8->(ColumnPos("DF8_SEQPRG")) > 0
EndIf

If	nOpcx == 5	//-- Excluir
	Begin Transaction
		For nRota := 1 To Len( aRota )
			//-- Verifica se marcou uma rota
			If	aRota[ nRota, 1 ]

				//-- Se houver documentos carregados, a exclusao da viagem sera permitida apos o
				//-- estorno do carregamento
				If	aRota[ nRota, 9 ]
					Help(' ', 1, 'TMSA14009')		//-- Ha documentos carregados nesta viagem
					Exit
				EndIf

				DTQ->( DbSetOrder( 2 ) )
				If	DTQ->( MsSeek( xFilial('DTQ') + M->DTQ_FILORI + M->DTQ_VIAGEM ) )
					RecLock('DTQ',.F.,.T.)
					DTQ->(DbDelete())
					MsUnLock()
				EndIf

				//-- Exclui Dados Da Tabela DIY (Restrições da Viagem)
				If AliasInDic("DIY")
				
					DbSelectArea("DIY")
					DbSetOrder(1) //-- DIY_FILIAL+DIY_FILORI+DIY_VIAGEM+DIY_CODBLQ+DIY_CODREG+DIY_CATEGO+DIY_ITEM
					While DIY->( MsSeek( xFilial('DIY') + M->DTQ_FILORI + M->DTQ_VIAGEM, .F. ) )
						RecLock('DIY',.F.)
						DIY->(DbDelete())
						DIY->(MsUnLock())
					EndDo					
				EndIf								
				//Retira a Viagem do Lote
				If TmsExp() .And. lVgeExpr
					DTP->( DbSetOrder( 3 ) )
					While	DTP->( MsSeek( xFilial('DTP') + M->DTQ_FILORI + M->DTQ_VIAGEM ) )
						RecLock('DTP',.F.,.T.)
						DTP->DTP_VIAGEM := ""
						MsUnLock()
					EndDo
				EndIf

				For nDocto := 1 To Len( aDocto )
					//-- Verifica se marcou um documento
					If	aDocto[ nDocto, CTMARCA ]
						TMSA140Del( aDocto[nDocto, CTFILDOC], aDocto[nDocto, CTDOCTO ], aDocto[nDocto, CTSERIE ], aDocto[nDocto, CTVIAGEM ], aDocto[nDocto, CTUNITIZ ],aDocto[nDocto, CTCODANA] )
					EndIf
				Next

				//-- Exclui bloqueio da viagem
				DUC->( DbSetOrder( 1 ) )
				While DUC->( MsSeek( xFilial('DUC') + M->DTQ_FILORI + M->DTQ_VIAGEM ) )
					If	(DUC->DUC_CODBLQ == PadR('D1', Len(DUC->DUC_CODBLQ)) .Or.;
						 DUC->DUC_CODBLQ == PadR('D2', Len(DUC->DUC_CODBLQ)) .Or.;
						 DUC->DUC_CODBLQ == PadR('D3', Len(DUC->DUC_CODBLQ)) .Or.;
						 DUC->DUC_CODBLQ == PadR('D4', Len(DUC->DUC_CODBLQ)))
						
						AAdd(aAvaliaBlq ,{	DUC->DUC_CODBLQ,;
											DUC->DUC_CODFOR,;
											DUC->DUC_LOJFOR,;
											DUC->DUC_CODMOT,;
											DUC->DUC_DTAAPR,;
											DUC->DUC_DTAAFA,;
											DUC->DUC_DTARET,;
											.F. } )
					EndIf
					RecLock('DUC',.F.,.T.)
					DUC->(DbDelete())
					MsUnLock()
				EndDo
				//-- Ajusta o Status das Tabelas referentes ao Controle de Documentos de Terceiros
				TMSAvlBlqDoc( aAvaliaBlq, .T. )

				// Exclui Registro De Bloqueio Por Incompatibilidade De Produtos.
				If lTmsa029  
					If Tmsa029Use("TMSA140")

						// Caso Existam Bloqueios, Limpa Referencia
						Tmsa029Blq( 5  ,;				// 01 - nOpc
									'TMSA140',;		// 02 - Rotina
									Nil,;				// 03 - Tipo Bloq (Nil Apaga Todos Codigos de Bloqueio da Viagem
									M->DTQ_FILORI,;	// 04 - Filial Origem
									'DUC',;			// 05 - Tabela Referencial
									'1',;				// 06 - Indice Da Tabela
									xFilial('DUC') + M->DTQ_FILORI + M->DTQ_VIAGEM,;	// 07 - Chave Indexação
									"",;				// 08 - Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
									"",;				// 09 - Detalhes Adicionais a Respeito Do Bloqueio
									nOpcx)				// 10 - Opcao da Rotina 
					EndIf
					
					If Tmsa029Use("TMSA310")				
						// Caso Existam Bloqueios, Limpa Referencia
						Tmsa029Blq( 5  ,;				// 01 - nOpc
									'TMSA310',;		// 02 - Rotina
									Nil,;				// 03 - Tipo Bloq (Nil Apaga Todos Codigos de Bloqueio da Viagem
									M->DTQ_FILORI,;	// 04 - Filial Origem
									'DTQ',;			// 05 - Tabela Referencial
									'1',;				// 06 - Indice Da Tabela
									xFilial('DTQ') + M->DTQ_FILORI + M->DTQ_VIAGEM,;	// 07 - Chave Indexação
									"",;				// 08 - Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
									"",;				// 09 - Detalhes Adicionais a Respeito Do Bloqueio
									nOpcx)				// 10 - Opcao da Rotina			
									
					EndIf

				EndIf
  
				//-- Cancela Programação de Carregamento
				If lTabDF8
					DbSelectArea('DF8')
					DF8->( DbSetOrder( 2 ) ) //-- DF8_FILIAL+DF8_FILORI+DF8_VIAGEM
					If DbSeek(xFilial("DF8") + M->DTQ_FILORI + M->DTQ_VIAGEM)
						RecLock("DF8",.F.)
						DF8->DF8_STATUS:= '9'   //Cancelada
						DF8->(MsUnLock())
					EndIf
				EndIf
				//-- Exclui complemento da viagem
				RegToMemory('DTR',.T.)
				M->DTR_FILORI := M->DTQ_FILORI
				M->DTR_VIAGEM := M->DTQ_VIAGEM
				lRet := TmsA240Grv( 5 )

                    //| Se houve algum problema na integração de exclusão ou no processo de exclusão.
                    If !lRet
                        DisarmTransaction()
                        Exit
                    EndIf

				// Exclui Rota Automatica
				If lRotAut .And. lRet
					TF10GrRote(5,M->DTQ_FILORI, M->DTQ_VIAGEM)
				EndIf
				//-- Trata o Retorno de Reboque
				DF7->(DbSetOrder(3))
				If DF7->(MsSeek(xFilial('DF7') + M->(DTQ_FILORI+M->DTQ_VIAGEM)))
					RegToMemory('DF7',.F.)
					TMSAF15Grv( 5 )
				EndIf

				If lTM141EST
					ExecBlock("TM141EST",.F.,.F.,{M->DTR_FILORI,M->DTR_VIAGEM})
				EndIf

			EndIf
		Next

		//-- Gera tabelas específicas da viagem modelo 3
		If lViagem3 .And. cSerTms != StrZero(1,Len(DTQ->DTQ_SERTMS))
			If lRet  .And. FindFunction('TmsAjuMod3')
				TmsAjuMod3(M->DTQ_FILORI,M->DTQ_VIAGEM,nOpcx,.T.)
			EndIf
		EndIf

		EvalTrigger()
	End Transaction
EndIf

If	nOpcx == 3 .Or. nOpcx == 4				// Incluir ou Alterar

	If nOpcx == 3
		If !IsBlind() .And. dDataBase <> Date() .And. dDataBase + 1 == Date()  .And. MsgYesNo( STR0116 , STR0117 ) //-- "Deseja atualizar a data do sistema, de acordo com a data do servidor?" "Deseja atualizar a data?"
			FwDateUpd( .F. , .T.)
			dDatGer  := dDataBase
			cHorGer  := StrTran(Left(Time(),5),':','')
		EndIf
	EndIf

	Begin Transaction

		For nRota := 1 To Len( aRota )

			//-- Verifica se marcou uma rota
			If	aRota[ nRota, 1 ]
				//-- Se houve uma alteracao de rota, retirar o nr. de viagem de todos os documentos
				DTQ->( DbSetOrder( 2 ) )
				If DTQ->( MsSeek( xFilial('DTQ') + M->DTQ_FILORI + M->DTQ_VIAGEM, .F. ) )	
					If	nOpcx == 4 
						If aRota[ nRota, 2 ] != DTQ->DTQ_ROTA
	
							lAltRota := .T.
		
							DTA->(DbSetOrder(1))
							If lVgeMod2 // Se estiver utilizando Viagem Mod. 2
								For nX := 1 To Len(aCols)
									If !GDDeleted( nX ) .And. DTA->(MsSeek(xFilial("DTA")+GdFieldGet('DTA_FILDOC',nX)+GdFieldGet('DTA_DOC',nX)+GdFieldGet('DTA_SERIE',nX)+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
										If GdFieldGet('DUD_STROTA',nX) == '3'  // Se documento nao fizer parte da rota.
											lAltFilDca := .T.
										EndIf
									EndIf
								Next nX
							Else
								For nX := 1 To Len(aDocto)
									If aDocto[nX][CTMARCA] .And. DTA->(MsSeek(xFilial("DTA")+aDocto[nX][CTFILDOC]+aDocto[nX][CTDOCTO]+aDocto[nX][CTSERIE]+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
										If aDocto[nX][CTSTATUS] == '3'  // Se documento nao fizer parte da rota.
											lAltFilDca := .T.
										EndIf
									EndIf
								Next nX
							EndIf
		
							//-- Na alteracao, guardo os documentos da viagem no vetor aBkpDocto
							If	nOpcx == 4 .And. Empty( aBkpDocto )
								For nCntFor := 1 To Len( aDocto )
									If	aDocto[ nCntFor, CTVIAGEM ]
										AAdd( aBkpDocto, aDocto[ nCntFor ] )
									EndIf
								Next
							EndIf
		
							For nDocto := 1 To Len( aBkpDocto )
								If	aBkpDocto[nDocto,CTSTATUS] == StrZero(1,Len(DUD->DUD_STATUS))
									TMSA140Del( aBkpDocto[nDocto, CTFILDOC], aBkpDocto[nDocto,CTDOCTO], aBkpDocto[nDocto,CTSERIE], aBkpDocto[nDocto,CTVIAGEM], aBkpDocto[nDocto, CTUNITIZ ],aBkpDocto[nDocto, CTCODANA] ) 
								Else
									//-- Carregamento automatico
									If ( nCarreg > 1 )
										lCarreg := .T.
									EndIf
								EndIf
							Next
						EndIf
						If lTipOpVg  .And. AllTrim(cTipOpVgAnt) <> AllTrim(M->DTQ_TPOPVG)   //Alteração da Negociacao na Inclusao da Viagem apos informar o Complemento para recalcular o frete
							lAltTipOpVg := .T.
						Endif
					EndIf	
				EndIf
				If nOpcx == 3 
					If !Empty(cRotaInf) .And. cRotaInf <> M->DTQ_ROTA   //Alteração da Rota na Inclusao da Viagem apos informar o Complemento para recalcular o frete
						lAltRota := .T.
					Endif
					If lTipOpVg  .And. AllTrim(cTipOpVgAnt) <> AllTrim(M->DTQ_TPOPVG)   //Alteração da Negociacao na Inclusao da Viagem apos informar o Complemento para recalcular o frete
						lAltTipOpVg := .T.
					Endif
				EndIf
				//-- Obtem as regioes da rota de transferencia
				If cSerTms == StrZero( 2, Len( DTQ->DTQ_SERTMS ) ) //-- Transporte
					//-- Retorna as Filiais / Regioes de Descarga da Rota
					//-- Elementos contidos por dimensao:
					//-- 1. Regiao Origem da Rota
					//-- 2. Regioes de Descarga da Rota
					//-- 3. Filiais de Descarga da Rota
					aRegioes:= TMSRegDca( aRota[ nRota, 2 ] )
					//-- Atribui a Filial de Destino
					If	! Empty( aRegioes )
						M->DTQ_FILDES := aRegioes[ Len( aRegioes ), 3 ]
					EndIf
				EndIf

				//-- Confirma a geracao da viagem.
				M->DTQ_ROTA		:= aRota[ nRota, 2 ]

				If nOpcx == 3
					M->DTQ_DATGER := dDatGer
					M->DTQ_HORGER := cHorGer
					M->DTQ_TIPVIA := StrZero( nTipVia, Len( DTQ->DTQ_TIPVIA ) )
				EndIf

				//-- Se algum documento foi marcado, sera confirmado o carregamento gravando o numero
				//-- da viagem nos documentos
				For nDocto := 1 To Len( aDocto )
					//-- Verifica se marcou um documento
					If	aDocto[ nDocto, CTMARCA ] 

						DUD->(DbSetOrder(1)) //DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM
						If  !DUD->(MsSeek(cSeekDUD := xFilial('DUD') + aDocto[ nDocto, CTFILDOC ] + aDocto[ nDocto, CTDOCTO ] + aDocto[ nDocto, CTSERIE ] + cFilAnt, .F.))
							DUD->(MsSeek(cSeekDUD := xFilial('DUD') + aDocto[ nDocto, CTFILDOC ] + aDocto[ nDocto, CTDOCTO ] + aDocto[ nDocto, CTSERIE ] + M->DTQ_FILORI , .F.))
						EndIf
						While DUD->(!Eof() .And. DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI == cSeekDUD)

							If Iif(Empty(DUD->DUD_NUMVGE),.T.,DUD->DUD_NUMVGE <> M->DTQ_VIAGEM) .And.  DUD->DUD_SERTMS == cSerTms .And. DUD->DUD_STATUS == StrZero(1,Len(DUD->DUD_STATUS))
								If Empty(DUD->DUD_VIAGEM) .Or. (TmsExp() .And. lVgeExpr)
									RecLock('DUD',.F.)
									If	aDocto[ nDocto, CTSEQUEN ] != Replicate('x',Len(DUD->DUD_SEQUEN))
										DUD->DUD_SEQUEN := aDocto[ nDocto, CTSEQUEN ]
									EndIf
									If DUD->DUD_SERTMS == StrZero( 2, Len( DUD->DUD_SERTMS ) ) .Or. lTMSDCol // Transporte ou despreza filial de origem
										DUD->DUD_FILORI := M->DTQ_FILORI  // Para os casos de documentos de outra filial
									EndIf
									DUD->DUD_VIAGEM := M->DTQ_VIAGEM
									DUD->DUD_GERROM := StrZero(1,Len(DUD->DUD_GERROM))
									DUD->DUD_STROTA := aDocto[ nDocto, CTSTROTA ]
									//--- Dados Integração TMS x GFE digitados somente pela viagem modelo 2
									If lTMS3GFE
										If ('TMSA144' $ AllTrim(FunName())) .And. Empty(DUD->DUD_NUMRED)
											DUD->DUD_UFORI  := aDocto[ nDocto, CTUFORI  ]
											DUD->DUD_CDMUNO := aDocto[ nDocto, CTCDMUNO ]
											DUD->DUD_CEPORI := aDocto[ nDocto, CTCEPORI ]
											DUD->DUD_UFDES  := aDocto[ nDocto, CTUFDES  ]
											DUD->DUD_CDMUND := aDocto[ nDocto, CTCDMUND ]
											DUD->DUD_CEPDES := aDocto[ nDocto, CTCEPDES ]
											DUD->DUD_TIPVEI := aDocto[ nDocto, CTTIPVEI ]
											DUD->DUD_CDCLFR := aDocto[ nDocto, CTCDCLFR ]
											DUD->DUD_CDTPOP := aDocto[ nDocto, CTCDTPOP ]
										EndIf	
									EndIf
									MsUnLock()
									//--Destravar o documento apos a gravacao
									TmsConTran(aDocto[nDocto,CTFILDOC] , aDocto[nDocto,CTDOCTO] , aDocto[nDocto,CTSERIE] )

									//-- Atualiza status da solitacao da coleta
									If lColeta
										DT5->( DbSetOrder( 4 ) )
										If DT5->( MsSeek( xFilial()+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE) ) )
											RecLock("DT5",.F.)
											DT5->DT5_STATUS := StrZero( 2, Len( DT5->DT5_STATUS ) ) // Indicada para Coleta
											MsUnLock()
										EndIf
									EndIf
								EndIf
								If lTM140DUD
									ExecBlock('TM140DUD',.F.,.F.,{nOpcx, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE, nDocto})
								EndIf								
								//-- Carregamento automatico
								If	( nCarreg > 1 )
									lCarreg := .T.
								EndIf
								Exit
							EndIf
							DUD->(dbSkip())
						EndDo

					Else
						//-- Se desmarcou um documento, que estava vinculado a uma viagem, apagar o campo
						//-- codigo da viagens deste documento.
						If	aDocto[nDocto,CTSTATUS] != StrZero(3,Len(DUD->DUD_STATUS))
							TMSA140Del( aDocto[nDocto, CTFILDOC], aDocto[nDocto, CTDOCTO ], aDocto[nDocto, CTSERIE ], aDocto[nDocto, CTVIAGEM ], aDocto[nDocto, CTUNITIZ ],aDocto[nDocto, CTCODANA] )
						EndIf
					EndIf
				Next

				 
				DTQ->( DbSetOrder( 2 ) )
				If	DTQ->( MsSeek( xFilial('DTQ') + M->DTQ_FILORI + M->DTQ_VIAGEM, .F. ) )
					RecLock('DTQ',.F.)
				Else
					RecLock('DTQ',.T.)
				EndIf

				//Guarda o recno da DTQ para restaurar no final
				nPosDTQ := DTQ->(RecNo())
				For nCntFor := 1 To FCount()
					If FieldName(nCntFor) == 'DTQ_FILIAL'
						FieldPut(nCntFor, xFilial('DTQ'))
					ElseIf Left(Alltrim(FieldName(nCntFor)),3) == "DTQ"  //Tratamento devido ao error.log nao identificado na LIB (DA8_DESC)
						FieldPut(nCntFor, M->&(EVAL(bCampo,nCntFor)))
					EndIf
				Next
				//-- Grava os Campos Memos Virtuais
				If lExstMemos
					cMemo := aMemos[1,2]
					If	nOpcx == 3		//Inclusao
						MSMM(,TamSx3(aMemos[1,2])[1],,&cMemo,1,,,'DTQ',aMemos[1,1])
					Else
						MSMM(&(aMemos[1,1]),TamSx3(aMemos[1,2])[1],,&cMemo,1,,,'DTQ',aMemos[1,1])
					EndIf
				EndIf

				MsUnLock()
				If __lSX8 .AND. !IsInCallStack("TMSA146")
					ConfirmSX8()
				EndIf

			EndIf
		Next
		If Len(aCompViag) > 0
			RegToMemory('DTR',.T.)
			M->DTR_FILORI := M->DTQ_FILORI
			M->DTR_VIAGEM := M->DTQ_VIAGEM
			M->DTR_DATINI := aCompViag[11, 3]
			M->DTR_HORINI := aCompViag[11, 4]
			M->DTR_DATFIM := aCompViag[11, 5]
			M->DTR_HORFIM := aCompViag[11, 6]

			If lTMSOPdg
				M->DTR_CODOPE := aCompViag[11, 7]
				M->DTR_PERADI := aCompViag[11, 8]	
				If lDTRTPSPDG
					M->DTR_TPSPDG := aCompViag[11, 10]
					M->DTR_QTDSAQ := aCompViag[11, 11]
					M->DTR_QTDTRA := aCompViag[11, 12]
				EndIf			
			EndIf
			
			If DTR->(FieldPos('DTR_TIPCRG')) > 0
					M->DTR_TIPCRG := aCompViag[11, 9]
			EndIf
			If Len(aCompViag[11]) >	12			
				M->DTR_PRCTRA	:= aCompViag[11, 13]
			EndIf

			lRet := TmsA240Grv( nOpcx, aCompViag,  M->DTQ_FILORI, M->DTQ_VIAGEM,,,,lGrvExpr, lAltRota, ,lAltTipOpVg )
			
			//| Se houve algum problema na integração EAI pelo TmsA240Grv ou no processo de gravação do complemento da viagem...
			If !lRet
				DisarmTransaction()
				Break
           Else
           	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se Alteracao, Verifica se existem viagens Interligadas 'a Viagem Original.³
				//³ Caso Exista, altera automaticamente todas as viagens Interligadas.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nOpcx == 4 .And. Len(aCompViag) > 0 .And. !(FindFunction("A240AtuDTR"))
					nRegDTQ:= DTQ->(Recno())
					aAreaBkp:= GetArea() 
					
					DTR->(dbSetOrder(2)) // DTR_FILVGE + DTR_NUMVGE
					If DTR->(MsSeek(xFilial('DTR')+M->DTR_FILORI+M->DTR_VIAGEM))
						Do While !DTR->(Eof()) .And. DTR->DTR_FILIAL+DTR->DTR_FILVGE+DTR->DTR_NUMVGE == xFilial('DTR')+M->DTR_FILORI+M->DTR_VIAGEM
							If ValType(aCompViag) == "A" .And. !Empty(aCompViag)
								aCompViag[11, 1] := DTR->DTR_FILVGE
								aCompViag[11, 2] := DTR->DTR_NUMVGE
							EndIf
								
							DTQ->( DbSetOrder( 2 ) )
							If DTQ->( MsSeek( xFilial('DTQ') + DTR->DTR_FILORI + DTR->DTR_VIAGEM, .F. ) )
			
								If !TMSA240Grv(nOpcx,aCompViag, DTR->DTR_FILORI, DTR->DTR_VIAGEM, DTR->DTR_FILVGE , DTR->DTR_NUMVGE, 2, , lAltRota, ,lAltTipOpVg )
									DisarmTransaction()
									Break
								EndIf
							EndIf
							DTR->(dbSkip())
						EndDo	
					EndIf
					
					RestArea(aAreaBkp)
					DTQ->(dbGoTo(nRegDTQ))
				EndIf
			
           EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento para o Retorno de Reboque lancado a partir da tela de ³
		//³ Complemento de Viagem                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aCompViag) > 0
			nPosCodVei := aScan(aCompViag[1], {|x| Alltrim(x[2]) == 'DTR_CODVEI'} )
			For nCntFor := 1 To Len(aCompViag[2])
				If Len(aRetRbq) == 0
					DF7->(DbSetOrder(3)) //-- DF7_FILIAL+DF7_FILDTR+DF7_VGEDTR+DF7_CODVEI
					If DF7->(MsSeek(xFilial('DF7') + M->(DTR_FILORI + DTR_VIAGEM) + aCompViag[2,nCntFor,nPosCodVei] ))
						For nCntFor1 := 1 To DF7->(FCount())
							AAdd( aRetRbq, { DF7->(FieldName(nCntFor1)), DF7->&(DF7->(FieldName(nCntFor1))) } )
						Next
					EndIf
				EndIf

				If Len(aRetRbq) > 0
					aRetRbq[ aScan(aRetRbq, {|x| x[1] == 'DF7_FILDTR'}), 2] := M->DTR_FILORI
					aRetRbq[ aScan(aRetRbq, {|x| x[1] == 'DF7_VGEDTR'}), 2] := M->DTR_VIAGEM
					If nOpcx == 4
						DF7->(DbSetOrder(3))
						If !DF7->(MsSeek(xFilial('DF7') + M->(DTR_FILORI+DTR_VIAGEM)))
							nOpcDF7 := 3
						EndIf
					EndIf
					TMSAF15Grv( nOpcDF7, aRetRbq )
				EndIf
			Next
		EndIf

		//---- Atualiza dados da Viagem Modelo 3
		If lRet .And. lViagem3 .And. FindFunction('TmsAjuMod3')
			TmsAjuMod3(M->DTQ_FILORI,M->DTQ_VIAGEM,nOpcx,.T.)
		EndIf

		EvalTrigger()
	End Transaction

	If lRet .And.  nOpcx == 3  .And. IsInCallStack("TMSF76EXE") .And. Len(aContrItC) > 0 	                   
   
		//Verifica se a negociacao contratual indica rateio.
		cRatItC := Iif(!Empty(aContrItC[01,48]), aContrItC[01,48],  aContrItC[01,53,01,05] )
	
		//Verifica se a negociacao contratual indica rateio.
		If cRatItC == '1'
			nPosTF    := Ascan(aFreVgeItC, {|x| x[3] == 'TF' })  

			If  nPosTF <> 0 .And. Empty( aFreVgeItC[ nPosTF, 2 ] )
				Aviso("Atenção", "Valor do frete zerado.", {"OK"},1)
				lRet := .F.
			Else					   
				//Valor do frete a receber da viagem.
		 		nVlVgeSImp +=aFreVgeItC[nPosTF,02]
			
				//Valor dos Impostos do frete da viagem.
		   		nVlImpVge  +=aFreVgeItC[nPosTF,05] 
					
		   		//Valor total do frete da viagem, quando definido na TES soma o valor da viagem com o valor dos impostoss.
		   		nVlVgeCImp +=aFreVgeItC[nPosTF,06]     
			   	 
		   		RecLock( 'DTQ', .F. )
				DTQ->DTQ_KMVGE  := M->DTQ_KMVGE
				DTQ->(MsUnlock()) 
			
				Aviso("Atencao","Valorização da viagem de Entrega " + AllTrim(M->DTQ_FILORI)+"-"+Alltrim(M->DTQ_VIAGEM)+;
					 		 " e rateio dos documentos foram realizados com sucesso.   ",{"OK"},1)  
			EndIf		 		 
		EndIf	    
	EndIf		
	
	If lRet 
		If lAltRota
			Aviso(STR0101,STR0115,{STR0103}) //Atencao ### A rota da viagem foi alterada, é necessário confirmar o complemento de viagem para que o valor de frete e pedagio sejam recalculados! ### OK					
	 	ElseIf lAltTipOpVg
			Aviso(STR0101,STR0120,{STR0103}) //Atencao ### O Tipo da negociacao da viagem foi alterado, é necessário confirmar o complemento de viagem para que o valor de frete sejam recalculados!'
		EndIf 
		If lAltRota .Or. lAltTipOpVg
			TmsA240Mnt( , , 4, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,Iif(nOpcx==3 .And. Len(aCompViag)>0,aCompViag,''),M->DTQ_ROTA,DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA,@M->DTQ_OBS,,,.T.,,,aDocto,aPosicao,.T.,,,,lAltRota,,,lAltTipOpVg)  
		EndIF
	EndIf

	//-- Carregamento automatico
	If lRet .And. (lCarreg .Or. lAltFilDca)
		lRet := TmsA140Crr( nOpcx , lAltRota)
	EndIf

	//Chama Rotina para Gerar Manifesto e Contrato de Carreteiro somente para viagem modelo I      
	If lRet
		If ( nOpcx == 3 .Or. nOpcx == 4 )
			If Substr(Funname(),1,7) != "TMSA144"
				If (( cSerTms == StrZero(2,Len(DC5->DC5_SERTMS))) .Or. ( cSerTms == StrZero(3,Len(DC5->DC5_SERTMS))))//Transportes ou Entrega  
					If nCarreg > 1  //Modo de Carregamento nao manual
						Tmsa144GMC(lVgeExpr)
					EndIf
				EndIf
			EndIf
			If lValBlq
				// Exclui Registro De Bloqueio Por Incompatibilidade De Produtos.
				If lTmsa029 
					If Tmsa029Use("TMSA140")
						// Caso Existam Bloqueios, Limpa Referencia
						Tmsa029Blq( 5  ,;				// 01 - nOpc
									'TMSA140',;		// 02 - Rotina
									Nil,;				// 03 - Tipo Bloq (Nil Apaga Todos Codigos de Bloqueio da Viagem
									M->DTQ_FILORI,;	// 04 - Filial Origem
									'DUC',;			// 05 - Tabela Referencial
									'1',;				// 06 - Indice Da Tabela
									xFilial('DUC') + M->DTQ_FILORI + M->DTQ_VIAGEM,;	// 07 - Chave Indexação
									"",;				// 08 - Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
									"",;				// 09 - Detalhes Adicionais a Respeito Do Bloqueio
									nOpcx)				// 10 - Opcao da Rotina
					EndIf
					
					If Tmsa029Use("TMSA310")
						Tmsa029Blq( 5  ,;				// 01 - nOpc
									'TMSA310',;		// 02 - Rotina
									Nil,;				// 03 - Tipo Bloq (Nil Apaga Todos Codigos de Bloqueio da Viagem
									M->DTQ_FILORI,;	// 04 - Filial Origem
									'DTQ',;			// 05 - Tabela Referencial
									'1',;				// 06 - Indice Da Tabela
									xFilial('DTQ') + M->DTQ_FILORI + M->DTQ_VIAGEM,;	// 07 - Chave Indexação
									"",;				// 08 - Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
									"",;				// 09 - Detalhes Adicionais a Respeito Do Bloqueio
									nOpcx)				// 10 - Opcao da Rotina
									
					EndIf			
				EndIf
				//-- Bloqueio de viagem
				TmsBlqViag( M->DTQ_FILORI, M->DTQ_VIAGEM)
			EndIf
		Endif
		//-- Ponto de Entrada chamado apos a inclusao, alteracao ou exclusao da Viagem de Transferencia
		If lTM140GRV
			ExecBlock('TM140GRV',.F.,.F.,{nOpcx})
		EndIf
	EndIf
EndIf

RestArea( aAreaDUD )
RestArea( aAreaAnt )
RestArea( aAreaDTQ )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA140Del³ Autor ³ Alex Egydio           ³ Data ³31.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apaga o numero da viagem, dos documentos.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA140Del()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial do Docto                                    ³±±
±±³          ³ ExpC2 = Nr.Docto                                           ³±±
±±³          ³ ExpC3 = Serie                                              ³±±
±±³          ³ ExpL1 = .T. = Docto associado a uma viagem                 ³±±
±±³          ³ ExpC4 = Numero do Unitizador                               ³±±
±±³          ³ ExpC5 = Codigo Analitico do Unitizador                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA140Del( cFilDoc, cDoc, cSerie, lViagem, cUnitiz, CCodAna )

Local aAreaAnt	:= GetArea()
Local aAreaDUD	:= DUD->(GetArea())
Local aAreaDT5 := DT5->(GetArea())
Local aAreaDT6 := DT6->(GetArea())
Local lCarMult := SuperGetMv('MV_TMSCMUL',,.F.) .And. DUD->(FieldPos('DUD_CARMUL')) > 0
Local lTMS3GFE := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)

//-- Se desmarcou um documento, que estava vinculado a uma viagem, apagar o campo
//-- codigo da viagens deste documento.
If	lViagem
	DUD->(DbSetOrder(1)) //DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM
	If	DUD->(dbSeek(xFilial('DUD')+cFilDoc+cDoc+cSerie+M->DTQ_FILORI+M->DTQ_VIAGEM))
		RecLock('DUD',.F.)
		DUD->DUD_SEQUEN := Space(Len(DUD->DUD_SEQUEN))
		DUD->DUD_VIAGEM := Space(Len(DUD->DUD_VIAGEM))
		DUD->DUD_STATUS := StrZero(1,Len(DUD->DUD_STATUS))		//-- Em aberto
		DUD->DUD_STROTA := Space(Len(DUD->DUD_STROTA))
		DUD->DUD_FILDCA := Space(Len(DUD->DUD_FILDCA))
		DUD->DUD_GERROM := StrZero(2,Len(DUD->DUD_GERROM))
		If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) .And. DUD->DUD_FILDOC == cFilAnt  //-- Transporte
			DUD->DUD_FILORI := DUD->DUD_FILDOC // Para os casos de documentos de outra filial 
		EndIf
		If lCarMult .And. DUD->DUD_CARMUL == '1' //-- Sim
			DT6->(DbSetOrder(1))
			If DT6->(dbSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie))
				DUD->DUD_SERTMS := DT6->DT6_SERTMS
				DUD->DUD_TIPTRA := DT6->DT6_TIPTRA
				DUD->DUD_CARMUL := '2' //-- Nao
			EndIf
		EndIf
		If lTMS3GFE 
			DUD->DUD_UFORI  := Space(Len(DUD->DUD_UFORI))
			DUD->DUD_CDMUNO := Space(Len(DUD->DUD_CDMUNO))
			DUD->DUD_CEPORI := Space(Len(DUD->DUD_CEPORI))
			DUD->DUD_UFDES  := Space(Len(DUD->DUD_UFDES))
			DUD->DUD_CDMUND := Space(Len(DUD->DUD_CDMUND))
			DUD->DUD_CEPDES := Space(Len(DUD->DUD_CEPDES))
			DUD->DUD_TIPVEI := Space(Len(DUD->DUD_TIPVEI))
			DUD->DUD_CDTPOP := Space(Len(DUD->DUD_CDTPOP))
			DUD->DUD_CDCLFR := Space(Len(DUD->DUD_CDCLFR))
			DUD->DUD_CHVEXT := Space(Len(DUD->DUD_CHVEXT))
		EndIf
		MsUnLock()
		//-- Atualiza status da solitacao da coleta
		If lColeta
			DT5->(DbSetOrder( 4 ))
			If DT5->(MsSeek(xFilial('DT5')+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE))
				RecLock('DT5',.F.)
				DT5->DT5_STATUS := StrZero(1,Len(DT5->DT5_STATUS)) //-- Em Aberto
				MsUnLock()
			EndIf
		EndIf
	EndIf
	//--Apaga o número da viagem do Unitizador.
		Dlga010Sta(5, cUnitiz, cCodAna, , ,  ,M->DTQ_FILORI, M->DTQ_VIAGEM, ,.T.)
EndIf

RestArea( aAreaDUD )
RestArea( aAreaDT5 )
RestArea( aAreaDT6 )
RestArea( aAreaAnt )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA140Crr³ Autor ³ Alex Egydio           ³ Data ³06.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua o carregamento automatico, se nCarreg igual a 2.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA140Crr( nOpcx , lAltRota)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA140Crr( nOpcx , lAltRota)

Local aAreaAnt		:= GetArea()
Local aAreaSF4		:= SF4->(GetArea()) 
Local aAreaDUD		:= DUD->(GetArea())
Local aNoFields	    := {}
Local aYesFields	:= {}
Local aVisual		:= {}
Local aFilDca		:= {}
Local aFiliais		:= {}
Local nDocto		:= 0
Local nItem			:= 0
Local nCntFor       := 0
Local nSeek			:= 0
Local cCampo        := ''
Local cFilNome		:= ''
Local cFilDca		:= ''
Local cFilDes		:= ''
Local cFilDoc		:= ''
Local cDocto		:= ''
Local cSerie		:= ''
Local lAlianca      := TmsAlianca() //-- Verifica se utiliza Alianca
Local lRet          := .T.
Local aFilDesDca    := {}  
Local lMostraTela	:= .T.
Local lAtuDTADCA	:= .F.
Local nPos          := 0
Local aAreaSM0 	:= {}

Private aHeader		:= {}
Private aCols		:= {}    

Default lAltRota 	:= .F.
                        
If ! TmsA210Srv(M->DTQ_SERTMS)
	Return( .F. )
EndIf
aAreaSM0 := SM0->(GetArea())
//-- Retorna as filiais de descarga da rota
aFilDca := TMSRegDca(M->DTQ_ROTA,,.F.)
If	! Empty(aFilDca)
	If	Len(aFilDca)>1
		aFiliais := {}
		For nCntFor := 1 To Len(aFilDca)
			cFilNome := Posicione('SM0',1,cEmpAnt + aFilDca[nCntFor,3],'M0_FILIAL')
	    	AAdd(aFiliais,{aFilDca[nCntFor,3],cFilNome})
		Next
	Else
    	cFilDca := aFilDca[1,3]
	EndIf	
EndIf
RestArea(aAreaSM0)
aFilDca := {}

//--Retorna as filiais de destino da rota
DUN->( DbSetOrder(1) ) //--DUN_FILIAL+DUN_ROTEIR+DUN_CDRDES
If DUN->( DbSeek( xFilial('DUN') + M->DTQ_ROTA ) )
	While !DUN->( Eof() ) .And. DUN->( DUN_FILIAL + DUN_ROTEIR ) == xFilial('DUN') + M->DTQ_ROTA
		AAdd( aFilDesDca, { DUN->DUN_FILDES, DUN->DUN_FILDCA } )
		DUN->( DbSkip() )
	End
EndIf

//-- Cria variaveis de memoria para operacoes de carregamento
RegToMemory('DTA',.T.)
M->DTA_FILIAL	:= xFilial('DTA')
M->DTA_FILORI	:= M->DTQ_FILORI
M->DTA_VIAGEM	:= M->DTQ_VIAGEM

AAdd( aVisual ,'DTA_FILORI' )
AAdd( aVisual ,'DTA_VIAGEM' )

AAdd( aNoFields ,'DTA_FILORI' )
AAdd( aNoFields ,'DTA_VIAGEM' )

M->DTA_CODVEI := Posicione('DTR',1,xFilial('DTR')+M->DTQ_FILORI+M->DTQ_VIAGEM,'DTR_CODVEI')
If Empty(M->DTA_CODVEI)
	M->DTA_CODVEI := Posicione('DTR',1,M->DTQ_FILORI+M->DTQ_FILORI+M->DTQ_VIAGEM,'DTR_CODVEI')
EndIf

AAdd( aVisual   ,'DTA_CODVEI' )
AAdd( aNoFields ,'DTA_CODVEI' )

AAdd( aNoFields ,"DTA_FILDPC" )

If !lLocaliz  
	AAdd( aNoFields ,'DTA_LOCAL'  )
	AAdd( aNoFields ,'DTA_LOCALI' )
	AAdd( aNoFields ,'DTA_UNITIZ'  )
	AAdd( aNoFields ,'DTA_CODANA' )	
EndIf
//-- Monta o aHeader e aCols
TMSFillGetDados( 3, 'DTA', 2, xFilial('DTA') + M->DTQ_FILORI + M->DTQ_VIAGEM, {|| ''}, {|| .T. }, aNoFields, aYesFields )

aCols := {}
DTA->( DbSetOrder(1) ) 
For nDocto := 1 To Len( aDocto )

	If !lAltRota .And. DTA->(MsSeek(xFilial("DTA")+aDocto[nDocto,CTFILDOC]+aDocto[nDocto,CTDOCTO]+aDocto[nDocto,CTSERIE]+DTQ->(DTQ_FILORI+DTQ_VIAGEM)))
    	Loop
	ElseIf lAltRota .And. DTA->(MsSeek(xFilial("DTA")+aDocto[nDocto,CTFILDOC]+aDocto[nDocto,CTDOCTO]+aDocto[nDocto,CTSERIE]+DTQ->(DTQ_FILORI+DTQ_VIAGEM)))
		RecLock('DTA',.F.)
		DTA->(DbDelete())
		MsUnLock()		
	EndIf

	//-- Verifica se marcou um documento
	If	aDocto[ nDocto, CTMARCA ] .And. (aDocto[nDocto,CTSTATUS] == "1" .Or. aDocto[nDocto,CTSTATUS] == "3")
		cFilDoc := aDocto[ nDocto, CTFILDOC ]
		cDocto  := aDocto[ nDocto, CTDOCTO ]
		cSerie  := aDocto[ nDocto, CTSERIE ]
		//-- Cria uma linha no aCols
		AAdd( aCols, Array( Len( aHeader ) + 1 ) )
		nItem := Len( aCols )
			
		For nCntFor := 1 To Len( aHeader )       
			cCampo := aHeader[nCntFor,2]
			GdFieldPut( cCampo, CriaVar( cCampo ), nItem )
		Next			
		If lLocaliz .And. !lColeta
			GDFieldPut('DTA_LOCAL' , aDocto[ nDocto, CTARMAZE ], nItem )
			GDFieldPut('DTA_LOCALI', aDocto[ nDocto, CTLOCALI ], nItem )
			GDFieldPut('DTA_UNITIZ', aDocto[ nDocto, CTUNITIZ ], nItem )
			GDFieldPut('DTA_CODANA', aDocto[ nDocto, CTCODANA ], nItem )			
		EndIf
		GDFieldPut( 'DTA_FILDOC' ,cFilDoc ,nItem )
		GDFieldPut( 'DTA_DOC'    ,cDocto  ,nItem )
		GDFieldPut( 'DTA_SERIE'  ,cSerie  ,nItem )
		GDFieldPut( 'DTA_TIPCAR' ,StrZero(2,Len(DTA->DTA_TIPCAR)), nItem )
		GDFieldPut( 'DTA_QTDVOL' ,aDocto[ nDocto, CTQTDVOL ], nItem )
		GDFieldPut( 'DTA_PESO'   ,aDocto[ nDocto, CTPLIQUI ], nItem )
		GDFieldPut( 'DTA_FILDCA' ,cFilDca ,nItem )
	
		If lAlianca
			GDFieldPut('DTA_FILDPC', cFilDca, nItem )
		EndIf
	
		aCols[ nItem, Len( aHeader ) + 1 ] := .F.
				
		If !lAltRota
			DbSelectArea("DUD")
			DbSetOrder(1)                            
			DUD->(MsSeek(xFilial('DUD') + cFilDoc + cDocto + cSerie + M->DTQ_FILORI + M->DTQ_VIAGEM))
			If !Empty(DUD_FILDCA)
				lMostraTela := .F. 
				lAtuDTADCA	:= .T.
			Else
				lMostraTela := .T. 
			EndIf			
		EndIf
                           
      	//-- Se a filial de Destino do documento fizer parte de uma das filiais de descarga da rota, nao 
      	//-- exibir o documento para escolha da filial de descarga, pois a filial de Descarga sera' a propria
      	//-- filial de destino                                                          
		DT6->(DbSetOrder(1))
		If	DT6->(MsSeek(xFilial('DT6') + cFilDoc + cDocto + cSerie)) 

			If ( nSeek := AScan( aFilDesDca, {|x| x[1] == DT6->DT6_FILDES } ) ) > 0

				GDFieldPut('DTA_FILDCA', aFilDesDca[nSeek,2] , nItem )		
				If lAlianca
					GDFieldPut('DTA_FILDPC', aFilDesDca[nSeek,2] , nItem )
				EndIf
	 			Loop

    		EndIf

      	EndIf  
      	
      	If nSeek <= 0 .And. lAtuDTADCA
			GDFieldPut('DTA_FILDCA', DUD->DUD_FILDCA , nItem )
      	EndIf     
		
		//-- Guardar em aFilDca, documentos por filial de destino
		If	Empty(cFilDca) .And. lMostraTela
			nSeek := AScan( aFilDesDca, {|x| x[1] == DT6->DT6_FILDES } )
			If	nSeek <= 0
				cFilDes := DT6->DT6_FILDES
				
				nSeek2 := AScan( aFilDca, {|x| x[1] == DT6->DT6_FILDES } )
				
				If nSeek2 <= 0
					aAreaSM0 := SM0->(GetArea())
					AAdd( aFilDca, { cFilDes, Posicione('SM0',1,cEmpAnt + cFilDes,'M0_FILIAL'), Space(Len(DTA->DTA_FILDCA)), Space(15), 0, {} } )
					RestArea(aAreaSM0)
					
					nSeek := Len(aFilDca)
				Else
					nSeek := nSeek2
				EndIf
			EndIf
			
			nPos := AScan( aFilDca[nSeek,6] , {|x| x == cFilDoc + cDocto + cSerie } )
			
			If nPos <= 0 
				aFilDca[nSeek,5] += 1
				AAdd(aFilDca[nSeek,6],cFilDoc + cDocto + cSerie)
			EndIf

		EndIf
		lMostraTela := .T.
		
	EndIf
Next
//-- Selecionar as filiais de descarga
If !Empty(aFilDca) .And. !Empty(aFiliais)
	TmsA140Dca(aFilDca,aFiliais,lAlianca)
EndIf
//-- Gravar o carregamento
If !Empty(aCols)
	Processa({|| lRet := TmsA210Grv( aVisual, 3, lLocaliz,.F.)}, STR0038) //"Aguarde..."
EndIf

RestArea( aAreaDUD )
RestArea( aAreaSF4 )
RestArea( aAreaAnt )

Return( lRet )

//- Exernalizando a rotina de gravação do carregamento da viagem
Function Tmsa140Crg(nOpcx,lAltRota)
Return TmsA140Crr(nOpcx,LAltRota)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140Doc³ Autor ³ Alex Egydio           ³ Data ³15.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa o vetor aDocto com os documentos atendidos pela ³±±
±±³          ³ rota selecionada                                           ³±±
±±³          ³ O vetor aDocto eh utilizado pelo listbox de documentos     ³±±
±±³          ³ O vetor aAllDocto contem todos os documentos atendidos por ³±±
±±³          ³ todas as rotas                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao selecionada                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140Doc(nOpcx)


//-- Zera o vetor aDocto
If	Empty( aDocto )
	TmsA140ZCt()
EndIf

If nOpcx == 3
	ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[ CTARMAZE ] + x[ CTLOCALI ] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] <  y[CTSEQUEN] + y[ CTARMAZE ] + y[ CTLOCALI ] + y[ CTFILDOC ] + y[ CTDOCTO ] + y[ CTSERIE ] })
Else
	ASort( aDocto,,,{|x,y| x[CTMARCA] >  y[CTMARCA ] })
EndIf

If !IsInCallStack("TMSF76Via")
	If ValType(oLbxDocto) == 'O'
		oLbxDocto:SetArray( aDocto )
	
		//-- Monta o bLine do listbox
		TMSA140bLi( 2 )
		
		oLbxDocto:Refresh()
	EndIf
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140Qry³ Autor ³ Alex Egydio           ³ Data ³15.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Select de documentos e rotas para viagem normal.           ³±±
±±³          ³ Inicializa o vetor aRota utilizado no listbox de rotas.    ³±±
±±³          ³ Somente rotas ativas que tenham documentos no armazem.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao selecionada                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140Qry(nOpcx,lSemViag,lCallAltera)

Local aAreaAnt   := GetArea()
Local aAreaDUD   := DUD->(GetArea())
Local aAreaDA8   := DA8->(GetArea())
Local cAliasTop  := GetNextAlias()
Local cAliasTop1 := ''
Local cQuery	 := ''
Local cStatus    := StrZero(1,Len(DUD->DUD_STATUS))
Local lRet		 := .T.
Local nPos       := 0

Local lTMSDCol := SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.

DEFAULT lSemViag    := .F.
DEFAULT lCallAltera := .F.    

If nOpcx <> 3
	cQuery := "SELECT COUNT(*) DUD_COUNT FROM "
	cQuery += RetSqlName("DUD")+" DUD "
	cQuery += " WHERE DUD_FILIAL    = '"+xFilial("DUD")+"'"
	cQuery += "   AND DUD_FILORI    = '"+M->DTQ_FILORI+"'"
	cQuery += "   AND DUD_VIAGEM    = '"+M->DTQ_VIAGEM+"'"
	cQuery += "   AND DUD.D_E_L_E_T_    = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)
	If (cAliasTop)->DUD_COUNT > 0 //Eh permitido gerar viagem sem documento selecionado, portanto a query deve ser sem o dud
		(cAliasTop)->( DbCloseArea() )
		cQuery := "SELECT DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(DA8_TIPROT) TIPROT , "
		cQuery += "     SUM(DT6_QTDVOL) QTDVOL, SUM(DT6_PESO) PESO    , SUM(DT6_PESOM3) PESOM3, SUM(DT6_VALMER) VALMER FROM "
		cQuery += RetSqlName("DA8")+" DA8 "
		cQuery += " JOIN " + RetSqlName("DUD")+" DUD ON "
		cQuery += "   DUD_FILIAL        = '"+xFilial("DUD")+"'"
		cQuery += "   AND DUD_FILORI    = '"+M->DTQ_FILORI+"'"
		cQuery += "   AND DUD_VIAGEM    = '"+M->DTQ_VIAGEM+"'"
		cQuery += "   AND DUD.D_E_L_E_T_ = ' '"
		cQuery += " JOIN " + RetSqlName("DT6")+" DT6 ON "
		cQuery += "   DT6_FILIAL        = '"+xFilial("DT6")+"'"
		cQuery += "   AND DT6_FILDOC    = DUD_FILDOC"
		cQuery += "   AND DT6_DOC       = DUD_DOC"
		cQuery += "   AND DT6_SERIE     = DUD_SERIE"
		cQuery += "   AND DT6.D_E_L_E_T_ = ' '"
		cQuery += " WHERE DA8_FILIAL    = '"+xFilial("DA8")+"'"
		cQuery += "   AND DA8_COD       = '"+M->DTQ_ROTA+"'"
		cQuery += "   AND DA8.D_E_L_E_T_ = ' '"
	Else
		(cAliasTop)->( DbCloseArea() )
		cQuery := "SELECT DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(DA8_TIPROT) TIPROT , "
		cQuery += "    0 QTDVOL, 0 PESO    , 0 PESOM3, 0 VALMER FROM "
		cQuery += RetSqlName("DA8")+" DA8 "
		cQuery += " WHERE "
		cQuery += "   DA8_FILIAL  = '"+xFilial("DA8")+"'"
		cQuery += "   AND DA8_COD = '"+M->DTQ_ROTA+"'"
		cQuery += "   AND DA8.D_E_L_E_T_ = ' '"
	EndIf
	cQuery += " GROUP BY DA8_COD"
	cQuery := ChangeQuery(cQuery)
	cAliasTop := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)
	If (cAliasTop)->(!Eof())
		AAdd(aRota,{(Iif(nOpcx==3,.F., (cAliasTop)->DA8_COD == M->DTQ_ROTA ) ),;
							(cAliasTop)->DA8_COD,;
							(cAliasTop)->DA8_DESC,;
							Padr(Tabela('M3',(cAliasTop)->TIPROT,.F.),30),;
							(cAliasTop)->QTDVOL  ,;
							(cAliasTop)->PESO    ,;
							(cAliasTop)->PESOM3  ,;
							(cAliasTop)->VALMER  ,.F., {'******'} })
	EndIf
	(cAliasTop)->(DbCloseArea())
EndIf

If nOpcx == 3 .Or. nOpcx == 4
	cQuery := " SELECT DUD_CDRCAL, Sum(DT6_QTDVOL) QTDVOL, Sum(DT6_PESO) PESO, "
	cQuery += "        Sum(DT6_PESOM3) PESOM3, Sum(DT6_VALMER) VALMER "
	cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
	cQuery += "   JOIN " + RetSqlName("DT6") + " DT6 "
	cQuery += "     ON  DT6_FILIAL    = '"+xFilial("DT6")+"'"
	cQuery += "     AND DT6_FILDOC    = DUD_FILDOC"
	cQuery += "     AND DT6_DOC       = DUD_DOC"
	cQuery += "     AND DT6_SERIE     = DUD_SERIE"
	cQuery += "     AND DT6_BLQDOC    <> '1'"
	cQuery += "     AND DT6.D_E_L_E_T_    = ' '"
	cQuery += "   WHERE DUD_FILIAL    = '"+xFilial("DUD")+"'"
	If !lTMSDCol
		cQuery += "     AND DUD_FILORI    = '"+cFilAnt+"'"
	EndIf
	cQuery += "     AND DUD_SERTMS    = '"+cSerTms+"'"
	cQuery += "     AND DUD_TIPTRA    = '"+cTipTra+"'"
	cQuery += "     AND DUD_STATUS    = '"+cStatus+"'"
	cQuery += "     AND DUD_VIAGEM    = ' '"  
	cQuery += "     AND DUD_CDRCAL BETWEEN '"+cCdrDesDe+"' AND '"+cCdrDesAte+"'"
	cQuery += "     AND DUD.D_E_L_E_T_    = ' '"
	cQuery += "     AND EXISTS ( "
	cQuery += "           SELECT 1 FROM " + RetSqlName("DVM")
	cQuery += "             WHERE DVM_FILIAL = '" + xFilial("DVM") + "'"
	If ( nOpcx == 3 .Or. ( nOpcx == 4 .And. M->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS))) )
		cQuery += "     			  AND DVM_ROTEIR BETWEEN '"+cRotaDe+"' AND '"+cRotaAte+"'"
	Else
		cQuery += "     			  AND DVM_ROTEIR = '" + M->DTQ_ROTA + "' "
	EndIf
	cQuery += "               AND DVM_CDRDES = DUD_CDRCAL "
	cQuery += "               AND D_E_L_E_T_ = ' ' )"
	If !Empty(cGrpProd) .Or. lLocaliz
		cQuery += "     AND EXISTS ( "
		cQuery += "        SELECT 1 "
		cQuery += "   			FROM " + RetSqlName("DTC") + " DTC "
		If lLocaliz .And. lDoctoEnd
			cQuery += "   		JOIN " + RetSqlName("DUH") + " DUH "
		Else
			cQuery += "   		LEFT JOIN " + RetSqlName("DUH") + " DUH "
		EndIf
		cQuery += "   		  ON DUH_FILIAL = '" + xFilial("DUH") + "'"
		cQuery += "   		  AND DUH_FILORI = '" + cFilAnt + "'"
		cQuery += "   		  AND DUH_NUMNFC = DTC_NUMNFC
		cQuery += "   		  AND DUH_SERNFC = DTC_SERNFC
		cQuery += "   		  AND DUH_CLIREM = DTC_CLIREM
		cQuery += "   		  AND DUH_LOJREM = DTC_LOJREM
		cQuery += "   		  AND DUH_LOCALI <> ' '
		cQuery += "   		  AND DUH.D_E_L_E_T_ = ' ' 
		If !Empty(cGrpProd) //-- Filtra por Grupo de Produto
			cQuery += " JOIN " + RetSqlName("SB1")+" SB1 "
			cQuery += "   ON B1_FILIAL = '" + xFilial("SB1") + "'"
			cQuery += "  AND B1_COD    = DTC_CODPRO"
		EndIf
		cQuery += " WHERE DTC_FILIAL = '" + xFilial("DTC") + "'"
		cQuery += "   AND DTC_FILDOC = DT6_FILDOC "
	   	cQuery += "   AND DTC_DOC    = DT6_DOC "
	   	cQuery += "   AND DTC_SERIE  = DT6_SERIE "
	   	cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
		//-- Filtra por Grupo de Produto
		If !Empty(cGrpProd)
			cQuery += " AND B1_GRUPO IN (" + cGrpProd + ")"
			cQuery += "   AND SB1.D_E_L_E_T_    = ' '"
		EndIf
	   cQuery += " ) "
	EndIf
	cQuery += " GROUP BY DUD_CDRCAL "
	cQuery := ChangeQuery(cQuery)
	cAliasTop:= GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)
	
	TCSetField(cAliasTop,"QTDVOL","N",TamSx3("DT6_QTDVOL")[1],TamSx3("DT6_QTDVOL")[2])
	TCSetField(cAliasTop,"PESO"  ,"N",TamSx3("DT6_PESO"  )[1],TamSx3("DT6_PESO"  )[2])
	TCSetField(cAliasTop,"PESOM3","N",TamSx3("DT6_PESOM3")[1],TamSx3("DT6_PESOM3")[2])
	TCSetField(cAliasTop,"VALMER","N",TamSx3("DT6_VALMER")[1],TamSx3("DT6_VALMER")[2])
	
	While (cAliasTop)->(!Eof())
		cQuery := " SELECT DA8_COD, DA8_DESC, DA8_TIPROT "
		cQuery += "   FROM " + RetSqlName("DVM") + " DVM "
		cQuery += "   JOIN " + RetSqlName("DA8") + " DA8 "
		cQuery += "     ON  DA8_FILIAL = '"+xFilial("DA8")+"'"
		cQuery += "     AND DA8_COD    = DVM_ROTEIR "
		cQuery += "     AND DA8_SERTMS = '" + cSerTms + "'"
		cQuery += "     AND DA8_TIPTRA = '" + cTipTra + "'"
		If ( nOpcx == 3 .Or. ( nOpcx == 4 .And. M->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS))) )		
			cQuery += "     AND DA8_CDRORI = '" + _cCdrOri + "'"
		EndIf
		cQuery += "     AND DA8_ATIVO  = '1' "
		cQuery += "     AND DA8.D_E_L_E_T_ = ' ' "
		cQuery += "   WHERE DVM_FILIAL  = '"+xFilial("DVM")+"'"
		cQuery += "     AND DVM_CDRDES = '" + (cAliasTop)->DUD_CDRCAL + "' "
		If ( nOpcx == 3 .Or. ( nOpcx == 4 .And. M->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS))) )
			cQuery += "  AND DVM_ROTEIR BETWEEN '"+cRotaDe+"' AND '"+cRotaAte+"'"
		Else
			cQuery += "  AND DVM_ROTEIR = '" + M->DTQ_ROTA + "' "
		EndIf
		cQuery += "     AND DVM.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		cAliasTop1 := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop1,.T.,.T.)
		While (cAliasTop1)->(!Eof())
			If	(nPos:= TmsA140ChkRot('2',(cAliasTop1)->DA8_COD)) > 0
				aRota[nPos,5] += (cAliasTop)->QTDVOL
				aRota[nPos,6] += (cAliasTop)->PESO
				aRota[nPos,7] += (cAliasTop)->PESOM3
				aRota[nPos,8] += (cAliasTop)->VALMER
				AAdd( aRota[nPos,10], (cAliasTop)->DUD_CDRCAL )
				(cAliasTop1)->(dbSkip())
				Loop
			EndIf
			AAdd(aRota,{(Iif(nOpcx==3,.F., (cAliasTop1)->DA8_COD == M->DTQ_ROTA ) ),;
								(cAliasTop1)->DA8_COD,;
								(cAliasTop1)->DA8_DESC,;
								Padr(Tabela('M3',(cAliasTop1)->DA8_TIPROT,.F.),30),;
								(cAliasTop)->QTDVOL  ,;
								(cAliasTop)->PESO    ,;
								(cAliasTop)->PESOM3  ,;
								(cAliasTop)->VALMER  ,;
								.F. ,;
								 { (cAliasTop)->DUD_CDRCAL } })
			(cAliasTop1)->(DbSkip())
		EndDo
		(cAliasTop1)->(DbCloseArea())
		(cAliasTop)->(DbSkip())
	EndDo
	(cAliasTop)->(DbCloseArea())

	//-- Apresenta todas as rotas
	If lAllRota
		cQuery := " SELECT DA8_COD, DA8_DESC, DA8_TIPROT "
		cQuery += "   FROM " + RetSqlName("DA8") + " DA8 "
		cQuery += "   WHERE DA8_FILIAL = '"+xFilial("DA8")+"'"
		cQuery += "     AND DA8_SERTMS = '" + cSerTms + "'"
		cQuery += "     AND DA8_TIPTRA = '" + cTipTra + "'"
		If ( nOpcx == 3 .Or. ( nOpcx == 4 .And. M->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS))) )		
			cQuery += "     AND DA8_CDRORI = '" + _cCdrOri + "'"
		EndIf
		cQuery += "     AND DA8_ATIVO  = '1' "
		cQuery += "     AND DA8.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		cAliasTop1 := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop1,.T.,.T.)
		While (cAliasTop1)->(!Eof())
			If	(nPos:= TmsA140ChkRot('2',(cAliasTop1)->DA8_COD)) == 0
				AAdd(aRota,{(Iif(nOpcx==3,.F., (cAliasTop1)->DA8_COD == M->DTQ_ROTA ) ),;
									(cAliasTop1)->DA8_COD,;
									(cAliasTop1)->DA8_DESC,;
									Padr(Tabela('M3',(cAliasTop1)->DA8_TIPROT,.F.),30),;
									0  ,;
									0  ,;
									0  ,;
									0  ,;
									.F. ,;
									 { ' ' } })
			EndIf
			(cAliasTop1)->(DbSkip())
		EndDo
		(cAliasTop1)->(DbCloseArea())
	EndIf

EndIf

If	!lSemViag .And. Empty(aRota)    
	//-- Apresentou esta mensagem pq a base estava com os seguintes problemas;
	//-- 1. Nao encontrou DVM_CDRORI para a regiao da rota(DUN_CDRDES) da viagem
	//-- 2. DUD_CDRCAL em branco
	//-- 3. Nao encontrou documentos(DUD) com o nr da viagem
	//-- 4. Nao encontrou DVM_ROTEIR + DVM_CDRDES igual a DTQ_ROTA + DUD_CDRCAL
	Help(' ', 1, 'TMSA14015',,STR0037+AllTrim( TmsValField('cSerTms',.F.) )+' '+AllTrim( TmsValField('cTipTra',.F.) ),4,1)	//-- Nao ha Documentos
	lRet := .F.
EndIf

If	lRet 
	If Empty(aRota)
		AAdd(aRota,{.F., Space(Len(DA8->DA8_COD)), Space(Len(DA8->DA8_DESC)), Space(15), 0, 0, 0, 0, .F.})
	EndIf
	If	nOpcx == 3 .And. !lSemViag
		If !lCallAltera
			//-- Deixa o vetor de documentos em branco
			TmsA140ZCt(.T.)
		EndIf			
	Else
		TmsA140Adc( TmsA140ChkRot('1') ,nOpcx,"1")
		If Empty(aDocto)
			//-- Deixa o vetor de documentos em branco
			TmsA140ZCt(.T.)
		Else
	 		TmsA140Doc(nOpcx)
		EndIf			
	EndIf
EndIf

RestArea( aAreaDUD )
RestArea( aAreaDA8 )
RestArea( aAreaAnt )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140DUH³ Autor ³ Alex Egydio           ³ Data ³15.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa o vetor aEnder q contem os enderecos onde se    ³±±
±±³          ³ encontram as notas fiscais dos clientes e a qtde de volumes³±±
±±³          ³ colocada em cada endereco.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Vetor q sera preenchido com os enderecos das notas ³±±
±±³          ³ ExpC1 = Alias do DTC                                       ³±±
±±³          ³ ExpC2 = Alias do SB1                                       ³±±
±±³          ³ ExpC3 = Alias do DT6                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140DUH(aEnder,cAliasDTC,cAliasSB1,cAliasDT6)

Local cSeekDUH	:= ''

//-- Analisa o enderecamento de notas fiscais
aEnder := {}
DUH->(DbSetOrder(1))
If	lLocaliz 
	If  Localiza((cAliasDTC)->DTC_CODPRO) .And. DUH->(MsSeek(cSeekDUH := xFilial('DUH') + cFilAnt + (cAliasDTC)->DTC_NUMNFC + (cAliasDTC)->DTC_SERNFC + (cAliasDTC)->DTC_CLIREM + (cAliasDTC)->DTC_LOJREM))
		While DUH->( ! Eof() .And. DUH->DUH_FILIAL + DUH->DUH_FILORI + DUH->DUH_NUMNFC + DUH->DUH_SERNFC + DUH->DUH_CLIREM + DUH->DUH_LOJREM == cSeekDUH )
			AAdd(aEnder,{ DUH->DUH_LOCAL, DUH->DUH_LOCALI, DUH->DUH_QTDVOL, (cAliasDT6)->DT6_VOLORI, (cAliasDTC)->DTC_CLIREM, (cAliasDTC)->DTC_LOJREM, (cAliasDTC)->DTC_CLIDES, (cAliasDTC)->DTC_LOJDES })
			DUH->(DbSkip())
		EndDo
	ElseIf !lDoctoEnd
		AAdd(aEnder,{ DUH->DUH_LOCAL, DUH->DUH_LOCALI, DUH->DUH_QTDVOL, (cAliasDT6)->DT6_VOLORI, (cAliasDTC)->DTC_CLIREM, (cAliasDTC)->DTC_LOJREM, (cAliasDTC)->DTC_CLIDES, (cAliasDTC)->DTC_LOJDES })
	EndIf
Else
	AAdd(aEnder,{ ' ', ' ' ,(cAliasDT6)->DT6_QTDVOL, (cAliasDT6)->DT6_VOLORI, (cAliasDTC)->DTC_CLIREM, (cAliasDTC)->DTC_LOJREM, (cAliasDTC)->DTC_CLIDES, (cAliasDTC)->DTC_LOJDES })
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140ADc³ Autor ³ Alex Egydio           ³ Data ³15.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa o vetor aAllDocto que contem todos os documentos³±±
±±³          ³ atendidos por todas as rotas.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Vetor contendo os enderecos das notas fiscais      ³±±
±±³          ³ ExpC1 = Alias do DUD                                       ³±±
±±³          ³ ExpC2 = Alias do DUY                                       ³±±
±±³          ³ ExpC3 = Alias do DT6                                       ³±±
±±³          ³ ExpC4 = 1 Doctos da  rota                                  ³±±
±±³          ³         2 Doctos sem rota definida. Rotas variaveis        ³±±
±±³          ³         3 Doctos de outras rotas.   Rotas variaveis        ³±±
±±³          ³ ExpN1 = Opcao selecionada                                  ³±±
±±³          ³ ExpN2 = Posicao da rota selecionada no vetor aRota         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140ADc(nItRota,nOpcx,cAcao,lVgeExpr)

Local nCnt
Local aLinha	   	:= {}
Local cRota		   	:= aRota[nItRota,2]
Local nQtdVolRota  	:= aRota[nItRota,5]
Local nCntFor	   	:= 0
Local aAreaAnt	   	:= GetArea()
Local nStRota	   	:= Len(DUD->DUD_STROTA)
Local nSequen	   	:= Len(DUD->DUD_SEQUEN)
Local cQuery       	:= ""
Local cStatus      	:= StrZero(1,Len(DUD->DUD_STATUS))
Local cAliasTop    	:= GetNextAlias()
Local cCdrDes      	:= ''

Local lTMSDCol := SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.
Local lDTAOrigem 	:= DTA->(ColumnPos('DTA_ORIGEM')) > 0
Local nPosDoc		:= 0
Local aDoctoAux		:= {}

Private cAliasDoc  	:= cAliasTop

DEFAULT cAcao 		:= '2'
DEFAULT nOpcx 		:= 3
DEFAULT lVgeExpr 	:= .F.


If nOpcx == 2 .Or. nQtdVolRota > 0
	If nOpcx <> 3
		If lLocaliz
			cQuery := "SELECT DUD_FILDOC, DUD_DOC   , DUD_SERIE , DUH_LOCAL  , DUH_LOCALI, DUH_UNITIZ, DUH_CODANA, SUM(DUH_QTDVOL) DUH_QTDVOL, "
		Else
			cQuery := "SELECT DUD_FILDOC, DUD_DOC   , DUD_SERIE , "
		EndIf
		
		cQuery += "   MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_STROTA) DUD_STROTA, MIN(DUD_SEQUEN) DUD_SEQUEN, "
		cQuery += "   MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, MIN(DT6_VALMER) DT6_VALMER, "
		cQuery += "   MIN(DT6_PRZENT) DT6_PRZENT, MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DUD_CDRCAL) DUD_CDRCAL, "
		cQuery += "   MIN(DT6_CLIREM) DT6_CLIREM, MIN(DT6_LOJREM) DT6_LOJREM, MIN(DT6_CLIDES) DT6_CLIDES, "
		cQuery += "   MIN(DT6_LOJDES) DT6_LOJDES, MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DUD_FILORI) DUD_FILORI, "
		cQuery += "   MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DT6_VOLORI) DT6_VOLORI "
		If lLocaliz
			cQuery += "   ,MIN(DTC_DATENT) DTC_DATENT "
		EndIf
		cQuery += "   FROM "
		
		cQuery += RetSqlName("DUD")+" DUD, "
		cQuery += RetSqlName("DT6")+" DT6 "
	
		If lLocaliz
			cQuery += " LEFT JOIN " + RetSqlName("DTC")+" DTC ON "
			cQuery += "   DTC.DTC_FILIAL        = '"+xFilial("DTC")+"'"
			cQuery += "   AND DTC.DTC_FILDOC    = DT6_FILDOC"
			cQuery += "   AND DTC.DTC_DOC       = DT6_DOC"
			cQuery += "   AND DTC.DTC_SERIE     = DT6_SERIE"
			cQuery += "   AND DTC.D_E_L_E_T_    = ' '"
			cQuery += " LEFT JOIN " + RetSqlName("DUH")+" DUH ON "
			cQuery += "   DUH.DUH_FILIAL        = '"+xFilial("DUH")+"'"
			cQuery += "   AND DUH.DUH_FILORI    = '"+cFilAnt+"'"
			cQuery += "   AND DUH.DUH_NUMNFC    = DTC_NUMNFC"
			cQuery += "   AND DUH.DUH_SERNFC    = DTC_SERNFC"
			cQuery += "   AND DUH.DUH_CLIREM    = DTC_CLIREM"
			cQuery += "   AND DUH.DUH_LOJREM    = DTC_LOJREM"
			cQuery += "   AND DUH.DUH_LOCALI    <> ' '"
			cQuery += "   AND DUH.D_E_L_E_T_     = ' '"
		EndIf
	
		cQuery += " WHERE DUD.DUD_FILIAL    = '"+xFilial("DUD")+"'"
		cQuery += "   AND DUD.DUD_FILORI    = '"+M->DTQ_FILORI+"'"
		cQuery += "   AND DUD.DUD_VIAGEM    = '"+M->DTQ_VIAGEM+"'"
		cQuery += "   AND DUD.D_E_L_E_T_    = ' '"
	
		cQuery += "   AND DT6.DT6_FILIAL    = '"+xFilial("DT6")+"'"
		cQuery += "   AND DT6.DT6_FILDOC    = DUD_FILDOC"
		cQuery += "   AND DT6.DT6_DOC       = DUD_DOC"
		cQuery += "   AND DT6.DT6_SERIE     = DUD_SERIE"
		cQuery += "   AND DT6.D_E_L_E_T_    = ' '"
	
		If lLocaliz
			cQuery += " GROUP BY DUD_FILDOC, DUD_DOC, DUD_SERIE, DUH_LOCAL, DUH_LOCALI ,DUH_UNITIZ , DUH_CODANA "
		Else
			cQuery += " GROUP BY DUD_FILDOC, DUD_DOC, DUD_SERIE "
		EndIf
	EndIf
	If nOpcx == 3 .Or. nOpcx == 4
		For nCnt := 1 To Len(aRota[nItRota,10])
			cCdrDes += "'" + aRota[nItRota,10,nCnt] + "',"
		Next nCnt
		cCdrDes := SubStr(cCdrDes,1,Len(cCdrDes)-1)
		If nOpcx == 4
			If lLocaliz
				cQuery += " UNION ALL "
				cQuery += " SELECT DUD_FILDOC, DUD_DOC   , DUD_SERIE , DUH_LOCAL  , DUH_LOCALI, DUH_UNITIZ , DUH_CODANA ,  SUM(DUH_QTDVOL) DUH_QTDVOL, "
			Else
				cQuery += " UNION ALL "
				cQuery += " SELECT DUD_FILDOC, DUD_DOC   , DUD_SERIE , "
			EndIf
		Else
			If lLocaliz
				cQuery := " SELECT DUD_FILDOC, DUD_DOC   , DUD_SERIE , DUH_LOCAL  , DUH_LOCALI, DUH_UNITIZ , DUH_CODANA , SUM(DUH_QTDVOL) DUH_QTDVOL, "
			Else
				cQuery := " SELECT DUD_FILDOC, DUD_DOC   , DUD_SERIE , "
			EndIf
		EndIf
		cQuery += "   MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_STROTA) DUD_STROTA, MIN(DUD_SEQUEN) DUD_SEQUEN, "
		cQuery += "   MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, MIN(DT6_VALMER) DT6_VALMER, "
		cQuery += "   MIN(DT6_PRZENT) DT6_PRZENT, MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DUD_CDRCAL) DUD_CDRCAL, "
		cQuery += "   MIN(DT6_CLIREM) DT6_CLIREM, MIN(DT6_LOJREM) DT6_LOJREM, MIN(DT6_CLIDES) DT6_CLIDES, "
		cQuery += "   MIN(DT6_LOJDES) DT6_LOJDES, MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DUD_FILORI) DUD_FILORI, "
		cQuery += "   MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DT6_VOLORI) DT6_VOLORI "
		If !Empty(cGrpProd) .Or. lLocaliz
			cQuery += "   ,MIN(DTC_DATENT) DTC_DATENT "
		EndIf
		cQuery += "   FROM "
		cQuery += RetSqlName("DUD")+" DUD, "
		cQuery += RetSqlName("DT6")+" DT6 "
	
		If !Empty(cGrpProd) .Or. lLocaliz
			cQuery += " JOIN " + RetSqlName("DTC")+" DTC ON "
			cQuery += "   DTC.DTC_FILIAL        = '"+xFilial("DTC")+"'"
			cQuery += "   AND DTC.DTC_FILDOC    = DT6_FILDOC"
			cQuery += "   AND DTC.DTC_DOC       = DT6_DOC"
			cQuery += "   AND DTC.DTC_SERIE     = DT6_SERIE"
			cQuery += "   AND DTC.D_E_L_E_T_    = ' '"
			If lLocaliz
				If lDoctoEnd
					cQuery += " JOIN " + RetSqlName("DUH")+" DUH ON "
				Else
					cQuery += " LEFT JOIN " + RetSqlName("DUH")+" DUH ON "
				EndIf
				cQuery += "   DUH.DUH_FILIAL = '"+xFilial("DUH")+"'"
				cQuery += "   AND DUH.DUH_FILORI = '"+cFilAnt+"'"
				cQuery += "   AND DUH.DUH_NUMNFC = DTC_NUMNFC"
				cQuery += "   AND DUH.DUH_SERNFC = DTC_SERNFC"
				cQuery += "   AND DUH.DUH_CLIREM = DTC_CLIREM"
				cQuery += "   AND DUH.DUH_LOJREM = DTC_LOJREM"
				cQuery += "   AND DUH.DUH_LOCALI <> ' '"
				cQuery += "   AND DUH.D_E_L_E_T_ = ' '"
			EndIf
		EndIf   
		If !Empty(cGrpProd) //-- Filtra por Grupo de Produto                                                           
			cQuery += " LEFT JOIN " + RetSqlName("SB1")+" SB1 ON "
			cQuery += " SB1.B1_FILIAL   = '"+xFilial("SB1")+"'"                
			cQuery += " AND SB1.B1_COD  = DTC.DTC_CODPRO"     			
	   EndIf	
	
		cQuery += " WHERE DUD.DUD_FILIAL    = '"+xFilial("DUD")+"'"
		If !lTMSDCol
			cQuery += "   AND DUD.DUD_FILORI    = '"+cFilAnt+"'"
		EndIf
		cQuery += "   AND DUD.DUD_SERTMS    = '"+cSerTms+"'"
		cQuery += "   AND DUD.DUD_TIPTRA    = '"+cTipTra+"'"
		cQuery += "   AND DUD.DUD_STATUS    = '"+cStatus+"'"
		cQuery += "   AND DUD.DUD_VIAGEM    = ' '"
		cQuery += "	  AND DUD.DUD_CDRCAL  IN ( "+cCdrDes+" )"
		cQuery += "   AND DUD.D_E_L_E_T_    = ' '"
			
		cQuery += "   AND DT6.DT6_FILIAL    = '"+xFilial("DT6")+"'"
		cQuery += "   AND DT6.DT6_FILDOC    = DUD_FILDOC"
		cQuery += "   AND DT6.DT6_DOC       = DUD_DOC"
		cQuery += "   AND DT6.DT6_SERIE     = DUD_SERIE"	
		cQuery += "   AND DT6.DT6_BLQDOC   <> '1'"
		cQuery += "   AND DT6.D_E_L_E_T_    = ' '"
	
		If !Empty(cGrpProd) //-- Filtra por Grupo de Produto                                                           		
	   	cQuery += " AND SB1.B1_GRUPO IN ("+cGrpProd+")"		
			cQuery += "   AND SB1.D_E_L_E_T_    = ' '"                     	
		EndIf	
		
		If lLocaliz
			cQuery += " GROUP BY DUD_FILDOC, DUD_DOC, DUD_SERIE, DUH_LOCAL, DUH_LOCALI , DUH_UNITIZ , DUH_CODANA "
		Else
			cQuery += " GROUP BY DUD_FILDOC, DUD_DOC, DUD_SERIE "
		EndIf
	EndIf
	cQuery += " ORDER BY DUD_FILDOC, DUD_DOC, DUD_SERIE "
	cQuery := ChangeQuery(cQuery)
			
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)
			
	TCSetField(cAliasTop,"DT6_PESO"  ,"N",TamSx3("DT6_PESO"  )[1],TamSx3("DT6_PESO"  )[2])
	TCSetField(cAliasTop,"DT6_PESOM3","N",TamSx3("DT6_PESO"  )[1],TamSx3("DT6_PESO"  )[2])
	TCSetField(cAliasTop,"DT6_VALMER","N",TamSx3("DT6_VALMER")[1],TamSx3("DT6_VALMER")[2])
	If !Empty(cGrpProd) .Or. lLocaliz
		TCSetField(cAliasTop,"DTC_DATENT","D",8,0)
		TCSetField(cAliasTop,"DUH_QTDVOL","N",TamSx3("DUH_QTDVOL")[1],TamSx3("DUH_QTDVOL")[2])
	EndIf
	TCSetField(cAliasTop,"DT6_PRZENT","D",8,0)
	
	While (cAliasTop)->(!Eof())
	
		aLinha := Array(55)
		aLinha[CTSTATUS] := (cAliasTop)->DUD_STATUS 
		aLinha[CTSTROTA] := Iif( nOpcx == 3,StrZero(Val(cAcao),nStRota),Iif( Empty((cAliasTop)->DUD_STROTA),StrZero(Val(cAcao),nStRota),(cAliasTop)->DUD_STROTA))
		aLinha[CTMARCA]  := Iif( nOpcx == 3, .F., (cAliasTop)->(DUD_FILORI+DUD_VIAGEM) == M->(DTQ_FILORI+DTQ_VIAGEM) ) 
		aLinha[CTSEQUEN] := Iif(Empty((cAliasTop)->DUD_SEQUEN),Replicate('x',nSequen),(cAliasTop)->DUD_SEQUEN) 
		aLinha[CTARMAZE] := Iif(lLocaliz,(cAliasTop)->DUH_LOCAL,Space(Len(DUH->DUH_LOCAL))) 
		aLinha[CTLOCALI] := Iif(lLocaliz,(cAliasTop)->DUH_LOCALI,Space(Len(DUH->DUH_LOCALI)))    
		aLinha[CTUNITIZ] := Iif(lLocaliz,(cAliasTop)->DUH_UNITIZ,Space(Len(DUH->DUH_UNITIZ))) 
		aLinha[CTCODANA] := Iif(lLocaliz,(cAliasTop)->DUH_CODANA,Space(Len(DUH->DUH_CODANA)))    		
		aLinha[CTFILDOC] := (cAliasTop)->DUD_FILDOC 
		aLinha[CTDOCTO]  := (cAliasTop)->DUD_DOC 
		aLinha[CTSERIE]  := (cAliasTop)->DUD_SERIE 
		aLinha[CTREGDES] := Posicione("DUY",1,xFilial("DUY")+(cAliasTop)->DUD_CDRCAL,"DUY_DESCRI") 
		aLinha[CTESTADO] := DUY->DUY_EST 
		If !Empty(cGrpProd) .Or. lLocaliz
			aLinha[CTDATENT] := (cAliasTop)->DTC_DATENT 
		Else
			aLinha[CTDATENT] := Posicione("DTC",3,xFilial("DTC")+(cAliasTop)->DUD_FILDOC+(cAliasTop)->DUD_DOC+(cAliasTop)->DUD_SERIE,"DTC_DATENT") 
		EndIf
		aLinha[CTPRZENT] := (cAliasTop)->DT6_PRZENT 
		aLinha[CTNOMREM] := Posicione('SA1',1,xFilial('SA1') + (cAliasTop)->(DT6_CLIREM+DT6_LOJREM),'A1_NREDUZ') 
		aLinha[CTNOMDES] := Posicione('SA1',1,xFilial('SA1') + (cAliasTop)->(DT6_CLIDES+DT6_LOJDES),'A1_NREDUZ')
		If lLocaliz .And. !Empty((cAliasTop)->DUH_LOCALI) .And.  (cAliasTop)->DUH_QTDVOL > 0
			aLinha[CTQTDVOL] := (cAliasTop)->DUH_QTDVOL 
		Else
			aLinha[CTQTDVOL] := (cAliasTop)->DT6_QTDVOL 
		EndIf		
		aLinha[CTVOLORI] := (cAliasTop)->DT6_VOLORI 
		aLinha[CTPLIQUI] := (cAliasTop)->DT6_PESO   
		aLinha[CTPESOM3] := (cAliasTop)->DT6_PESOM3 
		aLinha[CTVALMER] := (cAliasTop)->DT6_VALMER 
		aLinha[CTVIAGEM] := Iif( nOpcx == 3, .F., (cAliasTop)->DUD_VIAGEM == M->DTQ_VIAGEM ) 
		aLinha[CTSEQDA7] := ''
		aLinha[CTSOLICI] := ''
		aLinha[CTENDERE] := ''
		aLinha[CTBAIRRO] := ''
		aLinha[CTMUNICI] := ''
		aLinha[CTDATSOL] := CtoD('')
		aLinha[CTHORSOL] := ''
		aLinha[CTDATPRV] := CtoD('')
		aLinha[CTHORPRV] := ''
		aLinha[CTDOCROT] := cRota								//-- Indica a q rota pertence o documento
		aLinha[CTBLQDOC] := (cAliasTop)->DT6_BLQDOC 
		If lDTAOrigem
			nPosDoc := aScan(aDocto, {|x| x[7]+x[8]+x[9] == (cAliasTop)->(DUD_FILDOC + DUD_DOC + DUD_SERIE)})
			If nPosDoc > 0
				aLinha[CTORIGEM] := aDocto[nPosDoc][CTORIGEM]
			Else
				If (cAliasTop)->DUD_STATUS == "1" // Em aberto
					If lVgeExpr .AND. M->DTQ_STATUS == StrZero(2, Len(DTQ->DTQ_STATUS)) // Nf Cliente e a viagem esta em transito.
						aLinha[CTORIGEM] := StrZero(2,Len(DTA->DTA_ORIGEM))
					Else
						aLinha[CTORIGEM] := StrZero(1,Len(DTA->DTA_ORIGEM))
					EndIf
				EndIf
			EndIf
		EndIf
		//-- Inclui colunas do usuario
		If lTM141COL
			For nCnt := 1 To Len(aUsHDocto)
				AAdd(aLinha, &( aUsHDocto[nCnt,2] ) )
			Next nCnt
		EndIf
	
		AAdd(aDoctoAux,AClone(aLinha))
		
		If nItRota > 0 .And. !aRota[nItRota,9] .And. (cAliasTop)->DUD_STATUS <> StrZero(1,Len(DUD->DUD_STATUS))
			aRota[nItRota,9] := .T.
		EndIf
		(cAliasTop)->(dbSkip())
	EndDo	
	
	(cAliasTop)->(dbCloseArea())
	aDocto := {}
	For nCntFor := 1 To Len(aDoctoAux)
		aAdd(aDocto, aClone(aDoctoAux[nCntFor]))
	Next
	aDoctoAux := {}
EndIf

RestArea( aAreaAnt )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140Qr1³ Autor ³ Alex Egydio           ³ Data ³15.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Select rotas para viagem vazia.                            ³±±
±±³          ³ Inicializa o vetor aRota utilizado no listbox de rotas.    ³±±
±±³          ³ Somente rotas ativas.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao selecionada                                  ³±±
±±³          ³ ExpL1 = .T. = Todas as rotas disponiveis                   ³±±
±±³          ³ ExpL2 = .T. = Deixa o vetor de documentos em branco        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140Qr1(nOpcx,lSemViag,lZeraDoc)

Local aAreaAnt	 := GetArea()
Local aAreaDA8	 := DA8->(GetArea())
Local cAliasDA8  := 'DA8'
Local cAliasTop  := 'TMSA140'
Local cDscSer	 := ''
Local cDscTra	 := ''
Local cIndDA8	 := ''
Local cQuery	 := ''
Local lQuery	 := .F.
Local lRet		 := .T.

DEFAULT lSemViag := .F.
DEFAULT lZeraDoc := .T.

lQuery := .T.
If nOpcx == 3 .Or. lSemViag
	cQuery := "SELECT DA8_FILIAL,DA8_COD,DA8_CDRORI,DA8_SERTMS,DA8_TIPTRA,DA8_ATIVO,DA8_DESC,DA8_TIPROT"
	cQuery += " FROM"
	cQuery += " "+RetSqlName('DA8')
	cQuery += " WHERE"
	cQuery += " D_E_L_E_T_  = ' '"
	cQuery += " AND DA8_FILIAL  = '"+xFilial("DA8")+"'"
	cQuery += " AND DA8_CDRORI  = '"+_cCdrOri+"'"
	cQuery += " AND DA8_SERTMS  = '"+cSerTms+"'"
	cQuery += " AND DA8_TIPTRA  = '"+cTipTra+"'"
	cQuery += " AND DA8_ATIVO   = '1'"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)
	cAliasDA8:=cAliasTop
	DbSelectArea(cAliasTop)
	AEval(DA8->(DbStruct()), {|x| Iif(x[2] <> 'C' .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
ElseIf nOpcx == 2 .Or. nOpcx == 4 .Or. nOpcx == 5
	cQuery := "SELECT DA8_FILIAL,DA8_COD,DA8_CDRORI,DA8_SERTMS,DA8_TIPTRA,DA8_ATIVO,DA8_DESC,DA8_TIPROT"
	cQuery += " FROM"
	cQuery += " "+RetSqlName('DA8')
	cQuery += " WHERE"
	cQuery += " D_E_L_E_T_  = ' '"
	cQuery += " AND DA8_FILIAL  = '"+xFilial("DA8")+"'"
	cQuery += " AND DA8_COD     = '"+M->DTQ_ROTA+"'"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)
	cAliasDA8:=cAliasTop
	DbSelectArea(cAliasTop)
	AEval(DA8->(DbStruct()), {|x| Iif(x[2] <> 'C' .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
EndIf	

While (cAliasDA8)->(!Eof())
	If	TmsA140ChkRot('2',(cAliasDA8)->DA8_COD) <= 0
		AAdd(aRota,{Iif(nOpcx==3,.F.,(cAliasDA8)->DA8_COD == M->DTQ_ROTA), (cAliasDA8)->DA8_COD, (cAliasDA8)->DA8_DESC, Tabela('M3',(cAliasDA8)->DA8_TIPROT,.F.),0,0,0,0,.F.})
	EndIf
	(cAliasDA8)->(DbSkip())
EndDo

If	lQuery
	DbSelectArea(cAliasTop)
	DbCloseArea()
Else
	If	File(cIndDA8+OrdBagExt())
		Ferase(cIndDA8+OrdBagExt())
	EndIf
EndIF

If !lSemViag .And. Empty(aRota)
	cDscSer := cSerTms + ' - ' + AllTrim(TmsValField('cSerTms',.F.))
	cDscTra := cTipTra + ' - ' + AllTrim(TmsValField('cTipTra',.F.))
	Help(' ', 1, 'TMSA14004',,STR0025 + cDscSer + STR0032 + cDscTra ,5,3)		//-- Rota para o servico e tipo de transporte nao encontrada (DA8). //'Servico : '###' / Tipo de Transporte : '
	lRet := .F.
EndIf

If	lRet .And. lZeraDoc
	//-- Deixa o vetor de documentos em branco
	TmsA140ZCt(.T.)
EndIf

RestArea( aAreaDA8 )
RestArea( aAreaAnt )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140Var³ Autor ³ Alex Egydio           ³ Data ³25.04.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seleciona documentos para rota variavel                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcoes de manutencao                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140Var(nOpcx)

Local aDoctoAnt := {}
Local oLbxAnt	:= oLbxDocto
Local nCntFor	:= 0
Local nSeek		:= 0
Local lRet		:= .F.

If (nSeek := TmsA140ChkRot('1',,.T.)) <= 0
	Return( Nil	)
EndIf
If	Empty(aDocto)
	Help(' ', 1, 'TMSA14006')	//-- Nenhum documento selecionado !
	Return( Nil )
EndIf

aDoctoAnt:= AClone(aDocto)
MsgRun(STR0044,,{|| lRet := TmsA140Qr3(nOpcx,nSeek,aDoctoAnt) })  // "Aguarde, verificando rotas"
  If lRet
	If	TmsA140VisDoc(,STR0036,nOpcx) // 'Documentos sem rota definida'
		For nCntFor := 1 To Len(aDocto)
			If	aDocto[nCntFor,CTMARCA]
				If ASCan(aDoctoAnt,{|x|x[CTARMAZE]+x[CTLOCALI]+x[CTFILDOC]+x[CTDOCTO]+x[CTSERIE]==aDocto[nCntFor,CTARMAZE]+aDocto[nCntFor,CTLOCALI]+aDocto[nCntFor,CTFILDOC]+aDocto[nCntFor,CTDOCTO]+aDocto[nCntFor,CTSERIE]})<=0
					nSeek := ASCan(aDoctoAnt,{|x|x[CTDOCTO]==Space(6)})
					If	nSeek > 0
						aDoctoAnt[nSeek]:=AClone(aDocto[nCntFor])
					Else
						AAdd(aDoctoAnt,AClone(aDocto[nCntFor]))
					EndIf
				EndIf
			EndIf
		Next
	EndIf
Else
	Help('',1,'TMSA14017') //-- Nao ha documentos sem rota definida
EndIf	

aDocto	 := AClone(aDoctoAnt)
oLbxDocto:= oLbxAnt
oLbxDocto:SetArray( aDocto )

//-- Monta o bLine do listbox
TMSA140bLi( 2 )
	
oLbxDocto:Refresh()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140Qr2³ Autor ³ Alex Egydio           ³ Data ³15.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Select de documentos para rotas variaveis                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = 2 = Seleciona documentos sem rota definida         ³±±
±±³          ³         3 = Seleciona documentos de outras rotas           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140Qr2(cAcao,nOpcx)

Local aAreaAnt	:= GetArea()
Local aAreaDUD  := DUD->(GetArea())
Local aAreaDVM	:= DVM->(GetArea())
Local aEnder	:= {}
Local cAliasDUD := 'DUD'
Local cAliasDT6 := 'DT6'
Local cAliasDTC := 'DTC'
Local cAliasSB1 := 'SB1'
Local cAliasDUY := 'DUY'
Local cIndDUD	:= ''
Local cIndDVM	:= ''
Local cStatus	:= StrZero(1,Len(DUD->DUD_STATUS))
Local cViagem	:= Space(Len(DUD->DUD_VIAGEM))
Local lQuery	:= .F.
Local nSeek		:= TmsA140ChkRot('1')

lChkRtVar := .F.


TmsA140IDc(,,,,,,,,@cIndDUD,,@cIndDVM,cStatus,cViagem,cAcao,,,,lQuery)
(cAliasDUD)->(DbGoTop())
While (cAliasDUD)->(!Eof())

	If !TmsA140DT6(cAliasDT6,cAliasDUD,nOpcx)
		(cAliasDUD)->(DbSkip())
		Loop
	EndIf
	If !TmsA140DTC(aEnder,cAliasDTC,cAliasDUD,cAliasSB1,cAliasDT6)
		(cAliasDUD)->(DbSkip())
		Loop			
	EndIf

	(cAliasDUY)->(DbSetOrder(1))
	(cAliasDUY)->(MsSeek(xFilial('DUY')+(cAliasDUD)->DUD_CDRCAL))

	//-- Identifica um Documento sem rota definida
	If DVM->( ! MsSeek(xFilial('DVM') + (cAliasDUD)->DUD_CDRCAL))
		Tms140Dall(aEnder,cAliasDUD,cAliasDUY,cAliasDT6,cAliasDTC,cAcao,nOpcx,nSeek)
  	EndIf

	(cAliasDUD)->(DbSkip())
EndDo

If File(cIndDUD+OrdBagExt())
	Ferase(cIndDUD+OrdBagExt())
EndIf
If File(cIndDVM+OrdBagExt())
	Ferase(cIndDVM+OrdBagExt())
EndIf

RestArea( aAreaDUD )
RestArea( aAreaDVM )
RestArea( aAreaAnt )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140IDc³ Autor ³ Alex Egydio           ³ Data ³15.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Select para inclusao de documentos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140IDc(cIndDUD,cIndDA8,cIndDVM,cStatus,cViagem,cAcao)

Local cQuery    := ''
Local nIndex    := 0

Local lTMSDCol := SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.

DEFAULT cStatus := StrZero(1,Len(DUD->DUD_STATUS))
DEFAULT cViagem := Space(Len(DUD->DUD_VIAGEM))
DEFAULT cAcao   := '1'

//-- Documentos
DbSelectArea('DUD')
cIndDUD := CriaTrab(Nil,.F.)
DUD->(DbSetOrder(3))
	
cQuery := "DUD_FILIAL == '"+xFilial("DUD")+"' .And. "
If !lTMSDCol
	cQuery += "DUD_FILORI == '"+cFilAnt+"' .And. "
EndIf
cQuery += "DUD_SERTMS == '"+cSerTms+"' .And. "
cQuery += "DUD_TIPTRA == '"+cTipTra+"' .And. "
cQuery += "DUD_STATUS == '"+cStatus+"' .And. "
cQuery += "DUD_VIAGEM == '"+cViagem+"'"

IndRegua('DUD',cIndDUD,DUD->(IndexKey()),,cQuery,STR0035) //"Selecionando Documentos..."
nIndex := RetIndex()
DbSetIndex(cIndDUD+OrdBagExt())
DbSetOrder(nIndex+1)
DbGotop()

If cAcao == '1'
	//-- Rotas
	DbSelectArea('DA8')
	DbSetOrder(1)
	cIndDA8 := CriaTrab(Nil,.F.)
	cQuery := "DA8_FILIAL == '"+xFilial("DA8")+"' .And. "
	cQuery += "DA8_SERTMS == '"+cSerTms+"' .And. "
	cQuery += "DA8_TIPTRA == '"+cTipTra+"' .And. "
	cQuery += "DA8_COD    >= '"+cRotaDe+"' .And. "
	cQuery += "DA8_COD    <= '"+cRotaAte+"' .And. "
	cQuery += "DA8_ATIVO  == '1'"
	IndRegua('DA8',cIndDA8, " DA8_DESC ",,cQuery,STR0012) //'Selecionando rotas...'
	nIndex := RetIndex()
	DbSetIndex(cIndDA8+OrdBagExt())
	DbSetOrder(nIndex+1)
	DbGotop()
ElseIf cAcao == '2'
	//-- Regioes atendidas pelas rotas
	DbSelectArea('DVM')
	cIndDVM := CriaTrab(Nil,.F.)
	IndRegua('DVM',cIndDVM,'DVM_FILIAL + DVM_CDRDES',,TmsA140DA8(),STR0013) //'Selecionando regioes por rota...'
	nIndex := RetIndex()
	DbSetIndex(cIndDVM+OrdBagExt())
	DbSetOrder(nIndex+1)
	DbGotop()
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140DT6³ Autor ³ Alex Egydio           ³ Data ³15.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posiciona documentos de transporte                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140DT6(cAliasDT6,cAliasDUD,nOpcx)

Local lRet := .T.

(cAliasDT6)->(DbSetOrder(1))
If (cAliasDT6)->(MsSeek(xFilial('DT6') + (cAliasDUD)->DUD_FILDOC + (cAliasDUD)->DUD_DOC + (cAliasDUD)->DUD_SERIE))
	If nOpcx != 2
		If	(cAliasDT6)->DT6_CDRORI == _cCdrOri
			lRet := .F.
		ElseIf (cAliasDT6)->DT6_CDRDES < cCdrDesDe .Or. (cAliasDT6)->DT6_CDRDES > cCdrDesAte
			lRet := .F.
		Else
			//-- Documentos bloqueados nao entram na viagem
			If (cAliasDT6)->DT6_BLQDOC == StrZero(1,Len((cAliasDT6)->DT6_BLQDOC))
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140DTC³ Autor ³ Alex Egydio           ³ Data ³15.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa todas as notas contidas no documento.              ³±±
±±³          ³ Obtem documentos do grupo de produto selecionado e qtde de ³±±
±±³          ³ volume em cada endereco                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140DTC(aEnder,cAliasDTC,cAliasDUD,cAliasSB1,cAliasDT6)

Local cSeekDTC := ''
Local aAreaDTC := {}
Local lAchou   := .F.

//-- Posiciona as notas fiscais do cliente contidas no documento
(cAliasDTC)->(DbSetOrder(3))
If (cAliasDTC)->(MsSeek(cSeekDTC := xFilial('DTC') + (cAliasDUD)->DUD_FILDOC + (cAliasDUD)->DUD_DOC + (cAliasDUD)->DUD_SERIE))
	aAreaDTC := (cAliasDTC)->(GetArea())
	While (cAliasDTC)->( ! Eof() .And. (cAliasDTC)->DTC_FILIAL + (cAliasDTC)->DTC_FILDOC + (cAliasDTC)->DTC_DOC + (cAliasDTC)->DTC_SERIE == cSeekDTC )
		//-- Verifica se o grupo de produto foi selecionado
		lAchou := .F.
		If	! TmsA140SB1((cAliasDTC)->DTC_CODPRO,cAliasSB1)
			(cAliasDTC)->(DbSkip())
			Loop
		EndIf        
		lAchou := .T.
		TmsA140DUH(@aEnder,cAliasDTC,cAliasSB1,cAliasDT6)
		(cAliasDTC)->(DbSkip())
	EndDo
	RestArea( aAreaDTC )	
EndIf

Return( lAchou )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140SB1³ Autor ³ Alex Egydio           ³ Data ³15.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o grupo de produto foi selecionado             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140SB1(cCodPro,cAliasSB1)

Local lRet	:= .T.
Local nSeek	:= 0

(cAliasSB1)->(DbSetOrder(1))
If (cAliasSB1)->(MsSeek(xFilial('SB1') + cCodPro))
	If ! Empty( aGrpProd )
		nSeek := Ascan(aGrpProd,{|x|x[1] == (cAliasSB1)->B1_GRUPO})
		If Empty(nSeek)
			lRet := .F.
		EndIf
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140DA8³ Autor ³ Alex Egydio           ³ Data ³15.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Determina se a rota tem as seguintes caracteristicas;      ³±±
±±³          ³ Da regiao origem, do tipo de servico e transporte e se a   ³±±
±±³          ³ rota esta ativa                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140DA8()

Local lRet := .F.

DA8->(DbSetOrder(1))
If DA8->(MsSeek(xFilial('DA8')+DVM->DVM_ROTEIR))
	If	DA8->DA8_COD >= cRotaDe .And. DA8->DA8_COD <= cRotaAte
		lRet := ( DA8->DA8_SERTMS == cSerTms .And. DA8->DA8_TIPTRA == cTipTra .And. DA8->DA8_ATIVO == '1')
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140Qr3³ Autor ³ Alex Egydio           ³ Data ³15.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Select de documentos para rotas variaveis                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcoes de manutencao                               ³±±
±±³          ³ ExpN2 = Item do vetor aRota selecionado                    ³±±
±±³          ³ ExpA1 = Documentos pertencentes a viagem, atendidos pela   ³±±
±±³          ³         rota selecionada.                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140Qr3(nOpcx,nSeek,aDoctoAnt)

Local nCnt
Local cQuery	  := ''
Local nStRota	  := Len(DUD->DUD_STROTA)
Local nSequen	  := Len(DUD->DUD_SEQUEN)
Local cAliasTop   := GetNextAlias()
Local cAliasTop1  := GetNextAlias()
Local aLinha      := {}
Local aAreaAnt    := GetArea()
Local lRet 		  := .F.
Local cRota       := aRota[nSeek,2]
Local cStatus	  := StrZero(1,Len(DUD->DUD_STATUS))
Local lNoEnder    := .F.
Local cCdrDes     := ''

Local lTMSDCol := SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.

Private cAliasDoc := cAliasTop

For nCnt := 1 To Len(aRota[nSeek,10])
	cCdrDes += "'" + aRota[nSeek,10,nCnt] + "',"
Next nCnt
cCdrDes := SubStr(cCdrDes,1,Len(cCdrDes)-1)

cQuery := "   SELECT DUD_FILDOC, DUD_DOC   , DUD_SERIE , DUD_STATUS, DUD_STROTA, "
cQuery += "   			DUD_SEQUEN, DT6_PESO  , DT6_PESOM3, DT6_VALMER, DT6_PRZENT, "
cQuery += "   			DT6_BLQDOC, DUD_CDRCAL, DT6_CLIREM, DT6_LOJREM, DT6_CLIDES, "
cQuery += "   			DT6_LOJDES, DT6_QTDVOL, DT6_VOLORI, DUD_FILORI, DUD_VIAGEM "
cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
cQuery += "   JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += "   	 ON  DT6_FILIAL    = '" + xFilial("DT6") + "'"
cQuery += "  	 AND DT6_FILDOC    = DUD_FILDOC"
cQuery += "  	 AND DT6_DOC       = DUD_DOC"
cQuery += "  	 AND DT6_SERIE     = DUD_SERIE"
cQuery += "  	 AND DT6_CDRCAL BETWEEN '" + cCdrDesDe + "' AND '" + cCdrDesAte + "'"
cQuery += "  	 AND DT6_BLQDOC    <> '1'"
cQuery += "  	 AND DT6.D_E_L_E_T_    = ' '"
cQuery += " WHERE DUD.DUD_FILIAL    = '" + xFilial("DUD") + "'"
If !lTMSDCol
	cQuery += "   AND DUD.DUD_FILORI    = '" + cFilAnt + "'"
EndIf
cQuery += "   AND DUD.DUD_SERTMS    = '" + cSerTms + "'"
cQuery += "   AND DUD.DUD_TIPTRA    = '" + cTipTra + "'"
cQuery += "   AND DUD.DUD_STATUS    = '" + cStatus + "'"
cQuery += "   AND DUD.DUD_VIAGEM    = ' ' "
cQuery += "	  AND DUD.DUD_CDRCAL NOT IN ( "+cCdrDes+" )"
cQuery += "   AND DUD.D_E_L_E_T_    = ' '"
cQuery += "   AND NOT EXISTS ( "
cQuery += "   		SELECT 1 FROM " + RetSqlName("DVM") + " DVM, " + RetSqlName("DA8") + " DA8 "
cQuery += "				WHERE DVM_FILIAL = '" + xFilial("DVM") + "'"
cQuery += "					AND DVM_CDRDES = DUD_CDRCAL "
cQuery += "             AND DVM.D_E_L_E_T_ <> '*' "
cQuery += "             AND DA8_FILIAL = '" + xFilial("DA8") + "'"
cQuery += "             AND DA8_COD    = DVM_ROTEIR "
cQuery += "             AND DA8_SERTMS = '" + cSerTms + "'"
cQuery += "             AND DA8_TIPTRA = '" + cTipTra + "'"
cQuery += "             AND DA8_ATIVO  = '1'"
cQuery += "             AND DA8.D_E_L_E_T_ <> '*' )"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)

TCSetField(cAliasTop,"DT6_PESO"  ,"N",TamSx3("DT6_PESO"  )[1],TamSx3("DT6_PESO"  )[2])
TCSetField(cAliasTop,"DT6_PESOM3","N",TamSx3("DT6_PESO"  )[1],TamSx3("DT6_PESO"  )[2])
TCSetField(cAliasTop,"DT6_VALMER","N",TamSx3("DT6_VALMER")[1],TamSx3("DT6_VALMER")[2])
TCSetField(cAliasTop,"DT6_PRZENT","D",8,0)

aDocto	:= {}
While (cAliasTop)->(!Eof())
	//-- Os documentos da tela anterior nao devem aparecer na selecao de documentos de outras rotas
	If	lLocaliz
		cQuery := " SELECT DUH_LOCAL, DUH_LOCALI, Sum(DUH_QTDVOL) DUH_QTDVOL, MIN(DTC_DATENT) DTC_DATENT , DUH_UNITIZ , DUH_CODANA"
		cQuery += "   FROM " + RetSqlName("DTC") + " DTC "
		cQuery += "   JOIN " + RetSqlName("DUH") + " DUH "
		cQuery += "   	ON DUH_FILIAL = '"+xFilial("DUH")+"'"
		cQuery += "   	AND DUH_FILORI = '"+cFilAnt+"'"
		cQuery += "   	AND DUH_NUMNFC = DTC_NUMNFC"
		cQuery += "   	AND DUH_SERNFC = DTC_SERNFC"
		cQuery += "   	AND DUH_CLIREM = DTC_CLIREM"
		cQuery += "   	AND DUH_LOJREM = DTC_LOJREM"
		cQuery += "   	AND DUH_LOCALI <> ' '"
		cQuery += "   	AND DUH.D_E_L_E_T_ = ' '"
		cQuery += "    AND DTC_FILIAL    = '" + xFilial("DTC") + "'"
		cQuery += "    AND DTC_FILDOC    = '" + (cAliasTop)->DUD_FILDOC + "' "
		cQuery += "    AND DTC_DOC       = '" + (cAliasTop)->DUD_DOC    + "' "
		cQuery += "    AND DTC_SERIE     = '" + (cAliasTop)->DUD_SERIE  + "' "
		cQuery += "    AND DTC.D_E_L_E_T_    = ' '"
		cQuery += " GROUP BY DUH_LOCAL, DUH_LOCALI ,DUH_UNITIZ , DUH_CODANA"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop1,.T.,.T.)

		TCSetField(cAliasTop,"DUH_QTDVOL","N",TamSx3("DUH_QTDVOL")[1],TamSx3("DUH_QTDVOL")[2])

		lNoEnder := .F.
		While (cAliasTop1)->(!Eof())
			lNoEnder := .T.
			If	ASCan(aDoctoAnt,{|x|x[CTARMAZE]+x[CTLOCALI]+x[CTFILDOC]+x[CTDOCTO]+x[CTSERIE] == (cAliasTop1)->DUH_LOCAL + (cAliasTop1)->DUH_LOCALI + (cAliasTop)->DUD_FILDOC + (cAliasTop)->DUD_DOC + (cAliasTop)->DUD_SERIE}) > 0
				(cAliasTop1)->(DbSkip())
				Loop
			EndIf
			aLinha := Array(54)
			aLinha[CTSTATUS] := (cAliasTop)->DUD_STATUS 
			aLinha[CTSTROTA] := Iif( nOpcx == 3,StrZero(2,nStRota),Iif( Empty((cAliasTop)->DUD_STROTA),StrZero(2,nStRota),(cAliasTop)->DUD_STROTA))
			aLinha[CTMARCA]  := Iif( nOpcx == 3, .F., (cAliasTop)->(DUD_FILORI+DUD_VIAGEM) == M->(DTQ_FILORI+DTQ_VIAGEM) ) 
			aLinha[CTSEQUEN] := Iif(Empty((cAliasTop)->DUD_SEQUEN),Replicate('x',nSequen),(cAliasTop)->DUD_SEQUEN) 
			aLinha[CTARMAZE] := (cAliasTop1)->DUH_LOCAL 
			aLinha[CTLOCALI] := (cAliasTop1)->DUH_LOCALI 
			aLinha[CTUNITIZ] := (cAliasTop1)->DUH_UNITIZ
			aLinha[CTCODANA] := (cAliasTop1)->DUH_CODANA 
			aLinha[CTFILDOC] := (cAliasTop)->DUD_FILDOC 
			aLinha[CTDOCTO]  := (cAliasTop)->DUD_DOC 
			aLinha[CTSERIE]  := (cAliasTop)->DUD_SERIE 
			aLinha[CTREGDES] := Posicione("DUY",1,xFilial("DUY")+(cAliasTop)->DUD_CDRCAL,"DUY_DESCRI") 
			aLinha[CTESTADO] := DUY->DUY_EST 
			aLinha[CTDATENT] := (cAliasTop1)->DTC_DATENT 
			aLinha[CTPRZENT] := (cAliasTop)->DT6_PRZENT 
			aLinha[CTNOMREM] := Posicione('SA1',1,xFilial('SA1') + (cAliasTop)->(DT6_CLIREM+DT6_LOJREM),'A1_NREDUZ') 
			aLinha[CTNOMDES] := Posicione('SA1',1,xFilial('SA1') + (cAliasTop)->(DT6_CLIDES+DT6_LOJDES),'A1_NREDUZ') 
			If !Empty((cAliasTop1)->DUH_LOCALI) .And. (cAliasTop1)->DUH_QTDVOL > 0
				aLinha[CTQTDVOL] := (cAliasTop1)->DUH_QTDVOL 
			Else
				aLinha[CTQTDVOL] := (cAliasTop)->DT6_QTDVOL 
			EndIf
			aLinha[CTVOLORI] := (cAliasTop)->DT6_VOLORI 
			aLinha[CTPLIQUI] := (cAliasTop)->DT6_PESO   
			aLinha[CTPESOM3] := (cAliasTop)->DT6_PESOM3 
			aLinha[CTVALMER] := (cAliasTop)->DT6_VALMER 
			aLinha[CTVIAGEM] := Iif( nOpcx == 3, .F., (cAliasTop)->DUD_VIAGEM == M->DTQ_VIAGEM  )
			aLinha[CTSEQDA7] := '' 
			aLinha[CTSOLICI] := '' 
			aLinha[CTENDERE] := '' 
			aLinha[CTBAIRRO] := '' 
			aLinha[CTMUNICI] := '' 
			aLinha[CTDATSOL] := CtoD('') 
			aLinha[CTHORSOL] := '' 
			aLinha[CTDATPRV] := CtoD('') 
			aLinha[CTHORPRV] := '' 
			aLinha[CTDOCROT] := cRota								//-- Indica a q rota pertence o documento
			aLinha[CTBLQDOC] := (cAliasTop)->DT6_BLQDOC 
			//-- Inclui colunas do usuario
			If lTM141COL
				For nCnt := 1 To Len(aUsHDocto)
					AAdd(aLinha, &( aUsHDocto[nCnt,2] ) )
				Next nCnt
			EndIf
			AAdd(aDocto,AClone(aLinha))
			(cAliasTop1)->(DbSkip())
		EndDo
		(cAliasTop1)->(DbCloseArea())
	EndIf
	
	//-- Quando nao utilizar localizacao ou nao encontrar o endereco.
	If !lLocaliz .Or. ( !lNoEnder .And. !lDoctoEnd )
		If	ASCan(aDoctoAnt,{|x|x[CTFILDOC]+x[CTDOCTO]+x[CTSERIE] == (cAliasTop)->DUD_FILDOC + (cAliasTop)->DUD_DOC + (cAliasTop)->DUD_SERIE})>0
			(cAliasTop)->(DbSkip())
			Loop
		EndIf
		aLinha := Array(54)
		aLinha[CTSTATUS] := (cAliasTop)->DUD_STATUS 
		aLinha[CTSTROTA] := Iif( nOpcx == 3,StrZero(2,nStRota),Iif( Empty((cAliasTop)->DUD_STROTA),StrZero(2,nStRota),(cAliasTop)->DUD_STROTA))
		aLinha[CTMARCA]  := Iif( nOpcx == 3, .F., (cAliasTop)->(DUD_FILORI+DUD_VIAGEM) == M->(DTQ_FILORI+DTQ_VIAGEM) ) 
		aLinha[CTSEQUEN] := Iif(Empty((cAliasTop)->DUD_SEQUEN),Replicate('x',nSequen),(cAliasTop)->DUD_SEQUEN) 
		aLinha[CTARMAZE] := Space(Len(DUH->DUH_LOCAL))
		aLinha[CTLOCALI] := Space(Len(DUH->DUH_LOCALI))
		aLinha[CTUNITIZ] := Space(Len(DUH->DUH_UNITIZ))
		aLinha[CTCODANA] := Space(Len(DUH->DUH_CODANA))
		aLinha[CTFILDOC] := (cAliasTop)->DUD_FILDOC
		aLinha[CTDOCTO]  := (cAliasTop)->DUD_DOC
		aLinha[CTSERIE]  := (cAliasTop)->DUD_SERIE
		aLinha[CTREGDES] := Posicione("DUY",1,xFilial("DUY")+(cAliasTop)->DUD_CDRCAL,"DUY_DESCRI")
		aLinha[CTESTADO] := DUY->DUY_EST 
		aLinha[CTDATENT] := Posicione("DTC",3,xFilial("DTC")+(cAliasTop)->DUD_FILDOC+(cAliasTop)->DUD_DOC+(cAliasTop)->DUD_SERIE,"DTC_DATENT") 
		aLinha[CTPRZENT] := (cAliasTop)->DT6_PRZENT 
		aLinha[CTNOMREM] := Posicione('SA1',1,xFilial('SA1') + (cAliasTop)->(DT6_CLIREM+DT6_LOJREM),'A1_NREDUZ') 
		aLinha[CTNOMDES] := Posicione('SA1',1,xFilial('SA1') + (cAliasTop)->(DT6_CLIDES+DT6_LOJDES),'A1_NREDUZ') 
		aLinha[CTQTDVOL] := (cAliasTop)->DT6_QTDVOL 
		aLinha[CTVOLORI] := (cAliasTop)->DT6_VOLORI 
		aLinha[CTPLIQUI] := (cAliasTop)->DT6_PESO   
		aLinha[CTPESOM3] := (cAliasTop)->DT6_PESOM3 
		aLinha[CTVALMER] := (cAliasTop)->DT6_VALMER 
		aLinha[CTVIAGEM] := Iif( nOpcx == 3, .F., (cAliasTop)->DUD_VIAGEM == M->DTQ_VIAGEM ) 
		aLinha[CTSEQDA7] := ''
		aLinha[CTSOLICI] := ''
		aLinha[CTENDERE] := ''
		aLinha[CTBAIRRO] := ''
		aLinha[CTMUNICI] := ''
		aLinha[CTDATSOL] := CtoD('')
		aLinha[CTHORSOL] := ''
		aLinha[CTDATPRV] := CtoD('')
		aLinha[CTHORPRV] := ''
		aLinha[CTDOCROT] := cRota								//-- Indica a q rota pertence o documento
		aLinha[CTBLQDOC] := (cAliasTop)->DT6_BLQDOC
		//-- Inclui colunas do usuario
		If lTM141COL
			For nCnt := 1 To Len(aUsHDocto)
				AAdd(aLinha, &( aUsHDocto[nCnt,2] ) )
			Next nCnt
		EndIf
		AAdd(aDocto,AClone(aLinha))
	EndIf
	(cAliasTop)->(dbSkip())
EndDo
(cAliasTop)->(dbCloseArea())

lRet := !Empty(aDocto)

RestArea( aAreaAnt )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tms140Dall³ Autor ³ Alex Egydio           ³ Data ³15.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa o vetor aAllDocto que contem todos os documentos³±±
±±³          ³ atendidos por todas as rotas.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Vetor contendo os enderecos das notas fiscais      ³±±
±±³          ³ ExpC1 = Alias do DUD                                       ³±±
±±³          ³ ExpC2 = Alias do DUY                                       ³±±
±±³          ³ ExpC3 = Alias do DT6                                       ³±±
±±³          ³ ExpC4 = 1 Doctos da  rota                                  ³±±
±±³          ³         2 Doctos sem rota definida. Rotas variaveis        ³±±
±±³          ³         3 Doctos de outras rotas.   Rotas variaveis        ³±±
±±³          ³ ExpN1 = Opcao selecionada                                  ³±±
±±³          ³ ExpN2 = Posicao da rota selecionada no vetor aRota         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tms140Dall(aEnder,cAliasDUD,cAliasDUY,cAliasDT6,cAliasDTC,cAcao,nOpcx,nItRota)

Local nCnt
Local aLinha	   := {}
Local cRota		   := aRota[nItRota,2]
Local nCntFor	   := 0
Local nStRota	   := Len(DUD->DUD_STROTA)
Local nSequen	   := Len(DUD->DUD_SEQUEN)

DEFAULT cAcao      := '1'

Private cAliasDoc  := cAliasDUD

For nCntFor := 1 To Len( aEnder )
	aLinha := Array(54)
	aLinha[CTSTATUS] := (cAliasDUD)->DUD_STATUS
	aLinha[CTSTROTA] := Iif( nOpcx == 3,StrZero(Val(cAcao),nStRota),Iif( Empty((cAliasDUD)->DUD_STROTA),StrZero(Val(cAcao),nStRota),(cAliasDUD)->DUD_STROTA))
	aLinha[CTMARCA]  := Iif( nOpcx == 3, .F., (cAliasDUD)->DUD_VIAGEM == M->DTQ_VIAGEM )
	aLinha[CTSEQUEN] := Iif(Empty((cAliasDUD)->DUD_SEQUEN),Replicate('x',nSequen),(cAliasDUD)->DUD_SEQUEN) 

	aLinha[CTARMAZE] := aEnder[ nCntFor, 1 ] 
	aLinha[CTLOCALI] := aEnder[ nCntFor, 2 ] 
	//--Colocar a Linha
	aLinha[CTUNITIZ] := aEnder[ nCntFor, 5 ] 
	aLinha[CTCODANA] := aEnder[ nCntFor, 6 ]

	aLinha[CTFILDOC] := (cAliasDUD)->DUD_FILDOC 
	aLinha[CTDOCTO]  := (cAliasDUD)->DUD_DOC 
	aLinha[CTSERIE]  := (cAliasDUD)->DUD_SERIE 
	aLinha[CTREGDES] := (cAliasDUY)->DUY_DESCRI
	aLinha[CTESTADO] := (cAliasDUY)->DUY_EST
	aLinha[CTDATENT] := (cAliasDTC)->DTC_DATENT 
	aLinha[CTPRZENT] := (cAliasDT6)->DT6_PRZENT
	aLinha[CTNOMREM] := Posicione('SA1',1,xFilial('SA1') + aEnder[ nCntFor, 4 ] + aEnder[ nCntFor, 5 ],'A1_NREDUZ') 
	aLinha[CTNOMDES] := Posicione('SA1',1,xFilial('SA1') + aEnder[ nCntFor, 6 ] + aEnder[ nCntFor, 7 ],'A1_NREDUZ')
	aLinha[CTQTDVOL] := aEnder[ nCntFor, 3 ]
	aLinha[CTVOLORI] := aEnder[ nCntFor, 4 ]
	aLinha[CTPLIQUI] := (cAliasDT6)->DT6_PESO
	aLinha[CTPESOM3] := (cAliasDT6)->DT6_PESOM3
	aLinha[CTVALMER] := (cAliasDT6)->DT6_VALMER
	aLinha[CTVIAGEM] := Iif( nOpcx == 3, .F., (cAliasDUD)->DUD_VIAGEM == M->DTQ_VIAGEM )
	aLinha[CTSEQDA7] := ''
	aLinha[CTSOLICI] := ''
	aLinha[CTENDERE] := ''
	aLinha[CTBAIRRO] := ''
	aLinha[CTMUNICI] := ''
	aLinha[CTDATSOL] := CtoD('')
	aLinha[CTHORSOL] := ''
	aLinha[CTDATPRV] := CtoD('')
	aLinha[CTHORPRV] := ''
	aLinha[CTDOCROT] := cRota								//-- Indica a q rota pertence o documento
	aLinha[CTBLQDOC] := (cAliasDT6)->DT6_BLQDOC
	//-- Inclui colunas do usuario
	If lTM141COL
		For nCnt := 1 To Len(aUsHDocto)
			AAdd(aLinha, &( aUsHDocto[nCnt,2] ) )
		Next nCnt
	EndIf

	If	cAcao == '1'
		If ASCan(aAllDocto,{|x|x[CTDOCROT]+x[CTARMAZE]+x[CTLOCALI]+x[CTFILDOC]+x[CTDOCTO]+x[CTSERIE]==aLinha[CTDOCROT]+aLinha[CTARMAZE]+aLinha[CTLOCALI]+aLinha[CTFILDOC]+aLinha[CTDOCTO]+aLinha[CTSERIE]})<=0
			aRota[nItRota,5] := aRota[nItRota,5] + (cAliasDT6)->DT6_QTDVOL
			aRota[nItRota,6] := aRota[nItRota,6] + (cAliasDT6)->DT6_PESO
			aRota[nItRota,7] := aRota[nItRota,7] + (cAliasDT6)->DT6_PESOM3
			aRota[nItRota,8] := aRota[nItRota,8] + (cAliasDT6)->DT6_VALMER
			AAdd(aAllDocto,AClone(aLinha))
		EndIf
	ElseIf cAcao == '2'
		If	ASCan(aDocto,{|x|x[CTARMAZE]+x[CTLOCALI]+x[CTFILDOC]+x[CTDOCTO]+x[CTSERIE]==aEnder[nCntFor,1]+aEnder[nCntFor,2]+(cAliasDUD)->DUD_FILDOC+(cAliasDUD)->DUD_DOC+(cAliasDUD)->DUD_SERIE })<=0
			AAdd(aSRota,AClone(aLinha))
			AAdd(aDocto,AClone(aLinha))
		EndIf
	EndIf
Next

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA140ChkRot³ Autor ³ Alex Egydio        ³ Data ³23.04.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa o vetor aRota conforme o parametro cAcao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = '1' = Verifica se ha rotas selecionadas            ³±±
±±³          ³         '2' = Pesquisa o codigo da rota no vetor aRota     ³±±
±±³          ³ ExpC2 = Codigo da rota, se cAcao igual a '2'               ³±±
±±³          ³ ExpC3 = .T. Envia help                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140ChkRot(cAcao,cRota,lHelp)

Local nRet	  := 0

DEFAULT cAcao := '1'
DEFAULT cRota := ''
DEFAULT lHelp := .F.

If	cAcao == '1'
	nRet := AScan(aRota,{|x|x[1]==.T.})
ElseIf cAcao == '2'
	nRet := AScan(aRota,{|x|x[2]==cRota})
EndIf
If	lHelp .And. nRet <= 0
	Help(' ', 1, 'TMSA14016')	//-- Nenhuma rota selecionada !
EndIf

Return( nRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140Dca³ Autor ³ Alex Egydio           ³ Data ³09.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Informar a filial de descarga                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Filial de destino dos documentos da viagem         ³±±
±±³          ³ ExpA2 - Filial de descarga da rota selecionada na viagem   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140Dca(aFilDca,aFiliais,lAlianca)

Local cTxtDca	:= Posicione('SX3',2,'DTA_FILDCA' ,'X3Titulo()')
Local cLbx		:= ''
Local lChkDca	:= .F.
Local lFecha	:= .F.	//-- Somente sai da tela se a selecao das filiais de descarga estiver ok
Local oChkDca
Local oDlgDca
Local oLbxDca

DEFINE MSDIALOG oDlgDca TITLE STR0041 + cTxtDca FROM 00,00 TO 350,769 PIXEL //"Selecione a "

@ 30, 01 LISTBOX oLbxDca VAR cLbx FIELDS HEADER Posicione('SX3',2,'DT6_FILDES' ,'X3Titulo()'),STR0040,cTxtDca,;
STR0040,STR0039 SIZE 383,150 ON DBLCLICK(TmsA140ShowDca(aFilDca,aFiliais,lChkDca,oLbxDca),oLbxDca:Refresh()) NOSCROLL OF oDlgDca PIXEL
oLbxDca:SetArray( aFilDca )
oLbxDca:bLine := {|| {aFilDca[oLbxDca:nAT,1],aFilDca[oLbxDca:nAT,2],aFilDca[oLbxDca:nAT,3],aFilDca[oLbxDca:nAT,4],Transform(aFilDca[oLbxDca:nAT,5],PesqPictQt('DT6_QTDVOL'))} }

//-- Distribui a filial de descarga selecionada para todos os itens
@ 23,01 CHECKBOX oChkDca VAR lChkDca PROMPT STR0033 + AllTrim(cTxtDca) + STR0034 SIZE 150, 05 OF oDlgDca PIXEL //"Repete a "

ACTIVATE MSDIALOG oDlgDca VALID lFecha CENTERED ON INIT EnchoiceBar(oDlgDca,{||lFecha:=TmsA140FOk(aFilDca,lAlianca), Iif(lFecha,oDlgDca:End(),.F.)},{||.F.})

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140ShowDca³ Autor ³ Alex Egydio       ³ Data ³09.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche aFilDca com a filial de descarga selecionada      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Filial de destino dos documentos da viagem         ³±±
±±³          ³ ExpA2 - Filial de descarga da rota selecionada na viagem   ³±±
±±³          ³ ExpL1 - .T. = Distribui a fil.de descarga p/todos os itens ³±±
±±³          ³ ExpO1 - Listbox das filiais de destino                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140ShowDca(aFilDca,aFiliais,lChkDca,oLbxDca)

Local nCntFor := 0
Local nItem   := 0

nItem := TmsF3Array({STR0030,STR0027}, aFiliais,'',.F.) //"Filial de Descarga"###"Nome da Filial"
If	! Empty(nItem)
	If	lChkDca
		For nCntFor := 1 To Len(aFilDca)
			aFilDca[nCntFor,3]:=aFiliais[nItem,1]
			aFilDca[nCntFor,4]:=aFiliais[nItem,2]
		Next
	Else
		aFilDca[oLbxDca:nAT,3]:=aFiliais[nItem,1]
		aFilDca[oLbxDca:nAT,4]:=aFiliais[nItem,2]
	EndIf
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140FOk³ Autor ³ Alex Egydio           ³ Data ³09.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obriga informar fil.descarga em todos os itens de aFilDca  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Filial de destino dos documentos da viagem         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA140FOk(aFilDca,lAlianca)

Local cFilDca := Space(Len(DTA->DTA_FILDCA))
Local nCntFor := 0
Local n1Cnt   := 0
Local nSeek	  := 0

nSeek:=AScan(aFilDca,{|x|x[3]==cFilDca})
If	nSeek > 0
	Return( .F. )
EndIf
//-- Grava a filial de descarga na getdados de carregamento
For nCntFor := 1 To Len(aCols)
	For n1Cnt := 1 To Len(aFilDca)
		cFilDca := aFilDca[n1Cnt,3]
		nSeek   := AScan(aFilDca[n1Cnt,6],GdFieldGet('DTA_FILDOC',nCntFor)+GdFieldGet('DTA_DOC',nCntFor)+GdFieldGet('DTA_SERIE',nCntFor))
		If	nSeek > 0

			DUD->(DbSetOrder(1))
			If DUD->(MsSeek(xFilial("DUD")+GdFieldGet('DTA_FILDOC',nCntFor)+GdFieldGet('DTA_DOC',nCntFor)+GdFieldGet('DTA_SERIE',nCntFor)))

				GDFieldPut('DTA_FILDCA',cFilDca,nCntFor)
				RecLock("DUD", .F.)
				DUD->DUD_FILDCA := cFilDca

				If lAlianca
					GDFieldPut('DTA_FILDPC',cFilDca,nCntFor)
					DUD->DUD_FILDPC := cFilDca
				EndIf

				MsUnlock()

			EndIf
			Exit
		EndIf
	Next
Next

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA140Line³ Autor ³ Eduardo de Souza     ³ Data ³ 23/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao da bLine do documento.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA140Line(ExpN1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Posicao da linha no listbox                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA140Line(nAt)

Local abLine  := {}
Local nCnt    := 0
Local nPosIni := 0

AAdd( abLine, Tms140RetBitmap(aDocto[nAt,CTSTATUS],'1') )
AAdd( abLine, Tms140RetBitmap(aDocto[nAt,CTSTROTA],'2') )
AAdd( abLine, Iif(aDocto[nAt,CTMARCA], oMarked, oNoMarked ) )
If lLocaliz
	AAdd( abLine, aDocto[nAt,CTARMAZE])
	AAdd( abLine, aDocto[nAt,CTLOCALI])
	AAdd( abLine, aDocto[nAt,CTUNITIZ])
	AAdd( abLine, aDocto[nAt,CTCODANA])
EndIf

dbSelectArea("DT6")

AAdd( abLine ,aDocto[nAt,CTFILDOC] )
AAdd( abLine ,aDocto[nAt,CTDOCTO]  )
AAdd( abLine ,aDocto[nAt,CTSERIE]  )
AAdd( abLine ,aDocto[nAt,CTREGDES] )
AAdd( abLine ,aDocto[nAt,CTESTADO] )
AAdd( abLine ,aDocto[nAt,CTDATENT] )
AAdd( abLine ,aDocto[nAt,CTPRZENT] )
AAdd( abLine ,aDocto[nAt,CTNOMREM] )
AAdd( abLine ,aDocto[nAt,CTNOMDES] )
AAdd( abLine ,Transform(aDocto[nAt ,CTQTDVOL] ,PesqPictQt('DT6_QTDVOL'     ) ))
AAdd( abLine ,Transform(aDocto[nAt ,CTVOLORI] ,PesqPictQt('DT6_VOLORI'     ) ))
AAdd( abLine ,Transform(aDocto[nAt ,CTPLIQUI] ,PesqPict('DT6','DT6_PESO'   ) ))
AAdd( abLine ,Transform(aDocto[nAt ,CTPESOM3] ,PesqPict('DT6','DT6_PESOM3' ) ))
AAdd( abLine ,Transform(aDocto[nAt ,CTVALMER] ,PesqPict('DT6','DT6_VALMER' ) ))

//-- Inclui colunas do usuario
//-- Ultima posicao do aDocto padrao para inicializar o bline do usuario.
If lTM141COL
	nPosIni  := (Len(aDocto[nAt]) - Len(aUsHDocto)) + 1
	For nCnt := nPosIni To Len(aDocto[nAt])
		AAdd( abLine, aDocto[nAt,nCnt] )
	Next nCnt
EndIf

Return( abLine )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140MOk³ Autor ³ Alex Egydio           ³ Data ³28.09.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Condicoes nas quais nao deve alterar a marca do documento  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Item do vetor aDocto                               ³±±
±±³          ³ ExpN2 - Opcao de manutencao                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA140MOk(nItem,nOpcx,nLbx)

Local lRet		:= .T.
Local nStatus	:= Len(DUD->DUD_STATUS)
Local lTmsCte   := SuperGetMv( "MV_TMSCTE", .F., .F. )
Local aArea 	:= {}

Default nLbx		:= 2 

//-- Condicoes nas quais nao deve alterar a marca do documento
//-- Status do documento igual a 2 - Em Transito, 3 - Carregado, 4 - Encerrado
//-- Codigo do documento em branco
//-- Opcao de manutencao visualizar ou excluir
If aDocto[nItem,CTSTATUS] == StrZero(2,nStatus) .Or.;
	aDocto[nItem,CTSTATUS] == StrZero(3,nStatus) .Or.;
	aDocto[nItem,CTSTATUS] == StrZero(4,nStatus) .Or.;
	Empty(aDocto[nItem,CTDOCTO]) .Or. nOpcx == 2 .Or. nOpcx == 5
	lRet := .F.
EndIf

//--Nao e permitido selecionar um documento
//--ja utilizado em outra viagem
If lRet
	If !aDocto[nItem,CTMARCA] //-- Se o documento nao estiver marcado, validar antes de marcar
		DUD->(DbSetOrder(1))
		If DUD->(MsSeek(xFilial("DUD") + aDocto[nItem,CTFILDOC] + aDocto[nItem,CTDOCTO] + aDocto[nItem,CTSERIE] + cFilAnt ) )
		
			//////////////////////////////////////////////////////////////////
			// EXECUTAR PROCESSO DO CTe APENAS COM PARAMETRO HABILITADO		//
			// Verifica se o lote esta autorizado pela Sefaz.				//
			//////////////////////////////////////////////////////////////////
			If (lTMSCTe)
				//////////////////////////////////////////////////////////////
				// Checar o Status do Documento no Processo CT-e.			//
				// 	DT6_IDRCTE == 100 ("Autorizado o uso dO CT-e")	        //
				// 	DTP_TIPLOT == 3 (Eletronico)                            //
				// 	DTP_TIPLOT == 4 (CTe Único)                             //
				//////////////////////////////////////////////////////////////
				aArea 	:= GetArea() 
				cAliasDtp := GetNextAlias()
				
				cQuery := " SELECT " +CRLF
				cQuery += " 		DT6.DT6_IDRCTE " +CRLF
				cQuery += " FROM " + RetSqlName("DT6") + " DT6" +CRLF
				cQuery += " 		INNER JOIN " + RetSqlName('DTP') + " DTP ON (DTP.DTP_FILIAL = '" + xFilial('DTP') + "'" +CRLF
				cQuery += " 															  AND DTP.DTP_FILORI = DT6.DT6_FILORI AND DTP.DTP_LOTNFC = DT6.DT6_LOTNFC" +CRLF
				cQuery += " 															  AND DTP.DTP_TIPLOT IN ('3', '4')  AND DTP.D_E_L_E_T_<>'*' ) " +CRLF
				cQuery += " WHERE " +CRLF
				cQuery += " 		DT6.DT6_FILIAL ='" + xFilial("DT6")  + "'"
				cQuery += " AND DT6.DT6_FILDOC ='" + DUD->DUD_FILDOC + "'" +CRLF
				cQuery += " AND DT6.DT6_DOC    ='" + DUD->DUD_DOC    + "'" +CRLF
				cQuery += " AND DT6.DT6_SERIE  ='" + DUD->DUD_SERIE  + "'" +CRLF
				cQuery += " AND DT6.DT6_IDRCTE NOT IN ('100','136') " +CRLF
				If DT6->(FieldPos('DT6_CHVCTG')) > 0
					cQuery +=" AND DT6.DT6_CHVCTG= ' ' "
				EndIf	
				cQuery += " AND DT6.DT6_DOCTMS NOT IN ('" +	StrZero( 5, Len( DT6->DT6_DOCTMS ) ) + "', '" +;    //--Nota Fiscal de Serv. de Transp.
															Replicate('D', Len( DT6->DT6_DOCTMS ) ) + "', '" +; //--Nota Fiscal de Reentrega
															Replicate('F', Len( DT6->DT6_DOCTMS ) ) + "', '" +; //--Nota Fiscal de Armazenagem
															Replicate('G', Len( DT6->DT6_DOCTMS ) ) + "') "     //--Nota Fiscal de Complemento
				cQuery += " AND DT6.D_E_L_E_T_<>'*'"   +CRLF

				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDtp,.T.,.T.)
			
				If (cAliasDtp)->(!Eof())
					Help(' ',1, 'TMSA14027',,STR0074 + " " + AllTrim(DUD->DUD_FILDOC) + " - " + AllTrim(DUD->DUD_DOC) + " - " + DUD->DUD_SERIE,3,1)
					lRet := .F.
			   EndIf	
				(cAliasDtp)->(DbCloseArea())
				RestArea(aArea)
			EndIf		
		
			If nOpcx == 3 .And. !Empty(DUD->DUD_VIAGEM) //-- Verificacao se alguma viagem ja na gravou este documento
				lRet := .F.				
			Else
				If nLbx == 2 .And. !TmsConTran(aDocto[nItem,CTFILDOC] , aDocto[nItem,CTDOCTO] , aDocto[nItem,CTSERIE], .T. )
					Help(' ',1,'TMSA14023',,STR0060 + " " + aDocto[nItem,CTFILDOC] + " " + aDocto[nItem,CTDOCTO] + "-" + aDocto[nItem,CTSERIE],3,1) //--"O documento foi selecionado em outra viagem." ### "Documento"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	Else //-- Se o documento estiver marcado
		//-- Ao desmarcar o documento preciso libera-lo para ser utilizado em outra viagem
		TmsConTran( aDocto[nItem,CTFILDOC] , aDocto[nItem,CTDOCTO] , aDocto[nItem,CTSERIE] )
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA140Fbr ³ Autor ³Wellington A Santos   ³ Data ³ 26/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra Legenda da tabela para filtrar o mbrowse             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA140Fbr()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA140Fbr( cAlias , nOpc1 , nOpc2 , oObj ,lFwMBrowse )
Static aLegend
Static cFilDTQ

Local cFiltro 	:= ""
Local cLegend 	:= ""
Local aRetBox 	:= {}
Local aFiltros	:= {}
Local nCount  	:= 0
Local nItens  	:= 0
Local cResult	:= ""

Default oObj    	:= GetObjBrow()
Default lFwMBrowse	:= .F. 

If ValType(aLegend)=="U"
	aLegend := {}
	aRetBox := RetSx3Box( Posicione("SX3", 2, "DTQ_STATUS" , "X3CBox()" ),,, 1 )
	ASort( aRetBox,,,{|x,y| x[2] < y[2] })
	For nCount := 1 To Len(aRetBox)
		If !Empty(aRetBox[nCount,3])
			AAdd(aLegend, { .F., aRetBox[nCount,2],aRetBox[nCount,3] })
		EndIf
	Next nCount
EndIf

If ValType(cFilDTQ)=="U" .And. ValType(oObj) == "O"
	//-- Guarda filtro original
	cFilDTQ := oObj:GetFilterDefault()
EndIf

If TmsABrowse( aLegend, STR0026,,,,.F., { STR0016,STR0015 } ) //"Selecione o status da Viagem"###"Codigo"###"Status"
	//-- Total de itens marcados.
	aEval(aLegend,{|x|Iif(x[1],nItens++,)})
	For nCount := 1 To Len(aLegend)
		If aLegend[nCount,1]
			If !lFwMBrowse
				cLegend += "'" + aLegend[nCount,2] + "',"				
			Else
				Aadd( aFiltros , aLegend[nCount,2] )	
			EndIf
			aLegend[nCount,1] := .F. //-- Desmarca item para reutilizar var. static
		EndIf
	Next nCount
	
	For nCount := 1 To Len(aFiltros)
		cLegend += "DTQ_STATUS = '" + aFiltros[nCount] + "' "

		If nCount <> Len(aFiltros)
			cLegend		+= " .Or. "
		EndIf

	Next nCount

	If !lFwMBrowse
		///-- Retira virgula no final da string
		cLegend := Alltrim( Substr(cLegend,1,Len(cLegend)- 1) )

		//-- Verifica se marcou mais de um item.
		If nItens >= 1				
			cFiltro += " DTQ_STATUS IN (" + cLegend  + ") "			
		EndIf
		
		If !Empty(cFilDTQ)				
			cFiltro := " AND " + cFiltro			
		EndIf
	EndIf
EndIf

If ValType(oObj) == "O"
	
	If lFwMBrowse
		oObj:DeleteFilter("DTQ_STATUS")
		oObj:AddFilter("DTQ_STATUS",cLegend, .F. , .T. ,, .F. ,,"DTQ_STATUS") 
		oObj:ExecuteFilter(.T.)	
	Else
		cResult		:= cFilDTQ+cFiltro	
		oObj:SetFilterDefault(cResult)
		oObj:Refresh()
	EndIf

EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA140DSR ³ Autor ³Eduardo de Souza      ³ Data ³ 25/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Documentos de outras rotas                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA140DSR(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA140                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA140DSR(nOpcx)

Local oDlg
Local nOpcao    := 1
Local cFilDoc   := ""
Local cDocto    := ""
Local cSerie    := Space(Len(DT6->DT6_SERIE ))
Local cStatus   := StrZero(1,Len(DUD->DUD_STATUS))
Local cCdrDes   := ''
Local nCnt      := 0
Local cAliasTop := GetNextAlias()
Local nSeek     := 0
Local nStRota   := Len(DUD->DUD_STROTA)
Local nSequen   := Len(DUD->DUD_SEQUEN)
Local cRota     := ''

Local lTMSDCol := SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.

If (nSeek:=TmsA140ChkRot('1',,.T.)) <= 0
	Return( .F. )
EndIf

If Empty(aDocto)
	Help(' ', 1, 'TMSA14006')	//-- Nenhum documento selecionado !
	Return( .F. )
EndIf

cRota := aRota[nSeek,2]

For nCnt := 1 To Len(aRota[nSeek,10])
	cCdrDes += "'" + aRota[nSeek,10,nCnt] + "',"
Next nCnt
cCdrDes := SubStr(cCdrDes,1,Len(cCdrDes)-1)

While nOpcao == 1

	nOpcao    := 0
	aDoctoAnt := AClone(aDocto)

	cFilDoc   := Space(Len(DT6->DT6_FILDOC))
	cDocto    := Space(Len(DT6->DT6_DOC   ))
	
	DEFINE MSDIALOG oDlg FROM 00,00 TO 110,490 PIXEL STYLE nOr(DS_MODALFRAME,WS_POPUP,WS_CAPTION) TITLE STR0068 //"Doctos. de Outras Rotas"
	
	@ 05,05 SAY   RetTitle("DT6_FILDOC") PIXEL 
	@ 05,80 MSGET cFilDoc SIZE 20, 10 OF oDlg  F3 "DL6" PIXEL 
	
	@ 20,05 SAY   RetTitle("DT6_DOC")  PIXEL 
	@ 20,80 MSGET cDocto          SIZE 60, 10 OF oDlg PIXEL 
	
	@ 35,05 SAY   RetTitle("DT6_SERIE") PIXEL 
	@ 35,80 MSGET cSerie          SIZE 30, 10 OF oDlg PIXEL 
	
	DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (nOpcao := 1,oDlg:End())
	DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION (nOpcao := 0,oDlg:End())
		
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If nOpcao == 1
		If Empty(cFilDoc) .Or. Empty(cDocto) .Or. Empty(cSerie)
			Help(' ', 1, 'TMSA14022')	//"Documento nao encontrado !!!"
		Else			
			cQuery := " SELECT  DUD_FILDOC, DUD_DOC, DUD_SERIE, DUH_LOCAL, DUH_LOCALI , Sum(DUH_QTDVOL) DUH_QTDVOL, DUH_UNITIZ , DUH_CODANA, "
			cQuery += " 			MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_STROTA) DUD_STROTA, MIN(DUD_SEQUEN) DUD_SEQUEN, "
			cQuery += " 			MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, MIN(DT6_VALMER) DT6_VALMER, "
			cQuery += " 			MIN(DTC_DATENT) DTC_DATENT, MIN(DT6_PRZENT) DT6_PRZENT, MIN(DT6_BLQDOC) DT6_BLQDOC, "
			cQuery += " 			MIN(DT6_CLIREM) DT6_CLIREM, MIN(DT6_LOJREM) DT6_LOJREM, MIN(DT6_CLIDES) DT6_CLIDES, "
			cQuery += " 			MIN(DT6_LOJDES) DT6_LOJDES, MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DUD_FILORI) DUD_FILORI, "
			cQuery += " 			MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DUD_CDRCAL) DUD_CDRCAL, MIN(DT6_VOLORI) DT6_VOLORI "
			cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
			cQuery += "   JOIN " + RetSqlName("DT6") + " DT6 "
			cQuery += "     ON  DT6_FILIAL    = '"+xFilial("DT6")+"'"
			cQuery += "     AND DT6_FILDOC    = DUD_FILDOC"
			cQuery += "     AND DT6_DOC       = DUD_DOC"
			cQuery += "     AND DT6_SERIE     = DUD_SERIE"
			cQuery += "     AND DT6_BLQDOC    <> '1'"
			cQuery += "     AND DT6.D_E_L_E_T_    = ' '"
			cQuery += "   JOIN " + RetSqlName("DTC") + " DTC "
			cQuery += "     ON  DTC_FILIAL    = '"+xFilial("DTC")+"'"
			cQuery += "     AND DTC_FILDOC = DT6_FILDOC "
			cQuery += "     AND DTC_DOC    = DT6_DOC "
			cQuery += "     AND DTC_SERIE  = DT6_SERIE "
			cQuery += "     AND DTC.D_E_L_E_T_ = ' ' "
			If lDoctoEnd
				cQuery +=  "   JOIN " + RetSqlName("DUH") + " DUH "
			Else
				cQuery +=  "   LEFT JOIN " + RetSqlName("DUH") + " DUH "
			EndIf
			cQuery += "     ON  DUH_FILIAL    = '"+xFilial("DUH")+"'"
			cQuery += "     AND DUH_FILORI = '" + cFilAnt + "' "
			cQuery += "     AND DUH_NUMNFC = DTC_NUMNFC "
			cQuery += "     AND DUH_SERNFC = DTC_SERNFC "
			cQuery += "     AND DUH_CLIREM = DTC_CLIREM "
			cQuery += "     AND DUH_LOJREM = DTC_LOJREM "
			cQuery += "     AND DUH_LOCALI <> ' ' "
			cQuery += "     AND DUH.D_E_L_E_T_ = ' ' "
			cQuery += "   WHERE DUD_FILIAL    = '"+xFilial("DUD")+"'"
			cQuery += "     AND DUD_FILDOC    = '" + cFilDoc + "' "
			cQuery += "     AND DUD_DOC       = '" + cDocto  + "' "
			cQuery += "     AND DUD_SERIE     = '" + cSerie  + "' "
			If !lTMSDCol
				cQuery += "     AND DUD_FILORI    = '"+cFilAnt+"'"
			EndIf
			cQuery += "     AND DUD_SERTMS    = '"+cSerTms+"'"
			cQuery += "     AND DUD_TIPTRA    = '"+cTipTra+"'"
			cQuery += "     AND DUD_STATUS    = '"+cStatus+"'"
			cQuery += "     AND DUD_VIAGEM    = ' '"
			cQuery += "	    AND DUD.DUD_CDRCAL NOT IN ( "+cCdrDes+" )"
			cQuery += "     AND DUD.D_E_L_E_T_    = ' '"
			cQuery += " GROUP BY DUD_FILDOC, DUD_DOC, DUD_SERIE, DUH_LOCAL, DUH_LOCALI , DUH_UNITIZ , DUH_CODANA"
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)

			TCSetField(cAliasTop,"DUH_QTDVOL","N",TamSx3("DUH_QTDVOL")[1],TamSx3("DUH_QTDVOL")[2])

			If (cAliasTop)->(!Eof())
				//-- Zera o array para rota sem doctos.
				If	ASCan(aDoctoAnt,{|x|x[CTFILDOC]+x[CTDOCTO]+x[CTSERIE] == Space(Len(DUD->DUD_FILDOC))+Space(Len(DUD->DUD_DOC))+Space(Len(DUD->DUD_SERIE)) }) > 0
					aDocto := {}
				EndIf
				While (cAliasTop)->(!Eof())
					If lLocaliz
						If	ASCan(aDoctoAnt,{|x|x[CTARMAZE]+x[CTLOCALI]+x[CTFILDOC]+x[CTDOCTO]+x[CTSERIE] == (cAliasTop)->DUH_LOCAL + (cAliasTop)->DUH_LOCALI + (cAliasTop)->DUD_FILDOC + (cAliasTop)->DUD_DOC + (cAliasTop)->DUD_SERIE}) > 0
							(cAliasTop)->(DbSkip())
							Loop
						EndIf
					Else
						If	ASCan(aDoctoAnt,{|x|x[CTFILDOC]+x[CTDOCTO]+x[CTSERIE] == (cAliasTop)->DUD_FILDOC + (cAliasTop)->DUD_DOC + (cAliasTop)->DUD_SERIE}) > 0
							(cAliasTop)->(DbSkip())
							Loop
						EndIf
					EndIf
					aLinha := Array(54)
					aLinha[CTSTATUS] := (cAliasTop)->DUD_STATUS
					aLinha[CTSTROTA] := Iif( nOpcx == 3,StrZero(3,nStRota),Iif( Empty((cAliasTop)->DUD_STROTA),StrZero(3,nStRota),(cAliasTop)->DUD_STROTA))
					aLinha[CTMARCA]  := .T.
					aLinha[CTSEQUEN] := Iif(Empty((cAliasTop)->DUD_SEQUEN),Replicate('x',nSequen),(cAliasTop)->DUD_SEQUEN)
					aLinha[CTARMAZE] := Iif(lLocaliz,(cAliasTop)->DUH_LOCAL,Space(Len(DUH->DUH_LOCAL)))
					aLinha[CTLOCALI] := Iif(lLocaliz,(cAliasTop)->DUH_LOCALI,Space(Len(DUH->DUH_LOCALI))) 
					aLinha[CTUNITIZ] := Iif(lLocaliz,(cAliasTop)->DUH_UNITIZ,Space(Len(DUH->DUH_UNITIZ)))
					aLinha[CTCODANA] := Iif(lLocaliz,(cAliasTop)->DUH_CODANA,Space(Len(DUH->DUH_CODANA))) 										
					aLinha[CTFILDOC] := (cAliasTop)->DUD_FILDOC
					aLinha[CTDOCTO]  := (cAliasTop)->DUD_DOC
					aLinha[CTSERIE]  := (cAliasTop)->DUD_SERIE
					aLinha[CTREGDES] := Posicione("DUY",1,xFilial("DUY")+(cAliasTop)->DUD_CDRCAL,"DUY_DESCRI")
					aLinha[CTESTADO] := DUY->DUY_EST
					aLinha[CTDATENT] := (cAliasTop)->DTC_DATENT
					aLinha[CTPRZENT] := (cAliasTop)->DT6_PRZENT
					aLinha[CTNOMREM] := Posicione('SA1',1,xFilial('SA1') + (cAliasTop)->(DT6_CLIREM+DT6_LOJREM),'A1_NREDUZ')
					aLinha[CTNOMDES] := Posicione('SA1',1,xFilial('SA1') + (cAliasTop)->(DT6_CLIDES+DT6_LOJDES),'A1_NREDUZ') 
					If !Empty((cAliasTop)->DUH_LOCALI) .And.  (cAliasTop)->DUH_QTDVOL > 0
						aLinha[CTQTDVOL] := (cAliasTop)->DUH_QTDVOL
					Else
						aLinha[CTQTDVOL] := (cAliasTop)->DT6_QTDVOL
					EndIf
					aLinha[CTVOLORI] := (cAliasTop)->DT6_VOLORI
					aLinha[CTPLIQUI] := (cAliasTop)->DT6_PESO
					aLinha[CTPESOM3] := (cAliasTop)->DT6_PESOM3
					aLinha[CTVALMER] := (cAliasTop)->DT6_VALMER
					aLinha[CTVIAGEM] := Iif( nOpcx == 3, .F., (cAliasTop)->DUD_VIAGEM == M->DTQ_VIAGEM )
					aLinha[CTSEQDA7] := ''
					aLinha[CTSOLICI] := ''
					aLinha[CTENDERE] := ''
					aLinha[CTBAIRRO] := ''
					aLinha[CTMUNICI] := ''
					aLinha[CTDATSOL] := CtoD('')
					aLinha[CTHORSOL] := ''
					aLinha[CTDATPRV] := CtoD('')
					aLinha[CTHORPRV] := ''
					aLinha[CTDOCROT] := cRota								//-- Indica a q rota pertence o documento
					aLinha[CTBLQDOC] := (cAliasTop)->DT6_BLQDOC
					//-- Inclui colunas do usuario
					If lTM141COL
						For nCnt := 1 To Len(aUsHDocto)
							AAdd( aLinha, &( aUsHDocto[nCnt,2] ) )
						Next nCnt
					EndIf
					AAdd( aDocto ,AClone(aLinha) )
					(cAliasTop)->(DbSkip())
				EndDo
			Else
				Help("", 1, "TMSA21011",,cFilDoc+cDocto+cSerie,2,18) // "Erro ao localizar movimento de viagem para o documento
			EndIf
			(cAliasTop)->(DbCloseArea())
			DbSelectArea("DT6")
		EndIf
	EndIf
EndDo

DbSelectArea("DT6")

//-- Monta o bLine do listbox
oLbxDocto:SetArray( aDocto )
TMSA140bLi( 2 )
oLbxDocto:Refresh()

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA140Rdp ³ Autor ³ Vitor Raspa          ³ Data ³ 16/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao dos campos do Rodape da tela de Viagem         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA140Rdp()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA141                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA140Rdp()
Local nAux

nVolumes := 0
nPesReal := 0
nPesCub  := 0
nValMerc := 0
nDoctos  := 0

//-- Se chamado pelo painel não é necessário atualizar o objeto
If IsInCallStack("TMSF76Via") .Or. IsInCallStack("TMSF76Crg")
   Return NIL
EndIf
If Len(aDocto) > 0
	For nAux := 1 To Len(aDocto)
		If aDocto[nAux,CTMARCA]
			If (lColeta .And. aDocto[nAux,CTSERTMS] ==  '1') .Or. (!lColeta)
				nDoctos++
				nVolumes += aDocto[nAux,CTQTDVOL]
				nPesReal += aDocto[nAux,CTPLIQUI]
				nPesCub  += aDocto[nAux,CTPESOM3]
				nValMerc += aDocto[nAux,CTVALMER]
			EndIf
		EndIf
	Next
EndIf      

oDoctos:Refresh()
oVolumes:Refresh()
oPesReal:Refresh()
oPesCub:Refresh()
oValMerc:Refresh()

Return( Nil )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MenuD140  ³ Autor ³ Vitor Raspa           ³ Data ³ 23.Mar.07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MenuD140(cTipTra)

Local lTM140ROT  := ExistBlock("TM140ROT")
Local aRotAdic   := {}
Local aMntRotina := {}
Local aCarRotina := {}
Local aMafRotina := {}
Local aFecRotina := {}
Local aEncRotina := {}
Local aGrfRotina := {}
Local aCmpRotina := {}
Local aRotina    := {}
Local lMDFe      := .F.
Local cTMSOpDg	 := SuperGetMv("MV_TMSOPDG", .F., .F.)	// Indica se a integração com Operadoras de Frota está ativa. 0=Não utiliza, 1=Somente Vale-Pedágio e 2=Vale Pedágio e Frota.

//-- Esta abrindo o SX3 devido ao MenuDef, da erro log se tentar acessar alguma tabela via MDI.
DbSelectArea( 'SX3' )
SX3->(dbSetOrder(2))
If SX3->(MsSeek("DTX_TIPMAN")) 
	lMDFe:= .T. 
EndIf

aEncRotina := {	{ STR0077, "TMSA144Sub(7, 3)", 0, 3 },; //"Encerrar"
				{ STR0078, "TMSA144Sub(7, 4)", 0, 4 } } //"Estornar"

aFecRotina := {	{ STR0079, "TMSA144Sub(5, 3)", 0, 3 },; //"Fechar"
				{ STR0078, "TMSA144Sub(5, 5)", 0, 4 } } //"Estornar"

aCmpRotina := {	{ STR0121, "TMSA144Sub(12, 4)",0 ,3 },; //"Monitora"
				{ STR0122, "TMSA144Sub(12, 4)",0 ,4 } } //"Altera"

If lMDFe
	If TableInDic("DLI",.F.) .And. ExistFunc("TMSAE74")
		aMafRotina := {	{ STR0080, "TMSA144Sub(3, 2)", 0, 2 },; //"Visual/Excluir"
						{ STR0091, "TMSA144Sub(3, 3)", 0, 3 },; //"Manifestar"
						{ STR0106, "TMSAE73()",0 ,2  },; //"MDFe"
						{ STR0119, "TMSAE74()",0 ,4 } } //"Tracking eventos MDFe"
	Else
		aMafRotina := {	{ STR0080, "TMSA144Sub(3, 2)", 0, 2 },; //"Visual/Excluir"
						{ STR0091, "TMSA144Sub(3, 3)", 0, 3 },; //"Manifestar"
						{ STR0106, "TMSAE73()",0 ,2  } } //"MDFe"
	EndIf			
Else
	aMafRotina := {	{ STR0080, "TMSA144Sub(3, 2)", 0, 2 },; //"Visual/Excluir"
					{ STR0091, "TMSA144Sub(3, 3)", 0, 3 } } //"Manifestar"
EndIf

//-- Visualizar Percurso
If AliasInDic("DL0") .AND. ExistFunc("TMSA144Per")
	AAdd(aMafRotina, {STR0114,"TMSA144Per()", 0, 2 	})  //"Visu. Percurso"
EndIf

aCarRotina := {	{ STR0002, "TMSA144Sub(2, 2)", 0 ,2 },; //"Visualizar"
				{ STR0081, "TMSA144Sub(2, 3)", 0 ,3 },; //"Carregar"
				{ STR0078, "TMSA144Sub(2, 4)", 0 ,4 } } //"Estornar"

AAdd( aMntRotina, { STR0082, "TMSA144Sub(1, 3)", 0, 3 } ) //"Confirmacao"
AAdd( aMntRotina, { STR0083, aCarRotina        , 0, 2 } ) //"Carregamento"
AAdd( aMntRotina, { STR0084, aMafRotina        , 0, 2 } ) //"Manifesto"

aGrfRotina := {	{ STR0002, "TMSA144Sub(11,2)", 0, 2 },; //"Visualizar"
				{ STR0081, "TMSA144Sub(11,3)", 0, 3 },; //"Carregar"
				{ STR0004, "TMSA144Sub(11,4)", 0, 3 },; //"Alterar"
				{ STR0078, "TMSA144Sub(11,5)", 0, 4 } } //"&Estornar"

If cTipTra == "2"
	AAdd(aMntRotina, { STR0092, "TMSA144Sub(9, 2)", 0, 2 } ) //"Geracao AWB"
EndIf

AAdd( aMntRotina, { STR0085, "TMSA144Sub(4, 2)"	, 0, 2 } ) //"Operacoes"
AAdd( aMntRotina, { STR0086, aFecRotina			, 0, 2 } ) //"Fechamento"
AAdd( aMntRotina, { STR0087, "TMSA144Sub(6, 2)"	, 0, 2 } ) //"Reg.Ocorrencia"
AAdd( aMntRotina, { STR0088, aEncRotina			, 0, 2 } ) //"Encerramento"
If cTipTra == '3' .Or. IsInCallStack("TMSAF76")
	AAdd(aMntRotina, { STR0123, aCmpRotina			,0 ,2 }) //"Compr Entreg"
EndIf
AAdd( aMntRotina, { STR0089, "TMSA144Sub(8, 2)"	, 0, 2 } ) //"Movto.Caixinha"
AAdd( aMntRotina, { STR0105, aGrfRotina			, 0, 2 } ) //"Carregamento Gráfico"

If cTMSOpDg $ "1,2" .And. ExistFunc('TMSA161') 
	AAdd(aMntRotina, { STR0118, 'TMSA161', 0, 2} ) //"Troca de cartão"
EndIf	

aRotina	:= {	{ STR0001, 'AxPesqui'  , 0, 1 },; //'Pesquisar'
				{ STR0002, 'TMSA140Mnt', 0, 2 },; //'Visualizar'
				{ STR0003, 'TMSA140Mnt', 0, 3 },; //'Incluir'
				{ STR0004, 'TMSA140Mnt', 0, 4 },; //'Alterar'
				{ STR0005, 'TMSA140Mnt', 0, 5 },; //'Excluir'
				{ STR0090, aMntRotina  , 0, 6 },; //"Manutencao"
				{ STR0015, 'TMSA140Fbr', 0, 1 } } //'Status'


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. utilizado para adicionar items no Menu da mBrowse       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTM140ROT
	aRotAdic := ExecBlock("TM140ROT",.F.,.F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

AAdd( aRotina ,{ STR0006 ,'TMSA140Leg' ,0 ,2} ) //'Legenda'

Return( aRotina )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tm140MntDc ³ Autor ³ Rafael Souza        ³ Data ³07/11/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o Browse do manutencao de Doctos (TMSA500)     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tm140MntDc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Uso       ³ TMSA140                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Tm140MntDc()

Local aArea 	 := GetArea()
Local cOldFName  := FunName()

SetFunName("TMSA500")

TmsA500()

SetFunName(cOldFName)
RestArea( aArea )

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tmsa140Cor ³ Autor ³ Leandro Paulino     ³ Data ³17/11/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o Browse do manutencao de Doctos (TMSA500)     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tm140MntDc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Uso       ³ TMSA140                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSa140Cor()

Local aCores := {}

AAdd( aCores ,{ "DTQ_STATUS=='1'" ,'BR_VERDE'    } )	//-- Em Aberto
AAdd( aCores ,{ "DTQ_STATUS=='5'" ,'BR_VERMELHO' } )	//-- Fechada
AAdd( aCores ,{ "DTQ_STATUS=='2'" ,'BR_AMARELO'  } )	//-- Em Transito
AAdd( aCores ,{ "DTQ_STATUS=='4'" ,'BR_LARANJA'  } )	//-- Chegada em Filial.
AAdd( aCores ,{ "DTQ_STATUS=='3'" ,'BR_AZUL'     } )	//-- Encerrada
AAdd( aCores ,{ "DTQ_STATUS=='9'" ,'BR_PRETO'    } )	//-- Cancelada

Return aCores
