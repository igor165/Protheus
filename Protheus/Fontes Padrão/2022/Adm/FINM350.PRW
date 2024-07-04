#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

STATIC cFKAProc		:= ""
STATIC cAliasProc	:= ''
STATIC aDeParaFK6	:= FINLisCpo('FK6')
STATIC aRecSE5		:= {}
STATIC nSaveSx8   	:= 0
STATIC nTamHist		:= TamSx3("FK2_HISTOR")[1]
STATIC nTamFil  	:= TamSx3("FK5_FILIAL")[1]
STATIC nTamTpDoc	:= TamSx3("FK2_TPDOC")[1]
STATIC nTamLA	 	:= TamSx3("FK2_LA")[1]
STATIC lCmpFK6		:= NIL

//-----------------------------------------------------------------
/*/{Protheus.doc}ModelDef
Criação do Modelo de dados - Apuração de variação monetária 

@author Mauricio Pequim Jr
@since  14/10/2020
@version 12
/*/
//-----------------------------------------------------------------
Static Function ModelDef()

	Local oModel AS Object
	Local oCab AS Object
	Local oStruFKA AS Object
	Local oStruFK6 AS Object
	Local aRelacFKA AS Array
	Local aRelacFK6 AS Array
	Local cProc AS Character

	oModel		:= MPFormModel():New('FINM350' ,/*{|oModel| FINM350Pre(oModel)}*/,{|oModel| FINM350Pos(oModel)}, {|oModel| FINM350Grv(oModel)},/*bCancel*/ )
	oCab		:= FWFormModelStruct():New()
	oStruFKA	:= FWFormStruct(1,'FKA') //
	oStruFK6	:= FWFormStruct(1,'FK6') //
	aRelacFKA	:= {}
	aRelacFK6	:= {}
	cProc		:= ""

	nSaveSx8 := GetSX8Len()

	//Criado master falso para a alimentação dos detail.
	oCab:AddTable('MASTER',,'MASTER')

	FIN350Master(oCab)

	//Salva os dados na SE5.
	oStruFK6:AddField("FK6_GRVSE5","","FK6_GRVSE5","L",1,0,/*bValid*/,/*When*/,{.T.,.F.},.F.,/* */,/*Key*/,.F.,.T.,)

	//Chama a criação do cProc
	cProc:= FINProcFKs(SE5->E5_IDORIG, SE5->E5_TABORI,,.T.)	

	oCab:SetProperty( 'IDPROC', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "'" + cProc + "'" ) )
	oStruFK6:SetProperty( "FK6_GRVSE5", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, '.T.' ) )

	oStruFKA:SetProperty( 'FKA_IDFKA' , MODEL_FIELD_OBRIGAT, .F.)
	oStruFKA:SetProperty( 'FKA_IDPROC', MODEL_FIELD_OBRIGAT, .F.)
	oStruFK6:SetProperty( 'FK6_IDFK6' , MODEL_FIELD_OBRIGAT, .F.)

	//Retira a validação dos campos abaixo.
	//Validação original: Positivo()
	//No entanto correção monetária pode ser negativa.
	oStruFK6:SetProperty("FK6_VALCAL" , MODEL_FIELD_VALID , {||.T.} )
	oStruFK6:SetProperty("FK6_VALMOV" , MODEL_FIELD_VALID , {||.T.} )

	//Cria os modelos relacionados.
	oModel:AddFields('MASTER', /*cOwner*/, oCab , , ,{|o|{}} )
	oModel:AddGrid('FKADETAIL','MASTER'	,oStruFKA) 
	oModel:AddGrid('FK6DETAIL','FKADETAIL',oStruFK6)

	//Preenchimento opcional. - FKA é obrigatória na função de gravação.
	oModel:GetModel( 'MASTER'):SetOnlyQuery(.T.)
	oModel:GetModel('FK6DETAIL'):SetOptional( .T. )

	oModel:SetPrimaryKey( {} )

	//Cria relacionamentos FKA->MASTER
	aAdd(aRelacFKA,{'FKA_FILIAL','xFilial("FKA")'})
	aAdd(aRelacFKA,{'FKA_IDPROC','IDPROC'}) 
	oModel:SetRelation('FKADETAIL', aRelacFKA , FKA->(IndexKey(2)))

	//Cria relacionamentos FK6->FKA. 
	aAdd(aRelacFK6,{'FK6_FILIAL','xFilial("FK6")'})
	aAdd(aRelacFK6,{'FK6_IDFK6','FKA_IDORIG'})
	oModel:SetRelation( 'FK6DETAIL', aRelacFK6 , FK6->(IndexKey(1)))

Return oModel

