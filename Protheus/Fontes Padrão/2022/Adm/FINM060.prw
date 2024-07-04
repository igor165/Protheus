#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

Static cFKAProc := ""
Static cAliasProc := ''

//-----------------------------------------------------------------
/*/{Protheus.doc}ModelDef
Criação do Modelo de dados - Adiantamento a Receber.
@author Mauricio Pequim Jr
@since  01/11/2017
@version 12
/*/
//-----------------------------------------------------------------
Static Function ModelDef()

Local oModel := MPFormModel():New('FINM060' ,/*PreValidacao*/,/*bPos*/, {|oModel| FINM060Grv(oModel)},/*bCancel*/ )
Local oCab	 := FWFormModelStruct():New()
Local oStruFKA := FWFormStruct(1,'FKA') //
Local oStruFK0 := FWFormStruct(1,'FK0') //
Local oStruFK3 := FWFormStruct(1,'FK3') //
Local oStruFK4 := FWFormStruct(1,'FK4') //
Local oStruFK7 := FWFormStruct(1,'FK7') //
Local aRelacFK0 := {}
Local aRelacFK3 := {}
Local aRelacFK4 := {}
Local aRelacFKA := {}
Local cProc	  := ""

//Criado master falso para a alimentação dos detail.
oCab:AddTable('MASTER',,'MASTER')

FIN060Master(oCab,oStruFKA)

//Chama a criação do cProc
cProc:= FINPrcFKA()

oCab:SetProperty( 'IDPROC', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "'" + cProc + "'" ) )

oStruFK7:SetProperty( 'FK7_IDDOC' , MODEL_FIELD_OBRIGAT, .F.)
oStruFKA:SetProperty( 'FKA_IDFKA' , MODEL_FIELD_OBRIGAT, .F.)
oStruFKA:SetProperty( 'FKA_IDPROC', MODEL_FIELD_OBRIGAT, .F.)
oStruFK3:SetProperty( "FK3_IDRET" , MODEL_FIELD_OBRIGAT, .F. )
oStruFK4:SetProperty( "FK4_IDORIG", MODEL_FIELD_OBRIGAT, .F. )
oStruFK0:SetProperty( 'FK0_IDORIG', MODEL_FIELD_OBRIGAT, .F.)

//Cria os modelos relacionados.
oModel:AddFields('MASTER', /*cOwner*/, oCab , , ,{|o|{}} )
oModel:AddGrid('FKADETAIL','MASTER'	  ,oStruFKA)
oModel:AddGrid('FK7DETAIL','FKADETAIL',oStruFK7)
oModel:AddGrid('FK3DETAIL','FKADETAIL',oStruFK3)
oModel:AddGrid('FK4DETAIL','FK3DETAIL',oStruFK4)
oModel:AddGrid('FK0DETAIL','FK4DETAIL',oStruFK0)

//Cria os modelos relacionados.
oModel:SetPrimaryKey( {} )

//Seta os modelos como opcionais - FK5, FK7 e FKA são obrigatorias.
oModel:GetModel( 'MASTER'):SetOnlyQuery(.T.)
oModel:GetModel( 'FK7DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK3DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK4DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK0DETAIL' ):SetOptional( .T. )

//Cria relacionamentos FKA->MASTER
aAdd(aRelacFKA,{'FKA_FILIAL','xFilial("FKA")'})
aAdd(aRelacFKA,{'FKA_IDPROC','IDPROC'}) 
oModel:SetRelation('FKADETAIL', aRelacFKA , FKA->(IndexKey(2)))

//Cria relacionamentos FK3->FKA.
aAdd(aRelacFK3,{'FK3_FILIAL','xFilial("FK3")'})
aAdd(aRelacFK3,{'FK3_IDORIG','FKA_IDORIG'})
oModel:SetRelation( 'FK3DETAIL', aRelacFK3 , FK3->(IndexKey(2)))

//Cria relacionamentos FK4->FK3.
aAdd(aRelacFK4,{'FK4_FILIAL','xFilial("FK4")'})
aAdd(aRelacFK4,{'FK4_IDORIG','FKA_IDORIG'    })
oModel:SetRelation( 'FK4DETAIL', aRelacFK4 , FK4->(IndexKey(1)))

//Cria relacionamentos FK0->FKA.
aAdd(aRelacFK0,{'FK0_FILIAL','xFilial("FK0")'})
aAdd(aRelacFK0,{'FK0_IDORIG','FKA_IDORIG'})
oModel:SetRelation( 'FK0DETAIL', aRelacFK0 , FK0->(IndexKey(1)))

Return oModel

