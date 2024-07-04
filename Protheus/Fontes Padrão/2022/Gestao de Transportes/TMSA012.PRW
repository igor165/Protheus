#INCLUDE "TMSA012.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static aTabFre := {}

/*/-----------------------------------------------------------
{Protheus.doc} TMSA012()
Cadastro de Tabela de Frete Por Destinatário

Uso: SIGATMS

@sample
//TMSA012()

@author Gabriela Kamimoto.
@since 09/04/2012
@version 1.0
-----------------------------------------------------------/*/
Function TMSA012()
Local oBrowse   := Nil

Private aRotina := MenuDef()

If !X3Usado("DYG_CLIDES") .Or. !X3Usado("DYG_LOJDES")
	Help("",1,"TMSA01202")	//-- Atualize o dicionário. Pacote 010485.
Else
	oBrowse := FWMBrowse():New()   
	oBrowse:SetAlias("DY9")			    // Alias da tabela utilizada
	oBrowse:SetMenuDef("TMSA012")      // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)    //"Tabela de Frete por Destinatário"
	
	oBrowse:Activate()
EndIf

Return Nil

//---------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE "Pesquisar" ACTION "PesqBrw"    OPERATION 1  ACCESS 0  //"Pesquisar"
ADD OPTION aRotina TITLE STR0005     ACTION "TMSA012Mnt" OPERATION 2  ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0006     ACTION "TMSA012Mnt" OPERATION 3  ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0007     ACTION "TMSA012Mnt" OPERATION 4  ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0008     ACTION "TMSA012Mnt" OPERATION 5  ACCESS 0 //"Excluir"

Return aRotina

//---------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStruDY9   := FWFormStruct( 1, "DY9" )
Local cNameGrid  := ""
Local cNameGrid2 := ""
Local cModelGrid := ""
Local nCount     := 0
Local aCompTab   := {}  
Local nOpc  	 := 0	
Local aTabela    := {} 

oModel := MPFormModel():New( "TMSA012",/*bPre*/,/*bPos*/, {|oModel| TMSA012GRV(oModel)}, /*bCancel*/ )

oModel:AddFields( "012_DY9", /*cOwner*/, oStruDY9,/*bPre*/,/*bPost*/,/*bLoad*/ )

oModel:GetModel( "012_DY9" ):SetDescription( STR0001 ) //"Tabela de Frete por Destinatário"

aTabela  := TMA12GetTb()
if !empty(aTabela)
  aCompTab := TMSA012Cpo( aTabela[1], aTabela[2] )
else 
  aCompTab := {}
