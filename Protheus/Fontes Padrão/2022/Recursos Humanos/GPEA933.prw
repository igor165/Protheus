#include 'Protheus.ch'
#Include 'fwmvcdef.ch'
#include 'GPEA933.CH'

Static aEfd         := If( cPaisLoc == 'BRA', If(Findfunction("fEFDSocial"), fEFDSocial(), {.F.,.F.,.F.,.F.,.F.}), {.F.,.F.,.F.,.F.,.F.} )  //Statics com carga devido ao acesso via outros modulos destas variaveis
Static lIntTAF      := ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 ) //Integracao com TAF
Static aSocialNiv   := If( cPaisLoc == 'BRA' , If(Findfunction("fGM17Nivel"),fGM17Nivel("GPEA927"), {.F.,""}),{.F.,""})
Static lMiddleware  := If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static cVerTaf		:= StrTran(StrTran(SuperGetMv("MV_TAFVLES",, "2.4"), "_", "."), "0", "", 1, 2)
Static cVersEnvio	:= ""
Static cVersGPE		:= ""

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ão    ³ GPEA933  ³ Autor ³ Eduardo Vicente                   ³ Data ³ 07/02/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Observações contratuais para envio do esocial                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEA933()                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC            ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Eduard Vic  ³19/02/2018³DRHESOCP-3051   ³Cadastro de Observações contratuais         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPEA933()

Local oMBrowse
Local cFiltraRh     := ""
Local cTrabVincu    := fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|309" //Trabalhador com vinculo

Private cXMLS33     :=  ""
Private lNewVerEsoc := .F.

// RECEBE A VERSÃO DO TAF.
cVerTaf:= StrTran(Iif(cVerTaf == "2.4.01", "2.4", cVerTaf), "S.1", "9")

If lIntTaf .And. FindFunction("fVersEsoc") .And. FindFunction("ESocMsgVer")
	fVersEsoc("S2200", .F.,,, @cVersEnvio, @cVersGPE)			
	If !lMiddleware .And. cVersGPE <> cVersEnvio .And. (cVersGPE >= "9.0" .Or. cVersEnvio >= "9.0")
        //# "Atenção! # A versão do leiaute GPE é XXX e a do TAF é XXXX, sendo assim, estão divergentes. A rotina será encerrada"
		ESocMsgVer(.T.,/*cEvento*/, cVersGPE, cVersEnvio)
		Return ()
	EndIf
EndIf

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias("SRA")
oMBrowse:SetDescription(OemToAnsi(STR0001)) //Observações Contrato de Trabalho

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If IsInCallStack("GPEA933") .Or. FunName() =="GPEA010"
    cFiltraRh := "RA_TPCONTR == '2'"
    cFiltraRh += " .AND. RA_CATEFD $ '" + cTrabVincu + "'"
    cFiltraRh += " .AND. (Empty(RA_DEMISSA) .OR. DToC(RA_DEMISSA) >= '" + DToC(dDataBase) + "')"
EndIf

If FunName() == "GPEA010"
    cFiltraRh += "RA_MAT ="+ M->RA_MAT + "RA_CIC = "+ M->RA_CIC 
EndIf

If lMiddleware .And. !ChkFile("RJE")
	Help( " ", 1, OemToAnsi(STR0007),, OemToAnsi(STR0019), 1, 0 )//"Tabela RJE não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
	Return
EndIf	

oMBrowse:SetFilterDefault(cFiltraRh)
oMBrowse:SetLocate()
GpLegMVC(@oMBrowse)

oMBrowse:ExecuteFilter(.T.)

oMBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Definição do MenuDef
@type function
@author Eduardo
@since 07/02/2018
@version 1.0
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0003)  Action 'PesqBrw'           OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'VIEWDEF.GPEA933'   OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'VIEWDEF.GPEA933'   OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0006)  Action 'VIEWDEF.GPEA933'   OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
Definição e detalhamento do Model
@type function
@author Eduardo
@since 07/02/2018
@version 1.0
/*/
Static Function ModelDef()

Local oMdl
Local bAvalCampo    := {|cCampo| AllTrim(cCampo)+"|" $ "|RA_FILIAL|RA_MAT|RA_NOME|RA_CIC|RA_CODUNIC|"}
Local oStruSRA      := FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
Local oStruSVA      := FWFormStruct(1, 'SVA', /*bAvalCampo*/,/*lViewUsado*/)
Local bCommit       := {|oMdlSVA| f933Comm(oMdl)}
Local cFiltro       := ""
Local lVaTp         := SVA->( ColumnPos( "VA_TP")) > 0

