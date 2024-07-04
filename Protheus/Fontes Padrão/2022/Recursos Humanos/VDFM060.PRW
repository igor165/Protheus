#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#include "VDFM060.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ VDFM060  ³ Autor  ³ Everson. S P Junior      	³ Data ³ 26/11/2013 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Certidão de Tempo de Contribuição	                         		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFM060()                                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Marcos Pereira³09/12/14³Prj. M_RH001     ³-GSP-Ajustes na fGetLicencas p/tratar     ³±±
±±³              ³        ³                 ³ corretamente a data inicial e final      ³±±
±±³Joao Balbino  ³23/03/16³TUSX72          ³-   -Ajustes na nas verbas de contrib.    ³±±
±±³              ³        ³                 ³ Previdenciaria                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±³±±
/*/

//-------------------------------------------------------------------
/*/{Protheus.doc} VDFM060
Certidão de Tempo de Contribuição
@owner Tania Bronzeri
@author Tania Bronzeri
@since 05/12/2013
@version P11
@project M_RH001 - Gestão De Pessoas e Vida Funcional Ministério Público do Estado de Mato Grosso.
@history 23/03/2016, Joao Balbino, TUSX72 - Ajustes nas verbas de Contribuição Previdenciária.
/*/
//-------------------------------------------------------------------
Function VDFM060()
Local oBrowse
Private oDlg
Private cVdCert1	:= SuperGetMv("MV_VDCERT1",,"")
Private cVdCert2	:= SuperGetMv("MV_VDCERT2",,"")
Private cVdCert3	:= SuperGetMv("MV_VDCERT3",,"")
Private cVdCert4	:= SuperGetMv("MV_VDCERT4",," - MPE")
Private cVdCert5	:= SuperGetMv("MV_VDCERT5",,"/MT")
Private cOFC		:= ""

PtSetAcento(.t.)

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SRA')
oBrowse:SetDescription(STR0001)//'''Certidão de Tempo de Contribuição'
oBrowse:SetFilterDefault( "RA_CATFUNC $ '0,1,2,3,5,6'")
oBrowse:DisableDetails()
oBrowse:Activate()
PtSetAcento(.f.)
Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002	ACTION 'VIEWDEF.VDFM060()'     OPERATION 4 ACCESS 0 //Solicitação / Emissão

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSRA	:= FWFormStruct( 1, 'SRA', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruRIE	:= FWFormStruct( 1, 'RIE', /*bAvalCampo*/,/*lViewUsado*/ )   //Solicitação da Certidão
Local oStruRIF	:= FWFormStruct( 1, 'RIF', /*bAvalCampo*/,/*lViewUsado*/ )   //RIE, RIF, RIG e RIH
Local oStruRIG	:= FWFormStruct( 1, 'RIG', /*bAvalCampo*/,/*lViewUsado*/ )   //RIE, RIF, RIG e RIH
Local oStruRIH	:= FWFormStruct( 1, 'RIH', /*bAvalCampo*/,/*lViewUsado*/ )   //RIE, RIF, RIG e RIH
Local oModel
Local cRaCpLib		:= "RA_FILIAL,RA_MAT,RA_NOMECMP,"
Local cRieCpLib	:= "RIE_FILIAL,RIE_MAT,"


SX3->(DbSetOrder(1))
SX3->(MsSeek("SRA"))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SRA"
	If (!Alltrim(SX3->X3_CAMPO)+',' $ cRaCpLib)
		If X3USO(SX3->X3_USADO)
			oStruSRA:SetProperty(Alltrim(SX3->X3_CAMPO), MODEL_FIELD_OBRIGAT, .F. )
		EndIF
		oStruSRA:RemoveField(Alltrim(SX3->X3_CAMPO))
 	EndIf
	SX3->(dbSkip())
EndDo

SX3->(DbSetOrder(1))
SX3->(MsSeek("RIE"))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "RIE"
	If (Alltrim(SX3->X3_CAMPO)+',' $ cRieCpLib)
		If X3USO(SX3->X3_USADO)
			oStruRIE:SetProperty(Alltrim(SX3->X3_CAMPO), MODEL_FIELD_OBRIGAT, .F. )
		EndIF
 	EndIf
	SX3->(dbSkip())
EndDo


oStruRIE:SetProperty("RIE_DTSOLI",MODEL_FIELD_WHEN,{||iif((cOFC:=Posicione("RIE",1,SRA->(RA_FILIAL+RA_MAT),"RIE_CERNUM"))<>"000000".and.!empty(cOFC),.f.,.t.) })
oStruRIE:SetProperty("RIE_FINALI",MODEL_FIELD_WHEN,{||iif((cOFC:=Posicione("RIE",1,SRA->(RA_FILIAL+RA_MAT),"RIE_CERNUM"))<>"000000".and.!empty(cOFC),.f.,.t.) })
oStruRIE:SetProperty("RIE_ORGDES",MODEL_FIELD_WHEN,{||iif((cOFC:=Posicione("RIE",1,SRA->(RA_FILIAL+RA_MAT),"RIE_CERNUM"))<>"000000".and.!empty(cOFC),.f.,.t.) })
oStruSRA:SetProperty("RA_NOMECMP",MODEL_FIELD_WHEN,{||.f.})


// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('VDFM060M', /*bPreValidacao*/, {|oModel|VDFVLDRIE(oModel)}, { |oModel| VD060GRVMD(oModel) }, /*bCancel*/ )

oModel:SetOperation(MODEL_OPERATION_INSERT)
If RIE->(DbSeek(SRA->(RA_FILIAL + RA_MAT)))
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
EndIf

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'SRAMASTER', /*cOwner*/, oStruSRA, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddFields( 'RIEDETAIL', 'SRAMASTER', oStruRIE, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVld*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'RIEDETAIL', { { 'RIE_FILIAL', 'RA_FILIAL' }, { 'RIE_MAT', 'RA_MAT' } }, RIE->(IndexKey( 1 ) ) )
oModel:SetPrimaryKey({"RIE_FILIAL", "RIE_MAT"})

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0003) //Solicitação das Certidão de Tempo de Contribuição

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'SRAMASTER' ):SetDescription(STR0001) //'Certidão de Tempo de Contribuição'

//Permissão de grid sem dados
oModel:GetModel( 'RIEDETAIL' ):SetOptional( .T. )

oModel:SetActivate({|oMdl|MA060Act(oMdl)})

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA060Act  º Autor ³ Wagner Mobile Costa   º Data ³ 08/07/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Bloco executado ao iniciar o formulario MVC para inclusao,  º±±
±±º          ³alteracao, exclusao e visualizacao.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³VDFM060                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MA060Act(oModel)

Local oModelRIE := oModel:GetModel( 'RIEDETAIL' ), aArea := GetArea(), aAreaSM0 := SM0->(GetArea()), cValue := ""

// Dados do primeiro responsável pela assinatura - Certidão
If Empty(oModelRIE:GetValue("RIE_NOMDGP"))
	oModelRIE:SetValue("RIE_NOMDGP",AllTrim(vGetMv(cFilAnt, "MV_VNOMDGP", "")))
EndIf
If Empty(oModelRIE:GetValue("RIE_CRGDGP"))
	oModelRIE:SetValue("RIE_CRGDGP",AllTrim(vGetMv(cFilAnt, "MV_VCRGDGP", "")))
EndIf
If Empty(oModelRIE:GetValue("RIE_DEPTOR"))
	oModelRIE:SetValue("RIE_DEPTOR",AllTrim(vGetMv(cFilAnt, "MV_VDDEPRC", "")))
EndIf
If Empty(oModelRIE:GetValue("RIE_ENDR"))
	DbSelectArea("SM0")
	Set Filter to M0_CODIGO == cEmpAnt .And. M0_CODFIL == Left(SRA->RA_FILIAL + Space(Len(SM0->M0_CODFIL)), Len(SM0->M0_CODFIL))
	DbGoTop()

	cValue := AllTrim(SM0->M0_ENDENT)
	If ! Empty(AllTrim(SM0->M0_BAIRENT))
		cValue += "-" + AllTrim(SM0->M0_BAIRENT)
	EndIf
	If ! Empty(SM0->M0_TEL)
		cValue += ", FONE: " + AllTrim(SM0->M0_TEL)
	EndIf
	oModelRIE:SetValue("RIE_ENDR",cValue)

	Set Filter To
	RestArea(aAreaSM0)
	RestArea(aArea)
EndIf
If Empty(oModelRIE:GetValue("RIE_MAILR"))
	oModelRIE:SetValue("RIE_MAILR", AllTrim(vGetMv(cFilAnt, "MV_VDMAIRC", "")))
EndIf

// Dados do segundo responsável pela assinatura - Certidão
If Empty(oModelRIE:GetValue("RIE_NOMDIR"))
	oModelRIE:SetValue("RIE_NOMDIR",AllTrim(vGetMv(cFilAnt, "MV_VNOMDIR", "")))
EndIf
If Empty(oModelRIE:GetValue("RIE_CRGDIR"))
	oModelRIE:SetValue("RIE_CRGDIR",AllTrim(vGetMv(cFilAnt, "MV_VCRGDIR", "")))
EndIf

// Dados do terceiro responsável pela assinatura - Certidão
If Empty(oModelRIE:GetValue("RIE_NOMPGJ"))
	oModelRIE:SetValue("RIE_NOMPGJ",AllTrim(vGetMv(cFilAnt, "MV_VNOMPGJ", "")))
EndIf
If Empty(oModelRIE:GetValue("RIE_CRGPGJ"))
	oModelRIE:SetValue("RIE_CRGPGJ",AllTrim(vGetMv(cFilAnt, "MV_VCRGPGJ", "")))
EndIf

