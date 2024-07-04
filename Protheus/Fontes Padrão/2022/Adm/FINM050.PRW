#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH' 

STATIC __aCposFK5	:= NIL
STATIC __aCposFK3	:= NIL
STATIC __aCposFK4	:= NIL
STATIC __aCposFK8	:= NIL
STATIC __aCposFK9	:= NIL
STATIC aDeParaFK8 	:= FINLisCpo('FK8')
STATIC aDeParaFK9 	:= FINLisCpo('FK9')
STATIC aDeParaFK5 	:= FINLisCpo('FK5')
STATIC nSaveSx8   	:= 0
STATIC nTamHist		:= TamSx3("FK2_HISTOR")[1]
STATIC nTamFil  	:= TamSx3("FK5_FILIAL")[1]
STATIC nTamTpDoc	:= TamSx3("E5_TIPODOC")[1]
STATIC nTamLA	 	:= TamSx3("E5_LA")[1]
STATIC aRecSE5		:= {}
STATIC nSaveSx8   	:= 0

Function FINM050()

Return .T.

//-------------------------------------------
/*/{Protheus.doc}ModelDef
Criação do Modelo de dados - Geração PA.
@author Mauricio Pequim Jr
@since  24/02/2021
@version 12
/*/
//-------------------------------------------
Static Function ModelDef()

Local oModel	:= MPFormModel():New('FINM050' ,/*{|oModel| FINM050Pre(oModel)}*/,{|oModel| FINM050Pos(oModel)}, {|oModel| FINM050Grv(oModel)},/*bCancel*/ )
Local oMaster	:= FWFormModelStruct():New()
Local oStruFKA	:= FWFormStruct(1,'FKA') //
Local oStruFK3	:= FWFormStruct(1,'FK3') //
Local oStruFK4	:= FWFormStruct(1,'FK4') //
Local oStruFK5	:= FWFormStruct(1,'FK5') //
Local oStruFK8	:= FWFormStruct(1,'FK8') //
Local oStruFK9	:= FWFormStruct(1,'FK9') //
Local aRelacFKA := {}
Local aRelacFK3 := {}
Local aRelacFK4 := {}
Local aRelacFK5 := {}
Local aRelacFK8 := {}
Local aRelacFK9 := {}
Local cProcFKs  := ""
Local nX 		:= 0  

nSaveSx8 := GetSX8Len()

//Criado master falso para a alimentação dos detail.
oMaster:AddTable('MASTER',,'MASTER')

FIN030Master(oMaster)

If __aCposFK5 == NIL
	__aCposFK5 := FK5->(DbStruct())
Endif

For nX := 1 To Len(__aCposFK5)
	oStruFK5:SetProperty(__aCposFK5[nX][1], MODEL_FIELD_OBRIGAT, .F.)
Next nX

//Chama a criação do cProc
cProcFKs:= FINPrcFKA()

oMaster:SetProperty( 'IDPROC', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "'" + cProcFKs + "'" ) )

oStruFKA:SetProperty( 'FKA_IDFKA' , MODEL_FIELD_OBRIGAT, .F. )
oStruFKA:SetProperty( 'FKA_IDPROC', MODEL_FIELD_OBRIGAT, .F. )

oStruFK5:SetProperty( 'FK5_IDMOV' , MODEL_FIELD_OBRIGAT, .F. )
oStruFK5:SetProperty( 'FK5_NATURE', MODEL_FIELD_OBRIGAT, .F. )
oStruFK5:SetProperty( 'FK5_NATURE', MODEL_FIELD_VALID, {||.T.} )

oStruFK8:SetProperty( 'FK8_IDMOV' , MODEL_FIELD_OBRIGAT, .F. )
oStruFK9:SetProperty( 'FK9_IDMOV' , MODEL_FIELD_OBRIGAT, .F. )
oStruFK3:SetProperty( "FK3_IDRET" , MODEL_FIELD_OBRIGAT, .F. )
oStruFK4:SetProperty( "FK4_IDORIG", MODEL_FIELD_OBRIGAT, .F. )

//Cria os modelos relacionados.
oModel:AddFields('MASTER', /*cOwner*/, oMaster , , ,{|o|{}} )
oModel:AddGrid('FKADETAIL','MASTER'   ,oStruFKA)
oModel:AddGrid('FK5DETAIL','FKADETAIL',oStruFK5)
oModel:AddGrid('FK8DETAIL','FK5DETAIL',oStruFK8)
oModel:AddGrid('FK9DETAIL','FK5DETAIL',oStruFK9)
oModel:AddGrid('FK3DETAIL','FKADETAIL',oStruFK3)
oModel:AddGrid('FK4DETAIL','FK3DETAIL',oStruFK4)

