#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA870B.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA870B
Cadastro de layout  para configuracao de arquivos texto ( txt ).

@author Varejo
@since 29/05/2013
@version P11
/*/
//-------------------------------------------------------------------
Function LOJA870B()
Local oBrowse


oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'MFG' )
oBrowse:SetDescription( STR0001 )//'Cadastro de LayOut'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Menu Funcional

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRotina        := {}

ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"  			   OPERATION 0                         ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.LOJA870B"     OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.LOJA870B"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.LOJA870B"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.LOJA870B"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007 Action 'LJ870BVl' OPERATION 6 ACCESS 0 //"Visualiza Layout"

Return aRotina

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructMFG := FWFormStruct(1,"MFG") // Informe os campos que eu quero no cabecalho
Local oModel := Nil

//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA870B",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)

oModel:AddFields("MFGMASTER", Nil/*cOwner*/, oStructMFG ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)

oModel:SetPrimaryKey( { "MFG_FILIAL","MFG_CODIGO" } )
                                                                        
oModel:GetModel("MFGMASTER"):SetDescription(STR0001)


Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da Visao

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView        := Nil
Local oModel       := FWLoadModel("LOJA870B")
Local oStructMFG := FWFormStruct(2,"MFG") // Informe os campos que eu quero no cabecalho
//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
            

oView:AddField( "VIEWMFG" , oStructMFG, "MFGMASTER" )
 
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWMFG' , 'SUPERIOR' )
                               
oView:EnableTitleView( 'VIEWMFG' )
                                                       	
Return oView


//-------------------------------------------------------------------
/*{Protheus.doc} LJ870BVl
Visualiza a Layout configurado

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Function LJ870BVl()
Local oDlg   := Nil // objeto principal da tela
Local oFolder:= Nil // objeto folder para visualizar
Local oCabec := Nil // objeto para o cabecalho
Local oRegist:= Nil // objeto para o registro
Local oRodape:= Nil // objeto para o rodape
Local nOpcA     := 0// sem opção para incluir/alterar/excluir  
Local nFreeze	:= 0// sem freeze
Local nMax		:= 999999999 // maximo de itens
Local cLinOk	:= "AllwaysTrue"   // sempre .T.
Local cTudoOk	:= "AllwaysTrue"   // sempre .T.
Local cIniCpos	:= ""              // sem inicializador
Local cFieldOk	:= "AllwaysTrue"  // sempre .T.
Local cSuperDel	:= ""             // sem validação
Local cDelOk	:= "AllwaysTrue"  // sempre .T.
Local aAlter    := {}             //Array para campos que podem ser alterados
Local aTitles:= {STR0008,STR0009,STR0010}  // array com os folder para visualizar. //"Cabeçalho"##"Registro"##"Rodapé"
Local aHeader:= LjMontaHeader()// monta aHeader para tela
Local aCabec := LjMontaCols(aHeader,'1') //carrega aCols para exibir na tela
Local aRegist:= LjMontaCols(aHeader,'2') //carrega aCols para exibir na tela
Local aRodape:= LjMontaCols(aHeader,'3') //carrega aCols para exibir na tela
Local aSize     := MsAdvSize()           // Tamanho da tela
         

	DEFINE MSDIALOG oDlg TITLE STR0011+MFE->MFE_CODIGO From aSize[7],0 To aSize[6]/1.5,aSize[5]/1.5 OF oMainWnd PIXEL//"Layout "
	oFolder := TFolder():New(000,000,aTitles,{"HEADER"},oDlg,,,, .T., .F.,315,140)
	oFolder:Align:= CONTROL_ALIGN_ALLCLIENT	       
	  
	
	oCabec := MsNewGetDados():New(000,000,000,000,nOpcA,cLinOk,cTudoOk,cIniCpos,aAlter,;
						  	nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oFolder:aDialogs[1],@aHeader,@aCabec)
	oCabec:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT	
	
	oRegist := MsNewGetDados():New(000,000,000,000,nOpcA,cLinOk,cTudoOk,cIniCpos,aAlter,;
						  	nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oFolder:aDialogs[2],@aHeader,@aRegist)
	oRegist:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT	

	oRodape := MsNewGetDados():New(000,000,000,000,nOpcA,cLinOk,cTudoOk,cIniCpos,aAlter,;
						  	nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oFolder:aDialogs[3],@aHeader,@aRodape)
	oRodape:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()})
Return()	 
  
//-------------------------------------------------------------------
/*{Protheus.doc} LJ870BVl
Monta aHeader para tela

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function LjMontaHeader()

Local aHeader:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta aHeader para GetDados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader:= {}
dbSelectArea("SX3")
dbSetOrder(1)
If dbSeek("MFE")
	While !Eof() .AND. SX3->X3_ARQUIVO == "MFE"
		If !Alltrim(SX3->X3_CAMPO) $ "MFE_FILIAL|MFE_TIPO||MFE_DESCRI|MFE_CARACT|MFE_CODIGO|MFE_RETSEP"
			AAdd(aHeader,	{AllTrim(X3Titulo()),;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT})			
			EndIf	
		SX3->(dbSkip())
	EndDo	
EndIf                         

Return aHeader

//-------------------------------------------------------------------
/*{Protheus.doc} LjMontaCols
Monta aHeader para tela

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function LjMontaCols(aHeader,cTipo)

Local aCols := {}
Local nCntFor:= 1
Local cWhile:= ''
 
MFF->(DbSetOrder(1))		 
If MFF->(DbSeek(xFilial("MFF")+ MFG->MFG_CODBLO ))
	If cTipo == '1'
		cWhile:= MFF->MFF_CABECA
    ElseIf cTipo == '2'
    	cWhile:= MFF->MFF_REGIST
    ElseIf cTipo == '3'
    	cWhile:= MFF->MFF_RODAPE
    EndIf
	//Verifica se o cabecalho, registro e rodape que foram vinculados ao bloco
	// Cabecalho
	MFE->(DbSetOrder(1))
	MFE->(DbSeek(xFilial("MFE")+ cWhile,.T. ))

	While MFE->(!EOF()) .AND. MFE->MFE_CODIGO == cWhile
		Aadd(aCols,Array(Len(aHeader)+1))
		aCols[Len(aCols)][Len(aHeader)+1] := .F.
		For nCntFor := 1 To Len(aHeader)
			If ( aHeader[nCntFor][10] != "V" )
				aCols[Len(aCols)][nCntFor] := &("MFE"+"->"+aHeader[nCntFor][2]) 
			Else
				aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
			EndIf
		Next		
		
		MFE->(DbSkip())			
	EndDo 
EndIf

Return aCols
