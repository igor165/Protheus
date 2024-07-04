#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH' 

STATIC aDeParaFK1	:= FINLisCpo('FK1')
STATIC aDeParaFK5	:= FINLisCpo('FK5')
STATIC aRecSE5		:= {}
STATIC nSaveSx8   	:= 0
STATIC aCamposFK1	:= Nil
STATIC aCamposFK3	:= Nil
STATIC aCamposFK4	:= Nil
STATIC aCamposFK5	:= Nil
STATIC aCamposFK6	:= Nil
STATIC aCamposFK9	:= Nil
STATIC aCamposFK8	:= Nil
STATIC nCountSE5	:= Nil
STATIC lCmpFK1		:= Nil

Function FINM010()

Return

/*/{Protheus.doc}ModelDef
Criação do Modelo de dados - Baixa a Receber.
@author William Matos Gundim Junior
@since  14/03/2014
@version 12
/*/
Static Function ModelDef()
Local oModel 	 := MPFormModel():New('FINM010' ,{|oModel| FINM010Pre(oModel)},{|oModel| FINM010Pos(oModel)}, {|oModel| FINM010Grv(oModel)},/*bCancel*/ )
Local oCab		 := FWFormModelStruct():New()
Local oStruFKA := FWFormStruct(1,'FKA') //
Local oStruFK1 := FWFormStruct(1,'FK1') //
Local oStruFK3 := FWFormStruct(1,'FK3') //
Local oStruFK4 := FWFormStruct(1,'FK4') //
Local oStruFK5 := FWFormStruct(1,'FK5') //
Local oStruFK6 := FWFormStruct(1,'FK6') //
Local oStruFK7 := FWFormStruct(1,'FK7') //Auxiliar SE1/SE2.//
Local oStruFK8 := FWFormStruct(1,'FK8') //
Local oStruFK9 := FWFormStruct(1,'FK9') //
Local aRelacFKA := {}
Local aRelacFK1 := {}
Local aRelacFK3 := {}
Local aRelacFK4 := {}
Local aRelacFK5 := {}
Local aRelacFK6 := {}
Local aRelacFK7 := {}
Local aRelacFK8 := {}
Local aRelacFK9 := {}
Local cProc	    := ""
Local aCamposFK5 := FK5->(DbStruct())
Local nX 		:= 0      
Local cChave	:= SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
Local cCodNat	:= ""
Local aAliasAnt	:= {}
	
If SE1->(!Eof()) .And. Empty(SE1->E1_NATUREZ)
	cCodNat := FINNATFKS()
	//Verifica se o título possui natureza
	aAliasAnt	:= GetArea() 
	If Empty(SE1->E1_NATUREZ) 
		Reclock("SE1",.F.)
		SE1->E1_NATUREZ	:= cCodNat
		MsUnlock()
	EndIf	
	RestArea(aAliasAnt)
Endif

//Migra o registro de SE5 posicionado que ainda não foi migrado
If SE5->E5_MOVFKS <> 'S' .AND. SE5->( !EOF() ) .and. !Empty(cChave)
	FINXSE5(SE5->(Recno()), 3)
EndIf

nSaveSx8 := GetSX8Len()

//Criado master falso para a alimentação dos detail.
oCab:AddTable('MASTER',,'MASTER')

FIN030Master(oCab)

//Salva os dados na SE5.
oStruFK6:AddField("FK6_GRVSE5","","FK6_GRVSE5","L",1,0,/*bValid*/,/*When*/,{.T.,.F.},.F.,/* */,/*Key*/,.F.,.T.,)

For nX := 1 To Len(aCamposFK5)
	oStruFK5:SetProperty(aCamposFK5[nX][1], MODEL_FIELD_OBRIGAT, .F.)
Next nX

//Chama a criação do cProc
If cPaisLoc == "ARG" .And. FunName() == "FINA096"
	cProc:= FINProcFKs(SE5->E5_IDORIG, Iif(SE5->E5_TABORI == "FK1", "FK1", "FK5"), SE5->E5_SEQ)
Else
	cProc:= FINProcFKs(SE5->E5_IDORIG, "FK1", SE5->E5_SEQ)
EndIf	

