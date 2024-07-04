#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OGAA770.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} OGAA770
Cadastro MVC das Pautas Fiscais de ICMS

@author Rafael Völtz
@since 03/02/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Function OGAA770()

Local	oBrw		:=	FWmBrowse():New()
Private _lCopy := .F.

//Proteç?o
If !TableInDic('N8R')
	Help( , , STR0007, , STR0022, 1, 0 ) //"Ajuda" //"Para acessar esta funcionalidade é necessario atualizar o dicionario do Protheus."
	Return(Nil)
EndIf 

oBrw:SetDescription( STR0010 ) //"Pauta Fiscal de ICMS por Tipo"                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
oBrw:SetAlias( 'N8R' )
oBrw:SetCacheView( .F. )
oBrw:SetMenuDef( 'OGAA770' )
oBrw:Activate()

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rafael Völtz
@since 20/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0001 	ACTION "OGAA7700VIS"  	OPERATION 2 ACCESS 0 		//"Visualizar"
ADD OPTION aRotina TITLE STR0002    	ACTION "OGAA770INSR" 	OPERATION 3 ACCESS 0 	//Incluir
ADD OPTION aRotina TITLE STR0003    	ACTION "OGAA770UPD" 	OPERATION 4 ACCESS 143	//Alterar
ADD OPTION aRotina TITLE STR0004      ACTION "OGAA7700DEL" 	OPERATION 5 ACCESS 144		//Excluir
ADD OPTION aRotina TITLE STR0005       ACTION "OGAA770CPY" OPERATION 9 ACCESS 0			//Copiar

Return( aRotina )

Function OGAA770INSR
  
  FWExecView('', 'VIEWDEF.OGAA770', MODEL_OPERATION_INSERT, , {|| .T. })  //executado para refazer a view - reload da estrutura de campos

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OGAA770UPD
Função para executar o menu de update

@author Rafael Völtz
@since 20/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function OGAA770UPD
  
  FWExecView('', 'VIEWDEF.OGAA770', MODEL_OPERATION_UPDATE, , {|| .T. })  //executado para refazer a view - reload da estrutura de campos

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OGAA7700DEL
Função para executar o menu de delete

@author Rafael Völtz
@since 20/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function OGAA7700DEL
  
  FWExecView('', 'VIEWDEF.OGAA770', MODEL_OPERATION_DELETE, , {|| .T. })  //executado para refazer a view - reload da estrutura de campos

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OGAA770CPY
Função para executar o menu de copy

@author Rafael Völtz
@since 20/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function OGAA770CPY()
	
	_lCopy := .T.
	Private _aNCPN8R	:= {"N8R_CODIGO"}
	FWExecView('', 'VIEWDEF.OGAA770', 9, , {|| .T. }) 
	
	_lCopy := .F.
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} OGAA7700VIS
Função para executar o menu de view