oMdl := MPFormModel():New('GPEA933', /*bPreValid */, /*bPosValid*/, bCommit, /*bCancel*/)

oMdl:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

oMdl:AddGrid( 'SVADETAIL', 'SRAMASTER', oStruSVA, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oMdl:SetRelation('SVADETAIL', {{'VA_FILIAL', 'RA_FILIAL'}, {'VA_MATRIC', 'RA_MAT'}}, SVA->(IndexKey(1)))

If lVaTp    
    cFiltro:= FiltraGrid(cTpObs)
    oMdl:GetModel('SVADETAIL'):SetLoadFilter( {}, cFiltro)
    oMdl:GetModel('SVADETAIL'):SetUniqueLine({'VA_FILIAL','VA_ITEM','VA_MATRIC','VA_TP'})
    oMdl:GetModel('SVADETAIL'):SetMaxLine(If(cTpObs == "1", 99, 1) )
    oStruSVA:SetProperty('VA_TP',MODEL_FIELD_INIT, {||cTpObs})
Else
    oMdl:GetModel('SVADETAIL'):SetUniqueLine({'VA_FILIAL','VA_ITEM','VA_MATRIC'})
    oMdl:GetModel('SVADETAIL'):SetMaxLine(99)
Endif

//Permite grid sem dados
oMdl:GetModel('SVADETAIL'):SetOptional(.T.)
oMdl:GetModel('SRAMASTER'):SetOnlyView(.T.)
oMdl:GetModel('SRAMASTER'):SetOnlyQuery(.T.)

// Adiciona a descricao do Componente do Modelo de Dados
oMdl:GetModel('SRAMASTER'):SetDescription(OemToAnsi(STR0002)) // "Funcionários"

oMdl:SetVldActivate( { |oModel| setFilSVA(oMdl) })

Return oMdl

/*/{Protheus.doc} ViewDef
Definição da viewdef
@type method
@author Eduardo
@since 07/02/2018
@version 1.0
/*/
Static Function ViewDef()

Local oView
Local bAvalCampo    := {|cCampo| AllTrim(cCampo)+"|" $ "|RA_FILIAL|RA_MAT|RA_NOME|RA_CIC|"}
Local oModel        := FWLoadModel('GPEA933')
Local oStruSRA      := FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruSVA      := FWFormStruct(2, 'SVA')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')
oStruSRA:SetNoFolder()

oView:AddGrid('VIEW_SVA', oStruSVA, 'SVADETAIL')

//oStruSRA:RemoveField("RA_CODUNIC")
oStruSRA:RemoveField("RA_CIC")
oStruSVA:RemoveField("VA_MATRIC")

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 15)
oView:CreateHorizontalBox('INFERIOR', 85)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_SVA', 'INFERIOR')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_SRA', OemToAnsi(STR0002)) // "Funcionário"
oView:EnableTitleView('VIEW_SVA', OemToAnsi(STR0001)) // Observações Contrato de Trabalho
oView:AddIncrementField( 'VIEW_SVA', 'VA_ITEM' )

Return oView

/*/{Protheus.doc} f933Comm
Commit manual para integração com o TAF
@type function
@author Eduardo
@since 08/02/2018
@version 1.0
/*/
Static Function f933Comm(oModel)
Local lRet          := .T.
Local lContinua     := .T.
Local leSocCompl    := .F.

Local cVersEnvio    := ""
Local cStat2200     := " "
Local cStat2206     := " "
Local cFilEnv       := ""
Local cCPF          := ""
Local cCodUnico     := ""
Local cSVAObs       := ""
Local nOpcAux       := 3
Local aTpAlt        := {}
Local aErros        := {}
Local aFilInTaf     := {}
Local aArrayFil     := {}

Local oSRAMDL       := oModel:GetModel("SRAMASTER")
Local oSVAMDL       := oModel:GetModel("SVADETAIL")
//Middleware
Local aInfoC		:= {}
Local cChaveMid		:= ""
Local cNrInsc		:= ""
Local cTpInsc		:= ""
Local lAdmPubl		:= .F.
Local cStatus		:= ""