// Dados do primeiro responsável pela assinatura - Relação dos Subsidios
If Empty(oModelRIE:GetValue("RIE_NOMSB1"))
	oModelRIE:SetValue("RIE_NOMSB1",AllTrim(vGetMv(cFilAnt, "MV_VDFNSB1", "")))
EndIf
If Empty(oModelRIE:GetValue("RIE_CRGSB1"))
	oModelRIE:SetValue("RIE_CRGSB1",AllTrim(vGetMv(cFilAnt, "MV_VDFCSB1", "")))
EndIf

// Dados do segundo responsável pela assinatura - Relação dos Subsidios
If Empty(oModelRIE:GetValue("RIE_NOMSB2"))
	oModelRIE:SetValue("RIE_NOMSB2",AllTrim(vGetMv(cFilAnt, "MV_VDFNSB2", "")))
EndIf
If Empty(oModelRIE:GetValue("RIE_CRGSB2"))
	oModelRIE:SetValue("RIE_CRGSB2",AllTrim(vGetMv(cFilAnt, "MV_VDFCSB2", "")))
EndIf

Return(.T.)


//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel( 'VDFM060' )
Local oStruSRA := FWFormStruct( 2, 'SRA' )
Local oStruRIE := FWFormStruct( 2, 'RIE' )
Local oView
Local cRaCpLib		:= 	"RA_FILIAL,RA_MAT,RA_NOMECMP,"
Local cRieCpLib	:= 	"RIE_DTSOLI,RIE_FINALI,RIE_ORGDES,RIE_NOMDGP,RIE_CRGDGP,RIE_DEPTOR,RIE_ENDR,RIE_MAILR,RIE_NOMDIR,RIE_CRGDIR,RIE_NOMPGJ," +;
						"RIE_CRGPGJ,RIE_NOMSB1,RIE_CRGSB1,RIE_NOMSB2,RIE_CRGSB2,RIE_NROBO,RIE_DATABO,"
Local lVia2		:= .F.
Local lVia1		:= .F.
SX3->(DbSetOrder(1))
SX3->(MsSeek("SRA"))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SRA"
	If (!Alltrim(SX3->X3_CAMPO)+',' $ cRaCpLib)
		If X3USO(SX3->X3_USADO)
			oStruSRA:SetProperty(Alltrim(SX3->X3_CAMPO), MODEL_FIELD_OBRIGAT, .F. )
		EndIF
		oStruSRA:RemoveField(Alltrim(SX3->X3_CAMPO))
 	EndIf
	SX3->(dbSkip())
EndDo

SX3->(MsSeek("RIE"))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "RIE"
	If (!Alltrim(SX3->X3_CAMPO)+',' $ cRieCpLib)
		If X3USO(SX3->X3_USADO)
			oStruRIE:SetProperty(Alltrim(SX3->X3_CAMPO), MODEL_FIELD_OBRIGAT, .F. )
		EndIF
		oStruRIE:RemoveField(Alltrim(SX3->X3_CAMPO))
 	EndIf
	SX3->(dbSkip())
EndDo