oModel:SetPrimaryKey( {} )

//Seta os modelos como opcionais - FK5 e FKA são obrigatorias.
oModel:GetModel( 'MASTER' ):SetOnlyQuery(.T.)
oModel:GetModel( 'FK3DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK4DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK5DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK8DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FKADETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK9DETAIL' ):SetOptional( .T. )

oModel:SetPrimaryKey( {} )

//Cria relacionamentos FK8->FK5.
aAdd(aRelacFK8,{'FK8_FILIAL','xFilial("FK8")'})
aAdd(aRelacFK8,{'FK8_IDMOV','FKA_IDORIG'})
oModel:SetRelation( 'FK8DETAIL', aRelacFK8 , FK8->(IndexKey(1)))

//Cria relacionamentos FK9->FK5.
aAdd(aRelacFK9,{'FK9_FILIAL','xFilial("FK4")'})
aAdd(aRelacFK9,{'FK9_IDMOV','FKA_IDORIG'})
oModel:SetRelation('FK9DETAIL', aRelacFK9 , FK9->(IndexKey(1)))

//Cria relacionamentos FK3->SE2
aAdd(aRelacFK3,{'FK3_FILIAL','xFilial("FK3")'})
aAdd(aRelacFK3,{'FK3_TABORI',"'SE2'"})
aAdd(aRelacFK3,{'FK3_IDORIG','FKA_IDORIG'})
oModel:SetRelation( 'FK3DETAIL', aRelacFK3 , FK3->(IndexKey(2)))

//Cria relacionamentos FK4->FK3.
aAdd(aRelacFK4,{'FK4_FILIAL','xFilial("FK4")'})
aAdd(aRelacFK4,{'FK4_IDORIG','FKA_IDORIG'    })
oModel:SetRelation( 'FK4DETAIL', aRelacFK4 , FK4->(IndexKey(1)))

//Cria relacionamento FKA -> MASTER
aAdd(aRelacFKA,{'FKA_FILIAL','xFilial("FKA")' })
aAdd(aRelacFKA,{'FKA_IDPROC','IDPROC'}) 
oModel:SetRelation('FKADETAIL', aRelacFKA , FKA->(IndexKey(2)))

//Cria relacionamento FK5 -> FKA
aAdd(aRelacFK5,{'FK5_FILIAL','xFilial("FK5")' })
aAdd(aRelacFK5,{'FK5_IDMOV','FKA_IDORIG'})
oModel:SetRelation('FK5DETAIL', aRelacFK5 , FK5->(IndexKey(1)))

Return oModel

//-------------------------------------------
/*/{Protheus.doc}FINM050Grv
Gravação do modelo e de outras entidades.
@param oModel - Modelo de dados
@author Mauricio Pequim Jr
@since  24/02/2021
@version 12
/*/
//-------------------------------------------
Function FINM050Grv(oModel)

Local oFK3		:= oModel:GetModel('FK3DETAIL')
Local oFK4		:= oModel:GetModel('FK4DETAIL')
Local oFK5		:= oModel:GetModel('FK5DETAIL')	
Local oFK8  	:= oModel:GetModel('FK8DETAIL')
Local oFK9	 	:= oModel:GetModel('FK9DETAIL')
Local oFKA		:= oModel:GetModel('FKADETAIL')
Local nOper 	:= oModel:GetOperation()
Local nOperSE5  := oModel:GetValue('MASTER','E5_OPERACAO')
Local cHistCan  := oModel:GetValue('MASTER','HISTMOV')
Local cLA		:= oModel:GetValue('MASTER','E5_LA')
Local lRet		:= .T.
Local nX		:= 0
Local nY		:= 0
Local nK		:= 0
Local nPos		:= 0
Local aValMaster:= {}
Local aAux		:= {}
Local cVetAux	:= ''
Local aAuxFK3	:= {}
Local aAuxFK4	:= {}
Local aAuxFK5	:= {}
Local aAuxFK8	:= {}
Local aAuxFK9	:= {}
Local aOldFK3	:= {}
Local aOldFK4	:= {}
Local cAux		:= ""  
Local aSE5		:= {}	 	
Local nCountSE5 := SE5->(Fcount())
Local cCart		:= "P" 
Local nLen		:= 0
Local nTamFKA	:= 0
Local nTamE5Cpos := 0
Local cIdOrig 	:= ""
Local cTabOri	:= ""
Local cIdFKA 	:= ""
Local cTbFKA	:= ""