@author Rafael Völtz
@since 20/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function OGAA7700VIS
  
  FWExecView('', 'VIEWDEF.OGAA770', MODEL_OPERATION_VIEW, , {|| .T. })  //executado para refazer a view - reload da estrutura de campos

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rafael Völtz
@since 20/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruN8R   := FWFormStruct( 1, 'N8R', {|cCampo| ALLTRIM(cCampo) $ "N8R_PROD|N8R_DPROD|N8R_UFORIG|N8R_UFDEST|N8R_DTINVG" } )
	Local oStruN8RGr := FWFormStruct( 1, 'N8R' )
	Local oModel 	 := MPFormModel():New( 'OGAA770', /*bPre */, {|oModel| validaPos(oModel) },  { |oModel| SaveModel( oModel ) }, /*bCancel */)
	Local nIt        := 1
	Local lCopy		 := (Type("_lCopy") == "L" .AND. _lCopy)
	
	If lCopy		
		If !Empty(_aNCPN8R) .AND. Len(_aNCPN8R) == 1 .AND. "*" $ _aNCPN8R[1]
			For nIt := 1 To Len(oStruN8R:GetFields())
				aAdd(_aNCPN8R, oStruN8R:GetFields()[nIt][3])
			Next nIt
		EndIf
	EndIf
	
	oModel:AddFields( 'MODEL_N8R' , /*cOwner*/,  oStruN8R)
	oModel:AddGrid ( 'MODEL_GRID', 'MODEL_N8R', oStruN8RGr, , , , ,)
	
	oStruN8RGr:SetProperty("N8R_PROD", MODEL_FIELD_OBRIGAT , .F.)
	oStruN8RGr:SetProperty("N8R_UFORIG", MODEL_FIELD_OBRIGAT , .F.)
	oStruN8RGr:SetProperty("N8R_UFDEST", MODEL_FIELD_OBRIGAT , .F.)	
	oStruN8R:SetProperty("N8R_DTINVG", MODEL_FIELD_OBRIGAT , .T.)
	oStruN8R:SetProperty("N8R_UFDEST", MODEL_FIELD_VALID , {|oField| VldDupl(oField,"N8R_UFDEST")})
	oStruN8R:SetProperty("N8R_UFORIG", MODEL_FIELD_VALID , {|oField| VldDupl(oField,"N8R_UFORIG")})
	oStruN8R:SetProperty("N8R_PROD", MODEL_FIELD_VALID , {|oField| VldDupl(oField,"N8R_PROD")})
	oStruN8R:SetProperty("N8R_DTINVG", MODEL_FIELD_VALID , {|oField| VldDupl(oField,"N8R_DTINVG")})
	
	oModel:SetRelation( 'MODEL_GRID' , { { 'N8R_FILIAL' , 'xFilial( "N8R" )' } , { 'N8R_PROD' , 'N8R_PROD' }, { 'N8R_UFORIG' , 'N8R_UFORIG' }, { 'N8R_UFDEST' , 'N8R_UFDEST' }, { 'N8R_DTINVG' , 'N8R_DTINVG' }} , N8R->( IndexKey( 1 ) ) )
	
	oModel:GetModel( 'MODEL_N8R' ):SetPrimaryKey( { 'N8R_PROD', 'N8R_UFORIG', 'N8R_UFDEST', 'N8R_DTINVG'} )
	oModel:GetModel( 'MODEL_GRID'):SetUniqueLine( { 'N8R_PROD', 'N8R_UFORIG', 'N8R_UFDEST', 'N8R_TIPO'} )
	oModel:GetModel( 'MODEL_N8R' ):SetDescription(STR0006 ) //Pauta Fiscal de ICMS
	
	If lCopy
		oStruN8R:SetProperty("N8R_UFORIG", MODEL_FIELD_INIT , {|| N8R->N8R_UFORIG})
		oStruN8R:SetProperty("N8R_UFDEST", MODEL_FIELD_INIT , {|| N8R->N8R_UFDEST})
		oStruN8R:SetProperty("N8R_PROD", MODEL_FIELD_INIT , {|| N8R->N8R_PROD})
		oStruN8R:SetProperty("N8R_DTINVG", MODEL_FIELD_INIT , {|| N8R->N8R_DTINVG})
		
		oModel:GetModel( 'MODEL_GRID' ):SetNoInsertLine( .T. )
		oModel:GetModel( 'MODEL_GRID' ):SetNoDeleteLine( .T. )
		oModel:GetModel( "MODEL_GRID" ):SetFldNoCopy(_aNCPN8R)
	EndIf

Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rafael Völtz
@since 20/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel 	 := FWLoadModel( 'OGAA770' )
	
	Local oStruN8R   := FWFormStruct( 2, 'N8R',   { |x| ALLTRIM(x) $ 'N8R_PROD, N8R_DPROD, N8R_UFORIG, N8R_UFDEST, N8R_DTINVG' } )
	Local oStruN8RGr := FWFormStruct( 2, 'N8R' /*, {   |x| !ALLTRIM(x) $ 'N8R_CODIGO,  N8R_PROD, N8R_DPROD, N8R_UFORIG, N8R_UFDEST' }*/  )
	
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	
	oStruN8RGr:SetProperty("N8R_DTINVG", MVC_VIEW_CANCHANGE , .F.)
	If !IsInCallStack("OGAA770INSR") .and. !IsInCallStack("OGAA770CPY")
		oStruN8R:SetProperty("N8R_PROD", MVC_VIEW_CANCHANGE , .F.)
		oStruN8R:SetProperty("N8R_UFORIG", MVC_VIEW_CANCHANGE , .F.)
		oStruN8R:SetProperty("N8R_UFDEST", MVC_VIEW_CANCHANGE , .F.)
		oStruN8R:SetProperty("N8R_DTINVG", MVC_VIEW_CANCHANGE , .F.)
	ElseIf IsInCallStack("OGAA770CPY")
		oStruN8R:SetProperty("N8R_PROD", MVC_VIEW_CANCHANGE , .F.)
		oStruN8R:SetProperty("N8R_UFORIG", MVC_VIEW_CANCHANGE , .F.)
		oStruN8RGr:SetProperty("N8R_TIPO", MVC_VIEW_CANCHANGE , .F.)
	EndIf 
	
	oStruN8RGr:RemoveField("N8R_PROD")
	oStruN8RGr:RemoveField("N8R_DPROD")
	oStruN8RGr:RemoveField("N8R_UFDEST")
	oStruN8RGr:RemoveField("N8R_UFORIG")
	oStruN8RGr:RemoveField("N8R_DTINVG")
	oStruN8RGr:RemoveField("N8R_CODIGO")
	
	oView:AddField( 'VIEW_N8R', oStruN8R, 'MODEL_N8R' )						
	oView:AddGrid ( 'VIEW_N8RGR', oStruN8RGr, 'MODEL_GRID' )
	
	oView:CreateHorizontalBox( 'FIELDSN8R', 20 )
	oView:CreateHorizontalBox( 'FIELDSN8RGRID', 80 )
	
	oView:SetOwnerView( 'VIEW_N8R', 'FIELDSN8R' )
	oView:SetOwnerView( 'VIEW_N8RGR', 'FIELDSN8RGRID' )


Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Função de commit do model