oStruSRA:RemoveField( 'SRA_FILIAL' )
oStruSRA:RemoveField( 'SRA_MAT' )
oStruRIE:RemoveField( 'RIE_MAT' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_SRA', oStruSRA, 'SRAMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddField( 'VIEW_RIE', oStruRIE,  'RIEDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SERVIDOR' , 15 )
oView:CreateHorizontalBox( 'AVERBACS' , 85 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_SRA', 'SERVIDOR' )
oView:SetOwnerView( 'VIEW_RIE', 'AVERBACS' )

// Cria Ações Relacionadas
oView:AddUserButton('Impr.p/Análise'   ,"CLIPS",{|oView| VDANL060(oView,"ANL","1"),oView:Refresh()})
oView:AddUserButton('Impressão Oficial',"CLIPS",{|oView| VDANL060(oView,"OFC","1"),oView:Refresh()})

oView:AddUserButton('Reimpressão'      ,"CLIPS",{|oView| VDFMREIMP(oView,"OFC","REIMPRESSÃO"),oView:Refresh()})
oView:AddUserButton('Impr. 2ª via'     ,"CLIPS",{|oView| VDFMREIMP(oView,"OFC","2"),oView:Refresh()})
oView:AddUserButton('Texto Certificado',"CLIPS",{|oView| VDA060CFG()})

//oView:SetCloseOnOk({||.T.})
//oView:Refresh()

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} VDANL060
Impressão para analise e Impressão Oficial
@owner Tania Bronzeri
@author Tania Bronzeri
@since 05/12/2013
@version P11
@project M_RH001 - Gestão De Pessoas e Vida Funcional Ministério Público do Estado de Mato Grosso
/*/
//-------------------------------------------------------------------
Function VDANL060(oView,cTipo,cVia)
Local aArea		:= GetArea()
Local oModel 		:= FWModelActive()
Local cRaFilial	:= oView:GetValue("SRAMASTER","RA_FILIAL")
Local cRaMat		:= oView:GetValue("SRAMASTER","RA_MAT")
Local cNumCert		:= "000000"
Local lOk			:= .T.
Local cIMPPORC	:= SuperGetMv("MV_IMPPORC",,"")

cOFC := Posicione("RIE",1,cRaFilial+cRaMat,"RIE_CERNUM")

If Empty(cIMPPORC)
	MsgAlert(STR0004 + ;  //"Deve ser Configurado o Parâmentro 'MV_IMPPORC'. Seu conteúdo será impresso no campo  MÊS "
	STR0004)             //"do Relatorio de Relação dos Subsidios de Contribuições para informar os percentuais do desconto de previdencia."
	Return
EndIf
IF	!Empty(cOFC) .AND. cOFC <> "000000"
	MsgAlert(STR0006) //"Permitido apenas 'Reimpressão' e 'Impr. 2ª via'"
	RestArea(aArea)
	Return
EndIf
If !VDFVLDRIE(oModel)
	RestArea(aArea)
	Return
EndIf

Iif(cTipo=="OFC",Eval({||IIF(VldPublic(cRaFilial,cRaMat),lOk := .T.,lOk := .F.)}),lOk := .T.)

If lOk
	MsAguarde({|| VD060GRVMD(oModel,cTipo) }, OemToAnsi(STR0007),OemToAnsi(STR0056) ,.T.) //'Certidão de Tempo de Contribuição','Gravando os dados da certidão ...'

	MsAguarde({|| VDFR060(cRaFilial,cRaMat,RIE->RIE_CERNUM,cTipo,cVia) }, OemToAnsi(STR0007),OemToAnsi(STR0008),.T.)	//'Certidão de Tempo de Contribuição','Montando a certidão ...'

	MsAguarde({|| VDFR060A(cRaFilial,cRaMat,cVia) }, OemToAnsi(STR0007), OemToAnsi(STR0009),.T.) //Certidão de Tempo de Contribuição','Montando a relação de subsidios ...
EndIf

RestArea(aArea)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} VDFMREIMP
função para Reimpressão' e 'Impr. 2ª via
@owner Tania Bronzeri
@author Tania Bronzeri
@since 05/12/2013
@version P11
@project M_RH001 - Gestão De Pessoas e Vida Funcional Ministério Público do Estado de Mato Grosso
/*/
//-------------------------------------------------------------------
Function VDFMREIMP(oView,cTipo,cVia)
Local aArea			:= GetArea()
Local lok			:= .T.
Local oModel 		:= FWModelActive()
Local cRaFilial		:= oView:GetValue("SRAMASTER","RA_FILIAL")
Local cRaMat		:= oView:GetValue("SRAMASTER","RA_MAT")
Local lNumBO		:= IIF(Alltrim(oView:GetValue("RIEDETAIL","RIE_NROBO"))== "",.T.,.F.)
Local lDatBO		:= IIF(oView:GetValue("RIEDETAIL","RIE_DATABO")== cTod("  /  /    "),.T.,.F.)
Local cIMPPORC		:= SuperGetMv("MV_IMPPORC",,"")

cOFC	:= Posicione("RIE",1,cRaFilial+cRaMat,"RIE_CERNUM")

If Empty(cIMPPORC)
	MsgAlert(STR0004 + ;    //"Deve ser Configurado o Parâmentro 'MV_IMPPORC'. Seu conteúdo será impresso no campo  MÊS "
	STR0005 )  //"do Relatorio de Relação dos Subsidios de Contribuições para informar os percentuais do desconto de previdencia."
	Return
EndIf
IF	Empty(cOFC) .Or. cOFC == "000000"
	MsgAlert(STR0010) //"Impressão Oficial não realizada!"
	lOk := .F.
ElseIf	 cVia == "2" .AND. (lNumBO .Or. lDatBO)
	MsgAlert(STR0011)  //"Para impressão da 2ª Via da Certidão de Tempo de Contribuição é necessária a informação do Boletim de Ocorrência."
	lOk := .F.
EndIf

If "REI" $ cVia .AND. lOk
	If RIE->(DbSeek(cRaFilial+cRaMat))
		RIE->(RecLock( "RIE",.F., .F.))
		RIE->RIE_REIMPR := dDataBase
		RIE->(MsUnlock())
	EndIf
ElseIf cVia == "2" .AND. lOk
	If RIE->(DbSeek(cRaFilial+cRaMat))
		RIE->(RecLock( "RIE",.F., .F.))
		RIE->RIE_SEGVIA := dDataBase
		RIE->RIE_NROBO  := oView:GetValue("RIEDETAIL","RIE_NROBO")
		RIE->RIE_DATABO := oView:GetValue("RIEDETAIL","RIE_DATABO")
		RIE->(MsUnlock())
	EndIf
EndIf

If lOk
	MsAguarde({|| VDFR060(cRaFilial,cRaMat,RIE->RIE_CERNUM,cTipo,cVia) }, OemToAnsi(STR0007), OemToAnsi(STR0008),.T.)	//'Certidão de Tempo de Contribuição','Montando a certidão ...'

	MsAguarde({|| VDFR060A(cRaFilial,cRaMat,cVia) }, OemToAnsi(STR0007),OemToAnsi(STR0009) ,.T.) 	//'Certidão de Tempo de Contribuição','Montando a relação de subsidios ...'

EndIf

RestArea(aArea)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} VDANL060
Configuração do texto do certificado
@owner Wagner Mobile Costa
@author Wagner Mobile Costa
@since 17/07/2014
@version P11
@project M_RH001 - Gestão De Pessoas e Vida Funcional Ministério Público do Estado de Mato Grosso
/*/
//-------------------------------------------------------------------
Function VDA060CFG()

Local aAdvSize			:= {}
Local aInfoAdvSize	:= {}
Local aObjSize			:= {}
Local aObjCoords		:= {}
Local lRet 			:= .F., nFiles := 0
Local bOk      		:= {|| (lRet := UpdText(oText, aData), oDlg:End()) }
Local bCancel			:= {|| oDlg:End()}, oDlg, aFolder := { 'Texto Certificado', '' }, cVar := ""
Local aData            := { "" }, nFolder := 1, oText := {}
Local aFiles 			:= { 	"\inicializadores\vdfm060_cer.ini" }

If ! File(aFiles[1])
	WriteCer(aFiles[1])
EndIf

For nFolder := 1 To Len(aData)
	If File(aFiles[nFolder])
		aData[nFolder] := LoadFile(aFiles[nFolder])
	EndIf
Next

Begin Sequence

aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE MSDIALOG oDlg TITLE STR0012;    //Edição Modelo
		FROM aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

oFolder := TFolder():New( 0, 0, aFolder, aFolder, oDlg,,,, .T.,,oDlg:NCLIENTWIDTH/2,(oDlg:NCLIENTHEIGHT/2))
oFolder:bSetOption := { |x| If(x = Len(aFolder), .F., .T.) }

For nFolder := 1 To Len(aFolder)
    cVar := ""
	If nFolder <= Len(aData)
		cVar := aData[nFolder]
	EndIf
	Aadd(oText, tSimpEdit():New( , , , , "",  cVar, 2, .F., .F.,oFolder:aDialogs[nFolder]))

	oText[Len(oText)]:oSimpEdit:TextFamily("Courier New")
	oText[Len(oText)]:oSimpEdit:TextSize(12)
	oText[Len(oText)]:oSimpEdit:Load(cVar)
Next

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)

End Sequence

If lRet
	For nFolder := 1 To Len(aFiles)
		If Empty(aData[nFolder])
			Delete File (aFiles[nFolder])
		Else
			nHandle := FCreate(aFiles[nFolder])
			FWrite(nHandle, aData[nFolder] + CRLF)
			FClose(nHandle)
		EndIf
	Next
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ UpdText  ³ Autor ³ Wagner Mobile Costa   ³ Data ³  13.06.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Atualiza as informações do objeto text para gravação        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ UpdText()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function UpdText(oText, aData)

Local nPos := 1

For nPos := 1 To Len(aData)
	aData[nPos] := oText[nPos]:GetText()
	If oText[nPos]:GetText() == oText[Len(oText)]:GetText()
		aData[nPos] := ""
	EndIf
Next

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LoadFile ³ Autor ³ Wagner Mobile Costa   ³ Data ³  13.06.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Carrega o arquivo de modelo da portaria                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LoadFile()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function LoadFile(cFileOpen)

Local cBuffer := ""

FT_FUSE(cFileOpen)         //ABRIR
FT_FGOTOP()                //PONTO NO TOPO

While !FT_FEOF()
	IncProc()
	cbuffer  := cbuffer+ FT_FREADLN()
	FT_FSKIP()
endDo
FT_FUSE()


Return(cbuffer)


//-------------------------------------------------------------------
/*/{Protheus.doc} VD060GRVMD
Grava a Impressão antes de imprimir.
@owner Tania Bronzeri
@author Tania Bronzeri
@since 05/12/2013
@version P11
@project M_RH001 - Gestão De Pessoas e Vida Funcional Ministério Público do Estado de Mato Grosso
/*/
//-------------------------------------------------------------------
Function VD060GRVMD(oModel,cTpImpr)
Local aAreaSRA		:= GetArea("SRA")
Local cRaFilial	:= oModel:GetValue("SRAMASTER","RA_FILIAL")
Local cRaMat	   	:= oModel:GetValue("SRAMASTER","RA_MAT")
Local oModelRIE 	:= oModel:GetModel( 'RIEDETAIL' )
Local cDesCargo	:= ""
Local cDesFunc		:= ""
Local cDesDepto	:= ""
Local cTxtCer		:= ""
Local cCerNum		:= "000000"
Local nTmpBru		:= 0
Local nFalJus		:= 0
Local nFalNJu		:= 0
Local nLicenc		:= 0
Local nSuspen		:= 0
Local nOutras		:= 0
Local nSoma		:= 0
Local nTmpLiq		:= 0
Local nTmpAvr		:= 0
Local nTmpFLi		:= 0
Local aInfo		:= {}
Local aSessoes		:= {}
Local lExistOFC 	:= .f.
Default cTpImpr	:= ""

//Se cTpImpr está vazio, entao foi chamado pelo botao Confirmar
If empty(cTpImpr)
	If (cOFC	:= Posicione("RIE",1,cRaFilial+cRaMat,"RIE_CERNUM")) <> '000000' .and. !empty(cOFC)
		lExistOFC := .t.
	EndIf
EndIf

DbSelectArea("SRA")
DbSetOrder(1)

If DbSeek(cRaFilial+cRaMat)
	//Se chamado por algum botao de impressao (analise ou oficial)  ou  se botão CONFIRME e não existe oficial
	If !empty(cTpImpr) .or.  !lExistOFC

		cDesCargo	:= fDesc("SQ3",SRA->RA_CARGO  ,"Q3_DESCSUM")
		cDesFunc	:= fDesc("SRJ",SRA->RA_CODFUNC,"RJ_DESC"   )

		DbSelectArea("SQB")
		DbSetOrder(1)
		DbSeek(xFilial("SQB") + SRA->RA_DEPTO)
		cDesDepto	:= SQB->QB_DESCRIC

		DbSelectArea("REC")
		DbSetOrder(1)
		DbSeek(xFilial("REC") + SQB->QB_COMARC)

		DbSelectArea("SRA")

		cCerNum := Iif(cTpImpr=="OFC",fCerNum(),"000000")

		fInfo(@aInfo,SRA->RA_FILIAL)

		fRifGrava(cRaFilial,cRaMat,SRA->RA_ADMISSA,SRA->RA_DEMISSA,@nTmpBru,@nFalJus,@nFalNJu,@nLicenc,@nSuspen,@nOutras,@nSoma,@nTmpLiq)
		fRigGrava(cRaFilial,cRaMat,SRA->RA_ADMISSA,SRA->RA_DEMISSA,@nTmpAvr,@nTmpFLi,@aSessoes)
		fRIHGrava(cRaFilial,cRaMat,SRA->RA_ADMISSA,SRA->RA_DEMISSA,cOFC,cCerNum)

		oModelRIE:SetValue("RIE_FILIAL",FWxFilial("RIE"))
		oModelRIE:SetValue("RIE_MAT"   ,cRaMat          )
		oModelRIE:SetValue("RIE_NOME"  ,SRA->RA_NOMECMP )
		oModelRIE:SetValue("RIE_RG"    ,SRA->RA_RG      )
		oModelRIE:SetValue("RIE_RGORG" ,SRA->RA_RGORG   )
		oModelRIE:SetValue("RIE_RGUF"  ,SRA->RA_RGUF    )
		oModelRIE:SetValue("RIE_DTRGEX",SRA->RA_DTRGEXP )
		oModelRIE:SetValue("RIE_CPF"   ,SRA->RA_CIC     )
		oModelRIE:SetValue("RIE_PASEP" ,SRA->RA_PIS     )
		oModelRIE:SetValue("RIE_MAE"   ,SRA->RA_MAE     )
		oModelRIE:SetValue("RIE_PAI"   ,SRA->RA_PAI     )
		oModelRIE:SetValue("RIE_SEXO"  ,SRA->RA_SEXO     )
		oModelRIE:SetValue("RIE_CARGO" ,SRA->RA_CARGO   )
		oModelRIE:SetValue("RIE_DCARGO",cDesCargo       )
		oModelRIE:SetValue("RIE_FUNCAO",SRA->RA_CODFUNC )
		oModelRIE:SetValue("RIE_DFUNC" ,cDesFunc        )
		oModelRIE:SetValue("RIE_COMARC",REC->REC_NOME )
		oModelRIE:SetValue("RIE_TABELA",SRA->RA_TABELA  )
		oModelRIE:SetValue("RIE_TABNIV",SRA->RA_TABNIVE )
		oModelRIE:SetValue("RIE_TABFAI",SRA->RA_TABFAIX )
		oModelRIE:SetValue("RIE_DEPTO" ,SRA->RA_DEPTO   )
		oModelRIE:SetValue("RIE_DDEPTO",cDesDepto       )
		oModelRIE:SetValue("RIE_CATFUN",SRA->RA_CATFUNC )
		oModelRIE:SetValue("RIE_NASC"  ,SRA->RA_NASC )
		oModelRIE:SetValue("RIE_ADMISS",SRA->RA_ADMISSA )
		oModelRIE:SetValue("RIE_DEMISS",SRA->RA_DEMISSA )
		oModelRIE:SetValue("RIE_CEP"   ,SM0->M0_CEPENT )
		oModelRIE:SetValue("RIE_MUNICI",Left(SM0->M0_CIDENT, 20) )
		oModelRIE:SetValue("RIE_ESTADO",SM0->M0_ESTENT )
		oModelRIE:SetValue("RIE_LOCTRB",AllTrim(aInfo[3]))
		oModelRIE:SetValue("RIE_CNPJ"  ,AllTrim(aInfo[8]))
		oModelRIE:SetValue("RIE_DTCTDE",SRA->RA_ADMISSA )
		oModelRIE:SetValue("RIE_DTCTAT",Iif(Empty(SRA->RA_DEMISSA),dDataBase,SRA->RA_DEMISSA))
		oModelRIE:SetValue("RIE_FONTE",Upper(cVdCert3) + " DO " + Upper(cVdCert1) + UPPER(cVdCert4) )

		oModelRIE:SetValue("RIE_TMPBRU",nTmpBru		 )
		oModelRIE:SetValue("RIE_CERNUM",cCerNum		 )
		oModelRIE:SetValue("RIE_FALJUS",nFalJus    	 )
		oModelRIE:SetValue("RIE_FALNJU",nFalNJu      	 )
		oModelRIE:SetValue("RIE_LICENC",nLicenc      	 )
		oModelRIE:SetValue("RIE_SUSPEN",nSuspen      	 )
		oModelRIE:SetValue("RIE_OUTRAS",nOutras      	 )
		oModelRIE:SetValue("RIE_SOMA"  ,nSoma		  	 )
		oModelRIE:SetValue("RIE_TMPLIQ",nTmpLiq      	 )
		oModelRIE:SetValue("RIE_TMPAVR",nTmpAvr	  	 )
		oModelRIE:SetValue("RIE_TMPFLI",nTmpFLi      	 )

		cTxtCer := VD060TXTCER(oModel,aSessoes)
		oModelRIE:SetValue("RIE_TXTCER",cTxtCer         )

 	EndIf
EndIf
	//Realiza a gravação do Modelo
If FWFormCommit( oModel )
EndIf
oModel:DeActivate()
oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()

RestArea(aAreaSRA)

Return .T.
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} VD060TXTCER()

@protected
@author        Tania Bronzeri
@since         09/01/2014
@version       P11
/*/
//---------------------------------------------------------------------------------------
Function VD060TXTCER(oModel,aSessoes)
Local aAreaRi6		:= GetArea("RI6")
Local aAreaRi5		:= GetArea("RI5")
Local cRieFilial	:= oModel:GetValue("RIEDETAIL","RIE_FILIAL")
Local cRieMat		:= oModel:GetValue("RIEDETAIL","RIE_MAT"   )
Local cRieFinali	:= oModel:GetValue("RIEDETAIL","RIE_FINALI")
Local cRieOrgDes	:= oModel:GetValue("RIEDETAIL","RIE_ORGDES")
Local cRieCpf		:= oModel:GetValue("RIEDETAIL","RIE_CPF"   )
Local nRieTmpLiq	:= oModel:GetValue("RIEDETAIL","RIE_TMPLIQ")
Local nRieAvrTmp 	:= oModel:GetValue("RIEDETAIL","RIE_TMPAVR")
Local nRieFliTmp	:= oModel:GetValue("RIEDETAIL","RIE_TMPFLI")
Local dRieDeDtCt	:= oModel:GetValue("RIEDETAIL","RIE_DTCTDE")
Local dRieAtDtCt	:= oModel:GetValue("RIEDETAIL","RIE_DTCTAT")
Local dRieDtSoli	:= oModel:GetValue("RIEDETAIL","RIE_DTSOLI")
Local dRieAdmiss	:= oModel:GetValue("RIEDETAIL","RIE_ADMISS")
Local dRieDemiss	:= oModel:GetValue("RIEDETAIL","RIE_DEMISS")
Local cRieServ		:= Iif(Empty(dRieDemiss),"","Ex-") +"Servidor " + AllTrim(oModel:GetValue("RIEDETAIL","RIE_NOME"))
Local cRieExoner	:= GetNextAlias()
Local cQFil     	:= "%'" + cRieFilial + "'%"
Local cQMat		:= "%'" + cRieMat    + "'%"
Local cQDemiss		:= "%'" + DtoS(dRieDemiss) + "'%"
Local cQDtCanc		:= "%'" + DtoS(CtoD("  /  /  ")) + "'%"