endif                  
For nCount := 1 To Len(aCompTab)
   
	DYA->(dbGoTo(0))
	
	cNameGrid := "012_DYA_"+ Alltrim(Str(nCount))

	aCompTab[ nCount, 3 ]:= FWFormStruct(1,"DYA")

	aCompTab[ nCount, 3 ]:SetProperty( "DYA_CODPAS", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'"+aCompTab[ nCount, 1 ]+"'" )  )
	
	oModel:AddGrid( cNameGrid, "012_DY9", aCompTab[ nCount, 3 ], /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, &("{ |oModel| TMSA012Gr1( oModel, '"+aCompTab[ nCount, 1 ]+"')}")  ) 

	oModel:SetRelation( cNameGrid,{{'DYA_FILIAL','xFilial( "DYA" )'},{'DYA_TABFRE','DY9_TABFRE'},{'DYA_TIPTAB','DY9_TIPTAB'}}, DYA->(IndexKey(1)) ) 

	oModel:GetModel( cNameGrid ):SetUniqueLine( { "DYA_CLIDES", "DYA_LOJDES" } ) 
	
	oModel:GetModel( cNameGrid ):SetMaxLine(25000)

	oModel:GetModel( cNameGrid ):SetDescription( aCompTab[ nCount, 2 ] )  

	oModel:GetModel( cNameGrid ):SetUseOldGrid()

	oModel:GetModel( cNameGrid ):SetOptional(.T.)

   
	If !Empty(Posicione("DT3",1,xFilial("DT3")+aCompTab[ nCount, 1 ],"DT3_FAIXA2"))    
	
		cNameGrid2 := "012_DYG_"+ Alltrim(Str(nCount))
	
		aCompTab[ nCount, 4 ] := FWFormStruct(1,"DYG")
	    
	    oModel:AddGrid( cNameGrid2, cNameGrid, aCompTab[ nCount, 4 ], /*bLinePre*/, { |oModelGrid| TMSA012LOk(oModelGrid,cNameGrid2) }, /*bPreVal*/, /*bPosVal*/, &("{ |oModel| TMSA012Gr2( oModel, '"+aCompTab[ nCount, 1 ]+"', '"+cNameGrid2+"' )}")  ) 
		
		oModel:SetRelation( cNameGrid2,{{'DYG_FILIAL','xFilial( "DYG" )'},{'DYG_TABFRE','DY9_TABFRE'},{'DYG_TIPTAB','DY9_TIPTAB'},{'DYG_CODPAS','"'+aCompTab[ nCount, 1 ]+'"'}},DYG->(IndexKey(1)) ) 
						
		oModel:SetOptional( cNameGrid2, .T. )

		oModel:GetModel(cNameGrid2):SetUseOldGrid()

	EndIf		

Next nCount
	
oModel:SetPrimaryKey( {"DY9_FILIAL", "DY9_TABFRE", "DY9_TIPTAB"} )            

Return oModel                                        

//---------------------------------------------------------

Static Function ViewDef()

Local oModel     := FWLoadModel("TMSA012")
Local oView      := Nil
Local oStruDY9   := FWFormStruct( 2, "DY9" )
Local xRet       := .F.                          
Local nCount     := 0
Local cNameGrid  := "" 
Local cViewFold  := ""
Local cAba		 := ""
Local cPosFold   := ""
Local aTabela    := {}
Private aCompTab := {}

oView := FWFormView():New()

oView:SetModel( oModel )

oView:CreateHorizontalBox( "CABEC" , 30 )	
oView:CreateHorizontalBox( "FOLDER", 70 )      
oView:AddField( "VIEW_DY9" ,  oStruDY9 , "012_DY9" )
oView:SetOwnerView( "VIEW_DY9" , "CABEC"  )  
oView:CreateFolder( "IDFOLDER1", "FOLDER" )	  
oView:EnableTitleView( "012_DY9" )

aTabela  := TMA12GetTb()
aCompTab := TMSA012Cpo( aTabela[1], aTabela[2] )

For nCount:= 1 To Len(aCompTab)

	aCompTab[ nCount, 3 ] := FWFormStruct(2,"DYA")	  
	aCompTab[ nCount, 3 ]:RemoveField( "DYA_TABFRE" )
	aCompTab[ nCount, 3 ]:RemoveField( "DYA_TIPTAB" ) 
	aCompTab[ nCount, 3 ]:RemoveField( "DYA_CODPAS" )
	
	If !Empty(Posicione("DT3",1,xFilial("DT3")+aCompTab[ nCount, 1 ],"DT3_FAIXA2"))
		aCompTab[ nCount, 3 ]:RemoveField( "DYA_VALOR"  )
		aCompTab[ nCount, 3 ]:RemoveField( "DYA_TIPVAL" ) 
	EndIf		
	
	cNameGrid := "012_DYA_"    + Alltrim( Str( nCount ) )	
	cNameGrid2:= "012_DYG_"	   + Alltrim( Str( nCount ) )	
	cViewFold := "VIEW_DYA_"   + Alltrim( Str( nCount ) )	
	cAba      := "ABA_DYA"     + Alltrim( Str( nCount ) )	
	cPosFold  := "POSFOLD_DYA" + Alltrim( Str( nCount ) )	

	oView:AddGrid(  cViewFold , aCompTab[ nCount, 3 ] , cNameGrid )
	oView:AddSheet( "IDFOLDER1", cAba, aCompTab[ nCount, 2 ] )    
	oView:EnableTitleView( cNameGrid )

	If Empty(Posicione("DT3",1,xFilial("DT3")+aCompTab[ nCount, 1 ],"DT3_FAIXA2"))
		oView:CreateHorizontalBox( cPosFold, 100,,, "IDFOLDER1", cAba )
		oView:SetOwnerView( cViewFold, cPosFold )
		oView:AddIncrementField( cNameGrid, "DYA_ITEM" )     
	Else		                                                          
		oView:CreateHorizontalBox( cPosFold    , 50,,, "IDFOLDER1", cAba )
		oView:CreateHorizontalBox( cPosFold+"Sfx", 50,,, "IDFOLDER1", cAba )
		oView:AddIncrementField( cNameGrid, "DYA_ITEM" )     
       
		aCompTab[ nCount, 4 ] := FWFormStruct(2,"DYG")
		aCompTab[ nCount, 4 ]:RemoveField( "DYG_TABFRE" )
		aCompTab[ nCount, 4 ]:RemoveField( "DYG_TIPTAB" ) 
		aCompTab[ nCount, 4 ]:RemoveField( "DYG_CODPAS" )	   
		aCompTab[ nCount, 4 ]:RemoveField( "DYG_CLIDES" )	   
		aCompTab[ nCount, 4 ]:RemoveField( "DYG_LOJDES" )	   

		oView:SetOwnerView( cViewFold, cPosFold )
		oView:AddGrid(  cViewFold+"Sfx" , aCompTab[ nCount, 4 ] , cNameGrid2  )
		oView:AddIncrementField( cNameGrid2, "DYG_ITEM" )     
		oView:SetOwnerView( cViewFold+"Sfx"  ,  cPosFold+"Sfx" )
		cTipFai := Posicione("DT3",1,xFilial("DT3")+aCompTab[ nCount, 1 ],"DT3_FAIXA2")
		oView:EnableTitleView( cNameGrid2, "Subfaixa - "+TMSValField("cTipFai", .F. ) )
	EndIf
Next nCount           
	
xRet := oView  
	
Return ( xRet )

       
/*/--------------------------------------------------------
{Protheus.doc}  TMSA012Mnt()

Manuntenção da Tabela de Frete por Destinatário.

ExpC1: Tabela de Frete
ExpN1: Variável Lógica
ExpN2: Tipo da Operação
ExpC2: Tabela de Frete
ExpC3: Tipo da Tabela de Frete 


@sample
//TMSA012()

@author Gabriela Kamimoto.
@since 18/04/2012
@version 1.0   
//---------------------------------------------------------
/*/                                   
Function TMSA012Mnt(cAlias,nReg,nOpc,cTabela,cTipTab)

Local aGetArea	   	:= GetArea()
Local aLayOut  	   	:= {}   
Local aTbFreTmp	   	:= {}   
Local aCabec   	   	:= {}
Local aVisual  	   	:= {}
Local cTitulo  	   	:= STR0002 //-- "Escolha a configuração da Tabela de Frete"                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
Local lOpcao   	   	:= .T.
Local lRet     	   	:= .T.  
Local oMainModel	   	:= Nil 
Local nCount	 		:= 0
Local nQtdDel	   		:= 0
Local cAliasQry    	:= ""
Local dDatDe	   		:= CtoD("")
Local dDatAte 		:= CtoD("")
Local cMoeda 	   		:= ""     
Local cDescTab		:= ""
Local lContHis    	:= GetMv("MV_CONTHIS",.F.,.T.) //-- Controla Historico da Tabela de Frete
Local lDTLDESCRI		:= DTL->(FieldPos("DTL_DESCRI"))>0
Private aColsDYG   	:= {}                      
						
Default nOpc       := 0
Default cTabela    := ""
Default cTipTab    := ""
//----------------------

If !Empty(cTabela) .And. aRotina[nOpc][4] == 2   
	cAliasQry := GetNextAlias()
	cQuery := "SELECT COUNT(*) QTDCOMP FROM "
	cQuery += RetSqlName("DYA")+" DYA, "
	cQuery += RetSqlName("DT3")+" DT3  "
	cQuery += " WHERE DYA.DYA_FILIAL = '"+xFilial('DYA')+"'"
	cQuery += "   AND DYA.DYA_TABFRE = '"+cTabela+"'"
	cQuery += "   AND DYA.DYA_TIPTAB = '"+cTipTab+"'"
	cQuery += "   AND DYA.D_E_L_E_T_ = ' '"
	cQuery += "   AND DT3.DT3_FILIAL = '"+xFilial('DT3')+"'"
	cQuery += "   AND DT3.DT3_CODPAS = DYA_CODPAS"
	cQuery += "   AND DT3.DT3_TIPFAI = '15'"
	cQuery += "   AND DT3.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	If (cAliasQry)->(Eof()) .Or. (cAliasQry)->QTDCOMP == 0
		lRet := .F.  
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aGetArea)
EndIf   

