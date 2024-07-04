#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FILEIO.CH'
#INCLUDE 'TopConn.ch'
#INCLUDE 'Plsmger.ch'
#INCLUDE 'Colors.ch'
#INCLUDE "plsmfun.ch"
#INCLUDE "PLSMCCR.CH" 
#INCLUDE "PLSP520.CH"

#DEFINE CRLF chr( 13 ) + chr( 10 )
#DEFINE G_CONSULTA  "01"
#DEFINE G_SADT_ODON "02" 
#DEFINE G_RES_INTER "05"
#DEFINE G_HONORARIO "06"

STATIC nAcaoB2TView := 0
STATIC _oBaixa		:= NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSP520
Rotina de Aviso Lote Guias - Recebimento

@author  Guilherme Carvalho
@since   16/04/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLSP520()

private oMBrwB2T 
private cFilter := ""

cFilter := PLSP520FIL(.f.)
setKey(VK_F2 ,{|| cFilter := PLSP520FIL(.t.) })

oMBrwB2T:= FWMarkBrowse():New()
oMBrwB2T:SetAlias('B2T')
oMBrwB2T:SetDescription(STR0001)
oMBrwB2T:SetMenuDef("PLSP520")
oMBrwB2T:AddLegend( "B2T->B2T_STATUS=='1'", "GREEN", 	STR0002  ) //"Aviso Importado"
oMBrwB2T:AddLegend( "B2T->B2T_STATUS=='2'", "YELLOW", 	STR0003  ) //"Baixa Aviso Pendente"
oMBrwB2T:AddLegend( "B2T->B2T_STATUS=='3'", "ORANGE", 	STR0004  ) //"Baixa Aviso Enviado"
oMBrwB2T:AddLegend( "B2T->B2T_STATUS=='4'", "RED", 		STR0005  ) //"Lote Cancelado"
oMBrwB2T:SetFieldMark( 'B2T_OK' )	
oMBrwB2T:SetAllMark({ ||  PLSInvert(oMBrwB2T, "B2T") })
oMBrwB2T:SetWalkThru(.F.)
oMBrwB2T:SetFilterDefault(cFilter)
oMBrwB2T:SetAmbiente(.F.)
oMBrwB2T:ForceQuitButton()
oMBrwB2T:Activate()

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta o menu

@author  Guilherme Carvalho
@since   16/04/2018
@version P12
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0006  	Action 'PesqBrw'        	OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina Title STR0007 	Action 'PLSVIEWB2T(1)'		OPERATION 2 ACCESS 0 //'Detalhar'
ADD OPTION aRotina Title STR0008 	Action 'ViewDef.PLSP520'	OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0009   	Action 'PLSP520IMP()'		OPERATION 3 ACCESS 0 //'Importar Arquivo'
ADD OPTION aRotina Title STR0010   	Action 'PLSP520BAI()'		OPERATION 3 ACCESS 0 //'Proc.Baixa Aviso Vencido'
ADD OPTION aRotina Title STR0012	Action 'Processa({||PLSP520DEL()},"Lote de Aviso - Exclusao","Processando...",.T.)' 	OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina Title "<F2> - Filtrar" 	Action 'PLSP520FIL(.t.)'    OPERATION 2 ACCESS 0 //'Filtrar'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVIEWB2T
Chamada para mudar a visualização do form.

@author Guilherme Carvalho
@since 08/06/18
@version P11
/*/
Function PLSVIEWB2T(nOpc)

nAcaoB2TView := nOpc

If nAcaoB2TView == 1
	FWExecView('','PLSP520', MODEL_OPERATION_VIEW, , { || lOk := .T., lOk } )
EndIf

nAcaoB2TView := 0

Return(.T.)    

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view

@author  Guilherme Carvalho
@since   16/04/2018
@version P12
/*/
Static Function ViewDef()

Local oStruB2T := FWFormStruct( 2, 'B2T' ) 
Local oStruB5T := FWFormStruct( 2, 'B5T' )
Local oStruB6T := FWFormStruct( 2, 'B6T' )
Local oStruBNT := FWFormStruct( 2, 'BNT' )
Local oModel   := FWLoadModel( 'PLSP520' )
Local oView      

oView := FWFormView():New()
oView:SetModel( oModel )

If nAcaoB2TView == 1

	//oView:AddField( 'VIEW_B2T', oStruB2T, 	'B2TMASTER' )
	oView:AddGrid( 'VIEW_B5T', 	oStruB5T, 	'B5TDETAIL' )
	oView:AddGrid( 'VIEW_B6T', 	oStruB6T, 	'B6TDETAIL' )
	oView:AddGrid( 'VIEW_BNT', 	oStruBNT, 	'BNTDETAIL' )
	
	//oView:EnableTitleView('VIEW_B2T','Lote') 
	oView:EnableTitleView('VIEW_B5T',STR0013) //'Guias do Lote'
	oView:EnableTitleView('VIEW_B6T',STR0014) //'Eventos da Guia'
	oView:EnableTitleView('VIEW_BNT',STR0015) //'Equipe do Procedimento'
	
	// Divide a tela em para conteúdo e rodapé
	//oView:CreateHorizontalBox( 'LOTE', 		15 )
	oView:CreateHorizontalBox( 'PESQUISAR',	06 )
	oView:CreateHorizontalBox( 'GUIAS', 	40 )
	oView:CreateHorizontalBox( 'EVENTOS', 	32 )
	oView:CreateHorizontalBox( 'EQUIPE', 	22 )
	
	//oView:SetOwnerView( 'VIEW_B2T', 'LOTE')   
	oView:SetOwnerView( 'VIEW_B5T', 'GUIAS')
	oView:SetOwnerView( 'VIEW_B6T', 'EVENTOS')
	oView:SetOwnerView( 'VIEW_BNT', 'EQUIPE')
	
	oView:AddOtherObject("OTHER_PANEL", {|oPanel| fPesquisa(oPanel)})
	
	// Associa ao box que ira exibir os outros objetos
	oView:SetOwnerView("OTHER_PANEL",'PESQUISAR')