Local cMensagem	:= ""
Local cNomRieAto	:= ""
Local cExoRieAto	:= ""
Local cRieExtDias	:= fExtDias(nRieTmpLiq)
Local cRieAvrDias	:= fExtDias(nRieAvrTmp)
Local cRieFliDias	:= fExtDias(nRieFliTmp)
Local cRieGerDias	:= fExtDias(nRieTmpLiq + nRieAvrTmp + nRieFliTmp)
Local dRieDtAto	:= CtoD("  /  /  ")
Local dRieDtAPub	:= CtoD("  /  /  ")
Local dExoAtRieDt	:= CtoD("  /  /  ")
Local dExoPuRieDt	:= CtoD("  /  /  ")
Local dExoEfRieDt	:= CtoD("  /  /  ")
Local cTRegime		:= 	Iif(SRA->RA_REGIME == "1","CLT","Estatutário")
Local cTPrevid		:= 	Iif(SRA->RA_TPPREVI == "1","RGPS-Reg.Geral Previdência Social",;
						Iif(SRA->RA_TPPREVI == "2","RPPS-Reg. Proprio Previdencia Social",;
							"RPPE-Reg. Proprio Previdencia Social Exterior"))
Default aSessoes	:= {}

PRIVATE __TEMPO 		:= ""			// Texto com o tempo de contribuição
PRIVATE __NOMEACAO	:= ""			// Informações de nomeação e exoneração

dRieAtDtCt	:= Iif(Empty(dRieAtDtCt),dRieDtSoli,dRieAtDtCt)
dRieDeDtCt	:= Iif(Empty(dRieDeDtCt),dRieAdmiss,dRieDeDtCt)

//Pesquisa Ato de Nomeação
DbSelectArea("RI6")
DbSetOrder(1)
If  RI6->(DbSeek(FwxFilial("RI6") + "REY" + cRieCpf + cRieFilial + cRieMat))
	cNomRieAto	:= RI6->RI6_NUMDOC
	DbSelectArea("RI5")
	DbSetOrder(1)
	If RI5->(DbSeek(FwxFilial("RI5") + RI6->RI6_ANO + RI6->RI6_NUMDOC + RI6->RI6_TIPDOC))
		dRieDtAto	:= RI5->RI5_DTATPO
		dRieDtAPub	:= RI5->RI5_DTAPUB
	EndIf
EndIf

//Pesquisa Ato de Exoneração
BeginSql alias cRieExoner
	SELECT RI6_FILIAL, RI6_MAT,    RI6_TIPDOC, RI6_CLASTP, RI6_DTATPO, RI6_NUMDOC, RI6_DTCANC, RI6_DTEFEI,
		   RI5_TIPDOC, RI5_NUMDOC, RI5_DTAPUB, RI5_DTATPO
	From 	%table:RI6% RI6
		Left Join
			%table:RI5% RI5 On RI6_FILIAL = RI5_FILIAL And RI6_ANO = RI5_ANO
				And RI6_NUMDOC = RI5_NUMDOC And RI6_TIPDOC = RI5_TIPDOC
	WHERE RI6.%notDel% And RI5.%notDel% And
		  RI6_FILIAL = %exp:cQFil% And RI6_MAT = %exp:cQMat% And
		  RI6_DTCANC = %exp:cQDtCanc% And RI6_DTEFEI = %exp:cQDemiss% And
		 (RI6_CLASTP = '02' Or RI6_CLASTP = '03')
EndSql

DbSelectArea(cRieExoner)
(cRieExoner)->(DbGoTop())
cExoRieAto	:= (cRieExoner)->RI6_NUMDOC
dExoAtRieDt	:= CtoD((cRieExoner)->RI6_DTATPO)
dExoPuRieDt	:= CtoD((cRieExoner)->RI5_DTAPUB)
dExoEfRieDt	:= CtoD((cRieExoner)->RI6_DTEFEI)

(cRieExoner)->(DbCloseArea())

 __TEMPO := AllTrim(Str(nRieTmpLiq)) + " (" + Lower(AllTrim(Extenso(nRieTmpLiq,.T.))) + STR0013 + cRieExtDias		//") dias, correspondentes a "
If nRieAvrTmp > 0
	__TEMPO += " e " + AllTrim(Str(nRieAvrTmp)) + " (" + Lower(AllTrim(Extenso(nRieAvrTmp,.T.))) + STR0013 + cRieAvrDias   // ") dias, correspondentes a "
Else
	__TEMPO += STR0014 																							//" e 0 (zero) dias "
EndIf
If nRieFliTmp > 0
	__TEMPO += " e " + AllTrim(Str(nRieFliTmp)) + " (" + Lower(AllTrim(Extenso(nRieFliTmp,.T.))) + STR0013 + cRieFliDias   	//") dias, correspondentes a "
EndIf
__TEMPO += STR0015 + cVdCert1 + STR0016 +;               //" de Tempo de Serviço e Contribuição este averbado no "   ##" perfazendo um total de "
			AllTrim(Str(nRieTmpLiq + nRieAvrTmp + nRieFliTmp)) + " (" + Lower(AllTrim(Extenso(nRieTmpLiq + nRieAvrTmp + nRieFliTmp,.T.))) + STR0017    //") dias, "
__TEMPO += STR0018 + cRieGerDias + " - " + R060Util(nRieTmpLiq + nRieAvrTmp + nRieFliTmp) + "."            //" correspondentes a "