If lContHis .And. ( aRotina[nOpc][4] ==  MODEL_OPERATION_UPDATE  .Or. aRotina[nOpc][4] ==  MODEL_OPERATION_DELETE)
	If	TmsTabUso(DY9->DY9_TABFRE,DY9->DY9_TIPTAB,,,.T.,)
		UnLockByName("TABMAN",.T.,.F.) //-- Libera Lock   
		RestArea( aGetArea )
		Return( .F. )
	EndIf
EndIf

If lRet                     
	If !Empty(cTabela) .And. aRotina[nOpc][4] != MODEL_OPERATION_INSERT
	 	DY9->( dbSetOrder( 1 ) )
		DY9->( dbSeek(xFilial('DY9')+cTabela+cTipTab) ) 
	EndIf		
	If aRotina[nOpc][4] == 2 //Visualizar  
	
		TMA12SetTb( DY9->DY9_TABFRE, DY9->DY9_TIPTAB )

		oMainModel:= FWLoadModel("TMSA012")
		oMainModel:SetOperation( MODEL_OPERATION_VIEW )
		oMainModel:Activate()  
			
		FWExecView (, "TMSA012" , MODEL_OPERATION_VIEW , ,{|| .T. }, , , , , , , oMainModel ) 	
		
	ElseIf aRotina[nOpc][4] ==  MODEL_OPERATION_UPDATE //Alterar
	
		TMA12SetTb( DY9->DY9_TABFRE, DY9->DY9_TIPTAB )
		
		oMainModel:= FWLoadModel("TMSA012")
		oMainModel:SetOperation( MODEL_OPERATION_UPDATE )
		oMainModel:Activate()
		
		FWExecView (, "TMSA012" , MODEL_OPERATION_UPDATE , ,{|| .T. }, , , , , , , oMainModel ) 	
		
	ElseIf aRotina[nOpc][4] ==  MODEL_OPERATION_INSERT //Incluir  
		Aadd( aCabec, STR0003 ) //"Tabela de Frete"
		Aadd( aCabec, STR0004 ) //"Tipo"
		Aadd( aCabec, STR0011 ) //"Descricao"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega Configuracao da Tabela          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aLayOut := TMSLayOutTab( ,.T.,{ "15" }, ) //DT3_TIPFAI == "15" -> Calcula Frete por "Cliente Destinatário".
		
		If !Empty(aLayOut)
			lRet := TMSABrowse( aLayOut,cTitulo,,,,lOpcao,aCabec,, )
			
			If lRet
				nAt := Ascan( aLayOut, { |aItem| aItem[1] == .T. } )
				
				cTabela := Left( aLayOut[ nAt ][2], 4 ) 
				cTipTab := Left( aLayOut[ nAT ][3], 2 )

				DY9->(dbSetOrder(1))
				If DY9->(dbSeek(xFilial("DY9")+cTabela+cTipTab))
					Help("",1,"JAGRAVADO")
				Else					
					TMA12SetTb( cTabela, cTipTab )
		
					dDatDe  := Posicione( "DTL", 1, xFilial( "DTL" ) + cTabela + cTipTab, "DTL_DATDE" )
					dDatAte := DTL->DTL_DATATE
					cMoeda  := DTL->DTL_MOEDA
					
					If lDTLDESCRI
						cDescTab:= DTL->DTL_DESCRI
					EndIf
					
					oMainModel:= FWLoadModel("TMSA012")
		 			oMainModel:SetOperation( MODEL_OPERATION_INSERT )
					oMainModel:Activate()
					
					oMainModel:LoadValue( "012_DY9", "DY9_TABFRE" , cTabela )
					oMainModel:LoadValue( "012_DY9", "DY9_TIPTAB" , cTipTab )
					oMainModel:LoadValue( "012_DY9", "DY9_DESTIP" , Tabela( "M5", M->DY9_DESTIP, .F. ) )
					oMainModel:LoadValue( "012_DY9", "DY9_DATDE"  , dDatDe  )
					oMainModel:LoadValue( "012_DY9", "DY9_DATATE" , dDatAte ) 
					oMainModel:LoadValue( "012_DY9", "DY9_MOEDA"  , cMoeda  )
					If lDTLDESCRI
						oMainModel:LoadValue( "012_DY9", "DY9_DESTAB" , cDescTab )
					EndIf
		
					FWExecView (, "TMSA012" , MODEL_OPERATION_INSERT , ,{|| .T. }, , , , , , , oMainModel ) 	
				EndIf
			EndIf			                                                                                               	     	
		EndIf
	ElseIf aRotina[nOpc][4] ==  MODEL_OPERATION_DELETE //Excluir
		
		TMA12SetTb( DY9->DY9_TABFRE, DY9->DY9_TIPTAB )
		
		oMainModel:= FWLoadModel("TMSA012")
		oMainModel:SetOperation( MODEL_OPERATION_DELETE )
		oMainModel:Activate()   
		
		FWExecView (, "TMSA012" , MODEL_OPERATION_DELETE , ,{|| .T. }, , , , , , , oMainModel ) 	
		
	EndIf                                                                                                          	