oCab:SetProperty( 'IDPROC', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "'" + cProc + "'" ) )
oStruFK6:SetProperty( "FK6_GRVSE5", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, '.T.' ) )

//Tratamento para ambientes localizados, onde o campo E1_NATUREZ não é obrigatório
//Estendo o escopo desse campo para o campo FK1_NATURE
If cPaisLoc <> "BRA" .And. cPaisLoc <> "PER"
	oStruFK1:SetProperty( 'FK1_NATURE', MODEL_FIELD_OBRIGAT, .F.)
EndIf

oStruFK1:SetProperty( 'FK1_NATURE', MODEL_FIELD_VALID, {||.T.} )

oStruFK1:SetProperty( 'FK1_IDFK1' , MODEL_FIELD_OBRIGAT, .F.)
oStruFK1:SetProperty( 'FK1_VENCTO', MODEL_FIELD_OBRIGAT, .F.)
oStruFK3:SetProperty( "FK3_IDRET" , MODEL_FIELD_OBRIGAT, .F.)
oStruFK4:SetProperty( "FK4_IDORIG", MODEL_FIELD_OBRIGAT, .F.)
oStruFKA:SetProperty( 'FKA_IDFKA' , MODEL_FIELD_OBRIGAT, .F.)
oStruFKA:SetProperty( 'FKA_IDPROC', MODEL_FIELD_OBRIGAT, .F.)
oStruFK6:SetProperty( 'FK6_IDFK6' , MODEL_FIELD_OBRIGAT, .F.)
//Retira a validação dos campos abaixo.
//Validação original: Positivo()
//No entanto correção monetária pode ser negativa.
oStruFK1:SetProperty("FK1_VALOR"  , MODEL_FIELD_VALID , {||.T.} )
oStruFK6:SetProperty("FK6_VALCAL" , MODEL_FIELD_VALID , {||.T.} )
oStruFK6:SetProperty("FK6_VALMOV" , MODEL_FIELD_VALID , {||.T.} )

//Cria os modelos relacionados.
oModel:AddFields('MASTER', /*cOwner*/, oCab , , ,{|o|{}} )
oModel:AddGrid('FKADETAIL','MASTER'	,oStruFKA) 
oModel:AddGrid('FK5DETAIL','FKADETAIL',oStruFK5)
oModel:AddGrid('FK1DETAIL','FKADETAIL',oStruFK1) 
oModel:AddGrid('FK8DETAIL','FK5DETAIL',oStruFK8)
oModel:AddGrid('FK9DETAIL','FK5DETAIL',oStruFK9)
oModel:AddGrid('FK3DETAIL','FK1DETAIL',oStruFK3)
oModel:AddGrid('FK4DETAIL','FK3DETAIL',oStruFK4)
oModel:AddGrid('FK6DETAIL','FK1DETAIL',oStruFK6)
//Preenchimento opcional. - FK1, FKA são obrigatórias na função de gravação.
oModel:GetModel( 'MASTER'):SetOnlyQuery(.T.)
oModel:GetModel('FK1DETAIL'):SetOptional( .T. )
oModel:GetModel('FKADETAIL'):SetOptional( .T. )
oModel:GetModel('FK3DETAIL'):SetOptional( .T. )
oModel:GetModel('FK4DETAIL'):SetOptional( .T. )
oModel:GetModel('FK5DETAIL'):SetOptional( .T. )
oModel:GetModel('FK6DETAIL'):SetOptional( .T. )
oModel:GetModel('FK8DETAIL'):SetOptional( .T. )
oModel:GetModel('FK9DETAIL'):SetOptional( .T. )

oModel:SetPrimaryKey( {} )

//Cria relacionamentos FKA->MASTER
aAdd(aRelacFKA,{'FKA_FILIAL','xFilial("FKA")'})
aAdd(aRelacFKA,{'FKA_IDPROC','IDPROC'}) 
oModel:SetRelation('FKADETAIL', aRelacFKA , FKA->(IndexKey(2)))

//Cria relacionamento FK1->FKA
aAdd(aRelacFK1,{'FK1_FILIAL','xFilial("FK1")'})
aAdd(aRelacFK1,{'FK1_IDFK1','FKA_IDORIG'})
oModel:SetRelation('FK1DETAIL', aRelacFK1 , FK1->(IndexKey(1)))