@author Rafael Völtz
@since 20/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)
	Local oModelN8R    := oModel:GetModel("MODEL_N8R")
	Local oModelGrd    := oModel:GetModel("MODEL_GRID")
	Local nX           := 1	
	Local aRegGrav     := {}
	Local nUF          := 1
	Local nSaveSx8     := GetSX8Len()
	Local oView		   := FwViewActive()	
	
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .and. oModelN8R:GetValue("N8R_UFDEST") == '**'			
			BEGIN TRANSACTION	
				SX5->(DbSetOrder(1))			
				If (SX5->(Dbseek(xFilial("SX5")+'12')))
					While SX5->(!Eof()) .And. SX5->X5_FILIAL == xFilial("SX5") .And. SX5->X5_TABELA == '12' 
					   While nX <= oModelGrd:length()
							oModelGrd:GoLine(nX)
							If !oModelGrd:IsDeleted(nX)
								If (Alltrim(SX5->X5_CHAVE) == N8R->N8R_UFDEST .And. _lCopy) .OR. Alltrim(SX5->X5_CHAVE) =='EX'  //não faz cópia da UF corrente e tb de EX
								Else 
									Iif(nUF == 1, cCodigo := oModelGrd:GetValue("N8R_CODIGO"), cCodigo := GetSXENum('N8R','N8R_CODIGO')) 
									aAdd(aRegGrav, {xFilial("N8R"),cCodigo,alltrim(oModelN8R:GetValue("N8R_PROD")), "", alltrim(oModelGrd:GetValue("N8R_TIPO")), "", alltrim(oModelN8R:GetValue("N8R_UFORIG")), ALLTRIM(SX5->X5_CHAVE),  oModelGrd:GetValue("N8R_VLICMP"), oModelGrd:GetValue("N8R_VLFOBP"), oModelN8R:GetValue("N8R_DTINVG")})
	                            EndIf								
							EndIf
							nX++
					   EndDo
					   		
					   oModelGrd:GoLine(1)
					   nX := 1
					   nUF++	
					   SX5->(DbSkip())					
					EndDo
				EndIf
				
				nX := 1			
			
				While nX <= Len(aRegGrav)				
						
						RecLock("N8R",.T.)
						N8R->N8R_FILIAL := aRegGrav[nX][1]
						N8R->N8R_CODIGO	:= aRegGrav[nX][2]                                                                                                
						N8R->N8R_PROD   := aRegGrav[nX][3]
						N8R->N8R_TIPO   := aRegGrav[nX][5]
						N8R->N8R_UFORIG := aRegGrav[nX][7]
						N8R->N8R_UFDEST  := aRegGrav[nX][8]
						N8R->N8R_VLICMP  := aRegGrav[nX][9]
						N8R->N8R_VLFOBP  := aRegGrav[nX][10]
						N8R->N8R_DTINVG := aRegGrav[nX][11]
						MsUnLock()						
						
					nX++
				EndDo	
				
				 While (GetSX8Len() > nSaveSx8)
                     ConfirmSX8()
                 End
			
			END TRANSACTION
			
			oView:Refresh()
	Else
		FwFormCommit(oModel)
	EndIf
	
	
REturn .t.


