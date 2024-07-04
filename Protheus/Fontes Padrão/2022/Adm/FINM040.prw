#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

STATIC aDeParaFK5 := FINLisCpo('FK5')

Function FINM040()

Return

/*/{Protheus.doc}ModelDef
Criação do Modelo de dados - Adiantamento a Receber.
@author William Matos Gundim Junior
@since  14/03/2014
@version 12
/*/
Static Function ModelDef()
Local oModel 	 := MPFormModel():New('FINM040' ,/*PreValidacao*/,/*{|oModel| FINM040Pos(oModel)}*/, {|oModel| FINM040Grv(oModel)},/*bCancel*/ )
Local oCab		 := FWFormModelStruct():New()
Local oStruFKA := FWFormStruct(1,'FKA') //
Local oStruFK3 := FWFormStruct(1,'FK3') //
Local oStruFK4 := FWFormStruct(1,'FK4') //
Local oStruFK5 := FWFormStruct(1,'FK5') //
Local oStruFK7 := FWFormStruct(1,'FK7') //
Local oStruFK8 := FWFormStruct(1,'FK8') //
Local oStruFK9 := FWFormStruct(1,'FK9') //
Local aRelacFK5 := {}
Local aRelacFK3 := {}
Local aRelacFK8 := {}
Local aRelacFK9 := {}
Local aRelacFK4 := {}
Local aRelacFK7 := {}
Local aRelacFKA := {}
Local cProc	  := ""

//Criado master falso para a alimentação dos detail.
oCab:AddTable('MASTER',,'MASTER')

FIN030Master(oCab,oStruFKA)

//Pega o número do processo com base na SE5 posicionada ou gera um novo número de processo 
If !Empty(SE5->E5_IDORIG)
	cProc := FINProcFKs( SE5->E5_IDORIG, "FK7" )
Endif
If Empty(cProc)
	cProc := GetSx8Num('FKA','FKA_IDPROC')	
Endif
oCab:SetProperty( 'IDPROC', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "'" + cProc + "'" ) )

oStruFK7:SetProperty( 'FK7_IDDOC', MODEL_FIELD_OBRIGAT, .F.)
oStruFK5:SetProperty( 'FK5_IDMOV', MODEL_FIELD_OBRIGAT, .F.)
oStruFKA:SetProperty( 'FKA_IDFKA', MODEL_FIELD_OBRIGAT, .F.)
oStruFKA:SetProperty( 'FKA_IDPROC', MODEL_FIELD_OBRIGAT, .F.)
oStruFK8:SetProperty( 'FK8_IDMOV' , MODEL_FIELD_OBRIGAT, .F. )
oStruFK9:SetProperty( 'FK9_IDMOV' , MODEL_FIELD_OBRIGAT, .F. )


//Cria os modelos relacionados.
oModel:AddFields('MASTER', /*cOwner*/, oCab , , ,{|o|{}} )
oModel:AddGrid('FKADETAIL','MASTER'	,oStruFKA)
oModel:AddGrid('FK7DETAIL','FKADETAIL'	,oStruFK7)
oModel:AddGrid('FK5DETAIL','FKADETAIL',oStruFK5)
oModel:AddGrid('FK3DETAIL','FK7DETAIL',oStruFK3)
oModel:AddGrid('FK4DETAIL','FK3DETAIL',oStruFK4)
oModel:AddGrid('FK8DETAIL','FK5DETAIL',oStruFK8)
oModel:AddGrid('FK9DETAIL','FK5DETAIL',oStruFK9)

//Cria os modelos relacionados.
oModel:SetPrimaryKey( {} )

//Seta os modelos como opcionais - FK5, FK7 e FKA são obrigatorias.
oModel:GetModel( 'MASTER'):SetOnlyQuery(.T.)
oModel:GetModel( 'FK5DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK7DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK3DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK4DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK8DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK9DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FKADETAIL' ):SetOptional( .T. )


//Cria relacionamentos FKA->MASTER
aAdd(aRelacFKA,{'FKA_FILIAL','xFilial("FKA")'})
aAdd(aRelacFKA,{'FKA_IDPROC','IDPROC'}) 
oModel:SetRelation('FKADETAIL', aRelacFKA , FKA->(IndexKey(2)))

//Cria relacionamentos FK7->FKA.
aAdd(aRelacFK7,{'FK7_FILIAL','xFilial("FK7")'})
aAdd(aRelacFK7,{'FK7_IDDOC','FKA_IDORIG'})
oModel:SetRelation( 'FK7DETAIL', aRelacFK7 , FK7->(IndexKey(1)))

//Cria relacionamentos FK5->FKA.
aAdd(aRelacFK5,{'FK5_FILIAL','xFilial("FK5")'})
aAdd(aRelacFK5,{'FK5_IDMOV','FKA_IDORIG'})
oModel:SetRelation( 'FK5DETAIL', aRelacFK5 , FK5->(IndexKey(1)))