//Cria relacionamentos FK5->FKA.
aAdd(aRelacFK5,{'FK5_FILIAL','xFilial("FK5")'})
aAdd(aRelacFK5,{'FK5_IDMOV','FKA_IDORIG'})
oModel:SetRelation( 'FK5DETAIL', aRelacFK5 , FK5->(IndexKey(1)))

//Cria relacionamentos FK6->FKA. 
aAdd(aRelacFK6,{'FK6_FILIAL','xFilial("FK6")'})
aAdd(aRelacFK6,{'FK6_IDORIG','FKA_IDORIG'})
oModel:SetRelation( 'FK6DETAIL', aRelacFK6 , FK6->(IndexKey(1)))

//Cria relacionamentos FK3->FK1.
aAdd(aRelacFK3,{'FK3_FILIAL','xFilial("FK3")'})
aAdd(aRelacFK3,{'FK3_TABORI',"'FK1'"})
aAdd(aRelacFK3,{'FK3_IDORIG','FKA_IDORIG'})
oModel:SetRelation( 'FK3DETAIL', aRelacFK3 , FK3->(IndexKey(2)))

//Cria relacionamentos FK4->FK3.
aAdd(aRelacFK4,{'FK4_FILIAL','xFilial("FK4")'})
aAdd(aRelacFK4,{'FK4_IDORIG','FKA_IDORIG'    })
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

/*/{Protheus.doc}FINM010Grv
Gravação do modelo e de outras entidades.
@param oModel - Modelo de dados
@author William Matos Gundim Junior
@since  04/04/2014
@version 12
/*/
Function FINM010Grv(oModel)
Local aArea 	:= GetArea()
Local oFK1		:= oModel:GetModel('FK1DETAIL')
Local oFK3		:= oModel:GetModel('FK3DETAIL')	
Local oFK4		:= oModel:GetModel('FK4DETAIL')
Local oFK5		:= oModel:GetModel('FK5DETAIL')	
Local oFK6		:= oModel:GetModel('FK6DETAIL')
Local oFK8  	:= oModel:GetModel('FK8DETAIL')
Local oFK9	 	:= oModel:GetModel('FK9DETAIL')
Local oFKA		:= oModel:GetModel('FKADETAIL')
Local nOper 	:= oModel:GetOperation()
Local nOperSE5  := oModel:GetValue('MASTER','E5_OPERACAO')
Local cHistCan  := oModel:GetValue('MASTER','HISTMOV')
Local cLA		  := oModel:GetValue('MASTER','E5_LA')
Local lRet		:= .T.
Local nX		:= 0
Local nY		:= 0
Local nK		:= 0
Local nM		:= 0
Local nPos		:= 0
Local nLinha	:= 0
Local aValMaster:= {}
Local aAux		:= {}
Local cVetAux	:= ''
Local cProc		:= ""
Local cLog		:= ""
Local aAuxFK1	:= {}
Local aAuxFK3	:= {}
Local aAuxFK4	:= {}
Local aAuxFK5	:= {}
Local aAuxFK6	:= {}
Local aAuxFK8	:= {}
Local aAuxFK9	:= {}
Local aOldFK6	:= {}
Local aOldFK3	:= {}
Local aOldFK4	:= {}
Local cAux		:= ""  
Local nPosFK1	:= 0    
Local aSE5		:= {}	 	
Local cCart		:= "R"
Local cIdFK1	:= ""
Local oSubFK3	:= Nil
Local oSubFK4	:= Nil
Local oSubFK6	:= Nil
Local nLen		:= 0
Local nTamFKA	:= 0
Local nTamE5Cpos := 0 
Local dDtDispo := ""
Local l200trf	:= IsInCallStack("fa200Tarifa")
Local cFk5TpDoc	:= ""
Local nDelMaster := 0
Local nCntFK6	:= 0
Local lFKDID	:= oFK6:HasField( "FK6_IDFKD") // Proteção campo criado 12.1.25

