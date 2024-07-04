#INCLUDE "Protheus.CH"
#INCLUDE "FwMVCDef.CH"
#INCLUDE "TAFA465.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA465

Cadastro MVC de Informa��es de identifica��o do registrador da CAT

@Author	Paulo V.B. Santana
@Since		05/01/2017
@Version	1.0
 
/*/
//------------------------------------------------------------------
Function TAFA465()

Local oBrw := FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Codifica��o de Acidente de Trabalho"
oBrw:SetAlias( "T5G" )
oBrw:SetMenuDef( "TAFA465" )
T5G->( DBSetOrder( 1 ) )
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@Author	Paulo V.B. Santana
@Since		05/01/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return xFunMnuTAF( "TAFA465",,,, .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@Return oModel - Objeto do Modelo MVC

@Author	Paulo V.B. Santana
@Since		05/01/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT5G := FwFormStruct( 1, "T5G" )
Local oModel   := MpFormModel():New( "TAFA465" )

oModel:AddFields( "MODEL_T5G", /*cOwner*/, oStruT5G )
oModel:GetModel ( "MODEL_T5G" ):SetPrimaryKey( { "T5G_FILIAL", "T5G_ID" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@Return oView - Objeto da View MVC

@Author	Paulo V.B. Santana
@Since		05/01/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel( "TAFA465" )
Local oStruT5G := FwFormStruct( 2, "T5G" )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_T5G", oStruT5G, "MODEL_T5G" )
oView:EnableTitleView( "VIEW_T5G", STR0001 ) //"Tipos de Benef�cios Previdenci�rios dos Regimes Pr�prios de Previd�ncia"
oView:CreateHorizontalBox( "FIELDST5G", 100 )
oView:SetOwnerView( "VIEW_T5G", "FIELDST5G" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida:
T5G - (Tipos Benef. Previdenci�rios  ) 
Tipos de Benef�cios Previdenci�rios dos Regimes Pr�prios de Previd�ncia

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Author	Paulo Vilas Boas Santana
@Since		05/01/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1013

If nVerEmp < nVerAtu
	aAdd( aHeader, "T5G_FILIAL" )
	aAdd( aHeader, "T5G_ID" )
	aAdd( aHeader, "T5G_CODIGO" )
	aAdd( aHeader, "T5G_DESCRI" )
	aAdd( aHeader, "T5G_VALIDA" )

	aAdd( aBody, { " ", "000001","01","Aposentadoria Volunt�ria por Idade e Tempo de Contribui��o - Proventos Integrais: Art. 40, � 1�, III 'a' da CF, Reda��o EC 20/98", " " } )
	aAdd( aBody, { " ", "000002","02","Aposentadoria por Idade - Proventos proporcionais: Art. 40, III, c da CF reda��o original - Anterior � EC 20/1998", " " } )
	aAdd( aBody, { " ", "000003","03","Aposentadoria por Invalidez - Proventos integrais ou proporcionais: Art. 40, I da CF reda��o original - anterior � EC 20/1998", " " } )
	aAdd( aBody, { " ", "000004","04","Aposentadoria Compuls�ria - Proventos proporcionais: Art. 40, II da CF reda��o original, anterior � EC 20/1998 *", " " } )
	aAdd( aBody, { " ", "000005","05","Aposentadoria por Tempo de Servi�o Integral - Art. 40, III, a da CF reda��o original - anterior � EC 20/1998 *", " " } )
	aAdd( aBody, { " ", "000006","06","Aposentadoria por Tempo de Servi�o Proporcional - Art. 40, III, a da CF reda��o original - anterior � EC 20/1998 *", " " } )
	aAdd( aBody, { " ", "000007","07","Aposentadoria Compuls�ria Proporcional calculada sobre a �ltima remunera��o- Art. 40, � 1�, Inciso II da CF, Reda��o EC 20/1998", " " } )
	aAdd( aBody, { " ", "000008","08","Aposentadoria Compuls�ria Proporcional calculada pela m�dia - Art. 40, � 1� Inciso II da CF, Reda��o EC 41/03", " " } )
	aAdd( aBody, { " ", "000009","09","Aposentadoria Compuls�ria Proporcional calculada pela m�dia - Art. 40, � 1� Inciso II da CF, Reda��o EC 41/03, c/c EC 88/2015", " " } )
	aAdd( aBody, { " ", "000010","10","Aposentadoria Compuls�ria Proporcional calculada pela m�dia - Art. 40, � 1� Inciso II da CF, Reda��o EC 41/03, c/c LC 152/2015", " " } )
	aAdd( aBody, { " ", "000011","11","Aposentadoria - Magistrado, Membro do MP e TC - Proventos Integrais correspondentes � �ltima remunera��o: Regra de Transi��o do Art. 8�, da EC 20/98", " " } )
	aAdd( aBody, { " ", "000012","12","Aposentadoria - Proventos Integrais correspondentes � �ltima remunera��o - Regra de Transi��o do Art. 8�, da EC 20/98: Geral", " " } )
	aAdd( aBody, { " ", "000013","13","Aposentadoria Especial do Professor - Regra de Transi��o do Art. 8�, da EC 20/98: Proventos Integrais correspondentes � �ltima remunera��o.", " " } )
	aAdd( aBody, { " ", "000014","14","Aposentadoria com proventos proporcionais calculados sobre a �ltima remunera��oRegra de Transi��o do Art. 8�, da EC20/98 - Geral", " " } )
	aAdd( aBody, { " ", "000015","15","Aposentadoria - Regra de Transi��o do Art. 3�, da EC 47/05: Proventos Integrais correspondentes � �ltima remunera��o", " " } )
	aAdd( aBody, { " ", "000016","16","Aposentadoria Especial de Professor - Regra de Transi��o do Art. 2�, da EC41/03: Proventos pela M�dia com redutor (Implementa��o a partir de 01/01/2006)", " " } )
	aAdd( aBody, { " ", "000017","17","Aposentadoria Especial de Professor - Regra de Transi��o do Art. 2�, da EC41/03: Proventos pela M�dia com redutor (Implementa��o at� 31/12/2005)", " " } )
	aAdd( aBody, { " ", "000018","18","Aposentadoria Magistrado, Membro do MP e TC (homem) - Regra de Transi��o do Art. 2�, da EC41/03: Proventos pela M�dia com redutor (Implementa��o a partir de 01/01/2006)", " " } )
	aAdd( aBody, { " ", "000019","19","Aposentadoria Magistrado, Membro do MP e TC - Regra de Transi��o do Art. 2�, da EC41/03: Proventos pela M�dia com redutor (Implementa��o at� 31/12/2005)", " " } )
	aAdd( aBody, { " ", "000020","20","Aposentadoria Volunt�ria - Regra de Transi��o do Art. 2�, da EC 41/03 - Proventos pela M�dia com redutor - Geral (Implementa��o a partir de 01/01/2006)", " " } )
	aAdd( aBody, { " ", "000021","21","Aposentadoria Volunt�ria - Regra de Transi��o do Art. 2�, da EC 41/03 - Proventos pela M�dia reduzida - Geral (Implementa��o at� 31/12/2005)", " " } )
	aAdd( aBody, { " ", "000022","22","Aposentadoria Volunt�ria - Regra de Transi��o do Art. 6�, da EC41/03: Proventos Integrais correspondentes � ultima remunera��o do cargo - Geral", " " } )
	aAdd( aBody, { " ", "000023","23","Aposentadoria Volunt�ria Professor Educa��o infantil, ensino fundamental e m�dioRegra de Transi��o do Art. 6�, da EC41/03: Proventos Integrais correspondentes � �ltima remunera��o do cargo", " " } )
	aAdd( aBody, { " ", "000024","24","Aposentadoria Volunt�ria por Idade - Proventos Proporcionais calculados sobre a �ltima remunera��o do cargo: Art. 40, � 1�, Inciso III, al�nea 'b'' CF, Reda��o EC 20/98", " " } )
	aAdd( aBody, { " ", "000025","25","Aposentadoria Volunt�ria por Idade - Proventos pela M�dia proporcionais - Art. 40, � 1�, Inciso III, al�nea 'b' CF, Reda��o EC 41/03", " " } )
	aAdd( aBody, { " ", "000026","26","Aposentadoria Volunt�ria por Idade e por Tempo de Contribui��o - Proventos pela M�dia: Art. 40, � 1�, Inciso III, aliena 'a', CF, Reda��o eC 41/03", " " } )
	aAdd( aBody, { " ", "000027","27","Aposentadoria Volunt�ria por Tempo de Contribui��o - Especial do professor de q/q n�vel de ensino - Art. 40, III, al�nea b, da CF- Red. Original at� EC 20/1998", " " } )
	aAdd( aBody, { " ", "000028","28","Aposentadoria Volunt�ria por idade e Tempo de Contribui��o - Especial do professor ed. infantil, ensino fundamental e m�dio - Art. 40, � 1�, Inciso III, al�nea a, c/c � 5� da CF red. da EC 20/1998 )", " " } )
	aAdd( aBody, { " ", "000029","29","Aposentadoria Volunt�ria por idade e Tempo de Contribui��o - Especial de Professor - Proventos pela M�dia: Art. 40, � 1�, Inciso III, al�nea 'a', C/C � 5� da CF, Reda��o EC 41/2003", " " } )
	aAdd( aBody, { " ", "000030","30","Aposentadoria por Invalidez (proporcionais ou integrais, calculadas com base na �ltima remunera��o do cargo) - Art. 40, Inciso I, Reda��o Original, CF", " " } )
	aAdd( aBody, { " ", "000031","31","Aposentadoria por Invalidez (proporcionais ou integrais , calculadas com base na �ltima remunera��o do cargo) - Art. 40, � 1�, Inciso I da CF com Reda��o da EC 20/1998", " " } )
	aAdd( aBody, { " ", "000032","32","Aposentadoria por Invalidez (proporcionais ou integrais, calculadas pela m�dia) - Art. 40, � 1�, Inciso I da CF com Reda��o da EC 41/2003", " " } )
	aAdd( aBody, { " ", "000033","33","Aposentadoria por Invalidez (proporcionais ou integrais calculadas com base na �ltima remunera��o do cargo) -Art. 40 � 1�, Inciso I da CF C/C combinado com Art. 6a- A da EC 70/2012", " " } )
	aAdd( aBody, { " ", "000034","34","Reforma por invalidez", " " } )
	aAdd( aBody, { " ", "000035","35","Reserva Remunerada Compuls�ria", " " } )
	aAdd( aBody, { " ", "000036","36","Reserva Remunerada Integral", " " } )
	aAdd( aBody, { " ", "000037","37","Reserva Remunerada Proporcional", " " } )
	aAdd( aBody, { " ", "000038","38","Aux�lio Doen�a - Conforme lei do Ente", " " } )
	aAdd( aBody, { " ", "000039","39","Aux�lio Reclus�o - Art. 13 da EC 20/1998 c/c lei do Ente", " " } )
	aAdd( aBody, { " ", "000040","40","Pens�o por Morte", " " } )
	aAdd( aBody, { " ", "000041","41","Sal�rio Fam�lia - Art. 13 da EC 20/1998 c/c lei do Ente", " " } )
	aAdd( aBody, { " ", "000042","42","Sal�rio Maternidade - Art. 7�, XVIII c/c art. 39, � 3� da Constitui��o Federal", " " } )
	aAdd( aBody, { " ", "000043","43","Complementa��o de Aposentadoria do Regime Geral de Previd�ncia Social (RGPS)", " " } )
	aAdd( aBody, { " ", "000044","44","Complementa��o de Pens�o por Morte do Regime Geral de Previd�ncia Social (RGPS)", " " } )
	aAdd( aBody, { " ", "000045","91","Aposentadoria sem paridade concedida antes do in�cio de vig�ncia do eSocial", " " } )
	aAdd( aBody, { " ", "000046","92","Aposentadoria com paridade concedida antes do in�cio de vig�ncia do eSocial", " " } )
	aAdd( aBody, { " ", "000047","93","Aposentadoria por invalidez com paridade concedida antes do in�cio de vig�ncia do eSocial", " " } )
	aAdd( aBody, { " ", "000048","94","Aposentadoria por invalidez sem paridade concedida antes do in�cio de vig�ncia do eSocial", " " } )
	aAdd( aBody, { " ", "000049","95","Transfer�ncia para reserva concedida antes do in�cio de vig�ncia do eSocial", " " } )
	aAdd( aBody, { " ", "000050","96","Reforma concedida antes do in�cio de vig�ncia do eSocial", " " } )
	aAdd( aBody, { " ", "000051","97","Pens�o por morte com paridade concedida antes do in�cio de vig�ncia do eSocial", " " } )
	aAdd( aBody, { " ", "000052","98","Pens�o por morte sem paridade concedida antes do in�cio de vig�ncia do eSocial", " " } )
	aAdd( aBody, { " ", "000053","99","Outros Benef�cios previdenci�rios concedidos antes do in�cio de vig�ncia do eSocial", " " } )	

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )