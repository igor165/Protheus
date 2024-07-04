#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TopConn.ch'
#INCLUDE "hat-actions.ch"
#INCLUDE "plsa365bc0.ch"

#DEFINE CRLF chr( 13 ) + chr( 10 )

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS365BC0V
Browse Procedimentos Autorizados.

@author  Guilherme Carvalho
@since   16/04/2018
@version P12
/*/
Function PLS365BC0V(cCodRDA, cCodInt, cCodLoc, cCodEsp, cCodSubEsp)
Local aRotBkp	:= aclone(aRotina)

Local cFiltro := "@(BC0_FILIAL = '" + xFilial("BC0") + "' AND BC0_CODIGO = '" + cCodRDA + "' AND BC0_CODINT = '" + cCodInt + "' AND BC0_CODLOC = '" + ;
                 cCodLoc + "' AND BC0_CODESP = '" + cCodEsp + "' AND BC0_CODSUB = '" + cCodSubEsp + "')"
private cLocBB8 := cCodLoc
private cEspBAX := cCodEsp
private cEspSBAX := cCodSubEsp

oBroBC0 := FWmBrowse():New()

oBroBC0:SetAlias( 'BC0' )
oBroBC0:SetDescription(STR0001) //STR0001
oBroBC0:SetFilterDefault(cFiltro)
oBroBC0:SetMenuDef("PLSA365BC0")
oBroBC0:setMainProc("PLSA365BC0")
aRotina := MenuDef()
oBroBC0:Activate()

aRotina	:= aclone(aRotBkp)

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta o menu

@author  Guilherme Carvalho
@since   16/04/2018
@version P12
/*/
Static Function MenuDef()

Local aRotina2 := {}

//ADD OPTION aRotina2 Title STR0002  	Action 'PesqBrw'          		OPERATION 1 ACCESS 0 //Pesquisar
ADD OPTION aRotina2 Title STR0003 	Action 'ViewDef.PLSA365BC0'		OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina2 Title STR0004   Action 'ViewDef.PLSA365BC0'		OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina2 Title STR0005  	Action 'ViewDef.PLSA365BC0'		OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina2 Title STR0006  	Action 'ViewDef.PLSA365BC0'		OPERATION 5 ACCESS 0 //Excluir

Return aRotina2   

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view

@author  Guilherme Carvalho
@since   16/04/2018
@version P12
/*/
Static Function ViewDef()

Local oStruBC0 := FWFormStruct( 2, 'BC0',{ |cCampo| PLSCMPBC0(cCampo) }  )
Local oStruBZB := FWFormStruct( 2, 'BZB' )
Local oStruBDN := FWFormStruct( 2, 'BDN' )
//Local oStruBLG := FWFormStruct( 2, 'BLG' )
Local oModel   := FWLoadModel( 'PLSA365BC0' )
Local oView      

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField('VIEW_BC0', 	oStruBC0, 	'BC0MASTER' )
oView:AddGrid( 'VIEW_BZB', 	oStruBZB, 	'BZBDETAIL' )
oView:AddGrid( 'VIEW_BDN', 	oStruBDN, 	'BDNDETAIL' )

oView:EnableTitleView('VIEW_BC0',STR0008) //Procedimentos Autorizados
oView:EnableTitleView('VIEW_BZB',STR0009) //Divisao Remuneracao
oView:EnableTitleView('VIEW_BDN',STR0010) //Diferenciar Composicao do Procedimento


// Divide a tela em para conteúdo e rodapé
oView:CreateHorizontalBox( 'SUPERIOR',	50 )
oView:CreateHorizontalBox( 'INFERIOR', 	50 )

oView:CreateFolder(	'FOLDER_01','INFERIOR'	) 
oView:AddSheet(		'FOLDER_01','ABA_01'	, STR0009) //Divisao Remuneracao
oView:AddSheet(		'FOLDER_01','ABA_02'	, STR0010) //"Diferenciar Composicao do Procedimento"

oView:CreateHorizontalBox("FORMFOLDER_01",100,,,'FOLDER_01','ABA_01')
oView:CreateHorizontalBox("FORMFOLDER_02",100,,,'FOLDER_01','ABA_02') 

oView:SetOwnerView( 'VIEW_BC0', "SUPERIOR")
oView:SetOwnerView( 'VIEW_BZB', "FORMFOLDER_01")   
oView:SetOwnerView( 'VIEW_BDN', "FORMFOLDER_02")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define a model
@author  Guilherme Carvalho
@since   16/04/2018
@version P12
/*/
Static Function ModelDef()
Local oStruBC0 := FWFormStruct( 1, 'BC0' )
Local oStruBZB := FWFormStruct( 1, 'BZB' )
Local oStruBDN := FWFormStruct( 1, 'BDN' )
Local aGatilho := {}
Local oModel
local lAutoma :=  IIf(type('lAutBC0')=='U',.F.,lAutBC0) // Variavel declarada para fins de automação