Else

	oView:AddField( 'VIEW_B2T', oStruB2T, 'B2TMASTER' )
	oView:EnableTitleView('VIEW_B2T','Lote')
	oView:CreateHorizontalBox( 'LOTE', 100 )
	oView:SetOwnerView( 'VIEW_B2T', 'LOTE')
	
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define a model

@author  Guilherme Carvalho
@since   16/04/2018
@version P12
/*/
Static Function ModelDef()
                                         
Local oStruB2T := FWFormStruct( 1, 'B2T')
Local oStruB5T := FWFormStruct( 1, 'B5T')
Local oStruB6T := FWFormStruct( 1, 'B6T')
Local oStruBNT := FWFormStruct( 1, 'BNT')
Local oModel

oModel := MPFormModel():New( 'PLSP520MODEL',/*bPreValidacao*/,{|| PLSP520IVd(oModel)},/*bCommit*/, /*bCancel*/ )

// Monta a estrutura
oModel:AddFields( 'B2TMASTER', 				, oStruB2T)
oModel:AddGrid(   'B5TDETAIL', 	'B2TMASTER'	, oStruB5T)           
oModel:AddGrid(   'B6TDETAIL', 	'B5TDETAIL'	, oStruB6T)
oModel:AddGrid(   'BNTDETAIL', 	'B6TDETAIL'	, oStruBNT)  

// Descrições
oModel:SetDescription( STR0020 ) //'Aviso Lote Guia'
oModel:GetModel( 'B2TMASTER' ):SetDescription( STR0016 ) //'Lote'
oModel:GetModel( 'B5TDETAIL' ):SetDescription( STR0017 ) //'Guias'
oModel:GetModel( 'B6TDETAIL' ):SetDescription( STR0018 ) //'Eventos'
oModel:GetModel( 'BNTDETAIL' ):SetDescription( STR0019 ) //'Equipe'

oModel:SetRelation( 'B5TDETAIL', { 	{ 	'B5T_FILIAL', 'xFilial( "B5T" )' 	},;
									{ 	'B5T_SEQLOT', 'B2T_SEQLOT'   		}},; 
										'B5T_FILIAL+B5T_SEQLOT+B5T_SEQGUI' )
										
oModel:SetRelation( 'B6TDETAIL', { 	{ 	'B6T_FILIAL', 'xFilial( "B6T" )' 	},;
									{ 	'B6T_SEQLOT', 'B5T_SEQLOT'   		},;
									{ 	'B6T_SEQGUI', 'B5T_SEQGUI' 			}},;
										'B6T_FILIAL+B6T_SEQLOT+B6T_SEQGUI+B6T_SEQUEN' )
										
oModel:SetRelation( 'BNTDETAIL', { 	{ 	'BNT_FILIAL', 'xFilial( "BNT" )' 	},;
									{ 	'BNT_SEQLOT', 'B6T_SEQLOT'   		},;
									{ 	'BNT_SEQGUI', 'B6T_SEQGUI' 			},;
									{ 	'BNT_SEQUEN', 'B6T_SEQUEN' 			}},;
										'BNT_FILIAL+BNT_SEQLOT+BNT_SEQGUI+BNT_SEQUEN+BNT_SEQEQU' )										

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSP520IVd
Valida a model

@author  Michel Montoro
@since   25/04/2018
@version P12
/*/
Function PLSP520IVd(oModel)                       
Local aArea 		:= GetArea()
Local nOperation 	:= oModel:GetOperation()
Local lRet			:= .T.		
Local cSql			:= ""	
	                                     
If nOperation == MODEL_OPERATION_DELETE
    
	// Verifica a Fase para exclusao.

	If B2T->B2T_STATUS <> "1"
		Help( ,, 'HELP',,STR0021, 1, 0) //"Permitido apenas excluir registros [1=Aviso Importado]"
		lRet := .F.
	Endif 		

	cSql += " SELECT B6T_CHVPRO " 
	cSql += " FROM " + RetSqlName("B2T") + " B2T "
	cSql += " INNER JOIN " + RetSqlName("B6T") + " B6T " 
	cSql += "  ON B6T_FILIAL = B2T_FILIAL "
	cSql += "  AND B6T_OPEHAB = B2T_OPEHAB "
	cSql += "  AND B6T_NUMLOT = B2T_NUMLOT "
	cSql += "  AND B6T_LAPRO <> ' ' "
	cSql += "  AND B6T.D_E_L_E_T_ = ' ' "
	cSql += " WHERE B2T_FILIAL = '" + xfilial("B2T") + "' "
	cSql += "  AND B2T_OPEHAB = '" + B2T->B2T_OPEHAB + "' "
	cSql += "  AND B2T_NUMLOT = '" + B2T->B2T_NUMLOT + "' "
	cSql += "  AND B2T.D_E_L_E_T_ = ' ' "
	
	cSql := ChangeQuery(cSql)
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbExc",.F.,.T.)	
	if !TrbExc->(eof())	
		Help( ,, 'HELP',,STR0029 + CRLF + STR0030 + CRLF + STR0031 +" '" + alltrim(TrbExc->B6T_CHVPRO) + "' ", 1, 0) //"Registro já contabilizado. " # " Exclua sua provisão para prosseguir! " # " Chave:" 
		lRet := .F.
	endif
	
	TrbExc->(dbclosearea())
Endif

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fPesquisa
Cria o campo de pesquisa

@author  Michel Montoro
@since   16/04/2018
@version P12
/*/
Static Function fPesquisa( oPanel )