If __aCposFK5 == NIL
	__aCposFK5 := FK5->(DbStruct())
Endif
If __aCposFK3 == NIL
	__aCposFK3 := FK3->(DbStruct())
Endif
If __aCposFK4 == NIL
	__aCposFK4 := FK4->(DbStruct())
Endif
If __aCposFK8 == NIL
	__aCposFK8 := FK8->(DbStruct())
Endif
If __aCposFK9 == NIL
	__aCposFK9 := FK9->(DbStruct())
Endif

If !Empty(oModel:GetValue('MASTER','E5_CAMPOS'))
	aValMaster := Separa(oModel:GetValue('MASTER','E5_CAMPOS'),'|')
	nTamE5Cpos := Len(aValMaster)
EndIf

If nOper == MODEL_OPERATION_INSERT

	If oModel:GetValue( 'MASTER', 'NOVOPROC' )
		oModel:SetValue( 'MASTER', 'IDPROC', FINFKSID('FKA','FKA_IDPROC') )
	Endif

	If oModel:GetValue("MASTER", "E5_GRV")

		For nX := 1 To oFKA:Length()

			oFKA:GoLine(nX)
			oFKA:SetValue( 'FKA_IDFKA', FWUUIDV4() )
			
			//Grava SE5 - Movimento Bancario.				
			If !oFK5:IsEmpty()
				RecLock("SE5",.T.)			
				FinGrvSE5(__aCposFK5,aDeParaFK5,oFK5)
							
				E5_FILIAL	:= xFilial("SE5")
				E5_TABORI	:= oFKA:GetValue('FKA_TABORI', nX)
				E5_MOVFKS	:= 'S'	// Campo de controle para migração dos dados.
				E5_TIPODOC	:= oFK5:GetValue('FK5_TPDOC') 
				E5_IDORIG	:= oFKA:GetValue('FKA_IDORIG', nX)
				E5_RATEIO	:= If(oFK5:GetValue('FK5_RATEIO') == '1', 'S', 'N')
				
				If oFK5:IsFieldUpdated('FK5_TPMOV')
					E5_TIPOMOV := If(AllTrim(oFK5:GetValue('FK5_TPMOV')) == '1', '01', '02')					
				EndIf
				
				//Para cada FK5, há um grupo de E5_CAMPOS diferente 
				nK ++
				cVetAux := aValMaster[nK]   //Valor recibo do E5_CAMPOS.

				//Grava os campos complementares da SE5
				FGrvCpoSE5(cVetAux,aAux)

				SE5->(MsUnlock())				

				oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))				
			
				If !oFK8:IsEmpty() 
					RecLock("SE5",.F.)							
					FinGrvSE5(__aCposFK8,aDeParaFK8,oFK8)
					If oFK8:IsFieldUpdated('FK8_TPLAN')
						E5_TIPOLAN := Iif( AllTrim(oFK8:GetValue('FK8_TPLAN', nX)) == '1', 'D', Iif( AllTrim(oFK8:GetValue('FK8_TPLAN', nX)) == '2', 'C', 'X') )
					EndIf	
					SE5->(MsUnlock())												
				EndIf
						
				If !oFK9:IsEmpty() 
					RecLock("SE5",.F.)				     		
					FinGrvSE5(__aCposFK9,aDeParaFK9,oFK9)
					SE5->(MsUnlock())
				EndIf		
			EndIf
		Next
	Endif