oModel := MPFormModel():New( 'PLSA365BC0MODEL',,,{|oModel| ConfGrv(oModel) }, )

//Gatilho
aGatilho := FwStruTrigger('BDN_CODUNI', 'BDN_DESUNI', '', .f., '', 0, '','!empty(FwFldGet("BDN_CODUNI"))')                                           
oStruBDN:AddTrigger( aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4] )

aGatilho := FwStruTrigger('BDN_CODUNI', 'BDN_DESUNI', 'BD3->BD3_DESCRI', .f., 'BD3', 1, 'xFilial("BD3") + FwFldGet("BDN_CODUNI")','!empty(FwFldGet("BDN_CODUNI"))') 
oStruBDN:AddTrigger( aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4] )
                                               
// Monta a estrutura
oModel:AddFields( 'BC0MASTER', 	''			, oStruBC0)  
oModel:AddGrid(   'BZBDETAIL', 	'BC0MASTER'	, oStruBZB)
oModel:AddGrid(   'BDNDETAIL', 	'BC0MASTER'	, oStruBDN)


// Descrições
oModel:SetDescription( 'Procedimentos Autorizados' )
oModel:GetModel( 'BC0MASTER' ):SetDescription(STR0001) //'Procedimentos Autorizados'
oModel:GetModel( 'BZBDETAIL' ):SetDescription(STR0009) //'Divisao Remuneracao'
oModel:GetModel( 'BDNDETAIL' ):SetDescription(STR0010) //Diferenciar Composicao do Procedimento'
																	
oModel:SetRelation( 'BZBDETAIL', { 	{ 	'BZB_FILIAL', 'xFilial( "BZB" )' 	},;
									{ 	'BZB_CODIGO', 'BC0_CODIGO'   		},;
									{ 	'BZB_CODINT', 'BC0_CODINT' 			},;
									{ 	'BZB_CODLOC', 'BC0_CODLOC' 			},;
									{ 	'BZB_CODESP', 'BC0_CODESP' 			},;
									{ 	'BZB_CODTAB', 'BC0_CODTAB' 			},;
									{ 	'BZB_CODOPC', 'BC0_CODOPC' 			},;
									{ 	'BZB_NIVEL',  'BC0_NIVEL' 			}},;
										'BZB_FILIAL+BZB_CODIGO+BZB_CODINT+BZB_CODLOC+BZB_CODESP+BZB_CODTAB+BZB_CODOPC+BZB_NIVEL+BZB_CODUNI' )

oModel:SetRelation( 'BDNDETAIL', { 	{ 	'BDN_FILIAL', 'xFilial( "BDN" )' 	},;
									{ 	'BDN_CODIGO', 'BC0_CODIGO'   		},;
									{ 	'BDN_CODINT', 'BC0_CODINT' 			},;
									{ 	'BDN_CODLOC', 'BC0_CODLOC' 			},;
									{ 	'BDN_CODESP', 'BC0_CODESP' 			},;
									{ 	'BDN_CODTAB', 'BC0_CODTAB' 			},;
									{ 	'BDN_CODPAD', 'BC0_CODPAD' 			},;
									{ 	'BDN_CODOPC', 'BC0_CODOPC' 			}},;
										'BDN_FILIAL+BDN_CODIGO+BDN_CODINT+BDN_CODLOC+BDN_CODESP+BDN_CODTAB+BDN_CODPAD+BDN_CODOPC+BDN_CODUNI' )

oModel:SetPrimaryKey( { "BC0_FILIAL","BC0_CODIGO","BC0_CODINT","BC0_CODLOC","BC0_CODESP","BC0_CODPAD","BC0_CODOPC","BC0_NIVEL","BC0_TIPO","BC0_VIGDE" } )