__NOMEACAO	:= "o " + cRieServ + STR0019 + cNomRieAto + STR0020 + DtoC(dRieDtAto) + STR0021 + DtoC(dRieDtAPub)      //", foi nomeado(a) pelo Ato Nº "  ## ", de "    ## ", D.O.E. de "
__NOMEACAO	+= STR0022 + DtoC(dRieAdmiss) + ". "                                  //". Tomou posse e entrou em exercício em "
If !Empty(dRieDemiss)
    __NOMEACAO	+= STR0023 + cExoRieAto + ", de " + DtoC(dExoAtRieDt) + STR0021 + DtoC(dExoPuRieDt)          //"Exonerado(a) pelo Ato Nº " ## //", D.O.E. de "
    __NOMEACAO	+= STR0024 + DtoC(RI6->RI6_DTEFEI) + ". "                               //", com efeitos a partir de "
EndIf

MsAguarde({|| cMensagem := VD060MCert() }, STR0025,STR0026,.T.)  		//"Texto da Certidão","Lendo o texto. Aguarde ..."

RestArea(aAreaRi5)
RestArea(aAreaRi6)

Return (cMensagem)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} VD060MCert()

@protected
@author        Wagner Mobile Cost
@since         11/07/2014
@version       P11
/*/
//---------------------------------------------------------------------------------------
Function VD060MCert()

Local cMensagem := "", cFile := "\inicializadores\vdfm060_cer.ini"

If ! File(cFile)
	WriteCer(cFile)
EndIf

FT_FUSE(cFile)         //ABRIR
FT_FGOTOP()            //PONTO NO TOPO

While !FT_FEOF()
	IncProc()
	cMensagem := cMensagem+ FT_FREADLN()
	FT_FSKIP()
endDo
FT_FUSE()

Return VD210Macro(cMensagem)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ WriteCer * Autor ³ Wagner Mobile Costa   ³ Data ³  11.07.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Gera o arquivo \inicializadores\vdfm060_cer.ini            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ WriteCer()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function WriteCer(cFile)

Local aTxt := {}, nTxt := 0

Aadd(aTxt, STR0027) 		//Certifico, em face do apurado, que o interessado conta, de efetivo exercício prestado ao [{*cVdCert1*}], o tempo de Contribuição de
Aadd(aTxt, STR0040 +Chr(13) + Chr(10))																						//[{*__TEMPO*}]chr(192)
Aadd(aTxt, 'chr(193)'+Chr(13) + Chr(10))
Aadd(aTxt, STR0028)         	//"Certifico que a Lei Complementar No. 04, de 15 de outubro de 1990, de 15-10-90, publicado no D.O.E da mesma data e suas "
Aadd(aTxt, STR0029)		 		//alterações, c/c Art. 2º da Lei Ordinária No. 9.782, de 19 de julho de 2012, publicado no D.O.E da mesma data, assegura aos
Aadd(aTxt, STR0030)				//servidores da Procuradoria-Geral de Justiça do Estado de Mato Grosso, aposentadoria voluntária por idade e por Tempo de
Aadd(aTxt, STR0031) 			//Contribuição e idade, aposentadorias por invalidez e compulsória e pensão por morte, com aproveitamento de tempo de
Aadd(aTxt, STR0032) 			//contribuição para o Regime Geral de Previdência Social - RGPS ou para outro Regime Próprio de Previdência Social - RPPS na
Aadd(aTxt, STR0033)      		//forma contagem/recíproca, conforme Lei Federal No. 6.226, de 14-07-1975, com alteração dada pela Lei Federal No. 6.864,
Aadd(aTxt, STR0034) 			//de 01-02-1980. O regime aplicado aos servidores é o Estatutário e as Contribuições foram recolhidas para o fundo Próprio
Aadd(aTxt, STR0035+Chr(13) + Chr(10))	//Ministério Público do Estado de Mato Grosso.chr(192)
Aadd(aTxt, 'chr(193)'+Chr(13) + Chr(10))
Aadd(aTxt, STR0036)         	//Certifico ainda, conforme o disposto no Art. 76 da Lei Complementar No. 64/2002 que regulamentou o Art. 4º da EC No.
Aadd(aTxt, STR0037)   			//20/1998, que o tempo de serviço considerado para o efeito de aposentadoria nos termos de legislação vigente e cumprido até
Aadd(aTxt, STR0038)  			//a data da publicação desta lei complementar será contado como tempo de contribuição.chr(192)
Aadd(aTxt, 'chr(193)'+Chr(13) + Chr(10))
Aadd(aTxt, STR0039)  			//Certifico por fim, que o [{*__NOMEACAO*}]

nHandle := FCREATE(cFile)
For nTxt := 1 To Len(aTxt)
	FWrite(nHandle, aTxt[nTxt] + Chr(13) + Chr(10))
Next
FClose(nHandle)

Return


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} fExtDias()

@protected
@author        Tania Bronzeri
@since         09/01/2014
@version       P11
/*/
//---------------------------------------------------------------------------------------
Function fExtDias(nRieTmpLiq)
Local cRieAnos		:= ""
Local cRieMeses		:= ""
Local cRieDias		:= ""
Local cRieTempo		:= ""
Local nRieAnos		:= 0
Local nRieMeses		:= 0
Local nRieDias		:= 0

Default nRieTmpLiq	:= 0

fDias2Anos(nRieTmpLiq,@nRieAnos,@nRieMeses,@nRieDias)

cRieAnos	:= AllTrim(Str(nRieAnos))  + " (" + if(nRieAnos==0, STR0041,Lower(AllTrim(Extenso(nRieAnos,.T.))))  + ")" + Iif(nRieAnos == 1,  STR0042,STR0043)   //" ano, "," anos, "
cRieMeses	:= AllTrim(Str(nRieMeses)) + " (" + if(nRieMeses==0,STR0041,Lower(AllTrim(Extenso(nRieMeses,.T.)))) + ")" + Iif(nRieMeses == 1, STR0044,STR0045) //" mês e "," meses e "
cRieDias	:= AllTrim(Str(nRieDias))  + " (" + if(nRieDias==0, STR0041,Lower(AllTrim(Extenso(nRieDias,.T.))))  + ")" + Iif(nRieDias == 1,  STR0046,STR0047) //" dia "," dias "

cRieTempo	:= cRieAnos + cRieMeses + cRieDias

