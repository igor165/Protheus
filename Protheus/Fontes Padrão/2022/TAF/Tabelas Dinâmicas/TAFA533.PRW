#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA533.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA533
MVC DA TABELA AUTO CONTIDA V3O-NATUREZA DE RENDIMENTO

@author Katielly Feitosa Rezende
@since 06/05/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA533()
Local	oBrw		:=	FWmBrowse():New()

If AliasIndic("V3O")
    oBrw:SetDescription(STR0001)    //"Cadastros das Naturezas de rendimento "
    oBrw:SetAlias( 'V3O')
    oBrw:SetMenuDef( 'TAFA533' )
    V3O->(DbSetOrder(1))
    oBrw:Activate()
Else
	Alert(STR0002)  //"Tabela V3O n�o existe."
EndIF

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC para o menu
@author Katielly Feitosa Rezende
@since 06/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA533" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Katielly Feitosa Rezende
@since 06/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruV3O 	:= 	FWFormStruct( 1, 'V3O' )
Local oModel 	:= 	MPFormModel():New( 'TAFA533' )

oModel:AddFields('MODEL_V3O', /*cOwner*/, oStruV3O)
oModel:GetModel('MODEL_V3O'):SetPrimaryKey({'V3O_FILIAL','V3O_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Katielly Feitosa Rezende
@since 06/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA533' )
Local 	oStruV3O	:= 	FWFormStruct( 2, 'V3O' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_V3O', oStruV3O, 'MODEL_V3O' )

oView:EnableTitleView( 'VIEW_V3O',STR0003)  //"Natureza de Rendimento"
oView:CreateHorizontalBox( 'FIELDSV3O', 100 )
oView:SetOwnerView( 'VIEW_V3O', 'FIELDSV3O' )

Return oView	

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Autor Katielly Feitosa Rezende
@Since		06/05/2019
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1028
If AliasIndic("V3O")
	If nVerEmp < nVerAtu 
        
        aAdd( aHeader, "V3O_FILIAL" ) 
        aAdd( aHeader, "V3O_ID" ) 
        aAdd( aHeader, "V3O_CODIGO" )
        aAdd( aHeader, "V3O_DESCR" )
        aAdd( aHeader, "V3O_FCI" )
        aAdd( aHeader, "V3O_DECSAL" )
        aAdd( aHeader, "V3O_RRA" )
        aAdd( aHeader, "V3O_CMPJUD" )
        aAdd( aHeader, "V3O_DEDUC" ) 
        aAdd( aHeader, "V3O_ISENTO" ) 
        aAdd( aHeader, "V3O_BENNAC" ) 
        aAdd( aHeader, "V3O_BENEXT" )
        aAdd( aHeader, "V3O_TRIB" )

        aAdd( aBody, { "", "000001", "000000001", "Decorrente de Decis�o da Justi�a do Trabalho" , "2", "1", "1", "1", "1,5,6", "2,3,4,5,7,8,99", "3", "3", "1"})
        aAdd( aBody, { "", "000002", "000000002", "Decorrente de Decis�o da Justi�a Federal", "2", "1", "1", "1", "1,2,3,4,5,6,7", "1,2,3,4,5,6,7,8,99", "3", "3", "1"})
        aAdd( aBody, { "", "000003", "000000003", "Decorrente de Decis�o da Justi�a dos Estados/Distrito Federal", "2", "1", "1", "1", "1,2,3,4,5,6,7", "1,2,3,4,5,6,7,8,99", "3", "3", "1"})
        aAdd( aBody, { "", "000004", "000000004", "Honor�rios advocat�cios de sucumb�ncia pelos advogados e procuradores p�blicos deque trata o art. 27 da Lei n� 13.327", "2", "2", "1", "1", "1,2,3,4,5,6,7",, "1", "1", "1"})
        aAdd( aBody, { "", "000005", "000000005", "Benef�cio do Regime Geral de Previd�ncia Social", "2", "1", "1", "1", "1,2,3,4,5,6,7", "1,6", "1", "1","1"})
        aAdd( aBody, { "", "000006", "000000006", "Lucro e Dividendo", "2", "2", "2", "2", , , "3", "3", })
        aAdd( aBody, { "", "000007", "000000007", "Resgate de Previd�ncia Complementar - Modalidade Contribui��o Definida/Vari�vel - N�o Optante pela Tributa��o Exclusiva", "1", "2", "2", "1", , "7", "1", "1", "1"})
        aAdd( aBody, { "", "000008", "000000008", "Resgate de Fundo de Aposentadoria Programada Individual (Fapi)- N�o Optante pela Tributa��o Exclusiva", "1", "2", "2", "1",  , "7", "1", "1", "1"})
        aAdd( aBody, { "", "000009", "000000009", "Resgate de Previd�ncia Complementar - Modalidade Benef�cio Definido - N�o Optante pela Tributa��o Exclusiva", "1", "2", "2", "1",  , "7", "1", "1", "1"})
        aAdd( aBody, { "", "000010", "000000010", "Resgate de Previd�ncia Complementar - Modalidade Contribui��o Definida/Vari�vel - Optante pela Tributa��o Exclusiva", "1", "2", "2", "2",, "7", "1", "1","1"})
        aAdd( aBody, { "", "000011", "000000011", "Resgate de Fundo de Aposentadoria Programada Individual (Fapi)- Optante pela Tributa��o Exclusiva", "1", "2", "2", "2", , "7", "1", "1", "1"})
        aAdd( aBody, { "", "000012", "000000012", "Resgate de Planos de Seguro de Vida com Cl�usula de Cobertura por Sobreviv�ncia- Optante pela Tributa��o Exclusiva", "1", "2", "2", "2",,, "1", "1", "1"})
        aAdd( aBody, { "", "000013", "000000013", "Resgate de Planos de Seguro de Vida com Cl�usula de Cobertura por Sobreviv�ncia - N�o Optante pela Tributa��o Exclusiva", "2", "2", "2", "1",,, "1", "1", "1"})
        aAdd( aBody, { "", "000014", "000000014", "Benef�cio de Previd�ncia Complementar - Modalidade Contribui��o Definida/Vari�vel - N�o Optante pela Tributa��o Exclusiva", "1", "1", "1", "1", "2,3,4,5,6,7", "1,6,7,99", "1",  "1", "1"})
        aAdd( aBody, { "", "000015", "000000015", "Benef�cio de Fundo de Aposentadoria Programada Individual (Fapi)- N�o Optante pela Tributa��o Exclusiva", "1", "1", "1", "1", "2,3,4,5,6,7", "1,6,7,99", "1", "1", "1"})
        aAdd( aBody, { "", "000016", "000000016", "Benef�cio de Previd�ncia Complementar - Modalidade Benef�cio Definido - N�o Optante pela Tributa��o Exclusiva", "1", "1", "1", "1", "2,3,4,5,6,7", "1,6,7,99", "1", "1", "1"})
        aAdd( aBody, { "", "000017", "000000017", "Benef�cio de Previd�ncia Complementar - Modalidade Contribui��o Definida/Vari�vel - Optante pela Tributa��o Exclusiva", "1", "1", "1", "2",, "6,7", "1", "1", "1"})
        aAdd( aBody, { "", "000018", "000000018", "Benef�cio de Fundo de Aposentadoria Programada Individual (Fapi)- Optante pela Tributa��o Exclusiva", "1", "1", "1", "2",, "6,7", "1", "1","1"})
        aAdd( aBody, { "", "000019", "000000019", "Benef�cio de Planos de Seguro de Vida com Cl�usula de Cobertura por Sobreviv�ncia- Optante pela Tributa��o Exclusiva", "1", "2", "2", "2",,, "1", "1", "1"})
        aAdd( aBody, { "", "000020", "000000020", "Benef�cio de Planos de Seguro de Vida com Cl�usula de Cobertura por Sobreviv�ncia - N�o Optante pela Tributa��o Exclusiva", "2", "2", "2", "1",,, "1", "1", "1"})
        aAdd( aBody, { "", "000021", "000000021", "Juros sobre o Capital Pr�prio", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000022", "000000022", "Rendimento de Aplica��es Financeiras de Renda Fixa, decorrentes de aliena��o, liquida��o (total ou parcial), resgate, cess�o ou repactua��o do t�tulo ou aplica��o", "2", "2", "2", "2",,,"3", "3", "1"})
        aAdd( aBody, { "", "000023", "000000023", "Rendimentos auferidos pela entrega de recursos � pessoa jur�dica", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000024", "000000024", "Rendimentos predeterminados obtidos em opera��es conjugadas realizadas: nos mercados de op��es de compra e venda em bolsas de valores, de mercadorias e de futuros (box); no mercado a termo nas bolsas de valores, de mercadorias e de futuros, em opera��es de venda coberta e sem ajustes di�rios, e no mercado de balc�o.", "2", "2", "2", "2",,,"3", "3", "1"})
        aAdd( aBody, { "", "000025", "000000025", "Rendimentos obtidos nas opera��es de transfer�ncia de d�vidas realizadas com institui��o financeira e outras institui��es autorizadas a funcionar pelo Banco Central do Brasil", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000026", "000000026", "Rendimentos peri�dicos produzidos por t�tulo ou aplica��o, bem como qualquer remunera��o adicional aos rendimentos prefixados", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000027", "000000027", "Rendimentos auferidos nas opera��es de m�tuo de recursos financeiros", "2", "2", "2", "2",,, "3", "3", "1"}) 
        aAdd( aBody, { "", "000028", "000000028", "Rendimentos auferidos em opera��es de adiantamento sobre contratos de c�mbio de exporta��o, n�o sacado (trava de c�mbio), bem como opera��es com export notes, com deb�ntures, com dep�sitos volunt�rios para garantia de inst�ncia e com dep�sitos judiciais ou administrativos, quando seu levantamento se der em favor do depositante", "2", "2", "2", "2",,,"3", "3", "1"})
        aAdd( aBody, { "", "000029", "000000029", "Rendimentos obtidos nas opera��es de m�tuo e de compra vinculada � revenda tendo por objeto ouro, ativo financeiro", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000030", "000000030", "Rendimentos auferidos em contas de dep�sitos de poupan�a", "2", "2", "2", "2",,, "2", "2", "1"})
        aAdd( aBody, { "", "000031", "000000031", "Rendimentos auferidos sobre juros produzidos por letras hipotec�rias", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000032", "000000032", "Rendimentos ou ganhos decorrentes da negocia��o de t�tulos ou valores mobili�rios de renda fixa em bolsas de valores, de mercadorias, de futuros e assemelhadas", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000033", "000000033", "Rendimentos auferidos em outras aplica��es financeiras de renda fixa ou de renda vari�vel", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000034", "000000034", "Rendimentos auferidos em Fundo de Investimento", "1", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000035", "000000035", "Rendimentos auferidos em Fundos de investimento em quotas de fundos de investimento", "1", "2", "2", "2",,,"3", "3", "1"})
        aAdd( aBody, { "", "000036", "000000036", "Rendimentos produzidos por aplica��es em fundos de investimento em a��es", "1", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000037", "000000037", "Rendimentos produzidos por aplica��es em fundos de investimento em quotas de fundos de investimento em a��es", "1", "2", "2" ,"2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000038", "000000038", "Rendimentos produzidos por aplica��es em Fundos M�tuos de Privatiza��o com recursos do Fundo de Garantia por Tempo de Servi�o (FGTS)", "1", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000039", "000000039", "Rendimentos auferidos pela carteira dos Fundos de Investimento Imobili�rio", "1", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000040", "000000040", "Rendimentos distribu�dos pelo Fundo de Investimento Imobili�rio aos seus cotistas", "1", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000041", "000000041", "Rendimento auferido pelo cotista no resgate de cotas na liquida��o do Fundo de Investimento Imobili�rio", "1", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000042", "000000042", "Rendimentos e ganhos de capital distribu�dos pelo Fundo de Investimento Cultural e Art�stico (Ficart)", "1", "2", "2", "2",,, "3", "3","1"})
        aAdd( aBody, { "", "000043", "000000043", "Rendimentos e ganhos de capital distribu�dos pelo Fundo de Financiamento da Ind�stria Cinematogr�fica Nacional (Funcines)", "1", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000044", "000000044", "Juros n�o especificados", "2","2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000045", "000000045", "Rendimentos auferidos no resgate de quotas de fundos de investimento mantidos com recursos provenientes de convers�o de d�bitos externos brasileiros, e de que participem, exclusivamente, residentes ou domiciliados no exterior", "1", "2", "2","2",,,"4", "3", "1"})
        aAdd( aBody, { "", "000046", "000000046", "Demais rendimentos de capital", "2", "2", "2", "2",,,"3", "3", "1"})
        aAdd( aBody, { "", "000047", "000000047", "Rendimentos  de Loca��o ou Subloca��o", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000048", "000000048", "Rendimentos  de Arrendamento ou Subarrendamento", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000049", "000000049", "Import�ncias pagas por terceiros por conta do locador do bem (juros, comiss�es etc.)", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000050", "000000050", "Import�ncias pagas ao locador pelo contrato celebrado (luvas, pr�mios etc.)", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000051", "000000051", "Benfeitorias e quaisquer melhoramentos realizados no bem locado", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000052", "000000052", "Juros decorrente da aliena��o a prazo de bens", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000053", "000000053", "Rendimentos de Direito de Uso ou Passagem de Terrenos e de aproveitamento de �guas", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000054", "000000054", "Rendimentos de Direito de explora��o de pel�culas cinematogr�ficas, Obras Audiovisuais, e Videof�nicas", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000055", "000000055", "Rendimentos de  Direito de Conjuntos Industriais e Inven��es", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000056", "000000056", "Rendimentos de Direito Autoral", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000057", "000000057", "Rendimentos de Direito Autoral (quando n�o percebidos pelo autor ou criador da obra)", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000058", "000000058", "Rendimentos de Direito de Imagem", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000059", "000000059", "Rendimentos de Direito de colher ou extrair recursos vegetais, pesquisar e extrair recursos minerais", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000060", "000000060", "Produto da aliena��o de marcas de ind�stria e com�rcio, patentes de inven��o e processo ou f�rmulas de fabrica��o", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000061", "000000061", "Import�ncias pagas por terceiros por conta do cedente dos direitos (juros, comiss�es etc.)", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000062", "000000062", "Import�ncias pagas ao cedente do direito, pelo contrato celebrado (luvas, pr�mios etc.)", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000063", "000000063", "Despesas para conserva��o dos direitos cedidos (quando compensadas pelo uso do bem ou direito)", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000064", "000000064", "Demais Royalties", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000065", "000000065", "Juros de mora e quaisquer outras compensa��es pelo atraso no pagamento de royalties", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000066", "000000066", "Juros decorrente da aliena��o a prazo de direitos", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000067", "000000067", "Ganho de capital decorrente da integraliza��o de cotas de fundos ou clubes de investimento por meio da entrega de ativos financeiros", "1","2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000068", "000000068", "Distribui��o de Juros sobre o Capital Pr�prio pela companhia emissora de a��es objeto de empr�stimo", "1", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000069", "000000069", "Rendimentos de Partes Benefici�rias ou de Fundador", "2", "2", "2", "1", "1,5,6",, "3", "3", "1"})
        aAdd( aBody, { "", "000070", "000000070", "Rendimentos auferidos em opera��es de swap", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000071", "000000071", "Rendimentos auferidos em opera��es day trade realizadas em bolsa de valores, de mercadorias, de futuros e assemelhadas", "2", "2", "2","2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000072", "000000072", "Rendimento decorrente de Opera��o realizada em bolsas de valores, de mercadorias, de futuros, e assemelhadas, exceto day trade", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000073", "000000073", "Rendimento decorrente de Opera��o realizada no mercado de balc�o, com intermedia��o, tendo por objeto a��es, ouro ativo financeiro e outros valores mobili�rios negociados no mercado � vista", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000074", "000000074", "Rendimento decorrente de Opera��o realizada em mercados de liquida��o futura fora de bolsa", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000075", "000000075", "Aliena��o de bens e direitos do ativo n�o circulante localizados no Brasil", "2", "2", "2", "2",,, "4", "2", "1"})
        aAdd( aBody, { "", "000076", "000000076", "Comiss�es, corretagens, ou qualquer outra import�ncia paga/creditada pela representa��o comercial ou pela media��o na realiza��o de neg�cios civis e comerciais", "2", "2", "2", "2",,, "2", "3", "1"})
        aAdd( aBody, { "", "000077", "000000077", "Rendimento de Servi�os de propaganda e publicidade", "2", "2", "2", "2",,, "2", "3", "1"})
        aAdd( aBody, { "", "000078", "000000078", "Pr�mios distribu�dos, sob a forma de bens e servi�os, mediante concursos e sorteios", "2", "2", "2", "2",,, "3", "3" , "1"})
        aAdd( aBody, { "", "000079", "000000079", "Pr�mios distribu�dos, sob a forma de dinheiro, mediante concursos e sorteios", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000080", "000000080", "Pr�mios de Propriet�rios e Criadores de Cavalos de Corrida", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000081", "000000081", "Benef�cios l�quidos resultantes da amortiza��o antecipada, mediante sorteio, dos t�tulos de capitaliza��o", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000082", "000000082", "Benef�cios atribu�dos aos portadores de t�tulos de capitaliza��o nos lucros da empresa emitente", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000083", "000000083", "Pr�mios distribu�dos, sob a forma de bens e servi�os, mediante sorteios de jogos de bingo permanente ou eventual", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000084", "000000084", "Pr�mios distribu�dos, em dinheiro, obtido mediante sorteios de jogos de bingo permanente ou eventual", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000085", "000000085", "Import�ncias correspondentes a multas e qualquer outra vantagem, ainda que a t�tulo de indeniza��o, em virtude de rescis�o de contrato", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000086", "000000086", "Responsabilidade Civil - juros e indeniza��es por lucros cessantes", "2", "1", "2", "2", "1,2,3,4,5,6,7",, "3", "3", "1"})
        aAdd( aBody, { "", "000087", "000000087", "Import�ncias pagas ou creditadas a cooperativas de trabalho, associa��es de profissionais ou assemelhadas, relativas a servi�os pessoais que lhes forem prestados por associados destas ou colocados � disposi��o", "2", "2", "2", "2",,, "2", "2", "1"}) 
        aAdd( aBody, { "", "000088", "000000088", "Remunera��o de Servi�os de administra��o de bens ou neg�cios em geral, exceto cons�rcios ou fundos m�tuos para aquisi��o de bens", "2", "2", "2", "2" ,,, "2", "2", "2"})
        aAdd( aBody, { "", "000089", "000000089", "Remunera��o de Servi�os de advocacia", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000090", "000000090", "Remunera��o de Servi�os de an�lise cl�nica laboratorial", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000091", "000000091", "Remunera��o de Servi�os de an�lises t�cnicas", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000092", "000000092", "Remunera��o de Servi�os de arquitetura", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000093", "000000093", "Remunera��o de Servi�os de assessoria e consultoria t�cnica, exceto servi�o de assist�ncia t�cnica prestado a terceiros e concernente a ramo de ind�stria ou com�rcio explorado pelo prestador do servi�o", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000094", "000000094", "Remunera��o de Servi�os de assist�ncia social", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000095", "000000095", "Remunera��o de Servi�os de auditoria", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000096", "000000096", "Remunera��o de Servi�os de avalia��o e per�cia", "2", "2", "2","2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000097", "000000097", "Remunera��o de Servi�os de  biologia e biomedicina", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000098", "000000098", "Remunera��o de Servi�os de c�lculo em geral", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000099", "000000099", "Remunera��o de Servi�os de consultoria", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000100", "000000100", "Remunera��o de Servi�os de contabilidade", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000101", "000000101", "Remunera��o de Servi�os de desenho t�cnico", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000102", "000000102", "Remunera��o de Servi�os de economia", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000103", "000000103", "Remunera��o de Servi�os de elabora��o de projetos", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000104", "000000104", "Remunera��o de Servi�os de engenharia, exceto constru��o de estradas, pontes, pr�dios e obras assemelhadas", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000105", "000000105", "Remunera��o de Servi�os de  ensino e treinamento", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000106", "000000106", "Remunera��o de Servi�os de estat�stica", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000107", "000000107", "Remunera��o de Servi�os de fisioterapia", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000108", "000000108", "Remunera��o de Servi�os de fonoaudiologia", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000109", "000000109", "Remunera��o de Servi�os de geologia", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000110", "000000110", "Remunera��o de Servi�os de leil�o",  "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000111", "000000111", "Remunera��o de Servi�os de  medicina, exceto aquela prestada por ambulat�rio, banco de sangue, casa de sa�de, casa de recupera��o ou repouso sob orienta��o m�dica, hospital e pronto-socorro", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000112", "000000112", "Remunera��o de Servi�os de nutricionismo e diet�tica", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000113", "000000113", "Remunera��o de Servi�os de odontologia", "2", "2", "2", "2",,, "2", "2","2"})
        aAdd( aBody, { "", "000114", "000000114", "Remunera��o de Servi�os de organiza��o de feiras de amostras, congressos, semin�rios, simp�sios e cong�neres", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000115", "000000115", "Remunera��o de Servi�os de pesquisa em geral", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000116", "000000116", "Remunera��o de Servi�os de planejamento", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000117", "000000117", "Remunera��o de Servi�os de programa��o", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000118", "000000118", "Remunera��o de Servi�os de  pr�tese", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000119", "000000119", "Remunera��o de Servi�os de  psicologia e psican�lise", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000120", "000000120", "Remunera��o de Servi�os de qu�mica", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000121", "000000121", "Remunera��o de Servi�os de radiologia e radioterapia", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000122", "000000122", "Remunera��o de Servi�os de rela��es p�blicas", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000123", "000000123", "Remunera��o de Servi�os de servi�o de despachante", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000124", "000000124", "Remunera��o de Servi�os de  terap�utica ocupacional", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000125", "000000125", "Remunera��o de Servi�os de  tradu��o ou interpreta��o comercial", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000126", "000000126", "Remunera��o de Servi�os de urbanismo", "2", "2", "2", "2",,,"2", "2", "2"})
        aAdd( aBody, { "", "000127", "000000127", "Remunera��o de Servi�os de  veterin�ria", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000128", "000000128", "Remunera��o de Servi�os de Limpeza","2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000129", "000000129", "Remunera��o de Servi�os de Conserva��o/ Manuten��o", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000130", "000000130", "Remunera��o de Servi�os de Seguran�a/Vigil�ncia/Transporte de valores", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000131", "000000131", "Remunera��o de Servi�os Loca��o de M�o de obra", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000132", "000000132", "Remunera��o de Servi�os de Assessoria Credit�cia, Mercadol�gica, Gest�o de Cr�dito, Sele��o e Riscos e Administra��o de Contas a Pagar e a Receber", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000133", "000000133", "Pagamentos Referentes � Aquisi��o de Autope�as", "2", "2", "2", "2",,, "2", "4", "3" })
        aAdd( aBody, { "", "000134", "000000134", "Rendimentos pago a companhias de navega��o a�rea e mar�tima", "2", "2", "2", "2",,, "4", "2", "2" })
        aAdd( aBody, { "", "000135", "000000135", "Demais pagamentos a entidades imunes ou isentas", "2", "2", "2", "2",,,"2", "4", } )

        aAdd( aBody, { "", "000136", "200000001", "Alimenta��o", "2", "2", , "2",,,"2","4","2" } )
        aAdd( aBody, { "", "000137", "200000002", "Energia el�trica", "2", "2", , "2",,,"2","4","2" } )
        aAdd( aBody, { "", "000138", "200000003", "Servi�os prestados com emprego de materiais", "2", "2",, "2",,,"2","4", "2" } )
        aAdd( aBody, { "", "000139", "200000004", "Constru��o Civil por empreitada com emprego de materiais", "2", "2", ,"2",,,"2","4","2" } )
        aAdd( aBody, { "", "000140", "200000005", "Servi�os hospitalares de que trata o art. 30 da Instru��o Normativa RFB n� 1.234, de 11 de janeiro de 2012", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aBody, { "", "000141", "200000006", "Transporte nacional de cargas", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aBody, { "", "000142", "200000007", "Servi�os de aux�lio diagn�stico e terapia, patologia cl�nica, imagenologia, anatomia patol�gica e citopatol�gica, medicina nuclear e an�lises e patologias cl�nicas, exames por m�todos gr�ficos, procedimentos endosc�picos, radioterapia, quimioterapia, di�lise e oxigenoterapia hiperb�rica de que trata o art. 31 e par�grafo �nico da Instru��o Normativa RFB n� 1.234, de 2012", "2", "2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000143", "200000008", "Produtos farmac�uticos, de perfumaria, de toucador ou de higiene pessoal adquiridos de produtor, importador, distribuidor ou varejista", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aBody, { "", "000144", "200000009", "Mercadorias e bens em geral", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aBody, { "", "000145", "200000010", "Gasolina, inclusive de avia��o, �leo diesel, g�s liquefeito de petr�leo (GLP), combust�veis derivados de petr�leo ou de g�s natural, querosene de avia��o (QAV), e demais produtos derivados de petr�leo, adquiridos de refinarias de petr�leo, de demais produtores, de importadores, de distribuidor ou varejista", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aBody, { "", "000146", "200000011", "�lcool et�lico hidratado, inclusive para fins carburantes, adquirido diretamente de produtor, importador ou do distribuidor", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000147", "200000012", "Biodiesel adquirido de produtor ou importador", "2", "2", , "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000148", "200000013", "Gasolina, exceto gasolina de avia��o, �leo diesel e g�s liquefeito de petr�leo (GLP), derivados de petr�leo ou de g�s natural e querosene de avia��o adquiridos de distribuidores e comerciantes varejistas", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000149", "200000014", "�lcool et�lico hidratado nacional, inclusive para fins carburantes adquirido de comerciante varejista", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000150", "200000015", "Biodiesel adquirido de distribuidores e comerciantes varejistas", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000151", "200000016", "Biodiesel adquirido de produtor detentor regular do selo Combust�vel Social, fabricado a partir de mamona ou fruto, caro�o ou am�ndoa de palma produzidos nas regi�es norte e nordeste e no semi�rido, por agricultor familiar enquadrado no Programa Nacional de Fortalecimento da Agricultura Familiar (Pronaf)", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000152", "200000017", "Transporte internacional de cargas efetuado por empresas nacionais", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aBody, { "", "000153", "200000018", "Estaleiros navais brasileiros nas atividades de Constru��o, conserva��o, moderniza��o, convers�o e reparo de embarca��es pr�- registradas ou registradas no REB", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aBody, { "", "000154", "200000019", "Produtos de perfumaria, de toucador e de higiene pessoal a que se refere o � 1� do art. 22 da Instru��o Normativa RFB n� 1.234, de 2012, adquiridos de distribuidores e de comerciantes varejistas", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000155", "200000020", "Produtos a que se refere o � 2� do art. 22 da Instru��o Normativa RFB n� 1.234, de 2012","2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000156", "200000021", "Produtos de que tratam as al�neas c a k do inciso I do art. 5� da Instru��o Normativa RFB n� 1.234, de 2012", "2", "2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000157", "200000022", "Outros produtos ou servi�os beneficiados com isen��o, n�o incid�ncia ou al�quotas zero da Cofins e da Contribui��o para o PIS/Pasep, observado o disposto no � 5� do art. 2� da Instru��o Normativa RFB n� 1.234, de 2012","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000158", "200000023", "Passagens a�reas, rodovi�rias e demais servi�os de transporte de passageiros, inclusive, tarifa de embarque, exceto transporte internacional de passageiros", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000159", "200000024", "Transporte internacional de passageiros efetuado por empresas nacionais","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000160", "200000025", "Servi�os prestados por associa��es profissionais ou assemelhadas e cooperativas","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000161", "200000026", "Servi�os prestados por bancos comerciais, bancos de investimento, bancos de desenvolvimento, caixas econ�micas, sociedades de cr�dito, financiamento e investimento, sociedades de cr�dito imobili�rio, e c�mbio, distribuidoras de t�tulos e valores mobili�rios, empresas de arrendamento mercantil, cooperativas de cr�dito, empresas de seguros privados e de capitaliza��o e entidades abertas de previd�ncia complementar","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000162", "200000027", "Seguro Sa�de","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000163", "200000028", "Servi�os de abastecimento de �gua", "2", "2", ,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000164", "200000029", "Telefone","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000165", "200000030", "Correio e tel�grafos","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000166", "200000031", "Vigil�ncia", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aBody, { "", "000167", "200000032", "Limpeza","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000168", "200000033", "Loca��o de m�o de obra", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000169", "200000034", "Intermedia��o de neg�cios","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000170", "200000035", "Administra��o, loca��o ou cess�o de bens im�veis, m�veis e direitos de qualquer natureza", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000171", "200000036", "Factoring", "2", "2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000172", "200000037", "Plano de sa�de humano, veterin�rio ou odontol�gico com valores fixos por servidor, por empregado ou por animal", "2", "2", ,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000173", "200000038", "Demais servi�os", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aRet, { aHeader, aBody } )
    EndIf
EndIf
   
Return( aRet )