//Inicializador padrão
if lAutoma  //Para fins de automação. Como as variaveis vem de outra tela, na automação vem vazias, foi necessário fazer esse desvio
	oStruBC0:SetProperty( 'BC0_CODIGO' , MODEL_FIELD_INIT, { || '000004'  })
	oStruBC0:SetProperty( 'BC0_CODLOC' , MODEL_FIELD_INIT, { || '001'  })
	oStruBC0:SetProperty( 'BC0_CODESP' , MODEL_FIELD_INIT, { || '002'  })
	oStruBC0:SetProperty( 'BC0_CODSUB' , MODEL_FIELD_INIT, { || ' ' })
	oStruBC0:SetProperty( 'BC0_CODINT' , MODEL_FIELD_INIT, { || Plsintpad()} )
else
	oStruBC0:SetProperty( 'BC0_CODLOC' , MODEL_FIELD_INIT, { || cLocBB8  })
	oStruBC0:SetProperty( 'BC0_CODESP' , MODEL_FIELD_INIT, { || cEspBAX  })
	oStruBC0:SetProperty( 'BC0_CODSUB' , MODEL_FIELD_INIT, { || cEspSBAX })
	oStruBC0:SetProperty( 'BC0_CODINT' , MODEL_FIELD_INIT, { || Plsintpad()} )
Endif

oModel:GetModel( 'BZBDETAIL' ):SetOptional( .T. )
oModel:GetModel( 'BDNDETAIL' ):SetOptional( .T. )

																	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCpoBC0
Validação dos campos da tabela BC0