Return cRieTempo


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} fRifGrava()
faz a gravação da tabela RIF
@protected
@author        Tania Bronzeri
@since         09/01/2014
@version       P11
/*/
//---------------------------------------------------------------------------------------
Function fRifGrava(cRaFilial,cRaMat,dRaAdmissa,dRaDemissa,nTmpBru,nFalJus,nFalNJu,nLicenc,nSuspen,nOutras,nSoma,nTmpLiq)
Local aAreaSRA		:= GetArea("SRA")
Local lRet			:= .T.
Local aRetorno		:= {}
Local aFaltas		:= {}
Local aDevols		:= {}
Local aLicencas	:= {}
Local aCaracts		:= {"1","2","3","4","5"}		//Considera: 1=Licença;2=Licença sem Subsidios;3=Suspensão;4=Disponibilidade e 5=Outros
Local cPD0054  	:= fGetCodFol("0054")	//Faltas I
Local cPD0242  	:= fGetCodFol("0242")	//Faltas II
Local cPD1364  	:= fGetCodFol("1364")	//Faltas III
Local cPD1365  	:= fGetCodFol("1365")	//Faltas IV
Local cPD0244  	:= fGetCodFol("0244")	//Dev.Faltas I
Local cPD1363  	:= fGetCodFol("1363")	//Dev.Faltas II
Local cPD1366  	:= fGetCodFol("1366")	//Dev.Faltas III
Local cPD1367  	:= fGetCodFol("1367")	//Dev.Faltas IV
Local cJFaltas		:= "'" + AllTrim(cPD0054) + Iif(!Empty(cPD0054) .And. !Empty(cPD0242), ";", "") + AllTrim(cPD0242) + "'"
Local cNJFaltas	:= "'" + AllTrim(cPD1364) + Iif(!Empty(cPD1364) .And. !Empty(cPD1365), ";", "") + AllTrim(cPD1365) + "'"
Local cJDevols		:= "'" + AllTrim(cPD0244) + Iif(!Empty(cPD0244) .And. !Empty(cPD1363), ";", "") + AllTrim(cPD1363) + "'"
Local cNJDevols	:= "'" + AllTrim(cPD1366) + Iif(!Empty(cPD1366) .And. !Empty(cPD1367), ";", "") + AllTrim(cPD1367) + "'"
Local niPd			:= 0
Local niCaracs		:= 0
Local nOk			:= 0
Local cARifRie		:= GetNextAlias()
Local cQFil		:= "%'" + cRaFilial + "'%"
Local cQMat		:= "%'" + cRaMat	   + "'%"
Local cExecSql		:= ""

Private aTmpBru	:= {}

//No MP são consideradas as seguintes faltas/devoluções:
//[1]-Faltas Justificadas-I;     [2]-Faltas Justificadas-II;     [3]-Faltas Nao Justificadas-III;     [4]-Faltas Nao Justificadas-IV
//[5]-Dev.Faltas Justificadas-I; [6]-Dev.Faltas Justificadas-II; [7]-Dev.Faltas Nao Justificadas-III; [8]-Dev.Faltas Nao Justificadas-IV

Default nTmpBru	:= 0
Default nFalJus	:= 0
Default nFalNJu	:= 0
Default nLicenc	:= 0
Default nSuspen	:= 0
Default nOutras	:= 0
Default nSoma	:= 0
Default nTmpLiq	:= 0

If Select('RIFQRY') > 0
	RIFQRY->( dbCloseArea())
EndIf

cExecSql	:=" SELECT R_E_C_N_O_ AS RECRIF FROM " + RETSQLNAME("RIF") + " WHERE "
cExecSql	+= " RIF_FILIAL = '" + cRaFilial + "' And RIF_MAT = '" + cRaMat + "' And D_E_L_E_T_ = ' '"
cExecSql := ChangeQuery(cExecSql)
dbUseArea(.T., 'TOPCONN', TcGenQry(,, cExecSql), 'RIFQRY', .F., .T. )

DbSelectArea("RIF")
DbSetOrder(1)
If	RIFQRY->(!Eof())
	RIFQRY->(dbGoToP())
	While RIFQRY->(!Eof())
		RIF->(dbGoTo(RIFQRY->(RECRIF)))
		RIF->(RecLock( "RIF",.F., .F.))
		RIF->(dbDelete())
		RIFQRY->(DbSkip())
		RIF->(MsUnlock())
	EndDo
EndIF
RIFQRY->(DbCloseArea())


//Apura Tempo Bruto Ano a Ano

aTmpBru := fGetTmpBru(dRaAdmissa,dRaDemissa)

If Len(aTmpBru) > 0
	For niPd := 1 to Len(aTmpBru)
		If DbSeek(cRaFilial+cRaMat+aTmpBru[niPd][1])
			RecLock("RIF",.F.)
		Else
		    RecLock("RIF",.T.)
			Replace RIF_FILIAL	With	cRaFilial
			Replace RIF_MAT		With	cRaMat
		    Replace RIF_ANO		With	aTmpBru[niPd][1]
        EndIf
		Replace RIF_TMPBRU	With	aTmpBru[niPd][2]
		Replace RIF_FALJUS	With	0
		Replace RIF_FALNJU	With	0
		Replace RIF_LICENC	With	0
		Replace RIF_SUSPEN	With	0
		Replace RIF_OUTRAS	With	0
		Replace RIF_SOMA		With	0
		Replace RIF_TMPLIQ	With	aTmpBru[niPd][2]
		MsUnlock()
 	Next niPd
EndIf


//Apura Faltas Justificadas e Não Justificadas Ano a Ano
aRetorno	:= fGetFalDev(cRaFilial,cRaMat,dRaAdmissa,dRaDemissa,,,.F.,aTmpBru)	//Devolve: Ano, Verba, Valor
aFaltas	:= aClone(aRetorno[1])
aDevols	:= aClone(aRetorno[2])

DbSelectArea("RIF")
DbSetOrder(1)

If Len(aFaltas) > 0
	For niPd := 1 to Len(aFaltas)
		If DbSeek(cRaFilial+cRaMat+aFaltas[niPd][1])
			RecLock("RIF",.F.)
		Else
			RecLock("RIF",.T.)
			Replace RIF_FILIAL	With	cRaFilial
			Replace RIF_MAT		With	cRaMat
			Replace RIF_ANO		With	aFaltas[niPd][1]
		EndIf
		If aFaltas[niPd][2] $ (cJFaltas)		//Faltas Justificadas
			Replace RIF_FALJUS	With	(RIF_FALJUS + aFaltas[niPd][3])
		ElseIf aFaltas[niPd][2] $ (cNJFaltas)	//Faltas Não Justificadas
			Replace RIF_FALNJU	With	(RIF_FALNJU + aFaltas[niPd][3])
		EndIf
		Replace RIF_SOMA		With	(RIF_FALJUS + RIF_FALNJU + RIF_LICENC + RIF_SUSPEN + RIF_OUTRAS)
		Replace RIF_TMPLIQ	With	(RIF_TMPBRU - RIF_SOMA)
		MsUnlock()
    Next niPd
EndIf

If Len(aDevols) > 0
	For niPd := 1 to Len(aDevols)
		If DbSeek(cRaFilial+cRaMat+aDevols[niPd][1])
			RecLock("RIF",.F.)
		Else
			RecLock("RIF",.T.)
			Replace RIF_FILIAL	With	cRaFilial
			Replace RIF_MAT		With	cRaMat
			Replace RIF_ANO		With	aDevols[niPd][1]
		EndIf
		If aDevols[niPd][2] $ (cJDevols)		//Devoluções de Faltas Justificadas
			Replace RIF_FALJUS	With	(RIF_FALJUS - aDevols[niPd][3])
		ElseIf aDevols[niPd][2] $ (cNJDevols)	//Devoluções de Faltas Não Justificadas
			Replace RIF_FALNJU	With	(RIF_FALNJU - aDevols[niPd][3])
		EndIf
		Replace RIF_SOMA	With	(RIF_FALJUS + RIF_FALNJU + RIF_LICENC + RIF_SUSPEN + RIF_OUTRAS)
		Replace RIF_TMPLIQ	With	(RIF_TMPBRU - RIF_SOMA)
		MsUnlock()
    Next niPd
EndIf


//Apura dias de Licenças
For niCaracs	:= 1 to Len(aCaracts)
	aLicencas	:= fGetLicencas(cRaFilial,cRaMat,dRaAdmissa,dRaDemissa,aCaracts[niCaracs])

	If Len(aLicencas) > 0
		For niPd := 1 to Len(aLicencas)
			If DbSeek(cRaFilial+cRaMat+aLicencas[niPd][1])
				RecLock("RIF",.F.)
			Else
				RecLock("RIF",.T.)
				Replace RIF_FILIAL	With	cRaFilial
				Replace RIF_MAT		With	cRaMat
				Replace RIF_ANO		With	aLicencas[niPd][1]
			EndIf
			If aCaracts[niCaracs] == "1"			//Licenças
				Replace RIF_LICENC	With	(RIF_LICENC + aLicencas[niPd][2])
			ElseIf aCaracts[niCaracs] == "2"	//Licenças sem Subsidios
				Replace RIF_LICSUB	With	(RIF_LICSUB + aLicencas[niPd][2])
			ElseIf aCaracts[niCaracs] == "3"	//Suspensões
				Replace RIF_SUSPEN	With	(RIF_SUSPEN + aLicencas[niPd][2])
			ElseIf aCaracts[niCaracs] == "4"	//Disponibilidade
				Replace RIF_DISPON	With	(RIF_DISPON + aLicencas[niPd][2])
			ElseIf aCaracts[niCaracs] == "5"	//Outros Afastamentos
				Replace RIF_OUTRAS	With	(RIF_OUTRAS + aLicencas[niPd][2])
			EndIf
			Replace RIF_SOMA		With	(RIF_FALNJU + RIF_LICENC + RIF_LICSUB + RIF_SUSPEN + RIF_DISPON + RIF_OUTRAS)
			Replace RIF_TMPLIQ	With	(RIF_TMPBRU - RIF_SOMA)
			MsUnlock()
	    Next niPd
	EndIf
Next niCaracs

//Atualiza Valores da RIE
BeginSql alias cARifRie
	SELECT 	Sum(RIF_TMPBRU) AS QTmpBru, Sum(RIF_FALJUS) AS QFalJus, Sum(RIF_FALNJU) AS QFalNJu,
			Sum(RIF_LICENC) AS QLicenc, Sum(RIF_SUSPEN) AS QSuspen, Sum(RIF_OUTRAS) AS QOutras,
			Sum(RIF_SOMA  ) AS QSoma  , Sum(RIF_TMPLIQ) AS QTmpLiq
	From %table:RIF% RIF
	WHERE RIF.%notDel% And RIF_FILIAL = %exp:cQFil% And RIF_MAT = %exp:cQMat%
EndSql

DbSelectArea(cARifRie)
(cARifRie)->(DbGoTop())
nTmpBru	:= (cARifRie)->QTmpBru
nFalJus	:= (cARifRie)->QFalJus
nFalNJu	:= (cARifRie)->QFalNJu
nLicenc	:= (cARifRie)->QLicenc
nSuspen	:= (cARifRie)->QSuspen
nOutras	:= (cARifRie)->QOutras
nSoma		:= (cARifRie)->QSoma
nTmpLiq	:= (cARifRie)->QTmpLiq

(cARifRie)->(DbCloseArea())

RestArea(aAreaSRA)

Return lRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} fGetTmpBru
Busca as Faltas
@protected
@author        Tania Bronzeri
@since         09/01/2014
@version       P11
/*/
//---------------------------------------------------------------------------------------
Function fGetTmpBru(dInicio,dFinal)
Local nAnoIni	:= 0
Local nAnoFin	:= 0
Local aTmpDias	:= {}

dFinal	:= Iif(Empty(dFinal),dDataBase,dFinal)

nAnoIni	:= Year(dInicio)
nAnoFin	:= Year(dFinal)

If nAnoIni == nAnoFin
	aadd(aTmpDias, {AllTrim(Str(nAnoIni)), (dFinal - dInicio) + 1})
Else
	aAdd(aTmpDias, {AllTrim(Str(nAnoIni)), (StoD(AllTrim(Str(nAnoIni)) + "1231") - dInicio) + 1})
	nAnoIni++
	While nAnoIni < nAnoFin
		aAdd(aTmpDias, {AllTrim(Str(nAnoIni)), (StoD(AllTrim(Str(nAnoIni)) + "1231") - StoD(AllTrim(Str(nAnoIni)) + "0101")) + 1})
		nAnoIni++
	EndDo
    aAdd(aTmpDias, {AllTrim(Str(nAnoIni)), dFinal - (StoD(AllTrim(Str(nAnoFin)) + "0101")) + 1})
EndIf