Else 
	Help("",1,"TMSA01220") //--"Não há componentes em que o cálculo é feito sobre Cliente Destinatário..." 
EndIf 

RestArea( aGetArea )

Return ( lRet ) 
/*/--------------------------------------------------------
{Protheus.doc}  TMA12SetTb()

Preenche o array aTabFre. 

ExpC1: Tabela de Frete
ExpC2: Variável Lógica

@sample
//TMSA012()

@author Gabriela Kamimoto.
@since 18/04/2012
@version 1.0   
//---------------------------------------------------------
/*/   
Function TMA12SetTb( cTabela, cTipTab )

aTabFre := { cTabela, cTipTab }

Return Nil 

/*/--------------------------------------------------------
{Protheus.doc}  TMA12GetTb()

Tratamento para o array aTabFre.

@sample
//TMSA012()

@author Gabriela Kamimoto.
@since 18/04/2012
@version 1.0   
//---------------------------------------------------------
/*/
Function TMA12GetTb() 

Return aTabFre

/*/--------------------------------------------------------
{Protheus.doc} TMSA012Cpo()

Query que seleciona o Componente de Frete e a Descrição

de Frete.

@sample
//TMSA012()

@author Gabriela Kamimoto.
@since 18/04/2012
@version 1.0   
//---------------------------------------------------------
/*/
Function TMSA012Cpo( cTabFre, cTipTab )
Local aGetArea 	 := GetArea()
Local aReturn 	 := {}
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()