@author Guilherme Carvalho
@since 13/06/18
@version P11
/*/
Function VldCpoBC0(cCampo)
	Local lRet		:= .T.
	Local oView 	:= FWViewActive()
	Local oModel 	:= FWModelActive()
	Local oStruBC0 	:= oModel:GetModel('BC0MASTER')
	Local oStruBZB 	:= oModel:GetModel('BZBDETAIL')
	Local oStruBDN 	:= oModel:GetModel('BDNDETAIL')
	Local nLineBZB 	:= oStruBZB:GetLine()
	Local nLineBDN 	:= oStruBDN:GetLine()
	Local dVigIni	:= CtoD(" / / ")
	Local dVigFim	:= CtoD(" / / ")
	Local nFor		:= 0
	Local cDescri	:= ""
	Local nRecnoAtu	:= BC0->(recno())
	Local aArea	:= BC0->(getArea())
	
If cCampo == "BC0_CODTAB" 
	
	If !Empty( FwFldGet('BC0_CODTAB') )
		cDescri := AllTrim( Posicione("BF8",1,xFilial("BF8")+Plsintpad()+FwFldGet('BC0_CODTAB')+"01","BF8_DESCM") )
		if !ExistCpo('BF8',Plsintpad()+FwFldGet('BC0_CODTAB'),1)
			lRet := .f.
		endif
	EndIf
	oModel:LoadValue( 'BC0MASTER','BC0_DESTAB', SubStr(cDescri,1, GetSX3CACHE('BC0_DESTAB','X3_TAMANHO') ))
	
ElseIf cCampo == "BC0_CODOPC"
	
	If !Empty( FwFldGet('BC0_CODOPC') )
		cDescri := AllTrim( Posicione("BA8",1,xFilial("BA8")+Plsintpad()+FwFldGet('BC0_CODTAB')+FwFldGet('BC0_CODPAD')+FwFldGet('BC0_CODOPC'),"BA8_DESCRI") )	
		if !ExistCpo('BA8',Plsintpad()+FwFldGet('BC0_CODTAB')+FwFldGet('BC0_CODPAD')+FwFldGet('BC0_CODOPC'),1)
			lRet := .f.
		endif
	EndIf
	oModel:LoadValue( 'BC0MASTER','BC0_DESOPC', SubStr(cDescri,1, GetSX3CACHE('BC0_DESOPC','X3_TAMANHO') ) )
	
	If oStruBDN:GetQtdLine() > 1 .Or. !Empty( FwFldGet('BDN_CODUNI', nLineBDN) ) 
		For nFor := 1 To oStruBDN:GetQtdLine() 
			oStruBDN:GoLine( nFor )
			oStruBDN:DeleteLine()
		Next nFor
		oStruBDN:AddLine()
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se deve carregar a composicao padrao da TDE...             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("BD4")
	BD4->(DbSetOrder(1))
	If BD4->(MsSeek(xFilial("BD4")+M->(BC0_CODINT+BC0_CODTAB+BC0_CODPAD+BC0_CODOPC)))
	   
	   While !BD4->(Eof()) .And. BD4->(BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO) == ;
	                               xFilial("BD4")+M->(BC0_CODINT+BC0_CODTAB+BC0_CODPAD+BC0_CODOPC)
	                               
	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Desconsidera as composicoes com vigencia vencida ou  ³
			//³ com o inicio da vigencia posterior a Data Base       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        If ( dDataBase < BD4->BD4_VIGINI .And. !Empty(BD4->BD4_VIGINI)) .Or.;
	           ( dDataBase > BD4->BD4_VIGFIM .And. !Empty(BD4->BD4_VIGFIM))
	           BD4->(DbSkip())
	           Loop
	        EndIf
	              
	      	oModel:LoadValue( 'BDNDETAIL','BDN_CODUNI', BD4->BD4_CODIGO )
	      	oModel:LoadValue( 'BDNDETAIL','BDN_DESUNI', AllTrim( Posicione("BD3",1,xFilial("BD3")+BD4->BD4_CODIGO,"BD3_DESCRI") ) )
	      	oModel:LoadValue( 'BDNDETAIL','BDN_REF', BD4->BD4_VALREF )
	      	
	   		BD4->(DbSkip())
	   		
	   		If !BD4->(Eof()) .And. BD4->(BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO) == ;
	                               xFilial("BD4")+M->(BC0_CODINT+BC0_CODTAB+BC0_CODPAD+BC0_CODOPC)
	        	
	        	oStruBDN:AddLine()
	   		
	   		EndIf
	   Enddo
	EndIf
	
ElseIf cCampo == "BC0_FORMUL"
	
	If M->BC0_FORMUL == "1" 
		M->BC0_EXPRES := Space(Len(M->BC0_EXPRES)) 
	EndIf

ElseIf cCampo == "BC0_VIGDE" .Or. cCampo == "BC0_VIGATE" 
	
	dVigIni	:= M->BC0_VIGDE 	
	dVigFim	:= M->BC0_VIGATE 	
	
	If cCampo == "BC0_VIGDE"
		
		If ( !Empty(dVigFim) .And. dVigIni > dVigFim )
			lRet := .F.
			Help(nil, nil ,STR0007, nil, STR0011, 1, 0, nil, nil, nil, nil, nil, {STR0013} )//Atenção: Vigência Inicial não pode ser maior que a Final. Informe outra data.
		Else 

			BC0->(DbSetOrder(1)) //BC0_FILIAL+BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODTAB+BC0_CODOPC
			If BC0->(MsSeek(xFilial("BC0")+M->(BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODTAB+BC0_CODOPC)))
				While BC0->(!EoF()) .And. 	M->(BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODTAB+BC0_CODOPC) ==;
											BC0->(BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODTAB+BC0_CODOPC)
					
					If (nRecnoAtu == BC0->(recno())) .And. Altera
						BC0->(DbSkip())
						Loop
					endIf
					If (  dVigIni >= BC0->BC0_VIGDE .And. (dVigIni <= BC0->BC0_VIGATE .Or. Empty(BC0->BC0_VIGATE))  )
						lRet := .F.
						Help(nil, nil ,STR0007, nil, STR0012, 1, 0, nil, nil, nil, nil, nil, {STR0013} )//Atenção: Vigência Inicial inválida, data já considerada em outro registro. Informe outra data.				
						exit			
					EndIf

					If !Empty(BC0->BC0_VIGATE) .And. dVigIni < BC0->BC0_VIGDE .And. dVigFim > BC0->BC0_VIGATE 
						lRet := .F. 
						Help(nil, nil ,STR0007, nil, STR0012, 1, 0, nil, nil, nil, nil, nil, {STR0013} )//Atenção: Vigência Inicial inválida, data já considerada em outro registro. Informe outra data.
						exit
					EndIf
					
					BC0->(DbSkip())
				EndDo
			EndIf
			
		EndIf
		
	Else
		
		If ( !Empty(dVigIni) .And. !Empty(dVigFim) .And. dVigFim < dVigIni )
			Help(nil, nil ,STR0007, nil, STR0011, 1, 0, nil, nil, nil, nil, nil, {STR0013} )//Atenção: Vigência Inicial não pode ser maior que a Final. Informe  outra data
			lRet := .F.
		Else

			BC0->(DbSetOrder(1)) //BC0_FILIAL+BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODTAB+BC0_CODOPC
			If BC0->(MsSeek(xFilial("BC0")+M->(BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODTAB+BC0_CODOPC)))
				While BC0->(!EoF()) .And. 	M->(BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODTAB+BC0_CODOPC) ==;
											BC0->(BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODTAB+BC0_CODOPC)
	
					If (nRecnoAtu == BC0->(recno())) .And. Altera
						BC0->(DbSkip())
						Loop
					endIf
	
					If (  dVigFim >= BC0->BC0_VIGDE .And. (dVigFim <= BC0->BC0_VIGATE .Or. Empty(BC0->BC0_VIGATE)) )
						lRet := .F.
						Help(nil, nil ,STR0007, nil, STR0014, 1, 0, nil, nil, nil, nil, nil, {STR0013} )//Atenção:Vigência Final inválida, data já considerada em outro registro. Informe outra Data. 		
						exit
					EndIf
					If !Empty(BC0->BC0_VIGATE) .And. dVigIni < BC0->BC0_VIGDE .And. dVigFim > BC0->BC0_VIGATE 
						lRet := .F.
						Help(nil, nil ,STR0007, nil, STR0014, 1, 0, nil, nil, nil, nil, nil, {STR0013} )//Atenção:Vigência Final inválida, data já considerada em outro registro. Informe outra Data.			
						exit
					EndIf
					
					BC0->(DbSkip())
				EndDo
			EndIf
			
		EndIf
	
	EndIf
	
ElseIf cCampo == "BZB_CODUNI"

	If !Empty( FwFldGet('BZB_CODUNI',nLineBZB) ) 
		cDescri := AllTrim( Posicione("BD3",1,xFilial("BD3")+FwFldGet('BZB_CODUNI',nLineBZB),"BD3_DESCRI") )	
	EndIf
	oModel:LoadValue( 'BZBDETAIL','BZB_DESUNI', SubStr(cDescri,1, GetSX3CACHE('BZB_DESUNI','X3_TAMANHO') ) )
	
	oModel:LoadValue( 'BZBDETAIL','BZB_CDNV01', M->BC0_CDNV01 )
	oModel:LoadValue( 'BZBDETAIL','BZB_CDNV02', M->BC0_CDNV02 )
	oModel:LoadValue( 'BZBDETAIL','BZB_CDNV03', M->BC0_CDNV03 )
	oModel:LoadValue( 'BZBDETAIL','BZB_CDNV04', M->BC0_CDNV04 )
	
EndIf
BC0->(Restarea(aArea))

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} IniCpoBC0
Validação dos campos da tabela BC0

@author Guilherme Carvalho
@since 13/06/18
@version P11
/*/
Function IniCpoBC0(cCampo,lTab)
Local cRet := ""