Return aClone(aTmpDias)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} fGetLicencas
Busca as licenças
@protected
@author        Tania Bronzeri
@since         09/01/2014
@version       P11
/*/
//---------------------------------------------------------------------------------------
Function fGetLicencas(cRaFilial,cRaMat,dInicio,dFinal,cCaracts)
Local nLicAcum	:= 0
Local niPd		:= 0
Local nAnoIni	:= 0
Local nAnoFin	:= 0
Local aTmpLic	:= {}
Local aTmpDias	:= {}
Local aLicencas	:= {}
Local dIni
Local dFim

dFinal	:= Iif(Empty(dFinal),dDataBase,dFinal)


nAnoIni	:= Year(dInicio)
nAnoFin	:= Year(dFinal)

While nAnoIni <= nAnoFin

	dIni := max(stod(strzero(nAnoIni,4)+'0101'),dInicio)
	dFim := min(stod(strzero(nAnoIni,4)+'1231'),dFinal)

	aTmpLic	:= fVerSR8(cRaFilial, cRaMat, dIni, dFim, .F., .F., .T.,,,, .T.,,cCaracts)
	nLicAcum	:= 0
	If Len(aTmpLic) > 0
		For niPd	:= 1 to Len(aTmpLic)
			nLicAcum	+= min(dFim,atmplic[1][4]) - max(dIni,atmplic[1][3]) + 1
		Next niPd
		aAdd(aTmpDias, {strzero(nAnoIni,4), nLicAcum})
	EndIf
	nAnoIni++

EndDo

Return aTmpDias

//-------------------------------------------------------------------
/*/{Protheus.doc} VD060GRVMD
Gera sequencia para o campo RIE_CERNUM
@owner Tania Bronzeri
@author Tania Bronzeri
@since 05/12/2013
@version P11
@project M_RH001 - Gestão De Pessoas e Vida Funcional Ministério Público do Estado de Mato Grosso
/*/
//-------------------------------------------------------------------
Function fCerNum()
Local aAreaRIE	:= GetArea("RIE")
Local cCerAls	:= GetNextAlias()
Local cCerNum	:= ""

BeginSql alias cCerAls
	Select	Max(RIE_CERNUM) AS MaxCerNum
	From 	%table:RIE% RIE
	Where	RIE.%notDel%
EndSql

DbSelectArea(cCerAls)
(cCerAls)->(DbGoTop())

cCerNum	:= AllTrim(STR(VAL((cCerAls)->MaxCerNum) + 1))
cCerNum	:= PadL(cCerNum,Len((cCerAls)->MaxCerNum),"0")

//-- Fecha a área de trabalho e retorna a area corrente.
(cCerAls)->(DbCloseArea())

RestArea (aAreaRIE)
Return cCerNum

//-------------------------------------------------------------------
/*/{Protheus.doc} VD060GRVMD
faz a gravação da Tabela RIG
@owner Tania Bronzeri
@author Tania Bronzeri
@since 05/12/2013
@version P11
@project M_RH001 - Gestão De Pessoas e Vida Funcional Ministério Público do Estado de Mato Grosso
/*/
//-------------------------------------------------------------------
Function fRigGrava(cRaFilial,cRaMat,dRaAdmissa,dRaDemissa,nTmpAvr,nTmpFLi,aSessoes)
Local aAreaSRA	:= GetArea("SRA")
Local cRiiAls	:= GetNextAlias()
Local cARigRie  := GetNextAlias()
Local cQRaFil	:= "%'" + cRaFilial + "'%"
Local cQRaMat	:= "%'" + cRaMat    + "'%"
Local cExecSql	:= ""
Local nOk		:= 0

Default nTmpAvr	:= 0
Default nTmpFLi	:= 0
Default	aSessoes:= {}

BeginSql alias cRiiAls
	Column RII_DTAVER As Date
	Column RII_DTCERT As Date
	Column RII_PERDE  As Date
	Column RII_PERATE As Date

	Select * from %table:RII% RII
	Where RII.%notDel%
		And RII_FILIAL = %exp:cQRaFil%
		And RII_MAT    = %exp:cQRaMat%
EndSql

If Select("RIGQRY") > 0
	RIGQRY->(DbCloseArea())
EndIf

cExecSql	:=" SELECT R_E_C_N_O_ AS RECRIG FROM " + RETSQLNAME("RIG") + " WHERE "
cExecSql	+= " RIG_FILIAL = '" + cRaFilial + "' And RIG_MAT = '" + cRaMat + "' And D_E_L_E_T_ = ' '"
cExecSql := ChangeQuery(cExecSql)
dbUseArea(.T., 'TOPCONN', TcGenQry(,, cExecSql), 'RIGQRY', .F., .T. )

DbSelectArea("RIG")
DbSetOrder(1)
If	RIGQRY->(!Eof())
	RIGQRY->(dbGoToP())
	While RIGQRY->(!Eof())
		RIG->(dbGoTo(RIGQRY->(RECRIG)))
		RIG->(RecLock( "RIG",.F., .F.))
		RIG->(dbDelete())
		RIGQRY->(DbSkip())
		RIG->(MsUnlock())
	EndDo
	RIGQRY->(DbCloseArea())
EndIF

DbSelectArea(cRiiAls)
(cRiiAls)->(DbGotop())
While (cRiiAls)->(!EOF())
	RecLock("RIG",.T.)
	Replace RIG_FILIAL	With	(cRiiAls)->RII_FILIAL
	Replace RIG_MAT		With	(cRiiAls)->RII_MAT
	Replace RIG_TIPINF	With	(cRiiAls)->RII_TIPINF
	Replace RIG_TIPAVE 	With	(cRiiAls)->RII_TIPAVE
	Replace RIG_TIPREG	With	(cRiiAls)->RII_TIPREG
	Replace RIG_SESSAO	With	(cRiiAls)->RII_SESSAO
	Replace RIG_DTAVER	With	(cRiiAls)->RII_DTAVER
	Replace RIG_NUMCER	With	(cRiiAls)->RII_NUMCER
	Replace RIG_DTCERT	With	(cRiiAls)->RII_DTCERT
	Replace RIG_ORGEXP	With	(cRiiAls)->RII_ORGEXP
	Replace RIG_PERDE		With	(cRiiAls)->RII_PERDE
	Replace RIG_PERATE	With	(cRiiAls)->RII_PERATE
	Replace RIG_TMPBRU	With	(cRiiAls)->RII_TMPBRU
	Replace RIG_DEDUC		With	(cRiiAls)->RII_DEDUC
	Replace RIG_TMPLIQ	With	(cRiiAls)->RII_TMPLIQ
	MsUnlock()
	aAdd(aSessoes,{(cRiiAls)->RII_SESSAO,(cRiiAls)->RII_DTAVER})
	(cRiiAls)->(DbSkip())
EndDo


//Atualiza Valores da RIE
BeginSql alias cARigRie
	SELECT 	RIG_TIPAVE AS QTipAve, Sum(RIG_TMPLIQ) AS QTmpLiq
	From %table:RIG% RIG
	WHERE RIG.%notDel% And RIG_FILIAL = %exp:cQRaFil% And RIG_MAT = %exp:cQRaMat%
	GROUP BY RIG_TIPAVE
	ORDER BY RIG_TIPAVE
EndSql

DbSelectArea(cARigRie)
(cARigRie)->(DbGoTop())
While (cARigRie)->(!EOF())
	If (cARigRie)->QTipAve	== '1'
		nTmpAvr	+= (cARigRie)->QTmpLiq
	Else
		nTmpFLi	+= (cARigRie)->QTmpLiq
	EndIf
	(cARigRie)->(DbSkip())
EndDo


//-- Fecha a área de trabalho e retorna a area corrente.
(cRiiAls )->(DbCloseArea())
(cARigRie)->(DbCloseArea())

RestArea (aAreaSRA)
Return Nil
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} fRIHGrava()
Faz a gravação da Tabela RIH, para impressão do relatorio
Relação dos subsidios de contribuições.
@protected
@author        Everson S.P Junior
@since         09/01/2014
@version       P11
/*/
//---------------------------------------------------------------------------------------
Static Function fRIHGrava(cRaFilial,cRaMat,dADMISSA,dDEMISSA,cOFC,cCerNum)
Local cQuery   := ""
Local nX,nY	 := 0
Local nPeriodo := 0
Local cId0013	 := FgetCodFol("0013") //Base Contribuição
Local cId0019	 := FgetCodFol("0019") //Base Contribuição 13 sal.
Local cId0064	 := FgetCodFol("0064") //Previdencia Subsidio
Local cId0065	 := FgetCodFol("0065") //previdencia de Ferias
Local cId0070	 := FgetCodFol("0070") //Previdencia 13 Sal
Local cId1374	 := FgetCodFol("1374") //Contrib. Previdencia
Local cId1382	 := FgetCodFol("1382") //Contrib. Previdencia
Local cId1662	 := FgetCodFol("1662") //Base Previdência Própria - Folha - RPPS
Local cId1663	 := FgetCodFol("1663") //Base Previdência Própria - 13o. - RPPS
Local cId1664	 := FgetCodFol("1664") //Base Previdência Própria - Férias - RPPS
Local cId1665	 := FgetCodFol("1665") //Previdência Própria Desconto - Ferias - RPPS

Local lSubsTp 	:= "MSSQL" $ AllTrim( Upper( TcGetDb() ) ) .Or. AllTrim( Upper( TcGetDb() ) ) == 'SYBASE'

If Empty(cOFC)
	cOFC := Posicione("RIE",1,cRaFilial+cRaMat,"RIE_CERNUM")
EndIF

If Empty(dDEMISSA)
	dDEMISSA:= dDatabase
EndIf
If Select("TRBSRD") > 0
	TRBSRD->(DbCloseArea())
EndIf

cQuery += "select RD_DATARQ, SUM(RD_VALOR) AS SUB, SUM(RD_VALINFO) AS INSS from ( "
If lSubsTp
	cQuery += "select substring(RD_DATARQ,1,4) AS ANO, substring(RD_DATARQ,5,2) AS MES, "
Else
	cQuery += "select SUBSTR(RD_DATARQ,1,4) AS ANO, substring(RD_DATARQ,5,2) AS MES, "
