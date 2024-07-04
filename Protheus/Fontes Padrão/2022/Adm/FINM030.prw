#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

STATIC aDeParaFK8 	:= FINLisCpo('FK8')
STATIC aDeParaFK9 	:= FINLisCpo('FK9')
STATIC aDeParaFK5 	:= FINLisCpo('FK5')
STATIC nSaveSx8   	:= 0
STATIC nTamHist		:= TamSx3("FK2_HISTOR")[1]
STATIC nTamFil  	:= TamSx3("FK5_FILIAL")[1]
STATIC nTamTpDoc	:= TamSx3("E5_TIPODOC")[1]
STATIC nTamLA	 	:= TamSx3("E5_LA")[1]

Function FINM030()
Local lRet := .T.

Return lRet

/*/{Protheus.doc}ModelDef
Criação do Modelo de dados - Mov. Bancaria Manual.
@author William Matos Gundim Junior
@since  14/03/2014
@version 12
/*/
Static Function ModelDef()
Local oModel 	 := MPFormModel():New('FINM030' ,/*PreValidacao*/,{|oModel| FINM030Pos(oModel)}, {|oModel| FINM030Grv(oModel)},/*bCancel*/ )
Local oMaster	 := FWFormModelStruct():New()
Local oStruFKA := FWFormStruct(1,'FKA') //Rastreio de Movimento.
Local oStruFK3 := FWFormStruct(1,'FK3') //Impostos Calc.
Local oStruFK4 := FWFormStruct(1,'FK4') //Impostos Ret.
Local oStruFK5 := FWFormStruct(1,'FK5') //Movimentos Bancários.
Local oStruFK6 := FWFormStruct(1,'FK6') //Movimentos Bancários.
Local oStruFK8 := FWFormStruct(1,'FK8') //Dados Contábeis. 
Local oStruFK9 := FWFormStruct(1,'FK9') //Tabela auxiliar de integração.
Local aRelacFK8:= {}
Local aRelacFK9:= {}
Local aRelacFK3:= {}
Local aRelacFK4:= {}
Local aRelacFK5:= {}
Local aRelacFK6:= {}
Local aRelacFKA:= {}
Local cProcFKs := ""
Local lFina100 := IsInCallStack("FINA100")
Local cTabOri := ""
Local nIndFK4	:= Iif(FWSIXUtil():ExistIndex('FK4' , '2'), 2,1)

//Migra o registro de SE5 posicionado que ainda não foi migrado
If SE5->E5_MOVFKS <> 'S' .AND. SE5->( !EOF() ) .and. (!lFina100 .OR. (lFina100 .AND. !INCLUI))
	If !lFina100 .And. Alltrim(SE5->E5_TIPODOC) $ "CH" .And. !Empty(SE5->E5_NUMCHEQ) //Cheques
		FINXSE5(SE5->(Recno()), 4)
	Else
		FINXSE5(SE5->(Recno()), 1)
	Endif
Endif

nSaveSx8 := GetSX8Len()	                        

//Criado master, será utilizado como passagem de parametros pelo modelo.
oMaster:AddTable( 'FK5',,'MASTER' )

//Campos virtuais.
FIN030Master( oMaster )

//Salva os dados na SE5.
oStruFK6:AddField("FK6_GRVSE5","","FK6_GRVSE5","L",1,0,/*bValid*/,/*When*/,{.T.,.F.},.F.,/* */,/*Key*/,.F.,.T.,)


//Pega o número do processo com base na SE5 posicionada ou gera um novo número de processo 
If !Empty(SE5->E5_IDORIG)
	cTabOri := SE5->E5_TABORI

	If ( (lFina100 .Or. Empty(SE5->E5_TABORI))    .or. (cPaisLoc =="ARG" .and. FWIsInCallStack("F472ConFKS")) )
		cTabOri := "FK5"
	Endif
	
	cProcFKs := FINProcFKs( SE5->E5_IDORIG, cTabOri, SE5->E5_SEQ, lFina100)
Endif

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
oStruFK6:SetProperty( 'FK6_IDFK6' , MODEL_FIELD_OBRIGAT, .F.)