Default lTab := .F.

//If Type('Inclui') == 'U'
	cCodInt	:= PlsIntPad()
	Inclui := .F.
//EndIf	



If !Inclui .Or. lTab

	If cCampo == "BC0_DESTAB"
		DbSelectArea("BF8")
		cRet := AllTrim( Posicione("BF8",1,xFilial("BF8")+cCodInt+M->BC0_CODTAB+"01","BF8_DESCM") )
	ElseIf cCampo == "BC0_DESPAD"
		DbSelectArea("BR4")
		cRet := AllTrim( Posicione("BR4",1,xFilial("BR4")+M->BC0_CODPAD+"01","BR4_DESCRI") ) 
	ElseIf cCampo == "BC0_DESOPC"
		DbSelectArea("BA8")
		If !lTab
			cRet := AllTrim( Posicione("BA8",1,xFilial("BA8")+cCodInt+M->(BC0_CODTAB+BC0_CODPAD+BC0_CODOPC),"BA8_DESCRI") )
		Else
			cRet := AllTrim( Posicione("BA8",1,xFilial("BA8")+cCodInt+BC0->(BC0_CODTAB+BC0_CODPAD+BC0_CODOPC),"BA8_DESCRI") )
		EndIf
	EndIf

EndIf
	
Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ConfGrv
Função commit chamada do botão confirmar.