If (lInttaf .Or. lMiddleware) .And. oModel:GetOperation() != 5
    
    lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2200", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio ), .T.)
    cVersEnvio := Iif( Empty(cVersEnvio), "2.2",cVersEnvio)
    If !lMiddleware
    	fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
    Endif	
    If lIntegra
        If Empty(cFilEnv)
            cFilEnv:= cFilAnt
        EndIf
        cCodUnico:= SRA->RA_CODUNIC
        RegToMemory("SRA")
        If( Empty(cCodUnico) )
            cCodUnico:= fRACodUnic(.F.)
        EndIf
        cCPF := AllTrim( oSRAMDL:GetValue("RA_CIC")) + ";" + alltrim(cCodUnico)
        leSocCompl := fG17VSRA ("SRA",1)
        
        If leSocCompl 
            If lIntegra 
            	If !lMiddleware
            		cStat2200:= TAFGetStat( "S-2200", cCpf, cEmpAnt, cFilEnv)
            	Else
            		cStatus := "-1"
            		fPosFil( cEmpAnt, SRA->RA_FILIAL )
            		aInfoC   := fXMLInfos()
            		If LEN(aInfoC) >= 4
            			cTpInsc  := aInfoC[1]
            			lAdmPubl := aInfoC[4]
            			cNrInsc  := aInfoC[2]
            		Else
            			cTpInsc  := ""
            			lAdmPubl := .F.
            			cNrInsc  := "0"
            		EndIf
            		cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
            		cStatus 	:= "-1"			
            		//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
            		GetInfRJE( 2, cChaveMid, @cStatus )
            		cStat2200 := cStatus
            	Endif	
            	If cStat2200 == "2" 
					If !lMiddleware
						oModel:SetErrorMessage("",,oModel:GetId(),"","",OemToAnsi(STR0007)) //Em transito
					Else
						oModel:SetErrorMessage("",,oModel:GetId(),"","",OemToAnsi(STR0021)) //"Registro de admissão do funcionário em trânsito ao RET. A alteração não será efetivada."
					EndIf
					lContinua := .F.
					Return
				Else
					fStatusTAF(@aTpAlt,cStat2200,"-1",,)
				EndIf	

                If  lContinua
                    cXMLS33:= fVerSVA(oSVAMDL)
                    If cVersEnvio >= "2.5.00" .And. oSVAMDL:GetValue("VA_ITEM") == "01" .And. oSVAMDL:GetValue("VA_TP") == "2"
                    	cSVAObs := ALLTRIM(oSVAMDL:GetValue("VA_OBSERV"))
                    Else
                    	cSVAObs := ""
                    Endif
                    
                    If aTpAlt[3]
                        aTpAlt:= {} 
                        //cStat2206:= TAFGetStat( "S-2206", cCpf+";"+DtoS(dDataBase)+";"+ Space(Len(DtoS(dDataBase)))+";", cEmpAnt, cFilEnv)
                        //fStatusTAF(@aTpAlt,cStat2206,"-1",,)
                        fCheckStat(cCPF,cFilEnv,,@aTpAlt) 
                        If aTpAlt[3] 
                            lRet:=  fInt2206("SRA",/*lAltCad*/,4,"S2206",/*cTFilial*/,/*dtEf*/,/*cTurno*/,/*cRegra*/,/*cSeqT*/,/*oModel*/,cVersEnvio,,,,,,,,, cSVAObs)
                        ElseIf aTpAlt[1] .Or. aTpAlt[2]
                            lRet:=  fInt2206("SRA",/*lAltCad*/,3,"S2206",/*cTFilial*/,/*dtEf*/,/*cTurno*/,/*cRegra*/,/*cSeqT*/,/*oModel*/,cVersEnvio,,,,,,,,, cSVAObs)
                        EndIf
                    ElseIf aTpAlt[1] .Or. aTpAlt[2]
                        lRet:=  fIntAdmiss("SRA",/*lAltCad*/,nOpcAux,"S2200",/*cTFilial*/,/*aDep*/,alltrim(SRA->RA_CODUNIC),/*oModel*/, "ADM", @aErros, cVersEnvio,,,,,,,,,,,,,,,,,, cSVAObs)
                    EndIf
                
                    If lRet .And. FindFunction("fEFDMsg") .And. CVALTOCHAR(nOpcAux) $ "3/4"
                       fEFDMsg()
                    EndIf
                EndIf
            EndIf
        Else                        
        	oModel:SetErrorMessage("",,oModel:GetId(),oEmtoAnsi(STR0007),oEmtoAnsi(STR0007), oEmtoAnsi(STR0009))
        	lRet := .F.
        EndIf
    EndIf
Endif

If lRet .And. lContinua
    FWFormCommit(oModel)
Else
	If !lMiddleware
		oModel:SetErrorMessage("",,oModel:GetId(),oEmtoAnsi(STR0007),oEmtoAnsi(STR0007), oEmtoAnsi(STR0010))//"Não foi possivel realizar a integração com o TAF!"///"Não foi possivel realizar a integração com o Middleware"
	Else
		oModel:SetErrorMessage("",,oModel:GetId(),oEmtoAnsi(STR0007),oEmtoAnsi(STR0007), oEmtoAnsi(STR0020))//"Não foi possivel realizar a integração com o Middleware"
	Endif	