cQuery := " SELECT DT3_CODPAS, DT3_DESCRI, DVE_COMOBR "
cQuery += "   FROM " + RetSqlName( "DVE" ) + " DVE "
cQuery += " INNER JOIN " + RetSqlName( "DT3" ) + " DT3 "
cQuery += "    ON DT3.DT3_FILIAL = '"+ xFilial( "DT3" ) +"' "
cQuery += "   AND DT3.DT3_CODPAS = DVE_CODPAS "
cQuery += "   AND DT3.DT3_TIPFAI = '15' "
cQuery += "   AND DT3.D_E_L_E_T_ = '' "
cQuery += " WHERE DVE.DVE_FILIAL = '"+ xFilial( "DVE" ) +"' "
cQuery += "   AND DVE.DVE_TABFRE = '"+ cTabFre+ "' "
cQuery += "   AND DVE.DVE_TIPTAB = '"+ cTipTab+ "' "
cQuery += "   AND DVE.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY DT3_CODPAS "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->( !Eof() )
		
	aAdd( aReturn, { (cAliasQry)->DT3_CODPAS, (cAliasQry)->DT3_DESCRI,NIL,NIL,(cAliasQry)->DVE_COMOBR } )	                   
	
	(cAliasQry)->( DbSkip() )
EndDo
     
(cAliasQry)->( DbCloseArea() )

RestArea( aGetArea )

Return( aReturn )

/*/--------------------------------------------------------
{Protheus.doc} TMSA012Vld()

Validação do campo "DYA_CLIDES"  na GetDados. 
cCampo: DYA_CLIDES

@sample
//TMSA012()

@author Gabriela Kamimoto.
@since 18/04/2012
@version 1.0   
//---------------------------------------------------------
/*/

Function TMSA012Vld(cCampo)
Local oModel     := FwModelActive()
Local oModelAtu
Local oView      := FwViewActive()
Local aAreas     := {SA1->(GetArea()),GetArea()}
Local aFolder    := oView:GetFolderActive(oView:aFolders[1,1],2)
Local aCols      := {}
Local aHeader    := {}
Local lRet       := .F.
Local cCliDes    := ""
Local cLojDes    := ""
Local cSeekDYF   := ""
Local nPosCLiDes := 0
Local nPosLojDes := 0
Local nPosCodPas := 0
Local nFolder    := aFolder[1]

Default cCampo   := Alltrim(Readvar())

oModelAtu := oModel:GetModel("012_DYA_" + Alltrim(Str(nFolder)))

aCols      := oModelAtu:aCols[oModelAtu:nLine]
aHeader    := oModelAtu:aHeader
nPosCliDes := Ascan(aHeader,{|x| AllTrim(x[2]) == "DYA_CLIDES"})
nPosLojDes := Ascan(aHeader,{|x| AllTrim(x[2]) == "DYA_LOJDES"})
nPosCodPas := Ascan(aHeader,{|x| AllTrim(x[2]) == "DYA_CODPAS"})

cCliDes := aCols[nPosCliDes]
cLojDes := aCols[nPosLojDes]
cCodPas := aCols[nPosCodPas]