//----------------------------------------------------------------
/*/{Protheus.doc}FINM350Grv
Gravação do modelo e de outras entidades.
@param oModel - Modelo de dados
@author Mauricio Pequim Jr
@since  15/10/2020
@version 12
/*/
//----------------------------------------------------------------
Function FINM350Grv(oModel)

	Local oFK6 AS Object
	Local oFKA AS Object
	Local nOper AS Numeric
	Local nOperSE5 AS Numeric
	Local cHistCan AS Character
	Local cLA AS Character
	Local cCart AS Character
	Local cIdFK6 AS Character
	Local cIdFK7 AS Character
	Local cVetAux AS Character
	Local lRet AS Logical
	Local nX AS Numeric
	Local nY AS Numeric
	Local nK AS Numeric
	Local nPos AS Numeric
	Local nLen AS Numeric
	Local nTamFKA AS Numeric
	Local nCountSE5 AS Numeric
	Local aValMaster AS Array
	Local aAux AS Array
	Local aCamposFK6 AS Array
	Local aAuxFK6 AS Array
	Local aOldFK6 AS Array
	Local aSE5 AS Array

	oFK6		:= oModel:GetModel('FK6DETAIL')
	oFKA		:= oModel:GetModel('FKADETAIL')
	nOper 	    := oModel:GetOperation()
	nOperSE5	:= oModel:GetValue('MASTER','E5_OPERACAO')
	cHistCan    := oModel:GetValue('MASTER','HISTMOV')
	cLA		    := oModel:GetValue('MASTER','E5_LA')
	cCart		:= oModel:GetValue('MASTER','CARTEIRA')
	cIdFK6		:= ""
	cIdFK7		:= ""
	cVetAux		:= ""
	lRet		:= .T.
	nX			:= 0
	nY			:= 0
	nK			:= 0
	nLen		:= 0
	nPos		:= 0
	nTamFKA		:= 0
	nCountSE5	:= SE5->(Fcount())
	aValMaster	:= {}
	aAux		:= {}
	aAuxFK6		:= {}
	aOldFK6		:= {}
	aSE5		:= {}	 	
	aCamposFK6	:= FK6->(DbStruct())

	If !Empty(oModel:GetValue('MASTER','E5_CAMPOS'))
		aValMaster := Separa(oModel:GetValue('MASTER','E5_CAMPOS'),'|')
	EndIf

	If nOper == MODEL_OPERATION_INSERT

		If oModel:GetValue( 'MASTER', 'NOVOPROC' )
			oModel:SetValue( 'MASTER', 'IDPROC', FINFKSID('FKA','FKA_IDPROC') )
		Endif

		If oModel:GetValue("MASTER", "E5_GRV")
			//Gravo variação monetária (VM)
			For nX := 1 To oFKA:Length()
				
				//Posiciona na FKA do Model
				oFKA:GoLine(nX)
				oFKA:SetValue( 'FKA_IDFKA', FWUUIDV4() )
				
				//Gravo variação monetária (VM)
				If !oFK6:IsEmpty()
					cVetAux := aValMaster[nX]   //Valor recibo do E5_CAMPOS.
					RecLock("SE5",.T.)
					SE5->E5_FILIAL	:= xFilial("SE5")
					SE5->E5_TABORI	:= "FK6"
					SE5->E5_IDORIG	:= oFKA:GetValue('FKA_IDORIG', nX)
					SE5->E5_MOVFKS	:= 'S'	// Campo de controle para migração dos dados.	
					SE5->E5_DATA	:= dDatabase
					SE5->E5_DTDIGIT	:= dDatabase
					SE5->E5_DTDISPO	:= dDatabase
					SE5->E5_ORIGEM	:= "FINA350"
					SE5->E5_MOTBX	:= "VM"

					FGrvCpoSE5(cVetAux,aAux)
					SE5->(MsUnlock())

					F350GrFK6(aAux)

					FwFreeArray(aAux)
					aAux := {}

				EndIf

				oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))			
					
			Next nX
		Endif

	ElseIf nOper == MODEL_OPERATION_UPDATE 

		If lCmpFK6 == NIL
			lCmpFK6	:= FK6->(FieldPos("FK6_MOEDA"))	 > 0 .and. FK6->(FieldPos("FK6_TXMOED")) > 0
		Endif

		//Atualiza os campos na SE5.
		RecLock("SE5",.F.)
		For nX := 1 To Len(aCamposFK6)
			If oFK6:IsFieldUpdated(aCamposFK6[nX][1])  //Retorna se campo foi atualizado.
				If ( nPos := aScan(aDeParaFK6,{|x| AllTrim( x[1] ) ==  aCamposFK6[nX][1] } ) ) > 0  
					SE5->(FieldPut(FieldPos(aDeParaFK6[nPos,2]) , oFK6:GetValue(aCamposFK6[nX][1])))
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
				//Valores Acessorios (Multa, Juros etc)
				oFK6 := oModel:GetModel('FK6DETAIL')

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
				
				//Estorno na FK6
				nLen := oFKA:Length()
				If oFKA:AddLine() == nLen + 1

					cIdFK6 := FINFKSID('FK6','FK6_IDFK6')

					oFKA:SetValue( 'FKA_IDFKA', FWUUIDV4() )
					oFKA:SetValue( 'FKA_IDORIG', cIdFk6)		
					oFKA:SetValue( 'FKA_TABORI', "FK6")					

					//Estorno valores acessorios (Juros, Multa, Desconto etc)
					If Len(aOldFK6) > 0

						For nX := 1 To Len(aOldFK6)

							aAuxFK6 := aClone(aOldFK6[nX])

							//Estorno de valores acessorios (cancelamento de baixa)
							If !oFK6:IsEmpty()
								oFK6:AddLine()
								oFK6:GoLine( oFK6:Length() )
							Endif

							For nK := 1 To Len(aCamposFK6)
								oFK6:LoadValue(aCamposFK6[nK][1],aAuxFK6[nK])
							Next nK

							cCart	:= oFK6:GetValue("FK6_RECPAG")
							cIdFK7	:= oFK6:GetValue("FK6_IDORIG")

							oFK6:SetValue("FK6_IDFK6"  ,cIdFk6 )
							oFK6:SetValue("FK6_RECPAG" ,If (cCart == "P", "R", "P") )
							oFK6:SetValue("FK6_HISTOR" ,cHistCan )
							If lCmpFK6
								oFK6:SetValue("FK6_ORIGEM" ,FunName() )
							Endif

						Next nX

					EndIf		

				EndIf			

			Next nY

			//Atualiza a SE5 - Mov. Bancaria conforme a operação.
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
					SE5->E5_TABORI	:= 'FK6'
					SE5->E5_IDORIG	:= cIdFK7
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

	FwFreeArray(aValMaster)
	FwFreeArray(aOldFK6)
	FwFreeArray(aAuxFK6)
	FwFreeArray(aCamposFK6)