Endif

Return lRet

/*/{Protheus.doc} fVerSVA
Função responsável pela montagem da string xml de observações
@type function
@author Eduardo
@since 14/02/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
/*/
Function fVerSVA(oMdl, lRedMp936, dIniRed, dFimRed)
Local nLines    := 0
Local nI        := 0
Local cXMLSVA      := ""
Local aAreaSRA  := SRA->(GetArea())
Local aAreaSVA  := SVA->(GetArea())

default oMdl        := NIL
default lRedMp936   := .F.
default dIniRed     := cToD("//")
default dFimRed     := cToD("//")

cXMLSVA := ""

If oMdl != NIL
    nLines    := oMdl:Length()
    For nI := 1 To nLines 
        oMdl:GoLine( nI )
        If !oMdl:IsDeleted()
           cXMLSVA  += "<observacoes><observacao>"+Alltrim(oMdl:GetValue("VA_OBSERV"))+"</observacao></observacoes>"
        Else
           cXMLSVA  += "<observacoes></observacoes>"  
        EndIf
    Next nI
Else
    dbSelectArea("SVA")
    SVA->(dbSetOrder(1))//VA_FILIAL+VA_MATRIC
    If SVA->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT))
        While SVA->(!EOF()) .And. SVA->(VA_FILIAL+VA_MATRIC)==(SRA->RA_FILIAL+SRA->RA_MAT) 
            If (lRedMp936 .And. !empty(dIniRed) .And. dToc(dIniRed) $ AllTrim(SVA->VA_OBSERV) .And. (Empty(dFimRed) .Or. dToc(dFimRed) $ AllTrim(SVA->VA_OBSERV) )) .Or. !(STR0022 $ AllTrim(SVA->VA_OBSERV))//"Data de início da redução: "
                cXMLSVA  += "<observacoes><observacao>"+Alltrim(SVA->VA_OBSERV)+"</observacao></observacoes>"
            EndIf
            SVA->(DBSKIP())
        EndDo
    EndIf
EndIf
If !Empty(cXMLSVA)
   cXMLSVA:= ""+cXMLSVA+"" 
EndIf
RestArea(aAreaSRA)
RestArea(aAreaSVA)
Return cXMLSVA
/*/{Protheus.doc} fCheckStat
Função para checagem de status de evento, para envio da tag ideevento
@type
@author Eduardo
@since 16/05/2018
@version 1.0
@param cCPF, STRING, CPF DO PARTICIPANTE
@param cFilEnv, STRING, FILIAL DE ENVIO PARA O TAF
@param dDtAlt, DATE, DATA DA ALTERAÇÃO DO CADASTRO
/*/
Function fCheckStat(cCPF,cFilEnv,dDtAlt,aTpAlt)
Local cStat2206 := ""
Local lRet      := .T.

Local aErros    := {}

Local aStatus   := {    {'','[Aguardando validação do TAF.]'},;
	                   {'0','[Registro validado pelo TAF - Aguardando transmissão ao Governo.]'},;
	                   {'1','[Registro com inconsistências encontradas pelo TAF - Não será enviado ao Governo.]'},;
	                   {'2','[Registro já transmitido ao Governo, aguardando retorno.]'},;
	                   {'3','[Registro com inconsistências retornadas pelo Governo.]'},;
	                   {'4','[Registro transmitido ao Governo com retorno consistente.]'},;
	                   {'6','[Exclusão transmitida ao Governo, aguardando retorno.]'},;
	                   {'7','[Exclusão transmitida ao Governo com retorno consistente.]'}}
default aTpAlt  := {.F.,.F.,.F.,.F.}
default cCPF    := ""
default cFilEnv := ""
default dDtAlt  := DDATABASE
 

cStat2206:= TAFGetStat( "S-2206", cCPF+";"+DtoS(dDtAlt)+";"+ Space(Len(DtoS(dDtAlt)))+";", cEmpAnt, cFilEnv)

fStatusTAF(@aTpAlt,cStat2206,"-1",,)
If (aTpAlt[1] .And.  "["+cStat2206 $ "[-1") 
    cIndRetif   := ""
ElseIf aTpAlt[1] .Or. aTpAlt[2] .Or. (aTpAlt[3] .And. cStat2206 == "4")
    cIndRetif   :=  "<ideEvento><indRetif>2</indRetif></ideEvento>"