//-----------------------------------------------------------------
/*/{Protheus.doc}FINM060Grv
Gravação do modelo e de outras entidades.
@param oModel - Modelo de dados
@author Mauricio Pequim Jr
@since  01/11/2017
@version 12
/*/
//-----------------------------------------------------------------
Function FINM060Grv(oModel)
Local oFK3 As Object
Local oFK4 As Object
Local oFK0 As Object	
Local oFKA As Object
Local nOper As Numeric
Local nOperAE As Numeric
Local lRet As Logical
Local nX As Numeric
Local nY As Numeric
Local nZ As Numeric
Local aCamposFK3 As Array
Local aCamposFK4 As Array
Local aAuxFK3 As Array
Local aAuxFK4 As Array
Local aOldFK3 As Array
Local aOldFK4 As Array
Local aIDsFK7 As Array
Local aArea As Array
Local cTitImp As Character
Local cIdTitPai As Character
Local cTabPai As Character
Local nTamFKA As Numeric
Local nTamFK0 As Numeric
Local nRetido As Numeric
Local aRetido As Array
Local aSE2 As Array
Local aSE1 As Array
Local aSE5 As Array
Local nLen As Numeric

//Inicializa variáveis.
oFKA := oModel:GetModel('FKADETAIL')
nOper := oModel:GetOperation()
lRet := .T.
nX := 0
nY := 0
nZ := 0
aAuxFK3 := {}
aAuxFK4 := {}
aOldFK3 := {}
aOldFK4 := {}
aIDsFK7 := {}
aArea := GetArea()
cTitImp := ""
cIdTitPai := ""
cTabPai := ""
nTamFKA := 0
nTamFK0 := 0
nRetido := 0
aRetido := {}
aSE2 := {}
aSE1 := {}
aSE5 := {}
nLen := 0

If nOper == MODEL_OPERATION_INSERT .and. oModel != NIL
	If oModel:GetValue( 'MASTER', 'NOVOPROC' )
		oModel:SetValue( 'MASTER', 'IDPROC', FINFKSID('FKA','FKA_IDPROC') )
	Endif
	
	For nX := 1 To oFKA:Length()
		//Posiciona na FK5 do Model
		oFKA:GoLine(nX)
		oFKA:SetValue( 'FKA_IDFKA', FWUUIDV4() )	
	Next nX
ElseIf nOper == MODEL_OPERATION_UPDATE
	oFK3 := oModel:GetModel('FK3DETAIL')
	oFK4 := oModel:GetModel('FK4DETAIL')
	oFK0 := oModel:GetModel('FK0DETAIL')
	aCamposFK3:= FK3->(DbStruct())
	aCamposFK4:= FK4->(DbStruct())
	nOperAE := oModel:GetValue('MASTER','OPERACAO')
	
	If nOperAE == 2 //Exclusão do titulo Pai
		//Posiciona a FKA com base no IDORIG da SE5 posicionada
		oFKA := oModel:GetModel( "FKADETAIL" )
		nTamFKA := oFKA:Length()
		cIdTitPai := oModel:GetValue('FKADETAIL','FKA_IDORIG')
		cTabPai := oModel:GetValue('FKADETAIL','FKA_TABORI')	//SE1 ou SE2
		
		If !Empty(cIdTitPai)
			aadd(aIDsFK7, cIdTitPai)
			
			//Grava SE5 com os valores da SE2 - Baixas a Pagar.
			For nX := 1 To nTamFKA
				//Posiciona na FKA do Model
				oFKA:GoLine(nX)
				
				//Impostos Calculados
				oFK3 := oModel:GetModel('FK3DETAIL')			
				//Impostos Retidos
				oFK4 := oModel:GetModel('FK4DETAIL')			
				//Valores Acessorios (Multa, Juros etc)
				oFK0 := oModel:GetModel('FK0DETAIL')
				
				//Estorno de valores impostos calculados
				If !oFK3:IsEmpty()
					aOldFK3 := {}
					For nY := 1 To oFK3:Length()
						oFK3:GoLine(nY)					
						aAuxFK3 := {}
						
						For nZ := 1 To Len(aCamposFK3)	
							aAdd( aAuxFK3 , oFK3:GetValue(aCamposFK3[nZ][1]) ) 
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
						
						For nZ := 1 To Len(aCamposFK4)	
							aAdd( aAuxFK4 , oFK4:GetValue(aCamposFK4[nZ][1]) ) 
						Next nZ
						
						aadd (aOldFK4, aAuxFK4)
					Next nY
				Endif
				
				//Estorno de valores impostos retidos
				If !oFK0:IsEmpty()
					nTamFK0 := oFK0:Length()
					
					For nY := 1 To nTamFK0
						oFK0:GoLine(nY)		
						Aadd(aIDsFK7, oFK0:GetValue("FK0_IDDOC") )			
						Aadd(aRetido, oFK0:GetValue("FK0_FILIAL") + oFK0:GetValue("FK0_IDDOC"))
						
						If !oFK0:IsDeleted()
							oFK0:DeleteLine()
						EndIf
 					Next nY
				Endif
				
				//Estorno impostos
				If !oFK3:IsEmpty()
					FinEstFK34(aOldFK3, aOldFK4)
				Endif
				
				//Estorno na FKA
				nLen := oFKA:Length()
				
				If oFKA:AddLine() == nLen + 1
					oFKA:SetValue( 'FKA_IDFKA' , FWUUIDV4() )
					oFKA:SetValue( 'FKA_IDORIG', cIdTitPai  )		
					oFKA:SetValue( 'FKA_TABORI', cTabPai    )  					
					//Estorno impostos
					If Len(aOldFK3) > 0
						FGrvEstFks(aOldFK3, aOldFK4)
					Endif
				Endif
			Next nX
		EndIf
	Else
		//exclusão de retenções na baixa (FK0 e SE1/SE2)
		If !oFK0:IsEmpty()  
			nTamFK0 := oFK0:Length()
			
			For nY := 1 To nTamFK0
				oFK0:GoLine(nY)		
				Aadd(aIDsFK7, oFK0:GetValue("FK0_IDDOC"))
				Aadd(aRetido, oFK0:GetValue("FK0_FILIAL") + oFK0:GetValue("FK0_IDDOC"))
				
				If !oFK0:IsDeleted()
					oFK0:DeleteLine()
				EndIf
			Next nY
		Endif		
	Endif