@author Guilherme Carvalho
@since 13/06/18
@version P11
/*/
STATIC FUNCTION ConfGrv(oModel)
	Local oStruBZB 	:= oModel:GetModel('BZBDETAIL')
	Local oStruBDN 	:= oModel:GetModel('BDNDETAIL')
	Local oStruBC0  := oModel:GetModel('BC0MASTER')
	Local nLineBZB 	:= oStruBZB:GetLine()
	Local nLineBDN 	:= oStruBDN:GetLine()
	Local nFor		:= 0
	Local cCodUni	:= ""
	Local nOperation := 0
	Local aDadosHAT  := {}
	Local cChaveHAT  := ""
	Local nOperation := oModel:GetOperation()
	Local lIntHAT    := GetNewPar("MV_PLSHAT","0") == "1"
	
If nOperation = 3 
	
	DbSelectArea("BZB")
	BZB->(DbSetOrder(1)) //BZB_FILIAL+BZB_CODIGO+BZB_CODINT+BZB_CODLOC+BZB_CODESP+BZB_CODTAB+BZB_CODOPC+BZB_NIVEL+BZB_CODUNI
	For nFor := 1 To oStruBZB:GetQtdLine()
		oStruBZB:GoLine( nFor )
		cCodUni := FwFldGet('BZB_CODUNI', nFor)
		If !Empty(cCodUni)
			If BZB->(MsSeek(xFilial("BZB")+BAU->BAU_CODIGO+Plsintpad()+FwFldGet('BC0_CODLOC')+FwFldGet('BC0_CODESP')+FwFldGet('BC0_CODTAB')+FwFldGet('BC0_CODOPC')+FwFldGet('BC0_NIVEL')+cCodUni))
				oStruBZB:DeleteLine()		
			EndIf
		EndIf
	Next nFor
	
	DbSelectArea("BDN")
	BDN->(DbSetOrder(1)) //BDN_FILIAL+BDN_CODIGO+BDN_CODINT+BDN_CODLOC+BDN_CODESP+BDN_CODTAB+BDN_CODPAD+BDN_CODOPC+BDN_CODUNI
	For nFor := 1 To oStruBDN:GetQtdLine()
		oStruBDN:GoLine( nFor )
		cCodUni := FwFldGet('BDN_CODUNI', nFor)
		If !Empty(cCodUni)
			If BDN->(MsSeek(xFilial("BDN")+BAU->BAU_CODIGO+Plsintpad()+FwFldGet('BC0_CODLOC')+FwFldGet('BC0_CODESP')+FwFldGet('BC0_CODTAB')+FwFldGet('BC0_CODPAD')+FwFldGet('BC0_CODOPC')+cCodUni))
				oStruBDN:DeleteLine()		
			EndIf
		EndIf
	Next nFor
	
EndIf

//Integracao com o HAT quando e alteracao
If lIntHAT .And. nOperation == MODEL_OPERATION_UPDATE
	nOperation := oModel:GetOperation()

	Aadd(aDadosHAT,{"BC0_CODLOC",FwFldGet('BC0_CODLOC')})
	Aadd(aDadosHAT,{"BC0_CODESP",FwFldGet('BC0_CODESP')})
	Aadd(aDadosHAT,{"BC0_CODPAD",FwFldGet('BC0_CODPAD')})
	Aadd(aDadosHAT,{"BC0_CODOPC",FwFldGet('BC0_CODOPC')})
	Aadd(aDadosHAT,{"BC0_NIVEL" ,FwFldGet('BC0_NIVEL')})
	Aadd(aDadosHAT,{"BC0_TIPO"  ,FwFldGet('BC0_TIPO')})
	Aadd(aDadosHAT,{"BC0_VIGDE" ,FwFldGet('BC0_VIGDE')})
	Aadd(aDadosHAT,{"BC0_VIGATE",FwFldGet('BC0_VIGATE')})
	Aadd(aDadosHAT,{"BC0_DATBLO",FwFldGet('BC0_DATBLO')})

	cChaveHAT := (FwFldGet('BC0_CODIGO')+FwFldGet('BC0_CODINT')+FwFldGet('BC0_CODLOC')+;
	              FwFldGet('BC0_CODESP')+FwFldGet('BC0_CODTAB')+FwFldGet('BC0_CODOPC'))
	PLHATPedPD(nOperation,_healthProviders_alt,"BC0",cChaveHAT,aDadosHAT,1,oStruBC0:nDataID )
EndIf

lUpdBC0 := .T.

FwFormCommit(oModel)

//Integracao com o HAT quando e inclusao
If lIntHAT .And. nOperation == MODEL_OPERATION_INSERT
	cChaveHAT := BC0->(BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODTAB+BC0_CODOPC)
	PLHATPedPD(nOperation,_healthProviders_inc,"BC0",cChaveHAT,aDadosHAT,1,BC0->(Recno()) )
EndIf

Return(.T.)


/*//-------------------------------------------------------------------
{Protheus.doc} PLSCMPBC0
Campos que não devem ser exibidos  no form BE9
@since    05/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
static function PLSCMPBC0(cCampo)
Local lRet := .T.

if alltrim(cCampo) $ "BC0_CODIGO"
	lRet := .F.
endif

return lRet