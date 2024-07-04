#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA116.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA116
Rotina que irá fazer importação do invetario para compor bloco H
@author Rafael S Oliveira
@since 26/02/2016
@version 11.90

/*/
//-------------------------------------------------------------------
Function FISA116()
Local oBrw		:= FWmBrowse():New()
Local cDescric	:= STR0016

IF aliasindic("F0M")
	PRIVATE cAlias	:= "F0M"

	oBrw:SetDescription(cDescric)
	oBrw:SetAlias( cAlias)
	oBrw:SetMenuDef( 'FISA116' )	
	oBrw:Activate()  
Else
	Alert('Dicionário desatualizado, favor verificar atualizações do Dicionário de dados')
EndIF

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Rafael S Oliveira
@since 26/02/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   

Local aRotina	:= {}

	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA116' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA116' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA116' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.FISA116' OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina TITLE STR0009 ACTION 'PERG116'	   OPERATION 3 ACCESS 0 // Importar DBF
	ADD OPTION aRotina TITLE STR0010 ACTION 'FISR116'	   OPERATION 3 ACCESS 0 // Listagem
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rafael S Oliveira
@since 26/02/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruGener := Nil
Local oModel

Default cAlias := "F0M"

oStruGener := FWFormStruct( 1,cAlias)

//F0M_FILIAL+DTOS(F0M_DTFECH)+F0M_CODIGO+F0M_CST+F0M_SITUA+F0M_CLIFOR+F0M_LOJA+F0M_REGRA
oModel	:=	MPFormModel():New('FISA116MOD',,{ |oModel| ValidForm(oModel) })

oModel:AddFields( 'FISA116MOD' ,, oStruGener )

//Irá verificar qual alias está sendo processado, para não permitir campos do X2_UNICO sejam alterados no modo de edição
IF cAlias == 'F0M'
	oStruGener:SetProperty( 'F0M_FILIAL' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
	oStruGener:SetProperty( 'F0M_DTFECH' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
	oStruGener:SetProperty( 'F0M_CODIGO' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
	oStruGener:SetProperty( 'F0M_CST' 		, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
	
	oStruGener:SetProperty( 'F0M_SITUA' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
	oStruGener:SetProperty( 'F0M_CLIFOR'	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
	oStruGener:SetProperty( 'F0M_LOJA' 		, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
	oStruGener:SetProperty( 'F0M_REGRA'		, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
EndIF

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rafael S Oliveira
@since 26/02/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local	oModel 		:= 	FWLoadModel( 'FISA116' )
Local	oStruGener 	:= 	Nil
Local	oView 		:= 	FWFormView():New() 

Default cAlias := "F0M"

oView:SetModel( oModel )
oStruGener	:= 	FWFormStruct( 2, cAlias)
oView:AddField( 'VIEW_GEN', oStruGener, 'FISA116MOD' )

//Consulta F3
oStruGener:SetProperty( 'F0M_CLIFOR' , MVC_VIEW_LOOKUP  , { || A116ChgF3("F0M_CLIFOR",'FISA116MOD') } )

oStruGener:SetProperty("F0M_REGRA", MVC_VIEW_COMBOBOX,  F116ListReg())
 
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PERG116
Função que pergunta para usuário qual a pasta onde os arquivos a serem 
importados estão. 

@author Rafael S Oliveira
@since 26/02/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Function PERG116()

Local cDescric	:= ""
Local oProcess

If Pergunte("FISA116",.T.)	
	
	IF MV_PAR02 == Iif(ValType(MV_PAR02) == 'C', '1', 1)
		cDescric:=STR0001//'Média Ponderada da Base de ICMS ST'
	ElseIF MV_PAR02 == Iif(ValType(MV_PAR02) == 'C', '2', 2)
		cDescric:=STR0002//'Custo Médio com MVA'
	ElseIF MV_PAR02 == Iif(ValType(MV_PAR02) == 'C', '3', 3)
		cDescric:=STR0003//'Preço + seguro + frete – IPI'
	ElseIF MV_PAR02 == Iif(ValType(MV_PAR02) == 'C', '4', 4)
		cDescric:=STR0004//'Valor definido através de legislação específica'
	ElseIF MV_PAR02 == Iif(ValType(MV_PAR02) == 'C', '5', 5)
		cDescric:='Média ponderada da base de ICMS ST recolhido anteriormente'
	EndIF
Else
	Return
EndIF

oProcess := FISProgress():New({|| PrImpSPEDB(@oProcess,cDescric)},STR0011,.T.)//'Realizando Importação'
oProcess:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrImpSPEDB
Função responsável pela verificação da existência de dados retornada pelo estoque, bem como 
percorrer os dados e preparar as linhas para gravação.

@author Rafael S Oliveira
@since 26/02/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function PrImpSPEDB(oProcess,cDescric)

Local cAliBLH	:= {}
Local dTFech	:= MV_PAR01
Local dDataDe   := FirstDay(dTFech) 
Local dDataAte  := dTFech
Local lSPDBlocH	:= FindFunction("SPDBlocH")
Local lEnd 		:= .F.

dbSelectArea("F0M")
('F0M')->( dbSetOrder(1) )

//Verifico se existe a tabela F0Q para utiliza-la posteriormente
IF aliasindic('F0Q')
	
	PRIVATE lAchouF0Q	:= .t.

	dbSelectArea('F0Q')
	('F0Q')->( dbSetOrder(1) )

EndIF

Begin Transaction

oProcess:Inc1Progress(STR0018)//'Processando inventário : '
//Chamada da função do estoque
//FSModeloP7("SPEDA",1,@aAlias)
//CalcEst(,dDataAte,@aAlias,)
IF Empty(dDataAte)
	lEnd := .T.	
	Alert('Data de fechamento do inventário não preenchida')

//Ponto de entrada
ElseIf ExistBlock("SPEDALTH") 			

	cAliBLH := ExecBlock("SPEDALTH",.F.,.F.,{dDataAte,''})

	//Verifica se arquivo existe
	If MSFile(cAliBLH+GetDBExtension(),,__LocalDriver)
		dbSelectArea(cAliBLH) 
		(cAliBLH)->(dbGoTop())				
	Else
		lEnd := .T.
		Alert("Não foi encontrado arquivo do ponto de entrada SPEDALTH para compor Bloco H")		
	Endif
Elseif !lSPDBlocH
	lEnd := .T.	
	Alert('Não foi encontrada Função SPDBlocH, Verifique atualização do fonte MATXSPED')
Else
	SPDBlocH(@cAliBLH,dDataDe,dDataAte)

	oProcess:Inc1Progress(STR0012)//'Concluído'
	
	If Empty(cAliBLH)
		Alert("Nao foi encontrado dados no retorno da funçao SPDBlocH")
		lEnd := .T.					
	Else
		dbSelectArea(cAliBLH)
		(cAliBLH)->(dbGoTop())
	Endif	
Endif

IF !lEnd	
	oProcess:Inc2Progress('Processando: '+cDescric)	
		
	//Limpa Tabela
	FISAPG116(cAliBLH)
	//Grava dados
	PrInvF0M(cAliBLH)
	
	oProcess:Inc2Progress(STR0012)//'Concluído'
Else
	DisarmTransaction()	
	Alert(STR0014)//'Operação Cancelada'
Endif

End Transaction

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrInvF0M
Função que irá verificar se informação já está gravada no banco de dados
e também definir para qual tabela a informação deverá ser gravada.

@author Rafael S Oliveira
@since 26/02/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Static function PrInvF0M(cAliBLH)

Local aArea  		:= GetArea()
Local lCmpAltTri	:=	SB5->(FieldPos('B5_ALTTRIB'))>0
Local nAliqProd		:= 0
Local nSB1Aliq		:= 0
Local cProd			:= ""
Local cClasFis		:= ""
Local dTFech		:= MV_PAR01
Local nValICM		:= 0
Local nMVA			:= 0
Local cRegra		:= cValToChar(MV_PAR02)
Local nCustmedio	:= 0
Local nQuant		:= 0
Local nTotal		:= 0
Local nValUnit  	:= 0
Local cLoja			:= ""
Local cClifor		:= ""
Local cSitualcao	:= ""
Local cUnidade		:= ""
Local cTPCF     	:= ""
Local cConta		:= ""
Local nTamProd		:= TamSX3("B1_COD")[1]
local ntamCli		:= TamSX3("F0M_CLIFOR")[1]
Local nTamLoj		:= TamSX3("F0M_LOJA")[1]
Local lAchou		:= .F.
Local lNvcampos 	:= F0M->(FieldPos('F0M_UM'))>0 .And. F0M->(FieldPos('F0M_VUNIT'))>0 .And. F0M->(FieldPos('F0M_TPCF'))>0 .And. F0M->(FieldPos('F0M_CONTA'))>0
Local lF0QMva		:= F0Q->(fieldpos("F0Q_MVA")) > 0
Local lF0MMotInv    := F0M->(FieldPos('F0M_MOTINV'))>0
Local lExistF0Q		:= .F.
Local nAliqMV		:= SuperGetMv("MV_ICMPAD",.F.,0)
Local lVer12		:= GetRpoRelease() > "12.1.017"
Local lRegra5		:= .T.
Local lAchouSB5     := .F.
Local nI			:= 0
Local lH020Cst		:= cValToChar(MV_PAR03) == "2"
Local aBasIcm		:= {}

Do While !(cAliBLH)->(Eof()) 
	
	cProd		:= PadR(Alltrim((cAliBLH)->COD_ITEM),nTamProd)
	aBasIcm		:= {}

	//Para utilizar a opção 5-Média ponderada da base de ICMS ST recolhido anteriormente é necessário que o campo CST do produto (B1_CLASSFIS) seja igual a 60.
	lRegra5 := cRegra == '5' .And. (cAliBLH)->CL_CLASS == "60"
	
	//Se houver alteração na F0Q, posiciono para pegar o MVA e atualizar F0M_MVA		
	lExistF0Q	:= lAchouF0Q .and. F0Q->(MsSeek(xFilial('F0Q')+ dtos(dTFech)+cProd))
	nAliqProd	:= nAliqMV

	lAchouSB5 := SpedMotInv('',cProd,lCmpAltTri,@nAliqProd)
	
	If ( !lRegra5 .And. (lExistF0Q .Or. lAchouSB5) ) .Or. lRegra5
		
		lAchou      := .T.
		nSB1Aliq    := (cAliBLH)->ALQ_PICM // Aliquota SB1
		
		//Utiliza aliquota do produto se existir
		If nSB1Aliq > 0
			nAliqProd	:=	nSB1Aliq
		EndIf

		cClasFis	:= (cAliBLH)->COD_ORIG+(cAliBLH)->CL_CLASS
		IF lVer12
			cConta		:= (cAliBLH)->COD_CTA
		Else
			cConta		:= ""
		Endif
		cClifor		:= ''
		cLoja		:= ''
		cTPCF		:= ''
		
		nMVA		:= iif (lExistF0Q .and. lF0QMva .and. cRegra == '2', F0Q->F0Q_MVA, 0)
		cUnidade	:= (cAliBLH)->UNID
		nQuant		:= (cAliBLH)->QTD
		nValUnit	:= (cAliBLH)->VL_UNIT
		nCustmedio	:= (cAliBLH)->VL_ITEM
		cClifor		:= SubsTring((cAliBLH)->COD_PART,4,ntamCli)
		cLoja		:= SubsTring((cAliBLH)->COD_PART,4+ntamCli,nTamLoj)
		
		IF (cAliBLH)->IND_PROP <> '0'			
			If SubsTring((cAliBLH)->COD_PART,1,3) == 'SA1'
				cTPCF		:= 'C'
			Else
				cTPCF		:= 'F'
			Endif
		Endif
		
		//0 - Item de propriedade do informante e em seu poder;
		//1 - Item de propriedade do informante em posse de terceiros
		//2 - Item de propriedade de terceiros em posse do informante
		cSitualcao  := (cAliBLH)->IND_PROP
		
		IF cRegra == '1' .Or. cRegra == '5'//Base de cálculo unitária = Somatório da Base de Cálculo ICMS ST / Quantidade em estoque	
			aBasIcm:= MediaP(xFilial("F0M"),cProd,nQuant,lH020Cst,cClasFis)						
		ElseIF cRegra == '2'//Base de cálculo unitária = (Valor do Custo Médio * (1 + MVA do produto)) / Quantidade em estoque
			Aadd(aBasIcm,{cClasFis, iif(nMVA > 0, nCustmedio * (1 + (nMVA / 100)), 0), nQuant, nQuant})
		ElseIF cRegra == '3'//Base de Cálculo unitária = (Somatório do preço de aquisição + seguro + frete – IPI) / Quantidade em estoque	
			aBasIcm := PSFIPI(xFilial("F0M"),cProd,nQuant,lH020Cst,cClasFis)
		ElseIF cRegra == '4'//'Valor definido através de legislação específica'		
			Aadd(aBasIcm,{cClasFis, 0, nQuant, nQuant})
		EndIF

		If lExistF0Q .And. lF0MMotInv .And. !lRegra5 
			While F0Q->F0Q_FILIAL + DtoS(F0Q->F0Q_DTFECH) + F0Q->F0Q_CODIGO == xFilial("F0Q") + DtoS(dTFech) + cProd

				For nI := 1 to Len(aBasIcm)

					nValICM		:= aBasIcm[nI][2] * (nAliqProd/100)
					nTotal		:= nQuant * nValICM
					nCustmedio  := aBasIcm[nI][3] * nValUnit

					GrvF0M(  cProd, aBasIcm[nI][1], aBasIcm[nI][2], dTFech,   nValICM, nAliqProd, nMVA, aBasIcm[nI][3], nCustmedio, cSitualcao,;
							cRegra, cClifor ,   cLoja, nTotal, lNvcampos, cUnidade , nValUnit, cTPCF , cConta, lF0MMotInv, F0Q->F0Q_MOTINV, aBasIcm[nI][4] )
				
				Next nI	

				F0Q->(DbSkip())
			EndDo
		Else
			For nI := 1 to Len(aBasIcm)

				nValICM		:= aBasIcm[nI][2] * (nAliqProd/100)
				nTotal		:= nQuant * nValICM
				nCustmedio  := aBasIcm[nI][3] * nValUnit

				GrvF0M( cProd , aBasIcm[nI][1], aBasIcm[nI][2], dTFech, nValICM  , nAliqProd, nMVA, aBasIcm[nI][3], nCustmedio, cSitualcao,;
						cRegra, cClifor , cLoja  , nTotal, lNvcampos, cUnidade , nValUnit, cTPCF , cConta, lF0MMotInv, "02", aBasIcm[nI][4] )
			Next nI
		EndIf
	
	EndIf
	
	(cAliBLH)->(dbSkip())
Enddo

IF lAchou
	MsgInfo(STR0013)//'Importação Concluída'
else	
	Alert('Não foram encontrados produtos para data de fechamento de estoque informada')
Endif

(cAliBLH)->(dbCloseArea())
Ferase(cAliBLH+GetDBExtension())

RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrInvF0M
Função que irá verificar se informação já está gravada no banco de dados
e também definir para qual tabela a informação deverá ser gravada.

@author Rafael S Oliveira
@since 26/02/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Static function GrvF0M( cProd , cClasFis, nBasIcm, dTFech, nValICM  , nAliqProd, nMVA    , nQuant, nCustmedio, cSitualcao,;
			 			cRegra, cClifor , cLoja  , nTotal, lNvcampos, cUnidade , nValUnit, cTPCF , cConta    , lF0MMotInv, cMotInv, nQtdCst )

Local lF0MQtdCst := F0M->(FieldPos('F0M_QTDCST')) > 0 

//F0M_FILIAL+F0M_DTFECH+F0M_CODIGO+F0M_CST+F0M_SITUA+F0M_CLIFOR+F0M_LOJA+F0M_REGRA+F0M_MOTINV
If !F0M->(dbSeek(xFilial("F0M")+DTOS(dTFech)+cProd+cClasFis+cSitualcao+cClifor+cLoja+cRegra+IIf(lF0MMotInv,cMotInv,"") ))
	RecLock("F0M",.T.)
	F0M->F0M_FILIAL	:= xFilial("F0M")
	F0M->F0M_CODIGO	:= cProd
	F0M->F0M_CST	:= cClasFis
	F0M->F0M_BASICM	:= nBasIcm
	F0M->F0M_DTFECH	:= dTFech
	F0M->F0M_VALICM	:= nValICM
	F0M->F0M_ALIQ	:= nAliqProd
	F0M->F0M_MVA	:= nMVA
	F0M->F0M_QUANT	:= nQuant
	F0M->F0M_VALCMD := nCustmedio
	F0M->F0M_SITUA	:= cSitualcao
	F0M->F0M_REGRA	:= cRegra
	F0M->F0M_CLIFOR	:= cClifor
	F0M->F0M_LOJA	:= cLoja
	F0M->F0M_TOTICM	:= nTotal
	
	//novos campos para compor SPED
	IF lNvcampos
		F0M->F0M_UM		:= cUnidade     //02 - Unidade.
		F0M->F0M_VUNIT	:= nValUnit 	//04 - Valor Unidade.
		F0M->F0M_TPCF	:= cTPCF	    //Cliente/Fornecedor.
		F0M->F0M_CONTA	:= cConta
	Endif

	If lF0MMotInv
		F0M->F0M_MOTINV := cMotInv
	EndIf

	If lF0MQtdCst
		F0M->F0M_QTDCST := nQtdCst
	EndIf
	
	F0M->(MsUnLock())
Else
	RecLock("F0M",.F.)
	F0M->F0M_VALICM	+= nValICM
	F0M->F0M_QUANT	+= nQuant
	F0M->F0M_VALCMD += nCustmedio
	F0M->F0M_TOTICM	+= nTotal
	F0M->F0M_BASICM	+= nBasIcm
	If lNvcampos
		F0M->F0M_VUNIT	+= nValUnit 	//04 - Valor Unidade.
	Endif

	F0M->(MsUnLock())
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MediaP
Função para calculo da media ponderada
cRegra == '1' - Base de cálculo unitária = Somatório da Base de Cálculo ICMS ST / Quantidade em estoque	

@author Rafael S Oliveira
@since 26/02/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Function MediaP(cFil,cProduto,nQuant,lH020Cst,cClasFis)
Local aArea  	:= GetArea()
Local cAlias 	:= GetNextAlias()
Local dTFech	:= MV_PAR01
Local dDataDe    := FirstDay(dTFech) 
Local dDataAte   := dTFech
Local nTtQuant	:= 0
Local cAliasSFT := ""
Local lAchouFT	:= .F.
Local cGroupBy  := ""
Local cSelect   := "" 
Local cChave	:= ""
Local aRet 		:= {}
Local aAux		:= {}
Local oRet 		:= JsonObject():New()
cProduto := alltrim(cProduto)

//Verifica se exsiste nota de entrada para este produto
BeginSql Alias cAlias

SELECT SUM(SFT.FT_QUANT) QUANT
FROM 	%TABLE:SFT% SFT
	WHERE  SFT.FT_FILIAL=%XFILIAL:SFT%
	AND SFT.FT_PRODUTO = %EXP:cProduto%
	AND SFT.FT_TIPO NOT IN ('D','B')
	AND SFT.FT_TIPOMOV = 'E'
	AND SFT.FT_DTCANC = ''
	AND SFT.FT_ENTRADA <=  %EXP:dDataAte%
	AND SFT.%NOTDEL%	
EndSql
DbSelectArea (cAlias)
IF (cAlias)->QUANT >= nQuant
	lAchouFT:= .T.	
	
	(cAlias)->(dbCloseArea()) 
Else
	(cAlias)->(dbCloseArea())
	aAdd(aRet,{cClasFis,0,nQuant,nQuant})

	Return aRet
Endif

If lAchouFT

	If lH020Cst
		cSelect   := ", SFT.FT_CLASFIS "
		cGroupBy  := "GROUP BY SFT.FT_CLASFIS "
	EndIf

	cSelect := "% " + cSelect + " %"
	cGroupBy := "% " + cGroupBy + " %"

	While nTtQuant < nQuant 

		cAliasSFT := GetNextAlias()
		
		BeginSql Alias cAliasSFT	
			SELECT SUM(SFT.FT_QUANT) QUANT, SUM(SFT.FT_BASERET+SFT.FT_BASNDES) AS SOMA
			%Exp:cSelect%
			FROM 	%TABLE:SFT% SFT
			WHERE  SFT.FT_FILIAL=%XFILIAL:SFT%
			AND SFT.FT_PRODUTO = %EXP:cProduto%
			AND SFT.FT_TIPO NOT IN ('D','B')
			AND SFT.FT_TIPOMOV = 'E'
			AND SFT.FT_DTCANC = ''		
			AND SFT.FT_ENTRADA >=  %EXP:dDataDe%
			AND SFT.FT_ENTRADA <=  %EXP:dDataAte%
			AND SFT.%NOTDEL%
			%Exp:cGroupBy%
		EndSql
		DbSelectArea (cAliasSFT)

		While (cAliasSFT)->(!Eof())
			
			cChave := Iif(lH020Cst,Alltrim((cAliasSFT)->FT_CLASFIS),Alltrim(cClasFis))
			
			If oRet[cChave] == Nil .Or. Len(oRet[cChave]) == 0
				oRet[cChave] := {}
				Aadd(oRet[cChave], JsonObject():New())
				oRet[cChave][1]['soma'] := 0
				oRet[cChave][1]['quant'] := 0
			EndIf	

			oRet[cChave][1]['soma']  += (cAliasSFT)->SOMA
			oRet[cChave][1]['quant'] += (cAliasSFT)->QUANT

			nTtQuant += (cAliasSFT)->QUANT //50

			(cAliasSFT)->(DbSkip())
		EndDo
		
		//Primeiro dia
		dDataDe	:= FirstDay(dDataDe)
		dDataDe := dDataDe - 1
		dDataDe	:= FirstDay(dDataDe)

		//Ultimo Dia
		dDataAte := FirstDay(dDataAte)
		dDataAte :=  dDataAte - 1
		
		(cAliasSFT)->(dbCloseArea())

	Enddo

	aAux := oRet:GetNames()

	If Len(aAux) > 0
		aRet := F116MntBas(aAux,oRet,nQuant,lH020Cst,nTtQuant)
	EndIf

	FwFreeObj(oRet)

Endif

RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PSFIPI
Função que realiza calculo da media ponderada
cRegra == '3'- Base de Cálculo unitária = (Somatório do preço de aquisição + seguro + frete – IPI) / Quantidade em estoque	

@author Rafael S Oliveira
@since 26/02/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Function PSFIPI(cFil,cProduto,nQuant,lH020Cst,cClasFis)

Local aArea  	:= GetArea()
Local cAlias 	:= GetNextAlias()
Local dTFech	:= MV_PAR01
Local dDataDe    := FirstDay(dTFech) 
Local dDataAte   := dTFech
Local nTtQuant	:= 0
Local cAliasSFT := ""
Local lAchouFT	:= .F.
Local cGroupBy  := ""
Local cSelect   := "" 
Local aRet 		:= {}
Local aAux		:= {}
Local oRet 		:= JsonObject():New()
cProduto := alltrim(cProduto)

//Verifica se exsiste nota de entrada para este produto
BeginSql Alias cAlias

SELECT SUM(SFT.FT_QUANT) QUANT
FROM 	%TABLE:SFT% SFT
	WHERE  SFT.FT_FILIAL=%XFILIAL:SFT%
	AND SFT.FT_PRODUTO = %EXP:cProduto%
	AND SFT.FT_TIPO NOT IN ('D','B')
	AND SFT.FT_TIPOMOV = 'E'
	AND SFT.FT_DTCANC = ''
	AND SFT.FT_ENTRADA <=  %EXP:dDataAte%
	AND SFT.%NOTDEL%	
EndSql

DbSelectArea (cAlias)
IF (cAlias)->QUANT >= nQuant
	lAchouFT:= .T.	
	
	(cAlias)->(dbCloseArea()) 
Else
	(cAlias)->(dbCloseArea()) 
	aAdd(aRet,{cClasFis,0,nQuant,nQuant})

	Return aRet
Endif

IF lAchouFT

	If lH020Cst
		cSelect   := ", SFT.FT_CLASFIS"
		cGroupBy  := "GROUP BY SFT.FT_CLASFIS"
	EndIf

	cSelect := "% " + cSelect + " %"
	cGroupBy := "% " + cGroupBy + " %"

	while nTtQuant < nQuant

		cAliasSFT	:=	GetNextAlias()
		
		BeginSql Alias cAliasSFT	
			SELECT SUM(SFT.FT_QUANT) QUANT, SUM(SFT.FT_VALCONT-SFT.FT_VALIPI) AS SOMA
			%Exp:cSelect%
			FROM 	%TABLE:SFT% SFT
			WHERE  SFT.FT_FILIAL=%XFILIAL:SFT%
			AND SFT.FT_PRODUTO = %EXP:cProduto%
			AND SFT.FT_TIPO NOT IN ('D','B')
			AND SFT.FT_TIPOMOV = 'E'
			AND SFT.FT_DTCANC = ''		
			AND SFT.FT_ENTRADA >=  %EXP:dDataDe%
			AND SFT.FT_ENTRADA <=  %EXP:dDataAte%
			AND SFT.%NOTDEL%
			%Exp:cGroupBy%
		EndSql
		DbSelectArea (cAliasSFT)

		While (cAliasSFT)->(!Eof())
			
			cChave := Iif(lH020Cst,Alltrim((cAliasSFT)->FT_CLASFIS),Alltrim(cClasFis))
			
			If oRet[cChave] == Nil .Or. Len(oRet[cChave]) == 0
				oRet[cChave] := {}
				Aadd(oRet[cChave], JsonObject():New())
				oRet[cChave][1]['soma'] := 0
				oRet[cChave][1]['quant'] := 0
			EndIf	

			oRet[cChave][1]['soma']  += (cAliasSFT)->SOMA
			oRet[cChave][1]['quant'] += (cAliasSFT)->QUANT

			nTtQuant += (cAliasSFT)->QUANT
			
			(cAliasSFT)->(DbSkip())

		EndDo
		
		//Primeiro dia
		dDataDe	:= FirstDay(dDataDe)
		dDataDe := dDataDe - 1
		dDataDe	:= FirstDay(dDataDe)

		//Ultimo Dia
		dDataAte := FirstDay(dDataAte)
		dDataAte :=  dDataAte - 1
		
		(cAliasSFT)->(dbCloseArea())  

	Enddo

	aAux := oRet:GetNames()

	If Len(aAux) > 0
		aRet := F116MntBas(aAux,oRet,nQuant,lH020Cst,nTtQuant)		
	EndIf
	
	FwFreeObj(oRet)

Endif

RestArea(aArea)

Return aRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValidForm     ºAutor  ³ Rafael dos Santos   º Data ³ 17/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação das informações digitadas no form.            	        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIS                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³																   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Objeto                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidForm(oModel)

Local lRet		:=	.T.
Local dFech		:=	oModel:GetValue ('FISA116MOD','F0M_DTFECH')
Local cCod		:=	oModel:GetValue ('FISA116MOD','F0M_CODIGO')
Local cCST		:=	oModel:GetValue ('FISA116MOD','F0M_CST')
Local cSit		:=	oModel:GetValue ('FISA116MOD','F0M_SITUA')
Local cCliFor	:=	oModel:GetValue ('FISA116MOD','F0M_CLIFOR')
Local cLoja		:=	oModel:GetValue ('FISA116MOD','F0M_LOJA')
Local cRegra	:=	oModel:GetValue ('FISA116MOD','F0M_REGRA')
Local nOp		:=	oModel:GetOperation()
Local cRegisto	:= ""

//F0M_FILIAL+DTOS(F0M_DTFECH)+F0M_CODIGO+F0M_CST+F0M_SITUA+F0M_CLIFOR+F0M_LOJA+F0M_REGRA
If nOp == 3   //Inclusão
	DbSelectArea ("F0M")  //Valores de exclusão de PIS e Cofins para sociedade cooperativa.
	F0M->(DbSetOrder (1))
	If F0M->(DbSeek(xFilial("F0M")+DTOS(dFech)+cCod+cCST+cSit+cCliFor+cLoja+cRegra))
		Help(" ",1,"Help","Help","Registro já cadastrado",1,0)//Registro já cadastrado
		Return .F.
	EndIF		

	If cRegra == '5' .And. SubStr(cCST,2) <> "60"
		Help(" ",1,"Help","Help","Produto não pode ser utilizado devido ao campo Class. Fiscal estar diferente de 60.",1,0)
		Return .F.
	EndIf
EndIF

If nOp == 4 // Alterando registro
	dbSelectArea("F0M")
	cRegisto    := F0M->(RECNO())
	F0M->(DbSetOrder (1))
	If F0M->(DbSeek(xFilial("F0M")+DTOS(dFech)+cCod+cCST+cSit+cCliFor+cLoja+cRegra))
		 IF F0M->(RECNO()) <> cRegisto
			Help(" ",1,"Help","Help","Registro já cadastrado",1,0)//Registro já cadastrado
			Return .F.
		 EndIf   
	EndIF
EndIF

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FISAPG116
Função apaga registros antigos em caso de reprocessar mesmo periodo

@author Rafael S Oliveira
@since 26/02/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Function FISAPG116(cAliBLH)
Local dTFech	:= MV_PAR01
Local cRegra	:= cValToChar(MV_PAR02)
Local cClifor	:= ""
Local cLoja		:= ""
Local cProd		:= ""
Local cClasFis	:= ""
Local cSitualcao:= ""
Local nTamProd	:= TamSX3("B1_COD")[1]
local ntamCli	:= TamSX3("F0M_CLIFOR")[1]
Local nTamLoj	:= TamSX3("F0M_LOJA")[1]
Local lCmpAltTri:=	SB5->(FieldPos('B5_ALTTRIB'))>0
Local nAliqProd := 0
Local lRegra5  	:=  .F.
Local lExistF0Q	:= .F.

Do While !(cAliBLH)->(Eof()) 
	cProd		:= PadR(Alltrim((cAliBLH)->COD_ITEM),nTamProd)
	cClasFis	:= (cAliBLH)->COD_ORIG+(cAliBLH)->CL_CLASS
	cSitualcao  := (cAliBLH)->IND_PROP
	cClifor		:= SubsTring((cAliBLH)->COD_PART,4,ntamCli)
	cLoja		:= SubsTring((cAliBLH)->COD_PART,4+ntamCli,nTamLoj)
	lRegra5     := cRegra == '5' .And. (cAliBLH)->CL_CLASS == "60"
	
	//Verifico se há alteração referente ao produto na tabela F0Q
	lExistF0Q := F0Q->(MsSeek(xFilial('F0Q')+ dtos(dTFech)+cProd))

	If ( !lRegra5 .And. (lExistF0Q .or. SpedMotInv('',cProd,lCmpAltTri,@nAliqProd)) ) .Or. lRegra5
		
		DbSelectArea("F0M")
		F0M->(DbGoTop())

		While !F0M->(Eof()) .And. F0M->F0M_FILIAL == xFilial("F0M")
			If DTOS(F0M->F0M_DTFECH) == DTOS(dTFech) .And. F0M->F0M_CODIGO == cProd .And. F0M->F0M_SITUA == cSitualcao;
			.And. F0M->F0M_CLIFOR == cCliFor .And. F0M->F0M_LOJA == cLoja .And. F0M->F0M_REGRA == cRegra			
				RecLock("F0M")
				F0M->(DbDelete())
				F0M->(MsUnLock())
			EndIf
			F0M->(DbSkip())
		EndDo

	EndIf
	
	(cAliBLH)->(dbSkip())
	
Enddo

//retorna Arquivo temporario para primeira posição
(cAliBLH)->(dbGoTop())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} A116ChgF3
Funcao utilizada para trocar a consulta F3 em momento de execucao dependendo
da opcao informada

@param 	cCmpF3 - Nomde do campo para fazer a validacao, o conteudo eh retornado pela classe GetValue( cModel , cCmpF3 )
		cModel - Id do modelo para passar na funcao GetValue( cModel , cCmpF3 )
		
@return cF3 - Retorna o nome da consulta F3 a ser utilizada
			
@author Rafael
@since 24/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A116ChgF3 (cCmpF3,cModel)
Local	oModel	:= 	FWModelActive()
Local	cF3		:=	""
Local	cGet	:=	oModel:GetValue( cModel , cCmpF3 )
Local lPart	:= F0M->(FieldPos("F0M_TPCF")) > 0
Local cPart	:= ""

If lPart
	cPart:=oModel:GetValue(cModel,'F0M_TPCF')
EndiF 

If lPart .AND. !Empty(cPart)
	IF cPart == "C"
		cF3			:=	"SA1"	
	ElseIF cpart == "F"
		cF3			:=	"SA2A"	
	EndIF	
Else
	If cGet == "0"
		cF3			:=	"SA1"
	Else
		cF3			:=	"SA2A"
	Endif	
EndIF 

Return cF3

//-------------------------------------------------------------------
/*/{Protheus.doc} F116ListReg
Função que cria a lista de opções do campo F0M_REGRA