Local cCpoPesq 		:= Space(TamSx3("B5T_NMGPRE")[1])
Local cTpPesq		:= Space(50)
Local nPesq			:= 1                        
Local lRet			:= .F.
Local aTpPesq		:= {}                    
Local oTFont1 		:= TFont():New("Calibri",,-22,.T.,.T.)      
Local oTFont2 		:= TFont():New("Calibri",,-18,.T.,.F.)
Local oTFont3 		:= TFont():New("Calibri",,-13,.T.,.F.)
Local oCpoPesq	
Local oBtnPesq

aADD(aTpPesq,"Numero Guia")
 
@ 03,05 	COMBOBOX cTpPesq ITEMS aTpPesq	SIZE 80, 12;
			VALID fTpPesq(@nPesq, cTpPesq)	FONT oTFont2 	OF oPanel PIXEL
@ 03,90	MSGET oCpoPesq VAR cCpoPesq 	SIZE 100,010 FONT oTFont2 PIXEL OF oPanel

oBtnPesq := TBtnBmp2():New( 000,380,043,040,'BMPVISUAL',,,,{|| Processa({|| lRet:=PesquGuia(nPesq,cCpoPesq)}, STR0032 ) }, oPanel, STR0033,,.T. ) //"Pesquisando..." # "Pesquisar"

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} fTpPesq
Define o tipo de pesquisa

@author  Michel Montoro
@since   16/04/2018
@version P12
/*/
Static Function fTpPesq(nPesq, cTpPesq)

If AllTrim(cTpPesq) == "Numero Guia"
	nPesq := 1		
Else
	nPesq := 0
EndIf

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} PesquGuia
Efetua a pesquisa das Guias

@author  Michel Montoro
@since   16/04/2018
@version P12
/*/
Static Function PesquGuia(nPesq,cCpoPesq)
Local oModel 	:= FWModelActive()
Local oModelB5T := oModel:GetModel( 'B5TDETAIL' )
Local oView 	:= FWViewActive()
Local nFor 		:= 0
Local aSaveLine := FWSaveRows()
Local cConteudo	:= ""
Local lFind		:= .F.

For nFor := 1 To oModelB5T:Length()
	oModelB5T:GoLine( nFor )
	If nPesq == 1
		cConteudo := oModelB5T:GetValue("B5T_NMGPRE") 
	    If AllTrim(cCpoPesq) $ cConteudo
	    	lFind := .T.
	    	Exit
	    EndIf
	EndIf
Next nFor

If !lFind
	FWRestRows( aSaveLine )
Else
	oView:Refresh()
EndIf

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL520QUERY
Query das Guias