Do Case

	Case ("DYA_CLIDES" $ cCampo)
		lRet := ExistCpo("SA1", cCliDes, 1)
		
	Case ("DYA_LOJDES" $ cCampo)
		lRet := ExistCpo("SA1", cCliDes + cLojDes, 1)

EndCase

If lRet .And. !Empty(cCliDes) .And. !Empty(cLojDes)

	lRet     := .F.
	cSeekDYF := xFilial("DYF") + cCodPas
	
	//-- Verifica se o cliente destinatario esta cadastrado no componente de frete por destinatario
	DYF->(DbSetOrder(1)) //-- DYF_FILIAL+DYF_CODPAS
	If DYF->(MsSeek(cSeekDYF))
		While !lRet .And. DYF->(!Eof() .And. DYF_FILIAL + DYF_CODPAS == cSeekDYF)
			If DYF->(DYF_CLIDES + DYF_LOJDES) == cCliDes + cLojDes
				lRet := .T.
			EndIf
			DYF->(DbSkip())
		EndDo
	EndIf
	
	If !lRet
		Help("",1,"TMSA01201") //-- Cliente destinatario nao esta vinculado ao Componente de Frete Por destinatario
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return( lRet ) 


/*/--------------------------------------------------------
{Protheus.doc} TMSA012Whn()

Validação do campo DYA_LOJDES na GetDados.
cCampo: DYA_LOJDES

@sample
//TMSA012()

@author Gabriela Kamimoto.
@since 18/04/2012
@version 1.0   
//---------------------------------------------------------
/*/
                         
Function TMSA012Whn(cCampo)
Local oModel     := FwModelActive()
Local oModelAtu
Local oView      := FwViewActive()
Local aGetArea   := GetArea( )
Local aFolder    := oView:GetFolderActive(oView:aFolders[1,1],2)
Local aCols      := {}
Local aHeader    := {}
Local lRet       := .T.
Local cCliDes    := ""
Local nPosCLiDes := 0
Local nFolder    := aFolder[1]

Default cCampo  := AllTrim( ReadVar() )

oModelAtu := oModel:GetModel("012_DYA_" + Alltrim(Str(nFolder)))

aCols      := oModelAtu:aCols[oModelAtu:nLine]
aHeader    := oModelAtu:aHeader
nPosCliDes := Ascan(aHeader,{|x| AllTrim(x[2]) == "DYA_CLIDES"})

cCliDes := aCols[nPosCliDes]
           
If "DYA_LOJDES" $ cCampo

	If Empty( cCliDes )
		lRet := .F.
	EndIf
	
EndIf

RestArea( aGetArea )
Return ( lRet )                                    

//---------------------------------------------------------
/*{Protheus.doc} TMSA012Grd() 

Carrega a GetDados.

@sample               	
//TMSA012()

@author Gabriela Kamimoto.
@since 02/05/2012
@version 1.0   
//---------------------------------------------------------
/*/ 
Function TMSA012Gr1( oModel, cCodPas )

Local aRet	  := {}
Local cTmp	  := GetNextAlias()
Local cQuery  := ""     
Default cCodPas := ""

cQuery += " SELECT * FROM " + RetSqlName( "DYA" )
cQuery += " WHERE DYA_FILIAL = '" + xFilial("DYA")  + "'"
cQuery += "   AND DYA_TABFRE = '" + DY9->DY9_TABFRE + "' "
cQuery += "   AND DYA_TIPTAB = '" + DY9->DY9_TIPTAB + "' "
cQuery += "   AND DYA_CODPAS = '" + cCodPas         + "' "
cQuery += "   AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY DYA_ITEM "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .T., .F. )

aRet := FWLoadByAlias( oModel, cTmp ) 
	
(cTmp)->( dbCloseArea() )

Return( aRet )

//---------------------------------------------------------
/*{Protheus.doc} TMSA012Gr2() 

Carrega a GetDados da SubFaixa.

@sample               	
//TMSA012()

@author Gabriela Kamimoto.
@since 02/05/2012
@version 1.0   
//---------------------------------------------------------
/*/ 
Function TMSA012Gr2( oModel, cCodPas, cNameGrid )

Local aRet	   := {}
Local cTmp	   := GetNextAlias()
Local cQuery   := ""     

Local aColsPai   := oModel:oFormModelOwner:aCols[oModel:oFormModelOwner:nLine]
Local aHeaderPai := oModel:oFormModelOwner:aHeader
Local nPosCliDes := Ascan(aHeaderPai,{|x| AllTrim(x[2]) == "DYA_CLIDES"})
Local nPosLojDes := Ascan(aHeaderPai,{|x| AllTrim(x[2]) == "DYA_LOJDES"})