@author Eduardo Vicente da Silva
@since 11/01/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function F116ListReg()
Local aArea         := GetArea()
Local aRet			:= {}
Local aDadosSX5		:= {}
Local nCount		:= 0

aDadosSX5 := FWGetSX5( "AY" )

For nCount := 1 To Len( aDadosSX5 )
	aAdd(aRet, Alltrim( aDadosSX5[nCount][3] ) + "=" + Alltrim( aDadosSX5[nCount][4]) )
Next

//Se não encontrou a tabela AY deve adicionar as opções existentes para o campo.
If Len(aRet) == 0
	aRet := {'1=Méd. Pond. Base de ICMS ST','2=Custo Méd. com MVA','3=Pr+Seg+fret – IPI','4=Leg. Específica','5=Méd. Pond. Base ICMS ST Rec. Ant.'}
EndIf

aAdd(aRet,'')

RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F116MntBas
Função que realiza o calculo da Base de Icm, podendo ser detalhada
por CST.
@author Ramilson Sobral
@since 22/09/2022
@version 12.1.2210
/*/
//-------------------------------------------------------------------

Static Function F116MntBas(aAux,oRet,nQuant,lH020Cst,nTtQuant)

Local aRet 	:= {}
Local nAux 	:= 0
Local nQtd 	:= 0
Local nCont := 0
Local nI 	:= 0

nAux := nQuant 

For nI := 1 to Len(aAux)

	If !lH020Cst
		nQtd := nQuant
	Else
		If nI <> Len(aAux)
			If nAux >= oRet[aAux[nI]][1]["quant"] 
				nQtd := oRet[aAux[nI]][1]["quant"] 
			Else 
				nQtd := nAux/(Len(aAux)-nCont) 
			EndIf	
		Else
			nQtd := nAux 
		EndIf
	EndIf	

	Aadd(aRet,{	aAux[nI],; //CST
				oRet[aAux[nI]][1]["soma"]/nTtQuant,; //Base de Icm
				nQtd,; //Quant
				oRet[aAux[nI]][1]["quant"] }) //Quant do CST

	nAux -= nQtd 
	nCont++ 

Next nI

Return aRet
