#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE "VDFA100.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} VDFA100  
Averbações de Tempo de Contribuição
@owner Tania Bronzeri
@author Tania Bronzeri
@since 27/11/2013
@version P11
@project M_RH001 - Gestão De Pessoas e Vida Funcional Ministério Público do Estado de Mato Grosso
/*/
//-------------------------------------------------------------------
Function VDFA100()
Local oBrowse
Private oDlg 

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SRA')
oBrowse:SetDescription(STR0001)//''//'Averbações de Tempo de Contribuição'
oBrowse:SetFilterDefault( "RA_CATFUNC $ '0,1,2,3,5,6'")	
oBrowse:DisableDetails()
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002	ACTION 'VIEWDEF.VDFA100()'     OPERATION 4 ACCESS 0//'Histórico / Manutenção'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}ModelDef  
Averbações de Tempo de Contribuição
@owner Tania Bronzeri
@author Tania Bronzeri
@since 27/11/2013
@version P11
@project M_RH001 - Gestão De Pessoas e Vida Funcional Ministério Público do Estado de Mato Grosso
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSRA	:= FWFormStruct( 1, 'SRA', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruRII	:= FWFormStruct( 1, 'RII', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel
Local cCposLib	:= "RA_FILIAL,RA_MAT,RA_NOME"

SX3->(DbSetOrder(1))
SX3->(MsSeek("SRA"))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SRA"
	If (!Alltrim(SX3->X3_CAMPO) $ cCposLib) 
		If X3USO(SX3->X3_USADO)
			oStruSRA:SetProperty(Alltrim(SX3->X3_CAMPO), MODEL_FIELD_OBRIGAT, .F. )
		EndIF
		oStruSRA:RemoveField(Alltrim(SX3->X3_CAMPO))
 	EndIf
	SX3->(dbSkip())
EndDo

oStruRII:SetProperty("RII_MAT", MODEL_FIELD_OBRIGAT, .F. )

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('VDFA100M', /*bPreValidacao*/, /*bPosValidacao*/,{|oModel| Vdf100Grv(oModel)}, /*bCancel*/ )
oModel:SetOperation(MODEL_OPERATION_INSERT)

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'SRAMASTER', /*cOwner*/, oStruSRA, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'RIIDETAIL', 'SRAMASTER', oStruRII, /*bLinePre*/, /*bLinePost*/,/* */, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model 
oModel:SetRelation( 'RIIDETAIL', { { 'RII_FILIAL', 'FWxFilial( "SRA" )' }, { 'RII_MAT', 'RA_MAT' } }, RII->(IndexKey( 1 ) ) )
oModel:SetPrimaryKey({"RII_FILIAL", "RII_MAT","RII_PERDE","RII_PERATE"})

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0003)//'Histórico das Averbações de Tempo de Contribuição'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'SRAMASTER' ):SetDescription(STR0004)//'Averbações de Tempo de Contribuição'
oModel:GetModel( 'SRAMASTER' ):SetOnlyView( .T. )

//Permissão de grid sem dados
oModel:GetModel( 'RIIDETAIL' ):SetOptional( .T. )
//Não permite incluir, alterar ou deletar as linhas do grid.
oModel:GetModel( 'RIIDETAIL' ):SetNoInsertLine( .T. )    
oModel:GetModel( 'RIIDETAIL' ):SetNoUpdateLine( .T. )    
oModel:GetModel( 'RIIDETAIL' ):SetNoDeleteLine( .T. )    

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc}ViewDef  
Averbações de Tempo de Contribuição
@owner Tania Bronzeri
@author Tania Bronzeri
@since 27/11/2013
@version P11
@project M_RH001 - Gestão De Pessoas e Vida Funcional Ministério Público do Estado de Mato Grosso
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel( 'VDFA100' )
Local oStruSRA := FWFormStruct( 2, 'SRA' )
Local oStruRII := FWFormStruct( 2, 'RII' )
Local oView  
Local cCposLib	:= ""