If aCamposFK1==Nil
	aCamposFK1:= FK1->(DbStruct())
	aCamposFK3:= FK3->(DbStruct())
	aCamposFK4:= FK4->(DbStruct())
	aCamposFK5:= FK5->(DbStruct())
	aCamposFK6:= FK6->(DbStruct())
	aCamposFK9:= FK9->(DbStruct())
	aCamposFK8:= FK8->(DbStruct())
EndIF
If nCountSE5==Nil 
	nCountSE5 := SE5->(Fcount())
EndIf
If lCmpFK1==Nil
	lCmpFK1 := FK1->(FieldPos("FK1_DTDISP")) > 0 .and. FK1->(FieldPos("FK1_DTDIGI")) > 0
EndIf

If !Empty(oModel:GetValue('MASTER','E5_CAMPOS'))
	aValMaster := Separa(oModel:GetValue('MASTER','E5_CAMPOS'),'|')
	For nM:=1 To Len(aValMaster)
		If aValMaster[nM] <> Nil
			If Empty(Alltrim(aValMaster[nM]))
				ADel(aValMaster,nM)
				nM:=1
				nDelMaster++
			EndIf
		EndIf
	Next 
	nTamE5Cpos := Len(aValMaster) - nDelMaster 
EndIf

If nOper == MODEL_OPERATION_INSERT

	If oModel:GetValue( 'MASTER', 'NOVOPROC' )
		oModel:SetValue( 'MASTER', 'IDPROC', FINFKSID('FKA','FKA_IDPROC') )
	// Validação caso seja executado via Job/LOJA
	ElseIf Alltrim(oFK1:GetValue("FK1_ORIGEM")) = "RPC" .Or. Alltrim(oFK1:GetValue("FK1_ORIGEM")) = "LOJA701";
	.Or. Alltrim(oFK1:GetValue("FK1_ORIGEM")) = "LOJXREC"  
		oModel:SetValue( 'MASTER', 'IDPROC', FINFKSID('FKA','FKA_IDPROC') ) 
	Endif

	If oModel:GetValue("MASTER", "E5_GRV") 
		//Grava SE5 com os valores da SE1 - Baixas a Receber.
		For nX := 1 To oFKA:Length()
			
			//Posiciona na FKA do Model
			oFKA:GoLine(nX)
			oFKA:SetValue( 'FKA_IDFKA',  FWUUIDV4() )

			If !oFK1:IsEmpty()
			
				If !oFK6:IsEmpty()
					nPosFK1	:= nX 				
				Endif
				
				RecLock("SE5",.T.)
				E5_FILIAL	:= xFilial("SE5")
				E5_TABORI	:= "FK1"
				E5_IDORIG	:= oFKA:GetValue('FKA_IDORIG', nX)
				E5_MOVFKS	:= 'S'	// Campo de controle para migração dos dados.	
								
				/*
				 * Considerar os valores atribuídos no bloco de campos do SE5 para gravação de informações específicas.
				 */
				If nTamE5Cpos > nK
					nK++
									
					cVetAux := IIF(nTamE5Cpos < nK, aValMaster[nTamE5Cpos], aValMaster[nK])//Valor recibo do E5_CAMPOS.
					//aAux := aClone(&(cVetAux))
					//Substituida a macro da cVetAux devido a possibilidade de existirem caracteres especiais em campos texto (históricos, beneficiário)
					//Grava os campos complementares da SE5
					FGrvCpoSE5(cVetAux,aAux)
				
				Endif
				
				FinGrvSE5(aCamposFK1,aDeParaFK1,oFK1)
				SE5->(MsUnlock())
				
				/*
				 * Armazena os recnos gravados no commit do Modelo de Dados
				 */
				aAdd(aRecSE5,SE5->(Recno()))
				
				oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))
				
				If lCmpFK1
					oFK1:SetValue("FK1_DTDISP", SE5->E5_DTDISPO)
					oFK1:SetValue("FK1_DTDIGI", SE5->E5_DTDIGIT)
				EndIf

			Endif
	
			If !oFK5:IsEmpty()
			 	cFk5TpDoc	:= oModel:GetValue("FK5DETAIL", "FK5_TPDOC")
				If l200trf
					If SE5->(!EOF()) .And. (SE5->E5_TIPODOC == cFk5TpDoc)
						RecLock("SE5",.F.)
					Else 
						RecLock("SE5",.T.)
					EndIf
				Else
					RecLock("SE5",.F.)
				EndIf
				
				If cPaisLoc == "ARG" .Or. (oFK1:IsEmpty() .and. l200trf)
					E5_FILIAL	:= xFilial("SE5")
					E5_TABORI	:= "FK5"
					E5_IDORIG	:= oFKA:GetValue('FKA_IDORIG', nX)
					E5_MOVFKS	:= 'S'	// Campo de controle para migração dos dados.	
					
					If nTamE5Cpos > nK 
						nK++
											
						cVetAux := IIF(nTamE5Cpos > nK, aValMaster[nTamE5Cpos], aValMaster[nK])//Valor recibo do E5_CAMPOS.
						//aAux := aClone(&(cVetAux))
						//Substituida a macro da cVetAux devido a possibilidade de existirem caracteres especiais em campos texto (históricos, beneficiário)
						//Grava os campos complementares da SE5
						FGrvCpoSE5(cVetAux,aAux)
					Endif
				Endif
				FinGrvSE5(aCamposFK5,aDeParaFK5,oFK5)
				SE5->(MsUnlock())				
			Endif
		Next nX
	Endif

	//Posiciona na FKA do Model
	If nPosFK1 > 0
		oFKA:GoLine(nPosFK1)
	Endif

	//Gravo valores acessorios (Juros, Multa, Desconto etc)
	If !oFK6:IsEmpty()
		FinGrvFK6('FK1', aAux)
	EndIf