EndIf

If Alltrim(cStat2206) $ '2'
    aAdd(aErros, "Acesse o TAF e verifique os dados do registro no módulo, pois o mesmo se encontra com status: " + CRLF +aStatus[aScan( aStatus, { |x| x[1] == Alltrim(cStat2206) }),2])
    lRet:= .F.
EndIf
Return aErros

/*/{Protheus.doc} fObsSVA
Funcao para exibição de alerta e link para o TDN ao incluir/alterar uma verba
@author Claudinei Soares
@since 29/11/2018
@version 1.0
@return Nil
/*/

Function fObsSVA()

Local aItems        := {}
Local oDlg			:= NIL
Local oRadio		:= NIL
Local nSelect       := 1

Static cTpObs       := ""

    DEFINE DIALOG oDlg TITLE OemToAnsi(STR0011) FROM 10, 10 TO 170, 450 PIXEL STYLE DS_MODALFRAME //Selecione de Observação
    oDlg:lEscClose := .F. 
    
    @ 10, 10 SAY  OemToAnsi(STR0012) SIZE 220,10 PIXEL //""Favor selecionar o tipo de observação:"
    aItems := {OemToAnsi(STR0013),OemToAnsi(STR0014)} // 1 - Observação do contrato de trabalho , 2 - Objeto da contratação - Prazo determinado
    oRadio := TRadMenu():New (30,10,aItems,/*bSetGet*/,oDlg,/*uParam6*/,/*bChange*/, /*nClrText*/,/*nClrPane*/,OemToAnsi(STR0012),/*uParam11*/,/*bWhen*/,150,30;												
                    ,/*bValid*/,/*uParam16*/,/*uParam17*/,/*lPixel*/,/*lHoriz*/,.T.)
    
    oRadio:bSetGet := {|u| IIF (PCount()==0, nSelect, nSelect := u)}

    @ 60,110 BUTTON oBtn PROMPT OemToAnsi(STR0015) SIZE 50, 15 PIXEL OF oDlg ACTION ( cTpObs := cValToChar(nSelect), oDlg:End()) //Confirmar
    @ 60,165 BUTTON oBtn PROMPT OemToAnsi(STR0018) SIZE 50, 15 PIXEL OF oDlg ACTION ( cTpObs := "0", oDlg:End()) //Cancelar
        
    ACTIVATE DIALOG oDlg CENTERED

Return (cTpObs)

/*/{Protheus.doc} FiltraGrid
Faz o filtro do cadastro de observações de acordo com a opção escolhida
@author claudinei.soares
@since 29/11/2018
@param cTpObs, characters, Opção escolhida, 1 para Observação do contrato de trabalho, 2 para Objeto da contratação - prazo determinado

/*/
Static Function FiltraGrid(cTpObs)

	Local cFiltro   := ""
	Local cFilVa    := SRA->RA_FILIAL
    Local cMatVa    := SRA->RA_MAT
    Local lVaTp     := SVA->( ColumnPos( "VA_TP")) > 0

    Default cTpObs  := "1"

    If lVaTp
        cFiltro := "SELECT * FROM " + RetSQLName("SVA") + " WHERE ( (VA_TP =  '" + cTpObs + "' OR VA_TP = '' ) AND "
        cFiltro += " VA_FILIAL = '" + cFilVa +"'  AND VA_MATRIC = '" + cMatVa + "' ) "
    Else
        cFiltro := "SELECT * FROM " + RetSQLName("SVA") + " WHERE ( VA_FILIAL = '" + cFilVa +"'  AND VA_MATRIC = '" + cMatVa + "' ) "
    Endif

	cFiltro := ChangeQuery(cFiltro)
	cFiltro := SubStr(cFiltro, At("(", cFiltro))
	
Return cFiltro

/*/{Protheus.doc} setFilSVA
Funcao que aplica o filtro no grid da tabela SVA de acordo com o tipo escolhido(VA_TP)
@author martins.marcio
@since 19/07/2021
@version 1.0
@return .T.
/*/
Static Function setFilSVA(oModel)
    
    Local cFiltro := ""
    Local lVaTp   := SVA->( ColumnPos( "VA_TP")) > 0

    If lVaTp .And. FunName() == "GPEA933"
        fObsSVA()
        cFiltro:= FiltraGrid(cTpObs)
        oModel:GetModel('SVADETAIL'):SetLoadFilter( {}, cFiltro)
        oModel:GetModel('SVADETAIL'):SetMaxLine(If(cTpObs == "1", 99, 1) )
    EndIf

Return .T.