//Cria relacionamentos FK3->FK7.
aAdd(aRelacFK3,{'FK3_FILIAL','xFilial("FK3")'})
aAdd(aRelacFK3,{'FK3_TABORI',"'FK7'"})
aAdd(aRelacFK3,{'FK3_IDORIG','FKA_IDORIG'})
oModel:SetRelation( 'FK3DETAIL', aRelacFK3 , FK3->(IndexKey(2)))

//Cria relacionamentos FK4->FK3.
aAdd(aRelacFK4,{'FK4_FILIAL','xFilial("FK4")'})
aAdd(aRelacFK4,{'FK4_IDFK4','FK3_IDRET'})
oModel:SetRelation( 'FK4DETAIL', aRelacFK4 , FK4->(IndexKey(1)))

//Cria relacionamentos FK8->FK5.
aAdd(aRelacFK8,{'FK8_FILIAL','xFilial("FK8")'})
aAdd(aRelacFK8,{'FK8_IDMOV','FKA_IDORIG'})
oModel:SetRelation( 'FK8DETAIL', aRelacFK8 , FK8->(IndexKey(1)))

//Cria relacionamentos FK9->FK5.
aAdd(aRelacFK9,{'FK9_FILIAL','xFilial("FK9")'})
aAdd(aRelacFK9,{'FK9_IDMOV','FKA_IDORIG'})
oModel:SetRelation( 'FK9DETAIL', aRelacFK9 , FK9->(IndexKey(1)))

Return oModel

Function FINM040Pos()
Local lRet := .T.

Return lRet

/*/{Protheus.doc}FINM040Grv
Gravação do modelo e de outras entidades.
@param oModel - Modelo de dados
@author William Matos Gundim Ju nior
@since  04/04/2014
@version 12
/*/
Function FINM040Grv(oModel)
Local oFK3		  := oModel:GetModel('FK3DETAIL')
Local oFK4		  := oModel:GetModel('FK4DETAIL')
Local oFK7      := oModel:GetModel('FK7DETAIL')
Local oFK5		  := oModel:GetModel('FK5DETAIL')	
Local oFKA		  := oModel:GetModel('FKADETAIL')
Local nOper 	  := oModel:GetOperation()
Local nOperSE5  := oModel:GetValue('MASTER','E5_OPERACAO')
Local lRet		  := .T.
Local nX		  := 0
Local nY		  := 0
Local nPos		  := 0
Local nLinha	  := 0
Local aValMaster:= {}
Local aAux		  := {}
Local cVetAux	  := ''
Local aCamposFK7:= FK7->(DbStruct())
Local aCamposFK5:= FK5->(DbStruct())
Local aCamposFK9:= FK9->(DbStruct())
Local aCamposFK8:= FK8->(DbStruct())
Local cProc	  :=""
Local aAuxFK5 := {}
Local aAuxFK8 := {}
Local aAuxFK9 := {}
Local cAux := "" 

If !Empty(oModel:GetValue('MASTER','E5_CAMPOS'))
	aValMaster := Separa(oModel:GetValue('MASTER','E5_CAMPOS'),'|')
EndIf

If nOper == MODEL_OPERATION_INSERT

	
	
	If oModel:GetValue( 'MASTER', 'NOVOPROC' )
		oModel:SetValue( 'MASTER', 'IDPROC', GetSx8Num('FKA','FKA_IDPROC') )
	Endif
	
	
	RecLock("SE5",.T.)
	
	For nX := 1 To oFKA:Length()
		
		//Posiciona na FK5 do Model
		oFKA:GoLine(nX)
		oFKA:SetValue('FKA_IDFKA',GetSx8Num('FKA','FKA_IDFKA'))	
		
		FinGrvSE5(aCamposFK5,aDeParaFK5,oFK5)
		E5_FILIAL	:= xFilial("SE5")
		E5_TABORI	:= "FK7"
		If !oFK7:IsEmpty()
			E5_IDORIG	:= oFKA:GetValue('FKA_IDORIG', nX)
		EndIf
		E5_MOVFKS	:= 'S'	// Campo de controle para migração dos dados.	
			
		cVetAux := aValMaster[1]   //Valor recibo do E5_CAMPOS.
		aAux := aClone(&(cVetAux)) 	//Passa para array auxiliar gravar os campos na SE5.
		For nY := 1 To Len(aAux)
		  	&(aAux[nY,1]) := aAux[nY,2]
		Next nY	
					
	Next nX
	
	SE5->(MsUnlock())