EndIf
cQuery += "sum(CASE WHEN RD_PD In ('"+cID0013+"','"+cID0019+"','"+cID1662+"','"+cID1663+"','"+cID1664+"') then RD_VALOR ELSE 0 END) AS RD_VALOR, "
cQuery += "sum(CASE WHEN RD_PD In ('"+cID0064+"','"+cID0065+"','"+cID0070+"','"+cID1374+"','"+cID1382+"','"+cID1665+"') then RD_VALOR ELSE 0 END) AS RD_VALINFO, "
cQuery += "RD_DATARQ "
cQuery += " from " + RetSqlName("SRD") +  " SRD "
cQuery += " where RD_PD in ('"+cID0013+"','"+cID0019+"','"+cID0064+"','"+cID0065+"','"+cID0070+"','"+cID1374+"','"+cID1382+"','"+cID1662+"','"+cID1663+"','"+cID1664+"','"+cID1665+"') and D_E_L_E_T_ = ' ' "
cQuery += " and RD_DATARQ >= '"+AnoMes(dADMISSA)+"' "
cQuery += " and RD_FILIAL = '"+ xFilial("SRD") +"' and RD_MAT = '"+cRaMat+"' "
cQuery += " group by RD_DATARQ, RD_VALOR) XXX "

cQuery += " group by RD_DATARQ "

cQuery = ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),'TRBSRD',.T.,.T.)


If Select("TRBRIH") > 0
	TRBRIH->(DbCloseArea())
EndIf

cQuery := "SELECT R_E_C_N_O_ AS RECRIG "
cQuery += "FROM " + RetSqlName("RIH") +  " RIH "
cQuery += " where "
cQuery += " RIH.RIH_FILIAL = '"+cRaFilial+"' AND "
cQuery += " RIH.RIH_MAT = '"+SRA->RA_MAT+"' AND "
cQuery += " D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),'TRBRIH',.T.,.T.)

DbSelectArea("RIH")
DbSetOrder(1)
If RIH->(dbSeek(cRaFilial+cRaMat+ANOMES(dADMISSA))) .AND. (cOFC == "000000" .Or. Empty(cOFC))
	If	TRBRIH->(!Eof())
		TRBRIH->(dbGoToP())
		While TRBRIH->(!Eof())
			RIH->(dbGoTo(TRBRIH->(RECRIG)))
			RIh->(RecLock( "RIH",.F., .F.))
			RIh->(dbDelete())
			TRBRIH->(DbSkip())
			RIH->(MsUnlock())
		EndDo
		TRBRIH->(DbCloseArea())
	EndIF
EndIf

nPeriodo := (Year(dDEMISSA) - Year(dADMISSA))+1
If !RIH->(dbSeek(cRaFilial+cRaMat+ANOMES(dADMISSA) ))
	For nX := 1 to nPeriodo
		Ano := Iif(nx<>1,Val(SUBSTR(DTOC(dADMISSA),7,4))+nX-1,Val(SUBSTR(DTOC(dADMISSA),7,4)))
		For nY := 1 to 12
			RecLock("RIH",.T.)
			RIH->RIH_FILIAL 	:= 	SRA->RA_FILIAL
			RIH->RIH_MAT	 	:= 	SRA->RA_MAT
			RIH->RIH_ANO		:= Alltrim(STR(Ano))
			RIH->RIH_MES	   	:= STRZERO(nY, 2, 0)
			RIH_SUBMES			:= 0
			RIH_PREVID			:= 0
			RIH_CERNUM      	:= cCerNum
			RIH->(MsUnlock())
		Next
	Next
EndIf

While TRBSRD->(!EOF())
	If RIH->(dbSeek(cRaFilial+cRaMat+TRBSRD->RD_DATARQ))
		RecLock("RIH",.F.)
		RIH_SUBMES			:= TRBSRD->SUB
		RIH_PREVID			:= TRBSRD->INSS
		RIH_CERNUM      	:= cCerNum
		RIH->(MsUnlock())
	EndIf
	TRBSRD->(DbSkip())
EndDo
TRBSRD->(dbCloseArea())

Return
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} VDFVLDRIE()
Validação de campos da RIE
@protected
@author        Everson S.P Junior
@since         09/01/2014
@version       P11
/*/
//---------------------------------------------------------------------------------------
Function VDFVLDRIE(oModel)
Local lRet	:= .T.

Default oModel := FWModelActive()

If 	Empty(oModel:GetValue("RIEDETAIL","RIE_NOMDGP")) .Or.;
	Empty(oModel:GetValue("RIEDETAIL","RIE_CRGDGP"))	.Or.;
	Empty(oModel:GetValue("RIEDETAIL","RIE_ENDR"))	.Or.;
	Empty(oModel:GetValue("RIEDETAIL","RIE_MAILR"))	.Or.;
	Empty(oModel:GetValue("RIEDETAIL","RIE_DEPTOR"))	.Or.;
	Empty(oModel:GetValue("RIEDETAIL","RIE_NOMDIR"))	.Or.;
	Empty(oModel:GetValue("RIEDETAIL","RIE_CRGDIR"))	.Or.;
	Empty(oModel:GetValue("RIEDETAIL","RIE_NOMPGJ"))	.Or.;
	Empty(oModel:GetValue("RIEDETAIL","RIE_CRGPGJ"))
	Help(,,"Help",,' Nomes e Cargos dos Responsáveis não estão';
	+' informados adequadamente. Favor informar Nomes e Cargos de todos os Responsáveis. Verificar também endereço, e-mail e lotação do responsável',1,0)
	lRet := .F.
EndIf

Return lRet
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} VldPublic()
Faz a Validação se ja ouve publicação dos itens de Averbação.
@protected
@author        Everson S.P Junior
@since         23/01/2014
@version       P11
/*/
//---------------------------------------------------------------------------------------
Function VldPublic(cFil,cMat)
Local cQuery  := ""
Local lRet		:= .T.

If Select("TRBRII") > 0
	TRBRII->( dbCloseArea())
EndIf
cQuery  := "SELECT * "
cQuery  += " FROM " + RetSqlName( 'RII' )
cQuery  += " WHERE D_E_L_E_T_ 	=' '
cQuery  += " AND RII_FILIAL 	= '" +cFil+"'"
cQuery  += " AND RII_MAT		 	= '" +cMat+"'"

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBRII", .F., .T.)

While !TRBRII->(EOF())
	cChave := TRBRII->RII_PERDE+TRBRII->RII_PERATE+TRBRII->RII_TIPAVE+TRBRII->RII_SEQUEN
	If Select("TRBRI6") > 0
		TRBRI6->( dbCloseArea())
	EndIf
	cQuery  := "SELECT * "
	cQuery  += " FROM " + RetSqlName( 'RI6' ) + " RI6 "
	cQuery  += " Left Join "+ RetSqlName( 'RI5' )+ " RI5 on "
	cQuery  += " RI5.RI5_NUMDOC 		= RI6.RI6_NUMDOC "
	cQuery  += " AND RI5.RI5_ANO  		= RI6.RI6_ANO "
	cQuery  += " AND RI5.RI5_TIPDOC 	= RI6.RI6_TIPDOC  "
	cQuery  += " AND	RI5.D_E_L_E_T_ 	=' ' "
	cQuery  += " WHERE RI6.D_E_L_E_T_ 	=' ' "
	cQuery  += " AND RI6.RI6_FILMAT 	= '" +cFil+"'"
	cQuery  += " AND RI6.RI6_TABORI 	= 'RII'
	cQuery  += " AND RI6.RI6_MAT		= '" +cMat+"'"
	cQuery  += " AND RI6.RI6_CHAVE		= '"+cChave+"'"

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBRI6", .F., .T.)

	If TRBRII->RII_TIPINF = 'N' .AND. TRBRI6->(EOF())
		MsgAlert(STR0048+;        //"Existe Averbação de Tempo de Serviço sem item de publicação "
		STR0049+ TRBRII->RII_NUMCER + STR0050 + alltrim(TRBRII->RII_ORGEXP)+;       //"Gerado: Certidão n° "##" expedida por "
		STR0051 + dtoc(stod(TRBRII->RII_PERDE)) + " a "+ dtoc(stod(TRBRII->RII_PERATE)) + STR0052+;     //", período de "##". Não será possível emitir "
		STR0053)  						//"a Certidão"
		lRet := .F.
	ElseIf TRBRII->RII_TIPINF = 'N' .AND. Empty(TRBRI6->RI6_NUMDOC) .AND. Empty(TRBRI6->RI6_ANO)
		MsgAlert(STR0048+;  		//"Existe Averbação de Tempo de Serviço sem número de publicação: "
		STR0054 + TRBRII->RII_NUMCER + STR0050 + alltrim(TRBRII->RII_ORGEXP)+;     //"Certidão n° "  ##
		STR0051 + dtoc(stod(TRBRII->RII_PERDE)) + " a "+ dtoc(stod(TRBRII->RII_PERATE)) +STR0052 +;      //", período de "##". Não será possível emitir "
		STR0053)					//"a Certidão"
		lRet := .F.
	ElseIf TRBRII->RII_TIPINF = 'N' .AND. Empty(TRBRI6->RI5_DTAPUB)
		MsgAlert(STR0048+;			//"Existe Averbação de Tempo de Serviço sem item de publicação "
		STR0054+ TRBRII->RII_NUMCER +STR0050+ alltrim(TRBRII->RII_ORGEXP)+;//"Certidão n° "  ##"##" expedida por "
		STR0051 + dtoc(stod(TRBRII->RII_PERDE)) + " a "+ dtoc(stod(TRBRII->RII_PERATE)) +STR0052 +; //", período de "##". Não será possível emitir "
		STR0055) //"a Certidão. Favor providenciar os ajustes necessários para prosseguir com a emissão"
		lRet := .F.
	EndIf
	TRBRII->(DbSkip())
EndDo

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} vGETMV
Retorno de parametros por filial
@return	Null

@author	Wagner Mobile Costa
@since		24/06/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function vGetMV(cX6_FIL, cX6_VAR, cX6_CONTEUD)

Local aArea := GetArea()

DbSelectArea("SX6")
DbSetOrder(1)
If DbSeek(cX6_FIL + cX6_VAR)
	cX6_CONTEUD := SX6->X6_CONTEUD
EndIf

RestArea(aArea)

Return AllTrim(cX6_CONTEUD)