ElseIf nOper == MODEL_OPERATION_UPDATE 

	//Atualiza os campos na SE5.
	RecLock("SE5",.F.)
	For nX := 1 To Len(aCamposFK5)
		If oFK5:IsFieldUpdated(aCamposFK5[nX][1])  //Retorna se campo foi atualizado.
			If ( nPos := aScan(aDeParaFK5,{|x| AllTrim( x[1] ) ==  aCamposFK5[nX][1] } ) ) > 0  
				SE5->(FieldPut(FieldPos(aDeParaFK5[nPos,2]) , oFK5:GetValue(aCamposFK5[nX][1])))							
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

	nTamFKA := oFKA:Length()
	
	If nOperSE5 > 0

		//Grava SE5 com os valores da SE2 - Baixas a Pagar.
		For nY := 1 To nTamFKA
			
			//Posiciona na FKA do Model
			oFKA:GoLine(nY)

			oFK1 := oModel:GetModel('FK1DETAIL')
			//Movimento bancario
			oFK5 := oModel:GetModel('FK5DETAIL')

    		//Impostos Calculados
			oFK3 := oModel:GetModel('FK3DETAIL')			
    		//Impostos Retidos
			oFK4 := oModel:GetModel('FK4DETAIL')			
			//Valores Acessorios (Multa, Juros etc)
			oFK6 := oModel:GetModel('FK6DETAIL')

			If !oFK1:IsEmpty()
				aAuxFK1 := {}
				For nX := 1 To Len(aCamposFK1)	
					aAdd( aAuxFK1 , oFK1:GetValue(aCamposFK1[nX][1]) ) 
				Next nX

				//Estorno de valores acessorios (Juros, Multa etc)
				If !oFK6:IsEmpty()
					aOldFK6 := {}
					For nK := 1 To oFK6:Length()
						oFK6:GoLine(nK)					
						aAuxFK6 := {}						
						For nX := 1 To Len(aCamposFK6)	
							aAdd( aAuxFK6 , oFK6:GetValue(aCamposFK6[nX][1]) ) 
						Next nX
						aadd (aOldFK6, aAuxFK6)
	            	Next nK
				Endif

				cCart := oFK1:GetValue('FK1_RECPAG')
				
				//Estorno de valores impostos calculados
				If !oFK3:IsEmpty()
					aOldFK3 := {}
					For nK := 1 To oFK3:Length()
						oFK3:GoLine(nK)					
						aAuxFK3 := {}						
						For nX := 1 To Len(aCamposFK3)	
							aAdd( aAuxFK3 , oFK3:GetValue(aCamposFK3[nX][1]) ) 
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
						For nX := 1 To Len(aCamposFK4)	
							aAdd( aAuxFK4 , oFK4:GetValue(aCamposFK4[nX][1]) ) 
						Next nX
						aadd (aOldFK4, aAuxFK4)
	            	Next nK
				Endif
				//Estorno impostos
				If !oFK3:IsEmpty()
					FinEstFK34(aOldFK3, aOldFK4)
				Endif

				//Estorno na FK1
				nLen := oFKA:Length()
				If oFKA:AddLine() == nLen + 1
	              cIdFK1 := FWUUIDV4()
					oFKA:SetValue( 'FKA_IDFKA', FWUUIDV4() )
					oFKA:SetValue( 'FKA_IDORIG', cIdFk1)		
					oFKA:SetValue( 'FKA_TABORI', 'FK1')					
					
					For nX := 1 To Len(aCamposFK1)		
						oFK1:SetValue( aCamposFK1[nX][1], aAuxFK1[nX] )					
					Next nX								
					
					oFK1:SetValue('FK1_TPDOC', 'ES')
					oFK1:SetValue('FK1_HISTOR', cHistCan)
					oFK1:SetValue('FK1_RECPAG', If(cCart == "P","R","P"))
					oFK1:SetValue('FK1_DATA', dDataBase)
					oFK1:SetValue('FK1_LA', If(Upper(AllTrim(cLA)) $ 'S', 'S', 'N'))
					
					If lCmpFK1
						oFK1:SetValue("FK1_DTDISP", dDataBase)
						oFK1:SetValue("FK1_DTDIGI", dDataBase)
					EndIf

					//Estorno valores acessorios (Juros, Multa, Desconto etc)
					If Len(aOldFK6) > 0
						FinEstFK6( cCart, aOldFK6 )
					EndIf
					//Estorna o saldo do valor acessório na FKD
					For nCntFK6 := 1 to oFK6:Length()
						If oFK6:GetValue("FK6_TPDOC",nCntFK6) $ "VA"
							FAtuFKDBx(.T., "R", oFK6:GetValue("FK6_CODVAL",nCntFK6), oFK6:GetValue("FK6_VALMOV",nCntFK6), IIf(lFKDID, oFK6:GetValue("FK6_IDFKD",nCntFK6),"") )
						EndIf
					Next
					//Estorno impostos
					If Len(aOldFK3) > 0
						FGrvEstFks(aOldFK3, aOldFK4)
					Endif
				EndIf			
			Endif

			If !oFK5:IsEmpty()		
				aAuxFK5 := {}
				aAuxFK8 := {}
				aAuxFK9 := {}

				For nX := 1 To Len(aCamposFK5)	
					aAdd( aAuxFK5 , oFK5:GetValue(aCamposFK5[nX][1]) ) 
				Next nX
				
				For nX := 1 To Len(aCamposFK8)	
					aAdd( aAuxFK8 , oFK8:GetValue(aCamposFK8[nX][1]) ) 
				Next nX
				
				For nX := 1 To Len(aCamposFK9)	
					aAdd( aAuxFK9 , oFK9:GetValue(aCamposFK9[nX][1]) ) 
				Next nX

				cCart := oFK5:GetValue('FK5_RECPAG')

				//Estorno na FK5
				nLen := oFKA:Length()
				If oFKA:AddLine() == nLen + 1
					oFKA:SetValue( 'FKA_IDFKA', FWUUIDV4() )
					oFKA:SetValue( 'FKA_IDORIG', FWUUIDV4() )		
					oFKA:SetValue( 'FKA_TABORI', 'FK5')										
					
					For nX := 1 To Len(aCamposFK5)		
						oFK5:SetValue( aCamposFK5[nX][1], aAuxFK5[nX] )					
					Next nX
					
					oFK5:SetValue('FK5_TPDOC', 'ES')
					oFK5:SetValue('FK5_HISTOR', cHistCan)					
					oFK5:SetValue('FK5_RECPAG', If(cCart == "P","R","P"))
					oFK5:SetValue('FK5_DATA', dDataBase)
					oFK5:SetValue('FK5_DTCONC', CTOD("//"))
					oFK5:SetValue('FK5_LA', If(Upper(AllTrim(cLA)) $ 'S', 'S', 'N'))
					
					//Grava FK8 e inverte os valores de debito e crédito
					If Len(aCamposFK8) > 0	.and. !oFK8:IsEmpty()			
						For nX := 1 To Len(aCamposFK8)		
							oFK8:LoadValue( aCamposFK8[nX][1], aAuxFK8[nX] )					
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
 		    Endif
		Next nY

		//Atualiza a SE5 - Mov. Bancaria conforme a operação.
		Do Case
			Case nOperSE5 == 1 //Exclusão(Atualiza SITUACA = 'C') 
				RecLock("SE5",.F.)
				E5_SITUACA := 'C'
				SE5->(MsUnlock())
			Case nOperSE5 == 2 //	Estorno
				//Obtenho os dados do registro a ser estornado
				For nX := 1 to nCountSE5
					If AllTrim(SE5->(Field(nX))) == "E5_DTDISPO"
						If (SE5->E5_DTDISPO == SE5->E5_DATA .Or. dDatabase > SE5->E5_DTDISPO)						
							dDtDispo := dDatabase
						EndIf
					EndIf					
					
					AAdd(aSE5, If(Empty(dDtDispo), SE5->(FieldGet(nX)), dDtDispo))
					dDtDispo := ""
				Next
				// Grava o registro de estorno
				RecLock("SE5" ,.T.)
				For nX := 1 to nCountSE5
					SE5->( FieldPut( nX,aSE5[nX]))
				Next
				SE5->E5_FILIAL	:= xFilial("SE5")
				SE5->E5_TIPODOC	:= 'ES'
				SE5->E5_TABORI	:= "FK1"
				SE5->E5_IDORIG	:= cIdFK1
				SE5->E5_MOVFKS	:= 'S'	// Campo de controle para migração dos dados.
				SE5->E5_RECPAG	:= If(cCart == "P","R","P")
				SE5->E5_HISTOR	:= cHistCan
				SE5->E5_LA		:= cLa
				SE5->E5_DATA	:= dDatabase
				SE5->E5_DTDIGIT	:= dDatabase
				SE5->E5_RECONC	:= ''
				SE5->(MsUnlock())
				oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))
			Case nOperSE5 >= 3 //Exclui registro. 
				RecLock("SE5", .F.)
				SE5->(dbDelete())
				SE5->(MsUnlock())
				oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))
		End Case
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
RestArea(aArea)