//Cria os modelos relacionados.
oModel:AddFields('MASTER', /*cOwner*/, oMaster , , ,{|o|{}} )
oModel:AddGrid('FKADETAIL','MASTER'    ,oStruFKA)
oModel:AddGrid('FK5DETAIL','FKADETAIL',oStruFK5)
oModel:AddGrid('FK8DETAIL','FK5DETAIL',oStruFK8)
oModel:AddGrid('FK9DETAIL','FK5DETAIL',oStruFK9)
oModel:AddGrid('FK3DETAIL','FK5DETAIL',oStruFK3)
oModel:AddGrid('FK4DETAIL','FK3DETAIL',oStruFK4)
oModel:AddGrid('FK6DETAIL','FK5DETAIL',oStruFK6)

oModel:SetPrimaryKey( {} )

//Seta os modelos como opcionais - FK5 e FKA são obrigatorias.
oModel:GetModel( 'MASTER' ):SetOnlyQuery(.T.)
oModel:GetModel( 'FK3DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK4DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK5DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK8DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FKADETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK9DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK6DETAIL' ):SetOptional( .T. )

//Cria relacionamentos FK8->FK5.
aAdd(aRelacFK8,{'FK8_FILIAL','xFilial("FK8")'})
aAdd(aRelacFK8,{'FK8_IDMOV','FKA_IDORIG'})
oModel:SetRelation( 'FK8DETAIL', aRelacFK8 , FK8->(IndexKey(1)))

//Cria relacionamentos FK9->FK5.
aAdd(aRelacFK9,{'FK9_FILIAL','xFilial("FK4")'})
aAdd(aRelacFK9,{'FK9_IDMOV','FKA_IDORIG'})
oModel:SetRelation('FK9DETAIL', aRelacFK9 , FK9->(IndexKey(1)))

//Cria relacionamentos FK3->FK2.
aAdd(aRelacFK3,{'FK3_FILIAL','xFilial("FK3")'})
aAdd(aRelacFK3,{'FK3_TABORI',"'FK5'"})
aAdd(aRelacFK3,{'FK3_IDORIG','FKA_IDORIG'})
oModel:SetRelation( 'FK3DETAIL', aRelacFK3 , FK3->(IndexKey(2)))

//Cria relacionamentos FK4->FK3.
aAdd(aRelacFK4,{'FK4_FILIAL','xFilial("FK4")'})
aAdd(aRelacFK4,{'FK4_IDORIG','FKA_IDORIG'    })
oModel:SetRelation( 'FK4DETAIL', aRelacFK4 , FK4->(IndexKey(nIndFK4)))

//Cria relacionamento FKA -> MASTER
aAdd(aRelacFKA,{'FKA_FILIAL','xFilial("FKA")' })
aAdd(aRelacFKA,{'FKA_IDPROC','IDPROC'}) 
oModel:SetRelation('FKADETAIL', aRelacFKA , FKA->(IndexKey(2)))

//Cria relacionamento FK5 -> FKA
aAdd(aRelacFK5,{'FK5_FILIAL','xFilial("FK5")' })
aAdd(aRelacFK5,{'FK5_IDMOV','FKA_IDORIG'})
oModel:SetRelation('FK5DETAIL', aRelacFK5 , FK5->(IndexKey(1)))

//Cria relacionamentos FK6->FKA. 
aAdd(aRelacFK6,{'FK6_FILIAL','xFilial("FK6")'})
aAdd(aRelacFK6,{'FK6_IDORIG','FKA_IDORIG'})
oModel:SetRelation( 'FK6DETAIL', aRelacFK6 , FK6->(IndexKey(1)))

Return oModel

/*/{Protheus.doc}FINM030Pos
Validação do modelo de dados.
@param Modelo de dados
@author William Matos Gundim Junior
@since  14/03/2014
@version 12
/*/
Function FINM030Pos(oModel)
Local lRet := .F.
Local oSubFKA := oModel:GetModel( 'FKADETAIL' )
Local oSubFK5 := oModel:GetModel( 'FK5DETAIL' )
Local nOper := oModel:GetOperation()