@author  Michel Montoro
@version P12
@since   16/04/2018
/*/
//-------------------------------------------------------------------
Static Function PL520QUERY(cProcesso,aCampos)
Local cSql 		:= ""
Local aStru		:= B5T->(DBSTRUCT())	//Estrutura da Tabela
Local cArqTrab	:= ""
Local nX		:= 0

Default cProcesso := ""
Default aCampos   := {}

aAdd(aStru,{"B2T_DATTRA","D",8,0})

If cProcesso == "BAIXA"
	cSql := " SELECT B2T_OPEHAB AS OPEAVISO, B2T_DATTRA AS DATENVIO, B2T_NUMLOT AS NUMLOTE, B2T_OPEORI AS OPEBENEF, B5T_MATRIC AS MATRICULA, " 
	cSql += " B5T_TIPGUI AS TIPOGUIA, B5T_NMGPRE AS NUMGUIA, B5T_FILIAL AS FILIAL, B5T_SEQLOT AS SEQLOT, B5T_SEQGUI AS SEQGUI, B5T_VLRTOT, B5T_VLRGLO, "
	cSql += " B5T_NUMLOT, B5T_SEQLOT, B5T_SEQGUI, B5T_OPEORI, B5T_OPEHAB, B5T_NMGPRE, B5T_MATRIC, B5T_NOMUSR, B5T_CGCRDA, B5T_NOMRDA, B5T_IDMARK, B2T_DATTRA  "
	cSql += " FROM " + RetSqlName("B2T") + " B2T "
	cSql += " INNER JOIN " + RetSqlName("B5T") + " B5T "
	cSql += " 	ON  B5T.B5T_FILIAL = '" + xFilial("B5T") + "' "
	cSql += " 	AND B5T.B5T_NUMLOT = B2T.B2T_NUMLOT "
	cSql += " 	AND B5T.B5T_SEQLOT = B2T.B2T_SEQLOT "
	cSql += " 	AND B5T.B5T_CODPEG = ' ' "
	cSql += " 	AND B5T.B5T_NUMGUI = ' ' "
	cSql += " 	AND B5T.B5T_VLRGLO = 0   "
	If __aRetBai[08] == STR0064 //"Sim"
	cSql += " 	AND (B5T.B5T_STAAVI = ' ' OR B5T.B5T_STAAVI = '0' OR B5T.B5T_STAAVI = '1') " //0=Nao Enviado;1=Expirado Enviado
	Else
	cSql += " 	AND (B5T.B5T_STAAVI = ' ' OR B5T.B5T_STAAVI = '0') " //0=Nao Enviado;1=Expirado Enviado
	EndIf
	cSql += " 	AND B5T.D_E_L_E_T_ = ' ' "
	//cSql += " INNER JOIN " + RetSqlName("B6T") + " B6T "
	//cSql += " 	ON  B6T.B6T_FILIAL = '" + xFilial("B6T") + "' "
	//cSql += " 	AND B6T.B6T_NUMLOT = B5T.B5T_NUMLOT "
	//cSql += " 	AND B6T.B6T_SEQLOT = B5T.B5T_SEQLOT "
	//cSql += " 	AND B6T.B6T_SEQGUI = B5T.B5T_SEQGUI "
	//cSql += " 	AND B6T.D_E_L_E_T_ = ' ' "
	cSql += " WHERE B2T.B2T_FILIAL = '" + xFilial("B2T") + "' "
	cSql += " 	AND B2T.B2T_STATUS IN ('1','2') " //1=Aviso Importado;2=Baixa Aviso Parcial;3=Baixa Aviso Enviado;4=Lote Cancelado
	cSql += " 	AND B2T.B2T_OPEHAB = '" + __aRetBai[01] + "' "
	cSql += " 	AND B2T_NUMLOT BETWEEN '" + __aRetBai[02] + "' AND '" + __aRetBai[03] + "' " //Num.Lote de ? Num.Lote ate ?
	cSql += " 	AND B2T_SEQLOT BETWEEN '" + __aRetBai[04] + "' AND '" + __aRetBai[05] + "' " //Seq.Lote de ? Seq.Lote ate ?
	cSql += " 	AND B2T_DATTRA BETWEEN '" + DToS(__aRetBai[06]) + "' AND '" + DToS(__aRetBai[07]) + "' " //Dt.Trans.de ? Dt.Trans.ate ?
	cSql += " 	AND B2T.D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B5T.B5T_FILIAL, B5T.B5T_SEQLOT, B5T.B5T_SEQGUI "
	
	cSql := ChangeQuery(cSql)

	If _oBaixa <> Nil
		_oBaixa:Delete()
		_oBaixa := Nil
	Endif
	cArqTrab := GetNextAlias()
	_oBaixa  := FWTemporaryTable():New( cArqTrab )  
	_oBaixa:SetFields(aStru) 

	//------------------
	//Criação da tabela temporaria
	//------------------
	_oBaixa:Create()  
	
	Processa({||SqlToTrb(cSql, aStru, cArqTrab)})	// Cria arquivo temporario
	
	DbSetOrder(0) // Fica na ordem da query

	Return cArqTrab
EndIf

Return "TrbPeg"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSP520BAI
Realiza a Valoração da coparticipação do beneficiário

@author  Michel Montoro
@since   16/04/2018
@version P12
/*/
Function PLSP520BAI()

Local cTitulo	:= STR0051 //"Exportação do PTU A530 - Baixa Aviso"
Local cTexto	:= ""
Local aOpcoes	:= { STR0023,STR0024 } //"Processar" # "Cancelar"
Local nTaman	:= 3
Local nOpc		:= 0
Local lRet		:= .T.

Private __aRetBai	:= {}
Private oProcess 	:= Nil

cTexto	:= CRLF + CRLF +;
STR0052 + CRLF +; 	//"Esta é a opção que irá efetuar a comunicação via WebService e enviar as guias "
STR0053 + CRLF +; 	//"que ultrapassaram a data estipulada em parametro e não estão relacionados com "
STR0054 			//"arquivo PTU A500"
nOpc		:= aviso( cTitulo,cTexto,aOpcoes,nTaman )

If( nOpc == 1 )
	If( PergBaixa() )
		oProcess := msNewProcess():New( { | lEnd | PLU520IBai( @lEnd ) } , STR0027 , STR0028 , .F. ) //"Processando" # "Aguarde..." 
		oProcess:Activate()
	EndIf
EndIf

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PergBaixa
Perguntas para composicao do arquivo de baixa

@author    Michel Montoro
@version   P12
@since     16/04/2018
/*/
//------------------------------------------------------------------------------------------
Static Function PergBaixa()
Local lRet			:= .F.
Local aPergs		:= {}
Local cOperadora	:= CriaVar("B2S_OPEORI",.F.)
Local cNumLoteDe	:= CriaVar("B2T_NUMLOT",.F.)
Local cNumLoteAte	:= Replicate("Z",Len(cNumLoteDe))
Local cSeqLoteDe	:= CriaVar("B2T_SEQLOT",.F.)
Local cSeqLoteAte	:= Replicate("Z",Len(cSeqLoteDe))
Local cDtTransDe	:= CToD("")
Local cDtTransAte	:= CToD("")
Local nX			:= 1

aadd(/*01*/ aPergs,{ 1,STR0055,	cOperadora	,"@!",'.T.','B39PLS',/*'.T.'*/,40,.T. } ) //"Operadora Habitual:"
aadd(/*02*/ aPergs,{ 1,STR0056,	cNumLoteDe	,"@!",'.T.',        ,/*'.T.'*/,40,.F. } ) //"Num. Lote De"
aadd(/*03*/ aPergs,{ 1,STR0057,	cNumLoteAte	,"@!",'.T.',        ,/*'.T.'*/,40,.T. } ) //"Num. Lote Até"
aadd(/*04*/ aPergs,{ 1,STR0058,	cSeqLoteDe	,"@!",'.T.',        ,/*'.T.'*/,40,.F. } ) //"Seq. Lote De"
aadd(/*05*/ aPergs,{ 1,STR0059,	cSeqLoteAte	,"@!",'.T.',        ,/*'.T.'*/,40,.T. } ) //"Seq. Lote Até"
aadd(/*06*/ aPergs,{ 1,STR0060,	cDtTransDe	,"@!",'.T.',        ,/*'.T.'*/,40,.T. } ) //"Data Transação De"
aadd(/*07*/ aPergs,{ 1,STR0061,	cDtTransAte	,"@!",'.T.',        ,/*'.T.'*/,40,.T. } ) //"Data Transação Até"
aadd(/*08*/ aPergs,{ 2,STR0062,	STR0063		,{STR0063,STR0064}		,40    ,'.T.',.T. } ) //"Processa Enviados?" # "Não" # "Sim"