Return lRet

/*/{Protheus.doc}FINM010Pre
Pre validacao do modelo e de outras entidades.
@param oModel - Modelo de dados
@author William Matos Gundim Junior
@since  04/04/2014
@version 12
/*/
Function FINM010Pre( oModel As Object ) As Logical

Local lRet		As Logical
Local cNatFks	As Character

lRet	:= .T.
cNatFks	:= ""

//Verifica se o título possui natureza
If SE1->(!Eof()) .And. Empty(SE1->E1_NATUREZ) 
	cNatFks := FINNATFKS()
	Reclock("SE1",.F.)
	SE1->E1_NATUREZ	:= cNatFks
	MsUnlock()
EndIf

Return lRet

/*/{Protheus.doc}FINM010Pos
Pos validacao do modelo e de outras entidades.
@param oModel - Modelo de dados
@author William Matos Gundim Junior
@since  04/04/2014
@version 12
/*/
Function FINM010Pos( oModel )

Local lRet := .T.

Return lRet

/*/{Protheus.doc} FIM010RSE5
Função que retornar os Recnos dos SE5 gravados no commit do Modelo de Dados.
@author Marylly Araújo Silva
@since  12/05/2014
@version 12
/*/
Function FIM010RSE5()
Return aRecSE5

/*/{Protheus.doc} FIM010CLRE5
Fun‡?o para limpar o array de Recnos gravados no commit do Modelo de Dados
@author Caio Quiqueto dos Santos
@since  17/01/2017
@version 12
/*/
Function FIM010CLRE5()
	aRecSE5 := {}
Return 