If nOper <> MODEL_OPERATION_INSERT
	If oSubFKA:SeekLine( { {"FKA_FILIAL", SE5->E5_FILIAL },{"FKA_IDORIG", SE5->E5_IDORIG },{"FKA_TABORI", "FK5" } } ) .and. !oSubFK5:IsEmpty()
		lRet := .T.
	Endif
Else
	lRet := .T.	
EndIf
Return lRet


/*/{Protheus.doc}FINM030Grv
Gravação do modelo e de outras entidades.
@param oModel - Modelo de dados
@author William Matos Gundim Junior
@since  04/04/2014
@version 12
/*/
Function FINM030Grv(oModel)
Local oFK5	:= oModel:GetModel('FK5DETAIL')
Local oFKA	:= oModel:GetModel('FKADETAIL')
Local oFK3	:= oModel:GetModel('FK3DETAIL')
Local oFK4	:= oModel:GetModel('FK4DETAIL')
Local oFK6	:= oModel:GetModel('FK6DETAIL')
Local oFK8  := oModel:GetModel('FK8DETAIL')
Local oFK9	:= oModel:GetModel('FK9DETAIL')
Local nOperSE5 := oModel:GetValue('MASTER','E5_OPERACAO')
Local nOper := oModel:GetOperation()
Local aCamposFK3 := FK3->(DbStruct())
Local aCamposFK4 := FK4->(DbStruct())
Local aCamposFK5 := FK5->(DbStruct())
Local aCamposFK8 := FK8->(DbStruct())
Local aCamposFK9 := FK9->(DbStruct())
Local aCamposFK6 := FK6->(DbStruct())
Local lRet	:= .T.
Local nX := 0
Local nY := 0
Local nK := 0
Local aValMaster := {} //Array para receber valores do E5_CAMPOS da MASTER.
Local aAux	:= {}
Local cVetAux := ""
Local nLen := 0
Local aAuxFK3 := {}
Local aAuxFK4 := {}
Local aAuxFK5 := {}
Local aAuxFK8 := {}
Local aAuxFK9 := {}
Local aAuxFK6 := {}
Local aOldFK3 := {}
Local aOldFK4 := {}
Local aOldFK6 := {}
Local cAux := "" 
Local aSE5 := {}	 	
Local nCountSE5 := SE5->(Fcount())
Local cCart := oFK5:GetValue('FK5_RECPAG')
Local cTpDocEst := oModel:GetValue('MASTER','E5_TIPODOC')   
Local cFKAProc := ""
Local cHistCan  := oModel:GetValue('MASTER','HISTMOV')
Local nIndGrvSE5 := 0
Local nValEst := oModel:GetValue( "MASTER", "VALEST" )
Local lFina100	:= IsInCallStack("FINA100")
Local cTipo := ""

If !Empty(oModel:GetValue('MASTER','E5_CAMPOS'))
	aValMaster := Separa(oModel:GetValue('MASTER','E5_CAMPOS'),'|')
	nIndGrvSE5 := Len(aValMaster)
EndIf