If( paramBox( aPergs,STR0065,__aRetBai,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSP520B',/*lCanSave*/.T.,/*lUserSave*/.T. ) ) //"Parâmetros - Processa Baixa de Aviso"
	If( validPergBaixa( __aRetBai ) )
		lRet := .T.
	Else
		lRet := PergBaixa()
	EndIf
EndIf
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} validPergBaixa
Validador de perguntas antes de processar

@author    Michel Montoro
@version   P12
@since     16/04/2018
/*/
//------------------------------------------------------------------------------------------
Static Function validPergBaixa( __aRetBai )
	Local nX
	Local lRet		:= .T.
	Local cMsgErro	:= STR0066 + CRLF + CRLF //"Corrija os itens abaixo antes de prosseguir:"
	
	For nX:=1 to len( __aRetBai )
		If		( nX == 1 )
			If Empty(__aRetBai[01])
				lRet		:= .F.
				cMsgErro += " - " + STR0067 + CRLF //"Parâmetro 'Operadora' não preenchido"
			EndIf
		ElseIf ( nX == 2 .OR. nX == 3 )
			If Empty(__aRetBai[02] + __aRetBai[03])
				lRet		:= .F.
				cMsgErro += " - " + STR0068 + CRLF //"Parâmetros 'Numero do Lote De/Até' preenchidos incorretamente"
			EndIf
		ElseIf ( nX == 4 .OR. nX == 5 )
			If Empty(__aRetBai[04] + __aRetBai[05])
				lRet		:= .F.
				cMsgErro += " - " + STR0069 + CRLF //"Parâmetros 'Sequencia do Lote De/Até' preenchidos incorretamente"
			EndIf
		ElseIf ( nX == 6 .OR. nX == 7 )
			If Empty(__aRetBai[06] + __aRetBai[07])
				lRet		:= .F.
				cMsgErro += " - " + STR0070 + CRLF //"Parâmetros 'Data Transação De/Até' preenchidos incorretamente"
			EndIf
		EndIf
	Next nx
	
	If( !lRet )
		Alert( cMsgErro )
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLU520IBai
Faz o processamento das guias

@author  Michel Montoro
@version P12
@since   16/04/2018
/*/
//-------------------------------------------------------------------
Function PLU520IBai(lEnd)
	
Local cini		:= time()
Local aCpos		:= {}

Private cAlias	:= ""

aAdd(aCpos,{STR0045	,"B5T_NUMLOT"	,,,,PesqPict("B5T","B5T_NUMLOT")}) //"Num. Lote"
aAdd(aCpos,{STR0046	,"B5T_SEQLOT"	,,,,PesqPict("B5T","B5T_SEQLOT")}) //"Seq. Lote"
aAdd(aCpos,{STR0047	,"B5T_SEQGUI"	,,,,PesqPict("B5T","B5T_SEQGUI")}) //"Seq. Guia"
aAdd(aCpos,{STR0075	,"B5T_OPEORI"	,,,,PesqPict("B5T","B5T_OPEORI")}) //"Oper. Origem"
aAdd(aCpos,{STR0076	,"B5T_OPEHAB"	,,,,PesqPict("B5T","B5T_OPEHAB")}) //"Oper. Habit."
aAdd(aCpos,{STR0077	,"B5T_NMGPRE"	,,,,PesqPict("B5T","B5T_NMGPRE")}) //"Nr.Guia Pres"
aAdd(aCpos,{STR0078	,"B5T_MATRIC"	,,,,PesqPict("B5T","B5T_MATRIC")}) //"Matricula"
aAdd(aCpos,{STR0079	,"B5T_NOMUSR"	,,,,PesqPict("B5T","B5T_NOMUSR")}) //"Usuário"
aAdd(aCpos,{STR0080	,"B5T_CGCRDA"	,,,,PesqPict("B5T","B5T_CGCRDA")}) //"CPF/CNPJ RDA"
aAdd(aCpos,{STR0081	,"B5T_NOMRDA"	,,,,PesqPict("B5T","B5T_NOMRDA")}) //"Nome da RDA"
aAdd(aCpos,{STR0082	,"B5T_VLRTOT"	,,,,PesqPict("B5T","B5T_VLRTOT")}) //"Vlr.Tot.Even"


cAlias := PL520QUERY("BAIXA",aCpos)

If !(cAlias)->(Eof())
	PLP520Grid(cAlias,aCpos)
Else
	Help( ,, 'HELP',,STR0044, 1, 0) //"Registros não encontrado !!!"
EndIf

If _oBaixa <> Nil
	_oBaixa:Delete()
	_oBaixa := Nil
Endif
	
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLP520Grid
Monta o Grid e Grava os dados

@author    Michel Montoro
@version   1.xx
@since     30/06/2018
/*/
//------------------------------------------------------------------------------------------
Function PLP520Grid(cAliasTRB,aCpos)

Local cTitMBrow	:= OemToAnsi(STR0071) //"Apresentação das Guias selecionadas para Baixa do Aviso (Expiração)."
Local nFor 		:= 0

Private aRotina		:= {}

aAdd(aRotina,{STR0072	,"PLSP520Env()", 0,4}) //"Enviar Baixa de Aviso"
aAdd(aRotina,{STR0073	,"PLSP520Sel(1,oMark)"	, 0,4}) //"Seleciona tudo"
aAdd(aRotina,{STR0074 	,"PLSP520Sel(2,oMark)"	, 0,4}) //"Inverter seleção"

dbSelectArea(cAliasTRB)
dbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Construcao do MarkBrowse                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMark:=FWMarkBrowse():NEW()		// Cria o objeto oMark - MarkBrowse
oMark:SetAlias(cAliasTRB)		// Define a tabela do MarkBrowse
oMark:SetDescription(cTitMBrow)	// Define o titulo do MarkBrowse
oMark:SetFieldMark("B5T_IDMARK")// Define o campo utilizado para a marcacao
oMark:SetFilterDefault("")		// Define o filtro a ser aplicado no MarkBrowse
oMark:SetFields(aCpos)			// Define os campos a serem mostrados no MarkBrowse
oMark:SetSemaphore(.F.)			// Define se utiliza marcacao exclusiva
oMark:SetWalkThru(.F.)			// Desabilita a opcao de WalkThru
oMark:DisableReport()			// Desabilita a opcao de imprimir
oMark:SetAllMark({|| fSelecAll(oMark)})
oMark:Activate()				// Ativa o MarkBrowse

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fSelecAll
Funcionalidade de selecionar tudo

@author    Michel Montoro
@version   1.xx
@since     30/06/2018
/*/
//------------------------------------------------------------------------------------------
Static Function fSelecAll(oMark,lInverte)

Local lRet		:= .T.		  	 								// Retorno da rotina.                           
Local aAreaTmp	:= (oMark:Alias())->(GetArea())	  		// Guarda a area do browse.
Local lTop 		:= .T.	  										// Posiciona no primeiro registro.
Local cMsg		:= ""

Default lInverte := .F.

If lInverte
	cMsg	:= STR0083 //"Deseja Inverter a Seleção Todos os Registros ?"
Else
	cMsg	:= STR0084 //"Deseja Selecionar Todos os Registros ?"
EndIf

If MsgYesNo(cMsg,OemToAnsi('ATENCAO'))

	(oMark:Alias())->(DbGoTop())
	While (oMark:Alias())->(!Eof())
		If lInverte
			If ( !oMark:IsMark() )
				RecLock(oMark:Alias(),.F.)
				(oMark:Alias())->B5T_IDMARK  := oMark:Mark()
				(oMark:Alias())->(MsUnLock())
			Else
				RecLock(oMark:Alias(),.F.)
				(oMark:Alias())->B5T_IDMARK  := " "
				(oMark:Alias())->(MsUnLock())
			EndIf
		Else
			RecLock(oMark:Alias(),.F.)
			(oMark:Alias())->B5T_IDMARK  := oMark:Mark()
			(oMark:Alias())->(MsUnLock())
		EndIf
		(oMark:Alias())->(DbSkip())
	EndDo
Endif

RestArea(aAreaTmp)  
oMark:Refresh(lTop)

Return( lRet )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP520Sel
Funcionalidade de Seleção

@author    Michel Montoro
@version   1.xx
@since     30/06/2018
/*/
//------------------------------------------------------------------------------------------
Function PLSP520Sel(nTipo,oMark)
Local lRet := .T.

If nTipo == 1
	fSelecAll(oMark,.F.)
ElseIf nTipo == 2
	fSelecAll(oMark,.T.)
EndIf

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP520Env
Prepara o envio da Baixa do Aviso

@author    Michel Montoro
@version   1.xx
@since     30/06/2018
/*/
//------------------------------------------------------------------------------------------
Function PLSP520Env()
Local cMarca	:= oMark:Mark()
Local aChaveBa1	:= {}

Local nTotReg	:= 0
Local nCount	:= 0
Local nGuiasEnv	:= 0
Local a530		:= {}
Local cCodOpeAvi:= ""
Local dDatConhec:= CToD("")
Local cNumLote	:= ""
Local cNumGuia	:= ""
Local cCodOpeBen:= ""
Local cMatric	:= ""
Local cCGCOpOri := ""
Local aCpfCnpj	:= {}
Local aCampos	:= {}
Local aMsgs		:= {}

dbSelectArea(cAlias)
nTotReg := Contar(cAlias,"!EoF()")
oProcess:SetRegua1( 1 ) 		//Alimenta a primeira barra de progresso
oProcess:SetRegua2( nTotReg ) 	//Alimenta a primeira barra de progresso
oProcess:IncRegua1( STR0085 ) 	//"Processando Guias de Envio com Glosa: "
(cAlias)->(DbGoTop())

While !(cAlias)->(Eof())
	If oMark:IsMark(cMarca)
		nCount++
		oProcess:IncRegua2( STR0038+" [" + StrZero(nCount,4) + "] : [" + StrZero(nTotReg,4) + "]" ) //"Processando De:"
		
		cCodOpeAvi	:= &(cAlias+"->B5T_OPEHAB")//&(cAlias+"->"+"B5T_OPEORI")
		dDatConhec	:= &(cAlias+"->B2T_DATTRA") 	//(Data do Conhecimento - Data do Envio/Rec do aviso)
		cNumLote	:= &(cAlias+"->B5T_NUMLOT")
		cCodOpeBen	:= &(cAlias+"->B5T_OPEORI")
		cMatric		:= SUBSTR( &(cAlias+"->B5T_MATRIC"),5,13)
		cCGCOpOri 	:= POSICIONE("BA0",1,xFilial("BA0")+&(cAlias+"->B5T_OPEHAB"),"BA0_CGC")
		aCpfCnpj	:= {"2",cCGCOpOri} //{"1",cCpfCnpj} 1-CPF, 2-CNPJ (Operadora Habitual é tratado como Prestador - sempre CNPJ)
		cNumGuia	:= &(cAlias+"->B5T_NMGPRE")
		
		a530 := {"2","1",cCodOpeAvi,dDatConhec,cNumLote,cNumGuia,cCodOpeBen,cMatric,aCpfCnpj}
		cRet := PLSUA530(a530,.F.)
		
		If Empty(cRet)
			//Posiciona B5T
			B5T->(DBSetorder(1)) //B5T_FILIAL+B5T_SEQLOT+B5T_SEQGUI
			If B5T->( MsSeek(&(cAlias+"->(B5T_FILIAL+B5T_SEQLOT+B5T_SEQGUI)")) )
				While ( B5T->(!eof()) .And. B5T->(B5T_FILIAL+B5T_SEQLOT+B5T_SEQGUI) == &(cAlias+"->(B5T_FILIAL+B5T_SEQLOT+B5T_SEQGUI)") )
					aCampos := {}
					aAdd( aCampos,{ "B5T_STAAVI"	,"1"	} ) //0=Nao Enviado;1=Expirado Enviado
					lRet := PLU520IGrv( 4, aCampos, 'MODEL_B5T', 'PLSP520B5T' )
					B5T->( dbSkip() )
				EndDo
			EndIf
			nGuiasEnv++			
		Else
			aAdd(aMsgs,{cNumLote,cNumGuia,cRet})
		EndIf
	EndIf
	(cAlias)->(dbSkip())
EndDo

MsgInfo(STR0042 + STRZero(nCount,8)+ STR0087 + CRLF + CRLF + STR0086 + STRZero(nGuiasEnv,8)+ STR0087) //"Foram Processados: " # "Foram Enviados: " # " Guias."

If !Empty(aMsgs)
	PLSCRIGEN(aMsgs,{ {STR0045,"@C",30},{STR0047,"@C",30},{STR0049,"@C",150} },STR0050 ) //"Num. Lote" # "Seq. Guia" # "Critica" # "RESUMO DE CRÍTICAS" 
EndIf

CloseBrowse()

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLU520IGrv
Grava os dados do Lote Guias - Tabela B2T,B5T,B6T

@author    Guilherme Carvalho
@version   1.xx
@since     30/04/2018
/*/
//------------------------------------------------------------------------------------------
Function PLU520IGrv( nOpc,aCampos,cModel,cLoadModel )
	local oAux
	local oStruct
	local oModel
	local aAux
	local aErro
	
	local nI
	local nPos
	
	local lRet := .T.
	local lAux
	
	oModel := FWLoadModel( cLoadModel )
	oModel:setOperation( nOpc )
	oModel:activate()
	
	oAux	:= oModel:getModel( cModel )
	oStruct	:= oAux:getStruct()
	aAux	:= oStruct:getFields()
	
	if( nOpc <> MODEL_OPERATION_DELETE )
		begin Transaction
			for nI := 1 to len( aCampos )
				if( nPos := aScan( aAux,{| x | allTrim( x[ 3 ] ) == allTrim( aCampos[ nI,1 ] ) } ) ) > 0
					if !( lRet := oModel:setValue( cModel,aCampos[ nI,1 ],aCampos[ nI,2 ] ) )
						aErro := oModel:getErrorMessage()
						
						autoGrLog( "Id do formulário de origem:" 	+ ' [' + AllToChar( aErro[ 1 ] ) + ']' )
						autoGrLog( "Id do campo de origem: " 		+ ' [' + AllToChar( aErro[ 2 ] ) + ']' )
						autoGrLog( "Id do formulário de erro: " 	+ ' [' + AllToChar( aErro[ 3 ] ) + ']' )
						autoGrLog( "Id do campo de erro: " 			+ ' [' + AllToChar( aErro[ 4 ] ) + ']' )
						autoGrLog( "Id do erro: " 					+ ' [' + AllToChar( aErro[ 5 ] ) + ']' )
						autoGrLog( "Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']' )
						
						mostraErro()
						disarmTransaction()
						exit
					endif
				endIf
			next nI
		end Transaction
	endIf		
	
	if( lRet := oModel:vldData() )
		oModel:commitData()
	else
		aErro := oModel:getErrorMessage()						
		autoGrLog( "Id do formulário de origem:" 	+ ' [' + AllToChar( aErro[ 1 ] ) + ']' )
		autoGrLog( "Id do campo de origem: " 		+ ' [' + AllToChar( aErro[ 2 ] ) + ']' )
		autoGrLog( "Id do formulário de erro: " 	+ ' [' + AllToChar( aErro[ 3 ] ) + ']' )
		autoGrLog( "Id do campo de erro: " 			+ ' [' + AllToChar( aErro[ 4 ] ) + ']' )
		autoGrLog( "Id do erro: " 					+ ' [' + AllToChar( aErro[ 5 ] ) + ']' )
		autoGrLog( "Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']' )
		
		mostraErro()
		disarmTransaction()
	endif
	
	oModel:deActivate()
	oModel:destroy()
	freeObj( oModel )
	oModel := nil
	delClassInf()
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSInvert
Função para marcar e desmarcar todos os itens da MarkBrowse

@author    Lucas Nonato
@version   V12
@since     26/01/2017
/*/
//------------------------------------------------------------------------------------------
Function PLSInvert(oMBrw,cAlias)
Local nReg 	 := (cAlias)->(Recno())
(cAlias)->( dbgotop() )

While !(cAlias)->(Eof())
	// Marca ou desmarca. Este metodo respeita o controle de semaphoro.
	oMBrw:MarkRec()
	(cAlias)->(dbSkip())
Enddo

(cAlias)->(dbGoto(nReg))
oMBrw:oBrowse:Refresh(.t.)

Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP520FIL
Filtro de tela

@author    Lucas Nonato
@version   V12
@since     26/01/2017
/*/
//------------------------------------------------------------------------------------------
function PLSP520FIL(lF2)

local aPergs	:= {}
local aFilter	:= {}
local cFilter 	:= ""
local cStatus	:= space(1)
local cOpeDe	:= space(4)
local cOpeAte	:= space(4)
default lF2  := .f.
aadd( aPergs,{ 1,"Operadora De:" , 	cOpeDe,"@!",'.T.','B39PLS',/*'.T.'*/,40,.f. } )
aadd( aPergs,{ 1,"Operadora Ate:", 	cOpeAte,"@!",'.T.','B39PLS',/*'.T.'*/,40,.t. } )
aAdd( aPergs,{ 1, "Data Imp De:" , 	dDataBase	, "", "", ""		, "", 50, .f.})
aAdd( aPergs,{ 1, "Data Imp Até:", 	dDataBase	, "", "", ""		, "", 50, .t.})
aadd( aPergs,{ 2, "Status:"		 , 	cStatus,{ "0=Todos","1=Aviso Importado","2=Baixa Aviso Pendente","3=Baixa Aviso Enviado","4=Lote Cancelado" },100,/*'.T.'*/,.t. } )