cQuery += " SELECT * FROM " + RetSqlName( "DYG" )
cQuery += " WHERE DYG_FILIAL = '" + xFilial("DYG")  + "' "
cQuery += "   AND DYG_TABFRE = '" + DY9->DY9_TABFRE + "' "
cQuery += "   AND DYG_TIPTAB = '" + DY9->DY9_TIPTAB + "' "
cQuery += "   AND DYG_CODPAS = '" + cCodPas         + "' "
cQuery += "   AND DYG_CLIDES = '" + aColsPai[nPosCliDes] + "' "
cQuery += "   AND DYG_LOJDES = '" + aColsPai[nPosLojDes] + "' "
cQuery += "   AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY DYG_ITEM "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .T., .F. )   

aRet := FWLoadByAlias( oModel, cTmp ) 
	
(cTmp)->( dbCloseArea() )

Return( aRet )

//---------------------------------------------------------
/*{Protheus.doc} TMSA012LOk()

Valida a linha da aCols (DYG) 

@sample               	
//TMSA012()

@author Gabriela Kamimoto.
@since 11/09/2012
@version 1.0   
//---------------------------------------------------------
/*/
Function TMSA012LOk( oModelGrid, cNameGrid2 )

Local lRet       := .F.
Local nPosValAte 
Local nPosFatPes 
Local nValAte	   
Local nValPes    

SaveInter()
n		  := oModelGrid:GetLine() //Controle de numero da linha
aHeader   := oModelGrid:aHeader
aCols	  := oModelGrid:aCols

nPosValAte := GDFieldPos("DYG_VALATE")
nPosFatPes := GDFieldPos("DYG_FATPES")
nValAte	   := aCols[n][nPosValAte]
nValPes    := If(nPosFatPes > 0, aCols[n][nPosFatPes], 0)

lRet       := MaCheckCols(aHeader,aCols,n)

//-- Valida se esta deletado
If lRet
	If GDDeleted(n)
		lRet := .T.
	//-- Na primeira linha Valida p/ baixo
	ElseIf n == 1
		lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
										(nValAte >= aLine[nPosValAte] .Or. ;
										IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )}, 2 ) == 0
	//-- Na ultima linha Valida p/ cima
	ElseIf n == Len( aCols )
		lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
										(nValAte <= aLine[nPosValAte]	.Or.;
										IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) )}, 1, Len( Acols ) - 1 ) == 0
	//-- Valida Acima e Abaixo
	Else			
		lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
										(nValAte <= aLine[nPosValAte] .Or. ;
										IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) ) } , 1, n - 1 ) == 0
		
		lRet := lRet .And. ;
				   Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. ;
										(nValAte >= aLine[nPosValAte] .Or.;
										IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )	}, n + 1 ) == 0
	EndIf
	
	If !lRet
		Help("",1,"TMSA01007") //"Campo Ate'/Fator Peso Invalido ou ja existente"
	EndIf

	If lRet .And. !GdDeleted(n) .And. nPosFatPes >0 .And. GDFieldGet('DYG_FATPES',n) < GDFieldGet('DYG_VALATE',n)
		Help("", 1,"TMSA01007")  //"O Fator de Peso Nao pode ser menor do que o Peso ..."
		lRet := .F.
	EndIf

EndIf

RestInter()
Return( lRet )

//---------------------------------------------------------
/*{Protheus.doc} TMSA012GRV()

Gravação

@sample               	
//TMSA012()

@author Valdemar Roberto Mognon
@since 01/05/2022
@version 1.0   
//---------------------------------------------------------
/*/
Function TMSA012GRV(oModel)
Local lRet       := .T.
Local nCntFor1   := 0
Local nCntFor2   := 0
Local nCntFor3   := 0
Local nOperation := 0
Local aModelos   := {}
Local cTabFre    := ""
Local cTipTab    := ""
Local cCodPas    := ""
Local cCliDes    := ""
Local cLojDes    := ""
Local cSeekDYG   := ""
Local oObjDYA	 := Nil
Local oObjDYG	 := Nil

Default oModel := FwModelActive()