Return lRet

//-----------------------------------------------------------------------------------
/*/{Protheus.doc}FINM350Grv
Pos validacao do modelo e de outras entidades.
@param oModel - Modelo de dados
@author Mauricio Pequim Jr
@since  15/10/2020
@version 12
/*/
//-----------------------------------------------------------------------------------
Function FINM350Pos( oModel )

	Local lRet := .T.

Return lRet


//-----------------------------------------------------------------------------------
/*/{Protheus.doc} F350GrFK6
Faz a gravação dos valores na SE5 com base na FK6.
@author Mauricio Pequim Jr
@since  15/10/2020
@version 12
/*/
//-----------------------------------------------------------------------------------
Static Function F350GrFK6(aAux )
	Local oModel AS Object
	Local oFK6 AS Object
	Local aCamposFK6 AS Array
	Local nY AS Numeric
	Local aPosField AS Array

	Default aAux		:= {}

	oModel		:= FWModelActive()
	oFK6		:= oModel:GetModel('FK6DETAIL')
	aCamposFK6 	:= FK6->(DbStruct())
	nY  		:= 0
	aPosField	:= {}

	If !oFK6:IsEmpty() .And. ( oFK6:GetValue('FK6_VALMOV') != 0 .or. oFK6:GetValue('FK6_VALCAL') != 0 )

		If oFK6:GetValue('FK6_GRVSE5') .and. oFK6:GetValue('FK6_VALMOV') != 0  //Indica se grava SE5 para os valores acessorios

			RecLock("SE5")

			//Grava os dados na SE5 com base na FK6.
			FinGrvSE5(aCamposFK6,aDeParaFK6,oFK6)

			If cPaisLoc == "BRA"
				E5_TPDESC := If((Empty(oFK6:getvalue("FK6_TPDESC")) .Or. oFK6:getvalue("FK6_TPDESC") == "2"), "I", "C")
			Endif

			//Ajusto somente os campos chave da SE5 atraves do cCamposE5
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_TIPO'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_PREFIXO'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_NUMERO'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_PARCELA'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_CLIFOR'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_LOJA'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_BENEF'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_DTDIGIT'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_DTDISPO'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_CLIENTE'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_DTDISPO'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_BANCO'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_AGENCIA'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_CONTA'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_FORNECE'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_LA'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_MOTBX'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_FATURA'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_FATPREF'}))
			aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_DOCUMEN'}))

			For nY := 1 to Len(aPosField)
				If aPosField[nY] > 0
					SE5->(FieldPut(FieldPos(aAux[aPosField[nY]][1]),aAux[aPosField[nY]][2]))
				EndIf
			Next nY
	
			SE5->(MsUnlock())

		Endif
	EndIf
	aCamposFK6 := NIL

Return

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FIN350Master
Função tem como objetivo criar os campos virtuais.
@param oModel - Modelo de dados
@author Mauricio Pequim Jr
@since  20/10/2020
@version 12
/*/
//-----------------------------------------------------------------------------------
Function FIN350Master(oMaster)

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
//Indicador de contabilização
oMaster:AddField("CARTEIRA","","CARTEIRA","C",1,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||""},/*Key*/,.F.,.T.,)

Return