if( paramBox( aPergs,"Filtro de Tela",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSP520C',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
	cFilter += "@B2T_FILIAL = '" + xfilial("B2T") + "'"	
	cFilter += " AND B2T_OPEHAB >= '" + aFilter[1] + "'"	
	cFilter += " AND B2T_OPEHAB <= '" + aFilter[2] + "'"	
	cFilter += " AND B2T_DATIMP >= '" + dtos(aFilter[3]) + "'"	
	cFilter += " AND B2T_DATIMP <= '" + dtos(aFilter[4]) + "'"	
	if aFilter[5] <> "0"
		cFilter += " AND B2T_STATUS = '" + aFilter[5] + "'"	
	endif
endIf

if lF2
	oMBrwB2T:SetFilterDefault(cFilter)
	oMBrwB2T:Refresh()
endif
	
return cFilter

function PLSP520DEL
local cSql 		:= ""
local cChave 	:= ""
				
if(! msgYesNo( "Deseja excluir os registros marcados da importação do lote de avisos?" ) )
	return .f.
endIf

cSql := " SELECT B2T_OPEHAB, B2T_NUMLOT, R_E_C_N_O_ RECNO " 
cSql += " FROM " + RetSqlName("B2T") + " B2T "
cSql += " WHERE B2T_FILIAL = '" + xFilial("B2T") + "' "
cSql += " AND B2T_OK = '" + oMBrwB2T:cMark + "' "
cSql += " AND B2T.D_E_L_E_T_ = ' '  "

cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"PLEXC",.F.,.T.)	

B2T->(dbsetorder(2)) // B2T_FILIAL, B2T_OPEHAB, B2T_NUMLOT
B5T->(dbsetorder(2)) // B5T_FILIAL, B5T_OPEHAB, B5T_NUMLOT
B6T->(dbsetorder(3)) // B6T_FILIAL, B6T_OPEHAB, B6T_NUMLOT
BNT->(dbsetorder(2)) // BNT_FILIAL, BNT_OPEHAB, BNT_NUMLOT

begin transaction

while !PLEXC->(eof())

	B2T->(dbgoto(PLEXC->RECNO))
	cChave := B2T->B2T_OPEHAB + B2T->B2T_NUMLOT

	// B2T	
	IncProc("Excluindo registros " + cvaltochar(B2T->(recno())))
	B2T->(RecLock('B2T',.F.))
		B2T->(DbDelete())
	B2T->(MsUnLock())
	

	// B5T
	while B5T->(MsSeek(xFilial('B5T') + cChave)) 
		IncProc("Excluindo registros " + cvaltochar(B5T->(recno())))
		B5T->(RecLock('B5T',.F.))
			B5T->(DbDelete())
		B5T->(MsUnLock())
	enddo

	// B6T
	while B6T->(MsSeek(xFilial('B6T') + cChave)) 
		IncProc("Excluindo registros " + cvaltochar(B6T->(recno())))
		B6T->(RecLock('B6T',.F.))
			B6T->(DbDelete())
		B6T->(MsUnLock())
	enddo

	// BNT
	while BNT->(MsSeek(xFilial('BNT') + cChave)) 
		IncProc("Excluindo registros " + cvaltochar(BNT->(recno())))
		BNT->(RecLock('BNT',.F.))
			BNT->(DbDelete())
		BNT->(MsUnLock())
	enddo

	PLEXC->(dbskip())

enddo

end transaction

PLEXC->(dbclosearea())

return