If nOper == MODEL_OPERATION_INSERT

	If oModel:GetValue( 'MASTER', 'NOVOPROC' )
		oModel:SetValue( 'MASTER', 'IDPROC', FINFKSID('FKA','FKA_IDPROC') )
	Endif

	For nX := 1 To oFKA:Length()
		oFKA:GoLine(nX)
		oFKA:SetValue( 'FKA_IDFKA', FWUUIDV4() )
		
		If oModel:GetValue("MASTER", "E5_GRV")
			
			//Grava SE5 - Movimento Bancario.				
			If !oFK5:IsEmpty()
				RecLock("SE5",.T.)			
				FinGrvSE5(aCamposFK5,aDeParaFK5,oFK5)
							
				E5_FILIAL  := xFilial("SE5")
				E5_TABORI  := "FK5"
				E5_MOVCX   := Iif( Alltrim(oFK5:GetValue('FK5_ORIGEM')) $ "FINA550|FINA560", "S", "" )
				E5_MOVFKS	:= 'S'	// Campo de controle para migração dos dados.
				E5_RATEIO	:= If(oFK5:GetValue('FK5_RATEIO') == '1', 'S', 'N')
				E5_TIPODOC := Iif( Alltrim(oFK5:GetValue('FK5_TPDOC')) == "DH", "", oFK5:GetValue('FK5_TPDOC') )
				E5_IDORIG	:= oFKA:GetValue('FKA_IDORIG', nX)
				
				If oFK5:IsFieldUpdated('FK5_TPMOV')
					E5_TIPOMOV := If(AllTrim(oFK5:GetValue('FK5_TPMOV')) == '1', '01', '02')					
				EndIf
				
				//Para cada FK5, há um grupo de E5_CAMPOS diferente 
				nK ++
				cVetAux := aValMaster[nK]   //Valor recibo do E5_CAMPOS.
				//aAux := aClone(&(cVetAux))
				//Substituida a macro da cVetAux devido a possibilidade de existirem caracteres especiais em campos texto (históricos, beneficiário)
				//Grava os campos complementares da SE5
				FGrvCpoSE5(cVetAux,aAux)

				SE5->(MsUnlock())				

				oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))				
			
				If !oFK8:IsEmpty() 
					RecLock("SE5",.F.)							
					FinGrvSE5(aCamposFK8,aDeParaFK8,oFK8)
					If oFK8:IsFieldUpdated('FK8_TPLAN')
						E5_TIPOLAN := Iif( AllTrim(oFK8:GetValue('FK8_TPLAN', nX)) == '1', 'D', Iif( AllTrim(oFK8:GetValue('FK8_TPLAN', nX)) == '2', 'C', 'X') )
					EndIf	
					SE5->(MsUnlock())												
				EndIf
						   
		   		If !oFK9:IsEmpty() 
					RecLock("SE5",.F.)				     		
		     		FinGrvSE5(aCamposFK9,aDeParaFK9,oFK9)
					SE5->(MsUnlock())
				EndIf		
						    		 			
				//Gravo valores acessorios (Juros, Multa, Desconto etc)
				If !oFK6:IsEmpty()
					FinGrvFK6('FK5', aAux)
				EndIf

			Endif
		Else			
			If !oFK5:IsEmpty()			
				RecLock("SE5", .F.)
							
				If lFina100	// Para o FINA100, O SE5 já está gravado (commit do modelo da tela axinclui), atualizar com os dados da FK5
					FinGrvSE5(aCamposFK5,aDeParaFK5,oFK5)
				EndIf

				If Len(aValMaster) > 0
					nK ++
					cVetAux := aValMaster[nK]   //Valor recibo do E5_CAMPOS.
					//aAux := aClone(&(cVetAux))
					//Substituida a macro da cVetAux devido a possibilidade de existirem caracteres especiais em campos texto (históricos, beneficiário)
					//Grava os campos complementares da SE5
					FGrvCpoSE5(cVetAux,aAux)
				EndIf		

				SE5->(MsUnlock())
			Endif
		EndIf
						
	Next nX