cCposLib := "RA_FILIAL,RA_MAT,RA_NOME"
SX3->(DbSetOrder(1))
SX3->(MsSeek("SRA"))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SRA"
	If (!Alltrim(SX3->X3_CAMPO) $ cCposLib) 
		If X3USO(SX3->X3_USADO)
			oStruSRA:SetProperty(Alltrim(SX3->X3_CAMPO), MODEL_FIELD_OBRIGAT, .F. )
		EndIF
		oStruSRA:RemoveField(Alltrim(SX3->X3_CAMPO))
 	EndIf
	SX3->(dbSkip())
EndDo

cCposLib := " "
SX3->(DbSetOrder(1))
SX3->(MsSeek("RII"))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "RII"
	If (!Alltrim(SX3->X3_CAMPO) $ cCposLib) 
		If X3USO(SX3->X3_USADO)
			oStruRII:SetProperty(Alltrim(SX3->X3_CAMPO), MVC_VIEW_CANCHANGE, .F. )
		EndIF
 	EndIf
	SX3->(dbSkip())
EndDo

oStruSRA:RemoveField( 'SRA_FILIAL' )
oStruSRA:RemoveField( 'SRA_MAT' )
oStruRII:RemoveField( 'RII_MAT' )
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_SRA', oStruSRA, 'SRAMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_RII',  oStruRII,  'RIIDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SERVIDOR' , 15 )
oView:CreateHorizontalBox( 'AVERBACS' , 85 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_SRA', 'SERVIDOR' )
oView:SetOwnerView( 'VIEW_RII', 'AVERBACS' )

// Cria Ações Relacionadas
oView:AddUserButton(STR0005,'VDFIN100()',{|oView|VDFIN100(oView)})	//'Inclui Averbação'
oView:AddUserButton(STR0006,'VDFEX100()',{|oView|VDFEX100(oView,5)})	//'Exclui Averbação'

oView:SetNoDeleteLine('RIIDETAIL')
oView:SetCloseOnOk({||.T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VDFIN100  
Averbações de Tempo de Contribuição
@owner Tania Bronzeri
@author Tania Bronzeri
@since 27/11/2013
@version P11
@project M_RH001 - Gestão De Pessoas e Vida Funcional Ministério Público do Estado de Mato Grosso
/*/
//-------------------------------------------------------------------
Function VDFIN100(oView)
Local aArea			:= GetArea()
Local aSize	  		:= FWGetDialogSize( oMainWnd )
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local nOpRadio		:= 1
Local cOpRadio		:= SuperGetMV("MV_VDFHAVE", .F., 1)
Local cTpInformac	:= "" 
Local lRet			:= .T.

Local oGet
Local oFont  
Local bCancel 		:= {||oDlg:End(),lRet:=.F.}

Private cRiiFilial	:= Space(TamSx3("RII_FILIAL" )[1])
Private cRiiMat		:= Space(TamSx3("RII_MAT"    )[1])
Private cRiiTipInf	:= Space(TamSx3("RII_TIPINF" )[1])
Private cRiiTipAve	:= Space(TamSx3("RII_TIPAVE" )[1])
Private cRiiTipReg	:= Space(TamSx3("RII_TIPREG" )[1])
Private cRiiSessao	:= Space(TamSx3("RII_SESSAO" )[1])
Private cRiiNumCer	:= Space(TamSx3("RII_NUMCER" )[1])
Private cRiiOrgExp	:= Space(TamSx3("RII_ORGEXP" )[1])
Private cRiiContri	:= Space(TamSx3("RII_CONTRI" )[1])
Private nRiiTmpBru	:= 0	//RII_TMPBRU
Private nRiiDeduc	:= 0	//RII_DEDUC
Private nRiiTmpLiq	:= 0	//RII_TMPLIQ
Private dRiiDtAverb	:= CtoD("  /  /    ") 
Private dRiiDtCert	:= CtoD("  /  /    ")
Private dRiiPerDe	:= CtoD("  /  /    ")
Private dRiiPerAte	:= CtoD("  /  /    ")
Private aCombTP		:= {} 
Private aCombEC		:= {}
Private aCombTR		:= {} 
Private oCombTP             
Private oCombEC          
Private oCombTR   
Private oEnchoice 

nOpRadio	:= fVd100OpcRad() //Iif(cOpRadio == "1", fVd100OpcRad(), 1)
If nOpRadio == 0
	Return oView:Refresh()
Else 
	cTpInformac	:= Iif(	nOpRadio == 1, " *** NOVO ***  ", 	"*** HISTORICO ***"	)
EndIf


// Monta as Dimensoes dos Objetos         					   ³
aAdvSize		:= MsAdvSize()
aAdvSize[5]		:= (aAdvSize[5]/100) * 70	//horizontal
aAdvSize[6]		:= (aAdvSize[6]/100) * 80	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 

aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

Begin Sequence
DEFINE FONT oFont NAME "Arial" SIZE 0,-18 
DEFINE MSDIALOG oDlg TITLE STR0007 FROM aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL//"Averbação de Tempo de Contribuição"

aCombTP := {"",STR0008,STR0009}//"1=Tempo para Averbação de Contribuição em Outros Órgãos"//"2=Tempo Simples ou em Dobro de Licença-Prêmio e Férias Não Gozadas"
If nOpRadio <> 1
	Aadd(aCombTP, STR0050)	//"3=Tempo de comissionado antes da efetivacao"
EndIf

aCombEC := {"",STR0010,STR0011}//"1=RGPS (INSS)"//"2=RPPS (Previdência Própria)"
aCombTR := {"",STR0012,STR0013}//"1=Estatutário"//"2=CLT"

//Panel1
@ aObjSize[1,1]+20, aObjSize[1,2]+010 SAY STR0014 SIZE 30,10 PIXEL //"Filial:"
@ aObjSize[1,1]+18, aObjSize[1,2]+032 MSGET oGet VAR SRA->RA_FILIAL SIZE 30,10 PIXEL WHEN .F.
    	  
@ aObjSize[1,1]+20, aObjSize[1,2]+77 SAY STR0015 SIZE 30,10 PIXEL //"Matrícula:"
@ aObjSize[1,1]+18, aObjSize[1,2]+103 MSGET oGet VAR SRA->RA_MAT SIZE 30,10 PIXEL WHEN .F.

@ aObjSize[1,1]+20, aObjSize[1,2]+140 SAY STR0016 SIZE 25,10 PIXEL //"Tp.Averbação:"
@ aObjSize[1,1]+18, aObjSize[1,2]+170 MSCOMBOBOX oCombTP VAR cRiiTipAve ITEMS aCombTP SIZE 195,10 OF oDlg PIXEL WHEN .T.

oSay:= TSay():New( aObjSize[1,1]+18, aObjSize[1,2]+390, { || cTpInformac },oDlg,,oFont,,,,.T.,,,100,20 )

@ aObjSize[1,1]+40, aObjSize[1,2]+010 SAY Replicate("-",(aAdvSize[5]/100)*23) SIZE (aAdvSize[5]/100)*60,10 OF oDlg PIXEL //"----"

@ aObjSize[1,1]+65, aObjSize[1,2]+010 SAY STR0017 SIZE 50,10 OF oDlg PIXEL //"Data da Averbação"
@ aObjSize[1,1]+63, aObjSize[1,2]+70  MSGET oGet VAR dRiiDtAverb PICTURE "@D" SIZE 60,10 OF oDlg PIXEL 

@ aObjSize[1,1]+65, aObjSize[1,2]+175 SAY STR0018 SIZE 100,10 OF oDlg PIXEL //"Tp.Regime"
@ aObjSize[1,1]+63, aObjSize[1,2]+215 MSCOMBOBOX oCombTR VAR cRiiTipReg ITEMS aCombTR SIZE 58,10 OF oDlg PIXEL WHEN .T.
    
@ aObjSize[1,1]+85, aObjSize[1,2]+010 SAY STR0019 SIZE 100,10 OF oDlg PIXEL //"Sessão"
@ aObjSize[1,1]+83, aObjSize[1,2]+70  MSGET oGet VAR cRiiSessao  PICTURE "@!" SIZE 100,10 OF oDlg PIXEL 
    
@ aObjSize[1,1]+85, aObjSize[1,2]+175 SAY STR0020 SIZE 100,10 OF oDlg PIXEL //"Num.Certidão"
@ aObjSize[1,1]+83, aObjSize[1,2]+215 MSGET oGet VAR cRiiNumCer  PICTURE "@!" SIZE 58,10 OF oDlg PIXEL 
    
@ aObjSize[1,1]+85, aObjSize[1,2]+285 SAY STR0021 SIZE 100,10 OF oDlg PIXEL //"Data Certidão"
@ aObjSize[1,1]+83, aObjSize[1,2]+335 MSGET oGet VAR dRiiDtCert PICTURE "@D" SIZE 95,10 OF oDlg PIXEL 

@ aObjSize[1,1]+105, aObjSize[1,2]+010 SAY STR0022 SIZE 100,10 OF oDlg PIXEL //"Órgão Exped."
@ aObjSize[1,1]+103, aObjSize[1,2]+70  MSGET oGet VAR cRiiOrgExp PICTURE "@!" SIZE 357,10 OF oDlg PIXEL 

@ aObjSize[1,1]+125, aObjSize[1,2]+010 SAY STR0023 SIZE 100,10 OF oDlg PIXEL //"Período De"
@ aObjSize[1,1]+123, aObjSize[1,2]+70  MSGET oGet VAR dRiiPerDe  PICTURE "@D" SIZE 60,10 OF oDlg PIXEL 

@ aObjSize[1,1]+125, aObjSize[1,2]+175 SAY STR0024 SIZE 100,10 OF oDlg PIXEL //"Período Até"
@ aObjSize[1,1]+123,aObjSize[1,2]+215 MSGET oGet VAR dRiiPerAte PICTURE "@D" SIZE 58,10 OF oDlg PIXEL 

@ aObjSize[1,1]+125, aObjSize[1,2]+285 SAY STR0025 SIZE 100,10 OF oDlg PIXEL //"Ent.Contrib."
@ aObjSize[1,1]+123, aObjSize[1,2]+335 MSCOMBOBOX oCombEC VAR cRiiContri ITEMS aCombEC SIZE 95,10 OF oDlg PIXEL WHEN .T.

@ aObjSize[1,1]+145, aObjSize[1,2]+010 SAY STR0026 SIZE 100,10 OF oDlg PIXEL //"Tempo Bruto"
@ aObjSize[1,1]+143, aObjSize[1,2]+70  MSGET oGet VAR nRiiTmpBru PICTURE "@R 999999" VALID {||nRiiTmpLiq := nRiiTmpBru - nRiiDeduc, oDlg:Refresh()} SIZE 60,10 OF oDlg PIXEL 

@ aObjSize[1,1]+145, aObjSize[1,2]+175 SAY STR0027 SIZE 100,10 OF oDlg PIXEL //"Deduções"
@ aObjSize[1,1]+143, aObjSize[1,2]+215 MSGET oGet VAR nRiiDeduc  PICTURE "@R 999999" VALID {||nRiiTmpLiq := nRiiTmpBru - nRiiDeduc, oDlg:Refresh()} SIZE 56,10 OF oDlg PIXEL 
                
@ aObjSize[1,1]+145, aObjSize[1,2]+285 SAY STR0028 SIZE 100,10 OF oDlg PIXEL //"Tempo Liq."
@ aObjSize[1,1]+143, aObjSize[1,2]+335 MSGET oGet VAR nRiiTmpLiq PICTURE "@R 999999" VALID {||nRiiTmpLiq := nRiiTmpBru - nRiiDeduc, oDlg:Refresh()} SIZE 95,10 OF oDlg PIXEL WHEN .F.


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||lRet:=Vd100GrvRii(nOpRadio,oView),IIF(lRet,oDlg:End(),oView:Refresh()),oView:Refresh()},bCancel)

End Sequence 

RestArea(aArea)
Return oView:Refresh()


//-------------------------------------------------------------------
/*/{Protheus.doc} fVd100OpcRad  
Monta dialogo para selecao com botoes de radio
@owner RH
@author Equipe R.H.
@since 26/10/2001
@version P11
@project M_RH001 - Gestão De Pessoas e Vida Funcional Ministério Público do Estado de Mato Grosso
/*/
//-------------------------------------------------------------------
Function fVd100OpcRad(nOpcRadio, cTitJan, cTitBox, cTitRad1, cTitRad2)
	Local nOpcAux
	Local oRadio
	Local oDlg
	Local oGroup
	Local oFont
	Local bSet15
	Local bSet24
	
	// Declaração de arrays para dimensionar tela
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aGDCoord		:= {}
	
    Default nOpcRadio	:= 1
    Default cTitJan		:= STR0029  //"Tipo de Registro da Informação"
    Default cTitBox		:= STR0030	//"Selecione a Modalidade"
	Default cTitRad1	:= STR0031	//'"N" - Novo'
	Default cTitRad2 	:= STR0032	//'"H" - Histórico'
	
	nOpcAux   := nOpcRadio
	nOpcRadio := 0
	
	// Monta as Dimensoes dos Objetos
	aAdvSize			:= MsAdvSize()
	aAdvSize[5]		:=	(aAdvSize[5]/110) * 30	//horizontal
	aAdvSize[6]		:=  (aAdvSize[6]/60) * 15	//Vertical
	aInfoAdvSize		:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
	
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
	aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*13), (((aObjSize[1,4])/100)*29) }	//1,3 Vertical /1,4 Horizontal
	
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg FROM  aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE OemToAnsi(cTitJan) PIXEL
		
		@ aGdCoord[1],aGdCoord[2] GROUP oGroup TO aGdCoord[3]+30,aGdCoord[4]-15 LABEL OemToAnsi(cTitBox) OF oDlg PIXEL
		oGroup:oFont:=oFont
		
		@ aGdCoord[1]+10,aGdCoord[2]+5 RADIO oRadio VAR nOpcAux ITEMS 	OemToAnsi(cTitRad1), OemToAnsi(cTitRad2);
		          SIZE 115,010 OF oDlg PIXEL
		
		bSet15 := {|| nOpcRadio := nOpcAux, oDlg:End()}
		bSet24 := {|| nOpcRadio := 0,       oDlg:End()}
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15, bSet24, Nil, Nil) CENTERED
	
Return( nOpcRadio ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} Vd100GrvRii  
Averbações de Tempo de Contribuição
@owner Tania Bronzeri
@author Tania Bronzeri
@since 27/11/2013
@version P11
@project M_RH001 - Gestão De Pessoas e Vida Funcional Ministério Público do Estado de Mato Grosso
/*/
//-------------------------------------------------------------------
Function Vd100GrvRii(nOpRadio,oView)
Local aRiiArea		:= RII->(GetArea())
Local aSraArea		:= SRA->(GetArea())
Local lOk			:= .F.
Local oModel 	  	:= FWModelActive()
Local oModelRII 	:= oModel:GetModel( 'RIIDETAIL' ), nLine := 0
   
DbSelectArea("RII")
DbSetOrder(1)
If DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+DtoS(dRiiPerDe)+DtoS(dRiiPerAte))
	MsgAlert(STR0033,STR0034) //"Já existe averbação para este período. Verifique as informações.","Atenção!"
Else     
	lOk := fRiiValido(nOpRadio)
	If lOk
			
		oModelRII:SetNoUpdateLine( .F. )    
		oModelRII:SetNoInsertLine( .F. )
		
		if !Empty(oModelRII:GetValue("RII_TIPINF"))  //Já possui linha vazia criada automaticamente não sendo necessário criar uma nova linha.    
			nLine := oModelRII:AddLine(.T.)
		EndIf
		
		M->RII_SEQUEN := GetSXENum("RII","RII_SEQUEN")
		oModelRII:SetValue("RII_PERDE",dRiiPerDe)
		oModelRII:SetValue("RII_PERATE",dRiiPerAte)
		oModelRII:SetValue("RII_TIPINF",Iif(nOpRadio==1,"N","H"))
		oModelRII:SetValue("RII_TIPAVE",cRiiTipAve)
		oModelRII:SetValue("RII_TIPREG",cRiiTipReg)
		oModelRII:SetValue("RII_SESSAO",cRiiSessao)//ok
		oModelRII:SetValue("RII_DTAVER",dRiiDtAverb)//ok
		oModelRII:SetValue("RII_NUMCER",cRiiNumCer)
		oModelRII:SetValue("RII_DTCERT",dRiiDtCert)
		oModelRII:SetValue("RII_ORGEXP",cRiiOrgExp)
		oModelRII:SetValue("RII_TMPBRU",nRiiTmpBru)
		oModelRII:SetValue("RII_DEDUC",nRiiDeduc)
		oModelRII:SetValue("RII_TMPLIQ",nRiiTmpLiq)
		oModelRII:SetValue("RII_SEQUEN",M->RII_SEQUEN)//ok
		oModelRII:SetValue("RII_CONTRI",cRiiContri)

		Begin Transaction
			RecLock("RII",.T.)
			RII->RII_FILIAL 	:= SRA->RA_FILIAL
			RII->RII_MAT     	:= SRA->RA_MAT
			RII->RII_PERDE 	:= dRiiPerDe
			RII->RII_PERATE	:= dRiiPerAte
			RII->RII_TIPINF	:= Iif(nOpRadio==1,"N","H")
			RII->RII_TIPAVE 	:= cRiiTipAve
			RII->RII_TIPREG   := cRiiTipReg
			RII->RII_SESSAO	:= cRiiSessao
			RII->RII_DTAVER	:= dRiiDtAverb
			RII->RII_NUMCER	:= cRiiNumCer
			RII->RII_DTCERT	:= dRiiDtCert
			RII->RII_ORGEXP	:= cRiiOrgExp
			RII->RII_TMPBRU   := nRiiTmpBru
			RII->RII_DEDUC	:= nRiiDeduc
			RII->RII_TMPLIQ	:= nRiiTmpLiq
			RII->RII_SEQUEN	:= M->RII_SEQUEN
			RII->RII_CONTRI   := cRiiContri
			
			RII->(FKCommit())
			MsUnLock()
		End Transaction	
		
		If __lSX8
			ConfirmSX8()
		EndIf
		oModelRII:SetNoUpdateLine( .T. )    
		oModelRII:SetNoInsertLine( .T. )
		
		If nOpRadio == 1// se for do tipo Normal gerar publicação.
			cChave:= DTOS(oModelRII:GetValue("RII_PERDE"))+DTOS(oModelRII:GetValue("RII_PERATE"))+oModelRII:GetValue("RII_TIPAVE")+oModelRII:GetValue("RII_SEQUEN")
			VDFA060({'VDFA100',SRA->RA_MAT,SRA->RA_CATFUNC,cChave,SRA->RA_FILIAL,SRA->RA_CIC,SRA->RA_ADMISSA,'1','RII'})
		EndIf
	EndIf
EndIf

RestArea(aRiiArea)
RestArea(aSraArea)
oView:Refresh()
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc}	VDFEX100
Averbações de Tempo de Contribuição
@owner Tania Bronzeri
@author Tania Bronzeri
@since 27/11/2013
@version P11
@project M_RH001 - Gestão De Pessoas e Vida Funcional Ministério Público do Estado de Mato Grosso
/*/
//-------------------------------------------------------------------
Function VDFEX100(oView,nExclui)
Local aArea		:= GetArea()
Local cChave	:= DTOS(oView:GetValue('RIIDETAIL', 'RII_PERDE'))+DTOS(oView:GetValue('RIIDETAIL', 'RII_PERATE'))+oView:GetValue('RIIDETAIL', 'RII_TIPAVE')+oView:GetValue('RIIDETAIL', 'RII_SEQUEN')	
Local cTipo		:= "" //Tipo Informação Posicione("RII",1,SRA->RA_FILIAL+SRA->RA_MAT+cChave,"RII_TIPINF")
Local cAverb	:= "" //Tipo Averbação
Local cTpReg	:= "" //Tipo Regime
Local cEntContr := "" //Ent.Contrib.
Local cMensagem	:= ""
Local oModel	:= FWModelActive()
Local oModelRII := oModel:GetModel( 'RIIDETAIL' )
Local lRI6		:= .F.

cTipo	:= oView:GetValue('RIIDETAIL', 'RII_TIPINF')
cAverb	:= oView:GetValue('RIIDETAIL', 'RII_TIPAVE')
cTpReg	:= oView:GetValue('RIIDETAIL', 'RII_TIPREG')
cEntContr := oView:GetValue('RIIDETAIL', 'RII_CONTRI')

cMensagem := STR0035 + CRLF + CRLF	//"Deseja excluir a averbação selecionada ? "
cMensagem += STR0029 + ": " + If(cTipo = "N", STR0031, STR0032) + CRLF //"Tp. Informação: "
cMensagem += STR0016 + " " + If(cAverb == "1",STR0008,If(cAverb == "2",STR0009,STR0050)) + CRLF //"Tp. Averbação"
cMensagem += STR0018 + ": " + If(cTpReg == "1",STR0012,STR0013) + CRLF //"Tp. Regime"
cMensagem += STR0019 + ": " + oView:GetValue('RIIDETAIL', 'RII_SESSAO') + CRLF
cMensagem += STR0017 + ": " + DtoC(oView:GetValue('RIIDETAIL', 'RII_DTAVER')) + CRLF
cMensagem += STR0020 + ": " + oView:GetValue('RIIDETAIL', 'RII_NUMCER') + CRLF
cMensagem += STR0021 + ": " + DtoC(oView:GetValue('RIIDETAIL', 'RII_DTCERT')) + CRLF
cMensagem += STR0022 + ": " + oView:GetValue('RIIDETAIL', 'RII_ORGEXP') + CRLF
cMensagem += STR0023 + DtoC(oView:GetValue('RIIDETAIL', 'RII_PERDE')) + " "+"STR0024"+" " + DtoC(oView:GetValue('RIIDETAIL', 'RII_PERATE')) + CRLF
cMensagem += STR0025 + ": " + cEntContr + " - " + If(cEntContr = "1","RGPS (INSS)","RPPS (Previdência Própria)")

If MsgNoYes( cMensagem )//STR0035) //"Deseja excluir a averbação selecionada ? "
	If QueryRI6(cChave,SRA->RA_FILIAL,SRA->RA_MAT,"RII",oView,nExclui,@lRI6)
		If RII->(DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cChave))
			oModelRII:DeleteLine(.F.,.T.)
		EndIf
	Else
		MsgAlert(STR0036) //"Exclusão não autorizada! Averbação possui item já publicado."
	EndIf
EndIf	
RestArea(aArea)
oModelRII:GoLine(1)
oView:Refresh()
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc}	fRiiValido
Averbações de Tempo de Contribuição
@owner Tania Bronzeri
@author Tania Bronzeri
@since 27/11/2013
@version P11
@project M_RH001 - Gestão De Pessoas e Vida Funcional Ministério Público do Estado de Mato Grosso
/*/
//-------------------------------------------------------------------
Function fRiiValido(nOpRadio)
Local lRet	:= .T.

Do Case
	Case Empty(cRiiTipAve)
		MsgAlert(STR0038,STR0034) //"Favor informar o Tipo da Averbação.","Atenção!"
		lRet	:= .F.
	Case Empty(dRiiDtAverb)
		MsgAlert(STR0039,STR0034) //"Favor informar a Data da Averbação.","Atenção!"
		lRet	:= .F.
	Case Empty(cRiiTipReg)
		MsgAlert(STR0040,STR0034) //"Favor informar o Tipo do Regime da Averbação.","Atenção!"
		lRet	:= .F.
	Case Empty(cRiiSessao) .AND. nOpRadio == 2
		MsgAlert(STR0041,STR0034) //"Favor informar a Sessão.","Atenção!"
		lRet	:= .F.
	Case Empty(cRiiNumCer)
		MsgAlert(STR0042,STR0034) //"Favor informar o Número da Certidão Averbada.","Atenção!"
		lRet	:= .F.
	Case Empty(dRiiDtCert)
		MsgAlert(STR0043,STR0034) //"Favor informar a Data da Certidão Averbada.","Atenção!"
		lRet	:= .F.
	Case Empty(cRiiOrgExp)
		MsgAlert(STR0044,STR0034) //"Favor informar o Órgão Expedidor da Certidão Averbada.","Atenção!"
		lRet	:= .F.
	Case Empty(dRiiPerDe)
		MsgAlert(STR0045,STR0034) //"Favor informar o Início do Período Averbado.","Atenção!"
		lRet	:= .F.
	Case Empty(dRiiPerAte)
		MsgAlert(STR0046,STR0034) //"Favor informar o Fim do Período Averbado.","Atenção!"
		lRet	:= .F.
	Case Empty(cRiiContri)
		MsgAlert(STR0047,STR0034) //"Favor informar a Entidade de Contribuição.","Atenção!"
		lRet	:= .F.
	Case nRiiTmpBru <= 0
		MsgAlert(STR0048,STR0034) //"Favor informar o Número de Dias Brutos Relativos ao Período Averbado.","Atenção!"
		lRet	:= .F.
	Case nRiiTmpBru - nRiiDeduc < 0
		MsgAlert(STR0049,STR0034) //"Número de Dias Relativos às Deduções esta superior ao Tempo Bruto.","Atenção!"
		lRet	:= .F.
EndCase

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}	QueryRI6
Verifica se ja existe registro na RI6
@owner RH
@author Everson SP Junior
@since 10/11/2013
@version P11
@project M_RH001 - Gestão De Pessoas e Vida Funcional Ministério Público do Estado de Mato Grosso
/*/
//------------------------------------------------------------------- 
Static Function QueryRI6(cChave,cFil,cMat,cTab,oView,nExclui,lRI6)
Local cQuery 	:= ''
Local lRet		:= .F.

If Select("TRBRI6") > 0
	TRBRI6->( dbCloseArea())
EndIf	
cQuery  := "SELECT * "
cQuery  += " FROM " + RetSqlName( 'RI6' ) 
cQuery  += " WHERE D_E_L_E_T_ 	=' '
cQuery  += " AND RI6_FILMAT 	= '" +cFil+"'"
cQuery  += " AND RI6_TABORI 	= '" +cTab+"'"
cQuery  += " AND RI6_MAT		 	= '" +cMat+"'"
cQuery  += " AND RI6_CHAVE		= '"+cChave+"'" 
 
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBRI6", .F., .T.)

If	Empty(TRBRI6->RI6_NUMDOC) .AND. Empty(TRBRI6->RI6_ANO) 
	lRet := .T.
	lRI6 := .T.
EndIf

If TRBRI6->(EOF()) .AND. nExclui == 5 // Se não exitir registro na RI6 deve deletar so RII
	lRet := .T.
	lRI6 := .F.	
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}	Vdf100Grv
Averbações de Tempo de Contribuição - Deleta fisicamente os itens excluídos na grid.
@owner RH
@author esther.viveiro
@since 04/06/2018
@version P12
@project DRHGFP - Gestão Folha Pública
/*/
//-------------------------------------------------------------------
Static Function Vdf100Grv(oModel)
Local lRet		:= .T.
Local lRI6		:= .F.
Local cChave	:= ""
Local nLenGrid	:= 0
Local nLinAtual	:= 0
Local nLinha	:= 0
Local oModelRII := oModel:GetModel( 'RIIDETAIL' )

	nLenGrid	:= oModelRII:Length()
	nLinAtual 	:= oModelRII:GetLine()

	For nLinha := 1 to nLenGrid
		oModelRII:GoLine(nLinha)
		If !oModelRII:IsDeleted()
			Loop
		EndIf
		cChave := DTOS(oModelRII:GetValue('RII_PERDE'))+DTOS(oModelRII:GetValue('RII_PERATE'))+oModelRII:GetValue('RII_TIPAVE')+oModelRII:GetValue('RII_SEQUEN')
		If RII->(DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cChave))
			RII->(RecLock( "RII",.F., .F.))
			RII->(dbDelete())
			RII->(MsUnlock())
		EndIf	
		QueryRI6(cChave,SRA->RA_FILIAL,SRA->RA_MAT,"RII",,5,@lRI6)
		If lRI6
			RI6->(dbGoTo(TRBRI6->R_E_C_N_O_))
			RecLock("RI6",.F.,.T.)
			RI6->(dbDelete())
			RI6->(MsUnLock())
		EndIf
	Next nLinha
Return lRet