Begin Transaction

	nOperation := oModel:GetOperation()

	aModelos := oModel:aAllSubModels

	If nOperation == MODEL_OPERATION_DELETE .Or. nOperation == MODEL_OPERATION_UPDATE
		For nCntFor1 := 2 To Len(aModelos)
			oObjDYA := oModel:GetModel(aModelos[nCntFor1]:cId)
			If "012_DYA" $ oObjDYA:cId
				For nCntFor2 := 1 To oObjDYA:Length()
					oObjDYA:GoLine(nCntFor2)
					DYG->(DbSetOrder(1))
					If DYG->(DbSeek(cSeekDYG := xFilial("DYG") + oObjDYA:GetValue("DYA_TABFRE") + oObjDYA:GetValue("DYA_TIPTAB") + ;
																 oObjDYA:GetValue("DYA_CODPAS") + oObjDYA:GetValue("DYA_CLIDES") + ;
																 oObjDYA:GetValue("DYA_LOJDES")))
						While DYG->(!Eof()) .And. DYG->(DYG_FILIAL + DYG_TABFRE + DYG_TIPTAB + DYG_CODPAS + DYG_CLIDES + DYG_LOJDES) == cSeekDYG
							RecLock("DYG",.F.)
							DYG->(DbDelete())
							DYG->(MsUnlock())
							DYG->(DbSkip())
						EndDo
					EndIf
				Next nCntFor2
			EndIf
		Next nCntFor1
 	EndIf

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		For nCntFor1 := 2 To Len(aModelos)
			oObjDYA := oModel:GetModel(aModelos[nCntFor1]:cId)
			If "012_DYA" $ oObjDYA:cId				
				For nCntFor2 := 1 To oObjDYA:Length()
					oObjDYA:GoLine(nCntFor2)
					oObjDYG := oModel:GetModel("012_DYG" + SubStr(aModelos[nCntFor1]:cId,8))
					If !oObjDYA:IsDeleted(nCntFor2) .And. !oObjDYA:IsEmpty(nCntFor2)
						cTabFre := FwFldGet("DY9_TABFRE")
						cTipTab := FwFldGet("DY9_TIPTAB")
						cCodPas := oObjDYA:GetValue("DYA_CODPAS")
						cCliDes := oObjDYA:GetValue("DYA_CLIDES")
						cLojDes := oObjDYA:GetValue("DYA_LOJDES")
						If ValType(oObjDYG) =="O"
							For nCntFor3 := 1 To oObjDYG:Length()
								oObjDYG:GoLine(nCntFor3)
								If !oObjDYG:IsDeleted(nCntFor3) .And. !oObjDYG:IsEmpty(nCntFor3)
									oObjDYG:LoadValue("DYG_FILIAL",xFilial("DYG"))
									oObjDYG:LoadValue("DYG_TABFRE",cTabFre)
									oObjDYG:LoadValue("DYG_TIPTAB",cTipTab)
									oObjDYG:LoadValue("DYG_CODPAS",cCodPas)
									oObjDYG:LoadValue("DYG_CLIDES",cCliDes)
									oObjDYG:LoadValue("DYG_LOJDES",cLojDes)
								EndIf
							Next nCntFor3
						EndIf	
					EndIf
				Next nCntFor2
			EndIf
		Next nCntFor1
	EndIf
		
	lRet:= FwFormCommit(oModel)

	If !lRet	
		DisarmTransaction()
		Break
	EndIf

End Transaction

Return lRet

//---------------------------------------------------------
/*{Protheus.doc} TMSA012GAT()

Gravação

@sample               	
//TMSA012()

@author Valdemar Roberto Mognon
@since 03/05/2022
@version 1.0   
//---------------------------------------------------------
/*/
Function TMSA012GAT(nAcao)
Local oModel     := FwModelActive()
Local oModelAtu
Local oView      := FwViewActive()
Local aFolder    := oView:GetFolderActive(oView:aFolders[1,1],2)
Local aCols      := {}
Local aHeader    := {}
Local aAreas     := {SA1->(GetArea()),GetArea()}
Local nPosCLiDes := 0
Local nPosLojDes := 0
Local nFolder    := aFolder[1]
Local cChave     := ""
Local cRet       := ""

Default nAcao := 0

oModelAtu := oModel:GetModel("012_DYA_" + Alltrim(Str(nFolder)))

aCols      := oModelAtu:aCols[oModelAtu:nLine]
aHeader    := oModelAtu:aHeader
nPosCliDes := Ascan(aHeader,{|x| AllTrim(x[2]) == "DYA_CLIDES"})
nPosLojDes := Ascan(aHeader,{|x| AllTrim(x[2]) == "DYA_LOJDES"})

If nAcao == 1	//-- Somente cliente
	cChave := aCols[nPosCliDes]
ElseIf nAcao == 2	//-- Cliente mais loja
	cChave := aCols[nPosCliDes] + aCols[nPosLojDes]
EndIf

SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial("SA1") + cChave))
	cRet := SA1->A1_NOME
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return cRet