EndIf

lRet := FwFormCommit( oModel ) 

//Exclusão de retenções baixa e emissão.
nRetido := Len(aRetido)

If nRetido > 0
	aSE2 := SE2->(GetArea())
	aSE1 := SE1->(GetArea())
	
	SE1->(dbSetOrder(1))
	SE2->(dbSetOrder(1))
	FK7->(dbSetOrder(1))
	
	For nY := 1 To nRetido
		If FK7->(MsSeek(aRetido[nY])) .And. FK7->FK7_ALIAS $ "SE1|SE2"
			cTitImp := RTrim(StrTran(FK7->FK7_CHAVE, "|", ""))
			cTabPai := FK7->FK7_ALIAS
			
			If (cTabPai)->(MsSeek(cTitImp))
				RecLock(cTabPai)
				(cTabPai)->(dbDelete())
				(cTabPai)->(MsUnlock())
			EndIf
		EndIf
	Next nY
	
	RestArea(aSE2)
	RestArea(aSE1) 
EndIf

If lRet
	//Apago os registros de retenção (FK7)
	dbSelectArea("FK7")
	FK7->(dbSetOrder(1))	//FK7_FILIAL+FK7_IDDOC
	For nX := 1 to Len(aIDsFK7)
		If MsSeek(xFilial('FK7')+ aIDsFK7[nX] )
			RecLock("FK7")
			dbDelete()
			MsUnlock()
		Endif
	Next
Endif

RestArea(aArea)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc}FIN030Master
Função tem como objetivo criar os campos virtuais.
@param oModel - Modelo de dados
@author Mauricio Pequim Jr
@since  01/11/2017
@version 12
/*/ 
//-----------------------------------------------------------------
Function FIN060Master(oMaster)

Default oMaster := Nil

//Campo Id da Operação
oMaster:AddField("IDPROC"  ,"","IDPROC"  ,"C",20,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||""} ,/*Key*/,.F.,.T.,)
oMaster:AddField("NOVOPROC","","NOVOPROC","L", 1,0,/*bValid*/,/*When*/,{.T.,.F.}  ,.F.,{||.F.},/*Key*/,.F.,.T.,)
oMaster:AddField("OPERACAO","","OPERACAO","N", 1,0,/*bValid*/,/*When*/,{0,1,2,3}    ,.F.,{||0}  ,/*Key*/,.F.,.T.,)	//0 = Inclusão 1= Alteração 2= Exclusão

Return


//-----------------------------------------------------------------
/*/{Protheus.doc}FINPrcFKA
Retorna o processo da FKA para inclusão de titulos

@author Mauricio Pequim Jr
@since  13/11/2017
@version 12
/*/ 
//-----------------------------------------------------------------
Function FINPrcFKA()
Local cProc As Character

Default cAliasProc := ""

//Inicilaiza variável
cProc := ""

If !Empty(cAliasProc)
	cProc := FKA->FKA_IDPROC
EndIf

Return cProc


//-----------------------------------------------------------------
/*/{Protheus.doc}FINPrcFKA
Seto ou reseto o alias no qual estou operando (SE1 ou SE2)

@author Mauricio Pequim Jr
@since  13/11/2017
@version 12
/*/ 
//-----------------------------------------------------------------

Function FinSetAPrc( cAliasTit )

DEFAULT cAliasTit := ""

If !Empty(cAliasTit)
	cAliasProc := cAliasTit
Else
	cAliasProc := ""
Endif

Return