ElseIf nOper == MODEL_OPERATION_UPDATE 

	//Atualiza os campos na SE5.
	If !SE5->(EOF())
		RecLock("SE5",.F.)
		For nX := 1 To Len(__aCposFK5)
			If oFK5:IsFieldUpdated(__aCposFK5[nX][1])  //Retorna se campo foi atualizado.
				If ( nPos := aScan(aDeParaFK5,{|x| AllTrim( x[1] ) ==  __aCposFK5[nX][1] } ) ) > 0  
					SE5->(FieldPut(FieldPos(aDeParaFK5[nPos,2]) , oFK5:GetValue(__aCposFK5[nX][1])))
				EndIf
			EndIf
		Next nX
	
		//Valores passados pelo E5_CAMPOS.
		For nX := 1 To Len(aValMaster) 
			//Grava valores na SE5 passados pelo campo MEMO.
			cVetAux := aValMaster[nX]   //Valor recibo do E5_CAMPOS.
			//aAux := aClone(&(cVetAux))
			//Substituida a macro da cVetAux devido a possibilidade de existirem caracteres especiais em campos texto (históricos, beneficiário)
			//Grava os campos complementares da SE5
			FGrvCpoSE5(cVetAux,aAux)	
		Next nX
		
		SE5->(MsUnlock())
		oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))
	Endif

	nTamFKA := oFKA:Length()
	
	If nOperSE5 > 0

		//Grava SE5 com os valores da SE2 - Baixas a Pagar.
		For nY := 1 To nTamFKA
			//Posiciona na FKA do Model
			oFKA:GoLine(nY)

			cTabOri := oFKA:GetValue("FKA_TABORI")

			//Movimento bancario
			oFK5 := oModel:GetModel('FK5DETAIL')

    		//Impostos Calculados
			oFK3 := oModel:GetModel('FK3DETAIL')			
    		//Impostos Retidos
			oFK4 := oModel:GetModel('FK4DETAIL')			

			//Estorno de valores impostos calculados
			If !oFK3:IsEmpty()
				aOldFK3 := {}
				For nK := 1 To oFK3:Length()
					oFK3:GoLine(nK)					
					aAuxFK3 := {}						
					For nX := 1 To Len(__aCposFK3)	
						aAdd( aAuxFK3 , oFK3:GetValue(__aCposFK3[nX][1]) ) 
					Next nX
					aadd (aOldFK3, aAuxFK3)
				Next nK
			Endif
				
			//Estorno de valores impostos retidos
			If !oFK4:IsEmpty()
				aOldFK4 := {}
				For nK := 1 To oFK4:Length()
					oFK4:GoLine(nK)					
					aAuxFK4 := {}						
					For nX := 1 To Len(__aCposFK4)	
						aAdd( aAuxFK4 , oFK4:GetValue(__aCposFK4[nX][1]) ) 
					Next nX
					aadd (aOldFK4, aAuxFK4)
				Next nK
			Endif

			//Estorno impostos
			If !oFK3:IsEmpty()
				FinEstFK34(aOldFK3, aOldFK4)
			Endif

			//Estorno na FKA
			nLen := oFKA:Length()

			If cTabOri == 'SE2'
				cIdOrig := oFKA:GetValue("FKA_IDORIG")
				If oFKA:AddLine() == nLen + 1
			
					oFKA:SetValue( 'FKA_IDFKA', FWUUIDV4() )
					oFKA:SetValue( 'FKA_IDORIG', cIdOrig)
					oFKA:SetValue( 'FKA_TABORI', cTabOri)

					If Empty(cIdFKA)
						cIdFKASE2 := cIdOrig
						cTbFKASE2 := cTabOri
					Endif

					//Estorno impostos
					If Len(aOldFK3) > 0
						FGrvEstFks(aOldFK3, aOldFK4, .T.)
					Endif			

				EndIf			
			ElseIf cTabOri == 'SEF'
				cIdOrig := oFKA:GetValue("FKA_IDORIG")
				If oFKA:AddLine() == nLen + 1
			
					oFKA:SetValue( 'FKA_IDFKA', FWUUIDV4() )
					oFKA:SetValue( 'FKA_IDORIG', cIdOrig)
					oFKA:SetValue( 'FKA_TABORI', cTabOri)

				EndIf			

			ElseIf !oFK5:IsEmpty()		
				aAuxFK5 := {}
				aAuxFK8 := {}
				aAuxFK9 := {}
				
				For nX := 1 To Len(__aCposFK5)	
					aAdd( aAuxFK5 , oFK5:GetValue(__aCposFK5[nX][1]) ) 
				Next nX
				
				For nX := 1 To Len(__aCposFK8)	
					aAdd( aAuxFK8 , oFK8:GetValue(__aCposFK8[nX][1]) ) 
				Next nX
				
				For nX := 1 To Len(__aCposFK9)	
					aAdd( aAuxFK9 , oFK9:GetValue(__aCposFK9[nX][1]) ) 
				Next nX

				cCart := oFK5:GetValue('FK5_RECPAG')

				//Estorno na FK5
				nLen := oFKA:Length()
				If oFKA:AddLine() == nLen + 1

					cIdOrig := FWUUIDV4()

					oFKA:SetValue( 'FKA_IDFKA', FWUUIDV4() )
					oFKA:SetValue( 'FKA_IDORIG', cIdOrig )		
					oFKA:SetValue( 'FKA_TABORI', 'FK5')										
					For nX := 1 To Len(__aCposFK5)		
						oFK5:SetValue( __aCposFK5[nX][1], aAuxFK5[nX] )					
					Next nX								
					oFK5:SetValue('FK5_TPDOC', 'ES')
					oFK5:SetValue('FK5_HISTOR', cHistCan)					
					oFK5:SetValue('FK5_RECPAG', If(cCart == "P","R","P"))
					oFK5:SetValue('FK5_DATA', dDatabase)
					oFK5:SetValue('FK5_DTCONC', CTOD("//"))

					cIdFKA := cIdOrig
					cTbFKA := cTabOri

					//Grava FK8 e inverte os valores de debito e crédito
					If Len(__aCposFK8) > 0	.and. !oFK8:IsEmpty()		
						For nX := 1 To Len(__aCposFK8)		
							oFK8:LoadValue( __aCposFK8[nX][1], aAuxFK8[nX] )					
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
		
					If !oFK9:IsEmpty()
						For nX := 1 To Len(__aCposFK9)		
							oFK9:SetValue( __aCposFK9[nX][1], aAuxFK9[nX] )					
						Next nX	
					Endif
				EndIf			
 		    Endif
		Next nY

		//Atualiza a SE5 - Mov. Bancaria conforme a operação.
		If !SE5->(EOF())
			Do Case
				Case nOperSE5 == 1 //Exclusão(Atualiza SITUACA = 'C') 
					RecLock("SE5",.F.)
					E5_SITUACA := 'C'
					SE5->(MsUnlock())
					oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))

				Case nOperSE5 == 2 //	Estorno
					//Obtenho os dados do registro a ser estornado
					For nX := 1 to nCountSE5
						AAdd( aSE5, Iif(nX==2/*data*/ .And. ValType(SE5->( FieldGet(nX))) == "D",dDatabase,SE5->( FieldGet(nX)) ) )
					Next
					// Grava o registro de estorno
					RecLock("SE5" ,.T.)
					For nX := 1 to nCountSE5
						SE5->( FieldPut( nX,aSE5[nX]))
					Next
					SE5->E5_FILIAL	:= xFilial("SE5")
					SE5->E5_TIPODOC	:= 'ES'
					SE5->E5_TABORI	:= cTbFKA
					SE5->E5_IDORIG	:= cIdFKA
					SE5->E5_MOVFKS	:= 'S'	// Campo de controle para migração dos dados.
					SE5->E5_RECPAG	:= If(cCart == "P","R","P")
					SE5->E5_HISTOR	:= cHistCan
					SE5->E5_LA		:= cLa
					SE5->E5_DATA	:= dDatabase
					SE5->E5_DTDIGIT	:= dDatabase
					SE5->E5_DTDISPO	:= dDatabase
					SE5->E5_RECONC	:= ''
					SE5->(MsUnlock())
					oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))
					
				Case nOperSE5 >= 3 //Exclui registro. 
					RecLock("SE5", .F.)
					SE5->(dbDelete())
					SE5->(MsUnlock())
					oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))
			End Case
		EndIF
	EndIf
EndIf

lRet := FwFormCommit( oModel ) 

If lRet
	//Confirma os valores incrementais da GetSx8Num()
	While (GetSx8Len() > nSaveSx8)
		ConfirmSX8()			
	EndDo
Endif

nSaveSx8 := 0

Return lRet


/*/{Protheus.doc}FINM050Grv
Pos validacao do modelo e de outras entidades.
@param oModel - Modelo de dados
@author William Matos Gundim Junior
@since  04/04/2014
@version 12
/*/
Function FINM050Pos( oModel )

Local lRet := .T.

Return lRet

/*/{Protheus.doc} FIM020RSE5
Função que retornar os Recnos dos SE5 gravados no commit do Modelo de Dados.
@author Marylly Araújo Silva
@since  12/05/2014
@version 12
/*/
Function FIM050RSE5()
Return aRecSE5

