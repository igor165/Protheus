#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260B78
Browse do Historico Parcelamento
@author DEV TOTVS
@since  13/12/2019
@version P12
/*/
//-------------------------------------------------------------------

Function PLSA260B78(lAutomato)
// Declaração de Variáveis
Local oBrowse
Default lAutomato := .F.

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BA1' )
oBrowse:SetDescription( Fundesc() )	
oBrowse:SetMenuDef( 'PLSA260B78' )
If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu de Historico Parcelamento
@author  DEV TOTVS
@since   13/12/2019
@version P12
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
// Declaração de Variáveis
Local aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo de dados do Historico Parcelamento
@author  DEV TOTVS
@since   13/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
// Declaração de Variáveis
Local oModel	
Local oStruBA1 		:= FWFormStruct(1,'BA1')
Local oStruB78 		:= FWFormStruct(1,'B78')	

Local aCamposBA1	:= {'BA1_CODINT','BA1_CODEMP','BA1_MATRIC'} // Campos a serem adicionado na estrutura
Local aCamposB78	:= {'B78_CODINT','B78_CODEMP','B78_MATRIC','B78_ANOBAS'} // Campos a serem adicionado na estrutura
Local nNx

//Ja esta posicionado no titular.
BA3->( dbSetorder(01) )
BA3->( MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))

// Cria o objeto do Modelo de Dados	 
oModel := MPFormModel():New('PLSA260B78')

// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCamposBA1)
	oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
Next

For nNx := 1 To Len(aCamposB78)
	oStruB78 := CriaCampMVC(1,oStruB78,aCamposB78[nNx]) 
Next

// Adiciona as estruturas no modelo
oModel:addFields('MasterBA1' ,NIL,oStruBA1) 
oModel:AddGrid('B78DETAIL','MasterBA1',oStruB78)

// Permissão de grid sem dados
oModel:GetModel('B78DETAIL'):SetOptional(.T.)

// Relacionamento entre as tabelas
oModel:SetRelation( 'B78DETAIL', {  { 'B78_FILIAL' , 'xFilial( "B78" )'},;
								    { 'B78_CODINT'	, 'BA1_CODINT' } ,;
                                    { 'B78_CODEMP'	, 'BA1_CODEMP' } ,;
                                    { 'B78_MATRIC'	, 'BA1_MATRIC' }},;									
								B78->( IndexKey( ) ) ) 						
	
oModel:SetDescription( FunDesc() )	// Descrição do Modelo de dados

// Descrição de cada modelo usado
oModel:GetModel('MasterBA1'):SetDescription('Familia' )
oModel:GetModel('B78DETAIL'):SetDescription('Histórico Parcelamento' )	

// Não permite alteração ou inclusão no modelo
oModel:GetModel('MasterBA1'):SetOnlyQuery(.T.)
oModel:GetModel('MasterBA1'):SetOnlyView(.T.)
oModel:GetModel('B78DETAIL'):SetOnlyQuery(.T.)
oModel:GetModel('B78DETAIL'):SetOnlyView(.T.)

oModel:SetPrimaryKey( { "BA1_FILIAL", "BA1_CODINT", "BA1_CODEMP", "BA1_MATRIC" } )

Return (oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View do histórico Parcelamento
@author  DEV TOTVS
@since   13/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 
// Declaração de Variáveis
Local oStruBA1 := FWFormStruct(2,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|' } )
Local oStruB78 := FWFormStruct(2,'B78')	
Local oModel   := FWLoadModel( 'PLSA260B78') // Carrega o modelo
Local oView
Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
Local nNx	

oView := FWFormView():New() // Cria o Objeto View

// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCampos)
	oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
Next

oView:SetModel( oModel )

oStruB78:RemoveField('B78_CODINT')
oStruB78:RemoveField('B78_CODEMP')
oStruB78:RemoveField('B78_MATRIC')

oView:AddField( 'VIEW_BA1' , oStruBA1, 'MasterBA1' )
oView:AddGrid(  'VIEW_B78' , oStruB78, 'B78DETAIL' )

oStruBA1:SetNoFolder() // Retirando as pastas de uma estrutura

oView:CreateHorizontalBox( 'SUPERIOR', 20) 
oView:CreateHorizontalBox( 'MEIO'	 , 80) 

oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
oView:SetOwnerView('VIEW_B78', 'MEIO')	
	
oView:EnableTitleView('VIEW_BA1','Familia')
oView:EnableTitleView('VIEW_B78','Histórico Parcelamento')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PL260SALDMVC
Realiza a transferencia de saldo entre os beneficiarios
@author  DEV TOTVS
@since   13/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PL260SALDMVC(lAutomato)

Local aArea 		:= BA1->(GetArea())
Local nValAnt		:= 0
Local cDepois		:= ""
Local cAnt			:= ""
Local lAlt			:= .T.
Local cMesFat		:= ""
Local cAnoFat		:= ""
Local cMes			:= StrZero(Month(dDataBase),2)
Local cAno			:= StrZero(Year(dDataBase),4)

Local aParam1		:= {}
Local aDvFunc		:= {}
Local aDvFuncPara	:= {}
Local aDvFuncDe		:= {}
Local aDvFuncAux	:= {}
Local aAreaBA3	

Default lAutomato = .F.

//Posiciona na familia do usuario
BA3->( dbSetorder(01) )
BA3->( MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
aAreaBA3  := BA3->(GetArea())

cChaveBA3 := BA3->(BA3_CODCLI+BA3_LOJA)
BA3->(DbCloseArea())
DbSelectArea("BA3")
BA3->(DbSetOrder(3))//BA3_FILIAL, BA3_CODCLI, BA3_LOJA, BA3_CODINT, BA3_CODEMP, BA3_MATRIC, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB, R_E_C_N_O_, D_E_L_E_T_
BA3->(MsSeek(xFilial("BA3")+cChaveBA3))
//verifica se pode parcelar
While	BA3->( !Eof() )						.AND.;
		BA3->BA3_FILIAL == xFilial("BA3")	.AND.;
  		BA3->(BA3_CODCLI+BA3_LOJA)	== cChaveBA3
	DbSelectArea("BK2")
    BK2->(DbSetOrder(2))
    // Verifico se ha registro de bk2 nao parcelado para ver qual o mes/ano
    If 	BK2->(MsSeek(xFilial("BK2")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
	    While	BK2->( !Eof() )						.AND.;
				BK2->BK2_FILIAL == xFilial("BA3")	.AND.;
	   			BK2->BK2_CODINT == BA3->BA3_CODINT	.AND.;
	   	   		BK2->BK2_CODEMP == BA3->BA3_CODEMP	.AND.;
	  	   		BK2->BK2_MATRIC == BA3->BA3_MATRIC

			If BK2->BK2_PARCEL	<> 	'S' .And. AllTrim(BK2->BK2_PLNUCO) == ''
				cAnoFat := BK2->BK2_ANO
				cMesFat := BK2->BK2_MES
				Exit
			EndIf
			BK2->(DBSkip())
		EndDo
	EndIf
	If !Empty(cAnoFat) .And. !Empty(cMesFat)
		Exit
	EndIf
	BA3->(DBSkip())
EndDo

RestArea(aAreaBA3)
DbSelectArea("BA3")
BA3->(DbSetOrder(3))//BA3_FILIAL, BA3_CODCLI, BA3_LOJA, BA3_CODINT, BA3_CODEMP, BA3_MATRIC, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB, R_E_C_N_O_, D_E_L_E_T_
BA3->(MsSeek(xFilial("BA3")+cChaveBA3))
While	BA3->( !Eof() )						.AND.;
		BA3->BA3_FILIAL == xFilial("BA3")	.AND.;
  		BA3->(BA3_CODCLI+BA3_LOJA)	== cChaveBA3
	// Seleciona o usuario para transferir o saldo
	DbSelectArea("BA1")
	BA1->(DbSetOrder(2))
	If BA1->( MsSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)) )
		// Caso tenha mes/ano em aberto, permito o parcelamento
		If !Empty(cAnoFat) .And. !Empty(cMesFat)
			While	BA1->( !Eof() )						.AND.;
					BA1->BA1_FILIAL == xFilial("BA1")	.AND.;
					BA1->BA1_CODINT == BA3->BA3_CODINT	.AND.;
			   		BA1->BA1_CODEMP == BA3->BA3_CODEMP	.AND.;
			  		BA1->BA1_MATRIC == BA3->BA3_MATRIC
		            // Somente pessoas juridicas
		            If !Empty(BA1->BA1_CONEMP)
			            DbSelectArea("BK2")
						cValor := TransForm(Posicione("BK2",6,xFilial("BK2")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+BA1->BA1_TIPREG+cAnoFat+cMesFat,"BK2->BK2_SALDO"),"@E 99,999.99")
						If Val(cValor) > 0
							AaDd(aDvFunc,"R$ "+cValor +" - "+"("+BA1->BA1_CODEMP+"/"+BA1->BA1_MATRIC+"/"+BA1->BA1_TIPREG+")"+Capital(AllTrim(BA1->BA1_NOMUSR)))
							AaDd(aDvFuncDe,{BA1->(BA1_MATRIC+BA1_TIPREG),BK2->BK2_SALDO})
						EndIf
						AaDd(aDvFuncPara,"R$ "+cValor +" - "+"("+BA1->BA1_CODEMP+"/"+BA1->BA1_MATRIC+"/"+BA1->BA1_TIPREG+")"+Capital(AllTrim(BA1->BA1_NOMUSR)))
						AaDd(aDvFuncAux,{BA1->(BA1_MATRIC+BA1_TIPREG),BK2->BK2_SALDO})
					EndIf
					BA1->(DBSkip())
			EndDo
		EndIf
	EndIf
	BA3->(DBSkip())
EndDo
RestArea(aAreaBA3)

If lAutomato = .F.
	If Len(aDvFunc) == 0
		MsgAlert("Não há dados para selecionar") // Não há dados para selecionar

		RestArea(aArea)
		Return(.T.)
	Else
		If	ParamBox( {	{ 3 , "Origem" , 1 , aDvFunc ,120,"",.F.}} ,OemtoAnsi("Trânsferir do usuário: "),@aParam1,,,.T.,,)   //"Rotina" //"Trânsferir do usuário: "
			cAnt 	:= aDvFuncDe[aParam1[01],01]
			nValAnt	:= aDvFuncDe[aParam1[01],02]
		Else
			RestArea(aArea)
			Return(.T.)
		EndIf
	EndIf

	If	ParamBox( {	{ 3 , "Destino" , 1 , aDvFuncPara ,120,"",.F.}} ,OemtoAnsi("Trânsferir para o usuário: "),@aParam1,,,.T.,,) //"Rotina" //"Trânsferir para o usuário: "
		cDepois := aDvFuncAux[aParam1[01],01]
	Else
		RestArea(aArea)
		Return(.T.)
	EndIf
Else
	// Valores Definidos na automação
	cAnt 	:= "00000101" 
	cDepois := "00000102"
	nValAnt	:= 300

Endif

Begin Transaction
	// Deixo o saldo anterior com o valor zerado
	BK2->(DbSetOrder(6))
	If BK2->(MsSeek(xFilial("BK2")+BA3->(BA3_CODINT+BA3_CODEMP)+cAnt+cAnoFat+cMesFat))
		B78->(RecLock("B78",.T.))
	    	// Gero o historico deste lancamento
	    	B78->B78_FILIAL	:= 	xFilial("B78")
	    	B78->B78_CODINT	:=	BK2->BK2_CODINT
	    	B78->B78_CODEMP	:=	BK2->BK2_CODEMP
	    	B78->B78_MATRIC	:=	BK2->BK2_MATRIC
	    	B78->B78_TIPREG	:=	BK2->BK2_TIPREG
	    	B78->B78_MESBAS	:=	cMes
			B78->B78_ANOBAS	:=	cAno
			B78->B78_TIPOPE	:= 	"3"
			B78->B78_STATUS	:= 	"1"
			B78->B78_VLRTSA	:= 	nValAnt
			B78->B78_VALACU	:= 	0
		B78->(MsUnlock())
		BK2->(RecLock("BK2"),.F.)
			BK2->BK2_SALDO := 0
		BK2->(MsUnlock())
	Else
		lAlt := .F.
	EndIf

	// Contabilizo no usuario selecionado
	BK2->(DbSetOrder(6))
	If BK2->(MsSeek(xFilial("BK2")+BA3->(BA3_CODINT+BA3_CODEMP)+cDepois+cAnoFat+cMesFat)) .And. lAlt
		B78->(RecLock("B78",.T.))
	    	// Gero o historico deste lancamento
	    	B78->B78_FILIAL	:= 	xFilial("B78")
	    	B78->B78_CODINT	:=	BK2->BK2_CODINT
	    	B78->B78_CODEMP	:=	BK2->BK2_CODEMP
	    	B78->B78_MATRIC	:=	BK2->BK2_MATRIC
	    	B78->B78_TIPREG	:=	BK2->BK2_TIPREG
	    	B78->B78_MESBAS	:=	cMes
			B78->B78_ANOBAS	:=	cAno
			B78->B78_TIPOPE	:= 	"3"
			B78->B78_STATUS	:= 	"2"
			B78->B78_VLRTSA	:= 	nValAnt
			B78->B78_VALACU	:= 	BK2->BK2_SALDO+nValAnt
		B78->(MsUnlock())
		BK2->(RecLock("BK2"),.F.)
			BK2->BK2_SALDO := BK2->BK2_SALDO+nValAnt
		BK2->(MsUnlock())
	ElseIf lAlt
		BA1->(DbSetOrder(2))// BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
		If( BA1->(MsSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP)+cDepois)) )
			B78->(RecLock("B78",.T.))
	    		// Gero o historico deste lancamento
	    		B78->B78_FILIAL	:= 	xFilial("B78")
		    	B78->B78_CODINT	:=	BA1->BA1_CODINT
		    	B78->B78_CODEMP	:=	BA1->BA1_CODEMP
		    	B78->B78_MATRIC	:=	BA1->BA1_MATRIC
		    	B78->B78_TIPREG	:=	BA1->BA1_TIPREG
		    	B78->B78_MESBAS	:=	cMes
				B78->B78_ANOBAS	:=	cAno
				B78->B78_TIPOPE	:= 	"3"
				B78->B78_STATUS	:= 	"2"
				B78->B78_VLRTSA	:= 	nValAnt
				B78->B78_VALACU	:= 	nValAnt
			B78->(MsUnlock())
			BK2->(RecLock("BK2",.T.))
				BK2->BK2_FILIAL := xFilial("BK2")
				BK2->BK2_CODINT := BA1->BA1_CODINT
				BK2->BK2_CODEMP := BA1->BA1_CODEMP
				BK2->BK2_MATRIC := BA1->BA1_MATRIC
				BK2->BK2_TIPREG := BA1->BA1_TIPREG
				BK2->BK2_DIGITO := BA1->BA1_DIGITO
				BK2->BK2_ANO    := cAnoFat
				BK2->BK2_MES    := cMesFat
				BK2->BK2_SALDO  := nValAnt
				BK2->BK2_SALDO2 := 0
				BK2->BK2_PROPRI := "1"
				BK2->BK2_CODLAN := "01"
				BK2->BK2_DATREA	:= dDataBase
			BK2->(MsUnlock())
		Else
			lAlt := .F.
		EndIf
	EndIf

	If !lAlt
		DisarmTransaction()
	EndIf

End Transaction

If !lAlt
	If(!lAutomato,MsgAlert("Houve um problema para realizar a alteração!"),) // Houve um problema para realizar a alteração!
Else
	If(!lAutomato,MsgAlert("Alterado com sucesso!"),) // Alterado com sucesso!
EndIf

RestArea(aArea)

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL260ABASMVC
Emite titulo de abatimento sobre o saldo
@author  DEV TOTVS
@since   13/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PL260ABASMVC(lAutomato)

Local cNumero
Local cPrefixo		:= 	GetNewPar("MV_PLPREE1","PLS")
Local cTipTit 		:= 	SuperGetMv("MV_PLSTIP", .F., "DP ")
Local cNatureza		:= 	SuperGetMv("MV_PLSNAT", .F., "PLS")

Local aBK2			:= {}
Local aCpoSE1 		:= {}
Local aDadB78 		:= {}
Local aBases  		:= {0,0,0,0,0,0}

Local lRet      	:= 	.f.
Local lContabiliza 	:= 	.F.
Local lNcc			:=	.F.
local lErro         := .f.

Local oSaldo   		:= 	Nil
Local oVlrRea		:=	Nil
Local oVlrTot		:=	Nil
Local oMesRef		:= 	Nil
Local oAnoRef		:= 	Nil
Local oValor		:= 	Nil
Local nOpcA		
Local nCntFor		:= 0
Local nSaldo   		:= 	0
Local nValSal   	:= 	0
Local nVlrRea		:= 	0
Local nVlrTot		:= 	0
Local nValTot		:= 	0
Local nFor			:= 	0
Local nValor		:= 	0
Local nVlrReaAux	:=	0
Local nTotVal		:= 	0

Local cMesBK2		:= 	""
Local cAnoBK2		:= 	""
Local cTipo			:= 	""
Local cSQL			:= 	""
Local cAno			:= StrZero(Year(dDataBase),4)
Local cMes			:= StrZero(Month(dDataBase),2)
Local nSalario		:= RetSalPar( cAno, cMes )

Local MV_PAR05Aux	:= MV_PAR05
Local MV_PAR06Aux	:= MV_PAR06

Private MV_PAR05	:= ""
Private MV_PAR06	:= ""

Default  lAutomato := .F.

//Posiciona na familia do usuario
BA3->( dbSetorder(01) )
BA3->( MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))

cSQL := "SELECT BK2_CODINT,   BK2_CODEMP,   BK2_MATRIC,   BK2_TIPREG,   BK2_DIGITO,   BK2_MES, BK2_ANO,   BK2_DATREA,   BK2_SALDO"
cSQL += "FROM "+RetSqlName("BK2")+" WHERE "
cSQL += "BK2_FILIAL = 	'"+xFilial("BK2")+"' AND "
cSQL += "BK2_CODINT = 	'"+BA3->BA3_CODINT+"' AND "
cSQL += "BK2_CODEMP = 	'"+BA3->BA3_CODEMP+"' AND "
cSQL += "BK2_MATRIC = 	'"+BA3->BA3_MATRIC+"' AND "
cSQL += "BK2_PARCEL	<> 	'S' AND " // Diferente de parcelado
// cSQL += "BK2_NUMTIT	<> 	' ' AND " // Diferente de parcelado
cSQL += "(BK2_SALDO	> 0 OR BK2_SALDO2	> 0) AND "
cSQL += "D_E_L_E_T_ = ' '"

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"PLSBUSBK2",.F.,.T.)

PLSBUSBK2->(DBEval({ | | nTotVal += PLSBUSBK2->BK2_SALDO , cMesBK2	:= 	PLSBUSBK2->BK2_MES, cAnoBK2:= 	PLSBUSBK2->BK2_ANO} ))//Busco o valor total da familia
PLSBUSBK2->(DbGoTop())

If nTotVal <= 0
	MsgAlert("Não há dados para selecionar") // Não há dadso para selecionar
	PLSBUSBK2->(DbCloseArea())
	Return(.T.)
EndIf


dDataAux	:= StoD(cAnoBK2+cMesBK2+"01") - 1
cMesAmo		:= StrZero(Month(dDataAux),2)
cAnoAmo     := StrZero(Year(dDataAux),4)

DbSelectArea("BA1")

While !PLSBUSBK2->(EoF())

	BA1->(DbSetOrder(2))//BA1_FILIAL, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO
	If BA1->(MsSeek(xFilial("BA1")+PLSBUSBK2->(BK2_CODINT+BK2_CODEMP+BK2_MATRIC+BK2_TIPREG+BK2_DIGITO)))

		nPerPar := 0
		nVlrPar := 0
		nQtsMes := 0

		DbSelectArea("B81")
 		If B81->(MsSeek(xFilial("B81")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
        	While 	!B81->(EoF()) .And.;
        			xFilial("B81")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB) ==;
        			B81->(B81_FILIAL+B81_CODINT+B81_CODEMP+B81_CONEMP+B81_VERCON+B81_SUBCON+B81_VERSUB)

  		    	If dDataBase >= B81->B81_VIGPA .And. (dDataBase <= B81_VIGFIM .Or. Empty(B81_VIGFIM))
  		        	nPerPar := B81->B81_PERPAR
  		        	nVlrPar := B81->B81_VLRPAR
  		        	nQtsMes := B81->B81_QTSMES
  		        	Exit
  		    	EndIf
  				B81->(DbSkip())
  			EndDo
  		EndIf

		nSaldo 		+= 	PLSBUSBK2->BK2_SALDO
		dDataAnt	:=	StoD(PLSBUSBK2->BK2_DATREA)
		// Caso nao tenha data do ultimo reajuste considero 30 dias atras
		dDataAnt 	:= Iif( EmPty(dDataAnt), DaySub(dDataBase,30), dDataAnt )

		MV_PAR05	:= StrZero(Month(dDataBase),2)
		MV_PAR06	:= StrZero(Year(dDataBase),4)

		// Calculo o valor do reajuste
		CalJurSa(	0,		   			PLSBUSBK2->BK2_SALDO,  		PLSBUSBK2->BK2_SALDO,		@nVlrReaAux,;
					nTotVal,			nSalario,  					nPerPar,					nVlrPar,;
					B81->B81_QTSMES,	dDataAnt,	   				BA1->BA1_TREGRA,   			0,;
					BA1->BA1_VLRFIX,	BA1->BA1_ANOLIQ,			BA1->BA1_MESLIQ)


		nVlrRea		+= 	nVlrReaAux
		nVlrReaAux	:= 	0

		MV_PAR05	:= MV_PAR05Aux
		MV_PAR06	:= MV_PAR06Aux

	EndIf

	PLSBUSBK2->(DbSkip())

EndDo

PLSBUSBK2->(DbCloseArea())

nVlrTot	:= 	nSaldo+nVlrRea

If !lAutomato
	DEFINE MSDIALOG oDlg FROM 0,0 To 260,500 TITLE "Abatimento de saldo" PIXEL  //"Abatimento de saldo"

	@ 015,015		SAY 	"Saldo" 	   					SIZE 060,009 OF oDlg PIXEL // "Saldo"
	@ 015,060		MSGET 	oSaldo 							Var nSaldo SIZE  050,010 OF oDlg PIXEL;
					PICTURE "@E 99,999,999.99"				WHEN 	.F. ;

	@ 015,140		SAY 	"Vlr. Reajuste"							SIZE 060,009 OF oDlg PIXEL // "Vlr. Reajuste"
	@ 015,185		MSGET 	oVlrRea 							Var nVlrRea SIZE  050,010 OF oDlg PIXEL;
					PICTURE "@E 99,999,999.99"				WHEN 	.T. ;
					Valid 	nVlrRea>=0 .AND. (nVlrTot := nSaldo + nVlrRea)// Atualizo o saldo

	@ 035,015		SAY 	"Valor total"		 					SIZE 060,009 OF oDlg PIXEL // "Valor total"
	@ 035,060		MSGET 	oVlrTot  	   					Var nVlrTot SIZE  050,010 OF oDlg PIXEL;
					PICTURE "@E 99,999,999.99"				WHEN 	.F. ;

	@ 052,015		SAY 	"Mês referência"			 				SIZE 060,009 OF oDlg PIXEL // "Mês referência"
	@ 052,060		MSGET 	oMesRef  	   					Var cMesBK2 SIZE  010,010 OF oDlg PIXEL;
					WHEN 	.F. ;

	@ 052,140		SAY 	"Ano referência"			 				SIZE 060,009 OF oDlg PIXEL // "Ano referência"
	@ 052,185		MSGET 	oAnoRef  						Var cAnoBK2 SIZE  015,010 OF oDlg PIXEL;
					WHEN 	.F. ;

	@ 072,015		SAY 	"Valor" 						SIZE 060,009 OF oDlg PIXEL // "Valor"
	@ 072,060		MSGET 	oValor  						Var nValor SIZE  050,010 OF oDlg PIXEL;
					PICTURE "@E 99,999,999.99" 				WHEN 	.T. ;
					Valid 	nValor>=0 .AND. nValor <= nVlrTot

	@ 072,140		SAY 	"Tipo"	 	   					SIZE 060,009 OF oDlg PIXEL // "Tipo"
	@ 072,185 	COMBOBOX cTipo 	ITEMS 	{"Pagar","Receber"}	WHEN .T.	SIZE 050,010 PIXEL OF oDlg // "Pagar" // "Receber"

	DEFINE SBUTTON FROM 102,065 TYPE 1 ACTION (nOpcA := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 102,165 TYPE 2 ACTION (nOpcA := 0,oDlg:End()) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpcA == 0
		Return(.T.)
	EndIf
Else
	nValor:= 100

EndIf


If nValor == 0
    MsgAlert("Preencha o valor!") // "Preencha o valor!"
	Return(.F.)
EndIf

lNCC := ( cTipo == "Receber" )

//Posiciona na operadora origem para pegar o cliente...               
aRet := PLSRETNCB(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,BA3->BA3_CODINT)

If Len(aRet) > 0 .and. aRet[1]

   	cNumero := PLSE1NUM(cPrefixo)

   	aadd(aCpoSE1, {"E1_PREFIXO", cPrefixo, nil } )
   	aadd(aCpoSE1, {'E1_SERIE', cPrefixo, nil } )
   	aadd(aCpoSE1, {"E1_NUM", cNumero, nil } )
   	aadd(aCpoSE1, {'E1_PARCELA', '', nil } )
   	aadd(aCpoSE1, {"E1_TIPO", Iif( lNCC, "NCC", cTipTit), nil } )
   	aadd(aCpoSE1, {"E1_NATUREZ", cNatureza, nil } )
   	aadd(aCpoSE1, {"E1_CLIENTE", aRet[2], nil } )
   	aadd(aCpoSE1, {"E1_LOJA", aRet[3], nil } )
   	aadd(aCpoSE1, {'E1_NUMBCO', "", nil } )
   	aadd(aCpoSE1, {'E1_PLNUCOB', "", nil } )
   	aadd(aCpoSE1, {'E1_ORIGEM', "PLSA260", nil } )
   	aadd(aCpoSE1, {"E1_VENCTO", dDataBase, nil } )
   	aadd(aCpoSE1, {"E1_VENCREA", DataValida(dDataBase), nil } )
   	aadd(aCpoSE1, {"E1_EMISSAO", dDataBase, nil } )
   	aadd(aCpoSE1, {"E1_VALOR", nValor, nil } )
   	aadd(aCpoSE1, {"E1_SALDO", nValor, nil } )
   	aadd(aCpoSE1, {'E1_ROTINA', "FINA040", nil } )
   	aadd(aCpoSE1, {"E1_MULTNAT", "2", nil } )

	aadd(aCpoSE1, {'E1_CODINT', BA3->BA3_CODINT, nil } )
   	aadd(aCpoSE1, {'E1_CODEMP', BA3->BA3_CODEMP, nil } )
	aadd(aCpoSE1, {'E1_MATRIC', BA3->BA3_MATRIC, nil} )
   	aadd(aCpoSE1, {'E1_CODCOR', BA3->BA3_CODVEN, nil } )

   	aadd(aCpoSE1, {"E1_ANOBASE"  , cAno, nil } )
   	aadd(aCpoSE1, {"E1_MESBASE"  , cMes, nil } )
   
    // Incia a geracao do titulo e baixa do saldo
   	Begin Transaction

   		// Gera o titulo
   		lErro := PLStoSe1(aCpoSE1, aBases, cMes, cAno, "PLSMPAG", lContabiliza,,, cPrefixo, cNumero,, lNCC)

        if ! lErro
            // Abatimento de saldo
            DbSelectArea("BK2")
            BK2->(DbSetOrder(2))
            
            If 	BK2->(MsSeek(xFilial("BK2")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+cAnoBK2+cMesBK2))

                While !BK2->(EoF()) .And. 	BK2->(BK2_FILIAL+BK2_CODINT+BK2_CODEMP+BK2_MATRIC+BK2_ANO+BK2_MES) ==;
                                            xFilial("BK2")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+cAnoBK2+cMesBK2

                    AaDd(aBK2,{BK2->(BK2_FILIAL+BK2_CODINT+BK2_CODEMP+BK2_MATRIC+BK2_TIPREG+BK2_DIGITO+BK2_TIPLAN+BK2_CODLAN+BK2_ANO+BK2_MES),BK2->BK2_SALDO})
                    nValTot += BK2->BK2_SALDO

                    BK2->(DbSkip())

                EndDo

            EndIf

            nValTotAcu := 0
            DbSelectArea("B78")
            BK2->(DbSetOrder(1))//BK2_FILIAL, BK2_CODINT, BK2_CODEMP, BK2_MATRIC, BK2_TIPREG, BK2_DIGITO, BK2_TIPLAN, BK2_CODLAN, BK2_ANO, BK2_MES
            
            For nFor := 1 To Len(aBK2)

                If 	BK2->(MsSeek(aBK2[nFor,01]))
            
                    // Reduzo o saldo aplicando a proporcionalidade e adicionando o reajuste
                    If lNcc
                        nValSal	:= NOROUND(BK2->BK2_SALDO + (nValor * (aBK2[nFor,02]/nValTot)) + (nVlrRea * (aBK2[nFor,02]/nValTot)),2)
                    Else
                        nValSal	:= NOROUND(BK2->BK2_SALDO - (nValor * (aBK2[nFor,02]/nValTot)) + (nVlrRea * (aBK2[nFor,02]/nValTot)),2)
                    EndIf

                    nValTotAcu+=nValSal
                    
                    BK2->(RecLock("BK2",.F.))
                        BK2->BK2_SALDO 	:= If(nValSal >= BK2->BK2_SALDO,0,nValSal)
                        BK2->BK2_DATREA	:= dDataBase
                    BK2->(MsUnlock())
                    
                    If  nFor == Len(aBK2)
                        
                        nArred := (nValTot-nValor) - nValTotAcu
                        If nArred >= 0
                            BK2->(RecLock("BK2",.F.))
                            BK2->BK2_SALDO 	+=  nArred
                            BK2->(MsUnlock())
                        Endif 
                        
                        nValTotAcu += nArred

                        B78->(RecLock("B78",.T.))
                        
                            // Gero o historico deste lancamento
                            B78->B78_FILIAL	:= 	xFilial("B78")
                            B78->B78_CODINT	:=	BK2->BK2_CODINT
                            B78->B78_CODEMP	:=	BK2->BK2_CODEMP
                            B78->B78_MATRIC	:=	BK2->BK2_MATRIC
                            B78->B78_TIPREG	:=	BK2->BK2_TIPREG
                            B78->B78_MESBAS	:=	cMesBK2
                            B78->B78_ANOBAS	:=	cAnoBK2
                            B78->B78_TIPOPE	:= 	Iif(lNcc,"4","2")
                            B78->B78_PREFIX	:= 	cPrefixo
                            B78->B78_NUM 	:= 	cNumero
                            B78->B78_PARCEL	:= 	''
                            B78->B78_TIPO 	:= 	Iif(lNcc,"NCC",cTipTit)
                            B78->B78_VALOR 	:= 	nValor //* (aBK2[nFor,02]/nValTot)
                            B78->B78_VALACU	:= 	nValTotAcu 
                            B78->B78_VALREA	:=	nVlrRea
                            
                            B78->(MsUnlock())

                    Endif

                EndIf

            Next nFor

        endIf

    End Transaction
    
    if ! lErro
        lRet := .T.
        If(!lAutomato,MsgAlert("Processamento realizado com sucesso!"),) //"Processamento realizado com sucesso!"
    endIf

Else
	If(!lAutomato,MsgAlert("Não encaontrado o nível de cobrança da família!"),) //"Não encaontrado o nível de cobrança da família!"
	lRet := .F.
Endif

Return(lRet)