ElseIf nOper == MODEL_OPERATION_UPDATE 
	//Posiciona a FKA com base no IDORIG da SE5 posicionada
	oFKA := oModel:GetModel( "FKADETAIL" )
	oFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )

	cFKAProc := oFKA:GetValue('FKA_IDPROC')
	oFK3	:= oModel:GetModel('FK3DETAIL')	
	
	//Valores Acessorios (Multa, Juros etc)
	oFK6 := oModel:GetModel('FK6DETAIL')

	cTipo := SE5->E5_TIPO
	
	//Atualiza os campos na SE5.
	RecLock("SE5",.F.)
	FinGrvSE5(aCamposFK5,aDeParaFK5,oFK5)
	
	//Valores passados pelo E5_CAMPOS.
	If Len(aValMaster) > 0
	
		cVetAux := aValMaster[1]   //Valor recibo do E5_CAMPOS.
		//aAux := aClone(&(cVetAux))
		//Substituida a macro da cVetAux devido a possibilidade de existirem caracteres especiais em campos texto (históricos, beneficiário)
		//Grava os campos complementares da SE5
		FGrvCpoSE5(cVetAux,aAux)
	
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
		
		If cTipo $ MVPAGANT + "|" + MVRECANT
			//Estorno de valores impostos calculados
			If !oFK3:IsEmpty()
				aOldFK3 := {}
				For nY := 1 To oFK3:Length()
					oFK3:GoLine(nY)					
					aAuxFK3 := {}
					
					For nX := 1 To Len(aCamposFK3)	
						aAdd( aAuxFK3 , oFK3:GetValue(aCamposFK3[nX][1]) ) 
					Next nX
					
					aadd (aOldFK3, aAuxFK3)
				Next nY
			Endif
				
			//Estorno de valores impostos retidos
			If !oFK4:IsEmpty()
				aOldFK4 := {}
				For nY := 1 To oFK4:Length()
					oFK4:GoLine(nY)					
					aAuxFK4 := {}						
					
					For nX := 1 To Len(aCamposFK4)	
						aAdd( aAuxFK4 , oFK4:GetValue(aCamposFK4[nX][1]) ) 
					Next nX
					
					aadd (aOldFK4, aAuxFK4)
				Next nY
			Endif
			
		EndIf
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

		//Estorno impostos
		If !oFK3:IsEmpty()
			FinEstFK34()
		Endif
	
		nLen := oFKA:Length()
		If oFKA:AddLine() == nLen + 1
			oFKA:SetValue( 'FKA_IDFKA', FWUUIDV4() )
			oFKA:SetValue( 'FKA_IDORIG', FWUUIDV4() )		
			oFKA:SetValue( 'FKA_TABORI', "FK5" )
			
			For nX := 1 To Len(aCamposFK5)		
				oFK5:SetValue( aCamposFK5[nX][1], aAuxFK5[nX] )					
			Next nX								
			oFK5:SetValue('FK5_TPDOC', 'ES')
			oFK5:SetValue('FK5_HISTOR', cHistCan)
			oFK5:SetValue('FK5_RECPAG', If(cCart == "P","R","P"))
			oFK5:SetValue('FK5_DATA', dDataBase)
			oFK5:SetValue('FK5_DTDISP', dDataBase)
			
			//Juros, Multa e Descontos
			If Len(aOldFK6) > 0
				FinEstFK6( cCart, aOldFK6 )
			EndIf	

			//Estorno impostos
			If Len(aOldFK3) > 0
				FGrvEstFks(aOldFK3, aOldFK4)
			Endif
				
			//Grava FK8 e inverte os valores de debito e crédito
			If Len(aCamposFK8) > 0 .and. !oFK8:IsEmpty()			
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
				oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))
				
			Case nOperSE5 == 2 //	Estorno
			
				If !oFK5:IsEmpty()

					cTpDocEst := If(Empty(cTpDocEst), "ES",cTpDocEst)

					//Obtenho os dados do registro a ser estornado
					For nX := 1 to nCountSE5
						AAdd( aSE5, SE5->( FieldGet(nX) ) )
					Next
					// Grava o registro de estorno
					RecLock("SE5" ,.T.)
					For nX := 1 to nCountSE5
						SE5->( FieldPut( nX,aSE5[nX]))
					Next
					SE5->E5_FILIAL	:= xFilial("SE5")
					SE5->E5_TIPODOC	:= cTpDocEst
					SE5->E5_TABORI  := "FK5"
					SE5->E5_IDORIG	:= oFKA:GetValue('FKA_IDORIG')
					SE5->E5_MOVCX   := Iif( Alltrim(oFK5:GetValue('FK5_ORIGEM')) $ "FINA550|FINA560", "S", "" )
					SE5->E5_MOVFKS	:= 'S'	// Campo de controle para migração dos dados.
					SE5->E5_RECPAG	:= If(cCart == "P","R","P")
					SE5->E5_HISTOR	:= cHistCan
 					SE5->E5_DATA	:= dDatabase
 					SE5->E5_DTDISPO	:= dDatabase
 					
 					//Tratamento para se caso seja informado um valor de estorno diferente do valor original 
 					If nValEst > 0
 						SE5->E5_VALOR := nValEst
 						SE5->E5_VLMOED2 := nValEst
 						oFK5:SetValue( "FK5_VALOR", nValEst )
 						oFK5:SetValue( "FK5_VLMOE2", nValEst )
 					Endif
 					
					SE5->(MsUnlock())
					oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))

				EndIf	
			
			Case nOperSE5 == 3 //Exclui registro. 
			
				RecLock("SE5", .F.)
				SE5->(dbDelete())
				SE5->(MsUnlock())
				oModel:SetValue("MASTER","E5_RECNO",0)		
		End Case
			
	EndIf	

	//Posiciona a FKA com base no IDORIG da SE5 posicionada
	oFKA := oModel:GetModel( "FKADETAIL" )
	//Manda para o topo do oFKA 
	//Necessario pois a linha do estorno nao foi comitada e 
	//os campos de relacionamento (FKA_FILIAL e FKA_IDPROC) estao vazios, falhando o valid na troca de linha
	//O Goline força a mudanca de linha independente do valid
	oFKA:GoLine(1)	
	If oFKA:SeekLine( { {"FKA_TABORI", "SEF" } } )
		If oFKA:GetValue('FKA_IDPROC') == cFKAProc
			oFKA:DeleteLine()
		Endif
	Endif
	
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