//-------------------------------------------------------------------
/*/{Protheus.doc} validaPos
Função de validacao do model

@author Rafael Völtz
@since 20/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function validaPos(oModel)	
	Local lRet := .T.
	Local nX   := 1
	Local oModelN8R := oModel:GetModel("MODEL_N8R")
	Local oModelGrd := oModel:GetModel("MODEL_GRID")
	
	If !VldDupl(oModelN8R)
		lRet := .F.
	EndIf
	
	If !VldDupl(oModelN8R)
		lRet := .F.
	EndIf
	
	 While nX <= oModelGrd:length()
		oModelGrd:GoLine(nX)
		If !oModelGrd:IsDeleted(nX)
			If oModelGrd:GetValue("N8R_VLICMP") == 0 .and. oModelGrd:GetValue("N8R_VLFOBP") == 0
				Help( , , STR0007, , STR0011 + oModelGrd:GetValue("N8R_TIPO") , 1, 0, ,,,,,{STR0012} ) //Valor de pauta não informado para o tipo  //Informe um valor de pauta. 
				lRet := .F.
			EndIf			
		EndIf
		nX++
   EndDo
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldDupl
Função de validacao de registro duplicado

@author Rafael Völtz
@since 20/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldDupl(oField, cField)
	Local lRet   := .T.
	Local cAlias := ""	
	Local cUFDest   := oField:GetValue("N8R_UFDEST")
	Local cUf       := "" 	
	Local oModel    := oField:GetModel()
	Default cField  := ""
	
	If cField $ "N8R_PROD"			
		SB1->(DbSetOrder(1))
		If !SB1->(DBSEEK(xFilial("SB1")+oField:GetValue("N8R_PROD")))		
			lRet := .F.
			oModel:GetModel():SetErrorMessage( oModel:GetId(), , oModel:GetId(), "", "", STR0013 , STR0014, "", "") //Produto não cadastrado. //Informe um código que exista no cadastro.
		EndIf
	EndIf
	
	If cField $ "N8R_UFORIG"
		SX5->(DbSetOrder(1))
		If !SX5->(DBSEEK(xFilial("SX5")+'12'+oField:GetValue("N8R_UFORIG")))		
			lRet := .F.
			oModel:GetModel():SetErrorMessage( oModel:GetId(), , oModel:GetId(), "", "", STR0015 , STR0016, "", "") //UF não cadastrada.  //Informe uma UF que exista no cadastro.
		EndIf
	EndIf                                                                                                                 
	
	If cField $ "N8R_UFDEST"	
		IF oField:GetValue("N8R_UFDEST") != '**'
			SX5->(DbSetOrder(1))
			If !SX5->(DBSEEK(xFilial("SX5")+'12'+oField:GetValue("N8R_UFDEST")))		
				lRet := .F.
				oModel:GetModel():SetErrorMessage( oModel:GetId(), , oModel:GetId(), "", "", STR0017 , STR0018, "", "") //UF não cadastrada.  //Informe uma UF que exista no cadastro.
			EndIf                                                                                                                 
		EndIf
	EndIf
		
	If lRet
		If oField:GetOperation() == MODEL_OPERATION_INSERT  
			If !Empty(oField:GetValue("N8R_PROD")) .And. !Empty(oField:GetValue("N8R_UFORIG")) .and. !Empty(oField:GetValue("N8R_UFDEST")) .and. !Empty(oField:GetValue("N8R_DTINVG"))
			    If cUFDest == "**"
					SX5->(DbSetOrder(1))			
					If (SX5->(Dbseek(xFilial("SX5")+'12')))
						While SX5->(!Eof()) .And. SX5->X5_FILIAL == xFilial("SX5") .And. SX5->X5_TABELA == '12'
							If _lCopy .And. Alltrim(SX5->X5_CHAVE) == N8R->N8R_UFDEST //Não valida registro com UFDEST utilizada para cópia
								SX5->(DbSkip())
							EndIf
							
							If Empty(cUf)
								cUf := Alltrim(SX5->X5_CHAVE)
							Else
								cUf += "','" + alltrim(SX5->X5_CHAVE)
							EndIf
							
							SX5->(DbSkip())
						EndDo
					EndIf	
				Else
					cUf := alltrim(cUFDest)
				EndIf 
				
				cAlias := GetNextAlias()
				BeginSQL Alias cAlias
				   SELECT DISTINCT N8R_UFORIG, N8R_UFDEST, N8R_PROD 
				     FROM %table:N8R% N8R
				    WHERE N8R.%notDel%
				      AND N8R.N8R_FILIAL = %xFilial:N8R%
				      AND N8R.N8R_PROD   = %Exp: oField:GetValue("N8R_PROD")% 
				      AND N8R.N8R_UFORIG = %Exp: oField:GetValue("N8R_UFORIG")%
				      AND N8R.N8R_UFDEST IN (%Exp:cUf%)
				      AND N8R.N8R_DTINVG = %Exp: oField:GetValue("N8R_DTINVG")%			      
				EndSQL
				
				If !(cAlias)->(Eof()) 
					oModel:GetModel():SetErrorMessage( oModel:GetId(), , oModel:GetId(), "", "", STR0008 + CRLF + CRLF +"<b>"+STR0019 + "</b>"+ alltrim((cAlias)->N8R_PROD) + CRLF + "<b>"+STR0020+ "</b>"+ alltrim((cAlias)->N8R_UFORIG) + CRLF + "<b>"+STR0021+"</b>"+ alltrim((cAlias)->N8R_UFDEST) , STR0009, "", "")	//Pauta já cadastrada.				                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
					lRet := .F.
				EndIf
				(cAlias)->(dbCloseArea())
			Endif
		EndIf
	EndIf
	
Return lRet