ElseIf nOper == MODEL_OPERATION_UPDATE 

	//Atualiza os campos na SE5.
	RecLock("SE5",.F.)
	FinGrvSE5(aCamposFK5,aDeParaFK5,oFK5)
	
	//Valores passados pelo E5_CAMPOS.
	If Len(aValMaster) > 0
	
		cVetAux := aValMaster[1]   //Valor recibo do E5_CAMPOS.
		aAux := aClone(&(cVetAux)) 	//Passa para array auxiliar gravar os campos na SE5.
		For nX := 1 To Len(aAux)
			&( aAux[nX,1] ) := aAux[nX,2]
		Next nX
	
	EndIf
		
	SE5->(MsUnlock())
		
	
	If nOperSE5 > 0
		For nX := 1 To Len(aCamposFK5)	
			aAdd( aAuxFK5 , oFK5:GetValue(aCamposFK5[nX][1]) ) 
		Next nX
		
		For nX := 1 To Len(aCamposFK8)	
			aAdd( aAuxFK8 , oFK8:GetValue(aCamposFK8[nX][1]) ) 
		Next nX
		
		For nX := 1 To Len(aCamposFK9)	
			aAdd( aAuxFK9 , oFK9:GetValue(aCamposFK9[nX][1]) ) 
		Next nX
		
		nLen := oFKA:Length()
		If oFKA:AddLine() == nLen + 1
			oFKA:SetValue( 'FKA_IDFKA', GetSx8Num("FKA", "FKA_IDFKA") )
			oFKA:SetValue( 'FKA_IDORIG', FWUUIDV4() )		
			
			For nX := 1 To Len(aCamposFK5)		
				oFK5:SetValue( aCamposFK5[nX][1], aAuxFK5[nX] )					
			Next nX								
			oFK5:SetValue('FK5_TPDOC', 'ES')
			
			//Grava FK8 e inverte os valores de debito e crédito
			If Len(aCamposFK8) > 0			
				For nX := 1 To Len(aCamposFK8)		
					oFK8:SetValue( aCamposFK8[nX][1], aAuxFK8[nX] )					
				Next nX
			
				cAux := oFK8:GetValue( "FK8_DEBITO" )
				oFK8:SetValue( "FK8_DEBITO", oFK8:GetValue( "FK8_CREDIT" ) )
				oFK8:SetValue( "FK8_CREDIT", cAux )
				
				cAux := oFK8:GetValue( "FK8_CCD" )
				oFK8:SetValue( "FK8_CCD", oFK8:GetValue( "FK8_CCC" ) )
				oFK8:SetValue( "FK8_CCC", cAux )
				
				cAux := oFK8:GetValue( "FK8_ITEMD" )
				oFK8:SetValue( "FK8_ITEMD", oFK8:GetValue( "FK8_ITEMC" ) )
				oFK8:SetValue( "FK8_ITEMC", cAux )
				
				cAux := oFK8:GetValue( "FK8_CLVLDB" )
				oFK8:SetValue( "FK8_CLVLDB", oFK8:GetValue( "FK8_CLVLCR" ) )
				oFK8:SetValue( "FK8_CLVLCR", cAux )
				
				cAux := AllTrim( oFK8:GetValue( "FK8_TPLAN" ) )
				cAux := Iif( cAux == "1", "2", Iif( cAux == "2", "1", "3" ) )
				oFK8:SetValue( "FK8_TPLAN", cAux )
			Endif
			
			For nX := 1 To Len(aCamposFK9)		
				oFK9:SetValue( aCamposFK9[nX][1], aAuxFK9[nX] )					
			Next nX			
			
		EndIf			
			
		//Atualiza a SE5 - Mov. Bancaria conforme a operação.			
		Do Case
			
			Case nOperSE5 == 1 //Exclusão(Atualiza SITUACA = 'C') 
				
				RecLock("SE5",.F.)
				E5_SITUACA := 'C'
				SE5->(MsUnlock())
				
			Case nOperSE5 == 2 //	Estorno
			
				If !oFK5:IsEmpty()
				
					RecLock("SE5",.T.)
					FinGrvSE5(aCamposFK5,aDeParaFK5,oFK5)
				
					E5_FILIAL  := xFilial("SE5")
					E5_TIPODOC	:= 'ES'
					E5_TABORI  := "FK7"
					E5_MOVCX   := Iif( Alltrim(oFK5:GetValue('FK5_ORIGEM' ,nX)) == "FINA550", "S", "" )
					E5_MOVFKS	 := 'S'	// Campo de controle para migração dos dados.
					SE5->(MsUnlock())
				EndIf	
			
			Case nOperSE5 == 3 //Exclui registro. 
			
				RecLock("SE5", .F.)
				SE5->(dbDelete())
				SE5->(MsUnlock())
		
		End Case
			
	EndIf	
	
EndIf

FWFormCommit( oModel )

Return lRet