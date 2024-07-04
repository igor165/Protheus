#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#Include 'TmsA141.ch'

//-- Diretivas indicando as colunas dos documentos da viagem
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
#Define CTSEQDA7		21			//-- Sequencia de Entrega cadastrada no Pontos por Setor
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
#Define CTNUMAGD		36			//-- Número do Agendamento de Entrega.
#Define CTITEAGD		37			//-- Item do Agendamento de Entrega.
#Define CTPRIAGD		38			//-- Prioridade do Agendamento de Entrega.
#Define CTTIPAGD		39			//-- Tipo do Agendamento de Entrega.
#Define CTDATAGD		40			//-- Data do Agendamento de Entrega.
#Define CTPRDAGD		41			//-- Período do Agendamento de Entrega.
#Define CTINIAGD		42			//-- Hora Inicial do Agendamento de Entrega.
#Define CTFIMAGD		43			//-- Hora Final do Agendamento de Entrega.
#Define CTUNITIZ		44			//-- Unitizador
#Define CTCODANA		45			//-- Codigo analitico do unitizador.
//--- Estrutura da Integracao TMS x GFe
#Define CTUFORI      46        //-- UF Origem (Integracao GFE)
#Define CTCDMUNO     47        //-- Cod.Municipio Origem (Integracao GFE)
#Define CTCEPORI     48        //-- Cep Origem (Integracao GFE)
#Define CTUFDES      49        //-- UF Destino (Integracao GFE)
#Define CTCDMUND     50        //-- Cod.Municipio Destino (Integracao GFE)
#Define CTCEPDES     51        //-- Cep Destino (Integracao GFE)
#Define CTTIPVEI     52        //-- Tipo Veiculo (Integracao GFE)
#Define CTCDCLFR     53        //-- Cod.Classificacao Frete (Integracao GFE)
#Define CTCDTPOP     54        //-- Tipo de Operação (Integracao GFE)

#Define CTORIGEM	 55			//-- Origem Carregamento.
//-- Diretivas indicando as colunas para Matriz de Prioridades de Entrega
#define PE_QTDCOL	5

#define PE_CODPRI	1
#define PE_TIPPRI	2
#define PE_DEPRI	3
#define PE_ATEPRI	4
#define PE_CORPRI	5

Static lVgeMod2
Static lTM141GRV := ExistBlock('TM141GRV')
Static lTM141COL := ExistBlock('TM141COL')	//-- Permite ao usuario, incluir colunas nos itens.
Static aRetPrior := {}
Static __oModelCopia := NIL //unitizador
Static oMdlDJMGr := NIL //Modelo de dados DJM - Fornecedores Adicionais
Static lTmsRdpU  := SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho
Static aMemos    := {	{ 'DTQ_CODOBS', 'DTQ_OBS' }, { 'DTQ_CODCAN', 'DTQ_OBSCAN' } }
Static oBrw141	 := nil	
Static lViagem3  := FindFunction("TMSAF60") .And. AliasInDic("DM3")

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA141  ³ Autor ³ Alex Egydio           ³ Data ³15.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Geracao de Viagens de Coleta / Entrega                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = String com expressao inicial para mbrowse          ³±±
±±³          ³ ExpC2 = String com expressao final   para mbrowse          ³±±
±±³          ³ ExpC3 = Tipo de servico TMS                                ³±±
±±³          ³ ExpC4 = Tipo de transporte TMS                             ³±±
±±³          ³ ExpN1 = Indice do DTQ que interage com ExpC1 e ExpC2       ³±±
±±³          ³ ExpN2 = Nr.da opcao de manutencao                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141(cSer141,cTra141,nInd141,nOpc141,lModViag)

Local aCores     := {}
Local aRotAdic   := {}
Local cFilMbrow  := ''
Local lTM141ROT  := ExistBlock("TM141ROT")
Local lTM141FIM  := ExistBlock("TM141FIM")
Local cFilMbrPE  := ''
Local aRet       := {}
Local cProgCall  := ''
Local nAux		 := 1 
Local aStatus	 := {}
Local nPos       := 0 

Local cFunction := ProcName()

Private cFiltro    := ""
Private aIndex     := {}
Private bFiltraBrw
DEFAULT cSer141	   := ' '
DEFAULT cTra141	   := ' '
DEFAULT nInd141	   := 3
DEFAULT nOpc141	   := 0
DEFAULT lModViag   := .F.

If Type( "cCadastro" ) == "U"
	Private cCadastro  := Iif(cSer141== '1',STR0034,STR0035) //"Geracao de Viagens de Coleta"###"Geracao de Viagens de Entrega"
EndIf

Private cSerTms	   := cSer141
Private cTipTra	   := cTra141

//-- Pergunte
Private nRotPor	   := 0
Private nCarreg	   := 0
Private nTipVia	   := 0
Private nRotGen	   := 0
Private lPagSald   := .F.
Private cRotaDe	   := ''
Private cRotaAte   := ''
Private cCdrOriDe  := ''
Private cCdrOriAte := ''
Private cCdrDesDe  := ''
Private cCdrDesAte := ''
Private lCdrOri    := .F.

If lModViag
	lVgeMod2:= .F.
EndIf

Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction) ,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PROTEÇÃO CONTRA VERSÃO INCOMPATÍVEL NO TMSA144               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ExistFunc("TMSA144Ver") .Or. TMSA144Ver() < '12.1.17'
	Final("TMSA144.PRW desatualizado! Atualize p/ 10/Out/2017 ou mais recente!")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PROTEÇÃO CONTRA VERSÃO INCOMPATÍVEL NO TMSC080               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ExistFunc("TMSC080Ver") .Or. TMSC080Ver() < '12.1.17'
	Final("TMSC080.PRW desatualizado! Atualize p/ 10/Out/2017 ou mais recente!")
EndIf

SetKey (VK_F12,{|a,b| AcessaPerg("TMB144",.T.)})

If Type("aRotina") == "U"
	Private aRotina := MenuD141(cSerTms)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. utilizado para adicionar items no Menu da mBrowse       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTM141ROT
	aRotAdic := ExecBlock("TM141ROT",.F.,.F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

aStatus		:= TMSA140Leg( ,.F.)

AAdd(aRotina, { STR0033 ,'TMSA140Leg',0,2,0,.F.})		//'Legenda'
AAdd(aCores,{"DTQ_STATUS=='1'",'BR_VERDE'		})		//-- Em Aberto
AAdd(aCores,{"DTQ_STATUS=='5'",'BR_VERMELHO'	})		//-- Fechada
AAdd(aCores,{"DTQ_STATUS=='2'",'BR_AMARELO'		})		//-- Em Transito
AAdd(aCores,{"DTQ_STATUS=='4'",'BR_LARANJA'		})		//-- Chegada Em Filial
AAdd(aCores,{"DTQ_STATUS=='3'",'BR_AZUL'		})		//-- Encerrada
AAdd(aCores,{"DTQ_STATUS=='9'",'BR_PRETO'		})		//-- Cancelada

For nAux := 1 To Len(aCores)	
	nPos := aScan( aStatus , {|x| x[1] == aCores[nAux,2]})
	If nPos > 0 
		Aadd(aCores[nAux] , ASTATUS[nPos,2])
	EndIf
	
Next nAux

DbSelectArea('DTQ')
DbSetOrder( nInd141 )
cFilMbrow := "DTQ_FILIAL = '"+xFilial("DTQ") + "' AND DTQ_SERTMS = '" + cSerTms + "' AND DTQ_TIPTRA = '" + cTipTra + "'"

If ExistBlock("TM141FIL")
	cFilMbrPE := ExecBlock("TM141FIL",.F.,.F.)
	If(Valtype(cFilMbrPE) = "C") .And. !Empty(cFilMbrPE)
		cFilMbrow+=  " " + cFilMbrPE
	EndIf
EndIf

oBrw141		:= Nil 
cFilMbrow	:= StrFiltro(cFilMbrow)

If nOpc141 > 0
	//-- Viagem jah deve estar posicionada
	aRet := TMSA141Mnt( 'DTQ', Recno(), nOpc141 )
Else
	//Determina qual a rotina que deve ter a restricao de privilegios validada no menu.
	If 		cSer141 == StrZero(1,Len(DC5->DC5_SERTMS))	//COLETA
		If 		cTra141 == StrZero(1,Len(DC5->DC5_TIPTRA))//RODOVIARIA
				cProgCall := 'TMSA141A'
		ElseIf cTra141 == StrZero(2,Len(DC5->DC5_TIPTRA))//AEREA
				cProgCall := 'TMSA141B'
		EndIf
	ElseIf cSer141 == StrZero(3,Len(DC5->DC5_SERTMS))	//ENTREGA

		If 		cTra141 == StrZero(1,Len(DC5->DC5_TIPTRA))//RODOVIARIA
				cProgCall := 'TMSA141C'
		ElseIf cTra141 == StrZero(2,Len(DC5->DC5_TIPTRA))//AEREA
				cProgCall := 'TMSA141D'
		ElseIf cTra141 == StrZero(3,Len(DC5->DC5_TIPTRA))//FLUVIAL
				cProgCall := 'TMSA141E'
		ElseIf cTra141 == StrZero(4,Len(DC5->DC5_TIPTRA))//INTERNACIONAL
				cProgCall := 'TMSA140E'
		EndIf
	EndIf

	oBrw141 := FWMBrowse():New()
	oBrw141:SetAlias("DTQ")
	oBrw141:SetFilterDefault(cFilMbrow)
	oBrw141:SetDescription( cCadastro ) // Cadastro de Prioridades 

	For nAux := 1 To Len(aCores)
		oBrw141:AddLegend( aCores[nAux,1] , aCores[nAux,2]  , aCores[nAux,3] )	
	Next nAux 

	oBrw141:Activate()

EndIf

SetKey( VK_F12, Nil )

//-- Devolve os indices padroes do SIGA
RetIndex('DTQ')

If lTM141FIM
	ExecBlock("TM141FIM",.F.,.F.)
EndIf

Return Aclone(aRet)


//-------------------------------------------------------------------
/*StrFiltro

Rotina para tratar a expressão do filtro
                                                                                        
@author  Caio Murakami
@since   28/10/2019
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function StrFiltro(cFiltro)

cFiltro		:= StrTran(Upper(cFiltro),"AND" ,".And.")

Return cFiltro

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA141Mnt³ Autor ³ Alex Egydio           ³ Data ³15.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao de Viagens                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141Mnt( cAlias, nReg, nOpcx )
//-- Variaveis p/controle generico
Local aAreaAnt		:= GetArea()
Local aAreaDTQ		:= DTQ->(GetArea())
Local aSx3Box		:= {}
Local cSerOld		:= cSerTms
Local cTraOld		:= cTipTra
Local lNSequen		:= .F.
Local nSeek			:= 0
Local xRet			:= Nil
//-- Dialog
Local cHDlgEsp		:= ''
//-- EnchoiceBar
Local aButtons		:= {}
Local aUsButtons	:= {}
Local nOpca			:= 0
//-- Listbox de Rota
Local aHRota		:= {}
Local cLbx1			:= ''
//-- ListBox de Zona
Local aHZona		:= {}
Local cLbx2			:= ''
//-- ListBox de Setor
Local aHSetor		:= {}
Local cLbx3			:= ''
//-- Listbox de Documento
Local aHDocto		:= {}

//-- Controle de dimensoes de objetos
Local aSize		  	:= {}
Local aObjects	  	:= {}
Local aInfo		  	:= {}
Local aPosObjH	  	:= {}
Local aPosObjV	 	:= {}
Local aTipVei    	:= {}
Local aDoctosMrk 	:= {}
Local cMay       	:= ""
Local cFilOri    	:= ""
Local cViagem    	:= ""
Local nCnt       	:= 0
Local nCount     	:= 0
Local nPosDTQ    	:= 0
Local lRet       	:= .T.
Local aPosicao   	:= {}
Local oPanel
Local lContVei 		:= GetMv("MV_CONTVEI")
Local lMV_EmViag   	:= GetMV('MV_EMVIAG',,.F.)
Local lAgdEntr   	:= Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)    //-- Agendamento de Entrega.
Local cSerPar   	:= ""
Local cCodUser   	:= RetCodUsr()
Local nCntFor1  	:= 0
Local nPos       	:= 0

Local lTercRbq   := DTR->(ColumnPos("DTR_CODRB3")) > 0

Local cMV_TMSRRE 	:= SuperGetMv("MV_TMSRRE",.F.,"") //1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
//--Gestão de demandas
Local lMVITMSDMD    := SuperGetMv("MV_ITMSDMD",,.F.)
Local aRetExVgDm    := {}
//--
//-- Variaveis p/controle generico
Private cRotGen		:= ''
Private cGrpProd	:= ''
Private aGrpProd    := {}
Private aBkpDocto	:= {}
Private _cCdrOri	:= PadR(GetMv('MV_CDRORI'),Len(DA8->DA8_CDRORI))
Private lColeta		:= .F.
Private lLocaliz	:= GetMv('MV_LOCALIZ') == 'S'
Private lContDCA  	:= GetMv('MV_CONTDCA',,.F.)
Private lTmsA1411	:= ExistBlock( 'TMSA1411' ) //-- Permite ao usuario, incluir botoes na enchoicebar.
Private aUsHDocto 	:= {}
Private lDoctoEnd	:= .F.
Private oNoMarked	:= LoadBitmap( GetResources(),'LBNO'			)
Private oMarked		:= LoadBitmap( GetResources(),'LBOK'			)
Private oVerde		:= LoadBitmap( GetResources(),'BR_VERDE'		)
Private oAmarelo  	:= LoadBitmap( GetResources(),'BR_AMARELO'		)
Private oVermelho 	:= LoadBitmap( GetResources(),'BR_VERMELHO'		)
Private oAzul     	:= LoadBitmap( GetResources(),'BR_AZUL'			)
Private oPreto		:= LoadBitmap( GetResources(),'BR_PRETO'		)
//-- Dialog
Private oDlgEsp
//-- Listbox de Rota
Private aRota		:= {}
Private oLbxRota
//-- Listbox de Zona
Private aZona		:= {}
Private aAllZona	:= {}
Private oLbxZona
//-- Listbox de Setor
Private aSetor		:= {}
Private aAllSetor	:= {}
Private oLbxSetor
//-- Listbox de Documento
Private aDocto		:= {}
Private aAllDocto	:= {}
Private oLbxDocto
//-- Checkbox
Private oAllMark
Private lAllMark
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura do Array aCompViag (Complemento de Viagem):             ³
//³ aCompViag[1] - aHeader Complemento de Viagem                      ³
//³ aCompViag[2] - aCols Complemento de Viagem                        ³
//³ aCompViag[3] - aHeader Auxiliar Getdados de Motoristas da Viagem  ³
//³ aCompViag[4] - Array contendo os Motoristas da Viagem             ³
//³ aCompViag[5] - aHeader Auxiliar Getdados de Ajudantes da Viagem   ³
//³ aCompViag[6] - Array contendo os Ajudantes da Viagem              ³
//³ aCompViag[7] - aHeader Auxiliar Getdados de Lacres de veiculos    ³
//³ aCompViag[8] - Array contendo os Lacres dos veiculos              ³
//³ aCompViag[9] - aHeader Auxiliar Getdados de Adiantamentos         ³
//³ aCompViag[10]- Array contendo os Adiantamentos da Viagem          ³
//³ aCompViag[11]- Data/Hora Inicial e Final da Viagem                ³
//³ aCompViag[12]- Array contendo os componentes com 'Valor Informado'³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCompViag 	:= {}
//-- Identifica se as funcionalidades de Carga Fechada estao ativas.
Private lTmsCFec  	:= TmsCFec()
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
Private cSerAdi     := ''

If Type( "cCadastro" ) == "U"
	Private cCadastro  := Iif(cSerTms== '1',STR0034,STR0035) //"Geracao de Viagens de Coleta"###"Geracao de Viagens de Entrega"
EndIf

Pergunte("TMB144",.F.)
If Type("MV_PAR02") == "C"
	cSerPar := mv_par02
EndIf

If Type('aRetRbq') == 'U'
	Private aRetRbq := {}
EndIf

//-- Verifica se o registro n„o esta em uso por outra estacao.
If nOpcx == 4 .Or. nOpcx == 5//-- 4=Alteracao ; 5=Exclusao
	If !SoftLock("DTQ")
		Return( Nil )
	EndIf
EndIf

If	Type('nRotPor')=='U'
	nRotPor	:= 0
	nCarreg	:= 0
	nTipVia	:= 0
	nRotGen	:= 0
	lPagSald := .F.
EndIf
If Type('aIndex') <> "U"
	//Limpa o filtro no DTQ para que o usuario possa trabalhar com viagem de todos os tipos de transporte
	EndFilBrw("DTQ",aIndex)
EndIf
cRotaDe	   := Space(Len(DA8->DA8_COD))
cRotaAte   := Replicate('Z',Len(DA8->DA8_COD))
cCdrOriDe  := Space(Len(DT6->DT6_CDRORI))
cCdrOriAte := Replicate('Z',Len(DT6->DT6_CDRORI))
cCdrDesDe  := Space(Len(DT6->DT6_CDRDES))
cCdrDesAte := Replicate('Z',Len(DT6->DT6_CDRDES))

AAdd( aPosicao, CTMARCA  )
AAdd( aPosicao, CTFILDOC )
AAdd( aPosicao, CTDOCTO  )
AAdd( aPosicao, CTSERIE  )

RegToMemory(cAlias,nOpcx==3)

If nOpcx != 3
	nTipVia := Val(M->DTQ_TIPVIA)
EndIf

// Ajusta SXE e SXF caso estejam corrompidos.
If nOpcx == 3
	cFilOri := M->DTQ_FILORI
	cViagem := M->DTQ_VIAGEM
	cMay    := AllTrim(xFilial('DTQ'))+cFilOri+cViagem
	cSerAdi := cSerPar
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
Else
   cSerTms := DTQ->DTQ_SERTMS
   cTipTra := DTQ->DTQ_TIPTRA
	cSerAdi := DTQ->DTQ_SERADI
  	If nOpcx == 4 .And. (Empty(cSerAdi) .Or. cSerAdi == '0')
  		cSerAdi := cSerPar
	EndIf
EndIf

cHDlgEsp := Subs(aRotina[ nOpcx, 1 ],IIF(Subs(aRotina[nOpcx,1],1,1)=="&",2,1)) + ' - ' + 'Viagem ' + M->DTQ_VIAGEM + ' - ' + AllTrim( TmsValField('cSerTms',.F.) ) + ' - '
//-- Documentos no aeroporto
If	nOpcx == 3
	M->DTQ_SERTMS := cSerTms
	M->DTQ_TIPTRA := cTipTra
EndIf

DUD->(DbSetOrder(2))
If	DUD->(MsSeek(xFilial('DUD')+M->DTQ_FILORI+M->DTQ_VIAGEM))
	If	M->DTQ_SERTMS != DUD->DUD_SERTMS
		cHDlgEsp += STR0036 //"Aeroporto"
	Else
		cHDlgEsp += AllTrim( TmsValField('cTipTra',.F.) )
	EndIf
Else
	If	nRotPor == 2
		If	cSerTms == StrZero(1,Len(DC5->DC5_SERTMS))
			cHDlgEsp += STR0036 //"Aeroporto"
		Else
			cHDlgEsp += AllTrim( TmsValField('cTipTra',.F.) )
		EndIf
		cSerTms := StrZero(3,Len(DC5->DC5_SERTMS))
		cTipTra := StrZero(2,Len(DC5->DC5_TIPTRA))
	Else
		cHDlgEsp += AllTrim( TmsValField('cTipTra',.F.) )
	EndIf
EndIf

If nOpcx == 2// -- Se visualizacao
	TmsA141Par(.F.,nOpcx)
ElseIf nOpcx == 3//-- Se inclusao

	If	Empty( _cCdrOri )
		Help(' ', 1, 'TMSA14002')	//-- O parametro MV_CDRORI esta vazio !
		RestArea(aAreaDTQ)
		RestArea(aAreaAnt)
		cSerTms := cSerOld
		cTipTra := cTraOld
		lRet    := .F.
	EndIf

	//-- Informacoes para filtragem na Entrega
	If lRet .And. !TmsA141Par(.T.,nOpcx)
		lRet := .F.
	EndIf

	DTQ->( DbSetOrder( 2 ) )
	If	lRet .And. DTQ->( MsSeek( xFilial('DTQ') + M->DTQ_FILORI + M->DTQ_VIAGEM, .F. ) )
		Help(' ', 1, 'TMSA14010',,STR0037 + M->DTQ_FILORI + STR0038 + M->DTQ_VIAGEM,4,1)	//-- Viagem ja cadastrada. (DTQ)###"Fil.Origem : "### Viagem :
		RestArea(aAreaDTQ)
		RestArea(aAreaAnt)
		cSerTms := cSerOld
		cTipTra := cTraOld
		lRet    := .F.
	EndIf
	RestArea( aAreaDTQ )

	//-- Se encontrar e selecionar grupos de produtos, a viagem sera montada somente com produtos que pertencem a estes
	//-- grupos
	If lRet .And. (nTipVia == 1 .OR. nTipVia == 3)
		xRet := TmsGrpProd()
		If	ValType( xRet ) == 'L'
			RestArea(aAreaDTQ)
			RestArea(aAreaAnt)
			cSerTms := cSerOld
			cTipTra := cTraOld
			lRet    := .F.
		Else
			aGrpProd := AClone( xRet )
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
		RestArea(aAreaDTQ)
		Return( { nOpca, "", "" } )
	EndIf

ElseIf nOpcx == 4

	//--Verifica se existe um contrato aberto para a viagem junto a Operadora de Frota
	//--Existindo este contrato tentará fazer a exclusão do mesmo
	DTR->(dbSetOrder(1))
	If 	DTR->(MsSeek(FwxFilial('DTR')+M->DTQ_FILORI+M->DTQ_VIAGEM))  .And. DTR->DTR_CODOPE == '01' .And. ;
		DTR->(ColumnPos('DTR_PRCTRA')) .And. !Empty(DTR->DTR_PRCTRA) .And. ;
		DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS))
		If !TmsVldOper(nOpcX, DTR->DTR_FILORI, DTR->DTR_VIAGEM, DTR->DTR_PRCTRA, DTR->DTR_CODOPE)
			Return(.F.)
		EndIf
	EndIf

	//-- Somente permite manutencoes em viagens em aberto ou em transito
	If	! TMSChkViag(M->DTQ_FILORI,M->DTQ_VIAGEM,.T.,.F.,.F.,.T.,.F.,.F.,.F.,,,,.F.,,,,,, cFilAnt, .T.)
		RestArea(aAreaDTQ)
		RestArea(aAreaAnt)
		cSerTms := cSerOld
		cTipTra := cTraOld

		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea(aAreaDTQ)
		MsUnLockAll()
		Return( { nOpca, "", "" } )
	EndIf
	RestArea( aAreaDTQ )

	nTipVia := Val( M->DTQ_TIPVIA )

	//-- Informacoes para filtragem na Entrega
	If !TmsA141Par(.T.,nOpcx)

		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea(aAreaDTQ)
		MsUnLockAll()
		Return( { nOpca, "", "" } )
	EndIf
//-- Se exclusao
ElseIf nOpcx == 5
	//--Verifica se existe um contrato aberto para a viagem junto a Operadora de Frota
	//--Existindo este contrato tentará fazer a exclusão do mesmo
	DTR->(dbSetOrder(1))
	If 	DTR->(MsSeek(FwxFilial('DTR')+M->DTQ_FILORI+M->DTQ_VIAGEM))  .And. DTR->DTR_CODOPE == '01' .And. ;
		DTR->(ColumnPos('DTR_PRCTRA')) .And. !Empty(DTR->DTR_PRCTRA) .And. ;
		DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS))
		If !TmsVldOper(nOpcx, DTR->DTR_FILORI, DTR->DTR_VIAGEM, DTR->DTR_PRCTRA, DTR->DTR_CODOPE)
			Return(.F.)
		EndIf
	EndIf
	//-- Valida se a viagem de coleta esta em transito. As outras validacoes sera executa na TMSChkViag().
	If M->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_STATUS)) .And. ; //-- Coleta
		M->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) //-- Em Transito
		Help(' ', 1, 'TMSXFUNA03') //-- Viagem nao esta em Aberto

		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea(aAreaDTQ)
		MsUnLockAll()
		Return( Nil )
	EndIf
	//-- Somente permite manutencoes em viagens em aberto ou em transito
	If	! TMSChkViag(M->DTQ_FILORI,M->DTQ_VIAGEM,,.F.,.T.,,,,,,,,.F.,.F.,,.T.,,, cFilAnt, .T.)
		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea(aAreaDTQ)
		RestArea(aAreaAnt)
		cSerTms := cSerOld
		cTipTra := cTraOld
		MsUnLockAll()
		Return( { nOpca, "", "" } )
	EndIf
	RestArea( aAreaDTQ )
	//-- Se houver documentos carregados, a exclusao da viagem sera permitida apos o
	//-- estorno do carregamento
	DTA->( DbSetOrder( 2 ) )
	If	DTA->( MsSeek( xFilial('DTA') + M->DTQ_FILORI + M->DTQ_VIAGEM, .F. ) )
		Help(' ', 1, 'TMSA14009',,STR0037 + M->DTQ_FILORI + STR0038 + M->DTQ_VIAGEM,4,1)	//-- Ha documentos carregados nesta viagem.###"Fil.Origem : "###" Viagem : "

		If Type('bFiltraBrw') <> 'U'
			Eval(bFiltraBrw)
		EndIf
		RestArea(aAreaDTQ)
		RestArea(aAreaAnt)
		cSerTms := cSerOld
		cTipTra := cTraOld
		MsUnLockAll()
		Return( { nOpca, "", "" } )
	EndIf
	//Verifica se há integração com gestão de demandas e se as coletas vinculadas podem ser canceladas.
	DbSelectArea("DF8")
	DF8->( DbSetOrder( 2 ) ) //-- DF8_FILIAL+DF8_FILORI+DF8_VIAGEM
	If DbSeek(xFilial("DF8") + M->DTQ_FILORI + M->DTQ_VIAGEM)
		If lMVITMSDMD .And. DF8->(ColumnPos('DF8_PLNDMD')) > 0 .And. FindFunction('TMExVgDmd') .And. !IsInCallStack("TMSA146EST")
			aRetExVgDm := TMExVgDmd(DF8->DF8_PLNDMD, 1)
			If !aRetExVgDm[1]
				Help(,,'HELP',, aRetExVgDm[2],1,0)	//Coleta XX/XXXXX/XXX não pode ser cancelada.
				Return( { nOpca, "", "" } )
			EndIf
		EndIf
	EndIf
	
EndIf

aSx3Box	:= RetSx3Box( Posicione('SX3', 2, 'DTQ_TIPVIA', 'X3CBox()' ),,, 1 )
If ( nSeek := Ascan( aSx3Box, { |x| x[ 2 ] == StrZero( nTipVia, Len(DTQ->DTQ_TIPVIA) ) } ) ) > 0
	cHDlgEsp += ' - ' +	AllTrim( aSx3Box[ nSeek, 3 ] )
EndIf

If !Empty(cSerAdi) .And. cSerAdi != '0'
	cHDlgEsp += ' - Srv.Adicional de '+AllTrim( TmsValField('cSerAdi',.F.) )
EndIf

cHDlgEsp += '.'

//-- Viagem de coleta / entrega habilita digitacao da sequencia.
lNSequen:= ( cSerTms != StrZero( 2, Len( DC5->DC5_SERTMS ) ) )
//-- Viagem de coleta
lColeta := ( cSerTms == StrZero( 1, Len( DC5->DC5_SERTMS ) ) )
cRotGen := Iif(lColeta,GetMv('MV_ROTGCOL',,''),GetMv('MV_ROTGENT',,'')) //Rota generica para coleta //Rota generica para entreg

//-- Inclui colunas do usuario
If lTM141COL
	If ValType( aUsHDocto := ExecBlock( 'TM141COL', .F., .F. ) ) <> 'A'
		aUsHDocto := {}
	EndIf
EndIf

CursorWait()
MsgRun(STR0039,,{|| Tms141RotI(nOpcx) })  // "Aguarde, verificando documentos"
CursorArrow()

//-- Inicializa os vetores
If Empty(aRota)
	Help(' ', 1, 'TMSA14003')	//-- Nenhum documento selecionado !
	If	__lSX8
		RollBackSX8()
	EndIf

	If Type('bFiltraBrw') <> 'U'
		Eval(bFiltraBrw)
	EndIf
	RestArea(aAreaDTQ)
	MsUnLockAll()
	Return( { nOpca, "", "" } )
EndIf

If nOpcx == 3
	//-- Inicializa o vetor aZona
	TmsA141Zer(2)
	//-- Inicializa o vetor aSetor
	TmsA141Zer(3)
	//-- Inicializa o vetor aDocto
	TmsA141Zer(4)
EndIf

If lColeta .And. lTmsCFec
	//-- Quando for Carga Fechada, passa dois novos parametros para o Complemento de Viagem( aTipVei e aDoctosMrk ).
	AAdd(aButtons,{'CARGA',{||nSeek:=TmsA140ChkRot('1',,.T.), Tmsa141TpVei(@aTipVei,@aDoctosMrk), Iif(nSeek > 0 ,(aCompViag := TmsA240Mnt( , , nOpcx, M->DTQ_FILORI, M->DTQ_VIAGEM, aCompViag,;
	aRota[nSeek,2],cSerTms,cTipTra,@M->DTQ_OBS,aTipVei, aDoctosMrk,,nTipVia,,aDocto,aPosicao)),.F.)}, STR0008, STR0020 }) //'Complemento de Viagem'
Else
	AAdd(aButtons,{'CARGA',{||nSeek:=TmsA140ChkRot('1',,.T.),Iif(nSeek > 0,(aCompViag := TmsA240Mnt( , , nOpcx, M->DTQ_FILORI, M->DTQ_VIAGEM, aCompViag,;
	aRota[nSeek,2],cSerTms,cTipTra,@M->DTQ_OBS,,,,nTipVia,,aDocto,aPosicao)),.F.)}, STR0008, STR0020 }) //'Complemento de Viagem'
EndIf

If nOpcx != 5
	If nOpcx == 2 .And. M->DTQ_STATUS == StrZero( 9, Len( DTQ->DTQ_STATUS ) )
		//-- Se consultar uma viagem cancelada, apresenta a observacao do cancelamento.
		AAdd(aButtons,	{'EDIT',{|| TMSA140Obs(5) }, STR0023, STR0019 }) //'Observacao do Cancelamento'
   	EndIf
	AAdd(aButtons,	{'EDIT',{|| TMSA140Obs(nOpcx) }, STR0026 , STR0007 }) //'Observacao'
	AAdd(aButtons,	{'EDIT',{|| TMSA140Id(nOpcx) }, STR0084 ,STR0084  }) //'Id.Ope.Vge.'
EndIf

If lNSequen .And. (nOpcx == 3 .Or. nOpcx == 4)
	AAdd(aButtons,	{'CARGASEQ',{|| TmsA141Seq(nOpcx) }, STR0025 , STR0005 }) //'Sequencia de Viagem'
EndIf

AAdd(aButtons,	{'PESQUISA', {|| TmsA141Psq() }, STR0024 })   	//'Pesquisa'
AAdd(aButtons,	{'NOCHECKED',{|| TMSA140Leg(	{	{'BR_VERDE'		, STR0009 },; 		//'Em Aberto'
																{'BR_VERMELHO'	, STR0010 },; 		//'Em Carregado'
																{'BR_AMARELO'	, STR0022 },; 		//'Em Transito'
																{'BR_AZUL'		, STR0021 },; 		//'Encerrado'
																{'BR_PRETO'		, STR0006 }})}, STR0011, STR0018 }) //'Cancelado' ### 'Legenda de Documentos'
If lAgdEntr .And. cSerTMS == "3"
	AAdd(aButtons,	{'AGDENTR',{|| TMSA146Leg("A")}, STR0080 }) //"Leg. Agd. Entrega (A)"
EndIf
AAdd(aButtons, {'BMPVISUAL',{||TmsA141Lim()}, STR0017, STR0017	}) //'Limite...'
AAdd(aButtons, {'WEB',{||TmsA141VRt()},STR0016, STR0016 		}) //'Rota...'
AAdd(aButtons, {'DEVOLNF',{||TmsA141Dco()}, STR0015, STR0014 	}) //'Documento...'

//--
If AliasIndic('DJM') //Caso nao exista o Alias DJM - Fornecedores Adicionais Viagem
	AAdd(aButtons, {'DJM', {|| A141VwDJM(nOpcx)}, STR0100})
EndIf
If lTmsCFec .And. lColeta
	//-- Botão para visualizar o Agendamento.
	AAdd(aButtons, {'PEDIDO',{|| Tmsa141Age()}, STR0003, STR0004 }) //'Agendamento'
EndIf

AAdd(aButtons,	{'EDIT',{|| TmsA141Prd(aDocto[oLbxDocto:nAt,CTFILDOC],aDocto[oLbxDocto:nAt,CTDOCTO],aDocto[oLbxDocto:nAt,CTSERIE]) }, STR0013 , STR0012 }) //'Produtos do Documento'

If nOpcx == 2 .And. AliasInDic('DFM')
	AAdd(aButtons,{'CUSTOS'  ,{|| TM99CViag() } , STR0093 , STR0093 }) // Custo da Viagem
EndIf
//-- Controle de permissao de acesso a manut. de doctos
If TmsAcesso(,"TMSA500",cCodUser,,.F.)
	If !lColeta .And. ( nOpcx == 3 .Or. nOpcx == 4 )
   		//-- Botao para realizar manutencao no documento
   		AAdd(aButtons, {'PEDIDO', {||Tm141MntDc()}, STR0083 ,STR0083  }) //-- Doctos. , Manut. Doctos.
	EndIf
EndIf

//-- RRE - Check List da Viagem
If "3" $ cMV_TMSRRE .And. nOpcx == 2 .And. FindFunction('TMSA144RRE') //cMV_TMSRRE $ ("2|3")  .And. nOpcx == 2 .And. FindFunction('TMSA144RRE')
	AAdd(aButtons, {'RRE',{|| TMSA144RRE() },STR0091, STR0091 })  //RRE - Check List
EndIf
//-- Inclui botoes do usuario
If lTmsA1411
	If ValType( aUsButtons := ExecBlock( 'TMSA1411', .F., .F. ) ) == 'A'
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf
//-- Cabecalho do listbox de rota
AAdd( aHRota, ' ' )
AAdd( aHRota, Posicione('SX3', 2, 'DA8_COD'		, 'X3Titulo()') )
AAdd( aHRota, Posicione('SX3', 2, 'DA8_DESC'	, 'X3Titulo()') )
AAdd( aHRota, Posicione('SX3', 2, 'DA8_DESROT'	, 'X3Titulo()') )
AAdd( aHRota, Posicione('SX3', 2, 'DT6_QTDVOL'	, 'X3Titulo()') )
AAdd( aHRota, Posicione('SX3', 2, 'DT6_PESO'	, 'X3Titulo()') )
AAdd( aHRota, Posicione('SX3', 2, 'DT6_PESOM3'	, 'X3Titulo()') )
AAdd( aHRota, Posicione('SX3', 2, 'DT6_VALMER'	, 'X3Titulo()') )
//-- Cabecalho do listbox de zona
AAdd( aHZona, ' ' )
AAdd( aHZona, Posicione('SX3', 2, 'DA5_COD'		, 'X3Titulo()') )
AAdd( aHZona, Posicione('SX3', 2, 'DA5_DESC'	, 'X3Titulo()') )
AAdd( aHZona, Posicione('SX3', 2, 'DA8_COD'		, 'X3Titulo()') )
//-- Cabecalho do listbox de setor
AAdd( aHSetor, ' ' )
AAdd( aHSetor, Posicione('SX3', 2, 'DA6_ROTA'	, 'X3Titulo()') )
AAdd( aHSetor, Posicione('SX3', 2, 'DA6_REF'	, 'X3Titulo()') )
AAdd( aHSetor, Posicione('SX3', 2, 'DA8_COD'	, 'X3Titulo()') )
AAdd( aHSetor, Posicione('SX3', 2, 'DA5_COD'	, 'X3Titulo()') )
//-- Cabecalho do listbox de documentos
If	lColeta
	AAdd( aHDocto, ' ' )
	AAdd( aHDocto, ' ' )
	AAdd( aHDocto, Posicione('SX3', 2, 'DUD_SEQUEN'	, 'X3Titulo()') )
	If lTmsCFec
		//-- Exibe as colunas Agendamento e Item no cabecalho do listbox de documentos.
		AAdd( aHDocto, Posicione('SX3', 2, 'DF1_NUMAGE'	, 'X3Titulo()') )
		AAdd( aHDocto, Posicione('SX3', 2, 'DF1_ITEAGE'	, 'X3Titulo()') )
		AAdd( aHDocto, Posicione('SX3', 2, 'DC5_SERTMS'	, 'X3Titulo()') )
	EndIf
	AAdd( aHDocto, Posicione('SX3', 2, 'DUD_FILDOC'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DUD_DOC'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DUD_SERIE'	, 'X3Titulo()') )
	If lTmsCFec
		//-- Atera o titulo para Solicitante / Destinatario.
		AAdd( aHDocto, Alltrim(Posicione('SX3', 2, 'DT5_NOME'	, 'X3Titulo()')) + " / " + Posicione('SX3', 2, 'DF1_CLIDES', 'X3Titulo()') )
	Else
		AAdd( aHDocto, Posicione('SX3', 2, 'DT5_NOME'	, 'X3Titulo()') )
	EndIf
	AAdd( aHDocto, Posicione('SX3', 2, 'DUE_END'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DUE_BAIRRO'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DUE_MUN'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DT5_DATSOL'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DT5_HORSOL'	, 'X3Titulo()') )
	If lTmsCFec
		AAdd( aHDocto, STR0040 ) //"Data Prev."
		AAdd( aHDocto, STR0041 ) //"Hora Prev."
	Else
		AAdd( aHDocto, Posicione('SX3', 2, 'DT5_DATPRV'	, 'X3Titulo()') )
		AAdd( aHDocto, Posicione('SX3', 2, 'DT5_HORPRV'	, 'X3Titulo()') )
	EndIf
	AAdd( aHDocto, Posicione('SX3', 2, 'DT6_QTDVOL'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DT6_PESO'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DT6_PESOM3'	, 'X3Titulo()') )
Else
	AAdd( aHDocto, ' ' )
	//-- Agendamento de Entrega
	If lAgdEntr .And. cSerTms == '3'
		aAdd( aHDocto, 'A'                     )
		AAdd( aHDocto, ' '                     )
		aAdd( aHDocto, RetTitle('DYD_TIPAGD' ) )
		aAdd( aHDocto, RetTitle('DYD_DATAGD' ) )
		aAdd( aHDocto, RetTitle('DYD_PRDAGD' ) )
		aAdd( aHDocto, RetTitle('DYD_INIAGD' ) )
		aAdd( aHDocto, RetTitle('DYD_FIMAGD' ) )
	Else
		AAdd( aHDocto, ' ' )
	EndIf
	//--
	AAdd( aHDocto, Posicione('SX3', 2, 'DUD_SEQUEN'	, 'X3Titulo()') )
	If	lLocaliz
		AAdd( aHDocto, Posicione('SX3', 2, 'DUH_LOCAL'	, 'X3Titulo()') )
		AAdd( aHDocto, Posicione('SX3', 2, 'DUH_LOCALI'	, 'X3Titulo()') )
	EndIf
	AAdd( aHDocto, Posicione('SX3', 2, 'DUD_FILDOC'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DUD_DOC'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DUD_SERIE'	, 'X3Titulo()') )
	If cSerAdi == '1'
		AAdd( aHDocto, Posicione('SX3', 2, 'DUD_SERTMS'	, 'X3Titulo()') )
	EndIf
	AAdd( aHDocto, Posicione('SX3', 2, 'DTC_NOMREM'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DTC_NOMDES'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DUE_END'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DUE_BAIRRO'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DUE_MUN'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DT6_DATEMI'	, 'X3Titulo()') )
	If cSerAdi == '1'
	   AAdd( aHDocto, Posicione('SX3', 2, 'DT6_PRZENT'	, 'X3Titulo()') + '\ ' +  Posicione('SX3', 2, 'DT5_DATPRV'	, 'X3Titulo()')  )
	Else
		AAdd( aHDocto, Posicione('SX3', 2, 'DT6_PRZENT'	, 'X3Titulo()') )
	EndIf
	AAdd( aHDocto, Posicione('SX3', 2, 'DT6_QTDVOL'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DT6_VOLORI'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DT6_PESO'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DT6_PESOM3'	, 'X3Titulo()') )
	AAdd( aHDocto, Posicione('SX3', 2, 'DT6_VALMER'	, 'X3Titulo()') )
EndIf

//-- Inclui colunas do usuario
If lTM141COL
	For nCnt := 1 To Len(aUsHDocto)
		AAdd( aHDocto, aUsHDocto[nCnt,1] )
	Next nCnt
EndIf

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
AAdd( aObjects, { 100,40,.T.,.T.,.F. } )							//-- Horizontal superior.
AAdd( aObjects, { 100,60,.T.,.T.,.T. } )							//-- Horizontal central.
AAdd( aObjects, { 100,05,.T.,.T. } ) 								//-- Horizontal Inferior.

aInfo		:= { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
aPosObjH	:= MsObjSize( aInfo, aObjects, .T., .F. )

aObjects	:= {}
AAdd( aObjects, { 40,100,.T.,.T.,.T. } )								//-- Vertical esquerda.
AAdd( aObjects, { 30,100,.T.,.T.,.T. } )								//-- Vertical centro.
AAdd( aObjects, { 30,100,.T.,.T.,.T. } )								//-- Vertical direita.

aInfo		:= { aPosObjH[ 1, 2 ],aPosObjH[ 1, 1 ],aPosObjH[ 1, 4 ],aPosObjH[ 1, 3 ], 0, 0 }
aPosObjV	:= MsObjSize( aInfo, aObjects, .T., .T. )

//--Organizando as Rotas
Asort(aRota,,,{|x,y| x[2] <y[2] })

DEFINE MSDIALOG oDlgEsp FROM aSize[7],00 TO aSize[6],aSize[5] TITLE cHDlgEsp	OF oMainWnd PIXEL

	//-- Listbox Rota
	@ aPosObjV[1,1], aPosObjV[1,2] LISTBOX oLbxRota VAR cLbx1 FIELDS HEADER aHRota[1],aHRota[2],aHRota[3],aHRota[4],aHRota[5],;
	aHRota[6],aHRota[7],aHRota[8] SIZE aPosObjV[1,3], aPosObjV[1,4] OF oDlgEsp ON DBLCLICK ( TmsA141Mrk( 1,nOpcx) )	PIXEL
	oLbxRota:SetArray( aRota )
	TmsA141bLi( 1 )

	//-- Listbox Zona
	@ aPosObjV[2,1], aPosObjV[2,2] LISTBOX oLbxZona VAR cLbx2 FIELDS HEADER aHZona[1],aHZona[2],aHZona[3],aHZona[4] SIZE aPosObjV[2,3], aPosObjV[2,4] OF oDlgEsp ON DBLCLICK ( TmsA141Mrk( 2,nOpcx) )	PIXEL
	oLbxZona:SetArray( aZona )
	TmsA141bLi( 2 )

	//-- Listbox Setor
	@ aPosObjV[3,1], aPosObjV[3,2] LISTBOX oLbxSetor VAR cLbx3 FIELDS HEADER aHSetor[1],aHSetor[2],aHSetor[3],aHSetor[4],aHSetor[5] SIZE aPosObjV[3,3], aPosObjV[3,4] OF oDlgEsp ON DBLCLICK ( TmsA141Mrk( 3,nOpcx ) )	PIXEL
	oLbxSetor:SetArray( aSetor )
	TmsA141bLi( 3 )

	@ aPosObjH[2,1], aPosObjH[2,2] Say STR0042 OF oDlgEsp PIXEL //"Documentos"

	oLbxDocto := TWBrowse():New( aPosObjH[2,1]+7, aPosObjH[2,2], aPosObjH[2,3], aPosObjH[2,4]-8, Nil, ;
                                 aHDocto, Nil, oDlgEsp, Nil, Nil, Nil,,,,,,,,,, "ARRAY", .T. )
	oLbxDocto:bLDblClick  := {|| TMSA141Mrk(4,nOpcx)}
	oLbxDocto:SetArray( aDocto )
	TmsA141bLi( 4 )

	If	nOpcx == 3 .Or. nOpcx == 4
		//-- Marca/desmarca documentos.
		@ aPosObjH[2,1], aPosObjH[2,2] + 60 CHECKBOX oAllMark VAR lAllMark PROMPT STR0043 SIZE 68, 05; //"Marca/Desmarca todos "
		ON CLICK( TmsA141All(lAllMark, !lColeta, nOpcx ) ) OF oDlgEsp PIXEL
	EndIf

	//-- Campos do Rodape
	oPanel := TPanel():New(aPosObjH[3,1],aPosObjH[3,2],"",oDlgEsp,,,,,CLR_WHITE,(aPosObjH[3,4]), (aPosObjH[3,3]), .T.)

	@ 005,005 SAY STR0052 SIZE 40,9 OF oPanel PIXEL //--Volumes:
	@ 003,030 MSGET oVolumes VAR nVolumes WHEN .F. SIZE 30,9 OF oPanel PIXEL

	@ 005,070 SAY STR0053 SIZE 40,9 OF oPanel PIXEL //--Peso Real
	@ 003,100 MSGET oPesReal VAR nPesReal PICTURE PesqPict("DT6","DT6_PESO") WHEN .F. SIZE 50,9 OF oPanel PIXEL

	@ 005,160 SAY STR0054 SIZE 40,9 OF oPanel PIXEL //--Peso Cubado
	@ 003,195 MSGET oPesCub VAR nPesCub PICTURE PesqPict("DT6","DT6_PESOM3") WHEN .F. SIZE 50,9 OF oPanel PIXEL

	@ 005,255 SAY STR0055 SIZE 40,9 OF oPanel PIXEL //--Vlr. Merc.
	@ 003,285 MSGET oValMerc VAR nValMerc PICTURE PesqPict("DT6","DT6_VALMER") WHEN .F. SIZE 50,9 OF oPanel PIXEL

	@ 005,345 SAY STR0056 SIZE 50,9 OF oPanel PIXEL //--Doctos.
	@ 003,365 MSGET oDoctos VAR nDoctos WHEN .F. SIZE 20,9 OF oPanel PIXEL

	//-- Atualizando o Rodape
	TMSA141Rdp()

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||Iif(TmsA141TOk(nOpcx),(nOpca := 1,oDlgEsp:End()),.F.)},{||nOpca == 0, oDlgEsp:End()},, aButtons )

If	nOpca == 1
	TmsA141Grv(nOpcx,,,,,@nPosDTQ)
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
                TmsConTran(aDocto[nCnt,CTFILDOC],aDocto[nCnt,CTDOCTO],aDocto[nCnt,CTSERIE], .T.)
			EndIf
		Next nCnt
	EndIf

	If Len(aCompViag) > 0 //-- Se foi preenchido o Complemento de Viagem
		If lContVei .Or. lMV_EmViag
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

	//--
	//Limpa modelo de dados DJM - Fornecedores Adicionais
	Iif(AliasIndic('DJM') .And. nOpcx <> 2 .And. oMdlDJMGr != Nil, A141LmpDJM(), )
EndIf

If Type('bFiltraBrw') <> 'U'
	Eval(bFiltraBrw)
EndIf

cSerTms := cSerOld
cTipTra := cTraOld

//-- Nao chama novamente a tela, qd for inclusao
MBRCHGLoop()
MsUnLockAll()

//-- Inicializa Array para controle de prioridades de agendamento de entrega
aRetPrior := {}

Pergunte("TMB144",.F.)
If Type("MV_PAR02") == "C"
	cSerAdi := mv_par02
EndIf
RestArea( aAreaDTQ )

Return( { nOpca, M->DTQ_FILORI, M->DTQ_VIAGEM } )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA141Par³ Autor ³ Alex Egydio           ³ Data ³15.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Informacoes para filtragem.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 -> Editar os parametros.                             ³±±
±±³          ³ ExpN1 -> Opcao da viagem                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141Par(lEdita,nOpcx)

Local lRet      := .T.
Local lTM141PAR := ExistBlock("TM141PAR")
Local lRetPE    := .T.
Local cPerg141  := "TMA141"
Local lAgdEntr  := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)     //-- Agendamento de Entrega.

If	Type('lCdrOri') == 'U'
	Private lCdrOri := .F.
EndIf

If lTM141PAR
	lRetPE := ExecBlock("TM141PAR",.F.,.F.)
    If ValType(lRetPE) <> "L"
    	lRetPE := .T.
    EndIf
EndIf

If lAgdEntr .And.cSerTms == "3" //-- valida Agendamento de Entrega e se é uma viagem tipo entrega.
	cPerg141 := "TMSA141A"
EndIf

If	cSerTms == StrZero(1,Len(DC5->DC5_SERTMS)) .And. cTipTra == StrZero(1,Len(DC5->DC5_TIPTRA))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas como parametros                                  ³
	//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³ mv_par01	// Apresenta rotas ?         Ordem de Coleta              ³
	//³                                          Todas                        ³
	//³                                                                       ³
	//³ mv_par02	// Tipo da Viagem  ?         Normal                       ³
	//³                                          Planejada                    ³
	//³                                          Socorro                      ³
	//³                                                                       ³
	//³ mv_par03	// Marca Itens Agendamento ? Sim                          ³
	//³                                          Nao                          ³
	//³                                                                       ³
	//³ mv_par04	// Rota Generica ?           Sim                          ³
	//³                                          Nao                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	lRet := Pergunte('TMA142',lEdita .And. lRetPE) .Or. !lRetPE
	If nOpcx == 2
		mv_par01 := 2//mostra todas as rotas caso seja visualizacao
	EndIf
	If lRet
		If	mv_par01 == 2
			nRotPor := 3
		Else
			nRotPor := 1
		EndIf
		nCarreg := 1
		//-- Atualiza o tipo de viagem somente na inclusao.
		If nOpcx == 3
			If mv_par02 == 1
				nTipVia := 1 // -- Normal
			ElseIf mv_par02 == 2
				nTipVia := 3 // -- Planejada
         	ElseIf mv_par02 == 3
            	nTipVia := 4 // -- Socorro
			EndIf
			M->DTQ_TIPVIA := StrZero( nTipVia, Len( DTQ->DTQ_TIPVIA ) )
		EndIf
		//-- Rota generica (S/N)
		nRotGen := mv_par04
		lCdrOri := If(mv_par05==1,.T.,.F.) //-- Somente rotas da filial
	EndIf

ElseIf	cSerTms == StrZero(1,Len(DC5->DC5_SERTMS)) .And. cTipTra == StrZero(2,Len(DC5->DC5_TIPTRA))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas como parametros                                  ³
	//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³ mv_par01	// Apresenta rotas ?         Ordem de Coleta              ³
	//³                                          Docto Aeroporto              ³
	//³                                          Todas                        ³
	//³                                                                       ³
	//³ mv_par02	// Tipo da Viagems ?         Normal                       ³
	//³                                          Planejada                    ³
	//³                                          Socorro                      ³
	//³                                                                       ³
	//³ mv_par03	// Marca Itens Agendamento ? Sim                          ³
	//³                                          Nao                          ³
	//³                                                                       ³
	//³ mv_par04	// Rota Generica ?           Sim                          ³
	//³                                          Nao                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//-- Atualiza o parametro mv_par02( Tipo da Viagem ) para viagens de coleta.

	lRet := Pergunte('TMA143',lEdita .And. lRetPE) .Or. !lRetPE
	If nOpcx == 2
		mv_par01 := 3//mostra todas as rotas caso seja visualizacao
	EndIf
	If lRet
		nRotPor := mv_par01
		nCarreg := 1
		If nOpcx == 3
			nTipVia := 1
			If mv_par02 == 1
				nTipVia := 1 // -- Normal
			ElseIf mv_par02 == 2
				nTipVia := 3 // -- Planejada
         	ElseIf mv_par02 == 3
            	nTipVia := 4 // -- Socorro
			EndIf
			M->DTQ_TIPVIA := StrZero( nTipVia, Len( DTQ->DTQ_TIPVIA ) )
		EndIf
		//-- Rota generica (S/N)
		nRotGen := mv_par04
		lCdrOri := If(mv_par05==1,.T.,.F.) //-- Somente rotas da filial
	EndIf

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas como parametros                                  ³
	//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³ mv_par01	// Apresenta rotas ?  Docto Armazem                       ³
	//³                                   Docto Aeroporto                     ³
	//³                                   Todas                               ³
	//³                                                                       ³
	//³ mv_par02	// Carregamento ?     Manual                              ³
	//³                                   Automatico                          ³
	//|                                   Manifesto                           ³
	//|                                   Contr/Manifesto                     ³
	//³                                   Contrato                            ³
	//³                                                                       ³
	//³ mv_par03	// Tipo Viagem ?      Normal                              ³
	//³                                   Planejada                           ³
	//³                                   Vazia                               ³
	//³                                   Socorro                             ³
	//³                                                                       ³
	//³ mv_par04	// Rota Generica ?    Sim                                 ³
	//³                                   Nao                                 ³
	//³                                                                       ³
	//³ mv_par05	// Somente Rotas da Filial ?    Sim                       ³
	//³                                             Nao                       ³
	//³                                                                       ³
	//³ mv_par06	// Paga Saldo de Contrato ?     Sim                       ³
	//³                                             Nao                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	lRet := .F.
	If Pergunte(cPerg141,lEdita .And. lRetPE) .Or. !lRetPE
		If nOpcx == 2
			mv_par01 := 3//mostra todas as rotas caso seja visualizacao
		EndIf
		nRotPor := mv_par01
		nCarreg := mv_par02
		lRet    := .T.
		If nOpcx == 3
			nTipVia := 1
			If mv_par03 == 1
				nTipVia := 1      // -- Normal
			ElseIf mv_par03 == 2
				nTipVia := 3      // -- Planejada
			ElseIf mv_par03 == 3
				nTipVia := 2      // -- Vazia
			ElseIf mv_par03 == 4
				nTipVia := 4      // -- Socorro
			ElseIf mv_par03 == 5
				nTipVia := 5      // -- Redespacho
			EndIf
			M->DTQ_TIPVIA := StrZero( nTipVia, Len( DTQ->DTQ_TIPVIA ) )
		EndIf
		//-- Rota generica (S/N)
		nRotGen := mv_par04
		lCdrOri := If(mv_par05==1,.T.,.F.) //-- Somente rotas da filial
		lPagSald:= mv_par06 == 1 //Pagar Saldo Contrato  ?  Sim / Nao
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA141Seq³ Autor ³ Alex Egydio           ³ Data ³17.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Sequencia de Viagem                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 -> Opcao da viagem                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141Seq(nOpcx)

Local nSeek		 := 0
Local nSequen	 := 0
Local nCntFor

//-- Dialog
Local nOpca		 := 0
Local oDlgEsp
Local cTmsTit	 := cCadastro

//-- Controle de dimensoes de objetos
Local aInfo		 := {}
Local aObjects	 := {}
Local aPosObj	 := {}
Local aSize		 := {}

//-- Enchoice
Local aAltera	 := {}
Local aVisual	 := {'DTQ_FILORI','DTQ_VIAGEM'}
Local cAlias	 := 'DTQ'
Local nReg		 := DTQ->(Recno())
Local oEnch

//-- GetDados
Local aAltGetD	 := {'DUD_SEQUEN'}
Local aYesFields := {}
Local lSequen	 := .F.
Local nLin		 := 0
Local nPosCpo    := 0
Local aDoctoOld	 := AClone(aDocto)

Local aFldAll 	 := {}
Local aFldAux	 := {}
Local nI		 := 0
Local nPos		 := 0

//-- Enchoice
Private aTela[0][0]
Private aGets[0]

//-- GetDados
Private aHeader	 := {}
Private aCols	 := {}
Private oGetD

cCadastro := STR0025 //'Sequencia de viagem'

If lTmsCFec .And. lColeta
	//-- Ordena o vetor de trabalho pela Sequencia + Agendamento + Item + Serv. Transp.
	ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[CTNUMAGE] + x[ CTITEAGE ] + x[ CTSERTMS ] < y[CTSEQUEN] + y[CTNUMAGE] + y[ CTITEAGE ] + y[ CTSERTMS ] })
Else
	// QUANDO INCLUSAO, UTILIZAR O CAMPO DA7_SEQUEN
	If nOpcx == 3
		ASort( aDocto,,,{|x,y| x[CTSEQDA7] + x[ CTARMAZE ] + x[ CTLOCALI ] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] + x[CTSEQUEN] < y[CTSEQDA7] + y[ CTARMAZE ] + y[ CTLOCALI ] + y[ CTFILDOC ] + y[ CTDOCTO ] + y[ CTSERIE ] + y[CTSEQUEN] })
	Else
		ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[ CTARMAZE ] + x[ CTLOCALI ] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] + x[CTSEQDA7] < y[CTSEQUEN] + y[ CTARMAZE ] + y[ CTLOCALI ] + y[ CTFILDOC ] + y[ CTDOCTO ] + y[ CTSERIE ] + y[CTSEQDA7] })
	EndIf
EndIf

//-- Configura vetor aHeader
If	lColeta
	AAdd( aYesFields, 'DUD_SEQUEN' )			//-- Sequencia
	If lTmsCFec
		//-- Exibe as colunas Agendamento, Item e Serv. Transp.
		AAdd( aYesFields, 'DF0_NUMAGE' )		//-- Agendamento
		AAdd( aYesFields, 'DF1_ITEAGE' )		//-- Item
		AAdd( aYesFields, 'DC5_SERTMS' )		//-- Serv. Transp.
	EndIf
	AAdd( aYesFields, 'DUD_FILDOC' 	)		//-- Fil.Docto.
	AAdd( aYesFields, 'DUD_DOC' 	)			//-- No.Docto.
	AAdd( aYesFields, 'DUD_SERIE'	)			//-- Serie Docto.
	If cSerAdi $ '1/3'
		AAdd( aYesFields, 'DUD_DESSVT')		//-- Serviço de Transporte
	EndIf
	AAdd( aYesFields, 'DT5_NOME' 	)			//-- Solicitante
	AAdd( aYesFields, 'DUE_END' 	)			//-- Endereco
	AAdd( aYesFields, 'DUE_BAIRRO' 	)		//-- Bairro
	AAdd( aYesFields, 'DUE_MUN' 	)			//-- Municipio
	AAdd( aYesFields, 'DT5_DATSOL' 	)		//-- Data
	AAdd( aYesFields, 'DT5_HORSOL' 	)		//-- Hora
	AAdd( aYesFields, 'DT5_DATPRV' 	)		//-- Data Pre.Col
	AAdd( aYesFields, 'DT5_HORPRV' 	)		//-- Hora Pre.Col
	AAdd( aYesFields, 'DT6_QTDVOL' 	)		//-- Qtde.Volume
	AAdd( aYesFields, 'DT6_PESO' 	)			//-- Peso Real
	AAdd( aYesFields, 'DT6_PESOM3' 	)		//-- Peso Cubado

	aFldAux := ApBuildHeader("DUD")
	For nI := 1 To Len(aFldAux)
		aAdd(aFldAll, aFldAux[nI])
	Next

	aFldAux := ApBuildHeader("DF0")
	For nI := 1 To Len(aFldAux)
		aAdd(aFldAll, aFldAux[nI])
	Next

	aFldAux := ApBuildHeader("DF1")
	For nI := 1 To Len(aFldAux)
		aAdd(aFldAll, aFldAux[nI])
	Next

	aFldAux := ApBuildHeader("DC5")
	For nI := 1 To Len(aFldAux)
		aAdd(aFldAll, aFldAux[nI])
	Next

	aFldAux := ApBuildHeader("DT5")
	For nI := 1 To Len(aFldAux)
		aAdd(aFldAll, aFldAux[nI])
	Next

	aFldAux := ApBuildHeader("DUE")
	For nI := 1 To Len(aFldAux)
		aAdd(aFldAll, aFldAux[nI])
	Next

	aFldAux := ApBuildHeader("DT6")
	For nI := 1 To Len(aFldAux)
		aAdd(aFldAll, aFldAux[nI])
	Next
Else
	AAdd( aYesFields, 'DUD_SEQUEN' )			//-- Sequencia
	If	lLocaliz
		AAdd( aYesFields, 'DUH_LOCAL'  )		//-- Armazem
		AAdd( aYesFields, 'DUH_LOCALI' )		//-- Endereco
	EndIf
	AAdd( aYesFields, 'DUD_FILDOC' 	)			//-- Fil.Docto.
	AAdd( aYesFields, 'DUD_DOC' 	)				//-- No.Docto.
	AAdd( aYesFields, 'DUD_SERIE' 	)			//-- Serie Docto.
	If cSerAdi $ '1/3'
		AAdd( aYesFields, 'DUD_DESSVT')			//-- Serviço de Transporte
	EndIf
	AAdd( aYesFields, 'DTC_NOMREM' 	)			//-- Nome Remet.
	AAdd( aYesFields, 'DTC_NOMDES' 	)			//-- Nome Dest.
	AAdd( aYesFields, 'DUE_END' 	)				//-- Endereco
	AAdd( aYesFields, 'DUE_BAIRRO' 	)			//-- Bairro
	AAdd( aYesFields, 'DUE_MUN' 	)				//-- Municipio
	AAdd( aYesFields, 'DT6_PRZENT' 	)			//-- Prz.Entrega
	AAdd( aYesFields, 'DT6_QTDVOL' 	)			//-- Qtde.Volume
	AAdd( aYesFields, 'DT6_VOLORI' 	)			//-- Qtde.Volume
	AAdd( aYesFields, 'DT6_PESO' 	)			//-- Peso Real
	AAdd( aYesFields, 'DT6_PESOM3' 	)			//-- Peso Cubado
	AAdd( aYesFields, 'DT6_VALMER' 	)

	aFldAux := ApBuildHeader("DUD")
	For nI := 1 To Len(aFldAux)
		aAdd(aFldAll, aFldAux[nI])
	Next

	aFldAux := ApBuildHeader("DUH")
	For nI := 1 To Len(aFldAux)
		aAdd(aFldAll, aFldAux[nI])
	Next

	aFldAux := ApBuildHeader("DTC")
	For nI := 1 To Len(aFldAux)
		aAdd(aFldAll, aFldAux[nI])
	Next

	aFldAux := ApBuildHeader("DUE")
	For nI := 1 To Len(aFldAux)
		aAdd(aFldAll, aFldAux[nI])
	Next

	aFldAux := ApBuildHeader("DT6")
	For nI := 1 To Len(aFldAux)
		aAdd(aFldAll, aFldAux[nI])
	Next
EndIf

For nCntFor := 1 To Len( aYesFields )

	If (nPos := aScan(aFldAll, {|x| AllTrim(x[2]) == aYesFields[nCntFor]})) > 0

		AAdd(	aHeader, aFldAll[nPos] )

	EndIf

Next

aSize(aFldAux, 0)
aFldAux := Nil

aSize(aFldAll, 0)
aFldAll := Nil

If lTmsCFec .And. lColeta
	//-- Altera o titulo do campo DT5_DATPRV.
	If ( nPosCpo := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DT5_DATPRV' }) ) > 0
		aHeader[nPosCpo, 1] := STR0040 //"Data Prev."
	EndIf

	//-- Altera o titulo do campo DT5_HORPRV.
	If ( nPosCpo := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DT5_HORPRV' }) ) > 0
		aHeader[nPosCpo, 1] := STR0041 //"Hora Prev."
	EndIf
EndIf
For nCntFor := 1 To Len( aDocto )
	//-- Preenche o aCols somente com os itens marcados.
	If	aDocto[ nCntFor, CTMARCA ]
		//-- Nao duplica o numero do documento para digitacao da sequencia, se o documento foi distribuido
		//-- em mais de um endereco.
		If Ascan( aCols,{|x| x[GDFieldPos('DUD_FILDOC')] + x[GDFieldPos('DUD_DOC')] + x[GDFieldPos('DUD_SERIE')] == aDocto[ nCntFor, CTFILDOC ] + aDocto[ nCntFor, CTDOCTO ] + aDocto[ nCntFor, CTSERIE ] }) > 0 .And.;
			!lColeta
			Loop
		EndIf

		AAdd( aCols, Array( Len( aHeader ) + 1 ) )
		nLin := Len( aCols )

		lSequen := aDocto[ nCntFor, CTSEQUEN ] == Replicate('x',Len(DUD->DUD_SEQUEN))
		nSequen += 1

		If	lColeta
			GDFieldPut('DUD_SEQUEN'	, StrZero(nSequen,Len(DUD->DUD_SEQUEN)),nLin)
			If lTmsCFec
				//-- Exibe as colunas Agendamento, Item e Serv. Transp.
				GDFieldPut('DF0_NUMAGE'	, aDocto[nCntFor,CTNUMAGE]	, nLin)
				GDFieldPut('DF1_ITEAGE'	, aDocto[nCntFor,CTITEAGE]	, nLin)
				GDFieldPut('DC5_SERTMS'	, aDocto[nCntFor,CTDESSVT]	, nLin)
			EndIf
			GDFieldPut('DUD_FILDOC'	, aDocto[nCntFor,CTFILDOC]	, nLin)
			GDFieldPut('DUD_DOC'	, aDocto[nCntFor,CTDOCTO]	, nLin)
			GDFieldPut('DUD_SERIE'	, aDocto[nCntFor,CTSERIE]	, nLin)
			GDFieldPut('DT5_NOME'	, aDocto[nCntFor,CTSOLICI]	, nLin)
			GDFieldPut('DUE_END'  	, aDocto[nCntFor,CTENDERE]	, nLin)
			GDFieldPut('DUE_BAIRRO'	, aDocto[nCntFor,CTBAIRRO]	, nLin)
			GDFieldPut('DUE_MUN'	, aDocto[nCntFor,CTMUNICI]	, nLin)
			GDFieldPut('DT5_DATSOL'	, aDocto[nCntFor,CTDATSOL]	, nLin)
			GDFieldPut('DT5_HORSOL'	, aDocto[nCntFor,CTHORSOL]	, nLin)
			GDFieldPut('DT5_DATPRV'	, aDocto[nCntFor,CTDATPRV]	, nLin)
			GDFieldPut('DT5_HORPRV'	, aDocto[nCntFor,CTHORPRV]	, nLin)
			GDFieldPut('DT6_QTDVOL'	, aDocto[nCntFor,CTQTDVOL]	, nLin)
			GDFieldPut('DT6_PESO'	, aDocto[nCntFor,CTPLIQUI]	, nLin)
			GDFieldPut('DT6_PESOM3'	, aDocto[nCntFor,CTPESOM3]	, nLin)
		Else
			GDFieldPut('DUD_SEQUEN'	, Iif(lSequen,StrZero(nSequen,Len(DUD->DUD_SEQUEN)),aDocto[nCntFor,CTSEQUEN]),nLin)
			If	lLocaliz
				GDFieldPut('DUH_LOCAL'	, aDocto[nCntFor,CTARMAZE], nLin)
				GDFieldPut('DUH_LOCALI'	, aDocto[nCntFor,CTLOCALI], nLin)
			EndIf
			GDFieldPut('DUD_FILDOC'	, aDocto[nCntFor,CTFILDOC]	, nLin)
			GDFieldPut('DUD_DOC'	, aDocto[nCntFor,CTDOCTO]	, nLin)
			GDFieldPut('DUD_SERIE'	, aDocto[nCntFor,CTSERIE]	, nLin)
			GDFieldPut('DTC_NOMREM'	, aDocto[nCntFor,CTNOMREM]	, nLin)
			GDFieldPut('DTC_NOMDES'	, aDocto[nCntFor,CTNOMDES]	, nLin)
			GDFieldPut('DUE_END'  	, aDocto[nCntFor,CTENDERE]	, nLin)
			GDFieldPut('DUE_BAIRRO'	, aDocto[nCntFor,CTBAIRRO]	, nLin)
			GDFieldPut('DUE_MUN'	, aDocto[nCntFor,CTMUNICI]	, nLin)
			GDFieldPut('DT6_PRZENT'	, aDocto[nCntFor,CTPRZENT]	, nLin)
			GDFieldPut('DT6_QTDVOL'	, aDocto[nCntFor,CTQTDVOL]	, nLin)
			GDFieldPut('DT6_VOLORI'	, aDocto[nCntFor,CTVOLORI]	, nLin)
			GDFieldPut('DT6_PESO'	, aDocto[nCntFor,CTPLIQUI]	, nLin)
			GDFieldPut('DT6_PESOM3'	, aDocto[nCntFor,CTPESOM3]	, nLin)
			GDFieldPut('DT6_VALMER'	, aDocto[nCntFor,CTVALMER]	, nLin)
		EndIf
		If cSerAdi $ '1/3'
			GDFieldPut('DC5_SERTMS' , aDocto[nCntFor,CTDESSVT] , nLin)
		EndIf
		aCols[ nLin, Len( aHeader ) + 1 ] := .F.
	EndIf
Next

If Empty( aCols )
	Help(' ', 1, 'TMSA14003')	//-- Nenhum documento selecionado !
	Return( Nil )
EndIf

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 30, .T., .T. } )
AAdd( aObjects, { 200, 200, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oEnch	:= MsMGet():New( cAlias, nReg, nOpcx,,,, aVisual, aPosObj[1], aAltera, 3, , , , , ,.T. )

	//       MsGetDados(                nT ,               nL,             nB,               nR,    nOpc,    cLinhaOk,       cTudoOk,   cIniCpos,lDeleta, aAlter,  nFreeze,lEmpty, nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,          oWnd)
	oGetD	:= MSGetDados():New(aPosObj[ 2, 1 ], aPosObj[ 2, 2 ],aPosObj[ 2, 3 ], aPosObj[ 2, 4 ], nOpcx,'AllWaysTrue','AllWaysTrue',        ,    .T., aAltGetD,1      ,      ,nLin,        ,         ,       ,'!AllWaysTrue()',    )
ACTIVATE MSDIALOG oDlgEsp ON INIT ( TmsA141Car(), EnchoiceBar(oDlgEsp,{||Iif( oGetD:TudoOk(), (nOpca := 1,oDlgEsp:End()), (nOpca :=0, .F.))},{||nOpca:=0,oDlgEsp:End()}) )

If nOpca == 1

	For nCntFor := 1 To Len( aDocto )

		If lTmsCFec .And. lColeta
			nSeek := Ascan( aCols,{|x| x[GDFieldPos('DUD_FILDOC')] + x[GDFieldPos('DUD_DOC')] + x[GDFieldPos('DUD_SERIE')] + x[GDFieldPos('DC5_SERTMS')] == aDocto[ nCntFor, CTFILDOC ] + aDocto[ nCntFor, CTDOCTO ] + aDocto[ nCntFor, CTSERIE ] + aDocto[ nCntFor, CTDESSVT ] })
		Else
			nSeek := Ascan( aCols,{|x| x[GDFieldPos('DUD_FILDOC')] + x[GDFieldPos('DUD_DOC')] + x[GDFieldPos('DUD_SERIE')] == aDocto[ nCntFor, CTFILDOC ] + aDocto[ nCntFor, CTDOCTO ] + aDocto[ nCntFor, CTSERIE ] })
		EndIf

		If nSeek > 0
			aDocto[ nCntFor, CTSEQUEN ] := aCols[ nSeek, GDFieldPos('DUD_SEQUEN') ]
		Else
			If !Empty( aDocto[ nCntFor, CTSEQUEN ] )
				aDocto[ nCntFor, CTSEQUEN ] := Replicate( 'x', Len( DUD->DUD_SEQUEN ) )
			EndIf
		EndIf

	Next

	If lTmsCFec .And. lColeta
		//-- Ordena o vetor de trabalho pela Sequencia + Agendamento + Item + Serv. Transp.
		ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[CTNUMAGE] + x[ CTITEAGE ] + x[ CTSERTMS ] < y[CTSEQUEN] + y[CTNUMAGE] + y[ CTITEAGE ] + y[ CTSERTMS ] })
	Else
		//-- Ordena o vetor de trabalho pela sequencia.
		ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[ CTARMAZE ] + x[ CTLOCALI ] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] < y[CTSEQUEN] + y[ CTARMAZE ] + y[ CTLOCALI ] + y[ CTFILDOC ] + y[ CTDOCTO ] + y[ CTSERIE ] })
	EndIf
	oLbxDocto:Refresh()
Else
	aDocto := AClone(aDoctoOld)
EndIf

cCadastro := cTmsTit

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA141Car³ Autor ³ Alex Egydio           ³ Data ³17.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta os documentos encerrados com cor diferente.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141Car()

Local nCntFor	:= 0
Local nSeek		:= 0

For nCntFor := 1 To Len( aCols )
	If lLocaliz .And. ! lColeta
		nSeek := Ascan( aDocto,{ | x | x[ CTARMAZE ] + x[ CTLOCALI ] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] == GDFieldGet('DUH_LOCAL',nCntFor) + GDFieldGet('DUH_LOCALI',nCntFor) + GDFieldGet('DUD_FILDOC',nCntFor) + GDFieldGet('DUD_DOC',nCntFor) + GDFieldGet('DUD_SERIE',nCntFor) })
	Else
		nSeek := Ascan( aDocto,{ | x | x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] == GDFieldGet('DUD_FILDOC',nCntFor) + GDFieldGet('DUD_DOC',nCntFor) + GDFieldGet('DUD_SERIE',nCntFor) })
	EndIf
	If nSeek > 0
		//-- Nao permite editar sequencia de documentos encerrados/cancelados
		aCols[ nCntFor, Len(aCols[nCntFor]) ] := ( aDocto[ nSeek, CTSTATUS ] == StrZero(4, Len(DUD->DUD_STATUS)) .Or. aDocto[ nSeek, CTSTATUS ] == StrZero(9, Len(DUD->DUD_STATUS)) )
	EndIf
Next
oGetD:oBrowse:Refresh()

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA141Ord³ Autor ³ Alex Egydio           ³ Data ³17.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Troca a ordem dos documentos ao digitar a sequencia.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DUD_SEQUEN(X3_VALID)                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141Ord()

Local aColsTRB	 := AClone( aCols )
Local bBloco
Local cSequencia := &( ReadVar() )
Local cArmazem	 := ''
Local cEndereco	 := ''
Local cFilDoc	 := GDFieldGet('DUD_FILDOC', n )
Local cDocto	 := GDFieldGet('DUD_DOC', n )
Local cSerie	 := GDFieldGet('DUD_SERIE', n )
Local lBaixo	 := .F.
Local nCntFor	 := 0
Local nNewSequen := 0
Local nPosSequen := GDFieldPos('DUD_SEQUEN')
Local nSeek		 := 0
Local cDesSvt    := GDFieldGet('DC5_SERTMS', n )

If lVgeMod2 == Nil
	lVgeMod2 := IsInCallStack("TMSA144")
EndIf

//-- Ordem dos documentos na viagem manual.
If lVgeMod2
	Return( TmsA144Ord() )
EndIf

If	lLocaliz .And. ! lColeta
	cArmazem  := GDFieldGet('DUH_LOCAL' , n )
	cEndereco := GDFieldGet('DUH_LOCALI', n )
EndIf

//-- Teclou enter sem alterar a sequencia.
If cSequencia == GDFieldGet('DUD_SEQUEN',n)
	Return( .T. )
EndIf

//-- Procura a sequencia digitada no aCols.
nSeek := Ascan( aCols,{ |x| x[ nPosSequen ] == cSequencia } )

If Empty( nSeek )
	//-- Nao permite informar sequencia que nao exista.
	Help(' ', 1, 'TMSA14007')		//-- Sequencia nao encontrada.
	Return( .F. )
Else

	If	lLocaliz .And. ! lColeta
		nSeek := Ascan( aDocto,{ | x | x[ CTARMAZE ] + x[ CTLOCALI ] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] == GDFieldGet('DUH_LOCAL',nSeek) + GDFieldGet('DUH_LOCALI',nSeek) + GDFieldGet('DUD_FILDOC',nSeek) + GDFieldGet('DUD_DOC',nSeek) + GDFieldGet('DUD_SERIE',nSeek) })
	Else
		nSeek := Ascan( aDocto,{ | x | x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] == GDFieldGet('DUD_FILDOC',nSeek) + GDFieldGet('DUD_DOC',nSeek) + GDFieldGet('DUD_SERIE',nSeek) })
	EndIf
	If nSeek > 0
		If aDocto[ nSeek, CTSTATUS ] == StrZero(3, Len(DUD->DUD_STATUS))
			//-- Nao permite digitar o nr. da sequencia de um documento carregado.
			If	lLocaliz .And. ! lColeta
				Help(' ', 1, 'TMSA14008',,STR0044 + GDFieldGet('DUH_LOCAL',nSeek) + ' / '+ GDFieldGet('DUH_LOCALI',nSeek) + ' / '+ GDFieldGet('DUD_DOC',nSeek) + ' / '+ GDFieldGet('DUD_SERIE',nSeek),4,3) //"Esta sequencia pertence a um documento carregado !"###"Armazem/Endereco/Docto/Serie : "
			Else
				Help(' ', 1, 'TMSA14008',,STR0045 + GDFieldGet('DUD_DOC',nSeek) + ' / '+ GDFieldGet('DUD_SERIE',nSeek),4,3)		//-- Esta sequencia pertence a um documento carregado !###"Docto/Série : "
			EndIf
			Return( .F. )
		EndIf
	EndIf
EndIf

//-- Ordena o vetor de trabalho pela sequencia.
ASort( aColsTRB,,,{|x,y| x[nPosSequen] < y[nPosSequen] } )
//-- Mover a linha atual para baixo.
lBaixo := cSequencia > aColsTRB[ n, nPosSequen ]
//-- Grava no vetor de trabalho a sequencia digitada.
aColsTRB[ n, nPosSequen ] := cSequencia
ASort( aColsTRB,,,{|x,y| x[nPosSequen] < y[nPosSequen] } )
//-- Altera a sequencia.
For nCntFor := 1 To Len( aColsTRB )
	//-- Desconsidera a linha alterada.
	If lLocaliz .And. ! lColeta
		bBloco := {|| aColsTRB[ nCntFor,GDFieldPos('DUH_LOCAL')] + aColsTRB[ nCntFor,GDFieldPos('DUH_LOCALI')] + aColsTRB[ nCntFor,GDFieldPos('DUD_FILDOC')] + aColsTRB[ nCntFor,GDFieldPos('DUD_DOC')] + aColsTRB[nCntFor,GDFieldPos('DUD_SERIE')] != cArmazem + cEndereco + cFilDoc + cDocto + cSerie }
	Else
		If lTmsCFec .And. lColeta
			bBloco := {|| aColsTRB[ nCntFor,GDFieldPos('DUD_FILDOC')] + aColsTRB[ nCntFor,GDFieldPos('DUD_DOC')] + aColsTRB[nCntFor,GDFieldPos('DUD_SERIE')] + aColsTRB[ nCntFor,GDFieldPos('DC5_SERTMS')] != cFilDoc + cDocto + cSerie + cDesSvt }
		Else
			bBloco := {|| aColsTRB[ nCntFor,GDFieldPos('DUD_FILDOC')] + aColsTRB[ nCntFor,GDFieldPos('DUD_DOC')] + aColsTRB[nCntFor,GDFieldPos('DUD_SERIE')] != cFilDoc + cDocto + cSerie }
		EndIf
	EndIf

	If Eval( bBloco )

		If	aColsTRB[ nCntFor, nPosSequen ] == cSequencia

			If lBaixo
				aColsTRB[ nCntFor, nPosSequen ] := StrZero( nCntFor, Len( DUD->DUD_SEQUEN ) )
				Exit
			Else
				nNewSequen := Val(cSequencia) + 1
				aColsTRB[ nCntFor, nPosSequen ] := StrZero( nNewSequen, Len( DUD->DUD_SEQUEN ) )
			EndIf

		Else
			aColsTRB[ nCntFor, nPosSequen ] := StrZero( nNewSequen += 1, Len( DUD->DUD_SEQUEN ) )
		EndIf

	EndIf

Next
//-- Ordena o vetor de trabalho pela sequencia.
ASort( aColsTRB,,,{|x,y| x[nPosSequen] < y[nPosSequen] } )

&(ReadVar()):= aColsTRB[n,nPosSequen]

aCols := AClone( aColsTRB )

If lLocaliz .And. ! lColeta
	n := Ascan( aCols,{|x| x[GDFieldPos('DUH_LOCAL')] + x[GDFieldPos('DUH_LOCALI')] + x[GDFieldPos('DUD_FILDOC')] + x[GDFieldPos('DUD_DOC')] + x[GDFieldPos('DUD_SERIE')] == cArmazem + cEndereco + cFilDoc + cDocto + cSerie })
Else
	n := Ascan( aCols,{|x| x[GDFieldPos('DUD_FILDOC')] + x[GDFieldPos('DUD_DOC')] + x[GDFieldPos('DUD_SERIE')] == cFilDoc + cDocto + cSerie })
EndIf

oGetD:oBrowse:Refresh(.T.)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA141Whe³ Autor ³ Alex Egydio           ³ Data ³17.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida antes de editar o campo.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DUD_SEQUEN(X3_WHEN)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141Whe()
Local lRet    := .T.
Local cCampo  := AllTrim( ReadVar() )
Local nSeek   := 0
Local cRotina := FunName()

If	cCampo == 'M->DUD_SEQUEN' .And. !IsInCallStack("TMSAF76")
	//-- Nao permite editar documentos encerrados/cancelados.
	If lLocaliz .And. ! lColeta
		If "TMSA144" $ cRotina
			nSeek := Ascan( aDocto,{ | x | x[ CTARMAZE ] + x[ CTLOCALI ] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] == GDFieldGet('DUH_LOCAL',n) + GDFieldGet('DUH_LOCALI',n) + GDFieldGet('DTA_FILDOC',n) + GDFieldGet('DTA_DOC',n) + GDFieldGet('DTA_SERIE',n) })
		Else
			nSeek := Ascan( aDocto,{ | x | x[ CTARMAZE ] + x[ CTLOCALI ] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] == GDFieldGet('DUH_LOCAL',n) + GDFieldGet('DUH_LOCALI',n) + GDFieldGet('DUD_FILDOC',n) + GDFieldGet('DUD_DOC',n) + GDFieldGet('DUD_SERIE',n) })
		EndIf
	Else
		If "TMSA144" $ cRotina
			nSeek := Ascan( aDocto,{ | x | x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] == GDFieldGet('DTA_FILDOC',n) + GDFieldGet('DTA_DOC',n) + GDFieldGet('DTA_SERIE',n) })
		Else
			nSeek := Ascan( aDocto,{ | x | x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] == GDFieldGet('DUD_FILDOC',n) + GDFieldGet('DUD_DOC',n) + GDFieldGet('DUD_SERIE',n) })
		EndIf
	EndIf
	If nSeek > 0
		lRet := ( aDocto[ nSeek, CTSTATUS ] != StrZero(4, Len(DUD->DUD_STATUS)) .And. aDocto[ nSeek, CTSTATUS ] != StrZero(9, Len(DUD->DUD_STATUS)) )
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA141TOk³ Autor ³ Alex Egydio           ³ Data ³14.05.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes gerais                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao de manutencao                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141TOk(nOpcx)

Local aAreaAnt	:= GetArea()
Local aAreaDTR	:= DTR->(GetArea())
Local lRet      := .T.
// Indica se existe ponto de entrada para validar manutencao
Local lPontoVld:= ExistBlock("TMS141VLD")
//-- Operadoras de Frota/Vale-Pedagio
Local lTMSOPdg  := SuperGetMV( 'MV_TMSOPDG',, '0' ) <> '0'
Local nCntFor   := 0
Local aCodigos  := {}
Local cVsRepom  := SuperGetMV( 'MV_VSREPOM',, '1' )  //-- Versao 2- Contempla nova Legislacao (Encerramento viagem no Posto)
Local aDocsDUA  := {}
Local nI        := 0 
Local laCodigo  := .F. 
Local lMotAux   := lTMSOPdg
Local aAreaDA3  := {}
Local cCodVei   := ''
Local cCodRbq1  := ''
Local cCodRbq2  := ''
Local cCodRbq3  := ''
Local cCodMot   := ''

If	AScan(aDocto,{|x| x[CTMARCA] == .T. }) <= 0 .And. (nTipVia == 1 .Or. nTipVia == 3) // -- Normal / Planejada
	Help(' ', 1, 'TMSA14006')	//-- Nenhum documento selecionado !
	lRet := .F.
EndIf

If cSerAdi $ '1/3' .And. AScan(aDocto,{|x|x[CTSERTMS] == cSerAdi .And. x[CTMARCA] == .T.}) > 0  //--Coleta
	M->DTQ_SERADI := cSerAdi
Else
   M->DTQ_SERADI := StrZero(0, Len(DTQ->DTQ_SERADI))
EndIf

If	lRet .And. ( nCarreg > 1 ) .And. !lColeta //-- Carregamento automatico
	If	nOpcx == 3
		If Len(aCompViag) <= 0
			Help( ' ', 1, 'TMSA24002', , STR0038 + M->DTQ_FILORI + ' ' + M->DTQ_VIAGEM, 4, 1 ) //-- Complemento de viagem nao encontrado (DTR)###" Viagem : "
			lRet := .F.
		EndIf
	Else
		DTR->( DbSetOrder( 1 ) )
		If  DTR->( ! MsSeek( xFilial('DTR') + M->DTQ_FILORI + M->DTQ_VIAGEM ) ) .And. Len(aCompViag) <= 0
			Help( ' ', 1, 'TMSA24002', , STR0038 + M->DTQ_FILORI + ' ' + M->DTQ_VIAGEM, 4, 1 ) //-- Complemento de viagem nao encontrado (DTR)###" Viagem : "
			lRet := .F.
		EndIf
	EndIf
EndIf

//Verifica se existe uma ocorrência apontada para os documentos.
If lRet .AND. (nOpcX == 4 .OR. nOpcX == 5)
	For nI := 1 To Len(aDocto)
		If nOpcX == 4 .AND. !aDocto[nI, 3]
			aAdd(aDocsDUA, {aDocto[nI,CTFILDOC], aDocto[nI,CTDOCTO], aDocto[nI,CTSERIE]})
		ElseIf nOpcX == 5
			aAdd(aDocsDUA, {aDocto[nI,CTFILDOC], aDocto[nI,CTDOCTO], aDocto[nI,CTSERIE]})
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
			EndIf

			CursorWait()
			MsgRun( STR0058, STR0057, {||  lRet := TMSAtualOp( aCompViag[11, 7], '5', aCodigos )}) //
			CursorArrow()
		EndIf
	EndIf
EndIf

If lRet .AND. nOpcx == 5  // Excluindo um Viagem , verificar se existe despesas para este documento // caso exista nao excluir viagem
	If TMSDespCx(M->DTQ_FILORI,M->DTQ_VIAGEM)
		Help('',1,'TMSA14106') //-- "Viagem contem despesas lançadas",Favor excluir a(s) operação(ões)","no Movimento do Caixinha"
		lRet := .F.
	EndIf
	If lTMSOPdg .And. cVsRepom $ '2|2.2'
	//-- Se o titulo ja foi baixado, nao permite a exclusao da viagem. O cancelamento da baixa deverá ser efetuada manualmente.
		DTR->( DbSetOrder( 1 ) )
		If  DTR->(  MsSeek( xFilial('DTR') + M->DTQ_FILORI + M->DTQ_VIAGEM ) ) .And. DTR->DTR_CODOPE == '01'
			SDG->(DbSetOrder(5))
			If SDG->(MsSeek(xFilial('SDG')+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_CODVEI ))
				While SDG->(!Eof()) .And. SDG->DG_FILIAL + SDG->DG_FILORI + SDG->DG_VIAGEM + SDG->DG_CODVEI == xFilial('SDG')+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_CODVEI
					If SDG->DG_ORIGEM == 'DTR'
						If !Empty(SDG->DG_BANCO)
							cPrefixo := TMA250GerPrf(cFilAnt)
							SE2->( DbSetOrder( 1 ) )
							If SE2->( MsSeek( xFilial('SE2')+cPrefixo+Padr(M->DTQ_VIAGEM,Len(SE2->E2_NUM))+SDG->DG_PARC) )
								If !Empty(SE2->E2_BAIXA)
									Help(" ", 1,"TMSA07010")
									lRet:= .F.
									Exit
								EndIf
							EndIf
						EndIf
					EndIf
					SDG->(dbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
EndIf

// Executa ponto de entrada para validacao
If lRet .And. lPontoVld
	lRet:=ExecBlock("TMS141VLD",.F.,.F.,{nOpcx})
	If Valtype(lRet) # "L"
		lRet:=.T.
	EndIf
EndIf

RestArea(aAreaDTR)
RestArea(aAreaAnt)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA141Psq³ Autor ³ Alex Egydio           ³ Data ³17.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa documentos                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141Psq()

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

If	lColeta
	//-- (01) Fil.Docto. + No.Docto. + Serie
	cCampo := AllTrim(Posicione('SX3', 2, 'DUD_FILDOC'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_DOC'		, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_SERIE'	, 'X3Titulo()'))
	AAdd( aCbx, cCampo )
	//-- (02) Solicitante
	cCampo := AllTrim(Posicione('SX3', 2, 'DT5_NOME'	, 'X3Titulo()'))
	AAdd( aCbx, cCampo )
	//-- (03) Data + Hora
	cCampo := AllTrim(Posicione('SX3', 2, 'DT5_DATSOL'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DT5_HORSOL'	, 'X3Titulo()'))
	AAdd( aCbx, cCampo )
	//-- (04) Data Prevista + Hora Prevista
	cCampo := AllTrim(Posicione('SX3', 2, 'DT5_DATPRV'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DT5_HORPRV'	, 'X3Titulo()'))
	AAdd( aCbx, cCampo )
	//-- (05) Bairro + Cidade
	cCampo := AllTrim(Posicione('SX3', 2, 'DUE_BAIRRO'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUE_MUN'	, 'X3Titulo()'))
	AAdd( aCbx, cCampo )
	//-- (06) Cidade + Bairro
	cCampo := AllTrim(Posicione('SX3', 2, 'DUE_MUN'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUE_BAIRRO'	, 'X3Titulo()'))
	AAdd( aCbx, cCampo )
	//-- Pesquisa somente utilizada para Carga Fechada.
	If lTmsCFec
		//-- (07) Agendamento + Item
		cCampo := AllTrim(Posicione('SX3', 2, 'DF1_NUMAGE'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DF1_ITEAGE'	, 'X3Titulo()'))
		AAdd( aCbx, cCampo )
	EndIf
Else
	//-- (01) Fil.Docto. + No.Docto. + Serie
	cCampo := AllTrim(Posicione('SX3', 2, 'DUD_FILDOC'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_DOC'		, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_SERIE'	, 'X3Titulo()'))
	AAdd( aCbx, cCampo )
	//-- (02) Remetente + Destinatario
	cCampo := AllTrim(Posicione('SX3', 2, 'DTC_NOMREM'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DTC_NOMDES'	, 'X3Titulo()'))
	AAdd( aCbx, cCampo )
	//-- (03) Destinatario
	cCampo := AllTrim(Posicione('SX3', 2, 'DTC_NOMDES'	, 'X3Titulo()'))
	AAdd( aCbx, cCampo )
   //-- (04) Prz.Entrega + Fil.Docto. + No.Docto. + Serie
	cCampo := AllTrim(Posicione('SX3', 2, 'DT6_PRZENT'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_FILDOC'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_DOC'		, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_SERIE'	, 'X3Titulo()'))
	AAdd( aCbx, cCampo )
	//-- (05) Bairro + Cidade
	cCampo := AllTrim(Posicione('SX3', 2, 'DUE_BAIRRO'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUE_MUN'	, 'X3Titulo()'))
	AAdd( aCbx, cCampo )
	//-- (06) Cidade + Bairro
	cCampo := AllTrim(Posicione('SX3', 2, 'DUE_MUN'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUE_BAIRRO'	, 'X3Titulo()'))
	AAdd( aCbx, cCampo )
	//-- (07) Armazem + Endereco + Fil.Docto. + No.Docto. + Serie
	If	lLocaliz
		cCampo := AllTrim(Posicione('SX3', 2, 'DUH_LOCAL'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUH_LOCALI'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_FILDOC'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_DOC'		, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DUD_SERIE'	, 'X3Titulo()'))
		AAdd( aCbx, cCampo )
	EndIf
EndIf

cCampo := Space( 40 )

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0024 //'Pesquisa'

@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg ON CHANGE nOrdem := oCbx:nAt

@ 22,05 MSGET oPsqGet VAR cCampo SIZE 206,10 PIXEL

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If	lSeek
	cCampo := AllTrim( cCampo )

	If	lColeta

		If nOrdem == 1
			//-- (01) Fil.Docto. + No.Docto. + Serie
			ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] < y[CTSEQUEN] + y[ CTFILDOC ] + y[ CTDOCTO ] + y[ CTSERIE ] })
			nSeek := Ascan( aDocto,{ | x | PadR( x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ], Len( cCampo ) ) == cCampo } )

		ElseIf nOrdem == 2
			//-- (02) Solicitante
			ASort( aDocto,,,{|x,y| x[CTSOLICI] < y[CTSOLICI] } )
			nSeek := Ascan( aDocto,{ | x | PadR( x[ CTSOLICI ], Len( cCampo ) ) == cCampo } )

		ElseIf nOrdem == 3
			//-- (03) Data + Hora
			ASort( aDocto,,,{|x,y| DtoS(x[ CTDATSOL ]) + x[ CTHORSOL ] < DtoS(y[ CTDATSOL ]) + y[ CTHORSOL ] } )

			cData := Left( cCampo, 6 )
			cData := DtoS( CtoD(Left(cData,2)+'/'+Subs(cData,3,2)+'/'+Right(cData,2)) )

			If Len( cCampo ) > 6
				cCampo := cData + Subs( cCampo, 7, Len( cCampo ) )
			Else
				cCampo := cData
			EndIf

			nSeek := Ascan( aDocto,{ | x | PadR( DtoS( x[ CTDATSOL ] ) + x[ CTHORSOL ], Len( cCampo ) ) == cCampo  } )

		ElseIf nOrdem == 4
			//-- (04) Data Prevista + Hora Prevista
			ASort( aDocto,,,{|x,y| DtoS(x[ CTDATPRV ]) + x[ CTHORPRV ] < DtoS(y[ CTDATPRV ]) + y[ CTHORPRV ] } )

			cData := Left( cCampo, 6 )
			cData := DtoS( CtoD(Left(cData,2)+'/'+Subs(cData,3,2)+'/'+Right(cData,2)) )

			If Len( cCampo ) > 6
				cCampo := cData + Subs( cCampo, 7, Len( cCampo ) )
			Else
				cCampo := cData
			EndIf

			nSeek := Ascan( aDocto,{ | x | PadR( DtoS( x[ CTDATPRV ] ) + x[ CTHORPRV ], Len( cCampo ) ) == cCampo  } )

		ElseIf nOrdem == 5
			//-- (05) Bairro + Cidade
			ASort( aDocto,,,{|x,y| x[CTBAIRRO] + x[ CTMUNICI ] < y[CTBAIRRO] + y[ CTMUNICI ] })
			nSeek := Ascan( aDocto,{ | x | PadR( x[ CTBAIRRO ] + x[ CTMUNICI ], Len( cCampo ) ) == cCampo } )

		ElseIf nOrdem == 6
			//-- (06) Cidade + Bairro
			ASort( aDocto,,,{|x,y| x[CTMUNICI] + x[ CTBAIRRO ] < y[CTMUNICI] + y[ CTBAIRRO ] })
			nSeek := Ascan( aDocto,{ | x | PadR( x[ CTMUNICI ] + x[ CTBAIRRO ], Len( cCampo ) ) == cCampo } )
		ElseIf nOrdem == 7
			//-- (07) Agendamento + Item + Serv. Transp( somene para ordenar ).
			ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[CTNUMAGE] + x[ CTITEAGE ] + x[ CTSERTMS ] < y[CTSEQUEN] + y[CTNUMAGE] + y[ CTITEAGE ] + y[ CTSERTMS ] })
			nSeek := Ascan( aDocto,{ | x | PadR( x[ CTNUMAGE ] + x[ CTITEAGE ], Len( cCampo ) ) == cCampo } )
		EndIf

	Else

		If nOrdem == 1
			//-- (01) Fil.Docto. + No.Docto. + Serie
			ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] < y[CTSEQUEN] + y[ CTFILDOC ] + y[ CTDOCTO ] + y[ CTSERIE ] })
			nSeek := Ascan( aDocto,{ | x | PadR( x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ], Len( cCampo ) ) == cCampo } )

		ElseIf nOrdem == 2
			//-- (02) Remetente + Destinatario
			ASort( aDocto,,,{|x,y| x[CTNOMREM] + x[CTNOMDES] < y[CTNOMREM] + y[CTNOMDES] } )
			nSeek := Ascan( aDocto,{ | x | PadR( x[CTNOMREM] + x[CTNOMDES], Len( cCampo ) ) == cCampo } )

		ElseIf nOrdem == 3
			//-- (03) Destinatario
			ASort( aDocto,,,{|x,y| x[CTNOMDES] < y[CTNOMDES] } )
			nSeek := Ascan( aDocto,{ | x | PadR( x[ CTNOMDES ], Len( cCampo ) ) == cCampo } )

		ElseIf nOrdem == 4
		   //-- (04) Prz.Entrega + Fil.Docto. + No.Docto. + Serie
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
			//-- (05) Bairro + Cidade
			ASort( aDocto,,,{|x,y| x[CTBAIRRO] + x[ CTMUNICI ] < y[CTBAIRRO] + y[ CTMUNICI ] })
			nSeek := Ascan( aDocto,{ | x | PadR( x[ CTBAIRRO ] + x[ CTMUNICI ], Len( cCampo ) ) == cCampo } )

		ElseIf nOrdem == 6
			//-- (06) Cidade + Bairro
			ASort( aDocto,,,{|x,y| x[CTMUNICI] + x[ CTBAIRRO ] < y[CTMUNICI] + y[ CTBAIRRO ] })
			nSeek := Ascan( aDocto,{ | x | PadR( x[ CTMUNICI ] + x[ CTBAIRRO ], Len( cCampo ) ) == cCampo } )

		ElseIf nOrdem == 7
			//-- (07) Armazem + Endereco + Fil.Docto. + No.Docto. + Serie
			ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[ CTARMAZE ] + x[ CTLOCALI ] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] < y[CTSEQUEN] + y[ CTARMAZE ] + y[ CTLOCALI ] + y[ CTFILDOC ] + y[ CTDOCTO ] + y[ CTSERIE ] } )
			nSeek := Ascan( aDocto,{ | x | PadR( x[ CTARMAZE ] + x[ CTLOCALI ] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ], Len( cCampo ) ) == cCampo } )
		EndIf

	EndIf

EndIf
If	nSeek > 0
	oLbxDocto:nAT := nSeek
	oLbxDocto:Refresh()
EndIf
oLbxDocto:SetFocus()

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA141Lim³ Autor ³ Alex Egydio           ³ Data ³05.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa informacoes dos documentos selecionados para a     ³±±
±±³          ³ consulta de limites                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141Lim()

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
Local cChave 	 := ''
Local cCodFor	 := ''
Local cLojFor 	 := ''
Local cVeiRas    := ''
Local cCodVei    := ''
Local cCodReb    := ''
Local cCodRb1    := ''
Local cCodRb2    := ''
Local cCodRb3	   := ''
//-- Operadoras de Frota/Vale-Pedagio
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
	If cSerTms == StrZero( 2, Len( DTQ->DTQ_SERTMS ) ) .Or. ; //-- Transporte
	   cSerTms == StrZero( 3, Len( DTQ->DTQ_SERTMS ) ) //-- Entrega
		If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(aDocto[ nCntFor, CTFILDOC ], aDocto[ nCntFor, CTDOCTO ], aDocto[ nCntFor, CTSERIE ])
			dbSelectArea("DTC")
			DTC->(DbSetOrder(3)) //Fil.Docto. + No.Docto. + Serie Docto. + Servico + Cod. Produto
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
				Enddo
			Endif
		Endif
	ElseIf cSerTms == StrZero( 1, Len( DTQ->DTQ_SERTMS ) ) .And. cSerTms == aDocto[ nCntFor, CTSERTMS ] //-- Coleta
		DUM->(DbSetOrder(1))
		DT5->(DbSetOrder(4))
		If DT5->(MsSeek( xFilial('DT5') + aDocto[ nCntFor, CTFILDOC ] + aDocto[ nCntFor, CTDOCTO ] + aDocto[ nCntFor, CTSERIE ] ))
			If DUM->(MsSeek( xFilial('DUM') + DT5->DT5_FILORI + DT5->DT5_NUMSOL ))
				While DUM->(!Eof()) .And. DUM->DUM_FILIAL + DUM->DUM_FILORI + DUM->DUM_NUMSOL == xFilial('DUM') + DT5->DT5_FILORI + DT5->DT5_NUMSOL
					cCliente := Space(Len(DTC->DTC_CLIREM))
					cLoja    := Space(Len(DTC->DTC_LOJREM))
					cProduto := DUM->DUM_CODPRO
					If (nPos := Ascan( aLimite, { |x| x[1] + x[2] + x[3] == cCliente + cLoja + cProduto } )) == 0
						If	aDocto[ nCntFor, CTMARCA ]
							AAdd( aLimite,{ cCliente, cLoja, cProduto, DUM->DUM_VALMER, DUM->DUM_PESO, DUM->DUM_PESOM3 } )
						Else
							AAdd( aLimite,{ cCliente, cLoja, cProduto, 0, 0, 0 } )
						EndIf
					Else
						If aDocto[ nCntFor, CTMARCA ]
							aLimite[nPos,4] += DUM->DUM_VALMER
							aLimite[nPos,5] += DUM->DUM_PESO
							aLimite[nPos,6] += DUM->DUM_PESOM3
						EndIf
					EndIf

					DUM->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
	If aDocto[ nCntFor, CTMARCA ]
		DT6->(DbSetOrder(1))
		If DT6->(MsSeek(xFilial('DT6')+aDocto[ nCntFor, CTFILDOC ] + aDocto[ nCntFor, CTDOCTO ] + aDocto[ nCntFor, CTSERIE ] ))
			nTotFreRec += DT6->DT6_VALFRE // Total do Frete a Receber dos Documentos da viagem
		EndIf
	EndIf
Next nCntFor

/* Verifica se o complemento de viagem foi efetuado. */
If Len(aCompViag) > 0 .And. !Empty(aCompViag[1]) .And. !Empty(aCompViag[2])
	aHeader  := AClone(aCompViag[1])  // aHeader DTR(Veiculos da Viagem).
	aCols    := AClone(aCompViag[2])  // aCols DTR(Veiculos da Viagem).

	DA3->( DbSetOrder( 1 ) )
	For nA := 1 To Len(aCols)
		If !GDDeleted( nA )
			cCodVei := GdFieldGet( "DTR_CODVEI", nA )
			nValFrePag := GdFieldGet( "DTR_VALFRE", nA )	// Valor do Frete a Pagar informado no Complemento da Viagem
			nTotFrePag += nValFrePag    // Total do Frete a Pagar (todos os veiculos do complemento)
			If	DA3->( MsSeek( xFilial('DA3') + cCodVei ) ) .And. DA3->DA3_ATIVO == StrZero( 1, Len( DA3->DA3_ATIVO ) )
				cChave 	:= DA3->DA3_TIPVEI
				cCodFor	:= DA3->DA3_CODFOR
				cLojFor 	:= DA3->DA3_LOJFOR
				cVeiRas  := DA3->DA3_VEIRAS
				AAdd( aVeiculos, {cCodVei,	GdFieldGet("DTR_QTDEIX",nA), GdFieldGet("DTR_QTEIXV",nA) } )
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
					AAdd(aVeiculos, {cCodRB1, 0, 0 })
				ElseIf nB == 2 .And. !Empty( GdFieldGet("DTR_CODRB2", nA) )
					cCodRb2 := GdFieldGet("DTR_CODRB2", nA)
					cCodReb := cCodRb2
					AAdd( aVeiculos, {cCodRB2, 0, 0 } )
				ElseIf nB == 3 .And. !Empty( GdFieldGet("DTR_CODRB3", nA) )
					cCodRb3 := GdFieldGet("DTR_CODRB3", nA)
					cCodReb := cCodRb3
					AAdd( aVeiculos, {cCodRB3, 0, 0 } )
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
                                M->DTQ_SERTMS, M->DTQ_TIPTRA,,,IIF(lTMSOPdg, aCompViag[11, 7], ''),,,Iif(lTipOpVg,M->DTQ_TPOPVG,''))

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
					AAdd(aValSeg, { DA4->DA4_COD, DA4->DA4_VALSEG } )
					AAdd( aBlqCarPer, { DA4->DA4_COD, DA4->DA4_CARPER } )
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
	aHeader := AClone(aCompViag[1])  // aHeader DTR(Veiculos da Viagem).
	aCols   := AClone(aCompViag[2])  // aCols DTR(Veiculos da Viagem).
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
				If !Empty(GDFieldGet('DTR_CODRB3'))
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
	aHeader := AClone(aCompViag[5]) // aHeader DUP(Motorista da Viagem).
	For nB := 1 To Len(aCompViag[6])
		aCols := AClone(aCompViag[6][nB][2]) // aCols DUP(Motorista da Viagem).
		For nA := 1 To Len(aCols)
			If !GDDeleted( nA )
				AAdd( aBlqDoctos[3], GdFieldGet("DUQ_CODAJU", nA) )
			EndIf
		Next nA
	Next nB
EndIf

TmsBlqViag( M->DTQ_FILORI, M->DTQ_VIAGEM, aLimite, nCapacM, aValSeg, cSerTms, , aBlqAnoVei, aBlqCarPer, nCapCav, aBlqFrtCar, nTotFrePag, nTotFreRec, aBlqDoctos )

RestInter()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA141VRt³ Autor ³ Alex Egydio           ³ Data ³25.04.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualisa Rotas                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141VRt()

Local aAreaAnt	:= GetArea()
Local aAreaDA8  := DA8->(GetArea())
Local cCadOld	:= cCadastro
Local nSeek		:= 0
Local lInclAux  := Inclui

Inclui := .F.

nSeek := TmsA140ChkRot('1')
If nSeek > 0
	DbSelectArea('DA8')
	DbSetOrder(1)
	If	DA8->(MsSeek(xFilial('DA8')+aRota[nSeek,2]))
		cCadastro := STR0046 //"Cadastro de Rotas"
		FWExecView (, "OMSA100" , 1 , ,{|| .T. }, , , , , , , )
	EndIf
EndIf

cCadastro := cCadOld
Inclui    := lInclAux
RestArea(aAreaDA8)
RestArea(aAreaAnt)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA141Dco³ Autor ³ Alex Egydio           ³ Data ³25.04.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualisa Documentos                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141Dco()

Local aAreaAnt	:= GetArea()
Local aAreaDT6	:= DT6->(GetArea())

DbSelectArea('DT6')
DbSetOrder(1)
If	DT6->( MsSeek( xFilial('DT6') + aDocto[oLbxDocto:nAT, CTFILDOC ] + aDocto[oLbxDocto:nAT, CTDOCTO ] + aDocto[oLbxDocto:nAT, CTSERIE ] ) )
	TmsA500Mnt('DT6', Recno(), 2 )
EndIf

RestArea(aAreaDT6)
RestArea(aAreaAnt)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA141Zer³ Autor ³ Alex Egydio           ³ Data ³15.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Zera vetor utilizado no listbox.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Listbox 1=Rota,2=Zona,3=Setor,4=Documento          ³±±
±±³          ³ ExpL1 = .T. refresh no listbox                             ³±±
±±³          ³ ExpL1 = .T. zera os totalizadores do vetor aRota           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141Zer( nTela, lAtzLbx, lTotal )

Local aLinha	:= {}
Local nCntFor	:= 0

DEFAULT lAtzLbx := .F.
DEFAULT lTotal	:= .T.

If	nTela == 1			//-- Rota
	If	lTotal
		For nCntFor := 1 To Len( aRota )
			aRota[ nCntFor, 5 ] := 0
			aRota[ nCntFor, 6 ] := 0
			aRota[ nCntFor, 7 ] := 0
			aRota[ nCntFor, 8 ] := 0
			aRota[ nCntFor, 9 ] := .F.
		Next
	Else
		aRota := {}
		AAdd( aRota, { .F., Space(Len(DA8->DA8_COD)), Space(Len(DA8->DA8_DESC)), Space(15), 0, 0, 0, 0 , .F.}	 )
	EndIf
ElseIf nTela == 2		//-- Zona
	aZona	:= {}
	AAdd( aZona, { .F., Space(Len(DA5->DA5_COD)), Space(Len(DA5->DA5_DESC)), Space(Len(DA8->DA8_COD)) } )
ElseIf nTela == 3		//-- Setor
	aSetor := {}
	AAdd( aSetor, { .F., Space(Len(DA6->DA6_ROTA)), Space(Len(DA6->DA6_REF)), Space(Len(DA8->DA8_COD)), Space(Len(DA5->DA5_COD)), , Space(Len(DA5->DA5_FILIAL)) } )
ElseIf nTela == 4		//-- Documento
	aDocto := {}

	AAdd(aLinha, '' )
	AAdd(aLinha, '' )
	AAdd(aLinha, .F. )
	AAdd(aLinha, Space(Len(DUD->DUD_SEQUEN	)) )
	AAdd(aLinha, Space(Len(DUH->DUH_LOCAL	)) )
	AAdd(aLinha, Space(Len(DUH->DUH_LOCALI	)) )
	AAdd(aLinha, Space(Len(DUD->DUD_FILDOC	)) )
	AAdd(aLinha, Space(Len(DUD->DUD_DOC		)) )
	AAdd(aLinha, Space(Len(DUD->DUD_SERIE	)) )
	AAdd(aLinha, '' )
	AAdd(aLinha, CtoD('') )
	AAdd(aLinha, CtoD('') )
	AAdd(aLinha, Space(Len(SA1->A1_NREDUZ	)) )
	AAdd(aLinha, Space(Len(SA1->A1_NREDUZ	)) )
	AAdd(aLinha, 0 )
	AAdd(aLinha, 0 )
	AAdd(aLinha, 0 )
	AAdd(aLinha, 0 )
	AAdd(aLinha, 0 )
	AAdd(aLinha, .F. )
	AAdd(aLinha, Space(Len(DA7->DA7_SEQUEN	)) ) // CTSEQDA7
	AAdd(aLinha, Space(Len(DUE->DUE_NOME	)) )
	AAdd(aLinha, Space(Len(DUE->DUE_END		)) )
	AAdd(aLinha, Space(Len(DUE->DUE_BAIRRO	)) )
	AAdd(aLinha, Space(Len(DUE->DUE_MUN		)) )
	AAdd(aLinha, CtoD('') )
	AAdd(aLinha, Space(Len(DT5->DT5_HORSOL	)) )
	AAdd(aLinha, CtoD('') )
	AAdd(aLinha, Space(Len(DT5->DT5_HORPRV	)) )
	AAdd(aLinha, '' )
	AAdd(aLinha, '' )
	//-- Inicializa as colunas Agendamento, Item e Serv. Transp.
	AAdd(aLinha, Space(Len(DF1->DF1_NUMAGE)) )
	AAdd(aLinha, Space(Len(DF1->DF1_ITEAGE)) )
	AAdd(aLinha, Space(Len(DC5->DC5_SERTMS)) )
	AAdd(aLinha, Space(10) )
	//-- Inicializa as colunas de Agendamento de Entrega
	AAdd(aLinha, '' )
	AAdd(aLinha, "PMSEDT3" )
	AAdd(aLinha, '' )
	AAdd(aLinha, '' )
	AAdd(aLinha, '' )
	AAdd(aLinha, '' )
	AAdd(aLinha, '' )
	AAdd(aLinha, '' )

	AAdd(aDocto,AClone(aLinha))
EndIf

If lAtzLbx
	TmsA141Rfr( nTela )
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA141Rfr³ Autor ³ Alex Egydio           ³ Data ³15.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Refresh no listbox.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141Rfr( nTela )

If	nTela == 1									//-- Rota
	If	ValType(oLbxRota) == 'O'

		oLbxRota:SetArray( aRota )

		//-- Monta o bLine do listbox.
		TmsA141bLi( nTela )

		oLbxRota:Refresh()

	EndIf
ElseIf nTela == 2								//-- Zona
	If	ValType(oLbxZona) == 'O'

		oLbxZona:SetArray( aZona )

		//-- Monta o bLine do listbox.
		TmsA141bLi( nTela )

		oLbxZona:Refresh()

	EndIf
ElseIf nTela == 3								//-- Setor
	If	ValType(oLbxSetor) == 'O'

		oLbxSetor:SetArray( aSetor )

		//-- Monta o bLine do listbox.
		TmsA141bLi( nTela )

		oLbxSetor:Refresh()

	EndIf
ElseIf nTela == 4								//-- Documento
	If	ValType(oLbxDocto) == 'O'

		oLbxDocto:SetArray( aDocto )

		//-- Monta o bLine do listbox.
		TmsA141bLi( nTela )

		oLbxDocto:Refresh()

	EndIf
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA141bLi³ Autor ³ Alex Egydio           ³ Data ³15.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o bLine dos objetos listbox                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA141bLi( nTela )

If	nTela == 1					//-- Rota

		oLbxRota:bLine	:= { || {	Iif(aRota[oLbxRota:nAT,1] , oMarked, oNoMarked ), aRota[oLbxRota:nAT,2],;
									aRota[oLbxRota:nAT,3], aRota[oLbxRota:nAT,4],;
									Transform(aRota[oLbxRota:nAT,5],PesqPict('DT6','DT6_QTDVOL',6)),;
									Transform(aRota[oLbxRota:nAT,6],PesqPict('DT6','DT6_VOLORI',6)),;
									Transform(aRota[oLbxRota:nAT,7],PesqPict('DT6','DT6_PESO',15,4)),;
									Transform(aRota[oLbxRota:nAT,8],PesqPict('DT6','DT6_PESOM3',15,4)),;
									Transform(aRota[oLbxRota:nAT,9],PesqPict('DT6','DT6_VALMER',16,2)) } }

ElseIf nTela == 2				//-- Zona
	oLbxZona:bLine	:= { || {	Iif(aZona[oLbxZona:nAT,1] , oMarked, oNoMarked ), aZona[oLbxZona:nAT,2],;
								aZona[oLbxZona:nAT,3], aZona[oLbxZona:nAT,4] } }

ElseIf nTela == 3				//-- Setor
	oLbxSetor:bLine	:= { || {	Iif(aSetor[oLbxSetor:nAT,1] , oMarked, oNoMarked ), aSetor[oLbxSetor:nAT,2],;
								aSetor[oLbxSetor:nAT,3], aSetor[oLbxSetor:nAT,4], aSetor[oLbxSetor:nAT,5] } }

ElseIf nTela == 4				//-- Documento
	oLbxDocto:bLine := &('{ || TMSA141Line(oLbxDocto:nAT) }')
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA141All³ Autor ³ Alex Egydio           ³ Data ³05.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/desmarca todos os documentos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141All(lAllMark,lEntrega,nOpcx)

Local aAreaDT6 := DT6->(GetArea())
Local nCntFor  := 0
Local lRet     := .T.
Local aMsgErr  := {}

DEFAULT lEntrega := .F.

If ! lColeta
	For nCntFor := 1 To Len( aDocto )
		If	! lEntrega .Or. (lEntrega .And. nRotPor != 2)
			//-- Verifica se houve enderecamento
			If	! TmsSldDist(aDocto[nCntFor,CTFILDOC],aDocto[nCntFor,CTDOCTO],aDocto[nCntFor,CTSERIE])
				lRet := .F.
				Exit
			EndIf
		EndIf
		//-- Selecionar documento, somente se a operacao de descarregamento foi executada

		If lContDCA //parametro MV_CONTDCA Controle de descarga
			If	aDocto[nCntFor,CTBLQDOC]==StrZero(3,Len(DT6->DT6_BLQDOC))
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
		If	TmsA141MOk(nCntFor,nOpcx, @aMsgErr, lAllMark)
			aDocto[ nCntFor, CTMARCA ] := lAllMark
		EndIf
	Next
	If !Empty(aMsgErr)
		TmsMsgErr( aMsgErr )
	EndIf
	oLbxDocto:Refresh()
	//-- Atualizando o Rodape
	TMSA141Rdp()
EndIf
RestArea(aAreaDT6)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA141Mrk³ Autor ³ Alex Egydio           ³ Data ³15.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca itens do listbox                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Identifica o listbox                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA141Mrk( nTela, nOpcx )

Local aAreaDT6 := DT6->(GetArea())
Local cChave   := ''
Local cRota	   := ''
Local cZona	   := ''
Local lAllMrk  := .T.
Local n1Cnt	   := 0
Local nCntFor  := 0
Local nSeek    := 0
Local nNextAge := 0
Local lNextAge := .T.
Local lMarcAge := .T.
Local nAtDoc   := 0
Local cDocto   := ''
Local aMsgErr  := {}
Local lRetPE   := .T.
Local lRet     := .T.
Local lAgdEntr := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)   //-- Agendamento de Entrega.
Local aValAgend := {}
If nOpcx == 2 .Or. nOpcx == 5
	Return( .T. )
EndIf

If nTela <> 4
	nVolumes := 0
	nPesReal := 0
	nPesCub  := 0
	nValMerc := 0
	nDoctos  := 0	
	oDoctos:Refresh()
	oVolumes:Refresh()
	oPesReal:Refresh()
	oPesCub:Refresh()
	oValMerc:Refresh()
EndIf

If	nTela == 1		//-- Rota

	nSeek := TmsA140ChkRot('1')

	If Empty(aRota[oLbxRota:nAT,2])
		Return( .T. )
	EndIf

	aRota[ oLbxRota:nAT, 1 ]:=!aRota[ oLbxRota:nAT, 1 ]
	For nCntFor := 1 To Len( aRota )
		If	nCntFor != oLbxRota:nAT
			aRota[ nCntFor, 1 ] := .F.
		EndIf
	Next
	oLbxRota:Refresh()
	//-- Zera os vetores zona, setor e documento
	TMSA141Zer(2,.T.)
	TMSA141Zer(3,.T.)
	TMSA141Zer(4,.T.)

	If	aRota[oLbxRota:nAT,1] .And. (nTipVia == 1 .OR. nTipVia == 3)  //-- Normal / Planejada
		//-- Se marcou a rota, mostrar as zonas, setores e documentos
		CursorWait()
		MsgRun(STR0047,,{|| TmsA141ZSt(aRota[oLbxRota:nAT,2],,nOpcx) })  // "Aguarde, verificando documentos"
		CursorArrow()
		TmsA141Doc( nOpcx )
	EndIf

	TmsA141All(lAllMark, !lColeta, nOpcx )
	
ElseIf nTela == 2				//-- Zona
	If Empty(aZona[oLbxZona:nAT,2])
		Return( .T. )
	EndIf
	aZona[ oLbxZona:nAT, 1 ]:=!aZona[ oLbxZona:nAT, 1 ]
	//-- Marca/desmarca setores da zona
	TmsA141M_D( aZona[oLbxZona:nAT,4], aZona[oLbxZona:nAT,2], aZona[ oLbxZona:nAT, 1 ], 3 )
	TmsA141Doc( nOpcx )

	TmsA141All(lAllMark, !lColeta, nOpcx )

ElseIf nTela == 3				//-- Setor
	If Empty(aSetor[oLbxSetor:nAT,2])
		Return( .T. )
	EndIf
	aSetor[ oLbxSetor:nAT, 1 ]:=!aSetor[ oLbxSetor:nAT, 1 ]

	cRota := aSetor[oLbxSetor:nAT,4]
	cZona := aSetor[oLbxSetor:nAT,5]

	If !aSetor[ oLbxSetor:nAT, 1 ]
		//-- Verifica se marcou/desmarcou todos os setores da rota e zona
		For nCntFor := 1 To Len(aSetor)
			If	aSetor[nCntFor,4] + aSetor[nCntFor,5] == cRota + cZona .And. aSetor[nCntFor,1] != aSetor[ oLbxSetor:nAT, 1 ]
				lAllMrk := .F.
				Exit
			EndIf
		Next
	EndIf

	If lAllMrk
		//-- Marca/desmarca zona
		TmsA141M_D( cRota, cZona, aSetor[ oLbxSetor:nAT, 1 ], 2 )
	EndIf
	TmsA141Doc( nOpcx )
	TmsA141All( lAllMark , !lColeta, nOpcx )
ElseIf nTela == 4				//-- Documento
	//-- Condicoes nas quais nao deve alterar a marca do documento
	If	!TmsA141MOk(oLbxDocto:nAT,nOpcx,@aMsgErr,.T.)
		If !Empty(aMsgErr)
			TmsMsgErr( aMsgErr )
		EndIf
		Return( .T. )
	EndIf
	// Valida o Agendamento de entrega
   If lAgdEntr .AND.	!aDocto[oLbxDocto:nAT, CTMARCA ] .AND. aDocto[oLbxDocto:nAT, CTSERTMS ] == StrZero( 3, Len( DC5->DC5_SERTMS ) )
		aValAgend := TMSAgdVgVl(aDocto[oLbxDocto:nAT,CTFILDOC],aDocto[oLbxDocto:nAT,CTDOCTO],aDocto[oLbxDocto:nAT,CTSERIE],dDataBase,SubStr(Time(),1,5) )
		If !aValAgend[1]
			If !MsgNoYes( aValAgend[2] +chr(13)+chr(10)+ STR0098 , STR0099 + aDocto[oLbxDocto:nAT,CTFILDOC]+"/"+aDocto[oLbxDocto:nAT,CTDOCTO]+"/"+aDocto[oLbxDocto:nAT,CTSERIE] )//"Deseja continuar ?" -- "Documento: "
				Return( .F. )
			Endif
		EndIf
	EndIf
	//-- Nao permite marcar documento na viagem que possua o mesmo documento cancelado.
	If Ascan(aDocto, { |x| x[CTFILDOC]+x[CTDOCTO]+x[CTSERIE]+x[CTSTATUS] == aDocto[oLbxDocto:nAT,CTFILDOC]+aDocto[oLbxDocto:nAT,CTDOCTO]+aDocto[oLbxDocto:nAT,CTSERIE]+StrZero(9,Len(DUD->DUD_STATUS)) } ) <> 0
		Help(" ",1,"TMSA14104") //"Existe documento nesta viagem com status cancelado."
		Return( .F. )
	EndIf
	If ! lColeta
		If	nRotPor != 2
			If	! TmsSldDist(aDocto[oLbxDocto:nAT,CTFILDOC],aDocto[oLbxDocto:nAT,CTDOCTO],aDocto[oLbxDocto:nAT,CTSERIE])
				Return( Nil )
			EndIf
		EndIf
		//-- Selecionar documento, somente se a operacao de descarregamento foi executada
		If lContDCA
			If	aDocto[oLbxDocto:nAT,CTBLQDOC]==StrZero(3,Len(DT6->DT6_BLQDOC))
				Help(' ', 1, 'TMSA14014')	//-- Operacao de descarregamento nao executada. (DTW)
			EndIf
		EndIf
	EndIf

	If ExistBlock("TM141COK")
		lRetPE := ExecBlock("TM141COK",.F.,.F.,{aDocto[oLbxDocto:nAT]})
		If ValType(lRetPE) == "L"
			lRet := lRetPE
		EndIf
	EndIf
	If lRet
		//-- Sem endereco
		//-- Marca/desmarca por nfc
		If Empty(aDocto[oLbxDocto:nAT,CTLOCALI])

			If lTmsCFec .And. lColeta
				lMarcAge := ( lTmsCFec .And. mv_par03 == 1 ) //-- Verifica se deve ser marcado todos documentos do mesmo agendamento.
				//-- Se estiver desmarcado, marca todos os itens do Agendamento.
				If	!( aDocto[oLbxDocto:nAT, CTMARCA ] )
					If lMarcAge
						cChave := aDocto[oLbxDocto:nAT,CTNUMAGE]
					Else
						cChave := aDocto[oLbxDocto:nAT,CTNUMAGE]+aDocto[oLbxDocto:nAT,CTITEAGE]
					EndIf

					//-- Se o numero do Agendamento estiver em branco, marca somente o item posicionado.
					If Empty( cChave )
						cDocto := aDocto[oLbxDocto:nAT,CTFILDOC]+aDocto[oLbxDocto:nAT,CTDOCTO]+aDocto[oLbxDocto:nAT,CTSERIE]
						For nAtDoc := 1 To Len( aDocto )
							If aDocto[nAtDoc,CTFILDOC]+aDocto[nAtDoc,CTDOCTO]+aDocto[nAtDoc,CTSERIE] == cDocto
								aDocto[nAtDoc,CTMARCA] := .T.
							EndIf
						Next nAtDoc
					Else
						For nCntFor := 1 To Len( aDocto )
							If	( cChave == aDocto[nCntFor,CTNUMAGE] ) .Or. ( cChave == aDocto[nCntFor,CTNUMAGE]+aDocto[nCntFor,CTITEAGE] )
								aDocto[nCntFor,CTMARCA] := .T.
								If lNextAge
									nNextAge := nCntFor
								EndIf
							EndIf
						Next
						//-- Obtem a posicao do proximo item.
						If lNextAge
							nNextAge += 1
							If nNextAge >= Len( aDocto )
								nNextAge := 0
							EndIf
						EndIf
					EndIf
				Else
					//-- Desmarca item de coleta e entrega(se existir).
					cChave := aDocto[oLbxDocto:nAT,CTNUMAGE] + aDocto[oLbxDocto:nAT,CTITEAGE]

					//-- Se o numero do Agendamento estiver em branco, desmarca somente o item posicionado.
					If Empty( cChave )
						cDocto := aDocto[oLbxDocto:nAT,CTFILDOC]+aDocto[oLbxDocto:nAT,CTDOCTO]+aDocto[oLbxDocto:nAT,CTSERIE]
						For nAtDoc := 1 To Len( aDocto )
							If aDocto[nAtDoc,CTFILDOC]+aDocto[nAtDoc,CTDOCTO]+aDocto[nAtDoc,CTSERIE] == cDocto
								aDocto[nAtDoc,CTMARCA] := .F.
							EndIf
						Next nAtDoc
					Else
						For nCntFor := 1 To Len( aDocto )
							If	cChave == aDocto[nCntFor,CTNUMAGE] + aDocto[nCntFor,CTITEAGE]
								aDocto[nCntFor, CTMARCA ] := .F.
							EndIf
						Next
					EndIf
				EndIf

				//-- Posiciona no proximo Agendamento para facilitar a selecao.
				If lNextAge .And. nNextAge != 0
					oLbxDocto:nAT := nNextAge
				EndIf
			Else
				cChave := aDocto[oLbxDocto:nAT,CTFILDOC] + aDocto[oLbxDocto:nAT,CTDOCTO] + aDocto[oLbxDocto:nAT,CTSERIE]

				For nCntFor := 1 To Len( aDocto )
					If	cChave == aDocto[nCntFor,CTFILDOC] + aDocto[nCntFor,CTDOCTO] + aDocto[nCntFor,CTSERIE]
						aDocto[nCntFor,CTMARCA]:=!aDocto[nCntFor,CTMARCA]
					EndIf
				Next
			EndIf
		//-- Com endereco.
		Else
			//-- Se estiver marcado, desmarcar por nfc.
			If	aDocto[oLbxDocto:nAT, CTMARCA ]

				cChave := aDocto[oLbxDocto:nAT, CTFILDOC ] + aDocto[oLbxDocto:nAT, CTDOCTO ] + aDocto[oLbxDocto:nAT, CTSERIE ]

				For nCntFor := 1 To Len( aDocto )
					If	cChave == aDocto[nCntFor, CTFILDOC ] + aDocto[nCntFor, CTDOCTO ] + aDocto[nCntFor, CTSERIE ]
						aDocto[ nCntFor, CTMARCA ]:= .F.
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

					If	aDocto[nCntFor, CTMARCA ]

						cChave := aDocto[nCntFor, CTARMAZE ] + aDocto[nCntFor, CTFILDOC ] + aDocto[nCntFor, CTDOCTO ] + aDocto[nCntFor, CTSERIE ]

						For n1Cnt := 1 To Len( aDocto )
							If	cChave == aDocto[n1Cnt, CTARMAZE ] + aDocto[n1Cnt, CTFILDOC ] + aDocto[n1Cnt, CTDOCTO ] + aDocto[n1Cnt, CTSERIE ] .And. ! aDocto[ n1Cnt, CTMARCA ]
								aDocto[ n1Cnt, CTMARCA ] := .T.
							EndIf
						Next

   					EndIf

				Next

			EndIf

		EndIf

	EndIf
	oLbxDocto:Refresh()
	//-- Atualizando o Rodape
	TMSA141Rdp()
EndIf
RestArea(aAreaDT6)
Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA141ZSt³ Autor ³ Alex Egydio           ³ Data ³15.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Identifica a Zona e Setor ao selecionar a Rota             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Rota                                     ³±±
±±³          ³ ExpL1 = .T. Qdo for viagem diversa, apenas preenche os     ³±±
±±³          ³         vetores aZona e aSetor sem atualizar os listbox    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141ZSt( cRota, lDiversa ,nOpcx,lAddDoc, lVgeExpr)

Local cZona		 := ''
Local nCntFor	 := 0
Local n1Cnt		 := 0
Local cQuery     := ''

DEFAULT lDiversa := .F.
Default lAddDoc   := .T.
Default lVgeExpr := .F.

If lVgeMod2 == Nil
	lVgeMod2 := ('TMSA144' $ AllTrim(FunName()) .Or. lVgeExpr)
EndIf

aZona  := {}
aSetor := {}

For nCntFor := 1 To Len(aAllZona)
	If	aAllZona[nCntFor,4]==cRota
		AAdd(aZona,AClone(aAllZona[nCntFor]))
		cZona := aAllZona[nCntFor,2]
		For n1Cnt := 1 To Len(aAllSetor)
			If	aAllSetor[n1Cnt,4]==cRota .And. aAllSetor[n1Cnt,5]==cZona
				AAdd(aSetor,AClone(aAllSetor[n1Cnt]))
			EndIf
		Next
	EndIf
Next

cQuery := TM141Query(nOpcx,cRota)
cAliasNew := GetNextAlias()
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)

If lColeta
	TCSetField(cAliasNew,"DT5_DATPRV","D",8,0)
	TCSetField(cAliasNew,"DT5_DATSOL","D",8,0)
EndIf
TCSetField(cAliasNew,"DT6_DATEMI","D",8,0)
TCSetField(cAliasNew,"DT6_PRZENT","D",8,0)
TCSetField(cAliasNew,"DT6_QTDVOL","N",TamSx3("DT6_QTDVOL")[1],TamSx3("DT6_QTDVOL")[2])
TCSetField(cAliasNew,"DT6_PESO"  ,"N",TamSx3("DT6_PESO"  )[1],TamSx3("DT6_PESO"  )[2])
TCSetField(cAliasNew,"DT6_PESOM3","N",TamSx3("DT6_PESOM3")[1],TamSx3("DT6_PESOM3")[2])
TCSetField(cAliasNew,"DT6_VALMER","N",TamSx3("DT6_VALMER")[1],TamSx3("DT6_VALMER")[2])

If !lVgeMod2 .And. lTmsCFec .And. lColeta
	TCSetField(cAliasNew,"DT5_DATENT","D",8,0)
EndIF

cQuery := ""

aAllDocto := {}
While (cAliasNew)->(!Eof())
	If lVgeMod2
		TmsA141Add(,cAliasNew,,cRota,,,,nOpcx,lVgeExpr)
	Else
		TmsA141Add(,cAliasNew,(cAliasNew)->DA7_SEQUEN,cRota,(cAliasNew)->DA7_PERCUR , (cAliasNew)->DA7_ROTA ,lAddDoc, nOpcx)
	EndIf
	(cAliasNew)->( DbSkip() )
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formato do vetor aDocto                                                ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ aDocto[01] = Status da movimentacao                                    ³
//³ aDocto[02] = Status da rota sem uso no tmsa141                         |
//³ aDocto[03] = Mark                                                      ³
//| aDocto[04] = Sequencia de entrega                                      ³
//³ aDocto[05] = Armazen                                                   ³
//³ aDocto[06] = Endereco                                                  ³
//| aDocto[07] = FilDoc                                                    ³
//³ aDocto[08] = Doc                                                       ³
//³ aDocto[09] = Serie                                                     ³
//| aDocto[10] = Regiao destino sem uso no tmsa141                         ³
//³ aDocto[11] = Data de Emissao                                           ³
//³ aDocto[12] = Prazo de Entrega                                          ³
//| aDocto[13] = Descricao do Grupo de produtos                            ³
//³ aDocto[14] = Nome do solicitante                                       ³
//³ aDocto[15] = Nome reduzido do cliente (usado so para viagem de entrega)³
//| aDocto[16] = Quantidade do Volume                                      ³
//³ aDocto[17] = Peso                                                      ³
//³ aDocto[18] = Peso cubado                                               ³
//| aDocto[19] = Valor da mercadoria                                       ³
//³ aDocto[20] =                                                           ³
//³ aDocto[21] = Sequencia de entrega                                      ³
//| aDocto[22] = Nome do solicitante                                       ³
//³ aDocto[23] = Endereco do solicitante                                   ³
//³ aDocto[24] = Municipio do solicitante                                  ³
//| aDocto[25] = Data da solicitacao                                       ³
//³ aDocto[26] = Hora da solicitacao                                       ³
//³ aDocto[27] = Data prevista                                             ³
//| aDocto[28] = Hora prevista                                             ³
//³ aDocto[29] = Rota + Zona + Setor                                       ³
//| aDocto[30] = Bloqueio de documento                                     ³
//³ Elemento utilizados para Carga Fechada( MV_TMSCFEC == .T. ) :          ³
//³ aDocto[31] = Numero do Agendamento                                     ³
//| aDocto[32] = Item do Agendamento                                       ³
//³ aDocto[33] = Tipo do Servico                                           ³
//| aDocto[34] = Descricao do Servico                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//-- Fecha a query
(cAliasNew)->(DbCloseArea())

If	!lDiversa
	If Empty( aZona )
		//-- Preenche o vetor aZona com branco
		TmsA141Zer(2,.T.)
	Else
		//-- Refresh no listbox de Zona
		TmsA141Rfr( 2 )
	EndIf

	If Empty( aSetor )
		//-- Preenche o vetor aSetor com branco
		TmsA141Zer(3,.T.)
	Else
		//-- Refresh no listbox de Setor
		TmsA141Rfr( 3 )
	EndIf
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA141M_D³ Autor ³ Alex Egydio           ³ Data ³16.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/desmarca vetores conforme zona/setor selecionado     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da rota                                     ³±±
±±³          ³ ExpC2 = Codigo da zona                                     ³±±
±±³          ³ ExpL1 = .T. = Marcado / .F. = Desmarcado                   ³±±
±±³          ³ ExpN1 = marcar/desmar listbox 1=Rota/2=Zona/3=Setor        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA141M_D( cRota, cZona, lMarca, nTela )

Local nCntFor	:= 0

If nTela == 1				//-- Rota
ElseIf nTela == 2			//-- Zona
	For nCntFor := 1 To Len( aZona )
		If	aZona[nCntFor,4] + aZona[nCntFor,2] == cRota + cZona
			aZona[nCntFor,1] := lMarca
		EndIf
	Next
ElseIf nTela == 3			//-- Setor
	For nCntFor := 1 To Len(aSetor)
		//-- Procura a rota e zona no setor asetor
		If aSetor[nCntFor,4] + aSetor[nCntFor,5] == cRota + cZona
			aSetor[nCntFor,1] := lMarca
		EndIf
	Next
ElseIf nTela == 4			//-- Documento
EndIf
//-- Refresh no listbox
TmsA141Rfr( nTela )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA141Doc³ Autor ³ Alex Egydio           ³ Data ³17.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Identifica os documentos da Rota, Zona e Setor             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao de manutencao                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA141Doc( nOpcx )

Local cSetor  := ''
Local nCntFor := 0
Local nSeek   := 0
Local nSeekZ  := 0
Local nSeeks  := 0
Local cRota
Local lFiltro := Type("cSerAdi") <> "U" .And. cSerAdi == "1" .And. nOpcx == 4 .And. DTQ->DTQ_STATUS == '2'

nSeek := TmsA140ChkRot('1')

If	nSeek > 0
	cRota := aRota[nSeek,2] //Pega a rota selecionada
EndIf

aDocto := {}

For nCntFor := 1 To Len(aAllDocto)
	If AScan(aDocto,{|x|  x[CTARMAZE] + x[CTLOCALI] + x[CTFILDOC] + x[CTDOCTO] + x[CTSERIE] == aAllDocto[nCntFor,CTARMAZE] + aAllDocto[nCntFor,CTLOCALI] + aAllDocto[nCntFor,CTFILDOC] + aAllDocto[nCntFor,CTDOCTO] + aAllDocto[nCntFor,CTSERIE] }) <= 0 .Or.;
		( lTmsCFec .And. lColeta .And. aAllDocto[nCntFor,CTSERTMS ] == StrZero( 3, Len( DC5->DC5_SERTMS ) ) ) //-- Como o item foi duplicado para representar a Entrega, adiciona no array principal( aDocto ).

		If	Subs(aAllDocto[nCntFor,CTDOCROT ] , 1 , Len(DA8->DA8_COD) )  == cRota  .Or. aAllDocto[nCntFor,CTMARCA]

			cZona  := Subs(aAllDocto[nCntFor,CTDOCROT] , Len(DA8->DA8_COD) + 1 , Len(DA5->DA5_COD) )
			cSetor := Subs(aAllDocto[nCntFor,CTDOCROT] , Len(DA8->DA8_COD) + Len(DA5->DA5_COD)  + 1, Len(DA6->DA6_ROTA) )
			nSeekZ := AScan(aZona ,{|x|x[2]== cZona } )
			nSeekS := AScan(aSetor,{|x|x[2]+x[5]== cSetor + cZona} )

			If ( nSeekZ > 0 .And. nSeekS > 0 .And. aZona[nSeekZ,1] .And. aSetor[nSeeks,1] )  .And. Iif(lFiltro,aAllDocto[nCntFor][CTSERTMS] == cSerAdi,.T.)
				AAdd(aDocto,AClone(aAllDocto[nCntFor]))

				If nSeek > 0 .And. !aRota[nSeek,9] .And. aDocto[Len(aDocto),CTSTATUS] <> StrZero(1,Len(DUD->DUD_STATUS))
					aRota[nSeek,9] := .T.
				EndIf
			EndIf
		EndIf
	EndIf
Next

If Empty( aDocto )
	//-- Preenche o vetor aDocto com branco
	TmsA141Zer(4,.T.)
Else

	If nOpcx <> 4
		If lTmsCFec .And. lColeta
			ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[CTNUMAGE] + x[ CTITEAGE ] + x[ CTSERTMS ] < y[CTSEQUEN] + y[CTNUMAGE] + y[ CTITEAGE ] + y[ CTSERTMS ] })
		Else
			ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[ CTARMAZE ] + x[ CTLOCALI ] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] <  y[CTSEQUEN] + y[ CTARMAZE ] + y[ CTLOCALI ] + y[ CTFILDOC ] + y[ CTDOCTO ] + y[ CTSERIE ] })
		EndIf
	Else
		If lTmsCFec .And. lColeta
			//-- Se os documentos foram sequenciados, ordena o array pela sequencia. Caso contrario, ordena pela marca.
			If Ascan( aDocto,{ | x | x[ CTSEQUEN ] != Replicate( 'x', Len( DUD->DUD_SEQUEN ) ) } ) > 0
				ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[CTNUMAGE] + x[ CTITEAGE ] + x[ CTSERTMS ] < y[CTSEQUEN] + y[CTNUMAGE] + y[ CTITEAGE ] + y[ CTSERTMS ] })
			Else
				ASort( aDocto,,,{|x,y| x[CTMARCA] >  y[CTMARCA ] })
			EndIf
		Else
			//-- Se os documentos foram sequenciados, ordena o array pela sequencia. Caso contrario, ordena pela marca.
			If Ascan( aDocto,{ | x | x[ CTSEQUEN ] != Replicate( 'x', Len( DUD->DUD_SEQUEN ) ) } ) > 0
				ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[ CTFILDOC ] + x[ CTDOCTO ] + x[ CTSERIE ] < y[CTSEQUEN] + y[ CTFILDOC ] + y[ CTDOCTO ] + y[ CTSERIE ] })
			Else
				ASort( aDocto,,,{|x,y| x[CTMARCA] >  y[CTMARCA ] })
			EndIf
		EndIf
	EndIf
	//-- Refresh no listbox de Rotas, p/totalizadores
	If	ValType(oLbxRota) == 'O'
		oLbxRota:Refresh()
	EndIf
	//-- Refresh no listbox de Documentos
	TmsA141Rfr( 4 )
	//-- Na alteracao, guardo os documentos da viagem no vetor aBkpDocto
	If	nOpcx == 4 .And. Empty( aBkpDocto )
		For nCntFor := 1 To Len( aDocto )
			If	aDocto[ nCntFor, CTVIAGEM ]

				AAdd( aBkpDocto, aDocto[ nCntFor ] )

			EndIf
		Next
	EndIf
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA141Grv³ Autor ³ Alex Egydio           ³ Data ³31.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava / Estorna Viagens                                    ³±±
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
Function TMSA141Grv( nOpcx, lVgeExpr, lGrvExpr, dDatGer, cHorGer, nPosDTQ,lValBlq)
//-- Ponto de Entrada chamado apos a inclusao, alteracao ou exclusao da Viagem de Entrega/Coleta

Local aAreaAnt   := GetArea()
Local aAreaDTQ   := DTQ->(GetArea())
Local aAreaDUD   := DUD->(GetArea())
Local bCampo     := { |nCpo| Field(nCpo) }
Local cMemo      := ''
Local lCarreg    := .F.
Local lStatus    := .F.
Local nRota      := 0
Local nDocto     := 0
Local nCntFor    := 0
Local aRegioes   := {}
Local cSeekDUD   := ''
Local cCodUsr    := RetCodUsr()
Local lExstMemos := .T. // Type('aMemos') == 'A'
Local lExtRedVge := Type('aRedVge') == "A"
Local lExtBkpDc  := Type('aBkpDocto') == "A"
//-- Verifica se existem os campos de planejamento na base.
Local lRet       := .T.
//-- Operadoras de Frota/Vale-Pedagio
Local lTMSOPdg   := SuperGetMV( 'MV_TMSOPDG',, '0' ) <> '0'
Local aAvaliaBlq := {}
Local lDTRTPSPDG := DTR->(ColumnPos("DTR_TPSPDG")) > 0
//-- Redespacho
Local lTM141FGRV := ExistBlock('TM141FGRV')
Local lTM141DUD  := ExistBlock("TM141DUD")
Local lTM141EST  := ExistBlock("TM141EST")
Local aPosicao   := {}
Local lAltRota   := .F.
Local lRotAut    := FindFunction("F11RotRote") .AND. F11RotRote(M->DTQ_ROTA)
Local lTmsa029   := FindFunction("TMSA029USE")
//-- unitizador
Local aUnitiz	 := {}
//--
Local cSeekDJM := ""
Local lRetDJM  := .T.
Local oMdlDJM
Local lTMS3GFE := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local cHoraReg := StrTran(Left(Time(),5),':','')
//--Documentos não previstos
Local cCodCli		:= ""
Local cLojaCli		:= ""
Local nSeqAcols
Local aAreaBkp		:= {}
Local nRegDTQ		:= 0
Local lOperCli		:= Len(GetSrcArray("TMSXFUNX.PRW")) > 0 
Local lAptOper		:= .T. //--Define se a operação(DTW) gerada na alteração da viagem, será apontada automaticamente.
Local cCliDes		:= ""
Local cLojDes		:= ""
Local cUfAtiv		:= ""
//--Gestão de demandas
Local lMVITMSDMD := SuperGetMv("MV_ITMSDMD",,.F.)

Local lTMSDCol := SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.
Local lAltTipOpVg:= .F.
Local lTipOpVg   := DTQ->(ColumnPos("DTQ_TPOPVG")) > 0
Local lMostra240 := .T.

Local cAtvSaiCli	:= SuperGetMv('MV_ATVSAIC',,'')//-- Atividade de Saída do cliente
Local cAtvChgCli  	:= SuperGetMv('MV_ATVCHGC',,'')//-- Atividade de Chegada do cliente
Local cQuery		:= ""
Local cAliasNew		:= ""
Local aRetDTW		:= {}
Local nPSequen		:= 0

If Type('aHeader') == 'U'
	Private aHeader    := {}
EndIf

If Type('aCols') == 'U'
	Private aCols    := {}
EndIf

Default lVgeExpr := .F.
Default lGrvExpr := .F.   //Controle da viagem EXPRESS ao gravar os dados das despesas
Default dDatGer  := dDataBase
Default cHorGer  := StrTran(Left(Time(),5),':','')
Default nPosDTQ  := 0
Default lValBlq  := .T.

If Type('cSerAdi') == 'U'
	cSerAdi := ''
EndIf

If Type('cRotaInf') == 'U'
	cRotaInf := ''
EndIf

If Type('cTipOpVgAnt') == 'U'
	cTipOpVgAnt := ''
EndIf
AAdd( aPosicao, CTMARCA )
AAdd( aPosicao, CTFILDOC)
AAdd( aPosicao, CTDOCTO )
AAdd( aPosicao, CTSERIE )

If nOpcx == 5 //-- Excluir
	Begin Transaction
		For nRota := 1 To Len( aRota )
			//-- Verifica se marcou uma rota.
			If	aRota[ nRota, 1 ]

				//-- Se houver documentos carregados, a exclusao da viagem sera permitida apos o
				//-- estorno do carregamento.
				If	aRota[ nRota, 9 ]
					Help(' ', 1, 'TMSA14009')		//-- Ha documentos carregados nesta viagem.
					Exit
				EndIf

				DTQ->( DbSetOrder( 2 ) )
				If	DTQ->( MsSeek( xFilial('DTQ') + M->DTQ_FILORI + M->DTQ_VIAGEM, .F. ) )
					RecLock('DTQ',.F.,.T.)
					DTQ->(DbDelete())
					MsUnLock()
				EndIf

				//-- Exclui Dados Da Tabela DIY (Restrições da Viagem)--//
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
				DTP->( DbSetOrder( 3 ) )
				While DTP->( MsSeek( xFilial('DTP') + M->DTQ_FILORI + M->DTQ_VIAGEM ) )
					RecLock('DTP',.F.,.T.)
					DTP->DTP_VIAGEM := ""
					MsUnLock()
				EndDo

				For nDocto := 1 To Len( aDocto )
					If cSerTms == StrZero(3,Len(DC5->DC5_SERTMS)) //Entrega
						Tmsa141SEnt(aDocto[nDocto, CTFILDOC], aDocto[nDocto, CTDOCTO ], aDocto[nDocto, CTSERIE ], aDocto[ nDocto, CTSEQUEN ],.T.)
					EndIf
					//-- Verifica se marcou um documento.
					If	aDocto[ nDocto, CTMARCA ]
						TMSA141Del( aDocto[nDocto, CTFILDOC], aDocto[nDocto, CTDOCTO ], aDocto[nDocto, CTSERIE ], aDocto[nDocto, CTVIAGEM ] )
					EndIf
				Next

				//-- Exclui bloqueio da viagem.
				DUC->( DbSetOrder( 1 ) )
				While DUC->( MsSeek( xFilial('DUC') + M->DTQ_FILORI + M->DTQ_VIAGEM, .F. ) )
					If (DUC->DUC_CODBLQ == PadR('D1', Len(DUC->DUC_CODBLQ)) .Or.;
						DUC->DUC_CODBLQ == PadR('D2', Len(DUC->DUC_CODBLQ)) .Or.;
						DUC->DUC_CODBLQ == PadR('D3', Len(DUC->DUC_CODBLQ)) .Or.;
						DUC->DUC_CODBLQ == PadR('D4', Len(DUC->DUC_CODBLQ)))
						AAdd(aAvaliaBlq,{	DUC->DUC_CODBLQ,;
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
						// Caso Existam Bloqueios Antigos, Limpa Referencia - INCOMPATIBILIDADE e RRE
						Tmsa029Blq( 5  ,;				// 01 - nOpc
									'TMSA140',;		// 02 - Rotina
									Nil,;				// 03 - Tipo Bloq (Diverg. Produto)
									M->DTQ_FILORI,;	// 04 - Filial Origem
									'DUC',;			// 05 - Tabela Referencial
									'1',;				// 06 - Indice Da Tabela
									xFilial('DUC') + M->DTQ_FILORI + M->DTQ_VIAGEM,;	// 07 - Chave Indexação
									"",;				// 08 - Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
									"",;				// 09 - Detalhes Adicionais a Respeito Do Bloqueio
									nOpcx)				// 10 - Opcao da Rotina
					EndIf

					If Tmsa029Use("TMSA310")
						// Check List da Viagem
						Tmsa029Blq( 5  ,;				// 01 - nOpc
									'TMSA310',;			// 02 - Rotina
									'RR',;				// 03 - Tipo Bloq (Diverg. Produto)
								 	M->DTQ_FILORI,;		// 04 - Filial Origem
									'DTQ',;				// 05 - Tabela Referencial
									'1',;				// 06 - Indice Da Tabela
									xFilial('DTQ') + M->DTQ_FILORI + M->DTQ_VIAGEM,;	// 07 - Chave Indexação
									"",;				// 08 - Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
									"",;				// 09 - Detalhes Adicionais a Respeito Do Bloqueio
									nOpcx)				// 10 - Opcao da Rotina

						//-- Roteirizador 
						Tmsa029Blq( 5  			,;	//-- 01 - nOpc
								'TMSA310'		,;	//-- 02 - cRotina
								'RT'  			,;	//-- 03 - cTipBlq
								M->DTQ_FILORI	,;	//-- 04 - cFilOri
								'DTQ'	 		,;	//-- 05 - cTab
								'1' 			,;	//-- 06 - cInd
								xFilial('DTQ') + M->DTQ_FILORI + M->DTQ_VIAGEM,; //-- 07 - cChave
								"" 				,;	//-- 08 - cCod
								"" 				,;	//-- 09 - cDetalhe
								nOpcx)				//-- 10 - Opcao da Rotina

					EndIf
				EndIf

				//-- Cancela Programação de Carregamento
				DbSelectArea("DF8")
				DF8->( DbSetOrder( 2 ) ) //-- DF8_FILIAL+DF8_FILORI+DF8_VIAGEM
				If DbSeek(xFilial("DF8") + M->DTQ_FILORI + M->DTQ_VIAGEM)
					RecLock("DF8",.F.)
					DF8->DF8_STATUS:= '9'   //Cancelada
					DF8->(MsUnLock())

					//Cancela as coletas geradas pela gestao de demanda e retorna o planejamento para "Aberto com demandas"
					If lMVITMSDMD .And. DF8->(ColumnPos('DF8_PLNDMD')) > 0 .And. FindFunction('TMExVgDmd') .And. !IsInCallStack("TMSA146EST")
						TMExVgDmd(DF8->DF8_PLNDMD, 2)
					EndIf
				EndIf

				//-- Exclui complemento da viagem.
				RegToMemory('DTR',.T.)
				M->DTR_FILORI := M->DTQ_FILORI
				M->DTR_VIAGEM := M->DTQ_VIAGEM
				lRet := TmsA240Grv( 5 )

                    //| Se houve algum problema na integração de exclusão ou no processo de exclusão.
                    If !lRet
                        DisarmTransaction()
                        Break
                    EndIf

				// Exclui Rota Automatica
				If lRotAut
					TF10GrRote(5,M->DTQ_FILORI, M->DTQ_VIAGEM)
				EndIf

				If lTM141EST
					ExecBlock("TM141EST",.F.,.F.,{M->DTR_FILORI,M->DTR_VIAGEM})
				EndIf

			EndIf
		Next

		EvalTrigger()
		//Exclusao de Fornecedores Adicionais da Viagem
		If AliasIndic("DJM")
			DJM->(DbSetOrder(1)) //DJM_FILIAL+DJM_FILORI+DJM_VIAGEM+DJM_CODFOR+DJM_LOJFOR
			DJM->(MsSeek(cSeekDJM := FWxFilial('DJM') + M->DTQ_FILORI + M->DTQ_VIAGEM, .F.))
			While DJM->(!Eof() .And. DJM_FILIAL+DJM_FILORI+DJM_VIAGEM == cSeekDJM)
				oMdlDJM := FWLoadModel("TMSA151")
				oMdlDJM:SetOperation(MODEL_OPERATION_DELETE)
				oMdlDJM:Activate()
				If (lRetDJM := oMdlDJM:VldData())
					oMdlDJM:CommitData()
				EndIf
				oMdlDJM:DeActivate()
				oMdlDJM:Destroy()
				DJM->(DbSkip())
			EndDo
		EndIf

		//---- Atualiza dados da Viagem Modelo 3
		If lRet .And. lViagem3 .And. FindFunction('TmsAjuMod3')
			TmsAjuMod3(M->DTQ_FILORI,M->DTQ_VIAGEM,nOpcx,.T.)
		EndIf

	End Transaction
EndIf

If nOpcx == 3 .Or. nOpcx == 4 // Incluir ou Alterar.
	Begin Transaction
		For nRota := 1 To Len( aRota )
			//-- Verifica se marcou uma rota.
			If	aRota[ nRota, 1 ]
				//-- Se houve uma alteracao de rota, retirar o nr. de viagem de todos os documentos.
				If	nOpcx == 4
					DTQ->( DbSetOrder( 2 ) )
					DTQ->( MsSeek( xFilial('DTQ') + M->DTQ_FILORI + M->DTQ_VIAGEM, .F. ) )
					If DTQ->DTQ_ROTA != M->DTQ_ROTA .And. lExtBkpDc
						For nDocto := 1 To Len( aBkpDocto )
							If	aBkpDocto[nDocto,CTSTATUS]!=StrZero(3,Len(DUD->DUD_STATUS))
								TMSA141Del( aBkpDocto[nDocto, CTFILDOC], aBkpDocto[nDocto,CTDOCTO], aBkpDocto[nDocto,CTSERIE], aBkpDocto[nDocto,CTVIAGEM] )
							Else
								//-- Carregamento manual
								If	nCarreg > 1 .And. !lColeta
									lCarreg := .T.
								EndIf
							EndIf
						Next
						lAltRota := .T.
					EndIf
					If lTipOpVg .And. DTQ->DTQ_TPOPVG != M->DTQ_TPOPVG
						lAltTipOpVg := .T.
					EndIf 
				Else
					If !Empty(cRotaInf) .And. cRotaInf <> M->DTQ_ROTA   //Alteração da Rota na Inclusao da Viagem apos informar o Complemento para recalcular o frete
						lAltRota := .T.
					Endif
					If lTipOpVg .And.  AllTrim(cTipOpVgAnt) <> AllTrim(M->DTQ_TPOPVG)   //Alteração da Negociacao na Inclusao da Viagem apos informar o Complemento para recalcular o frete
						lAltTipOpVg := .T.
					Endif
				EndIf

				//-- Obtem as regioes da rota de transferencia
				If cSerTms == StrZero( 2, Len( DTQ->DTQ_SERTMS ) ) //-- Transporte
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Retorna as Filiais / Regioes de Descarga da Rota                      ³
					//³ Elementos contidos por dimensao:                                      ³
					//³ 1. Regiao Origem da Rota                                              ³
					//³ 2. Regioes de Descarga da Rota                                        ³
					//³ 3. Filiais de Descarga da Rota                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aRegioes:= TMSRegDca( aRota[ nRota, 2 ] )
					//-- Atribui a Filial de Destino
					If	! Empty( aRegioes )
						M->DTQ_FILDES := aRegioes[ Len( aRegioes ), 3 ]
					EndIf
				EndIf

				//-- Confirma a geracao da viagem.
				M->DTQ_ROTA		:= aRota[ nRota, 2 ]
				M->DTQ_TIPVIA	:= StrZero( nTipVia, Len( DTQ->DTQ_TIPVIA ) )
				If nOpcx == 3

					//-- Atualiza a database do sistema na virada do dia considerando permissão de troca de dias do usuário até 00:30
					If !IsBlind() .And. dDataBase <> Date() .And. dDataBase + 1 == Date() .And. MsgYesNo( STR0103 , STR0104 ) //-- "Deseja atualizar a data do sistema, de acordo com a data do servidor?" "Deseja atualizar a data?"
						FwDateUpd(.F. , .T. )
						dDatGer  := dDataBase
						cHorGer  := StrTran(Left(Time(),5),':','')
					EndIf

					M->DTQ_DATGER := dDatGer
					M->DTQ_HORGER := cHorGer
				EndIf

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
				//-- Grava os Campos Memos Virtuais.
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

				If lTmsCFec .And. lColeta
					//-- Ordena o array de documento para garantir a ordem correta de atualizacao( 1o - Coleta, 2o - Entrega( Se existir ) ).
					ASort( aDocto,,,{|x,y| x[CTSEQUEN] + x[CTNUMAGE] + x[ CTITEAGE ] + x[ CTSERTMS ] < y[CTSEQUEN] + y[CTNUMAGE] + y[ CTITEAGE ] + y[ CTSERTMS ] })
				EndIf

				//-- Se algum documento foi marcado, sera confirmado o carregamento gravando o numero
				//-- da viagem nos documentos.
				For nDocto := 1 To Len( aDocto )
					nSeqAcols = aScan( aCols, {|x|x[1] == aDocto[nDocto][4]} )
					//-- Verifica se marcou um documento.
					If	aDocto[ nDocto, CTMARCA ]
						//-- Verifica se o documento esta cancelado.
						If aDocto[ nDocto, CTSTATUS ] <> StrZero(9,Len(DUD->DUD_STATUS))
							If lTmsCFec .And. !lColeta
								//-- Quando o item for de entrega, somente atualiza a sequencia de entrega e o status do item do Agendamento.
								If cSerTms == StrZero(3, Len(DC5->DC5_SERTMS))
									Tmsa141SEnt(aDocto[ nDocto, CTFILDOC ], aDocto[ nDocto, CTDOCTO ], aDocto[ nDocto, CTSERIE ], aDocto[ nDocto, CTSEQUEN ])
								EndIf
							EndIf

							DUD->(DbSetOrder(1))
							DUD->(MsSeek(cSeekDUD := xFilial('DUD') + aDocto[ nDocto, CTFILDOC ] + aDocto[ nDocto, CTDOCTO ] + aDocto[ nDocto, CTSERIE ], .F.))
							While DUD->(!Eof() .And. DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE == cSeekDUD)
								//-- valida apenas viagem de entrega e coleta
								If ( cSerAdi $ '1/3' .Or. DUD->DUD_SERTMS == cSerTms ) .And. ( DUD->DUD_STATUS == StrZero( 1, Len( DUD->DUD_STATUS ) ) .Or. ( !Empty(DUD->DUD_NUMRED) .And. DUD->DUD_STATUS<>StrZero(9,Len(DUD->DUD_STATUS)) ) )
									RecLock('DUD',.F.)
									If	aDocto[ nDocto, CTSEQUEN ] != Replicate('x',Len(DUD->DUD_SEQUEN))
										DUD->DUD_SEQUEN := aDocto[ nDocto, CTSEQUEN ]
									EndIf
									If DUD->DUD_SERTMS == StrZero( 2, Len( DUD->DUD_SERTMS ) ) .Or. lTMSDCol // Transporte ou despreza filial de origem da coleta
										DUD->DUD_FILORI := M->DTQ_FILORI  // Para os casos de documentos de outra filial
									EndIf

                                    DUD->DUD_VIAGEM := M->DTQ_VIAGEM

									DUD->DUD_GERROM := StrZero(1,Len(DUD->DUD_GERROM))
									DUD->DUD_STROTA := aDocto[ nDocto, CTSTROTA ]
									If !lVgeExpr // Gravacao da zona e setor sera realizada no calculo do frete.
										DUD->DUD_ZONA   := Subs(aDocto[nDocto,CTDOCROT] , Len(DA8->DA8_COD) + 1, Len(DA5->DA5_COD) )
										DUD->DUD_SETOR  := Subs(aDocto[nDocto,CTDOCROT] , Len(DA8->DA8_COD) + Len(DA5->DA5_COD)  + 1, Len(DA6->DA6_ROTA))
									EndIf
									//--- Dados Integração TMS x GFE digitados somente pela viagem modelo 2
									If lTMS3GFE .Or. lTmsRdpU
										If ('TMSA144' $ AllTrim(FunName())) .And. Empty(DUD->DUD_NUMRED)
											DUD->DUD_UFORI  := aDocto[ nDocto, CTUFORI  ]
											DUD->DUD_CDMUNO := aDocto[ nDocto, CTCDMUNO ]
											DUD->DUD_CEPORI := aDocto[ nDocto, CTCEPORI ]
											DUD->DUD_UFDES  := aDocto[ nDocto, CTUFDES  ]
											DUD->DUD_CDMUND := aDocto[ nDocto, CTCDMUND ]
											DUD->DUD_CEPDES := aDocto[ nDocto, CTCEPDES ]
											DUD->DUD_TIPVEI := aDocto[ nDocto, CTTIPVEI ]
											DUD->DUD_CDTPOP := aDocto[ nDocto, CTCDTPOP ]
											DUD->DUD_CDCLFR := aDocto[ nDocto, CTCDCLFR ]
										EndIf
									EndIf
									If DUD->(ColumnPos("DUD_DTRNPR")) > 0 .And.  DUD->DUD_SERTMS $ '3;1'  .And. nOpcx == 4 .And. M->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) //-- Em Transito
										cHoraReg	:= StrTran(Left(Time(),5),':','')
										DUD->DUD_DTRNPR := dDataBase
										DUD->DUD_HRRNPR := cHoraReg
										DUD->DUD_USURNP := cCodUsr
									EndIf
									MsUnLock()

									If DUD->(ColumnPos("DUD_DTRNPR")) > 0 .And. !Empty(DUD->DUD_DTRNPR) .And. FindFunction("TmsDTWCli") .And. DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) //Em Transito
										cCliDes		:= ""
										cLojDes		:= ""
										//--Verifica se a rota possui serviço com geração de atividade do cliente.
										If DA8->( MsSeek( xFilial( 'DA8' ) + DTQ->DTQ_ROTA,.F. ) )
											If	DC5->( MsSeek( cSeekDC5 := xFilial('DC5') + DA8->DA8_SERVIC, .F.) )
												lAptOper := DUD->DUD_SERTMS <> '1'
												//--Chamada da função que verifica se existe atividade de saída e chegada do cliente											
												DT6->(DbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
												If DT6->(MsSeek(xFilial("DT6")+ aDocto[nDocto,CTFILDOC] + aDocto[nDocto,CTDOCTO] + aDocto[nDocto,CTSERIE]))
													// Para os documentos não previstos, as operações deverão ser para o cliente remetente.
													cCodCli	:= DT6->DT6_CLIREM
													cLojaCli:= DT6->DT6_LOJREM
													cCliDes	:= DT6->DT6_CLIDES
													cLojDes	:= DT6->DT6_LOJDES

                                                    If !Empty(DT6->DT6_CLIEXP) .AND. !Empty(DT6->DT6_LOJEXP)
                                                        cCodCli := DT6->DT6_CLIEXP
                                                        cLojaCli := DT6->DT6_LOJEXP
                                                    EndIf

													If !Empty(DT6->DT6_SQEDES)
														DUL->(dbSetOrder(2))
														If DUL->(MsSeek( xFilial("DUL") + cCliDes + cLojDes + DT6->DT6_SQEDES )) .And. !Empty(DUL->DUL_CODRED)
															cCliDes		:= DUL->DUL_CODRED
															cLojDes		:= DUL->DUL_LOJRED
														EndIf	
													EndIf

													DUY->( dbSetOrder(1) )
													If DUY->(MsSeek(xFilial("DUY")+ DT6->DT6_CDRCAL ))   
														cUfAtiv		:= DUY->DUY_EST	
													EndIf

												EndIf
												If lOperCli .And. (T310AtvCli(DA8->DA8_SERVIC,cAtvSaiCli,cAtvChgCli) .Or. lAptOper )

													If !Empty(cCodCli) .And. !Empty(cLojaCli)
														DTW->(DbSetOrder(8)) //-- DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_CODCLI+DTW_LOJCLI+DTW_SEQUEN
														// Verifica se existe registro do cliente na tela de operações.
														If !DTW->(MsSeek(xFilial("DTW")+ DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM + cCodCli + cLojaCli)) 
															TmsDTWCli(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_ROTA,cCodCli,cLojaCli, lAptOper ,cUfAtiv )
														Else
															aRetDTW := A350RetDTW(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, "4", "2")
															If Len(aRetDTW) > 0
																nPSequen := aScan(aRetDTW[1], { |x| x[1] == "DTW_SEQUEN" })
																If nPSequen > 0
																	DTW->(dbSetOrder(1)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_SEQUEN
																	If DTW->(MsSeek(xFilial("DTW")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM+aRetDTW[1][nPSequen][2]))
																		// Verificar se a atividade de chegada no cliente esta apontada.
																		If aDocto[nDocto,CTSERIE] <> "COL" .AND. DTW->DTW_ATIVID == cAtvChgCli .AND. Empty(DTW->DTW_DATINI) .AND. Empty(DTW->DTW_HORINI) .AND. Empty(DTW->DTW_DATREA) .AND. Empty(DTW->DTW_HORREA)
																			TMSA350Grv(3, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, cAtvChgCli, dDataBase, StrTran(Left(Time(),5),":",""), dDataBase, StrTran(Left(Time(),5),":",""), .F.)
																		EndIf

																		//Verifica se existe atividade de saída do cliente pendente de apontamento, caso não exista cria novas operações
																		cQuery := 	"SELECT DTW.DTW_VIAGEM "
																		cQuery += 	"FROM " + RetSqlName("DTW") + " DTW "
																		cQuery += 	"WHERE DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
																		cQuery += 	"AND DTW.DTW_FILORI = '" + DTQ->DTQ_FILORI + "' "
																		cQuery += 	"AND DTW.DTW_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
																		cQuery += 	"AND DTW.DTW_ATIVID = '" + cAtvSaiCli+ "' "
																		cQuery += 	"AND DTW.DTW_CODCLI = '" + cCodCli + "' "
																		cQuery += 	"AND DTW.DTW_LOJCLI = '" + cLojaCli + "' "
																		cQuery += 	"AND DTW.DTW_STATUS = '1' "
																		cQuery += 	"AND DTW.D_E_L_E_T_ = ' ' " 
																		cQuery := ChangeQuery(cQuery)
																		cAliasNew := GetNextAlias()
																		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)

																		If (cAliasNew)->(Eof())
																			TmsDTWCli(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_ROTA,cCodCli,cLojaCli , lAptOper ,cUfAtiv )
																		EndIf
																		(cAliasNew)->(DbCloseArea())
																	EndIf
																	aRetDTW := {}
																	aSize(aRetDTW, 0)
																EndIf
															EndIf
														EndIf
													EndIf
												
													If cSerTms == StrZero( 1, Len( DTQ->DTQ_SERTMS ) ) .And. !Empty(cCliDes) .And. !Empty(cLojDes) //-- Coleta
													
														DTW->(DbSetOrder(8)) //-- DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_CODCLI+DTW_LOJCLI+DTW_SEQUEN
														If !DTW->(MsSeek(xFilial("DTW")+ DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM + cCliDes + cLojDes)) 
															TmsDTWCli(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_ROTA,cCliDes,cLojDes , .F. , cUfAtiv )
														Else
															
															//Verifica se existe atividade de saída do cliente pendente de apontamento, caso não exista cria novas operações
															cQuery := 	"SELECT DTW.DTW_VIAGEM "
															cQuery += 	"FROM " + RetSqlName("DTW") + " DTW "
															cQuery += 	"WHERE DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
															cQuery += 	"AND DTW.DTW_FILORI = '" + DTQ->DTQ_FILORI + "' "
															cQuery += 	"AND DTW.DTW_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
															cQuery += 	"AND DTW.DTW_ATIVID = '" + cAtvSaiCli+ "' "
															cQuery += 	"AND DTW.DTW_CODCLI = '" + cCliDes + "' "
															cQuery += 	"AND DTW.DTW_LOJCLI = '" + cLojDes + "' "
															cQuery += 	"AND DTW.DTW_STATUS = '1' "
															cQuery += 	"AND DTW.D_E_L_E_T_ = ' ' " 
															cQuery := ChangeQuery(cQuery)
															cAliasNew := GetNextAlias()
															DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)

															If (cAliasNew)->(Eof())
																TmsDTWCli(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_ROTA,cCliDes,cLojDes , .T. ,cUfAtiv  )
															EndIf
															(cAliasNew)->(DbCloseArea())
														EndIf

													EndIf
												EndIf
											EndIf
										EndIf												
									EndIf
									//Destravar o documento apos a gravacao
                                    TmsConTran(aDocto[nDocto,CTFILDOC],aDocto[nDocto,CTDOCTO],aDocto[nDocto,CTSERIE], .F.)

									If lTM141DUD
										ExecBlock('TM141DUD',.F.,.F.,{nOpcx, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE, nDocto})
									EndIf
									//-- Atualiza status da solitacao da coleta
									If lColeta .Or. cSerAdi == '1'
										DT5->(DbSetOrder(4))
										If DT5->(MsSeek(xFilial("DT5")+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))
											RecLock("DT5",.F.)
											If nOpcx == 3
												DT5->DT5_STATUS := StrZero( 2, Len( DT5->DT5_STATUS ) ) // Indicada para Coleta
											ElseIf nOpcx == 4 .And. DTQ->DTQ_STATUS == StrZero( 1, Len( DTQ->DTQ_STATUS ) )
												DT5->DT5_STATUS := StrZero( 2, Len( DT5->DT5_STATUS ) ) // Indicada para Coleta
											ElseIf nOpcx == 4 .And. DTQ->DTQ_STATUS == StrZero( 2, Len( DTQ->DTQ_STATUS ) )
												DT5->DT5_STATUS := StrZero( 3, Len( DT5->DT5_STATUS ) ) // Em transito
												lStatus := .T.
											EndIf
											MsUnLock()
											If lStatus
												RecLock('DUD',.F.)
												DUD->DUD_STATUS := StrZero( 2, Len(DTQ->DTQ_STATUS)) // Em transito
												MsUnlock()
											EndIf
										EndIf

										If lTmsCFec
											//-- Atualiza o status do item do Agendamento.
											DF1->(DbSetOrder(3))
											If	DF1->(MsSeek(xFilial("DF1") + DUD->(DUD_FILDOC + DUD_DOC + DUD_SERIE)))
												RecLock("DF1",.F.)
												If nTipVia == 3
													DF1->DF1_STACOL := StrZero( 3, Len(DT5->DT5_STATUS)) // Planejado.
												Else
													DF1->DF1_STACOL := StrZero( 4, Len(DT5->DT5_STATUS)) // Em processo.
												EndIf
												MsUnLock()

												//-- Atualiza o status do Agendamento.
												DF0->(DbSetOrder(1))
												If	DF0->(MsSeek(xFilial("DF0") + DF1->DF1_NUMAGE)) .And. DF0->DF0_STATUS != StrZero( 3, Len(DT5->DT5_STATUS))
													RecLock("DF0",.F.)
													DF0->DF0_STATUS := TMSF05Stat(xFilial("DF0"), DF1->DF1_NUMAGE)
													MsUnLock()
												EndIf

											EndIf

										EndIf

									EndIf

									//-- Carregamento automatico
									If	( nCarreg > 1 ) .And. !lColeta
										lCarreg := .T.
									EndIf

									//-- Atualiza Redespacho Adicional da Viagem
									If lTMS3GFE .Or. lTmsRdpU
										If lExtRedVge
											A141AtuDJN(DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE,.F.)
										EndIf
									EndIf
									Exit

								EndIf
								//-- Atualiza Redespacho Adicional da Viagem
								If lTMS3GFE .Or. lTmsRdpU
									If lExtRedVge
										A141AtuDJN(DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE,.F.)
									EndIf
								EndIf

								DUD->(DbSkip())

							EndDo
						EndIf
					Else
						//-- Se desmarcou um documento, que estava vinculado a uma viagem, apagar o campo
						//-- codigo da viagens deste documento (Somente em "Alteracao").
						If nOpcx == 4
							If aDocto[ nDocto, CTSTATUS ] <> StrZero(9,Len(DUD->DUD_STATUS))
								If lTmsCFec .And. !lColeta
									//-- Quando o item for de entrega, somente atualiza a sequencia de entrega e o status do item do Agendamento.
									If cSerTms == StrZero(3, Len(DC5->DC5_SERTMS))
										If IiF(IsInCallStack("TmsA144Grv"),GDDeleted(nSeqAcols, aHeader, aCols), DUD->DUD_FILORI + DUD->DUD_VIAGEM == M->DTQ_FILORI+M->DTQ_VIAGEM)
											Tmsa141SEnt(aDocto[ nDocto, CTFILDOC ], aDocto[ nDocto, CTDOCTO ], aDocto[ nDocto, CTSERIE ], aDocto[ nDocto, CTSEQUEN ], .T.)
										EndIf
									EndIf
								EndIf
							Endif
							If	aDocto[nDocto,CTSTATUS]!=StrZero(3,Len(DUD->DUD_STATUS))
								//---- Estorno da Integração do GFE
								If (lTMS3GFE .Or. lTmsRdpu) .And. DTQ->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE)) .And. !Empty(DTQ->DTQ_CHVEXT)
									lRet:= Tms3GfeInt(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, .F., .T., aDocto[nDocto, CTFILDOC], aDocto[nDocto, CTDOCTO ], aDocto[nDocto, CTSERIE ])
									If !lRet
										DisarmTransaction()
										Break
									EndIf
								EndIf
								TMSA141Del( aDocto[nDocto, CTFILDOC], aDocto[nDocto, CTDOCTO ], aDocto[nDocto, CTSERIE ], aDocto[nDocto, CTVIAGEM ] )
								DFV->( DbSetOrder( 2 ) )
								If DFV->( MsSeek( xFilial('DFV') + aDocto[nDocto, CTFILDOC] + aDocto[nDocto, CTDOCTO ] + aDocto[nDocto, CTSERIE ] ) )
									RecLock('DFV',.F.)
									DFV->DFV_STATUS := StrZero( 1, Len( DFV->DFV_STATUS ) )
									MsUnLock()
								EndIf
							EndIf
						EndIf
					EndIf
					If Len(aDocto[nDocto]) > 44
						If Type('aDocto[nDocto,CTUNITIZ]') <> 'U' .And. Type('aDocto[nDocto,CTCODANA]') <> 'U'
							If Ascan(aUnitiz,{|x| x[1] + x[2] == aDocto[nDocto,CTUNITIZ]+aDocto[nDocto,CTCODANA]}) == 0 .And. aDocto[nDocto,CTMARCA] == .T.
								AAdd(aUnitiz, {aDocto[nDocto,CTUNITIZ],aDocto[nDocto,CTCODANA]})
							EndIf
						EndIf
					Endif
				Next

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
			//-- Trata Operadoras de Frota/Vale-Pedagio
			If lTMSOPdg
				M->DTR_CODOPE := aCompViag[11, 7]
				M->DTR_PERADI := aCompViag[11, 8]
				If lDTRTPSPDG
					M->DTR_TPSPDG := aCompViag[11, 10]
					M->DTR_QTDSAQ := aCompViag[11, 11]
					M->DTR_QTDTRA := aCompViag[11, 12]
				EndIf
			EndIf

			M->DTR_TIPCRG := aCompViag[11, 9]
			If Len(aCompViag[11]) > 12
				M->DTR_PRCTRA := aCompViag[11, 13]
			EndIf

			DbCommitAll()
			lRet := TmsA240Grv( nOpcx, aCompViag,  M->DTQ_FILORI, M->DTQ_VIAGEM,,,,lGrvExpr, lAltRota,,lAltTipOpVg)

			If !lRet
			     DisarmTransaction()
			     Break
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se Alteracao, Verifica se existem viagens Interligadas 'a Viagem Original.³
			//³ Caso Exista, altera automaticamente todas as viagens Interligadas.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpcx == 4 .And. Len(aCompViag) > 0  .And. !(FindFunction("A240AtuDTR"))
				nRegDTQ:= DTQ->(Recno())
				aAreaBkp:= GetArea()

				DTR->(dbSetOrder(2)) // DTR_FILVGE + DTR_NUMVGE
				If DTR->(MsSeek(xFilial('DTR')+M->DTR_FILORI+M->DTR_VIAGEM))
					Do While !DTR->(Eof()) .And. DTR->DTR_FILIAL+DTR->DTR_FILVGE+DTR->DTR_NUMVGE == xFilial('DTR')+M->DTR_FILORI+M->DTR_VIAGEM
						DTQ->( DbSetOrder( 2 ) )
						If DTQ->( MsSeek( xFilial('DTQ') + DTR->DTR_FILORI + DTR->DTR_VIAGEM, .F. ) )

							// Atualização de Campos da Viagem Interligada, mesmo processo que é feito no tmsa240mnt.
							If ValType(aCompViag) == "A" .And. !Empty(aCompViag)
								aCompViag[11, 1] := DTR->DTR_FILVGE
								aCompViag[11, 2] := DTR->DTR_NUMVGE
							EndIf

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
		//---Alteração da viagem executa a integração com o GFE caso a viagem ja tenha sido integrada (Fechamento, Chegada ou Saida)
		If (lTMS3GFE .Or. lTmsRdpu) .And. lRet
			If nOpcx == 4 .And. DTQ->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))  .And. !Empty(DTQ->DTQ_CHVEXT)
				lRet:= Tms3GfeInt(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, .F., .F.)
				If !lRet
					DisarmTransaction()
					Break
				EndIf
			EndIf
		EndIf

		//Gravacao DJM - Fornecedores Adicionais
		If oMdlDJMGr != Nil .And. AliasIndic('DJM')
			If oMdlDJMGr:VldData()
				FWFormCommit(oMdlDJMGr)
			EndIf
		EndIf

		EvalTrigger()

		//-- Gera tabelas específicas da viagem modelo 3
		If lViagem3 .And. cSerTms != StrZero(1,Len(DTQ->DTQ_SERTMS))
			If lRet .And. FindFunction('TmsAjuMod3')
				TmsAjuMod3(M->DTQ_FILORI,M->DTQ_VIAGEM,nOpcx,.T.)
			EndIf
		EndIf

	End Transaction

	If lRet 
		If lAltRota
			Aviso(STR0075,STR0102,{STR0077}) //Atencao ### A rota da viagem foi alterada, é necessário confirmar o complemento de viagem para que o valor de frete e pedagio sejam recalculados! ### OK
	 	ElseIf lAltTipOpVg 
		 	If (lVgeExpr .And. IsInCallStack('TmsA144Grv'))
			 	lMostra240:= .F.
			Else		 
			 	Aviso(STR0075,STR0107,{STR0077}) //Atencao ### O Tipo da Negociação da viagem foi alterado, é necessário confirmar o complemento de viagem para que o valor de frete sejam recalculados!"
			EndIf	 
		EndIf 
		If lAltRota .Or. (lAltTipOpVg ) 
		 	TmsA240Mnt( , , 4, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,Iif(nOpcx==3 .And. Len(aCompViag)>0,aCompViag,''),M->DTQ_ROTA,DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA,@M->DTQ_OBS,,,lMostra240,,,aDocto,aPosicao,.T.,,,,lAltRota,,,lAltTipOpVg)
		EndIf
	EndIf

	//-- Carregamento automatico
	If	lRet .And. lCarreg
		lRet := TMSA141Crr( nOpcx )
	EndIf

	If lRet	.And. DTA->(ColumnPos("DTA_ORIGEM")) > 0
		DTA->(DbSetOrder(1))
		For nDocto := 1 To Len(aDocto)
			If Len(aDocto[nDocto]) > 54 .AND. ValType('aDocto[nDocto,CTORIGEM]') <> 'U'
				If DTA->(MsSeek(xFilial('DTA') + aDocto[nDocto, CTFILDOC] + aDocto[nDocto, CTDOCTO] + aDocto[nDocto, CTSERIE] + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM ))
					RecLock('DTA',.F.)
					DTA->DTA_ORIGEM := aDocto[nDocto, CTORIGEM]
					DTA->(MsUnLock())
				EndIf
			EndIf
		Next
	EndIf

	//Chama Rotina para Gerar Manifesto e Contrato de Carreteiro somente para viagem modelo I
	If lRet
		If ( nOpcx == 3 .Or. nOpcx == 4 ) .And. Substr(Funname(),1,7) != "TMSA144"
			If (( cSerTms == StrZero(2,Len(DC5->DC5_SERTMS))) .Or. ( cSerTms == StrZero(3,Len(DC5->DC5_SERTMS))))//Transportes ou Entrega
				If nCarreg > 1  //Modo de Carregamento nao manual
					TmsA144GMC(lVgeExpr)
				EndIf
			EndIf
		EndIf


		//-- Bloqueio de viagem
		//-- A viagem gerada automaticamente (TMSA252) para o pagamento do Redespacho nao bloqueia
		If IsInCallStack(AllTrim('TMSA252')) .And. M->DTQ_TIPVIA == StrZero( 5, Len( DTQ->DTQ_TIPVIA ) )
			lRet := .T.
		Else
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
						// Check List da Viagem
						Tmsa029Blq( 5  ,;				// 01 - nOpc
									'TMSA310',;		// 02 - Rotina
									'RR',;				// 03 - Tipo Bloq (Diverg. Produto)
									M->DTQ_FILORI,;	// 04 - Filial Origem
									'DTQ',;			// 05 - Tabela Referencial
									'1',;				// 06 - Indice Da Tabela
									xFilial('DTQ') + M->DTQ_FILORI + M->DTQ_VIAGEM,;	// 07 - Chave Indexação
									"",;				// 08 - Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
									"",;				// 09 - Detalhes Adicionais a Respeito Do Bloqueio
									nOpcx)				// 10 - Opcao da Rotina
					EndIf
				EndIf
				TmsBlqViag( M->DTQ_FILORI, M->DTQ_VIAGEM)
			EndIf
		EndIf


		//-- Ponto de Entrada chamado apos a inclusao, alteracao ou exclusao da Viagem de Entrega/Coleta
		If lRet .And. lTM141GRV
			ExecBlock('TM141GRV',.F.,.F.,{nOpcx})
		EndIf
	Endif
EndIf

If lTM141FGRV
	ExecBlock('TM141FGRV',.F.,.F.,{nOpcx,lRet})
EndIf


RestArea( aAreaDTQ )
RestArea( aAreaDUD )
RestArea( aAreaAnt )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA141Del³ Autor ³ Alex Egydio           ³ Data ³31.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apaga o numero da viagem, dos documentos.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA141Del()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial do Docto                                    ³±±
±±³          ³ ExpC2 = Nr.Docto                                           ³±±
±±³          ³ ExpC3 = Serie                                              ³±±
±±³          ³ ExpL1 = .T. = Docto associado a uma viagem                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA141Del( cFilDoc, cDoc, cSerie, lViagem )

Local aAreaAnt   := GetArea()
Local aAreaDUD   := DUD->(GetArea())
Local aAreaDT5   := DT5->(GetArea())
Local aAreaDT6   := DT6->(GetArea())
Local aAreaDTA   := DTA->(GetArea())
Local cNumAge    := ""
Local lAtuStaEnt := .F.
Local lCarMult   := SuperGetMv('MV_TMSCMUL',,.F.)
Local lTMS3GFE   := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local lITmsDmd := SuperGetMv("MV_ITMSDMD",,.F.) .And. FindFunction("TMA144CVG")

If Type("cSerAdi") == "U"
	cSerAdi := ""
EndIf

//-- Se desmarcou um documento, que estava vinculado a uma viagem, apagar o campo
//-- codigo da viagens deste documento.
If lViagem
	DUD->(DbSetOrder(1))
	If	DUD->(dbSeek(xFilial('DUD')+cFilDoc+cDoc+cSerie+M->DTQ_FILORI+M->DTQ_VIAGEM)) .And.;
		DUD->DUD_STATUS != StrZero(9,Len(DUD->DUD_STATUS)) //-- Cancelado
		RecLock('DUD',.F.)
		DUD->DUD_SEQUEN := Space(Len(DUD->DUD_SEQUEN))
		If lTmsCFec .And. lColeta
			DUD->DUD_SEQENT := Space(Len(DUD->DUD_SEQENT))
		EndIf
		DUD->DUD_VIAGEM := Space(Len(DUD->DUD_VIAGEM))

		If !Tmsa141Red(cFilDoc,cDoc,cSerie)
			DUD->DUD_STATUS := StrZero(1,Len(DUD->DUD_STATUS))		//-- Em aberto
		EndIf

		DUD->DUD_STROTA := Space(Len(DUD->DUD_STROTA))
		DUD->DUD_ZONA   := Space(Len(DUD->DUD_ZONA))
		DUD->DUD_SETOR  := Space(Len(DUD->DUD_SETOR))
		DUD->DUD_FILDCA := Space(Len(DUD->DUD_FILDCA))
		DUD->DUD_GERROM := StrZero(2,Len(DUD->DUD_GERROM))

		If	DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) .And. DUD->DUD_FILDOC == cFilAnt  //-- Transporte
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
		If lTMS3GFE .Or. lTmsRdpU
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
		DUD->(MsUnLock())

		//-- Tratamento que busca a solicitação de coleta do documento que está sendo retirado da viagem. Se todas as coletas de todas as notas do
		//-- documento estiverem na mesma viagem a exclusao do documento será permitida. Tratamento efetuado para a integração com Gestão de Demandas.
		If lITmsDmd .AND. cSerie != "COL" .AND. FindFunction("TMMONTADMD") .AND. AliasInDic("DL8") //SUAVIZAÇÃO DEMANDAS
			If TMA144CVg(cFilDoc,cDoc,cSerie,M->DTQ_VIAGEM)
				TmMontaDmd("2",cFilDoc,cDoc,cSerie,"",.F.,,,.F.,.F.)

				//Efetua o estorno do carregamento do documento uma vez que o documento nao estara mais vinculado a viagem
				DTA->(DbSetOrder(1))
				If DTA->(DbSeek(xFilial("DTA")+cFilDoc+cDoc+cSerie+M->DTQ_FILORI+M->DTQ_VIAGEM))
					RecLock("DTA",.F.)
					DTA->(dbDelete())
					MsUnLock()
				EndIf
			EndIf
		EndIf

		//-- Atualiza status da solitacao da coleta
		If lColeta .Or. cSerAdi == '1'
			DT5->(DbSetOrder(4))
			If DT5->(dbSeek(xFilial('DT5')+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE))
				RecLock('DT5',.F.)
				DT5->DT5_STATUS := StrZero(1,Len(DT5->DT5_STATUS)) //-- Em Aberto
				MsUnLock()
			EndIf

			If lTmsCFec
				//-- Como o documento foi desmarcado, volta o status do item do Agendamento para 2 - Confirmado.
				DF1->(DbSetOrder(3))
				If DF1->(MsSeek(xFilial("DF1") + DUD->(DUD_FILDOC + DUD_DOC + DUD_SERIE)))
					//-- Verifica se o status de Entrega deve ser atualizado.
					If lColeta
						lAtuStaEnt := Ascan( aDocto,{ | x | x[ CTNUMAGE ] + x[ CTITEAGE ] + x[ CTSERTMS ] == DF1->( DF1_NUMAGE + DF1_ITEAGE ) + StrZero( 3, Len( DC5->DC5_SERTMS ) ) }) > 0
					EndIf
					cNumAge := DF1->DF1_NUMAGE

					RecLock("DF1",.F.)
					DF1->DF1_STACOL := StrZero( 2, Len( DT5->DT5_STATUS ) ) // Confirmado.
					If lAtuStaEnt
						DF1->DF1_STAENT := StrZero( 2, Len( DT5->DT5_STATUS ) ) // Confirmado.
					EndIf
					MsUnLock()

					//-- Se nenhum item do Agendamento estiver com status 3 - Planejado ou 4 - Em Processo,
					//--  volta o status do Cabecalho do Agendamento para 2 - Confirmado.
					DF1->(DbSetOrder(4))
					If	!(DF1->( MsSeek( xFilial("DF1") + StrZero( 3, Len( DT5->DT5_STATUS ) ) + cNumAge ) ) ) .And.;
						!(DF1->( MsSeek( xFilial("DF1") + StrZero( 4, Len( DT5->DT5_STATUS ) ) + cNumAge ) ) )

						DF0->(DbSetOrder(1))
						If DF0->(MsSeek( xFilial("DF0") + cNumAge))
							RecLock("DF0",.F.)
							DF0->DF0_STATUS := TMSF05Stat(xFilial("DF0"), cNumAge)
							MsUnLock()
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		//-- Exclui Redespacho Adicional da Viagem
		If lTMS3GFE .Or. lTmsRdpU
			If  Type('aRedVge') == "A"
				A141AtuDJN(DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE,.T.)
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aAreaDUD )
RestArea( aAreaDT5 )
RestArea( aAreaDT6 )
RestArea( aAreaDTA )
RestArea( aAreaAnt )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA141Crr³ Autor ³ Alex Egydio           ³ Data ³06.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua o carregamento automatico, se nCarreg igual a 2.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA141Crr( nOpcx )

Local aAreaAnt   := GetArea()
Local aAreaSF4   := SF4->(GetArea())
Local aNoFields  := {}
Local aYesFields := {}
Local aVisual    := {}
Local aFilDca    := {}
Local nDocto     := 0
Local nItem      := 0
Local nCntFor    := 0
Local cCampo     := ''
Local cFilDca    := ''
Local cTes       := GetMV('MV_TESDR',,'')
Local lAlianca   := TmsAlianca() //-- Verifica se utiliza Alianca
Local lRet       := .T.

Private aHeader  := {}
Private aCols    := {}

SF4->( DbSetOrder( 1 ) )
If	!SF4->( MsSeek( xFilial('SF4') + cTes, .F. ) )
	Help( ' ', 1, 'TMSA20015',,STR0048 + cTes,5,11)	//--Tipo de entrada/saida informado no parametro MV_TESDR nao encontrado (SF4)### TES :
	Return( .F. )
EndIf

If ! TmsA210Srv(M->DTQ_SERTMS)
	Return( .F. )
EndIf
//-- Qd for viagem de entrega, a filial de descarga sera a propria filial de origem,
//-- pois na rota de entrega nao e informado filial de descarga. 3o parametro .T.
aFilDca := TMSRegDca(M->DTQ_ROTA,,cSerTms==StrZero(3,Len(DC5->DC5_SERTMS)))
If	! Empty(aFilDca)
	cFilDca := aFilDca[1,3]
EndIf
If	Empty(cFilDca)
	Return( .F. )
EndIf
//-- Cria variaveis de memoria para operacoes de carregamento
RegToMemory('DTA',.T.)
M->DTA_FILIAL	:= xFilial('DTA')
M->DTA_FILORI	:= cFilAnt
M->DTA_VIAGEM	:= M->DTQ_VIAGEM

AAdd(aVisual, 'DTA_FILORI')
AAdd(aVisual, 'DTA_VIAGEM')

AAdd(aNoFields, 'DTA_FILORI')
AAdd(aNoFields, 'DTA_VIAGEM')

M->DTA_CODVEI := Posicione('DTR',1,xFilial('DTR')+M->DTQ_FILORI+M->DTQ_VIAGEM,'DTR_CODVEI')
AAdd(aVisual  ,'DTA_CODVEI')
AAdd(aNoFields,'DTA_CODVEI')

If !lAlianca
	AAdd(aNoFields, "DTA_FILDPC")
EndIf

If	!lLocaliz
	AAdd(aNoFields, 'DTA_LOCAL')
	AAdd(aNoFields, 'DTA_LOCALI')
EndIf
//-- Monta o aHeader e aCols
TMSFillGetDados( 3, 'DTA', 2, xFilial('DTA') + M->DTQ_FILORI + M->DTQ_VIAGEM, {|| ''}, {|| .T. }, aNoFields, aYesFields )

aCols := {}
DTA->( DbSetOrder(1) )
For nDocto := 1 To Len( aDocto )
	//-- Verifica se marcou um documento
	If	aDocto[ nDocto, CTMARCA ] .And. aDocto[nDocto,CTSTATUS] == "1"
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
		EndIf
		GDFieldPut('DTA_FILDOC', aDocto[ nDocto, CTFILDOC ], nItem )
		GDFieldPut('DTA_DOC'   , aDocto[ nDocto, CTDOCTO ] , nItem )
		GDFieldPut('DTA_SERIE' , aDocto[ nDocto, CTSERIE ] , nItem )
		GDFieldPut('DTA_TIPCAR', StrZero(2,Len(DTA->DTA_TIPCAR)), nItem )
		GDFieldPut('DTA_QTDVOL', aDocto[ nDocto, CTQTDVOL ], nItem )
		GDFieldPut('DTA_PESO'  , aDocto[ nDocto, CTPLIQUI ], nItem )
		GDFieldPut('DTA_FILDCA', cFilDca, nItem )

		If lAlianca
			GDFieldPut('DTA_FILDPC', cFilDca, nItem )
		EndIf
		If Len(aDocto[nDocto]) > 54 .AND. Type('aDocto[nDocto,CTORIGEM]') <> 'U'
			GDFieldPut('DTA_ORIGEM', aDocto[ nDocto, CTORIGEM ], nItem )
		EndIf

		aCols[ nItem, Len( aHeader ) + 1 ] := .F.
	EndIf
Next

If	! Empty(aCols)
	Processa({|| lRet := TmsA210Grv( aVisual, 3, lLocaliz,.F. )},STR0049) //"Aguarde..."
EndIf

RestArea(aAreaSF4)
RestArea(aAreaAnt)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA141DT5³ Autor ³ Alex Egydio           ³ Data ³16.01.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posiciona na solicitacao de coleta                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo de solicitacao de coletas         ³±±
±±³          ³ ExpC2 = Alias do arquivo de movimentos de viagem           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141DT5(cAliasDT5,cAliasDUD)

Local lRet	:= .F.
DT5->(DbSetOrder(4))
lRet := (cAliasDT5)->(MsSeek(xFilial('DT5') + (cAliasDUD)->DUD_FILDOC + (cAliasDUD)->DUD_DOC + (cAliasDUD)->DUD_SERIE))

If lTmsCFec
	//-- Posiciona o Agendamento.
	DF1->(DbSetOrder(3))
	DF1->(MsSeek(xFilial("DF1")+ (cAliasDUD)->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA141ADc³ Autor ³ Alex Egydio           ³ Data ³16.01.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posiciona o solicitante / cliente destinatario p avaliar   ³±±
±±³          ³ o pontos por zona e setor                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Vetor com os ceps obtidos na pesquisa do DA7       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141ADc(aCep,cAliasDA8,cAliasDA9,cAliasDT5,cAliasDT6,cAliasDUD,cAliasSB1,cAliasDTC,nOpcx,cZonaGen,cZonDesc,cSetorGen,cSetDesc,lAddDoc)

Local cCep	  := ''
Local cRota	  := ''
Local cDesc	  := ''
Local cTipo	  := ''
Local cZona	  := ''
Local cSetor  := ''
Local cSeqDA7 := ''
Local lRet	  := .F.

DEFAULT lAddDoc := .T.

cRota  := (cAliasDA8)->DA8_COD
cDesc  := (cAliasDA8)->DA8_DESC
cTipo  := Tabela('M3',(cAliasDA8)->DA8_TIPROT,.F.)
cZona  := (cAliasDA9)->DA9_PERCUR
cSetor := (cAliasDA9)->DA9_ROTA
DA6->(DbSetOrder(1))
DA7->(DbSetOrder(1))
If	DA7->(lRet:=MsSeek(xFilial('DA7') + cZona + cSetor)) .Or.;
	(DA6->(MsSeek(xFilial('DA6') + cZona + cSetor)) .And.;
	!Empty(DA6->DA6_ALIANC))
	If	lColeta
		//-- Posiciona no solicitante
		DUE->(DbSetOrder(1))
		DUE->(MsSeek(xFilial('DUE') + (cAliasDT5)->DT5_CODSOL))
		//-- Posiciona no endereco do solicitante
		DUL->(DbSetOrder(3))
		If	DUL->(MsSeek(xFilial('DUL') + (cAliasDT5)->DT5_CODSOL+ (cAliasDT5)->DT5_SEQEND))
			cCep := DUL->DUL_CEP
		Else
			cCep := DUE->DUE_CEP
		EndIf
		cSeqDA7 := ''
		//-- Analisa se o Cep do solicitante esta entre as faixas de cep, especificado no arquivo de pontos por zona e setor
		If	! TmsA141DA7(aCep,@cSeqDA7,DUE->DUE_CODCLI,DUE->DUE_LOJCLI,cZona,cSetor,cCep)
			Return( .F. )
		EndIf
		Tms141AddD(,cAliasDA8,cAliasDA9,cAliasDT5,cAliasDT6,cAliasDUD,cAliasSB1,,cSeqDA7,cRota,cZona,cSetor,lAddDoc,nOpcx)
	Else
		//-- Posiciona no cliente destinatario
		SA1->(DbSetOrder( 1 ))
		SA1->(MsSeek(xFilial('SA1') + (cAliasDTC)->DTC_CLIDES + (cAliasDTC)->DTC_LOJDES))

		cSeqDA7	:= ''
		cCep	:= SA1->A1_CEP
		//-- Analisa se o cliente destinatario esta especificado no arquivo de pontos por zona e setor ou
		//-- Analisa se o cep do cliente destinatario esta entre as faixas de cep, especificado no arquivo de pontos por zona e setor
		//-- Analisa se o documento eh alianca
		If	! TmsA141DA7(aCep,@cSeqDA7,SA1->A1_COD,SA1->A1_LOJA,cZona,cSetor,cCep)
			Return( .F. )
		EndIf
		Tms141AddD(,cAliasDA8,cAliasDA9,cAliasDT5,cAliasDT6,cAliasDUD,cAliasSB1,cAliasDTC,cSeqDA7,cRota,cZona,cSetor,lAddDoc,nOpcx)
	EndIf
	//-- Preenche vetores aRota, aAllZona e aAllSetor
	TmsA141ARt(cRota,cDesc,cTipo,cZona,cZonDesc,cSetor,cSetDesc,(cAliasDUD)->DUD_STATUS,(cAliasDT6)->DT6_PESO,(cAliasDT6)->DT6_PESOM3,nOpcx,,(cAliasDT6)->DT6_QTDVOL)
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA141DA7³ Autor ³ Alex Egydio           ³ Data ³17.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa pontos por zona e setor                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Vetor com os ceps obtidos na pesquisa do DA7       ³±±
±±³          ³ ExpC1 = Sequencia obtida na pesquisa do DA7                ³±±
±±³          ³ ExpC2 = Cliente Destinatario somente entrega               ³±±
±±³          ³ ExpC3 = Loja Destinatario somente entrega                  ³±±
±±³          ³ ExpC4 = Zona                                               ³±±
±±³          ³ ExpC5 = Setor                                              ³±±
±±³          ³ ExpC6 = CEP solicitante(Coleta) / Destinatario(Entrega)    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA141DA7(aCep,cSeqDA7,cCliente,cLoja,cZona,cSetor,cCep)

Local aAreaAnt	:= GetArea()
Local aAreaDA7	:= DA7->(GetArea())
Local cSeekDA7	:= ''
Local nSeek		:= 0
Local lRet		:= .F.

DEFAULT cSeqDA7 := ''
DEFAULT cCep	:= ''

//-- Identifica pontos por zona e setor pelo cep
DA7->(DbSetOrder(2))
If	lColeta
	//-- Verifica se foi especificado pontos por zona e setor para o cliente
	If	! Empty(cCliente) .And. ! Empty(cLoja) .And.	DA7->(MsSeek(xFilial('DA7') + cCliente + cLoja + cZona + cSetor))
		cSeqDA7	:= DA7->DA7_SEQUEN
		Return( .T. )
	EndIf
Else
	//-- Verifica se foi especificado pontos por zona e setor para o cliente
	If	DA7->(MsSeek(xFilial('DA7') + cCliente + cLoja + cZona + cSetor))
		cSeqDA7	:= DA7->DA7_SEQUEN
		Return( .T. )
	EndIf
EndIf
//-- Cep nao especificado
If	Empty( cCep )
	Return( .F. )
EndIf
//-- Verifica se o cep da zona e setor ja foi analisado
nSeek := AScan( aCep, {|x| x[1] + x[2] + x[3] == cZona + cSetor + cCep } )
If	nSeek > 0
	cSeqDA7	:= aCep[ nSeek, 4 ]
	Return( .T. )
EndIf

DA7->(DbSetOrder(1))
If	DA7->(MsSeek( cSeekDA7 := xFilial('DA7') + cZona + cSetor))
	While DA7->( ! Eof() .And. DA7->DA7_FILIAL + DA7->DA7_PERCUR + DA7->DA7_ROTA == cSeekDA7 )
		//-- Analisa se o cep, se encontra entre a faixa especificada no arquivo de pontos por zona e setor
		If	cCep >= DA7->DA7_CEPDE .And. cCep <= DA7->DA7_CEPATE
			cSeqDA7	:= DA7->DA7_SEQUEN
			lRet	:= .T.
			AAdd( aCep, { cZona, cSetor, cCep, DA7->DA7_SEQUEN } )
			Exit
		EndIf
		DA7->(DbSkip())
	EndDo
EndIf

RestArea( aAreaDA7 )
RestArea( aAreaAnt )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA141Add³ Autor ³ Alex Egydio           ³ Data ³16.01.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche o vetor aAllDocto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpNA = Vetor com informacoes do documento. Passado por    ³±±
±±³          ³         referencia qd rota generica                        ³±±
±±³          ³ ExpC1 ate ExpC7 = Alias dos arquivos                       ³±±
±±³          ³ ExpC8 = Sequencia obtida na pesquisa do DA7                ³±±
±±³          ³ ExpC9 = Rota ou rota generica                              ³±±
±±³          ³ ExpCA = Zona ou zona generica                              ³±±
±±³          ³ ExpCB = Setor ou setor generico                            ³±±
±±³          ³ ExpL1 = .T. Preenche o vetor aAllDocto                     ³±±
±±³          ³ ExpN1 = Opcao de manutencao                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141Add(aLinha,cAliasNew,cSeqDA7,cRota,cZona,cSetor,lAddDoc,nOpcx,lVgeExpr)

Local nCnt        := 0
Local aItem       := {}
Local lDupDocto   := .F.
Local cNomDes     := ''
Local cAliasQry   := ''
Local cQuery      := ''
Local nCont		   := 0
Local nPos		   := 0
Local aEndEstoque := {}
Local cSeekDTC    := ''
Local aEndEstPE   := {}
Local lTM141END   := ExistBlock('TM141END')
Local lContinua   := .T.
Local cEndEnt     := ''
Local cBaiEnt     := ''
Local cMunEnt     := ''
Local cCliRem	   := ''
Local cLojRem	   := ''
Local cCliDes 	   := ''
Local cLojDes 	   := ''
Local cDatSol	   := ''
Local cHorSol	   := ''
Local cDatPrv	   := ''
Local cHorPrv	   := ''
Local lDocRee	   := SuperGetMV('MV_DOCREE',,.F.) .And. TMSChkVer('11','R7')
Local lAgdEntr    	:= Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)     //-- Agendamento de Entrega.
Local cSerAnt     	:= cSerTms

Default aLinha  := {}
Default cSeqDA7 := ''
Default cZona   := ''
Default cSetor  := ''
Default lAddDoc := .T.
Default lVgeExpr:= .F.

Private cAliasDoc := cAliasNew

If Type("cSerAdi") == "U"
	cSerAdi := ""
EndIf

If lVgeMod2 == Nil
	lVgeMod2 := ('TMSA144' $ AllTrim(FunName()) .Or. lVgeExpr)
EndIf

If	lColeta .Or.(cSerAdi == '1' .And. (cAliasNew)->DUD_SERTMS == '1')
	cQuery := " SELECT DUE_NOME, DUE_CODCLI, DUE_LOJCLI, DUE_BAIRRO, DUE_MUN   , DUE_EST   , DUE_END   , DUL_BAIRRO, DUL_MUN, "
	cQuery += "        DUL_EST , DUL_END   , DT5_CLIDES, DT5_LOJDES, DT5_DATPRV, DT5_HORPRV, DT5_DATSOL, DT5_HORSOL"
	If cSerAdi == '1'
		cQuery += " , DF1_CLIREM, DF1_LOJREM, DF1_CLIDES, DF1_LOJDES, DF1_NUMAGE, DF1_ITEAGE "
	EndIf
	cQuery += "  FROM " + RetSQLName("DT5") + " DT5 "
	cQuery += "  JOIN " + RetSQLName("DUE") + " DUE "
	cQuery += "    ON DUE_FILIAL = '" + xFilial("DUE") + "' "
	cQuery += "    AND DUE_CODSOL   = DT5_CODSOL  "
	cQuery += "    AND DUE.D_E_L_E_T_ = ' ' "
	cQuery += "  LEFT JOIN " + RetSQLName("DUL") + " DUL "
	cQuery += "    ON DUL_FILIAL = '" + xFilial("DUL") + "' "
	cQuery += "    AND DUL_CODSOL    = DT5_CODSOL "
	cQuery += "    AND DUL_SEQEND = DT5_SEQEND "
	cQuery += "    AND DUL.D_E_L_E_T_ = ' ' "
	If cSerAdi == '1'
		cQuery += "LEFT JOIN " + RetSQLName("DF1") + " DF1 "  //-- Buscar da tabela de agendamento
		cQuery += "  ON DF1_FILIAL  = '" + xFilial("DF1") + "' "
		cQuery += " AND DF1_FILDOC = DT5_FILDOC "
		cQuery += " AND DF1_DOC    = DT5_DOC "
		cQuery += " AND DF1_SERIE  = DT5_SERIE "
		cQuery += " AND DF1.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "  WHERE DT5_FILIAL = '" + xFilial("DT5") + "' "
	cQuery += "    AND DT5_FILDOC = '" + (cAliasNew)->DUD_FILDOC + "' "
	cQuery += "    AND DT5_DOC    = '" + (cAliasNew)->DUD_DOC    + "' "
	cQuery += "    AND DT5_SERIE  = '" + (cAliasNew)->DUD_SERIE  + "' "
	cQuery += "    AND DT5.D_E_L_E_T_ = ' ' "
	cQuery    := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
	If cSerAdi == '1'
		cCliRem := If(!Empty((cAliasQry)->DF1_CLIREM), (cAliasQry)->DF1_CLIREM ,(cAliasQry)->DUE_CODCLI)
		cLojRem := If(!Empty((cAliasQry)->DF1_LOJREM), (cAliasQry)->DF1_LOJREM ,(cAliasQry)->DUE_LOJCLI)
		cCliDes := (cAliasQry)->DT5_CLIDES
		cLojDes := (cAliasQry)->DT5_LOJDES
		cDatSol := (cAliasQry)->DT5_DATSOL
		cHorSol := (cAliasQry)->DT5_HORSOL
		cDatPrv := (cAliasQry)->DT5_DATPRV
		cHorPrv := (cAliasQry)->DT5_HORPRV
	EndIf
	If lTmsCFec .And. !lVgeMod2
		lDupDocto := !Empty( (cAliasQry)->DT5_CLIDES ) .And. !Empty( (cAliasQry)->DT5_LOJDES )
	EndIf
	If	Empty(aLinha)
		If lVgeMod2
			AAdd(aLinha, .F. )
			AAdd(aLinha, (cAliasNew)->DUD_FILDOC )
			AAdd(aLinha, (cAliasNew)->DUD_DOC    )
			AAdd(aLinha, (cAliasNew)->DUD_SERIE  )
			AAdd(aLinha, (cAliasNew)->DT6_QTDVOL )
			AAdd(aLinha, (cAliasNew)->DT6_VOLORI )
			AAdd(aLinha, (cAliasNew)->DT6_PESO   )
			AAdd(aLinha, (cAliasNew)->DT6_PESOM3 )
			AAdd(aLinha, (cAliasNew)->DT6_VALMER )
			AAdd(aLinha, (cAliasQry)->DUE_NOME   )
			AAdd(aLinha, If(!Empty((cAliasQry)->DUL_BAIRRO),(cAliasQry)->DUL_BAIRRO,(cAliasQry)->DUE_BAIRRO) )
			AAdd(aLinha, If(!Empty((cAliasQry)->DUL_MUN),(cAliasQry)->DUL_MUN,(cAliasQry)->DUE_MUN) )
			AAdd(aLinha, If(!Empty((cAliasQry)->DUL_EST),(cAliasQry)->DUL_EST,(cAliasQry)->DUE_EST) )
			AAdd(aLinha, (cAliasQry)->DUE_EST    )
			AAdd(aLinha, cDatPrv                 )
			AAdd(aLinha, cHorPrv                 )
			//-- Inclui colunas do usuario
			If !Empty(aUsHDocto)
				For nCnt := 1 To Len(aUsHDocto)
					AAdd(aLinha, &( aUsHDocto[nCnt,2] ) )
				Next nCnt
			EndIf
		Else
			AAdd(aLinha, (cAliasNew)->DUD_STATUS )
			AAdd(aLinha, '' )																				//-- Status da rota sem uso no tmsa141
			AAdd(aLinha, Iif( nOpcx == 3, .F., (cAliasNew)->DUD_VIAGEM == M->DTQ_VIAGEM ) )
			AAdd(aLinha, Iif(Empty((cAliasNew)->DUD_SEQUEN),Replicate('x',Len((cAliasNew)->DUD_SEQUEN)),(cAliasNew)->DUD_SEQUEN) )
			AAdd(aLinha, '' )	//-- Armazem
			AAdd(aLinha, '' )	//-- Endereco
			AAdd(aLinha, (cAliasNew)->DUD_FILDOC )
			AAdd(aLinha, (cAliasNew)->DUD_DOC )
			AAdd(aLinha, (cAliasNew)->DUD_SERIE )
			AAdd(aLinha, '' )																				//-- Regiao destino sem uso no tmsa141
			AAdd(aLinha, (cAliasNew)->DT6_DATEMI )
			If cSerAdi == '1' .And. (cAliasNew)->DUD_SERTMS == '1'
				AAdd(aLinha, StoD(cDatPrv) )
				AAdd(aLinha, Posicione('SA1',1,xFilial('SA1')+cCliRem+cLojRem,'A1_NREDUZ'))
				AAdd(aLinha, Posicione('SA1',1,xFilial('SA1')+cCliDes+cLojDes,'A1_NREDUZ'))
			Else
				AAdd(aLinha, (cAliasNew)->DT6_PRZENT )
				AAdd(aLinha, (cAliasQry)->DUE_NOME )
				AAdd(aLinha, Space(Len(SA1->A1_NREDUZ)) )
			EndIf
			AAdd(aLinha, (cAliasNew)->DT6_QTDVOL )
			AAdd(aLinha, (cAliasNew)->DT6_VOLORI )
			AAdd(aLinha, (cAliasNew)->DT6_PESO )
			AAdd(aLinha, (cAliasNew)->DT6_PESOM3 )
			AAdd(aLinha, (cAliasNew)->DT6_VALMER )
			AAdd(aLinha, Iif( nOpcx == 3, .F., (cAliasNew)->DUD_VIAGEM == M->DTQ_VIAGEM ) )
			AAdd(aLinha, cSeqDA7 )
			AAdd(aLinha, (cAliasQry)->DUE_NOME )
			AAdd(aLinha, If(!Empty((cAliasQry)->DUL_END),(cAliasQry)->DUL_END,(cAliasQry)->DUE_END) )
			AAdd(aLinha, If(!Empty((cAliasQry)->DUL_BAIRRO),(cAliasQry)->DUL_BAIRRO,(cAliasQry)->DUE_BAIRRO) )
			AAdd(aLinha, If(!Empty((cAliasQry)->DUL_MUN),(cAliasQry)->DUL_MUN,(cAliasQry)->DUE_MUN) )
			AAdd(aLinha, cDatSol )
			AAdd(aLinha, cHorSol )
			AAdd(aLinha, cDatPrv )
			AAdd(aLinha, cHorPrv )
			AAdd(aLinha, cRota+cZona+cSetor )
			AAdd(aLinha, (cAliasNew)->DT6_BLQDOC )
			If lTmsCFec
				If (cSerAdi == '1' .And. (cAliasNew)->DUD_SERTMS == '1')
					//-- Adiciona o numero do Agendamento, Item e Serv. Transp.
					AAdd(aLinha, (cAliasQry)->DF1_NUMAGE ) //-- Numero do Agendamento
					AAdd(aLinha, (cAliasQry)->DF1_ITEAGE ) //-- Item do Agendamento
				Else
					//-- Adiciona o numero do Agendamento, Item e Serv. Transp.
					AAdd(aLinha, (cAliasNew)->DF1_NUMAGE ) //-- Numero do Agendamento
					AAdd(aLinha, (cAliasNew)->DF1_ITEAGE ) //-- Item do Agendamento
				EndIf
			Else
				AAdd(aLinha, Space(Len(DF1->DF1_NUMAGE)) )
				AAdd(aLinha, Space(Len(DF1->DF1_ITEAGE)) )
			EndIf
			cSerTms := (cAliasNew)->DUD_SERTMS
			AAdd(aLinha, cSerTms )
			AAdd(aLinha, TmsValField('cSerTms',.F.) )
			cSerTms := cSerAnt
			//-- Agendamento de entrega
			AAdd(aLinha, Space(TamSx3("DYD_NUMAGD")[1]))
			AAdd(aLinha, Space(TamSx3("DYD_ITEAGD")[1]))
			AAdd(aLinha, "PMSEDT3")
			AAdd(aLinha, Space(TamSx3("DYD_TIPAGD")[1]))
			AAdd(aLinha, Space(TamSx3("DYD_DATAGD")[1]))
			AAdd(aLinha, Space(TamSx3("DYD_PRDAGD")[1]))
			AAdd(aLinha, Space(TamSx3("DYD_INIAGD")[1]))
			AAdd(aLinha, Space(TamSx3("DYD_FIMAGD")[1]))
			AAdd(aLinha, '' )
			AAdd(aLinha, '' )
			AAdd(aLinha, '' )
			AAdd(aLinha, '' )

			//-- Inclui colunas do usuario
			If lTM141COL
				For nCnt := 1 To Len(aUsHDocto)
					AAdd(aLinha, &( aUsHDocto[nCnt,2] ) )
				Next nCnt
			EndIf
		EndIf
	EndIf
	 //--PONTO DE ENTRADA-Filtra na Montagem dos Documentos a serem selecionados para a viagem
    If ExistBlock('TM141ADD')
    	lAddDoc := ExecBlock("TM141ADD",.F.,.F., {(cAliasNew)->DUD_FILDOC ,(cAliasNew)->DUD_DOC ,(cAliasNew)->DUD_SERIE ,nOpcx ,lVgeMod2 ,cRota ,cZona,cSetor })
		If ValType(lAddDoc) != "L"
	    	lAddDoc := .T.
	    Endif
    Endif
	If lAddDoc
		If lVgeMod2
			If AScan(aAllDocto,{|x| x[2] + x[3] + x[4] == aLinha[2] + aLinha[3] + aLinha[4] }) == 0
				AAdd(aAllDocto,AClone(aLinha))
			EndIf
		Else
			If AScan(aAllDocto,{|x| x[CTARMAZE] + x[CTLOCALI] + x[CTFILDOC] + x[CTDOCTO] + x[CTSERIE] == aLinha[CTARMAZE] + aLinha[CTLOCALI] + aLinha[CTFILDOC] + aLinha[CTDOCTO] + aLinha[CTSERIE] }) = 0
				AAdd(aAllDocto,AClone(aLinha))
				If lTmsCFec .And. lDupDocto .And. Empty(cSerAdi)
					Tmsa141Dup( 1, { cAliasNew, cSeqDA7, cRota, cZona, cSetor, nOpcx }  )
				EndIf
			EndIf
		EndIf
	EndIf

	(cAliasQry)->(DbCloseArea())

Else

	If lVgeMod2
		AAdd(aItem, .F. )
		AAdd(aItem, (cAliasNew)->DUD_FILDOC )
		AAdd(aItem, (cAliasNew)->DUD_DOC    )
		AAdd(aItem, (cAliasNew)->DUD_SERIE  )
		AAdd(aItem, (cAliasNew)->DT6_QTDVOL )
		AAdd(aItem, (cAliasNew)->DT6_VOLORI )
		AAdd(aItem, (cAliasNew)->DT6_PESO   )
		AAdd(aItem, (cAliasNew)->DT6_PESOM3 )
		AAdd(aItem, (cAliasNew)->DT6_VALMER )
		AAdd(aItem, (cNomDes:= Posicione('SA1',1,xFilial('SA1') + (cAliasNew)->DT6_CLIDES + (cAliasNew)->DT6_LOJDES,'A1_NREDUZ'))  )
		AAdd(aItem, If(!Empty(SA1->A1_CEPE),SA1->A1_BAIRROE,SA1->A1_BAIRRO))
		AAdd(aItem, If(!Empty(SA1->A1_CEPE),SA1->A1_MUNE,SA1->A1_MUN))
		AAdd(aItem, If(!Empty(SA1->A1_CEPE),SA1->A1_ESTE,SA1->A1_EST))
		AAdd(aItem, Posicione('SA1',1,xFilial('SA1') + (cAliasNew)->DT6_CLIREM + (cAliasNew)->DT6_LOJREM,'A1_NREDUZ'))
		AAdd(aItem, cNomDes )
		//-- Inclui colunas do usuario
		If !Empty(aUsHDocto)
			For nCnt := 1 To Len(aUsHDocto)
				AAdd(aItem, &( aUsHDocto[nCnt,2] ) )
			Next nCnt
		EndIf
	Else
		DTC->(DbSetOrder(3))
		//--Verifica se o Documento eh uma devolucao:
		DT6->(DbSetOrder(1)) //--DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
		If DT6->( DbSeek( xFilial('DT6')+(cAliasNew)->(DUD_FILDOC+DUD_DOC+DUD_SERIE) ) )
			If DT6->DT6_DOCTMS == StrZero(6, Len(DT6->DT6_DOCTMS))
				//--Se os campos no DT6 referente ao documento original estiverem preenchidos,
				//--significa que o documento posicionado (DUD) refere-se a uma devolucao.
				//--Nesta situacao, deve-se obter os dados (Volumes, Peso, etc.) do documento original
				//--para compor a tela - Viagem Modelo I
				cSeekDTC := xFilial('DTC') + DT6->(DT6_FILDCO+DT6_DOCDCO+DT6->DT6_SERDCO)
			Else
				//--Caso Contrario, trata-se do transporte/entrega de um
				//--documento normal
				cSeekDTC := xFilial("DTC") + (cAliasNew)->(DUD_FILDOC+DUD_DOC+DUD_SERIE)
			EndIf
		EndIf
			//--Busca os dados das Notas Fiscais:
		DTC->(DbSetOrder(3)) //--DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
		If DTC->(DbSeek(cSeekDTC))
			While !DTC->(Eof()) .and. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) == cSeekDTC
				DUH->(DbSetOrder(1))
				IF DUH->(DbSeek(xFilial("DUH")+ cFilAnt + DTC->DTC_NUMNFC + DTC->DTC_SERNFC + DTC->DTC_CLIREM + DTC->DTC_LOJREM + DTC->DTC_CODPRO))

					nPos := aScan(aEndEstoque,{|x| x[1]+x[2]== DUH->DUH_LOCAL + DUH->DUH_LOCALI})
					IF nPos == 0
						AAdd(aEndEstoque,{DUH->DUH_LOCAL,DUH->DUH_LOCALI,DTC->DTC_QTDVOL,DTC->DTC_PESO,DTC->DTC_PESOM3,DTC->DTC_VALOR })
					Else
						aEndEstoque[nPos,3] += DTC->DTC_QTDVOL
						aEndEstoque[nPos,4] += DTC->DTC_PESO
						aEndEstoque[nPos,5] += DTC->DTC_PESOM3
						aEndEstoque[nPos,6] += DTC->DTC_VALOR
					EndIF
				Else
					nPos := aScan(aEndEstoque,{|x| x[1]+x[2]== Space(08)})
					IF nPos == 0
						AAdd(aEndEstoque,{Space(02),Space(06),DTC->DTC_QTDVOL,DTC->DTC_PESO,DTC->DTC_PESOM3,DTC->DTC_VALOR })
					Else
						aEndEstoque[nPos,3] += DTC->DTC_QTDVOL
						aEndEstoque[nPos,4] += DTC->DTC_PESO
						aEndEstoque[nPos,5] += DTC->DTC_PESOM3
						aEndEstoque[nPos,6] += DTC->DTC_VALOR
					EndIF
				EndIF

				If !Empty(DTC->DTC_SQEDES)
                    dbSelectArea("DUL")
					DUL->(DbSetOrder(2))
					If DUL->(DbSeek(xFilial('DUL')+ DTC->DTC_CLIDES + DTC->DTC_LOJDES + DTC->DTC_SQEDES))
        				cEndEnt:= DUL->DUL_END
						cBaiEnt:= DUL->DUL_BAIRRO
						cMunEnt:= DUL->DUL_MUN
					EndIf
				EndIf

				DTC->(DbSkip())
			EndDo
		ElseIf (lDocRee .And. (DT6->DT6_DOCTMS == StrZero(7, Len(DT6->DT6_DOCTMS)) .Or. DT6->DT6_DOCTMS == Replicate('D', Len(DT6->DT6_DOCTMS))))
			While !DT6->(Eof()) .And. DT6->(DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE) == cSeekDTC
				nPos := aScan(aEndEstoque,{|x| x[1]+x[2]== Space(08)})
				If nPos == 0
					AAdd(aEndEstoque,{Space(02),Space(06),DT6->DT6_QTDVOL,DT6->DT6_PESO,DT6->DT6_PESOM3,DT6->DT6_VALMER })
				Else
					aEndEstoque[nPos,3] += DT6->DT6_QTDVOL
					aEndEstoque[nPos,4] += DT6->DT6_PESO
					aEndEstoque[nPos,5] += DT6->DT6_PESOM3
					aEndEstoque[nPos,6] += DT6->DT6_VALMER
				EndIf
				DT6->(DbSkip())
			EndDo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ P.E. utilizado para adicionar registros no aEndEstoque       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTM141END .And. Empty(aEndEstoque)
			aEndEstPE := ExecBlock("TM141END",.F.,.F.,{(cAliasNew)->DUD_FILDOC,(cAliasNew)->DUD_DOC,(cAliasNew)->DUD_SERIE})
			If ValType(aEndEstPE) == "A"
				aEndEstoque:= aEndEstPE
			EndIf
		EndIf

		///--Monta Vetor para exibicao:
		If Len(aEndEstoque) > 0
			nEnderecos := Len(aEndEstoque)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Formato do vetor aItem:                                  ³
			//³                                                         ³
			//³ [01]: Status da Rota                                    ³
			//³ [02]: Status da Rota - Sem uso no TMSA141               ³
			//³ [03]: Mark                                              ³
			//³ [04]: Sequencia da Viagem                               ³
			//³ [05]: Armazem                                           ³
			//³ [06]: Endereco                                          ³
			//³ [07]: Filial Docto                                      ³
			//³ [08]: No. Docto                                         ³
			//³ [09]: Serie Docto                                       ³
			//³ [10]: Regiao Destino - Sem uso no TMSA141               ³
			//³ [11]: Dt. Emissao Docto                                 ³
			//³ [12]: Prazo de Entrega                                  ³
			//³ [13]: Nome Fantasia - Remetente                         ³
			//³ [14]: Nome Fantasia - Destinatario                      ³
			//³ [15]: Volumes da Nota Fiscal                            ³
			//³ [16]: Volumes Original                                  ³
			//³ [17]: Peso                                              ³
			//³ [18]: Peso Cubado                                       ³
			//³ [19]: Valor das Mercadorias                             ³
			//³ [20]: Mark                                              ³
			//³ [21]: Sequencia de entrega                              ³
			//³ [22]: Nome - Solicitante                                ³
			//³ [23]: Endereco - Entrega                                ³
			//³ [24]: Bairro - Entrega                                  ³
			//³ [25]: Municipio - Entrega                               ³
			//³ [26]: Data em Branco                                    ³
			//³ [27]: Hora Solicitacao da Coleta                        ³
			//³ [28]: Data em Branco                                    ³
			//³ [29]: Hora Previsao da Coleta                           ³
			//³ [30]: Rota + Zona + Setor                               ³
			//³ [31]: Documento Bloqueado                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			For nCont := 1 to nEnderecos
				aItem := {}
				AAdd(aItem, (cAliasNew)->DUD_STATUS )
				AAdd(aItem, '' )																			//-- Status da rota sem uso no tmsa141
				AAdd(aItem, Iif( nOpcx == 3, .F., (cAliasNew)->DUD_VIAGEM == M->DTQ_VIAGEM ) )
				AAdd(aItem, Iif(Empty((cAliasNew)->DUD_SEQUEN),Replicate('x',Len((cAliasNew)->DUD_SEQUEN)),(cAliasNew)->DUD_SEQUEN) )
				AAdd(aItem, aEndEstoque[nCont,1] )													//-- Armazem
				AAdd(aItem, aEndEstoque[nCont,2] )													//-- Endereco
				AAdd(aItem, (cAliasNew)->DUD_FILDOC )
				AAdd(aItem, (cAliasNew)->DUD_DOC )
				AAdd(aItem, (cAliasNew)->DUD_SERIE )
				AAdd(aItem, '' )																			//-- Regiao destino sem uso no tmsa141
				AAdd(aItem, (cAliasNew)->DT6_DATEMI )
				AAdd(aItem, (cAliasNew)->DT6_PRZENT )
				AAdd(aItem, Posicione('SA1',1,xFilial('SA1') + (cAliasNew)->DT6_CLIREM + (cAliasNew)->DT6_LOJREM,'A1_NREDUZ'))
				AAdd(aItem, Posicione('SA1',1,xFilial('SA1') + (cAliasNew)->DT6_CLIDES + (cAliasNew)->DT6_LOJDES,'A1_NREDUZ'))
				AAdd(aItem, (cAliasNew)->DT6_QTDVOL )	// 15 - CTQTDVOL
				AAdd(aItem, aEndEstoque[nCont,3] )		// 16 - CTVOLORI
				AAdd(aItem, aEndEstoque[nCont,4] )
				AAdd(aItem, aEndEstoque[nCont,5] )
				AAdd(aItem, aEndEstoque[nCont,6] )
				AAdd(aItem, Iif( nOpcx == 3, .F., (cAliasNew)->DUD_VIAGEM == M->DTQ_VIAGEM ) )
				AAdd(aItem, (cAliasNew)->DA7_SEQUEN ) // CTSEQDA7
				AAdd(aItem, Space(Len(DUE->DUE_NOME)) )
				If !Empty(cEndEnt)
					AAdd(aItem, cEndEnt)
					AAdd(aItem, cBaiEnt)
					AAdd(aItem, cMunEnt)
				Else
					AAdd(aItem, If(!Empty(SA1->A1_CEPE),SA1->A1_ENDENT ,SA1->A1_END))
					AAdd(aItem, If(!Empty(SA1->A1_CEPE),SA1->A1_BAIRROE,SA1->A1_BAIRRO))
					AAdd(aItem, If(!Empty(SA1->A1_CEPE),SA1->A1_MUNE,SA1->A1_MUN))
				EndIf
				AAdd(aItem, CtoD('') )
				AAdd(aItem, Space(Len(DT5->DT5_HORSOL)) )
				AAdd(aItem, CtoD('') )
				AAdd(aItem, Space(Len(DT5->DT5_HORPRV)) )
				AAdd(aItem, cRota+cZona+cSetor )
				AAdd(aItem, (cAliasNew)->DT6_BLQDOC )
	 			AAdd(aItem, Space(Len(DF1->DF1_NUMAGE)) )
				AAdd(aItem, Space(Len(DF1->DF1_ITEAGE)) )
				If cSerAdi == '1'
			  		AAdd(aItem, (cAliasNew)->DUD_SERTMS)
	   				AAdd(aItem, TMSValField((cAliasNew)+"->DUD_SERTMS",.F.,"DUD_DESSVT"))
				Else
					AAdd(aItem, Space(Len(DC5->DC5_SERTMS)) )
					AAdd(aItem, Space(10) )
				EndIf
				//-- Agendamento de Entrega
				If lAgdEntr
					lContinua := TMSA141Agd(@aItem,(cAliasNew)->(DUD_FILDOC+DUD_DOC+DUD_SERIE))
				EndIf
				//--Ponto de Entrada para
				//--incluir colunas do usuario
				If lTM141COL
					For nCnt := 1 To Len(aUsHDocto)
						AAdd(aItem, &( aUsHDocto[nCnt,2] ) )
					Next nCnt
				EndIf

			Next nCont
		EndIf
	EndIf
	  //--PONTO DE ENTRADA-Filtra na Montagem dos Documentos a serem selecionados para a viagem
    If ExistBlock('TM141ADD')
    	lAddDoc := ExecBlock("TM141ADD",.F.,.F., {(cAliasNew)->DUD_FILDOC ,(cAliasNew)->DUD_DOC ,(cAliasNew)->DUD_SERIE ,nOpcx ,lVgeMod2 ,cRota ,cZona,cSetor })
		If ValType(lAddDoc) != "L"
	    	lAddDoc := .T.
	    Endif
    Endif

	If lAddDoc .And. Len(aItem) > 0 .And. lContinua
		If lVgeMod2
			If AScan(aAllDocto,{|x| x[CTSTROTA] + x[CTMARCA] + x[CTSEQUEN] == aItem[CTSTROTA] + aItem[CTMARCA] + aItem[CTSEQUEN] }) == 0
				AAdd(aAllDocto,AClone(aItem))
			EndIf
		Else
			If AScan(aAllDocto,{|x| x[CTARMAZE] + x[CTLOCALI] + x[CTFILDOC] + x[CTDOCTO] + x[CTSERIE] == aItem[CTARMAZE] + aItem[CTLOCALI] + aItem[CTFILDOC] + aItem[CTDOCTO] + aItem[CTSERIE] }) = 0
				AAdd(aAllDocto,AClone(aItem))
			EndIf
		EndIf
	EndIf
EndIf


Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA141ARt³ Autor ³ Alex Egydio           ³ Data ³16.01.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche o vetor aAllDocto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Rota                                               ³±±
±±³          ³ ExpC2 = Descricao da rota                                  ³±±
±±³          ³ ExpC3 = Tipo da rota                                       ³±±
±±³          ³ ExpC4 = Zona                                               ³±±
±±³          ³ ExpC5 = Setor                                              ³±±
±±³          ³ ExpC6 = Status do DUD                                      ³±±
±±³          ³ ExpN1 = Peso real DT6                                      ³±±
±±³          ³ ExpN2 = Peso cubado DT6                                    ³±±
±±³          ³ ExpN3 = Opcao de manutencao                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141ARt(cRota,cDesc,cTipo,cZona,cZonDesc,cSetor,cSetDesc,cStatus,nPeso,nPesoM3,nValMer,nOpcx,cVisual,nQtdVol)

Local nItRota   := 0

DEFAULT cVisual := 'O'
DEFAULT nQtdVol := 1

//-- Adiciona a Rota
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formato do vetor aRota                                                ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ aRota[01] = Mark                                                      ³
//³ aRota[02] = Codigo da Rota                                            ³
//³ aRota[03] = Descricao da Rota                                         ³
//| aRota[04] = Descricao do Tipo da Rota                                 ³
//| aRota[05] = Status da viagem                                          ³
//| aRota[06] = Peso total dos documentos em aberto desta rota            ³
//| aRota[07] = Peso cubado total dos documentos em aberto desta rota     ³
//| aRota[08] = Quantidade total de viagens                               ³
//| aRota[09] = Permite ou nao desmarcar a rota da tela                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nItRota := TmsA140ChkRot('2',cRota)) <= 0
	If nOpcx <> 4 .OR. (nOpcx == 4 .And. cRota == M->DTQ_ROTA .And. (nTipVia == 2 .OR. (!Empty(cZona) .And. !Empty(cSetor))))
		AAdd(aRota,{Iif(nOpcx==3 ,.F.,cRota == M->DTQ_ROTA), cRota, cDesc, cTipo , nQtdVol , nPeso,nPesoM3, nValMer , cStatus == StrZero(3,Len(DUD->DUD_STATUS)) })
	EndIf
Endif
If nItRota <> 0
	aRota[nItRota,5] += nQtdVol
	aRota[nItRota,6] += nPeso
	aRota[nItRota,7] += nPesoM3
	aRota[nItRota,8] += nValMer
EndIf

//-- Adiciona a Zona
If	AScan(aAllZona,{|x| x[4] + x[2] == cRota + cZona}) == 0
	If  nOpcx <> 4 .And. nOpcx <> 2 .Or. (nOpcx == 4 .And. !Empty(cZona) .And. !Empty(cSetor))
		AAdd(aAllZona,{ Iif(cVisual == 'X' .Or. nOpcx == 3, .T. , .F.) ,cZona,cZonDesc,cRota})
	Else
		AAdd(aAllZona,{ Iif(cVisual == 'X' .Or. cVisual == 'O'.Or. nOpcx == 3, .T. , .F.) ,cZona,cZonDesc,cRota})
	EndIf
EndIf

//-- Adiciona o Setor
If	AScan(aAllSetor,{|x| x[4] + x[5] + x[2] == cRota + cZona + cSetor}) == 0
	If nOpcx <> 4 .And. nOpcx <> 2 .Or. (nOpcx == 4 .And. !Empty(cZona) .And. !Empty(cSetor))
		AAdd(aAllSetor,{  Iif(cVisual == 'X' .Or. nOpcx == 3, .T. , .F.) , cSetor,cSetDesc,cRota,cZona,DA6->DA6_ALIANC})
	Else
		AAdd(aAllSetor,{  Iif(cVisual == 'X' .Or. cVisual == 'O' .Or. nOpcx == 3, .T. , .F.) , cSetor,cSetDesc,cRota,cZona,DA6->DA6_ALIANC})
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMS141RotI³ Autor ³Wellington A Santos    ³ Data ³11/02/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carregamento das Rotas zonas e setores                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tms141RotI(nOpcx,cTipoGen,cDescGen,cZonaGen,cZonDesc,cSetorGen,cSetDesc,lSemViag,cRota)

Local aAreaAnt	:= GetArea()
Local cQuery	:= ''
Local cAliasNew := GetNextAlias()

Default lSemViag := .F.

cQuery    := TM141Query(nOpcx,cRota)
cAliasNew := GetNextAlias()
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
If (cAliasNew)->(Eof())
	(cAliasNew)->(DbCloseArea())
	cQuery    := TM141QryVz(nOpcx)
	cAliasNew := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
EndIf

TCSetField(cAliasNew,"DT6_QTDVOL" ,"N",TamSx3("DT6_QTDVOL")[1],TamSx3("DT6_QTDVOL")[2])
TCSetField(cAliasNew,"DT6_PESO"  ,"N",TamSx3("DT6_PESO"  )[1],TamSx3("DT6_PESO"  )[2])
TCSetField(cAliasNew,"DT6_PESOM3","N",TamSx3("DT6_PESOM3"  )[1],TamSx3("DT6_PESOM3"  )[2])
TCSetField(cAliasNew,"DT6_VALMER","N",TamSx3("DT6_VALMER")[1],TamSx3("DT6_VALMER")[2])

While (cAliasNew)->(!Eof())
	TmsA141ARt( (cAliasNew)->DA8_COD , (cAliasNew)->DA8_DESC , Tabela('M3',(cAliasNew)->TIPROT,.F.),  (cAliasNew)->DA5_COD  , (cAliasNew)->DA5_DESC ,;
					(cAliasNew)->DA6_ROTA ,	(cAliasNew)->DA6_REF,(cAliasNew)->DUD_STATUS , (cAliasNew)->DT6_PESO , (cAliasNew)->DT6_PESOM3 , (cAliasNew)->DT6_VALMER, nOpcx, (cAliasNew)->CVISUAL, (cAliasNew)->DT6_QTDVOL )
	(cAliasNew)->( DbSkip() )
EndDo
(cAliasNew)->(DbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formato do vetor aDocto                                                ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ aDocto[01] = Status da movimentacao                                    ³
//³ aDocto[02] = Status da rota sem uso no tmsa141                         |
//³ aDocto[03] = Mark                                                      ³
//| aDocto[04] = Sequencia de entrega                                      ³
//³ aDocto[05] = Armazen                                                   ³
//³ aDocto[06] = Endereco                                                  ³
//| aDocto[07] = FilDoc                                                    ³
//³ aDocto[08] = Doc                                                       ³
//³ aDocto[09] = Serie                                                     ³
//| aDocto[10] = Regiao destino sem uso no tmsa141                         ³
//³ aDocto[11] = Data de Emissao                                           ³
//³ aDocto[12] = Prazo de Entrega                                          ³
//| aDocto[13] = Descricao do Grupo de produtos                            ³
//³ aDocto[14] = Nome do solicitante                                       ³
//³ aDocto[15] = Nome reduzido do cliente (usado so para viagem de entrega)³
//| aDocto[16] = Quantidade do Volume                                      ³
//³ aDocto[17] = Peso                                                      ³
//³ aDocto[18] = Peso cubado                                               ³
//| aDocto[19] = Valor da mercadoria                                       ³
//³ aDocto[20] =                                                           ³
//³ aDocto[21] = Sequencia de entrega                                      ³
//| aDocto[22] = Nome do solicitante                                       ³
//³ aDocto[23] = Endereco do solicitante                                   ³
//³ aDocto[24] = Municipio do solicitante                                  ³
//| aDocto[25] = Data da solicitacao                                       ³
//³ aDocto[26] = Hora da solicitacao                                       ³
//³ aDocto[27] = Data prevista                                             ³
//| aDocto[28] = Hora prevista                                             ³
//³ aDocto[29] = Rota + Zona + Setor                                       ³
//| aDocto[30] = Bloqueio de documento                                     ³
//³ Elemento utilizados para Carga Fechada( MV_TMSCFEC == .T. ) :          ³
//³ aDocto[31] = Numero do Agendamento                                     ³
//| aDocto[32] = Item do Agendamento                                       ³
//³ aDocto[33] = Tipo do Servico                                           ³
//| aDocto[34] = Descricao do Servico                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formato do vetor aZona                                                ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ aZona[01] = Mark                                                      ³
//³ aZona[02] = Codigo da Zona                                            ³
//³ aZona[03] = Descricao da Zona                                         ³
//³ aZona[04] = Codigo da Rota                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formato do vetor aSetor                                               ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ aSetor[01] = Mark                                                     ³
//³ aSetor[02] = Codigo do Setor                                          ³
//³ aSetor[03] = Descricao do Setor                                       ³
//³ aSetor[04] = Codigo da Zona                                           ³
//³ aSetor[05] = Codigo da Rota                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpcx <> 3
	TmsA141ZSt( M->DTQ_ROTA,  ,nOpcx)
	TmsA141Doc( nOpcx )
EndIf

RestArea(aAreaAnt)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tms141AddD³ Autor ³ Alex Egydio           ³ Data ³16.01.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche o vetor aAllDocto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpNA = Vetor com informacoes do documento. Passado por    ³±±
±±³          ³         referencia qd rota generica                        ³±±
±±³          ³ ExpC1 ate ExpC7 = Alias dos arquivos                       ³±±
±±³          ³ ExpC8 = Sequencia obtida na pesquisa do DA7                ³±±
±±³          ³ ExpC9 = Rota ou rota generica                              ³±±
±±³          ³ ExpCA = Zona ou zona generica                              ³±±
±±³          ³ ExpCB = Setor ou setor generico                            ³±±
±±³          ³ ExpL1 = .T. Preenche o vetor aAllDocto                     ³±±
±±³          ³ ExpN1 = Opcao de manutencao                                ³±±
±±³          ³ ExpL2 = Indica se considera rota generica                  ³±±
±±³          ³ ExpA1 = ARRAY para duplicar o documento quando TMSCFEC     ³±±
±±³          ³         estiver ativo e a viagem for de coleta             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tms141AddD(aLinha,cAliasDA8,cAliasDA9,cAliasDT5,cAliasDT6,cAliasDUD,cAliasSB1,cAliasDTC,cSeqDA7,cRota,cZona,cSetor,lAddDoc,nOpcx,lRotGen, aLinhaDup)

Local nCnt
Local aEnder	  := {}
Local aItem		  := {}
Local nCntFor	  := 0
Local lDupDocto  := .F.
Local lContinua  := .T.
Local lAgdEntr   := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)     //-- Agendamento de Entrega.

DEFAULT aLinha	   := {}
DEFAULT lAddDoc   := .T.
DEFAULT lRotGen   := .F.
DEFAULT aLinhaDup := {}
DEFAULT cSeqDA7   := ""
Private cAliasDoc := cAliasDUD

If Type("cSerAdi") == "U"
	cSerAdi := ""
EndIf

If	lColeta
	If lTmsCFec
		lDupDocto := !Empty( (cAliasDT5)->DT5_CLIDES ) .And. !Empty( (cAliasDT5)->DT5_LOJDES )
	EndIf

	If	Empty(aLinha)
		AAdd(aLinha, (cAliasDUD)->DUD_STATUS )
		AAdd(aLinha, '' )																				//-- Status da rota sem uso no tmsa141
		AAdd(aLinha, Iif( nOpcx == 3, .F., (cAliasDUD)->DUD_VIAGEM == M->DTQ_VIAGEM ) )
		AAdd(aLinha, Iif(Empty((cAliasDUD)->DUD_SEQUEN),Replicate('x',Len((cAliasDUD)->DUD_SEQUEN)),(cAliasDUD)->DUD_SEQUEN) )
		AAdd(aLinha, '' )	//-- Armazem
		AAdd(aLinha, '' )	//-- Endereco
		AAdd(aLinha, (cAliasDUD)->DUD_FILDOC )
		AAdd(aLinha, (cAliasDUD)->DUD_DOC )
		AAdd(aLinha, (cAliasDUD)->DUD_SERIE )
		AAdd(aLinha, '' )																				//-- Regiao destino sem uso no tmsa141
		AAdd(aLinha, (cAliasDT6)->DT6_DATEMI )
		AAdd(aLinha, (cAliasDT6)->DT6_PRZENT )
		AAdd(aLinha, DUE->DUE_NOME )
		AAdd(aLinha, Space(Len(SA1->A1_NREDUZ)) )
		AAdd(aLinha, (cAliasDT6)->DT6_QTDVOL )
		AAdd(aLinha, (cAliasDT6)->DT6_VOLORI )
		AAdd(aLinha, (cAliasDT6)->DT6_PESO )
		AAdd(aLinha, (cAliasDT6)->DT6_PESOM3 )
		AAdd(aLinha, (cAliasDT6)->DT6_VALMER )
		AAdd(aLinha, Iif( nOpcx == 3, .F., (cAliasDUD)->DUD_VIAGEM == M->DTQ_VIAGEM ) )
		AAdd(aLinha, cSeqDA7 )
		AAdd(aLinha, DUE->DUE_NOME )
		AAdd(aLinha, DUE->DUE_END )
		AAdd(aLinha, DUE->DUE_BAIRRO )
		AAdd(aLinha, DUE->DUE_MUN )
		AAdd(aLinha, (cAliasDT5)->DT5_DATSOL )
		AAdd(aLinha, (cAliasDT5)->DT5_HORSOL )
		AAdd(aLinha, (cAliasDT5)->DT5_DATPRV )
		AAdd(aLinha, (cAliasDT5)->DT5_HORPRV )
		AAdd(aLinha, cRota+cZona+cSetor )
		AAdd(aLinha, (cAliasDT6)->DT6_BLQDOC )
		If lTmsCFec
			//-- Adiciona o numero do Agendamento, Item e Serv. Transp.
			AAdd(aLinha, DF1->DF1_NUMAGE ) //-- Numero do Agendamento
			AAdd(aLinha, DF1->DF1_ITEAGE ) //-- Item do Agendamento
			AAdd(aLinha, StrZero( 1, Len( DC5->DC5_SERTMS ) ) )
			AAdd(aLinha, STR0050 ) //"Coleta"
		EndIf
		//-- Agendamento de Entrega
		If lAgdEntr
			If !lTmsCFec
				AAdd(aLinha, Space(Len(DF1->DF1_NUMAGE)) )
				AAdd(aLinha, Space(Len(DF1->DF1_ITEAGE)) )
				AAdd(aLinha, Space(Len(DC5->DC5_SERTMS)) )
				AAdd(aLinha, Space(10) )
				AAdd(aLinha, Space(40) )
			EndIf
			lContinua := TMSA141Agd(@aLinha,(cAliasDUD)->(DUD_FILDOC+DUD_DOC+DUD_SERIE))
		EndIf
		//-- Inclui colunas do usuario
		If lTM141COL
			For nCnt := 1 To Len(aUsHDocto)
				AAdd(aLinha, &( aUsHDocto[nCnt,2] ) )
			Next nCnt
		EndIf
	EndIf

	If lAddDoc .And. !lRotGen .And. lContinua
		If AScan(aAllDocto,{|x| x[CTDOCROT] + x[CTARMAZE] + x[CTLOCALI] + x[CTFILDOC] + x[CTDOCTO] + x[CTSERIE] == aLinha[CTDOCROT] + aLinha[CTARMAZE] + aLinha[CTLOCALI] + aLinha[CTFILDOC] + aLinha[CTDOCTO] + aLinha[CTSERIE] }) <= 0
			AAdd(aAllDocto,AClone(aLinha))
		EndIf
	EndIf
	If lTmsCFec .And. lDupDocto
		Tmsa141Dup(2, {cAliasDT5, cAliasDT6, cAliasDUD, cAliasSB1, cSeqDA7, cRota, cZona, cSetor, nOpcx}, @aLinhaDup, lAddDoc )
	EndIf
Else
	If	Empty(aLinha)

		TmsA140DUH(aEnder,cAliasDTC,cAliasSB1,cAliasDT6)

		For nCntFor := 1 To Len(aEnder)
			aItem := {}
			AAdd(aItem, (cAliasDUD)->DUD_STATUS )
			AAdd(aItem, '' )																			//-- Status da rota sem uso no tmsa141
			AAdd(aItem, Iif( nOpcx == 3, .F., (cAliasDUD)->DUD_VIAGEM == M->DTQ_VIAGEM ) )
			AAdd(aItem, Iif(Empty((cAliasDUD)->DUD_SEQUEN),Replicate('x',Len((cAliasDUD)->DUD_SEQUEN)),(cAliasDUD)->DUD_SEQUEN) )
			AAdd(aItem, aEnder[ nCntFor, 1 ] )													//-- Armazem
			AAdd(aItem, aEnder[ nCntFor, 2 ] )													//-- Endereco
			AAdd(aItem, (cAliasDUD)->DUD_FILDOC )
			AAdd(aItem, (cAliasDUD)->DUD_DOC )
			AAdd(aItem, (cAliasDUD)->DUD_SERIE )
			AAdd(aItem, '' )																			//-- Regiao destino sem uso no tmsa141
			AAdd(aItem, (cAliasDT6)->DT6_DATEMI )
			AAdd(aItem, (cAliasDT6)->DT6_PRZENT )
			AAdd(aItem, Posicione('SA1',1,xFilial('SA1') + aEnder[ nCntFor, 4 ] + aEnder[ nCntFor, 5 ],'A1_NREDUZ') )
			SA1->(DbSetOrder( 1 ))
			SA1->(MsSeek(xFilial('SA1') + aEnder[ nCntFor, 6 ] + aEnder[ nCntFor, 7 ]))
			AAdd(aItem, SA1->A1_NREDUZ )
			AAdd(aItem, aEnder[ nCntFor, 3 ] )
			AAdd(aItem, (cAliasDT6)->DT6_VOLORI )
			AAdd(aItem, (cAliasDT6)->DT6_PESO )
			AAdd(aItem, (cAliasDT6)->DT6_PESOM3 )
			AAdd(aItem, (cAliasDT6)->DT6_VALMER )
			AAdd(aItem, Iif( nOpcx == 3, .F., (cAliasDUD)->DUD_VIAGEM == M->DTQ_VIAGEM ) )
			AAdd(aItem, cSeqDA7 )
			AAdd(aItem, Space(Len(DUE->DUE_NOME)) )
			AAdd(aItem, SA1->A1_END )
			AAdd(aItem, SA1->A1_BAIRRO )
			AAdd(aItem, SA1->A1_MUN )
			AAdd(aItem, CtoD('') )
			AAdd(aItem, Space(Len(DT5->DT5_HORSOL)) )
			AAdd(aItem, CtoD('') )
			AAdd(aItem, Space(Len(DT5->DT5_HORPRV)) )
			AAdd(aItem, cRota+cZona+cSetor )
			AAdd(aItem, (cAliasDT6)->DT6_BLQDOC )
			//-- Descrição Utilizada para serviço adicional
			AAdd(aItem, Space(Len(DF1->DF1_NUMAGE)) )
			AAdd(aItem, Space(Len(DF1->DF1_ITEAGE)) )
			If cSerAdi == "1"
				AAdd(aItem, (cAliasNew)->DUD_SERTMS)
   				AAdd(aItem, TMSValField((cAliasNew)+"->DUD_SERTMS",.F.,"DUD_DESSVT"))
     		Else
     			AAdd(aItem, Space(Len(DC5->DC5_SERTMS)) )
				AAdd(aItem, Space(10) )
   		EndIf
			//-- Agendamento de Entrega
			If lAgdEntr
				lContinua := TMSA141Agd(@aItem,(cAliasDUD)->(DUD_FILDOC+DUD_DOC+DUD_SERIE))
			EndIf
			//-- Inclui colunas do usuario
			If lTM141COL
				For nCnt := 1 To Len(aUsHDocto)
					AAdd(aItem, &( aUsHDocto[nCnt,2] ) )
				Next nCnt
			EndIf
			If lContinua
				If AScan(aLinha,{|x| x[CTDOCROT] + x[CTARMAZE] + x[CTLOCALI] + x[CTFILDOC] + x[CTDOCTO] + x[CTSERIE] == aItem[CTDOCROT] + aItem[CTARMAZE] + aItem[CTLOCALI] + aItem[CTFILDOC] + aItem[CTDOCTO] + aItem[CTSERIE] }) <= 0
					AAdd(aLinha,AClone(aItem))
				EndIf
			EndIf
		Next
	EndIf

	If lAddDoc .And. !lRotGen
		For nCntFor := 1 To Len(aLinha)
			If AScan(aAllDocto,{|x| x[CTDOCROT] + x[CTARMAZE] + x[CTLOCALI] + x[CTFILDOC] + x[CTDOCTO] + x[CTSERIE] == aLinha[nCntFor,CTDOCROT] + aLinha[nCntFor,CTARMAZE] + aLinha[nCntFor,CTLOCALI] + aLinha[nCntFor,CTFILDOC] + aLinha[nCntFor,CTDOCTO] + aLinha[nCntFor,CTSERIE] }) <= 0
				AAdd(aAllDocto,AClone(aLinha[nCntFor]))
			EndIf
		Next
	EndIf
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA141Ag³ Autor ³ Robson Alves          ³ Data ³ 19/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe o Agendamento.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa141Age()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa141Age()

Local aAreaDF0 := DF0->( GetArea() )
Local cNumAge  := AllTrim( aDocto[oLbxDocto:nAT, CTNUMAGE ] )

If Empty( cNumAge )
	Help(' ', 1, 'TMSA14103')	//-- Esse documento não foi agendado.
Else
	//-- Posicona o Agendamento.
	SaveInter()
	DF0->( DbSetOrder(1) )
	If DF0->( MsSeek(xFilial("DF0") + cNumAge) )
		Inclui := .F.
		TMSF05Mnt("DF0",DF0->(Recno()),2)
	EndIf
	RestInter()
EndIf

RestArea( aAreaDF0 )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA141Du³ Autor ³ Robson Alves          ³ Data ³ 21/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Duplica o item para representar a entrega.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Acao( 1 = Para Top, 2 = CodeBase )                 ³±±
±±³          ³ ExpA1 = Array de parametros.                               ³±±
±±³          ³ 	ExpN1 == 1( Acao ).                                       ³±±
±±³          ³    	ExpA1[1] = Alias da query.                            ³±±
±±³          ³    	ExpA1[2] = Sequencia de Entrega.                      ³±±
±±³          ³    	ExpA1[3] = Rota                                       ³±±
±±³          ³    	ExpA1[4] = Zona                                       ³±±
±±³          ³    	ExpA1[5] = Setor                                      ³±±
±±³          ³    	ExpA1[6] = Opcao do aRotina.                          ³±±
±±³          ³ 	ExpN1 == 2                                                ³±±
±±³          ³    	ExpA1[1] = Alias do DT5( Solicitacao de Coleta ).     ³±±
±±³          ³    	ExpA1[2] = Alias do DT6( Documentos de Transporte ).  ³±±
±±³          ³    	ExpA1[3] = Alias do DUD( Movimento de Viagem ).       ³±±
±±³          ³    	ExpA1[4] = Alias do SB1( Cadastro de Produtos ).      ³±±
±±³          ³    	ExpA1[5] = Sequencia de Entrega.                      ³±±
±±³          ³    	ExpA1[6] = Rota                                       ³±±
±±³          ³    	ExpA1[7] = Zona                                       ³±±
±±³          ³    	ExpA1[8] = Setor                                      ³±±
±±³          ³    	ExpA1[9] = Opcao do aRotina.                          ³±±
±±³          ³ ExpA2 = Array para duplicar os documentos( CodeBase )      ³±±
±±³          ³ ExpL1 = Adiciona linha no array auxililar( CodeBase )      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa141Dup()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa141Dup(nAcao, aParam, aLinhaDup, lAddDoc)

Local nCnt        := 0
Local aIteEnt     := {}
Local aAreaDF1    := {}
Local cQuery      := ''
Local cAliasQry   := ''
Local lContinua   := .T.
Local lAgdEntr    := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)    //-- Agendamento de Entrega.

Default aLinhaDup := {}
Default lAddDoc   := .T.
Private cAliasDoc := ""

If nAcao == 1
	cQuery := " SELECT DUE_NOME "
	cQuery += "  FROM " + RetSQLName("DT5") + " DT5 "
	cQuery += "  JOIN " + RetSQLName("DUE") + " DUE "
	cQuery += "    ON DUE_FILIAL = '" + xFilial("DUE") + "' "
	cQuery += "    AND DUE_CODSOL  = DT5_CODSOL  "
	cQuery += "    AND DUE.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE DT5_FILIAL = '" + xFilial("DT5") + "' "
	cQuery += "    AND DT5_FILDOC = '" + (cAliasNew)->DUD_FILDOC + "' "
	cQuery += "    AND DT5_DOC    = '" + (cAliasNew)->DUD_DOC    + "' "
	cQuery += "    AND DT5_SERIE  = '" + (cAliasNew)->DUD_SERIE  + "' "
	cQuery += "    AND DT5.D_E_L_E_T_ = ' ' "
	cQuery    := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

	cAliasDoc := aParam[1]
	aAreaDF1  := DF1->( GetArea() )

	AAdd(aIteEnt, (aParam[1])->DUD_STATUS )
	AAdd(aIteEnt, '' )																				//-- Status da rota sem uso no tmsa141
	AAdd(aIteEnt, Iif( aParam[6] == 3, .F., (aParam[1])->DUD_VIAGEM == M->DTQ_VIAGEM ) )
	AAdd(aIteEnt, Iif(Empty((aParam[1])->DUD_SEQENT),Replicate('x',Len((aParam[1])->DUD_SEQENT)),(aParam[1])->DUD_SEQENT) )
	AAdd(aIteEnt, '' )	//-- Armazem
	AAdd(aIteEnt, '' )	//-- Endereco
	AAdd(aIteEnt, (aParam[1])->DUD_FILDOC )
	AAdd(aIteEnt, (aParam[1])->DUD_DOC )
	AAdd(aIteEnt, (aParam[1])->DUD_SERIE )
	AAdd(aIteEnt, '' )																				//-- Regiao destino sem uso no tmsa141
	AAdd(aIteEnt, (aParam[1])->DT6_DATEMI )
	AAdd(aIteEnt, (aParam[1])->DT6_PRZENT )
	AAdd(aIteEnt, (cAliasQry)->DUE_NOME )
	AAdd(aIteEnt, Space(Len(SA1->A1_NREDUZ)) )
	AAdd(aIteEnt, (aParam[1])->DT6_QTDVOL )
	AAdd(aIteEnt, (aParam[1])->DT6_VOLORI )
	AAdd(aIteEnt, (aParam[1])->DT6_PESO )
	AAdd(aIteEnt, (aParam[1])->DT6_PESOM3 )
	AAdd(aIteEnt, (aParam[1])->DT6_VALMER )
	AAdd(aIteEnt, Iif( aParam[6] == 3, .F., (aParam[1])->DUD_VIAGEM == M->DTQ_VIAGEM ) )
	AAdd(aIteEnt, aParam[2] )
	AAdd(aIteEnt, Posicione("SA1", 1, xFilial("SA1") + (aParam[1])->(DT5_CLIDES + DT5_LOJDES), "A1_NREDUZ" ) )

	//-- Obtem o endereco do Destinatario.
	DF1->( DbSetOrder( 1 ) )
	If  DF1->( MsSeek( xFilial("DF1") + (aParam[1])->( DF1_NUMAGE + DF1_ITEAGE ) ) ) .And.;
		!Empty( DF1->DF1_SQEDES )

		AAdd(aIteEnt, Posicione("DUL", 2, xFilial("DUL") + (aParam[1])->(DT5_CLIDES + DT5_LOJDES) + DF1->DF1_SQEDES, "DUL_END" ) )
		AAdd(aIteEnt, DUL->DUL_BAIRRO )
		AAdd(aIteEnt, DUL->DUL_MUN )
	Else

		AAdd(aIteEnt, SA1->A1_END )
		AAdd(aIteEnt, SA1->A1_BAIRRO )
		AAdd(aIteEnt, SA1->A1_MUN )
	EndIf

	AAdd(aIteEnt, (aParam[1])->DT5_DATSOL )
	AAdd(aIteEnt, (aParam[1])->DT5_HORSOL )
	AAdd(aIteEnt, (aParam[1])->DT5_DATENT )
	AAdd(aIteEnt, (aParam[1])->DT5_HORENT )
	AAdd(aIteEnt, aParam[3]+aParam[4]+aParam[5] )
	AAdd(aIteEnt, (aParam[1])->DT6_BLQDOC )
	AAdd(aIteEnt, (aParam[1])->DF1_NUMAGE )
	AAdd(aIteEnt, (aParam[1])->DF1_ITEAGE )
	AAdd(aIteEnt, StrZero( 3, Len( DC5->DC5_SERTMS ) ) )
	AAdd(aIteEnt, STR0051 ) //"Entrega"
	AAdd(aIteEnt, Space(40) )
	//-- Agendamento de Entrega
	If lAgdEntr .And. cSerTms == StrZero( 3, Len( DC5->DC5_SERTMS ) )   
		lContinua := TMSA141Agd(@aIteEnt,(aParam[1])->(DUD_FILDOC+DUD_DOC+DUD_SERIE))
	EndIf

	//-- Inclui colunas do usuario
	If lTM141COL
		For nCnt := 1 To Len(aUsHDocto)
			AAdd(aIteEnt, &( aUsHDocto[nCnt,2] ) )
		Next nCnt
	EndIf

	If lContinua
		AAdd(aAllDocto,AClone(aIteEnt))
	EndIf
	(cAliasQry)->(DbCloseArea())

	RestArea( aAreaDF1 )
Else
	cAliasDoc := aParam[3] //-- DUD
	If Empty( aLinhaDup )
		AAdd(aLinhaDup, (aParam[3])->DUD_STATUS )
		AAdd(aLinhaDup, '' )																				//-- Status da rota sem uso no tmsa141
		AAdd(aLinhaDup, Iif( aParam[9] == 3, .F., (aParam[3])->DUD_VIAGEM == M->DTQ_VIAGEM ) )
		AAdd(aLinhaDup, Iif(Empty((aParam[3])->DUD_SEQENT),Replicate('x',Len((aParam[3])->DUD_SEQENT)),(aParam[3])->DUD_SEQENT) )
		AAdd(aLinhaDup, '' )	//-- Armazem
		AAdd(aLinhaDup, '' )	//-- Endereco
		AAdd(aLinhaDup, (aParam[3])->DUD_FILDOC )
		AAdd(aLinhaDup, (aParam[3])->DUD_DOC )
		AAdd(aLinhaDup, (aParam[3])->DUD_SERIE )
		AAdd(aLinhaDup, '' )																				//-- Regiao destino sem uso no tmsa141
		AAdd(aLinhaDup, (aParam[2])->DT6_DATEMI )
		AAdd(aLinhaDup, (aParam[2])->DT6_PRZENT )
		AAdd(aLinhaDup, DUE->DUE_NOME )
		AAdd(aLinhaDup, Space(Len(SA1->A1_NREDUZ)) )
		AAdd(aLinhaDup, (aParam[2])->DT6_QTDVOL )
		AAdd(aLinhaDup, (aParam[2])->DT6_VOLORI )
		AAdd(aLinhaDup, (aParam[2])->DT6_PESO )
		AAdd(aLinhaDup, (aParam[2])->DT6_PESOM3 )
		AAdd(aLinhaDup, (aParam[2])->DT6_VALMER )
		AAdd(aLinhaDup, Iif( aParam[9] == 3, .F., (aParam[3])->DUD_VIAGEM == M->DTQ_VIAGEM ) )
		AAdd(aLinhaDup, aParam[5] )
		AAdd(aLinhaDup, Posicione("SA1", 1, xFilial("SA1") + (aParam[1])->(DT5_CLIDES + DT5_LOJDES), "A1_NREDUZ" ) )

		//-- Obtem o endereco do Destinatario.
		If  !Empty( DF1->DF1_SQEDES )
			AAdd(aLinhaDup, Posicione("DUL", 2, xFilial("DUL") + (aParam[1])->(DT5_CLIDES + DT5_LOJDES) + DF1->DF1_SQEDES, "DUL_END" ) )
			AAdd(aLinhaDup, DUL->DUL_BAIRRO )
			AAdd(aLinhaDup, DUL->DUL_MUN )
		Else
			AAdd(aLinhaDup, SA1->A1_END )
			AAdd(aLinhaDup, SA1->A1_BAIRRO )
			AAdd(aLinhaDup, SA1->A1_MUN )
		EndIf

		AAdd(aLinhaDup, (aParam[1])->DT5_DATSOL )
		AAdd(aLinhaDup, (aParam[1])->DT5_HORSOL )
		AAdd(aLinhaDup, (aParam[1])->DT5_DATENT )
		AAdd(aLinhaDup, (aParam[1])->DT5_HORENT )
		AAdd(aLinhaDup, aParam[6]+aParam[7]+aParam[8] )
		AAdd(aLinhaDup, (aParam[2])->DT6_BLQDOC )

		//-- Adiciona o numero do Agendamento e Item.
		AAdd(aLinhaDup, DF1->DF1_NUMAGE ) //-- Numero do Agendamento
		AAdd(aLinhaDup, DF1->DF1_ITEAGE ) //-- Item do Agendamento
		AAdd(aLinhaDup, StrZero( 3, Len( DC5->DC5_SERTMS ) ) )
		AAdd(aLinhaDup, STR0051 ) //"Entrega"

		//-- Agendamento de Entrega
		If lAgdEntr .And. cSerTms == StrZero( 3, Len( DC5->DC5_SERTMS ) )   
			lContinua := TMSA141Agd(@aLinhaDup,(aParam[3])->(DUD_FILDOC+DUD_DOC+DUD_SERIE))
		EndIf

		//-- Inclui colunas do usuario
		If lTM141COL
			For nCnt := 1 To Len(aUsHDocto)
				AAdd(aLinhaDup, &( aUsHDocto[nCnt,2] ) )
			Next nCnt
		EndIf
	EndIf

	If lAddDoc .And. lContinua
		AAdd(aAllDocto,AClone(aLinhaDup))
		aLinhaDup := {}
	EndIf
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA141SE³ Autor ³ Robson Alves          ³ Data ³ 23/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza a sequencia de Entrega e status do item do        ³±±
±±³          ³Agendamento.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa141SEnt(ExpC1,ExpC2,ExpC3,ExpC4)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial do Documento.                               ³±±
±±³          ³ ExpC2 = Numero do Documento.                               ³±±
±±³          ³ ExpC3 = Serie do Documento.                                ³±±
±±³          ³ ExpC4 = Sequencia de Entrega.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa141SEnt(cFilDoc, cDoc, cSerie, cSeqEnt, lExcViagem)
Local aAreaDUD := DUD->(GetArea())
Local aAreaDTC 	:= DTC->(GetArea())
Local aAreaDF1 	:= DF1->(GetArea())
Local cSeekDUD 	:= ""

Default lExcViagem := .F.

DUD->(DbSetOrder(1))
DUD->(MsSeek(cSeekDUD := xFilial('DUD') + cFilDoc + cDoc + cSerie, .F.))
While DUD->(!Eof() .And. DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE == cSeekDUD)
	If DUD->DUD_SERTMS == cSerTms .And. DUD->DUD_STATUS == StrZero( 1, Len(DUD->DUD_STATUS))
		//-- Atualiza a sequencia de entrega.
		RecLock('DUD',.F.)
		If	cSeqEnt != Replicate('x',Len(DUD->DUD_SEQUEN))
			DUD->DUD_SEQENT := cSeqEnt
		EndIf
		MsUnLock()
		//-- Pesquisa documento cliente / agendamento
		DbSelectArea('DTC')
		DTC->(DbSetOrder(3)) //DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE
		If	DTC->(DbSeek(xFilial("DTC") + cFilDoc + cDoc + cSerie))
			//-- Atualiza o status de entrega do item do Agendamento.
			DbSelectArea('DF1')
			DF1->(DbSetOrder(3)) //DF1_FILIAL+DF1_FILDOC+DF1_DOC+DF1_SERIE
			If DF1->(MsSeek(xFilial("DF1") + DTC->(DTC_FILCFS + DTC->DTC_NUMSOL) + "COL"))
				RecLock("DF1",.F.)
				If nTipVia == 3
					DF1->DF1_STAENT := StrZero( 3, Len(DT5->DT5_STATUS)) // 3 = Planejado.
				Else
					If lExcViagem
						DF1->DF1_STAENT := StrZero( 2, Len(DT5->DT5_STATUS)) // 2 = Confirmado.
					Else
						DF1->DF1_STAENT := StrZero( 4, Len(DT5->DT5_STATUS)) // 4 = Em processo.
					EndIf
				EndIf
				MsUnLock()
			EndIf
			Exit
		EndIf
	EndIf
	DUD->(DbSkip())
EndDo

RestArea(aAreaDUD)
RestArea(aAreaDTC)
RestArea(aAreaDF1)
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA141Tp³ Autor ³ Robson Alves          ³ Data ³ 26/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna os tipos de veiculos associados aos documentos.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa141TpVei()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa141TpVei( aTipVei, aDoctosMrk )

Local nA       := 0
Local aAreaDT5 := DT5->( GetArea() )
Local aAreaDVT := DVT->( GetArea() )
Local cSeekDVT := ""
Local nSeek    := 0

aTipVei    := {}
aDoctosMrk := {}

DT5->( DbSetOrder( 4 ) )
DVT->( DbSetOrder( 1 ) )
For nA := 1 To Len( aDocto )

	If lTmsCFec .And. aDocto[ nA, CTSERTMS ] == StrZero( 3, Len( DC5->DC5_SERTMS ) )
		Loop
	EndIf

	//-- Verifica se o item esta marcado.
	If	aDocto[ nA, CTMARCA ]

		If lTmsCFec
			If DT5->( MsSeek( xFilial("DT5") + aDocto[ nA, CTFILDOC ] + aDocto[ nA, CTDOCTO ] + aDocto[ nA, CTSERIE ] ) )

				DVT->( MsSeek( cSeekDVT := xFilial("DVT") + DT5->DT5_FILORI + DT5->DT5_NUMSOL ) )
				While DVT->( !Eof() .And. DVT_FILIAL + DVT_FILORI + DVT_NUMSOL == cSeekDVT )

					If ( nSeek := Ascan( aTipVei, { |x| x[1] == DVT->DVT_TIPVEI } ) ) == 0
						AAdd( aTipVei, { DVT->DVT_TIPVEI, Posicione( "DUT", 1, xFilial("DUT") + DVT->DVT_TIPVEI, "DUT_DESCRI" ), DVT->DVT_QTDVEI } )
					Else
						aTipVei[ nSeek, 3 ] += DVT->DVT_QTDVEI
					EndIf

					DVT->( dbSkip() )
				EndDo

			EndIf
		EndIf
		AAdd( aDoctosMrk, { aDocto[ nA, CTFILDOC ], aDocto[ nA, CTDOCTO ], aDocto[ nA, CTSERIE ]} )
	EndIf
Next nA

RestArea( aAreaDT5 )
RestArea( aAreaDVT )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA141Line³ Autor ³ Eduardo de Souza     ³ Data ³ 23/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao da bLine do documento.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA141Line(ExpN1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Posicao da linha no listbox                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA141Line(nAt)

Local abLine  := {}
Local nCnt    := 0
Local nPosIni := 0
Local lAgdEntr:= Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)   //-- Agendamento de Entrega.

If Type("cSerAdi") == "U"
	cSerAdi := ""
EndIf

//-- Utilizado na troca de rotas.
If nAt > Len(aDocto)
	Return( abLine )
EndIf

If	lColeta
	DbSelectArea("DT6")
	AAdd( abLine, Tms140RetBitmap(aDocto[nAt,CTSTATUS],'1') )
	AAdd( abLine, Iif(aDocto[nAt,CTMARCA], oMarked, oNoMarked ))
	AAdd( abLine, aDocto[nAt,CTSEQUEN])
	If lTmscFec
		AAdd( abLine, aDocto[nAt,CTNUMAGE])
		AAdd( abLine, aDocto[nAt,CTITEAGE])
		AAdd( abLine, aDocto[nAt,CTDESSVT])
	EndIf
	AAdd( abLine, aDocto[nAt,CTFILDOC])
	AAdd( abLine, aDocto[nAt,CTDOCTO])
	AAdd( abLine, aDocto[nAt,CTSERIE])
	AAdd( abLine, aDocto[nAt,CTSOLICI])
	AAdd( abLine, aDocto[nAt,CTENDERE])
	AAdd( abLine, aDocto[nAt,CTBAIRRO])
	AAdd( abLine, aDocto[nAt,CTMUNICI])
	AAdd( abLine, Transform(aDocto[nAt,CTDATSOL],PesqPict('DT5','DT5_DATSOL')))
	AAdd( abLine, Transform(aDocto[nAt,CTHORSOL],PesqPict('DT5','DT5_HORSOL')))
	AAdd( abLine, Transform(aDocto[nAt,CTDATPRV],PesqPict('DT5','DT5_DATPRV')))
	AAdd( abLine, Transform(aDocto[nAt,CTHORPRV],PesqPict('DT5','DT5_HORPRV')))
	AAdd( abLine, Transform(aDocto[nAt,CTQTDVOL],PesqPict('DT6','DT6_QTDVOL')))
	AAdd( abLine, Transform(aDocto[nAt,CTPLIQUI],PesqPict('DT6','DT6_PESO'	 )))
	AAdd( abLine, Transform(aDocto[nAt,CTPESOM3],PesqPict('DT6','DT6_PESOM3')))
Else
	AAdd( abLine, Tms140RetBitmap(aDocto[nAt,CTSTATUS],'1') )
	If lAgdEntr
		AAdd( abLine,        LoadBitmap( GetResources() ,aDocto[nAt,CTPRIAGD])  )
		AAdd( abLine,       Iif(aDocto[nAt,CTMARCA ], oMarked, oNoMarked ))
		AAdd( abLine,           aDocto[nAt,CTTIPAGD])
		AAdd( abLine, Transform(aDocto[nAt,CTDATAGD],PesqPict('DYD','DYD_DATAGD')))
		AAdd( abLine,           aDocto[nAt,CTPRDAGD])
		AAdd( abLine, Transform(aDocto[nAt,CTINIAGD],PesqPict('DYD','DYD_INIAGD')))
		AAdd( abLine, Transform(aDocto[nAt,CTFIMAGD],PesqPict('DYD','DYD_FIMAGD')))
	ELse
	AAdd( abLine, Iif(aDocto[nAt,CTMARCA], oMarked, oNoMarked ))
	EndIf
	AAdd( abLine, aDocto[nAt,CTSEQUEN])
	If	lLocaliz
		AAdd( abLine, aDocto[nAt,CTARMAZE])
		AAdd( abLine, aDocto[nAt,CTLOCALI])
	EndIf
	AAdd( abLine, aDocto[nAt,CTFILDOC])
	AAdd( abLine, aDocto[nAt,CTDOCTO])
	AAdd( abLine, aDocto[nAt,CTSERIE])
	If cSerAdi $ '1/3' .And. Len(aDocto[nAt]) >= CTDESSVT
		AAdd( abLine, aDocto[nAt,CTDESSVT])
	EndIf
	AAdd( abLine, aDocto[nAt,CTNOMREM])
	AAdd( abLine, aDocto[nAt,CTNOMDES])
	AAdd( abLine, aDocto[nAt,CTENDERE])
	AAdd( abLine, aDocto[nAt,CTBAIRRO])
	AAdd( abLine, aDocto[nAt,CTMUNICI])
	AAdd( abLine, Transform(aDocto[nAt,CTDATEMI],PesqPict('DT6','DT6_DATEMI')))
	AAdd( abLine, Transform(aDocto[nAt,CTPRZENT],PesqPict('DT6','DT6_PRZENT')))
	AAdd( abLine, Transform(aDocto[nAt,CTQTDVOL],PesqPict('DT6','DT6_QTDVOL')))
	AAdd( abLine, Transform(aDocto[nAt,CTVOLORI],PesqPict('DT6','DT6_VOLORI')))
	AAdd( abLine, Transform(aDocto[nAt,CTPLIQUI],PesqPict('DT6','DT6_PESO'  )))
	AAdd( abLine, Transform(aDocto[nAt,CTPESOM3],PesqPict('DT6','DT6_PESOM3')))
	AAdd( abLine, Transform(aDocto[nAt,CTVALMER],PesqPict('DT6','DT6_VALMER')))
EndIf

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
±±³Fun‡„o    ³TmsA141MOk³ Autor ³ Alex Egydio           ³ Data ³28.09.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Condicoes nas quais nao deve alterar a marca do documento  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Item do vetor aDocto                               ³±±
±±³          ³ ExpN2 - Opcao de manutencao                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA141MOk(nItem,nOpcx,aMsgErr,lAllMark)

Local lRet    := .T.
Local nStatus := Len(DUD->DUD_STATUS)
Local lBloqEnt:= .F.
Local cFilDF8 := ""
Local cNumDF8 := ""
//-- Parametro para controle de Transações da Viagem mod2,
//-- o documento ficara locado até confirmar ou fechar a viagem impossibilitando o uso do documento por outras Estações.     
Local lCONTDOC := SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran")

Private cCriRat:= ""

If Type("cSerAdi") == "U"
	cSerAdi := ""
EndIf
lBloqEnt := cSerAdi $ ('1/3') .And. (M->DTQ_STATUS == StrZero(2, Len(DTQ->DTQ_STATUS)) .Or. M->DTQ_STATUS == StrZero(5, Len(DTQ->DTQ_STATUS)) )

Default aMsgErr := {}
Default lAllMark := .F.
//-- Condicoes nas quais nao deve alterar a marca do documento
//-- Status do documento igual a 2 - Em Transito, 3 - Carregado, 4 - Encerrado
//-- Codigo do documento em branco
//-- Opcao de manutencao visualizar ou excluir
If aDocto[nItem,CTSTATUS] == StrZero(2,nStatus) .Or.;
	aDocto[nItem,CTSTATUS] == StrZero(3,nStatus) .Or.;
	aDocto[nItem,CTSTATUS] == StrZero(4,nStatus) .Or.;
	aDocto[nItem,CTSTATUS] == StrZero(9,nStatus) .Or.;
	Empty(aDocto[nItem,CTDOCTO]) .Or. nOpcx == 2 .Or. nOpcx == 5
	lRet := .F.
EndIf

//-- Nao e permitido selecionar um documento
//-- ja selecionado em outra viagem
If lRet
	If !aDocto[nItem,CTMARCA] //-- Se o documento nao estiver marcado, validar antes de marcar
		DUD->(DbSetOrder(1))
		If DUD->(MsSeek(xFilial("DUD") + aDocto[nItem,CTFILDOC] + aDocto[nItem,CTDOCTO] + aDocto[nItem,CTSERIE] + cFilAnt ) )
			If lBloqEnt .And. DUD->DUD_SERTMS != StrZero(1, Len (DUD->DUD_SERTMS)) .And. DUD->DUD_STATUS == StrZero(1, Len (DUD->DUD_STATUS))
				Help("  ",1,"TMSA14107")
		   	lRet := .F.
		   EndIf
			If aDocto[ nItem, CTBLQDOC ] == '1'  //Documento Bloqueado
				AAdd( aMsgErr, { STR0014 + ": " + DUD->DUD_FILDOC + "-" + AllTrim(DUD->DUD_DOC) + "-" + DUD->DUD_SERIE +  ": " + STR0079 , , }) //-- "Docto." , " Bloqueado."
				lRet := .F.
			EndIf
			If nOpcx == 3 .And. !Empty(DUD->DUD_VIAGEM) //-- Verificacao se alguma viagem ja na gravou este documento
				lRet := .F.
			Else
                If lCONTDOC .AND. lAllMark .AND. !TmsConTran(aDocto[nItem,CTFILDOC],aDocto[nItem,CTDOCTO],aDocto[nItem,CTSERIE], lAllMark)
					Help(' ',1,'TMSA14105',,STR0014 + " " + aDocto[nItem,CTFILDOC] + " " + aDocto[nItem,CTDOCTO] + "-" + aDocto[nItem,CTSERIE],3,1) //--"O documento foi selecionado em outra viagem." ### "Docto."
					lRet := .F.
				EndIf
			EndIf
			//--- Verifica se está em uma Programação em Aberto
			If lRet
				If FindFunction("TMSA146Prg") .And. !IsInCallStack(AllTrim('TMSA146'))
					DbSelectArea("DF8")
					If DF8->(ColumnPos("DF8_SEQPRG")) > 0
						lRet:= TMSA146Prg(aDocto[nItem,CTFILDOC],aDocto[nItem,CTDOCTO],aDocto[nItem,CTSERIE],@cFilDF8,@cNumDF8)
						If !lRet
							AAdd( aMsgErr, { STR0014 + ": " + aDocto[nItem,CTFILDOC] + " " + aDocto[nItem,CTDOCTO] + "-" + aDocto[nItem,CTSERIE] + ": " + STR0094  + ': ' +  cFilDF8 + ' - ' + cNumDF8 , , }) //-- estÃ¡ em uma ProgramaÃ§Ã£o de carregamento em aberto.
						EndIf
					EndIf
				EndIf
	   		EndIf

			//---- Verifica se é um Documento de Rateio com criterio Origem/Destino Vge
            If DUD->DUD_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS)) // Solicitacao de Coleta
                DT5->(DbSetOrder(4))
                If DT5->(MsSeek(xFilial("DT5")+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))
                    If !Empty(DT5->DT5_CODNEG) .And. !Empty(DT5->DT5_SERVIC)
                        cCriRat:= TMSA144DcR(DT5->DT5_NCONTR,DT5->DT5_CODNEG,DT5->DT5_SERVIC)

                        If cCriRat == "A" //-- 'A' = Origem/Destino Vge
                            //"Documentos com Criterio de Rateio: " + cCriRat +  nao podem ser selecionados pela Viagem Modelo 1."
                            Aadd(aMsgErr,{STR0014 + ": " + aDocto[nItem,CTFILDOC] + " " + aDocto[nItem,CTDOCTO] + "-" + aDocto[nItem,CTSERIE] + " : " + STR0095 + cCriRat + " = " + TMSValField('cCriRat',.F.) + " " + STR0096 })
                            lRet:= .F.
                        EndIf
                    EndIf
                EndIf
			EndIf
		EndIf
	Else //--Se o documento estiver marcado
		//-- Ao desmarcar o documento preciso libera-lo para ser utilizado em outra viagem
        TmsConTran(aDocto[nItem,CTFILDOC],aDocto[nItem,CTDOCTO],aDocto[nItem,CTSERIE], .F.)
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA141Prd    ³ Autor ³ Patricia A. Salomao  ³ Data ³27.10.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe Tela contendo os Produtos do Documento Posicionado       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA141Prd(ExpC1,ExpC2,ExpC3)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Filial do Docto                                        ³±±
±±³          ³ExpC2 - No. do Docto                                           ³±±
±±³          ³ExpC3 - Serie do Docto                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141Prd(cFilDoc,cDoc,cSerie)

Local aArea     := GetArea()
Local aPrdDoc   := {}
Local cAliasNew := ''
Local cQuery    := ''

//-- Controle de dimensoes de objetos
Local aObjects	:= {}
Local aInfo		:= {}
Local aPosObj	:= {}
Local aSize		:= {}
//-- MsDialog
Local oDlgEsp
//-- ListBox
Local cLbx		:= ''
Local oLbx

Default cFilDoc := ''
Default cDoc    := ''
Default cSerie  := ''

If Empty(cFilDoc) .Or. Empty(cDoc) .Or. Empty(cSerie)
	Return( .T. )
EndIf

   If cSerTms == StrZero(1,Len(DC5->DC5_SERTMS)) //-- Coleta
      cAliasNew := GetNextAlias()
		cQuery := " SELECT DT5_FILORI FILORI, DT5_NUMSOL NUMSOL, B1_DESC DESPRO, BM_DESC  DESCGRP, "
		cQuery += " DUM_CODPRO CODPRO "
		cQuery += " FROM "
		cQuery += RetSqlName('DT5') + " DT5 "
		cQuery += "LEFT JOIN " + RetSqlName('DUM') + " DUM "
		cQuery += "  ON DUM_FILIAL     = '"+xFilial("DUM")+"'"
		cQuery += " AND DUM_FILORI     = DT5_FILORI "
	   	cQuery += " AND DUM_NUMSOL     = DT5_NUMSOL"
		cQuery += " AND DUM.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN " + RetSqlName('SB1') + " SB1 "
		cQuery += "  ON B1_FILIAL      = '"+xFilial("SB1")+"'"
		cQuery += " AND B1_COD  = DUM.DUM_CODPRO "
		cQuery += "LEFT JOIN " + RetSqlName('SBM') + " SBM "
		cQuery += "  ON BM_FILIAL   = '"+xFilial("SBM")+"'"
		cQuery += " AND BM_GRUPO  = SB1.B1_GRUPO"
		cQuery += " AND SBM.D_E_L_E_T_    = ' '"
		cQuery += " WHERE DT5_FILIAL     = '"+xFilial("DT5")+"'"
		cQuery += "   AND DT5_FILDOC     = '"+cFilDoc+"'"
		cQuery += "   AND DT5_DOC        = '"+cDoc+"'"
		cQuery += "   AND DT5_SERIE      = '"+cSerie+"'"
		cQuery += "   AND DT5.D_E_L_E_T_ = ' '"
		If !Empty(cGrpProd)
			cQuery += "   AND B1_GRUPO IN ("+cGrpProd+")"
			cQuery += "   AND SB1.D_E_L_E_T_ = ' '"
		EndIf
   Else
      cAliasNew := GetNextAlias()
		cQuery := " SELECT DTC_CODPRO CODPRO, B1_DESC DESPRO, BM_DESC DESCGRP"
		cQuery += " FROM "
		cQuery += RetSqlName('DTC') + " DTC "

		cQuery += "LEFT JOIN " + RetSqlName('SB1') + " SB1 "
		cQuery += "  ON B1_FILIAL   = '"+xFilial("SB1")+"'"
		cQuery += " AND B1_COD  = DTC.DTC_CODPRO "

		cQuery += "LEFT JOIN " + RetSqlName('SBM') + " SBM "
		cQuery += "  ON BM_FILIAL   = '"+xFilial("SBM")+"'"
		cQuery += " AND BM_GRUPO  = SB1.B1_GRUPO "
		cQuery += " AND SBM.D_E_L_E_T_    = ' '"

		cQuery += " WHERE DTC_FILIAL    = '"+xFilial("DTC")+"'"
		cQuery += "   AND DTC_FILDOC    = '"+cFilDoc+"'"
   	cQuery += "   AND DTC_DOC       = '"+cDoc+"'"
		cQuery += "   AND DTC_SERIE     = '"+cSerie+"'"
		cQuery += "   AND DTC_QTDVOL    > 0"
		cQuery += "   AND DTC.D_E_L_E_T_    = ' '"
		If !Empty(cGrpProd)
			cQuery += "   AND B1_GRUPO IN ("+cGrpProd+")"
			cQuery += "   AND SB1.D_E_L_E_T_    = ' '"
		EndIf
   EndIf

	cQuery := ChangeQuery(cQuery)

	cAliasNew := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)

	DbSelectArea(cAliasNew)
	(cAliasNew)->( DbGoTop() )
	Do While (cAliasNew)->(!Eof())

      If Ascan( aPrdDoc, (cAliasNew)->CODPRO ) == 0
			AAdd(aPrdDoc,{(cAliasNew)->CODPRO, (cAliasNew)->DESPRO, (cAliasNew)->DESCGRP,.F.})
	   EndIf

		(cAliasNew)->(dbSkip())
	EndDo

   dbCloseArea()

If Len(aPrdDoc) > 0

	//-- Calcula as dimensoes dos objetos
	aSize  := MsAdvSize()

	AAdd( aObjects, { 50, 50,.T.,.T. } )

	aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
	aPosObj:= MsObjSize( aInfo, aObjects,.T. )

	DEFINE MSDIALOG oDlgEsp TITLE STR0013 + ': ' +cFilDoc + '/'+cDoc+'/'+cSerie FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL //"Produtos do Documento: "

		@ aPosObj[1,1], aPosObj[1,2] LISTBOX oLbx VAR cLbx FIELDS HEADER ;
													OemToAnsi(Posicione('SX3',2,'DTC_CODPRO'	,'X3Titulo()'))	,;
													OemToAnsi(Posicione('SX3',2,'DTC_DESPRO'	,'X3Titulo()'))	,;
													OemToAnsi(Posicione('SX3',2,'BM_DESC'   	,'X3Titulo()'))	;
													SIZE	aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1]-20 OF oDlgEsp PIXEL
		oLbx:SetArray(aPrdDoc)
		oLbx:bLine	:= { || {	aPrdDoc[oLbx:nAT,01]	,;
										aPrdDoc[oLbx:nAT,02]	,;
										aPrdDoc[oLbx:nAT,03]	} }

	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||oDlgEsp:End()},{||oDlgEsp:End()})

EndIf

RestArea(aArea)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TM141Query ³ Autor ³ Eduardo de Souza     ³ Data ³ 09/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Query da viagem de entrega (Rota / Documento).             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TM141Query(ExpN1,ExpC1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±³          ³ ExpC1 - Rota                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA141                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM141Query(nOpcx,cRota,lOrderBy,cFiltroDUD)

Local cStatus   := StrZero(1,Len(DUD->DUD_STATUS))
Local cViagem   := Space(Len(DUD->DUD_VIAGEM))
Local cQuery    := ""
Local cFilDT5   := xFilial("DT5")
Local lAlianca  := TmsAlianca() //-- Verifica se utiliza Alianca
Local lPesqCCli := SuperGetMv("MV_TMSPCLI",,.F.)	//-- Atraves deste parametro é possivel fazer com que o
													//-- Pontos por setor sejam pesquisados por codigo de Cliente.
Local cZona     :=  ""
Local cSetor    :=  ""
Local lVgeColet := .F.
Local cQueryTp  := If("POSTGRES"$TCGetDb(),"Char(1)","") //-- Usado em query BD POSTGRES
Local lDTP 	  := .F.

Local lTMSDCol := SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.

Default cRota       := ""
Default lOrderBy    := .T.
Default cFiltroDUD  := ""

If lVgeMod2 == Nil
	lVgeMod2 := ("TMSA144" $ AllTrim(FunName()))
EndIf

If !lVgeMod2
	lVgeExpr := .F.
EndIf

If Type("lCdrOri") == "U"
	lCdrOri := .F.
EndIf

If Type("cSerAdi") == "U"
	cSerAdi := ""
EndIf

//Viagem de Coleta gerada pelo Modelo 2, para ser visualizada no Modelo 1
If !lVgeMod2 .And. nOpcx <> 3 .And. cSerTms == StrZero( 1, Len( DC5->DC5_SERTMS ) )
	DUD->(DbSetOrder(2))
	If DUD->(dBSeek(xFilial('DUD')+ M->DTQ_FILORI+M->DTQ_VIAGEM)) .And. Empty(DUD->DUD_ZONA) .And. Empty(DUD->DUD_SETOR)
		If TmsA144DA7(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,M->DTQ_ROTA,@cZona,@cSetor,.F.,.T.)
			lVgeColet:= .T.
		EndIf
	EndIf
EndIf

If cSerTms == '2'
	If !lVgeExpr
		cQuery := " SELECT DUD.DUD_FILDOC, DUD.DUD_DOC, DUD.DUD_SERIE, DUD.R_E_C_N_O_ DUDRECNO "
		cQuery += "   FROM " + RetSQLTab("DUD")
		cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "     AND DUD_SERTMS = '" + cSerTms + "' "
		cQuery += "     AND DUD_TIPTRA = '" + cTipTra + "' "
		cQuery += "     AND DUD_VIAGEM = ' ' "
		cQuery += "     AND DUD_STATUS = '" + StrZero(1,Len(DUD->DUD_STATUS)) + "' "
		If !lTMSDCol
			cQuery += "     AND DUD_FILORI = '" + cFilAnt + "'"
		EndIf
		cQuery += "     AND D_E_L_E_T_ = ' ' "
	Else
		cQuery := " SELECT DUD.DUD_FILDOC, DUD.DUD_DOC, DUD.DUD_SERIE, DUD.R_E_C_N_O_ DUDRECNO "
		cQuery += "   FROM " + RetSQLTab("DUD")
		cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "     AND DUD_SERTMS = '" + cSerTms + "' "
		cQuery += "     AND DUD_TIPTRA = '" + cTipTra + "' "
		If !lTMSDCol
			cQuery += "     AND DUD_FILORI = '" + cFilAnt + "'"
		EndIf
		cQuery += "     AND DUD_VIAGEM = '" + M->DTQ_VIAGEM + "' "
		cQuery += "     AND D_E_L_E_T_ = ' ' "
	EndIf
	If !Empty(cFiltroDUD)
		cQuery += cFiltroDUD
	EndIf
ElseIf nTipVia == 2 //-- Viagem Vazia
	cQuery := TM141QryVz(nOpcx,cRota)
Else
	If nOpcx <> 3
		If lOrderBy
			If Empty(cRota)
				cQuery += " SELECT "
				cQuery += " DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(TIPROT) TIPROT, "
				cQuery += " DA5_COD, MIN(DA5_DESC) DA5_DESC, DA6_ROTA, MIN(DA6_REF) DA6_REF , "
				cQuery += " MIN(DUD_STATUS) DUD_STATUS, SUM(DT6_QTDVOL) DT6_QTDVOL, SUM(DT6_PESO) DT6_PESO    , SUM(DT6_VOLORI) DT6_VOLORI, "
				cQuery += " SUM(DT6_PESOM3) DT6_PESOM3, SUM(DT6_VALMER) DT6_VALMER, MIN(DUD_SERTMS) DUD_SERTMS," + cQueryTp + " 'X' CVISUAL "
				cQuery += "  FROM ( "
				cQuery += " SELECT "
				cQuery += " DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(DA8_TIPROT) TIPROT, "
				cQuery += " DA5_COD, MIN(DA5_DESC) DA5_DESC, DA6_ROTA, MIN(DA6_REF) DA6_REF , "
				cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_VOLORI) DT6_VOLORI, "
				cQuery += " MIN(DT6_PESOM3) DT6_PESOM3, MIN(DT6_VALMER) DT6_VALMER, MIN(DUD_SERTMS) DUD_SERTMS, DUD_FILDOC, DUD_DOC, DUD_SERIE," + cQueryTp + " 'X' CVISUAL "
			Else
				If lColeta
					cQuery += " SELECT "
					cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, MIN(DUD_SERTMS) DUD_SERTMS, "
					cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM)  DUD_VIAGEM, MIN(DUD_SEQUEN) DUD_SEQUEN, "
					cQuery += " MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DT6_DATEMI)  DT6_DATEMI, MIN(DT6_PRZENT) DT6_PRZENT, "
					cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)    DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, "
					cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DT5_SEQEND)  DT5_SEQEND, MIN(DT5_DATSOL) DT5_DATSOL, "
					cQuery += " MIN(DT5_HORSOL) DT5_HORSOL, MIN(DT5_DATPRV)  DT5_DATPRV, MIN(DT5_HORPRV) DT5_HORPRV, "
					cQuery += " MIN(DT5_CODSOL) DT5_CODSOL, "
					cQuery += " MIN(DT5_DDD)    DT5_DDD   , MIN(DT5_TEL)     DT5_TEL   , MIN(DT6_VOLORI) DT6_VOLORI, "
					If nOpcx == 2
						cQuery += " MIN(DUD_ZONA) DA7_PERCUR, "
					Else
						cQuery += " MIN(DA6_PERCUR) DA7_PERCUR, "
					EndIf
					cQuery += cQueryTp + " ' ' DA7_SEQUEN, MIN(DA6_ROTA)   DA7_ROTA "
					If !lVgeMod2 .And. lTmsCFec
						//-- Retorna os campos referente ao Agendamento.
						cQuery += ", MIN(DF1_ITEAGE) DF1_ITEAGE "
						cQuery += ", MIN(DF1_NUMAGE) DF1_NUMAGE "
						cQuery += ", MIN(DT5_CLIDES) DT5_CLIDES "
						cQuery += ", MIN(DT5_LOJDES) DT5_LOJDES "
						cQuery += ", MIN(DT5_DATENT) DT5_DATENT "
						cQuery += ", MIN(DT5_HORENT) DT5_HORENT "
						cQuery += ", MIN(DUD_SEQENT) DUD_SEQENT "
					EndIf
				Else
					cQuery += " SELECT "
					cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, MIN(DUD_SERTMS) DUD_SERTMS, "
					cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DUD_SEQUEN) DUD_SEQUEN, "
					cQuery += " MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DT6_DATEMI) DT6_DATEMI, MIN(DT6_PRZENT) DT6_PRZENT, "
					cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, "
					cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DT6_CLIREM) DT6_CLIREM, MIN(DT6_LOJREM) DT6_LOJREM, "
					cQuery += " MIN(DT6_CLIDES) DT6_CLIDES, MIN(DT6_LOJDES) DT6_LOJDES, "
					If nOpcx == 2
						cQuery += " MIN(DUD_ZONA) DA7_PERCUR, "
					Else
						cQuery += " MIN(DA6_PERCUR) DA7_PERCUR, "
					EndIf

					cQuery += cQueryTp //-- Usado em query BD POSTGRES
					cQuery += " ''              DA7_SEQUEN, MIN(DA6_ROTA)  DA7_ROTA   , MIN(DT6_VOLORI) DT6_VOLORI  "
				EndIf
			EndIf
		Else
			cQuery += " SELECT "
			cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, DUD.R_E_C_N_O_ DUDRECNO "
		EndIf
		cQuery += " FROM "
		If lColeta .And. !lVgeMod2 .And. lTmsCFec
			//-- Verifica se existe Agendamento associado a Solicitacao de Coleta.
			cQuery +=   RetSqlName('DUD') + " DUD "//Movimento de Viagem
			cQuery += "LEFT JOIN " + RetSqlName('DF1') + " DF1 "
			cQuery += "  ON DF1_FILIAL     = '" + xFilial("DF1") + "'"
			cQuery += " AND DF1_FILDOC     = DUD_FILDOC"
			cQuery += " AND DF1_DOC        = DUD_DOC"
			cQuery += " AND DF1_SERIE      = DUD_SERIE"
			cQuery += " AND DF1.D_E_L_E_T_ = ' ', "
		Else
			cQuery +=   RetSqlName('DUD') + " DUD, "//Movimento de Viagem
		EndIf
		cQuery +=  RetSqlName('DA6') + " DA6, " //Cadastro de setor x Zona
		cQuery +=  RetSqlName('DA5') + " DA5, " //Cadastro de Zonas
		cQuery +=  RetSqlName('DA8') + " DA8, "//Documentos de transporte
		cQuery +=  RetSqlName('DA9') + " DA9, "// Zonas x Rotas
		cQuery +=  RetSqlName('DT6') + " DT6 "//Documentos de transporte
		If lColeta
			cQuery +=   "," + RetSqlName('DT5') + " DT5 "//Solicitacao de coleta
		EndIf
		cQuery += " WHERE DUD_FILIAL     = '" + xFilial("DUD") + "' "
		cQuery += "   AND DUD_FILORI     = '" + M->DTQ_FILORI  + "' "
		cQuery += "   AND DUD_VIAGEM     = '" + M->DTQ_VIAGEM  + "' "
		If !Empty(cSerAdi)
			cQuery += "AND DUD_SERTMS IN  ( '" + cSerTms + "', '" + cSerAdi + "' )"
		Else
			cQuery += "AND DUD_SERTMS     = '" + cSerTms + "'"
		EndIf
		cQuery += "   AND DUD_TIPTRA     = '" + cTipTra + "'"
		cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
		If !Empty(cFiltroDUD)
			cQuery += cFiltroDUD
		EndIf
		cQuery += "   AND DT6_FILIAL     = '" + xFilial("DT6") + "'"
		cQuery += "   AND DT6_FILDOC     = DUD_FILDOC "
		cQuery += "   AND DT6_DOC        = DUD_DOC "
		cQuery += "   AND DT6_SERIE      = DUD_SERIE "
		cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
		If lColeta
			If Empty(cFilDT5)
				cQuery += "AND DT5_FILIAL = '" + xFilial("DT5") + "'"
			Else
				cQuery += "AND DT5_FILIAL = DUD_FILDOC "
			EndIf
			cQuery += "   AND DT5_FILDOC     = DUD_FILDOC "
			cQuery += "   AND DT5_DOC        = DUD_DOC "
			cQuery += "   AND DT5_SERIE      = DUD_SERIE "
			cQuery += "   AND DT5.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery += "   AND DA8_FILIAL     = '" + xFilial("DA8") + "'"
		cQuery += "   AND DA8_COD        = '" + M->DTQ_ROTA + "'"
		cQuery += "   AND DA8.D_E_L_E_T_ = ' ' "
		cQuery += "   AND DA5_FILIAL     = '" + xFilial("DA5") + "'"
		If lVgeColet
			cQuery += "   AND DA5_COD        ='" + cZona + "'"
		Else
			cQuery += "   AND DA5_COD        =  DUD_ZONA "
		EndIf
		cQuery += "   AND DA5.D_E_L_E_T_ = ' ' "
		cQuery += "   AND DA6_FILIAL     = '" + xFilial("DA6") + "'"
		cQuery += "   AND DA6_PERCUR     =  DUD_ZONA "

		If lVgeColet
			cQuery += "   AND DA6_ROTA       ='" + cSetor + "'"
		Else
			cQuery += "   AND DA6_ROTA       =  DUD_SETOR "
		EndIf
		cQuery += "   AND DA6.D_E_L_E_T_ = ' ' "

		If Empty(cRota)
			cQuery += " GROUP BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE, DA8_COD, DA5_COD, DA6_ROTA ) QUERY "
			cQuery += " GROUP BY DA8_COD, DA5_COD, DA6_ROTA"
		Else
			cQuery += " GROUP BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE"
		EndIf
	EndIf

	If nOpcx == 3 .Or. nOpcx == 4
		If nOpcx == 4 //Se for alteracao traz os dados que estao gravados, junto com os dados novos pra incluir
			cQuery +=" UNION ALL "

            // Viagem de entrega e status em transito.
            If cSerTms == StrZero(3,Len(DT6->DT6_SERTMS)) .AND. M->DTQ_STATUS == "2"
                lDTP := .T.
            Else
                //Verificar se há Lote com Viagem Preenchdida
                cAliasDTP := GetNextAlias()
                cQryDTP := " SELECT COUNT(DTP_LOTNFC) as TOT_LOTE FROM "
                cQryDTP += RetSqlName('DTP') + " DTP WHERE "
                cQryDTP += "  DTP.DTP_FILIAL = '" + xFilial("DTP") + "'"
                cQryDTP += "  AND DTP.DTP_VIAGEM = '" + M->DTQ_VIAGEM + "'"
                cQryDTP += "  AND DTP.D_E_L_E_T_ = ' ' "
                cQryDTP := ChangeQuery(cQryDTP)
                dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryDTP ), cAliasDTP, .F., .T. )

                If 	(cAliasDTP)->TOT_LOTE > 0 .And. lVgeMod2
                    lDTP := .T.
                EndIf
                (cAliasDTP)->(dbCloseArea())
            EndIf
		EndIf
		If lOrderBy
			If Empty(cRota)
				cQuery += " SELECT "
				cQuery += " DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(TIPROT) TIPROT, "
				cQuery += " DA5_COD, MIN(DA5_DESC) DA5_DESC, DA6_ROTA, MIN(DA6_REF) DA6_REF , "
				cQuery += " MIN(DUD_STATUS) DUD_STATUS, SUM(DT6_QTDVOL) DT6_QTDVOL, SUM(DT6_PESO)   DT6_PESO  , SUM(DT6_VOLORI) DT6_VOLORI, "
				cQuery += " SUM(DT6_PESOM3) DT6_PESOM3, SUM(DT6_VALMER) DT6_VALMER, MIN(DUD_SERTMS) DUD_SERTMS," + cQueryTp + " 'O' CVISUAL "
				cQuery += "  FROM ( "
				cQuery += " SELECT "
				cQuery += " DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(DA8_TIPROT) TIPROT, "
				cQuery += " DA5_COD, MIN(DA5_DESC) DA5_DESC, DA6_ROTA, MIN(DA6_REF) DA6_REF , "
				cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_VOLORI) DT6_VOLORI, "
				cQuery += " MIN(DT6_PESOM3) DT6_PESOM3, MIN(DT6_VALMER) DT6_VALMER, MIN(DUD_SERTMS) DUD_SERTMS, DUD_FILDOC, DUD_DOC, DUD_SERIE," + cQueryTp + " 'O' CVISUAL "
			Else
				If lColeta
					cQuery += " SELECT "
					cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, MIN(DUD_SERTMS) DUD_SERTMS, "
					cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DUD_SEQUEN) DUD_SEQUEN, "
					cQuery += " MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DT6_DATEMI) DT6_DATEMI, MIN(DT6_PRZENT) DT6_PRZENT, "
					cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, "
					cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DT5_SEQEND) DT5_SEQEND, MIN(DT5_DATSOL) DT5_DATSOL, "
					cQuery += " MIN(DT5_HORSOL) DT5_HORSOL, MIN(DT5_DATPRV) DT5_DATPRV, MIN(DT5_HORPRV) DT5_HORPRV, "
					cQuery += " MIN(DT5_CODSOL) DT5_CODSOL, "
					cQuery += " MIN(DT5_DDD)    DT5_DDD   , MIN(DT5_TEL)    DT5_TEL   , MIN(DT6_VOLORI) DT6_VOLORI, "
					If nOpcx == 2
						cQuery += " MIN(DUD_ZONA) DA7_PERCUR, "
					Else
						cQuery += " MIN(DA6_PERCUR) DA7_PERCUR, "
					EndIf
					cQuery += " MIN(DA7_SEQUEN) DA7_SEQUEN, MIN(DA7_ROTA)   DA7_ROTA    "
					If !lVgeMod2 .And. lTmsCFec
						//-- Retorna os campos referente ao Agendamento.
						cQuery += ", MIN(DF1_ITEAGE) DF1_ITEAGE "
						cQuery += ", MIN(DF1_NUMAGE) DF1_NUMAGE "
						cQuery += ", MIN(DT5_CLIDES) DT5_CLIDES "
						cQuery += ", MIN(DT5_LOJDES) DT5_LOJDES "
						cQuery += ", MIN(DT5_DATENT) DT5_DATENT "
						cQuery += ", MIN(DT5_HORENT) DT5_HORENT "
						cQuery += ", MIN(DUD_SEQENT) DUD_SEQENT "
					EndIf
				Else
					cQuery += " SELECT "
					cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, MIN(DUD_SERTMS) DUD_SERTMS, "
					cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DUD_SEQUEN) DUD_SEQUEN, "
					cQuery += " MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DT6_DATEMI) DT6_DATEMI, MIN(DT6_PRZENT) DT6_PRZENT, "
					cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, "
					cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DT6_CLIREM) DT6_CLIREM, MIN(DT6_LOJREM) DT6_LOJREM, "
					cQuery += " MIN(DT6_CLIDES) DT6_CLIDES, MIN(DT6_LOJDES) DT6_LOJDES, MIN(DA7_PERCUR) DA7_PERCUR, "
					cQuery += " MIN(DA7_SEQUEN) DA7_SEQUEN, MIN(DA7_ROTA)   DA7_ROTA  , MIN(DT6_VOLORI) DT6_VOLORI  "
				EndIf
			EndIf
		Else
			cQuery += " SELECT "
			cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, DUD.R_E_C_N_O_ DUDRECNO "
		EndIf
		cQuery += " FROM "
		If lColeta .And. !lVgeMod2 .And. lTmsCFec .And. !Empty(cRota)
			//-- Verifica se existe Agendamento associado a Solicitacao de Coleta.
			cQuery +=   RetSqlName('DUD') + " DUD "//Movimento de Viagem
			cQuery += "LEFT JOIN " + RetSqlName('DF1') + " DF1 ON"
			cQuery += " DF1_FILIAL = '" + xFilial("DF1") + "'"
			cQuery += " AND DF1_FILDOC = DUD_FILDOC"
			cQuery += " AND DF1_DOC = DUD_DOC"
			cQuery += " AND DF1_SERIE = DUD_SERIE"
			cQuery += " AND DF1.D_E_L_E_T_ = ' ', "
		Else
			cQuery +=   RetSqlName('DUD') + " DUD, "//Movimento de Viagem
			If lDTP
				cQuery += RetSqlName('DTP') + " DTP, "
			EndIf
		EndIf
		cQuery +=  RetSqlName('DA8') + " DA8, "//Documentos de transporte
		cQuery +=  RetSqlName('DA7') + " DA7, " // Clientes por setor
		cQuery +=  RetSqlName('DA9') + " DA9, "// Zonas x Rotas
		cQuery +=  RetSqlName('DT6') + " DT6, "//Documentos de transporte
		cQuery +=  RetSqlName('DA5') + " DA5, "//Zonas
		cQuery +=  RetSqlName('DA6') + " DA6  " //Setor x Zonas
		If lColeta
			cQuery +=   ", " + RetSqlName('DT5') + " DT5 "//Solicitacao de coleta
		EndIf
		If !Empty(cGrpProd) //-- Filtra por Grupo de Produtos
			If lColeta
				cQuery += ", " + RetSqlName('SB1') + " SB1  "//Produtos
				cQuery += ", " + RetSqlName('DUM') + " DUM "//Itens da Solicitacao de Coleta
			Else
				cQuery +=  ", " + RetSqlName('DTC') + " DTC "//Notas Fiscais
				cQuery +=  ", " + RetSqlName('SB1') + " SB1 "//Produtos
			EndIf
		EndIf
		cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
		If !lTMSDCol
			cQuery += " AND DUD_FILORI = '" + cFilAnt + "'"
		EndIf
		If !Empty(cSerAdi)
			cQuery += "AND DUD_SERTMS IN  ( '" + cSerTms + "', '" + cSerAdi + "' )"
		Else
			cQuery += "AND DUD_SERTMS     = '" + cSerTms + "'"
		EndIf
		cQuery += " AND DUD_TIPTRA = '" + cTipTra + "'"
		//-- Faz com que caso seja utilizado uma viagem TMSEXPRESS
		//-- os documentos que serão utilizados serão os que já foram
		//-- calculados para aquela viagem.
		If lVgeMod2 .And. lVgeExpr
			If(nCarreg == 1)//-- Caso seja uma viagem com carregamento manual.
				cQuery += " AND DUD_STATUS = '" + StrZero(1,Len(DUD->DUD_STATUS)) + "' "
			ElseIf(nCarreg == 2)//-- Caso seja uma viagem com carregamento automático.
				cQuery += " AND DUD_STATUS IN ('" + StrZero(1,Len(DUD->DUD_STATUS)) + "', '" + StrZero(3,Len(DUD->DUD_STATUS)) + "' )"
			EndIf
			cQuery += " AND DUD_VIAGEM = '" + M->DTQ_VIAGEM + "'"
		Else
			cQuery += " AND DUD_STATUS = '" + cStatus + "' "
			cQuery += " AND DUD_VIAGEM = '" + cViagem + "'"
		EndIf
		//-- Pesquisa rota por codigo de cliente
		If ( cSerTms == StrZero( 1, Len( DC5->DC5_SERTMS ) )  .Or. cSerTms == StrZero( 3, Len( DC5->DC5_SERTMS ) ) ).And. ;
			lPesqCCli // Se Coleta ou Entrega e Parametro MV_TMSPCLI esta ativo pesquisa codigo e cep de destino
			cQuery += " AND ( DUD_CEPENT BETWEEN DA7_CEPDE AND DA7_CEPATE "
			cQuery += " OR  DT6_CLIDES = DA7_CLIENT "
			cQuery += " AND DT6_LOJDES = DA7_LOJA  )"
		Else
			cQuery += " AND DUD_CEPENT BETWEEN DA7_CEPDE AND DA7_CEPATE "
		EndIf
		cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
		If !Empty(cFiltroDUD)
			cQuery += cFiltroDUD
		EndIf

		If nCarreg == 2
			cQuery += " AND DUD.DUD_NUMRED = ' ' "
		EndIf

		cQuery += " AND DT6_FILIAL = '" + xFilial("DT6") + "'"
		cQuery += " AND DT6_FILDOC = DUD_FILDOC "
		cQuery += " AND DT6_DOC    = DUD_DOC "
		cQuery += " AND DT6_SERIE  = DUD_SERIE "
		cQuery += " AND DT6_STATUS <> '7'" //-- Entregue
		cQuery += " AND DT6.D_E_L_E_T_ = ' ' "

		If lDTP
			cQuery += " AND ( DTP_LOTNFC = DT6_LOTNFC AND DTP_VIAGEM = '" +  M->DTQ_VIAGEM + "'"
			cQuery += " OR DUD_SERTMS = '1' ) "
		EndIf

		If lColeta
			If Empty(cFilDT5)
				cQuery += "   AND DT5_FILIAL = '" + xFilial("DT5") + "'"
			Else
				cQuery += "   AND DT5_FILIAL = DUD_FILDOC "
			EndIf
			cQuery += "   AND DT5_FILDOC     = DUD_FILDOC "
			cQuery += "   AND DT5_DOC        = DUD_DOC "
			cQuery += "   AND DT5_SERIE      = DUD_SERIE "
			cQuery += "   AND DT5.D_E_L_E_T_ = ' ' "
		EndIf
		If !Empty(cGrpProd) //-- Filtra Grupo de Produtos
			If lColeta
				cQuery += " AND DUM_FILIAL     = '" + xFilial("DUM") + "'"
				cQuery += " AND DUM_FILORI     = DT5_FILORI "
				cQuery += " AND DUM_NUMSOL     = DT5_NUMSOL"
				cQuery += " AND DUM.D_E_L_E_T_ = ' ' "
				cQuery += " AND B1_FILIAL  = '" + xFilial("SB1") + "'"
				cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
				cQuery += " AND B1_COD     = DUM_CODPRO "
				cQuery += " AND SB1.D_E_L_E_T_    = ' '"
			ElseIf !Empty(cSerAdi)
				cQuery += " AND B1_FILIAL   = '"+xFilial("SB1")+"'"
				cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
				cQuery += " AND B1_COD  = DTC_CODPRO"
				cQuery += " AND SB1.D_E_L_E_T_    = ' '"
			Else
				cQuery += " AND DTC_FILIAL    = '"+xFilial("DTC")+"'"
				cQuery += " AND DTC_FILDOC    = DT6.DT6_FILDOC"
				cQuery += " AND DTC_DOC       = DT6.DT6_DOC"
				cQuery += " AND DTC_SERIE     = DT6.DT6_SERIE"
				cQuery += " AND DTC_QTDVOL    > 0"
				cQuery += " AND DTC.D_E_L_E_T_    = ' '"
				cQuery += " AND B1_FILIAL   = '"+xFilial("SB1")+"'"
				cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
				cQuery += " AND B1_COD  = DTC_CODPRO"
				cQuery += " AND SB1.D_E_L_E_T_    = ' '"
			EndIf
		EndIf
		cQuery += " AND DA7_FILIAL = '" + xFilial("DA7") + "'"
		cQuery += " AND DA7.D_E_L_E_T_ = ' ' "
		cQuery += " AND DA6_FILIAL = '" + xFilial("DA6") + "'"
		cQuery += " AND DA6_PERCUR = DA7_PERCUR "
		cQuery += " AND DA6_ROTA   = DA7_ROTA "
		cQuery += " AND DA6.D_E_L_E_T_ = ' ' "
		If lAlianca
			cQuery += " AND DA6_ALIANC = ' ' "
		EndiF
		cQuery += " AND DA5_FILIAL = '" + xFilial("DA5") + "'"
		cQuery += " AND DA5_COD    = DA6_PERCUR "
		cQuery += " AND DA5.D_E_L_E_T_ = ' ' "
		cQuery += " AND DA9_FILIAL = '" + xFilial("DA9") + "'"
		cQuery += " AND DA9_PERCUR = DA7_PERCUR "
		cQuery += " AND DA9_ROTA   = DA7_ROTA   "
		If !Empty(cRotGen) .And. cRota <> cRotGen //Se tiver rota generica cadastrada precisa filtrar para mostrar apenas no botao de documentos com rota generica
			cQuery += " AND DA9_ROTEIR <> '" + cRotGen + "'"
		EndIf
		If !Empty(cRota)
			cQuery += " AND DA9_ROTEIR = '" + cRota + "'"
		EndIf
		cQuery += " AND DA9.D_E_L_E_T_ = ' ' "
		cQuery += " AND DA8_FILIAL = '" + xFilial("DA8") + "'"
		cQuery += " AND DA8_COD    = DA9_ROTEIR "
		cQuery += " AND DA8_SERTMS = '" + cSerTms + "'"
		cQuery += " AND DA8_TIPTRA = '" + cTipTra + "'"
		If lCdrOri
			cQuery += " AND DA8_CDRORI = '" + _cCdrOri + "'"
		EndIf
		cQuery += " AND DA8_ATIVO      = '1' "
		cQuery += " AND DA8.D_E_L_E_T_ = ' ' "
		If Empty(cRota)
			cQuery += " GROUP BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE, DA8_COD, DA5_COD, DA6_ROTA, DA7_PERCUR, DA7_ROTA, DA9_PERCUR, DA9_ROTA ) QUERY "
			cQuery += " GROUP BY DA8_COD, DA5_COD, DA6_ROTA "
		Else
			cQuery += " GROUP BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE"
		EndIf

		If lAlianca
			cQuery += " UNION ALL " //Alianca
			If lOrderBy
				If Empty(cRota)
					cQuery += " SELECT "
					cQuery += " DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(TIPROT) TIPROT, "
					cQuery += " DA5_COD, MIN(DA5_DESC) DA5_DESC, DA6_ROTA, MIN(DA6_REF) DA6_REF , "
					cQuery += " MIN(DUD_STATUS) DUD_STATUS, SUM(DT6_QTDVOL) DT6_QTDVOL, SUM(DT6_PESO)   DT6_PESO  , SUM(DT6_VOLORI) DT6_VOLORI, "
					cQuery += " SUM(DT6_PESOM3) DT6_PESOM3, SUM(DT6_VALMER) DT6_VALMER, MIN(DUD_SERTMS) DUD_SERTMS," + cQueryTp + " 'O' CVISUAL "
					cQuery += "  FROM ( "
					cQuery += " SELECT "
					cQuery += "	DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(DA8_TIPROT) TIPROT, DA5_COD, "
					cQuery += "	MIN(DA5_DESC) DA5_DESC , DA6_ROTA, MIN(DA6_REF) DA6_REF , MIN(DUD_STATUS) DUD_STATUS, "
					cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3)  DT6_PESOM3   , MIN(DT6_VOLORI)  DT6_VOLORI, "
					cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DUD_SERTMS) DUD_SERTMS, DUD_FILDOC, DUD_DOC, DUD_SERIE, " + cQueryTp + " 'O' CVISUAL "
				Else
					If lColeta
						cQuery += " SELECT "
						cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, MIN(DUD_SERTMS) DUD_SERTMS, "
						cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DUD_SEQUEN) DUD_SEQUEN, "
						cQuery += " MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DT6_DATEMI) DT6_DATEMI, MIN(DT6_PRZENT) DT6_PRZENT, "
						cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, "
						cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DT5_SEQEND) DT5_SEQEND, MIN(DT5_DATSOL) DT5_DATSOL, "
						cQuery += " MIN(DT5_HORSOL) DT5_HORSOL, MIN(DT5_DATPRV) DT5_DATPRV, MIN(DT5_HORPRV) DT5_HORPRV, "
						cQuery += " MIN(DT5_CODSOL) DT5_CODSOL, "
						cQuery += " MIN(DT5_DDD)    DT5_DDD   , MIN(DT5_TEL)    DT5_TEL   , MIN(DT6_VOLORI) DT6_VOLORI, "
						If nOpcx == 2
							cQuery += " MIN(DUD_ZONA) DA7_PERCUR, "
						Else
							cQuery += " MIN(DA6_PERCUR) DA7_PERCUR, "
						EndIf
						cQuery += cQueryTp + " '' DA7_SEQUEN, MIN(DA6_ROTA)   DA7_ROTA    "
						If !lVgeMod2 .And. lTmsCFec
							//-- Retorna os campos referente ao Agendamento.
							cQuery += ", MIN(DF1_ITEAGE) DF1_ITEAGE "
							cQuery += ", MIN(DF1_NUMAGE) DF1_NUMAGE "
							cQuery += ", MIN(DT5_CLIDES) DT5_CLIDES "
							cQuery += ", MIN(DT5_LOJDES) DT5_LOJDES "
							cQuery += ", MIN(DT5_DATENT) DT5_DATENT "
							cQuery += ", MIN(DT5_HORENT) DT5_HORENT "
							cQuery += ", MIN(DUD_SEQENT) DUD_SEQENT "
						EndIf
					Else
						cQuery += " SELECT "
						cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, MIN(DUD_SERTMS) DUD_SERTMS, "
						cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DUD_SEQUEN) DUD_SEQUEN, "
						cQuery += " MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DT6_DATEMI) DT6_DATEMI, MIN(DT6_PRZENT) DT6_PRZENT, "
						cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, "
						cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DT6_CLIREM) DT6_CLIREM, MIN(DT6_LOJREM) DT6_LOJREM, "
						cQuery += " MIN(DT6_CLIDES) DT6_CLIDES, MIN(DT6_LOJDES) DT6_LOJDES, "
						If nOpcx == 2
							cQuery += " MIN(DUD_ZONA) DA7_PERCUR, "
						Else
							cQuery += " MIN(DA6_PERCUR) DA7_PERCUR, "
						EndIf
						cQuery += cQueryTp //-- Usado em query BD POSTGRES
						cQuery += " ''              DA7_SEQUEN, MIN(DA6_ROTA)   DA7_ROTA  , MIN(DT6_VOLORI) DT6_VOLORI  "
					EndIf
				EndIf
			Else
				cQuery += " SELECT "
				cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, DUD.R_E_C_N_O_ DUDRECNO "
			EndIf
			cQuery += " FROM "
			If lColeta .And. !lVgeMod2 .And. lTmsCFec .And. !Empty(cRota)
				//-- Verifica se existe Agendamento associado a Solicitacao de Coleta.
				cQuery +=   RetSqlName('DUD') + " DUD "//Movimento de Viagem
				cQuery += "LEFT JOIN " + RetSqlName('DF1') + " DF1 "
				cQuery += "  ON DF1_FILIAL = '" + xFilial("DF1") + "'"
				cQuery += " AND DF1_FILDOC = DUD_FILDOC"
				cQuery += " AND DF1_DOC = DUD_DOC"
				cQuery += " AND DF1_SERIE = DUD_SERIE"
				cQuery += " AND DF1.D_E_L_E_T_ = ' ', "
			Else
				cQuery +=   RetSqlName('DUD') + " DUD, "//Movimento de Viagem
			EndIf
			cQuery +=  RetSqlName('DA8') + " DA8, " // Rotas
			cQuery +=  RetSqlName('DA9') + " DA9, "//Documentos de transporte
			cQuery +=  RetSqlName('DT6') + " DT6, "//Documentos de transporte
			cQuery +=  RetSqlName('DA5') + " DA5, "//Zonas
			cQuery +=  RetSqlName('DA6') + " DA6  " //Setor x Zonas
			If lColeta
				cQuery +=   ", " + RetSqlName('DT5') + " DT5 "//Solicitacao de coleta
			EndIf
			If !Empty(cGrpProd) //-- Filtra por Grupo de Produtos
				If lColeta
					cQuery += ", " + RetSqlName('SB1') + " SB1  "//Produtos
					cQuery += ", " + RetSqlName('DUM') + " DUM "//Itens da Solicitacao de Coleta
				Else
					cQuery +=  ", " + RetSqlName('DTC') + " DTC "//Notas Fiscais
					cQuery +=  ", " + RetSqlName('SB1') + " SB1 "//Produtos
				EndIf
			EndIf
			cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
			If !lTMSDCol
				cQuery += " AND DUD_FILORI = '" + cFilAnt + "'"
			EndIf
			cQuery += " AND DUD_SERTMS = '" + cSerTms + "'"
			cQuery += " AND DUD_TIPTRA = '" + cTipTra + "'"
			cQuery += " AND DUD_STATUS = '" + cStatus + "' "
			cQuery += " AND DUD_VIAGEM = '" + cViagem + "'"
			cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
			If !Empty(cFiltroDUD)
				cQuery += cFiltroDUD
			EndIf
			cQuery += " AND DT6_FILIAL = '" + xFilial("DT6") + "'"
			cQuery += " AND DT6_FILDOC = DUD_FILDOC "
			cQuery += " AND DT6_DOC    = DUD_DOC "
			cQuery += " AND DT6_SERIE  = DUD_SERIE "
			cQuery += " AND DT6_ALIANC = DA6_ALIANC "
			cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
			If lColeta
				If Empty(cFilDT5)
					cQuery += " AND DT5_FILIAL = '" + xFilial("DT5") + "'"
				Else
					cQuery += " AND DT5_FILIAL = DUD_FILDOC "
				EndIf
				cQuery += "   AND DT5_FILDOC     = DUD_FILDOC "
				cQuery += "   AND DT5_DOC        = DUD_DOC "
				cQuery += "   AND DT5_SERIE      = DUD_SERIE "
				cQuery += "   AND DT5.D_E_L_E_T_ = ' ' "
			EndIf
			If !Empty(cGrpProd) //-- Filtra Grupo de Produtos
				If lColeta
					cQuery += " AND DUM_FILIAL     = '" + xFilial("DUM") + "'"
					cQuery += " AND DUM_FILORI     = DT5_FILORI "
					cQuery += " AND DUM_NUMSOL     = DT5_NUMSOL"
					cQuery += " AND DUM.D_E_L_E_T_ = ' ' "
					cQuery += " AND B1_FILIAL  = '" + xFilial("SB1") + "'"
					cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
					cQuery += " AND B1_COD     = DUM_CODPRO "
					cQuery += " AND SB1.D_E_L_E_T_    = ' '"
				Else
					cQuery += " AND DTC_FILIAL     = '"+xFilial("DTC")+"'"
					cQuery += " AND DTC_FILDOC    = DT6.DT6_FILDOC"
					cQuery += " AND DTC_DOC       = DT6.DT6_DOC"
					cQuery += " AND DTC_SERIE     = DT6.DT6_SERIE"
					cQuery += " AND DTC_QTDVOL    > 0"
					cQuery += " AND DTC.D_E_L_E_T_    = ' '"
					cQuery += " AND B1_FILIAL   = '"+xFilial("SB1")+"'"
					cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
					cQuery += " AND B1_COD  = DTC_CODPRO"
					cQuery += " AND SB1.D_E_L_E_T_    = ' '"
				EndIf
			EndIf
			cQuery += " AND DA6_FILIAL = '" + xFilial("DA6") + "'"
			cQuery += " AND DA6_ALIANC <> '  ' "
			cQuery += " AND DA6.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA5_FILIAL = '" + xFilial("DA5") + "'"
			cQuery += " AND DA5_COD    = DA6_PERCUR "
			cQuery += " AND DA5.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA8_FILIAL = '" + xFilial("DA8") + "'"
			If !Empty(cRotGen)//Se tiver rota generica cadastrada precisa filtrar para mostrar apenas no botao de rota generica
				cQuery += " AND DA8_COD <> '" + cRotGen + "'"
			EndIf
			If !Empty(cRota)
				cQuery += " AND DA8_COD = '" + cRota + "'"
			EndIf
			cQuery += " AND DA8_SERTMS = '" + cSerTms + "'"
			cQuery += " AND DA8_TIPTRA = '" + cTipTra + "'"
			If lCdrOri
				cQuery += " AND DA8_CDRORI = '" + _cCdrOri + "'"
			EndIf
			cQuery += " AND DA8_ATIVO      = '1' "
			cQuery += " AND DA8.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA9_FILIAL     = '" + xFilial("DA9") + "'"
			cQuery += " AND DA9_ROTEIR     = DA8_COD "
			cQuery += " AND DA9_PERCUR     = DA5_COD "
			cQuery += " AND DA9_ROTA       = DA6_PERCUR "
			cQuery += " AND DA9.D_E_L_E_T_ = ' ' "
			If Empty(cRota)
				cQuery += " GROUP BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE, DA8_COD, DA5_COD, DA6_ROTA ) QUERY "
				cQuery += " GROUP BY DA8_COD, DA5_COD, DA6_ROTA"
			Else
				cQuery += " GROUP BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE"
			EndIf
		EndIf

		//-- Rota generica de entrega
		If	!lVgeExpr .And. nRotGen == 1 .And. !Empty(cRotGen) .And. ( Empty(cRota) .Or. ( !Empty(cRota) .And. cRotGen == cRota ))
			cQuery += " UNION ALL"
			If lOrderBy
				If Empty(cRota)
					cQuery += " SELECT "
					cQuery += " DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(TIPROT) TIPROT, "
					cQuery += " DA5_COD, MIN(DA5_DESC) DA5_DESC, DA6_ROTA, MIN(DA6_REF) DA6_REF , "
					cQuery += " MIN(DUD_STATUS) DUD_STATUS, SUM(DT6_QTDVOL) DT6_QTDVOL, SUM(DT6_PESO)   DT6_PESO  , SUM(DT6_VOLORI) DT6_VOLORI, "
					cQuery += " SUM(DT6_PESOM3) DT6_PESOM3, SUM(DT6_VALMER) DT6_VALMER, MIN(DUD_SERTMS) DUD_SERTMS," + cQueryTp + " 'O' CVISUAL "
					cQuery += "  FROM ( "
					cQuery += " SELECT "
					cQuery += " DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(DA8_TIPROT) TIPROT, DA5_COD, "
					cQuery += " MIN(DA5_DESC) DA5_DESC, DA6_ROTA, MIN(DA6_REF) DA6_REF, "
					cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , SUM(DT6_VOLORI)  DT6_VOLORI   , "
					cQuery += " MIN(DT6_PESOM3) DT6_PESOM3, MIN(DT6_VALMER) DT6_VALMER, MIN(DUD_SERTMS) DUD_SERTMS, DUD_FILDOC, DUD_DOC, DUD_SERIE, "
					cQuery += cQueryTp + " 'O' CVISUAL"
				Else
					If lColeta
						cQuery += " SELECT "
						cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, MIN(DUD_SERTMS) DUD_SERTMS, "
						cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DUD_SEQUEN) DUD_SEQUEN, "
						cQuery += " MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DT6_DATEMI) DT6_DATEMI, MIN(DT6_PRZENT) DT6_PRZENT, "
						cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, "
						cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DT5_SEQEND) DT5_SEQEND, MIN(DT5_DATSOL) DT5_DATSOL, "
						cQuery += " MIN(DT5_HORSOL) DT5_HORSOL, MIN(DT5_DATPRV) DT5_DATPRV, MIN(DT5_HORPRV) DT5_HORPRV, "
						cQuery += " MIN(DT5_CODSOL) DT5_CODSOL, "
						cQuery += " MIN(DT5_DDD)    DT5_DDD   , MIN(DT5_TEL)    DT5_TEL   , MIN(DT6_VOLORI) DT6_VOLORI, "
						If nOpcx == 2
							cQuery += " MIN(DUD_ZONA) DA7_PERCUR, "
						Else
							cQuery += " MIN(DA6_PERCUR) DA7_PERCUR, "
						EndIf

						cQuery += cQueryTp+" '' DA7_SEQUEN, MIN(DA6_ROTA)   DA7_ROTA   "
						If !lVgeMod2 .And. lTmsCFec
							//-- Retorna os campos referente ao Agendamento.
							cQuery += ", MIN(DF1_ITEAGE) DF1_ITEAGE "
							cQuery += ", MIN(DF1_NUMAGE) DF1_NUMAGE "
							cQuery += ", MIN(DT5_CLIDES) DT5_CLIDES "
							cQuery += ", MIN(DT5_LOJDES) DT5_LOJDES "
							cQuery += ", MIN(DT5_DATENT) DT5_DATENT "
							cQuery += ", MIN(DT5_HORENT) DT5_HORENT "
							cQuery += ", MIN(DUD_SEQENT) DUD_SEQENT "
						EndIf
					Else
						cQuery += " SELECT "
						cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, MIN(DUD_SERTMS) DUD_SERTMS, "
						cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DUD_SEQUEN) DUD_SEQUEN, "
						cQuery += " MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DT6_DATEMI) DT6_DATEMI, MIN(DT6_PRZENT) DT6_PRZENT, "
						cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, "
						cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DT6_CLIREM) DT6_CLIREM, MIN(DT6_LOJREM) DT6_LOJREM, "
						cQuery += " MIN(DT6_CLIDES) DT6_CLIDES, MIN(DT6_LOJDES) DT6_LOJDES, "
						If nOpcx == 2
							cQuery += " MIN(DUD_ZONA) DA7_PERCUR, "
						Else
							cQuery += " MIN(DA6_PERCUR) DA7_PERCUR, "
						EndIf
						cQuery += cQueryTp //-- Usado em query BD POSTGRES
						cQuery += " ''              DA7_SEQUEN, MIN(DA6_ROTA)  DA7_ROTA   , MIN(DT6_VOLORI) DT6_VOLORI  "
					EndIf
				EndIf
			Else
				cQuery += " SELECT "
				cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, DUD.R_E_C_N_O_ DUDRECNO "
			EndIf
			cQuery += " FROM "
			If lColeta .And. !lVgeMod2 .And. lTmsCFec .And. !Empty(cRota)
				//-- Verifica se existe Agendamento associado a Solicitacao de Coleta.
				cQuery +=   RetSqlName('DUD') + " DUD "//Movimento de Viagem
				cQuery += "LEFT JOIN " + RetSqlName('DF1') + " DF1 ON"
				cQuery += " DF1_FILIAL = '" + xFilial("DF1") + "'"
				cQuery += " AND DF1_FILDOC = DUD_FILDOC"
				cQuery += " AND DF1_DOC = DUD_DOC"
				cQuery += " AND DF1_SERIE = DUD_SERIE"
				cQuery += " AND DF1.D_E_L_E_T_ = ' ', "
			Else
				cQuery +=   RetSqlName('DUD') + " DUD, "//Movimento de Viagem
			EndIf
			cQuery += RetSqlName('DT6') + " DT6, "
			cQuery += RetSqlName('DA8') + " DA8, "
			cQuery += RetSqlName('DA9') + " DA9, "
			cQuery += RetSqlName('DA5') + " DA5, "
			cQuery += RetSqlName('DA6') + " DA6 "
			If lColeta
				cQuery +=   ", " + RetSqlName('DT5') + " DT5 "//Solicitacao de coleta
			EndIf
			If !Empty(cGrpProd) //-- Filtra por Grupo de Produtos
				If lColeta
					cQuery += ", " + RetSqlName('SB1') + " SB1  "//Produtos
					cQuery += ", " + RetSqlName('DUM') + " DUM "//Itens da Solicitacao de Coleta
				Else
					cQuery +=  ", " + RetSqlName('DTC') + " DTC "//Notas Fiscais
					cQuery +=  ", " + RetSqlName('SB1') + " SB1 "//Produtos
				EndIf
			EndIf
			cQuery += " WHERE DUD_FILIAL   = '" + xFilial("DUD") + "'"
			If !lTMSDCol
				cQuery += " AND DUD_FILORI     = '" + cFilAnt + "'"
			EndIf
			cQuery += " AND DUD_SERTMS     = '" + cSerTms + "'"
			cQuery += " AND DUD_TIPTRA     = '" + cTipTra + "'"
			cQuery += " AND DUD_STATUS     = '" + cStatus + "'"
			cQuery += " AND DUD_VIAGEM     = '" + cViagem + "'"
			cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
			If !Empty(cFiltroDUD)
				cQuery += cFiltroDUD
			EndIf
			cQuery += " AND DT6_FILIAL     = '" + xFilial("DT6") + "'"
			cQuery += " AND DT6_FILDOC     = DUD_FILDOC "
			cQuery += " AND DT6_DOC        = DUD_DOC "
			cQuery += " AND DT6_SERIE      = DUD_SERIE "
			cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
			If lColeta
				If Empty(cFilDT5)
					cQuery += "   AND DT5_FILIAL = '" + xFilial("DT5") + "'"
				Else
					cQuery += "   AND DT5_FILIAL = DUD_FILDOC "
				EndIf
				cQuery += "   AND DT5_FILDOC     = DUD_FILDOC "
				cQuery += "   AND DT5_DOC        = DUD_DOC "
				cQuery += "   AND DT5_SERIE      = DUD_SERIE "
				cQuery += "   AND DT5.D_E_L_E_T_ = ' ' "
			EndIf
			If !Empty(cGrpProd) //-- Filtra Grupo de Produtos
				If lColeta
					cQuery += " AND DUM_FILIAL     = '" + xFilial("DUM") + "'"
					cQuery += " AND DUM_FILORI     = DT5_FILORI "
					cQuery += " AND DUM_NUMSOL     = DT5_NUMSOL"
					cQuery += " AND DUM.D_E_L_E_T_ = ' ' "
					cQuery += " AND B1_FILIAL  = '" + xFilial("SB1") + "'"
					cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
					cQuery += " AND B1_COD     = DUM_CODPRO "
					cQuery += " AND SB1.D_E_L_E_T_    = ' '"
				Else
					cQuery += " AND DTC_FILIAL     = '"+xFilial("DTC")+"'"
					cQuery += " AND DTC_FILDOC    = DT6.DT6_FILDOC"
					cQuery += " AND DTC_DOC       = DT6.DT6_DOC"
					cQuery += " AND DTC_SERIE     = DT6.DT6_SERIE"
					cQuery += " AND DTC_QTDVOL    > 0"
					cQuery += " AND DTC.D_E_L_E_T_    = ' '"
					cQuery += " AND B1_FILIAL   = '"+xFilial("SB1")+"'"
					cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
					cQuery += " AND B1_COD  = DTC_CODPRO"
					cQuery += " AND SB1.D_E_L_E_T_    = ' '"
				EndIf
			EndIf
			cQuery += " AND DA8_FILIAL     = '" + xFilial("DA8") + "'"
			cQuery += " AND DA8_SERTMS     = '" + cSerTms + "'"
			cQuery += " AND DA8_TIPTRA     = '" + cTipTra + "'"
			cQuery += " AND DA8_COD        = '" + cRotGen + "'"
			If lCdrOri
				cQuery += " AND DA8_CDRORI     = '" + _cCdrOri + "'"
			EndIf
			cQuery += " AND DA8_ATIVO      = '1' "
			cQuery += " AND DA8.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA9_FILIAL     = '" + xFilial("DA9") + "'"
			cQuery += " AND DA9_ROTEIR     = DA8_COD "
			cQuery += " AND DA9.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA5_FILIAL     = '" + xFilial("DA5") + "'"
			cQuery += " AND DA5_COD        = DA9_PERCUR "
			cQuery += " AND DA5.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA6_FILIAL     = '" + xFilial("DA6") + "'"
			cQuery += " AND DA6_PERCUR     = DA9_PERCUR "
			cQuery += " AND DA6_ROTA       = DA9_ROTA "
			If lAlianca
				cQuery += " AND DA6_ALIANC = ' ' "
			EndIf
			cQuery += " AND DA6.D_E_L_E_T_ = ' ' "
			cQuery += " AND NOT EXISTS ( "
			cQuery += " SELECT 1 "
			cQuery += " FROM "
			cQuery += RetSqlName('DUD') + " DUD, "
			cQuery += RetSqlName('DT6') + " DT61, "
			cQuery += RetSqlName('DA8') + " DA8, "
			cQuery += RetSqlName('DA9') + " DA9, "
			cQuery += RetSqlName('DA6') + " DA6, "
			cQuery += RetSqlName('DA7') + " DA7 "
			If lColeta
				cQuery +=   ", " + RetSqlName('DT5') + " DT5 "//Solicitacao de coleta
			EndIf
			If !Empty(cGrpProd) //-- Filtra por Grupo de Produtos
				If lColeta
					cQuery += ", " + RetSqlName('SB1') + " SB1  "//Produtos
					cQuery += ", " + RetSqlName('DUM') + " DUM "//Itens da Solicitacao de Coleta
				Else
					cQuery +=  ", " + RetSqlName('DTC') + " DTC "//Notas Fiscais
					cQuery +=  ", " + RetSqlName('SB1') + " SB1 "//Produtos
				EndIf
			EndIf
			cQuery += " WHERE "
			cQuery += " DUD_FILIAL         = '" + xFilial("DUD") + "'"
			cQuery += " AND DUD_FILDOC     = DT6.DT6_FILDOC "
			cQuery += " AND DUD_DOC        = DT6.DT6_DOC    "
			cQuery += " AND DUD_SERIE      = DT6.DT6_SERIE  "
			If !lTMSDCol
				cQuery += " AND DUD_FILORI     = '" + cFilAnt + "'"
			EndIf
			cQuery += " AND DUD_SERTMS     = '" + cSerTms + "'"
			cQuery += " AND DUD_TIPTRA     = '" + cTipTra + "'"
			cQuery += " AND DUD_STATUS     = '" + cStatus + "'"
			cQuery += " AND DUD_VIAGEM     = '" + cViagem + "'"
			cQuery += " AND DUD_CEPENT BETWEEN DA7_CEPDE AND DA7_CEPATE "
			cQuery += " AND DUD.D_E_L_E_T_  = ' ' "
			cQuery += " AND DT61.DT6_FILIAL = '" + xFilial("DT6") + "'"
			cQuery += " AND DT61.DT6_FILDOC = DUD_FILDOC "
			cQuery += " AND DT61.DT6_DOC    = DUD_DOC "
			cQuery += " AND DT61.DT6_SERIE  = DUD_SERIE "
			cQuery += " AND DT61.D_E_L_E_T_ = ' ' "
			If lColeta
				If Empty(cFilDT5)
					cQuery += "   AND DT5_FILIAL = '" + xFilial("DT5") + "'"
				Else
					cQuery += "   AND DT5_FILIAL = DUD_FILDOC "
				EndIf
				cQuery += "   AND DT5_FILDOC     = DUD_FILDOC "
				cQuery += "   AND DT5_DOC        = DUD_DOC "
				cQuery += "   AND DT5_SERIE      = DUD_SERIE "
				cQuery += "   AND DT5.D_E_L_E_T_ = ' ' "
			EndIf
			If !Empty(cGrpProd) //-- Filtra Grupo de Produtos
				If lColeta
					cQuery += " AND DUM_FILIAL     = '" + xFilial("DUM") + "'"
					cQuery += " AND DUM_FILORI     = DT5_FILORI "
					cQuery += " AND DUM_NUMSOL     = DT5_NUMSOL"
					cQuery += " AND DUM.D_E_L_E_T_ = ' ' "
					cQuery += " AND B1_FILIAL  = '" + xFilial("SB1") + "'"
					cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
					cQuery += " AND B1_COD     = DUM_CODPRO "
					cQuery += " AND SB1.D_E_L_E_T_    = ' '"
				Else
					cQuery += " AND DTC_FILIAL     = '"+xFilial("DTC")+"'"
					cQuery += " AND DTC_FILDOC    = DT61.DT6_FILDOC"
					cQuery += " AND DTC_DOC       = DT61.DT6_DOC"
					cQuery += " AND DTC_SERIE     = DT61.DT6_SERIE"
					cQuery += " AND DTC_QTDVOL    > 0"
					cQuery += " AND DTC.D_E_L_E_T_    = ' '"
					cQuery += " AND B1_FILIAL   = '"+xFilial("SB1")+"'"
					cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
					cQuery += " AND B1_COD  = DTC_CODPRO"
					cQuery += " AND SB1.D_E_L_E_T_    = ' '"
				EndIf
			EndIf
			cQuery += " AND DA8_FILIAL     = '" + xFilial("DA8") + "'"
			cQuery += " AND DA8_SERTMS     = '" + cSerTms + "'"
			cQuery += " AND DA8_TIPTRA     = '" + cTipTra + "'"
			cQuery += " AND DA8_COD       <> '" + cRotGen + "'"
			If lCdrOri
				cQuery += " AND DA8_CDRORI     = '" + _cCdrOri + "'"
			EndIf
			cQuery += " AND DA8_ATIVO      = '1' "
			cQuery += " AND DA8.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA9_FILIAL     = '" + xFilial("DA9") + "'"
			cQuery += " AND DA9_ROTEIR     = DA8_COD "
			cQuery += " AND DA9.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA6_FILIAL     = '" + xFilial("DA6") + "'"
			cQuery += " AND DA6_PERCUR     = DA9_PERCUR "
			cQuery += " AND DA6_ROTA       = DA9_ROTA "
			If lAlianca
				cQuery += " AND DA6_ALIANC = ' ' "
			EndIf
			cQuery += " AND DA6.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA7_FILIAL     = '" + xFilial("DA7") + "'"
			cQuery += " AND DA7_PERCUR     = DA9_PERCUR "
			cQuery += " AND DA7_ROTA       = DA9_ROTA "
			cQuery += " AND DA7.D_E_L_E_T_ = ' ' )"
			If Empty(cRota)
				cQuery += " GROUP BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE, DA8_COD, DA5_COD, DA6_ROTA ) QUERY "
				cQuery += " GROUP BY DA8_COD, DA5_COD, DA6_ROTA "
			Else
				cQuery += " GROUP BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE"
			EndIf
		EndIf
	EndIf
	If !Empty(cRota) .And. lOrderBy
		cQuery += " ORDER BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE "
	EndIf
	cQuery := ChangeQuery(cQuery)
EndIf

Return( cQuery )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TM141QryVz ³ Autor ³ Eduardo de Souza     ³ Data ³ 18/11/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Query da viagem de entrega vazia (Rota / Documento).       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TM141QryVz(ExpN1,ExpC1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±³          ³ ExpC1 - Rota                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA141                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM141QryVz(nOpcx,cRota)
Local cQuery   := ""
Local cQueryTp := If("POSTGRES"$TCGetDb(),"Char(1)","") //-- Usado em query BD POSTGRES

If Empty(cRota)
	cQuery := " SELECT DA8_COD, DA8_DESC, DA8_TIPROT TIPROT, "
	cQuery += cQueryTp + " ' ' DA5_COD,    "
	cQuery += cQueryTp + " ' ' DA5_DESC,   "
	cQuery += cQueryTp + " ' ' DA6_ROTA,   "
	cQuery += cQueryTp + " ' ' DA6_REF,    "
	cQuery += cQueryTp + " ' ' DUD_STATUS ,"
	cQuery += cQueryTp + " ' ' DUD_SERTMS ,"
	cQuery += " 0 DT6_QTDVOL, 0 DT6_PESO  ,"
	cQuery += " 0 DT6_PESOM3, 0 DT6_VALMER,"
	cQuery += cQueryTp + " 'O' CVISUAL "
	cQuery += " FROM " + RetSQLName("DA8") + " DA8 "
	cQuery += " WHERE DA8_FILIAL = '" + xFilial("DA8") + "'"
	cQuery += " AND DA8_SERTMS = '" + cSerTms + "'"
	cQuery += " AND DA8_TIPTRA = '" + cTipTra + "'"
	cQuery += " AND DA8_ATIVO  = '1' "
	cQuery += " AND DA8.D_E_L_E_T_ = ' ' "
Else
	cQuery += " SELECT "
	cQuery += cQueryTp + " ' ' DUD_FILDOC, "
	cQuery += cQueryTp + " ' ' DUD_DOC   , "
	cQuery += cQueryTp + " ' ' DUD_SERIE , "
	cQuery += cQueryTp + " ' ' DUD_STATUS, "
	cQuery += cQueryTp + " ' ' DUD_SERTMS, "
	cQuery += cQueryTp + " ' ' DUD_VIAGEM, "
	cQuery += cQueryTp + " ' ' DUD_SEQUEN, "
	cQuery += cQueryTp + " ' ' DT6_BLQDOC, "
	cQuery += cQueryTp + " ' ' DT6_DATEMI, "
	cQuery += cQueryTp + " ' ' DT6_PRZENT, "
	cQuery += " 0 DT6_QTDVOL, 0 DT6_PESO,  "
	cQuery += " 0 DT6_PESOM3, 0 DT6_VALMER,"
	cQuery += cQueryTp + " ' ' DT6_CLIREM, "
	cQuery += cQueryTp + " ' ' DT6_LOJREM, "
	cQuery += cQueryTp + " ' ' DT6_CLIDES, "
	cQuery += cQueryTp + " ' ' DT6_LOJDES, "
	cQuery += cQueryTp + " ' ' DA7_PERCUR, "
	cQuery += cQueryTp + " ' ' DA7_SEQUEN, "
	cQuery += " DA8_COD DA7_ROTA, 0 DT6_VOLORI "
	cQuery += " FROM " + RetSQLName("DA8") + " DA8 "
	cQuery += " WHERE DA8_FILIAL = '" + xFilial("DA8") + "'"
	cQuery += " AND DA8_COD    = '" + cRota + "' "
	cQuery += " AND DA8.D_E_L_E_T_ = ' ' "
EndIf
cQuery := ChangeQuery(cQuery)
Return(cQuery)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA141Rdp ³ Autor ³ Vitor Raspa          ³ Data ³ 16/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao dos campos do Rodape da tela de Viagem         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA141Rdp()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA141                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA141Rdp()
Local nAux

nVolumes := 0
nPesReal := 0
nPesCub  := 0
nValMerc := 0
nDoctos  := 0

If Len(aDocto) > 0
	For nAux := 1 To Len(aDocto)
		If aDocto[nAux,CTMARCA]
			//Quando for Coleta e Carga Fechada precisa validar o servico pois temos dois itens no aDocto.
			//Um item de coleta e outro de entrega, sem este tratamento o valor do Rodape ficaria duplicado
			//Quando nao e Carga Fechada ou nao for Coleta nao precisa tratar o servico pois temos apenas um item
			If (lColeta .And. lTmscFec .And. aDocto[nAux,CTSERTMS] ==  '1') .Or. (lColeta .And. !lTmscFec) .Or. (!lColeta)
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
±±³Fun‡„o    ³TMSA141Red³ Autor ³ Andre Godoi           ³ Data ³11.05.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o Doc e' de Redespacho e Status = Entregue     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial do Documento			                      ³±±
±±³          ³ ExpC2 = Documento										  ³±±
±±³          ³ ExpC3 = Serie do Documento  								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA141Red(cFilDoc,cDoc,cSerie)
Local lRet      := .F.
Local cAliasQry := ''
Local cQuery    := ''
Local aAreaDFV  := GetArea()

cAliasQry := GetNextAlias()
cQuery := " SELECT 1"
cQuery += " FROM " + RetSqlName("DFV")
cQuery += " WHERE DFV_FILIAL ='" + xFilial("DFV") + "'"
cQuery += "   AND DFV_FILDOC ='" + cFilDoc + "'"
cQuery += "   AND DFV_DOC    ='" + cDoc + "'"
cQuery += "   AND DFV_SERIE  ='" + cSerie + "'"
cQuery += "   AND DFV_STATUS ='" + StrZero(3, Len(DFV->DFV_STATUS))+ "'"
cQuery += "   AND D_E_L_E_T_<>'*'"

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

If (cAliasQry)->(!Eof())
	lRet := .T.
EndIf
(cAliasQry)->(DbCloseArea())

RestArea(aAreaDFV)
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA141Agd³ Autor ³ Marcelo Coutinho      ³ Data ³09.11.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acrescenta dados do Agendamento de Entrega ao aDocto       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Operação a ser realizada (Inclusão/Alteração)      ³±±
±±³          ³ ExpA1 = Matriz a ser processada  		                    ³±±
±±³          ³ ExpN1 = Linha para processamento							        ³±±
±±³          ³ ExpC2 = Expressão para pesquisa							        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA141Agd(aXMtrz,cXSeek)

Local lRet       := .F.
Local aAreaAGD   := GetArea()
Local cRetPri    := ''
Local cCorPri    := ''
Local cAliasPri  := GetNextAlias()
Local cNumAgd    := ''
Local cIteAgd    := ''
Local aRetPrd   := RetSx3Box( Posicione('SX3', 2, 'DYD_PRDAGD', 'X3CBox()' ),,, Len(DYD->DYD_PRDAGD))
Local aRetTipo  := RetSx3Box( Posicione('SX3', 2, 'DYD_TIPAGD', 'X3CBox()' ),,, Len(DYD->DYD_TIPAGD))
Local aRetCor   := RetSx3Box( Posicione('SX3', 2, 'DYK_CORPRI', 'X3CBox()' ),,, Len(DYK->DYK_CORPRI))

If Type("aRetPrior") == "U"
	aRetPrior := {}
EndIf

If Empty(aRetPrior)
	cQuery := "SELECT DYK_CODPRI, DYK_TIPPRI, DYK_DEPRI, DYK_ATEPRI, DYK_CORPRI "
	cQuery += "     FROM "
	cQuery += RetSqlName("DYK") + " DYK "
	cQuery += "    WHERE DYK_FILIAL  = '"+xFilial('DYK')+"'"
	If !aXMtrz[CTMARCA]
		cQuery += "   AND DYK_CODPRI >= '" + mv_par09 + "'"
		cQuery += "   AND DYK_CODPRI <= '" + mv_par10 + "'"
	EndIf
	cQuery += "      AND D_E_L_E_T_  = ' '"
	cQuery += "    ORDER BY DYK_TIPPRI, DYK_ATEPRI DESC"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasPri,.T.,.T.)

	While (cAliasPri)->(!Eof())

		AAdd(aRetPrior,Array(PE_QTDCOL))

		nI := Len(aRetPrior)

		aRetPrior[nI,PE_CODPRI] := (cAliasPri)->DYK_CODPRI
		aRetPrior[nI,PE_TIPPRI] := (cAliasPri)->DYK_TIPPRI
		aRetPrior[nI,PE_DEPRI ] := (cAliasPri)->DYK_DEPRI
		aRetPrior[nI,PE_ATEPRI] := (cAliasPri)->DYK_ATEPRI
		aRetPrior[nI,PE_CORPRI] := (cAliasPri)->DYK_CORPRI

		(cAliasPri)->(dbSkip())
	EndDo
	(cAliasPri)->(dbCloseArea())
EndIf

If aXMtrz <> Nil
	DT6->(dbSetOrder(1))
	cNumAgd := Posicione('DT6',1,xFilial('DT6')+cXSeek,'DT6_NUMAGD')
	cIteAgd := DT6->DT6_ITEAGD
	lTemAgd := .F.
	DYD->(dbSetOrder(1))
	If !Empty(cNumAgd) .And. DYD->(dbSeek(xFilial("DYD")+cNumAgd+cIteAgd))
		//Nao retirar "+1" da comparação dos dados, pois no cadastro do tipo de agendamento a prioridade é 0..4
		//nos parâmetros do pergunte 1..5, não sendo possivel alteração.
		If Iif(aXMtrz[CTMARCA],.T.,(Val(DYD->DYD_TIPAGD)+1 >= mv_par07 .And. Val(DYD->DYD_TIPAGD)+1 <= mv_par08))
			cRetPri := TMSA146PAE(aRetPrior,DYD->DYD_DATAGD)
			If !Empty(cRetPri)
				cCorPri := Upper( "BR_" + StrTran(AllTrim(aRetCor[Ascan(aRetCor, {|x| AllTrim(x[2])==AllTrim(cRetPri)}), 3]),"Rosa","Pink"))
				lRet    := .T.
			EndIf
   		 	Aadd(aXMtrz, DYD->DYD_NUMAGD                                                                   )
  			Aadd(aXMtrz, DYD->DYD_ITEAGD                                                                   )
			Aadd(aXMtrz, cCorPri                                                                           )
      		Aadd(aXMtrz, Upper( AllTrim( aRetTipo[ Ascan( aRetTipo, { |x| x[2] == DYD->DYD_TIPAGD} ), 3 ])))
   	   		Aadd(aXMtrz, DYD->DYD_DATAGD                                                                   )
  	   		Aadd(aXMtrz, Upper( AllTrim( aRetPrd[  Ascan( aRetPrd , { |x| x[2] == DYD->DYD_PRDAGD} ), 3 ])))
   			Aadd(aXMtrz, DYD->DYD_INIAGD                                                                   )
  	   		Aadd(aXMtrz, DYD->DYD_FIMAGD                                                                   )
		Else
   	   		Aadd(aXMtrz, Space(TamSx3("DYD_NUMAGD")[1])        )
  		  	Aadd(aXMtrz, Space(TamSx3("DYD_ITEAGD")[1])        )
			Aadd(aXMtrz, "PMSEDT3")
      		Aadd(aXMtrz, Space(TamSx3("DYD_TIPAGD")[1])        )
   	   		Aadd(aXMtrz, Space(TamSx3("DYD_DATAGD")[1])        )
  	   		Aadd(aXMtrz, Space(TamSx3("DYD_PRDAGD")[1])        )
   			Aadd(aXMtrz, Space(TamSx3("DYD_INIAGD")[1])        )
  	   		Aadd(aXMtrz, Space(TamSx3("DYD_FIMAGD")[1])        )
			lRet := aXMtrz[CTMARCA]
		EndIf
	Else
  	   	Aadd(aXMtrz, Space(TamSx3("DYD_NUMAGD")[1])        )
	   	Aadd(aXMtrz, Space(TamSx3("DYD_ITEAGD")[1])        )
		Aadd(aXMtrz, "PMSEDT3")
     	Aadd(aXMtrz, Space(TamSx3("DYD_TIPAGD")[1])        )
  	  	Aadd(aXMtrz, Space(TamSx3("DYD_DATAGD")[1])        )
   		Aadd(aXMtrz, Space(TamSx3("DYD_PRDAGD")[1])        )
  		Aadd(aXMtrz, Space(TamSx3("DYD_INIAGD")[1])        )
   		Aadd(aXMtrz, Space(TamSx3("DYD_FIMAGD")[1])        )
   		lRet := .T.
	EndIf
EndIf

RestArea(aAreaAGD)
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA141   ºAutor  ³Felipe Barbieri     º Data ³  20/01/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamada da função  TMSA240Mnt para Inclusão de Condutor    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Tmsa141                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA141TRM()
If DTQ->DTQ_STATUS == StrZero(2, Len(DTQ->DTQ_STATUS)) //Em trânsito
   RegToMemory('DTQ')
   TmsA240Mnt('DTR',DTR->( Recno() ),4,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,,DTQ->DTQ_ROTA,DTQ->DTQ_SERTMS,,,,DTQ->DTQ_TIPVIA,.T.,,.F.,,,.F.,,,,.T.)
Else
  Help(' ', 1, 'TMSXFUNA25')
EndIf

Return

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
Function MenuD141(cSerTms)

Local aEncRotina := {}
Local aFecRotina := {}
Local aMafRotina := {}
Local aCarRotina := {}
Local aMntRotina := {}
Local aCmpRotina := {}
Local lMDFe      := .F.
Local lTabDJM    := .F.
Local cTMSOpDg	 := SuperGetMv("MV_TMSOPDG", .F., .F.)	// Indica se a integração com Operadoras de Frota está ativa. 0=Não utiliza, 1=Somente Vale-Pedágio e 2=Vale Pedágio e Frota.

Private aRotina  := {}

//-- Esta abrindo o SX3 devido ao MenuDef, da erro log se tentar acessar alguma tabela via MDI.
DbSelectArea( 'SX3' )
SX3->(dbSetOrder(2))
If SX3->(MsSeek("DTX_TIPMAN"))
	lMDFe:= .T.
EndIf
If SX3->(MsSeek("DUA_CODFOR"))
	lTabDJM:= .T.
EndIf

If FindFunction("TMSA144Sub")

	aEncRotina := { { STR0059, "TMSA144Sub(7, 3)",0 ,3 },;  //"Encerrar"
						 { STR0060, "TMSA144Sub(7, 4)",0 ,4 }}   //"Estornar"

	aFecRotina := { { STR0061, "TMSA144Sub(5, 3)",0 ,3 },;  //"Fechar"
						 { STR0060, "TMSA144Sub(5, 5)",0 ,4}}    //"Estornar"

	aCmpRotina := {	{ STR0113, "TMSA144Sub(12, 4)",0 ,3 },; //"Monitora"
					{ STR0114, "TMSA144Sub(12, 4)",0 ,4 } } //"Altera"

	If lMDFe
		If TableInDic("DLI",.F.) .And. ExistFunc("TMSAE74")		
			aMafRotina := { { STR0062, "TMSA144Sub(3, 2)",0 ,2 },;  //"Visual/Excluir"
							 { STR0063, "TMSA144Sub(3, 3)",0 ,3 },;  //"Manifestar"
							 { STR0082, "TMSAE73()",0 ,2  },;   //"MDF-e"
							 { STR0106, "TMSAE74()",0 ,4 } } //"Tracking eventos MDFe"
		Else
			aMafRotina := { { STR0062, "TMSA144Sub(3, 2)",0 ,2 },;  //"Visual/Excluir"
							 { STR0063, "TMSA144Sub(3, 3)",0 ,3 },;  //"Manifestar"
							 { STR0082, "TMSAE73()",0 ,2  } } //"MDF-e"
		EndIf			 
	Else
		aMafRotina := { { STR0062, "TMSA144Sub(3, 2)",0 ,2 },;  //"Visual/Excluir"
						 { STR0063, "TMSA144Sub(3, 3)",0 ,3 }}   //"Manifestar"
	EndIf
    If ExistFunc("TMSAE73B") .AND. TMSA73BX1()
        aAdd(aMafRotina, {STR0112, "TMSAE73B()", 0, 2})
    EndIf
	//-- Visualizar Percurso
	If AliasInDic("DL0") .AND. ExistFunc("TMSA144Per")
		AAdd(aMafRotina, {STR0101,"TMSA144Per()", 0, 2 	})  //"Visu. Percurso"
	EndIf

	aCarRotina := { { STR0028, "TMSA144Sub(2, 2)",0 ,2 },;  //"Visualizar"
						 { STR0064, "TMSA144Sub(2, 3)",0 ,3 },;  //"Carregar"
						 { STR0060, "TMSA144Sub(2, 4)",0 ,4 }}   //"Estornar"

	AAdd(aMntRotina, { STR0065, "TMSA144Sub(1, 3)" ,0 ,3 })  //"Confirmacao"

	If cSerTms == "3"
		AAdd(aMntRotina, { STR0066, aCarRotina	,0 ,2 })   //"Carregamento"
		AAdd(aMntRotina, { STR0074, aMafRotina	,0 ,2 })   //"Manifesto"
	EndIf
	AAdd(aMntRotina, { STR0090 ,"TMSA141TRM"			,0 ,2 }) //"Inclusão Condutor"
	AAdd(aMntRotina, { STR0067, "TMSA144Sub(4, 2)" 	,0 ,2 })  //"Operacoes"
	AAdd(aMntRotina, { STR0068, aFecRotina 	     	,0 ,2 })  //"Fechamento"
	AAdd(aMntRotina, { STR0069, "TMSA144Sub(6, 2)" 	,0 ,2 })  //"Reg.Ocorrencia"
	AAdd(aMntRotina, { STR0070, aEncRotina	        ,0 ,2 })  //"Encerramento"
	If cSerTMS == '3' .Or. IsInCallStack("TMSAF76")
		AAdd(aMntRotina, { STR0115, aCmpRotina			,0 ,2 }) //"Compr Entreg"
	EndIf
	AAdd(aMntRotina, { STR0071, "TMSA144Sub(8, 2)" 	,0 ,2 })  //"Movto.Caixinha"
	If lTabDJM
		AAdd(aMntRotina, { STR0100, "TmsA141FAd"      ,0 ,2 })  //"Fornecedores Adicionais"
	EndIf
	If cTMSOpDg $ "1,2" .And. ExistFunc('TMSA161')
		AAdd(aMntRotina, { STR0105, 'TMSA161', 0, 2} ) //"Troca de cartão"
	EndIf

	aRotina	:= {	{ STR0027 ,'AxPesqui' ,0 ,1 ,0 ,.F. },;	//'Pesquisar'
						{ STR0028 ,'TMSA141Mnt' ,0 ,2 ,0 ,Nil },; 	//'Visualizar'
						{ STR0029 ,'TMSA141Mnt' ,0 ,3 ,0 ,Nil },; 	//'Incluir'
						{ STR0030 ,'TMSA141Mnt' ,0 ,4 ,0 ,Nil },; 	//'Alterar'
						{ STR0031 ,'TMSA141Mnt' ,0 ,5 ,0 ,Nil },; 	//'Excluir'
						{ STR0072 , aMntRotina  ,0 ,6 ,0 ,Nil },;   //"Manutencao"
						{ STR0032 ,'TMSA141Fbr' ,0 ,1 ,0 ,Nil }} 	 //'Status'
Else

	aRotina	:= {	{ STR0027 ,'AxPesqui' ,0 ,1 ,0 ,.F. },;	//'Pesquisar'
						{ STR0028 ,'TMSA141Mnt' ,0 ,2 ,0 ,Nil },; 	//'Visualizar'
						{ STR0029 ,'TMSA141Mnt' ,0 ,3 ,0 ,Nil },; 	//'Incluir'
						{ STR0030 ,'TMSA141Mnt' ,0 ,4 ,0 ,Nil },; 	//'Alterar'
						{ STR0031 ,'TMSA141Mnt' ,0 ,5 ,0 ,Nil },; 	//'Excluir'
						{ STR0032 ,'TMSA141Fbr',0 ,1 ,0 ,Nil }} 	 //'Status'
Endif

If ExistBlock("TM141MNU")
	ExecBlock("TM141MNU",.F.,.F.)
EndIf

Return( aRotina )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tm141MntDc ³ Autor ³ Rafael Souza        ³ Data ³07/11/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o Browse do manutencao de Doctos (TMSA500)     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tm141MntDc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA141                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Tm141MntDc()

Local aArea 	 := GetArea()
Local cOldFName  := FunName()

SetFunName("TMSA500")

TmsA500()

SetFunName(cOldFName)
RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA141Fbr
Filtro de Browse

@author Caio Murakami
@since 24/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function TMSA141Fbr()

TMSA140Fbr( ,,,oBrw141, .T. )

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsA141FAd
Tratamento para manutenção de fornecedores adicionais da viagem
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 23/11/2016
@param [cAlias], Caracter, Alias
@param [nReg], Numérico, Número do registro
@param [nOpc], Numérico, Opção
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Function TmsA141FAd(cAlias, nReg, nOpc)

	Local aArea   := GetArea()
	Local lRet    := .T.
	Local cTitulo := STR0029 //STR0029 'Incluir'
	Local nOper   := MODEL_OPERATION_INSERT
	Local oMdlDJM

	If !AliasIndic('DJM') //Caso nao exista o Alias DJM - Fornecedores Adicionais Viagem
		Help('', 1, 'TMSA14441')
		lRet := .F.
	Else
		//Posiciona no primeiro fornecedor adicinal, se existir
		DbSelectArea("DJM")
		DJM->(DbSetOrder(1)) //DJM_FILIAL+DJM_FILORI+DJM_VIAGEM+DJM_CODFOR+DJM_LOJFOR
		If DJM->(DbSeek(FwxFilial('DJM') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))
			cTitulo := STR0030 //STR0030 'Alterar'
			nOper   := MODEL_OPERATION_UPDATE
		EndIf

		//Cria modelo de dados para atribuir informacoes da viagem
		oMdlDJM := FWLoadModel("TMSA151")
		oMdlDJM:SetOperation(nOper)
		oMdlDJM:Activate()

		If nOper == MODEL_OPERATION_INSERT
			oMdlDJM:GetModel( 'TMSA151_CAB' ):SetValue( 'DJM_FILORI', DTQ->DTQ_FILORI )
			oMdlDJM:GetModel( 'TMSA151_CAB' ):SetValue( 'DJM_VIAGEM', DTQ->DTQ_VIAGEM )
		EndIf

		//Executa a view MVC com a operacao e modelo de dados identificados
		FWExecView(cTitulo, "TMSA151", nOper, ,{|| .T. }, , , , , , ,oMdlDJM)

		//Desativa e elimina modelo de dados
		oMdlDJM:DeActivate()
		oMdlDJM:Destroy()
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A141LmpDJM
Limpa variável Static referente ao Modelo de dados de fornecedores adicionais da viagem.
* ATENÇÃO: Função executada também pelo TMSA144 *
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 23/11/2016
@return Nil Não há retorno
/*/
//-------------------------------------------------------------------------------------------------
Function A141LmpDJM()

	oMdlDJMGr := Nil

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A141PCmDJM
Prepara o commit do modelo TMSA151
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 23/11/2016
@param [oMldDJM], Objeto, Modelo de dados
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Function A141PCmDJM(oMldDJM)

	Local lRet      := .T.
	Local oSubModel := oMldDJM:GetModel("MdFieldDJM")
	Local nOper     := oMldDJM:GetOperation()

	If oMdlDJMGr != Nil
		oMdlDJMGr:Destroy()
	Endif

	DbSelectArea('DJM')
	DJM->(DbSetOrder(1)) //DJM_FILIAL+DJM_FILORI+DJM_VIAGEM+DJM_CODFOR+DJM_LOJFOR
	DJM->(DbSeek(xFilial("DJM") + oSubModel:GetValue("DJM_FILORI") + oSubModel:GetValue("DJM_VIAGEM")))

	oMdlDJMGr := FWLoadModel("TMSA151")
	oMdlDJMGr:SetOperation(nOper)
	oMdlDJMGr:Activate()
	oMdlDJMGr:LoadByModel(oMldDJM)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A141VwDJM
Prepara o commit do modelo TMSA151
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 23/11/2016
@param [nOpcX], Numérico, Operação
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Function A141VwDJM(nOpcX)

	Local lRet       := .T.
	Local aArea      := GetArea()
	Local nOpcView   := nOpcx
	Local bCloseOnOK := {|| .T.}
	Local oModel     := Nil
	Local oExecView  := Nil
	Local cFilOri    := Iif(nOpcx == 3, M->DTQ_FILORI, DTQ->DTQ_FILORI)
	Local cViagem    := Iif(nOpcx == 3, M->DTQ_VIAGEM, DTQ->DTQ_VIAGEM)

	If nOpcx == 2
		DJM->(DbSetOrder(1)) //DJM_FILIAL+DJM_FILORI+DJM_VIAGEM+DJM_CODFOR+DJM_LOJFOR
		DJM->(DbSeek(FWxFilial('DJM') + cFilOri + cViagem))

		FWExecView(STR0028, "TMSA151", MODEL_OPERATION_VIEW, , {|| .T. }, , , , { || .T. }, , ,)
	Else

		DJM->(DbSetOrder(1)) //DJM_FILIAL+DJM_FILORI+DJM_VIAGEM+DJM_CODFOR+DJM_LOJFOR
		If !DJM->(DbSeek(FWxFilial('DJM') + cFilOri + cViagem)) .And. oMdlDJMGr == Nil
			nOpcView := MODEL_OPERATION_INSERT
		EndIf

		oExecView := FWViewExec():New()
		oExecView:SetOperation(nOpcView)

		oModel := FWLoadModel("TMSA151")
		oModel:SetOperation(nOpcView)
		oModel:SetCommit({|oMld| A141PCmDJM(oMld)})
		oModel:Activate()

		If nOpcView == MODEL_OPERATION_INSERT
			oModel:SetValue('MdFieldDJM', 'DJM_FILORI', cFilOri)
			oModel:SetValue('MdFieldDJM', 'DJM_VIAGEM', cViagem)
		EndIf

		If oMdlDJMGr != Nil
			oModel:LoadByModel(oMdlDJMGr)
			oModel:VldData()
		Endif

		oExecView:SetSource("TMSA151")
		oExecView:SetModal(.F.)
		oExecView:SetCloseOnOK(bCloseOnOK)
		oExecView:SetModel(oModel)
		oExecView:OpenView(.F.)
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A141AtuDJN
Atualiza dados do Redespachos Adicionais da Viagem - Integração TMS x GFE
@type function
@author Katia
@version 12
@since 30/11/2016
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Function A141AtuDJN(cFilDoc,cDoc,cSerie,l141Del)

Local aArea  := GetArea()
Local nX     := 0
Local nZ     := 0
Local nY     := 0
Local lCmpDFV:= DFV->(ColumnPos('DFV_TIPVEI')) > 0

Default l141Del := .F.  //Chamada do TMSA141DEL - exclui o documento da viagem

If Len(aRedVge) > 0
	dbSelectArea("DJN")
	nX := aScan(aRedVge,{|x| x[1] == cFilDoc+cDoc+cSerie}) //-- Verifica se foi informado o Redespacho Adicional para o Documento
	If nX > 0
		DJN->(dbSetOrder(1))
		While DJN->(MsSeek(xFilial('DJN')+M->DTQ_FILORI+M->DTQ_VIAGEM+cFilDoc+cDoc+cSerie))
			RecLock("DJN",.F.)
			DJN->(dbDelete())
			MsUnLock()
		EndDo

		If !l141Del	//Altera DJN quando nao há exclusao do documento na viagem
			For nZ := 1 to Len(aRedVge[nX][2])
				If !aRedVge[nX][2][nZ][Len(aRedVge[nX][2][nZ])] //-- Verifica se a linha esta deletada
					RecLock("DJN",.T.)
					For nY := 1 to Len(aHeaderDJN)
						If aHeaderDJN[nY][10] # "V"
							If (!lCmpDFV .And. aHeaderDJN[nY][2] $ 'DJN_TIPVEI|DJN_DESTIP') .Or. aHeaderDJN[nY][2] $ "DJN_CHVEXT"
								Loop
							EndIf
							DJN->(FieldPut(FieldPos(Trim(aHeaderDJN[nY][2])),aRedVge[nX][2][nZ][nY]))
						EndIf
					Next nY
					DJN->DJN_FILIAL := xFilial('DJN')
					DJN->DJN_FILORI := M->DTQ_FILORI
					DJN->DJN_VIAGEM := M->DTQ_VIAGEM
					DJN->DJN_FILDOC := cFilDoc
					DJN->DJN_DOC    := cDoc
					DJN->DJN_SERIE  := cSerie
					DJN->(MsUnlock())
				EndIf
			Next
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PROTEÇÃO CONTRA VERSÃO INCOMPATÍVEL - RETIRAR NA 12.1.18     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function TMSA141Ver()
Return '12.1.17'