/*/{Protheus.doc}FIN030Master
Função tem como objetivo criar os campos virtuais.
@param oModel - Modelo de dados
@author William Matos Gundim Junior
@since  04/04/2014
@version 12
/*/ 
Function FIN030Master(oMaster)

Default oMaster := Nil
//Salva os dados na SE5.
oMaster:AddField("E5_GRV","","E5_GRV","L",1,0,/*bValid*/,/*When*/,{.T.,.F.},.F.,/* */,/*Key*/,.F.,.T.,)
// nOper = 1 - Exclusão(Atualiza SITUACA = 'C' | 2 - Estorno | 3 - Apaga Registro.
oMaster:AddField("E5_OPERACAO","","E5_OPERACAO","N",1,0,/*bValid*/,/*When*/,{0,1,2,3},.F.,{||0},/*Key*/,.F.,.T.,)
//Campo Memo para array de campos que existem apenas na SE5.
oMaster:AddField("E5_CAMPOS","","E5_CAMPOS","M",10,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||""},/*Key*/,.F.,.T.,)
//Campo para controle do RECNO da SE5.
oMaster:AddField("E5_RECNO","","E5_RECNO","N",16,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||0},/*Key*/,.F.,.T.,)
//Campo Id da Operação
oMaster:AddField("IDPROC","","IDPROC","C",20,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||""},/*Key*/,.F.,.T.,)
//Campo para informar se deve ser gerado um novo número de processo
oMaster:AddField("NOVOPROC","","NOVOPROC","L",1,0,/*bValid*/,/*When*/,{.T.,.F.},.F.,{||.F.},/*Key*/,.F.,.T.,)
//Campo Id da Operação
oMaster:AddField("HISTMOV","","HISTMOV","C",nTamHist,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||""},/*Key*/,.F.,.T.,)
//Campo Id da Operação
oMaster:AddField("E5_TIPODOC","","E5_TIPODOC","C",nTamTpDoc,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||""},/*Key*/,.F.,.T.,)
//Indicador de contabilização
oMaster:AddField("E5_LA","","E5_LA","C",nTamLA,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||""},/*Key*/,.F.,.T.,)
//Campo para informar um valor de estorno diferente do registro original (a princípio, usado para cancelamento de borderô no qual houve algum título já transferido para carteira antes do cancelamento do borderô)
oMaster:AddField("VALEST","","VALEST","N",16,2,/*bValid*/,/*When*/,/*aValues*/,.F.,{||0},/*Key*/,.F.,.T.,)
//Campo para informar um valor de estorno de IOF diferente do registro original (a princípio, usado para cancelamento de borderô descontado no qual houve algum título já transferido para carteira antes do cancelamento do borderô)
oMaster:AddField("VALESTIOF","","VALESTIOF","N",16,2,/*bValid*/,/*When*/,/*aValues*/,.F.,{||0},/*Key*/,.F.,.T.,)
Return

