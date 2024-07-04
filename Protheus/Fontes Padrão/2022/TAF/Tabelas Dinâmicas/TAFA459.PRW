#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA459.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA459
Cadastro MVC dos Países do banco central/SISCOMEX

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA459()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de País do banco central/SISCOMEX
oBrw:SetAlias( 'T5A')
oBrw:SetMenuDef( 'TAFA459' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA459" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT5A 	:= 	FWFormStruct( 1, 'T5A' )
Local oModel 	:= 	MPFormModel():New( 'TAFA459' )

oModel:AddFields('MODEL_T5A', /*cOwner*/, oStruT5A)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA459' )
Local 	oStruT5A 	:= 	FWFormStruct( 2, 'T5A' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_T5A', oStruT5A, 'MODEL_T5A' )

oView:EnableTitleView( 'VIEW_T5A', STR0001 ) //Cadastro de operacoes ANP
oView:CreateHorizontalBox( 'FIELDST5A', 100 )
oView:SetOwnerView( 'VIEW_T5A', 'FIELDST5A' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody		:=	{}
Local aRet		:=	{}

nVerAtu := 1020

If nVerEmp < nVerAtu

	aAdd( aHeader, "T5A_FILIAL" )
	aAdd( aHeader, "T5A_ID" )
	aAdd( aHeader, "T5A_TIPO" )
	aAdd( aHeader, "T5A_FINALI" )
	aAdd( aHeader, "T5A_CLASSE" )
	aAdd( aHeader, "T5A_ESPECI" )
	aAdd( aHeader, "T5A_SEQUEN" )
	aAdd( aHeader, "T5A_CODOPE" )
	aAdd( aHeader, "T5A_DATINI" )
	aAdd( aHeader, "T5A_DATFIN" )
	aAdd( aHeader, "T5A_ORGOPE" )

	aAdd( aBody, {""	,"102cca9f-fa29-d923-a979-e1224499697c" ,"1" ,"1" ,"0" ,"VENDAS PARA ENTREGA FUTURA A AGENTES REGULADOS"                                                                                                                	,"1"   ,"1010001" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"c0ea2fef-f1e2-c1bd-0b1d-e4bad58ea7ed" ,"1" ,"1" ,"0" ,"VENDAS PARA ENTREGA FUTURA A AGENTES NÃO REGULADOS"                                                                                                            	,"2"   ,"1010002" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"b4e3e899-ee40-ae6b-e026-2be86a96d1e4" ,"1" ,"1" ,"0" ,"COMPRA PARA RECEBIMENTO FUTURO DE AGENTE REGULADO"                                                                                                             	,"3"   ,"1010003" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"03b816fb-95c6-3675-4aa8-eb069010e88f" ,"1" ,"1" ,"0" ,"COMPRA PARA RECEBIMENTO FUTURO DE AG.NÃO REGULADO"                                                                                                             	,"4"   ,"1010004" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"2941aa0c-f000-f8c5-3166-daef1449508b" ,"1" ,"1" ,"0" ,"VENDA P/CONTA E ORDEM DE TERC. P/ENTREGA FUTURA"                                                                                                               	,"5"   ,"1010005" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"bba25300-b678-bb14-3855-5edc11249292" ,"1" ,"1" ,"0" ,"COMPRA P/CONTA E ORDEM DE TERC. P/RECEB. FUTURO"                                                                                                               	,"6"   ,"1010006" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"27fb3687-8a45-1710-5737-0d07e6d7e1aa" ,"1" ,"1" ,"0" ,"CANCELAMENTO DE VENDA PARA ENTREGA FUTURA"                                                                                                                     	,"7"   ,"1010007" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"e20f60e9-f034-7aa4-57c4-18ff86572eaa" ,"1" ,"1" ,"0" ,"CANCELAMENTO DE COMPRA PARA RECEBIMENTO FUTURO"                                                                                                                	,"8"   ,"1010008" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"6211f509-c660-5111-fd4d-5ff1c94f1a8a" ,"1" ,"1" ,"0" ,"RETORNO DE REMESSA PARA VENDA FORA DO ESTABELECIMENTO"                                                                                                         	,"9"   ,"1010009" ,"201512" ,""       ,"1" })
	aAdd( aBody, {""	,"77d372a1-a67b-6d1f-48ea-ee656866440b" ,"1" ,"1" ,"0" ,"REMESSA PARA VENDA FORA DO ESTABELECIMENTO"                                                                                                                    	,"10"  ,"1010010" ,"201512" ,""       ,"1" })
	aAdd( aBody, {""	,"e08d1621-fcf6-12a2-8f23-cd40bf78329a" ,"1" ,"1" ,"1" ,"COMPRA DE AGENTE REGULADO"                                                                                                                                     	,"1"   ,"1011001" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"e411823e-fed4-2304-f5bc-5d64d759781e" ,"1" ,"1" ,"1" ,"COMPRA DE AGENTE NÃO REGULADO"                                                                                                                                 	,"2"   ,"1011002" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"e965adf3-1d7c-238a-bd6a-ba8ace8c585b" ,"1" ,"1" ,"1" ,"COMPRA COM REMESSA POR TERCEIRO"                                                                                                                               	,"3"   ,"1011003" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"52a29310-97d0-3aff-532b-d1e31135de47" ,"1" ,"1" ,"1" ,"RECEBIMENTO DE DEVOLUÇÕES DE AGENTE REGULADO"                                                                                                                  	,"4"   ,"1011004" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"80080f36-cf38-586a-c76e-1f6a8e2c1a19" ,"1" ,"1" ,"1" ,"RECEBIMENTO DE DEVOLUÇÕES DE AGENTE NÃO REGULADO"                                                                                                              	,"5"   ,"1011005" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"3bb051d7-cc23-5951-e8ee-aa6dfa83d356" ,"1" ,"1" ,"1" ,"RECEBIMENTO DE PRODUTOS PARA VENDA EM CONSIGNAÇÃO"                                                                                                             	,"6"   ,"1011006" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"9a21b6cb-e4e0-a7fc-d511-00e5a957c15c" ,"1" ,"1" ,"1" ,"RECEBIMENTO DE PRODUTO EM CONSIGNAÇÃO NÃO VENDIDO PELO AGENTE REGULADO"                                                                                        	,"7"   ,"1011007" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"f85afa48-5381-cc81-0614-8d702a040c72" ,"1" ,"1" ,"1" ,"RECEBIMENTO DE PRODUTO EM CONSIGNAÇÃO NÃO VENDIDO PELO AGENTE NÃO REGULADO"                                                                                    	,"8"   ,"1011008" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"7cb47399-0cc4-391e-7802-caf3153a8954" ,"1" ,"1" ,"1" ,"SOBRAS VERIFICADAS EM OPERAÇÕES COMERCIAIS"                                                                                                                    	,"9"   ,"1011009" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"d9123c73-2f2b-d4c7-ab6c-002977e7445c" ,"1" ,"1" ,"1" ,"RECEBIMENTO DE COMPRA CONTRATADA A FUTURO DE AGENTE REGULADO"                                                                                                  	,"10"  ,"1011010" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"8b50e04c-f9b9-e9c5-0709-8721183cf509" ,"1" ,"1" ,"1" ,"RECEBIMENTO DE COMPRA CONTRATADA A FUTURO DE AGENTE NÃO REGULADO"                                                                                              	,"11"  ,"1011011" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"35eff7c8-f51a-f5d0-f9eb-b9d80bf73f19" ,"1" ,"1" ,"1" ,"ENTRADA DE PRODUTOS C/DOC.INTERNO PROVISORIO(S/NF)"                                                                                                            	,"12"  ,"1011012" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"8362c1df-a6eb-6471-621a-eb4b598d2061" ,"1" ,"1" ,"1" ,"COLETA DE ÓLEO LUBRIFICANTE"                                                                                                                                   	,"13"  ,"1011013" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"4fa57804-4bae-aa58-9103-de8a17706bd0" ,"1" ,"1" ,"1" ,"RECEBIMENTO DE COOPERATIVADO"                                                                                                                                  	,"14"  ,"1011014" ,"201701" ,""       ,"1" })
	aAdd( aBody, {""	,"74351733-b4d1-2058-e6b5-81bbad4f1f3d" ,"1" ,"1" ,"1" ,"TOTAL DE ENTRADAS COMERCIAIS NACIONAIS"                                                                                                                        	,"998" ,"1011998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"44286f91-addf-3872-cc0d-7866b1132de0" ,"1" ,"1" ,"1" ,"OUTRAS ENTRADAS NÃO ESPECIFICADAS"                                                                                                                             	,"999" ,"1011999" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"e5afb959-9e74-d2c3-07e5-a342768688c2" ,"1" ,"1" ,"2" ,"VENDA PARA AGENTE REGULADO"                                                                                                                                    	,"1"   ,"1012001" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"2538c0e6-4ac5-8a22-09e2-588b8580846a" ,"1" ,"1" ,"2" ,"VENDA PARA AGENTE NÃO REGULADO"                                                                                                                                	,"2"   ,"1012002" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"624bcaaa-dd93-dfbf-48da-85ec20e499b1" ,"1" ,"1" ,"2" ,"VENDA COM REMESSA POR TERCEIRO"                                                                                                                                	,"3"   ,"1012003" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"03d936fd-a662-7c24-aeba-69771f5ec49e" ,"1" ,"1" ,"2" ,"DEVOLUÇÃO DE PRODUTO PARA AGENTE REGULADO"                                                                                                                     	,"4"   ,"1012004" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"d659173c-e90e-d7ef-f1cc-07cfe1d68a8a" ,"1" ,"1" ,"2" ,"DEVOLUÇÃO DE PRODUTO PARA AGENTE NÃO REGULADO"                                                                                                                 	,"5"   ,"1012005" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"d430dd5e-91a8-4401-7534-35e5d3c16d0e" ,"1" ,"1" ,"2" ,"DEVOLUÇÃO DE PRODUTO EM CONSIGNAÇÃO NÃO VENDIDO"                                                                                                               	,"6"   ,"1012006" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"1e3e18ee-044e-f96e-9107-c9dae4d4f27c" ,"1" ,"1" ,"2" ,"REMESSA DE PRODUTO PARA VENDA EM CONSIGNAÇÃO POR AGENTE REGULADO"                                                                                              	,"7"   ,"1012007" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"a6bde443-da2f-9bad-276a-9bd69c11c125" ,"1" ,"1" ,"2" ,"REMESSA DE PRODUTO PARA VENDA EM CONSIGNAÇÃO POR AGENTE NÃO REGULADO"                                                                                          	,"8"   ,"1012008" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"09f69ecf-4206-0546-3637-efcc68d2d722" ,"1" ,"1" ,"2" ,"ABASTECIMENTO DE NAVIOS OU AERONAVES EM TRÂNSITO"                                                                                                              	,"9"   ,"1012009" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"2860a8b7-d85c-2ed0-765e-dcaaff6f8aca" ,"1" ,"1" ,"2" ,"PERDAS VERIFICADAS EM OPERAÇÕES COMERCIAIS"                                                                                                                    	,"10"  ,"1012010" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"7495e27a-484f-878a-0d0e-1d1b1fc78f86" ,"1" ,"1" ,"2" ,"REMESSA DE ÓLEO LUBRIFICANTE DESTINADO A OUTROS FINS QUE NÃO RERREFINO"                                                                                        	,"11"  ,"1012011" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"4369ea36-7204-a626-f061-d94272da698b" ,"1" ,"1" ,"2" ,"ENTREGA DE VENDA CONTRATADA A FUTURO PARA AGENTE REGULADO"                                                                                                     	,"12"  ,"1012012" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"7fe0e6c1-5653-55ae-da73-b51008e7884e" ,"1" ,"1" ,"2" ,"ENTREGA DE VENDA CONTRATADA A FUTURO PARA AGENTE NÃO REGULADO"                                                                                                 	,"13"  ,"1012013" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"8324a9ba-ac69-77a4-8dc0-2535770e4b25" ,"1" ,"1" ,"2" ,"REMESSA PARA AMOSTRA OU DOAÇÃO"                                                                                                                                	,"14"  ,"1012014" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"cc18a15e-77f4-6196-7424-83fe00bdb296" ,"1" ,"1" ,"2" ,"SAÍDA DE PRODUTO C/DOC.INTERNO PROVISÓRIO(S/NF)"                                                                                                               	,"15"  ,"1012015" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"8cade525-05c1-20f5-f622-1cbffe64e9d9" ,"1" ,"1" ,"2" ,"VENDA DE GLP NO VAREJO"                                                                                                                                        	,"16"  ,"1012016" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"024c0dd7-bd58-d993-03c7-bca260e52ba8" ,"1" ,"1" ,"2" ,"VENDA DE ÓLEO LUBRIFICANTE NO VAREJO"                                                                                                                          	,"17"  ,"1012017" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"9cbc16bc-94fe-3578-e5f3-a736855d064c" ,"1" ,"1" ,"2" ,"REMESSA PARA COOPERATIVA"                                                                                                                                      	,"18"  ,"1012018" ,"201006" ,""       ,"1" })
	aAdd( aBody, {""	,"fbf3044b-f884-f47a-bd99-18e75a78cdf1" ,"1" ,"1" ,"2" ,"TOTAL DE SAÍDAS COMERCIAIS NACIONAIS"                                                                                                                          	,"998" ,"1012998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"eeff964b-aa91-1b03-283a-7cee4637162b" ,"1" ,"1" ,"2" ,"OUTRAS SAÍDAS NÃO ESPECIFICADAS"                                                                                                                               	,"999" ,"1012999" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"bcf341f5-8ad1-5d3b-b1a7-bfbedcd083f5" ,"1" ,"2" ,"0" ,"RECEBIMENTO PARA ARMAZENAMENTO"                                                                                                                                	,"1"   ,"1020001" ,"201701" ,""       ,"1" })
	aAdd( aBody, {""	,"2b978661-ea10-8430-e5c4-9c69a55339b0" ,"1" ,"2" ,"0" ,"RETORNO DE PRODUTO APÓS ARMAZENAMENTO"                                                                                                                         	,"2"   ,"1020002" ,"201701" ,""       ,"1" })
	aAdd( aBody, {""	,"f1dfe2e8-c00e-38a6-bc53-efb73a284aa5" ,"1" ,"2" ,"0" ,"DEVOLUÇÃO DE PRODUTO ARMAZENADO"                                                                                                                               	,"3"   ,"1020003" ,"201701" ,""       ,"1" })
	aAdd( aBody, {""	,"782fc179-8c50-450c-6d86-69d0dac83934" ,"1" ,"2" ,"0" ,"REMESSA DE PRODUTO PARA ARMAZENAMENTO"                                                                                                                         	,"4"   ,"1020004" ,"201701" ,""       ,"1" })
	aAdd( aBody, {""	,"aaf68962-67d8-8d32-8e89-55248147041b" ,"1" ,"2" ,"1" ,"SOBRAS DE PROCESSO"                                                                                                                                            	,"1"   ,"1021001" ,"200409" ,""       ,"2" })
	aAdd( aBody, {""	,"00b37c7e-6f67-c1da-339b-dfda8d3f6d95" ,"1" ,"2" ,"1" ,"PRODUÇÃO PRÓPRIA"                                                                                                                                              	,"2"   ,"1021002" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"c37badd9-3acc-e28d-5dec-9268704f9db3" ,"1" ,"2" ,"1" ,"RECEBIMENTO PARA ARMAZENAMENTO OU TRANSPORTE"                                                                                                                  	,"3"   ,"1021003" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"4a21918f-3348-a71b-af35-bd0f6a331bb5" ,"1" ,"2" ,"1" ,"PRODUÇÃO POR MISTURA"                                                                                                                                          	,"4"   ,"1021004" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"bb042edd-e08a-6730-10c2-a99b47891093" ,"1" ,"2" ,"1" ,"PRODUÇÃO POR REPROCESSAMENTO"                                                                                                                                  	,"5"   ,"1021005" ,"201701" ,""       ,"4" })
	aAdd( aBody, {""	,"412916ec-135e-38bd-8b90-026448902c8b" ,"1" ,"2" ,"1" ,"PRODUÇÃO POR REPROCESSAMENTO PARA TERCEIRO"                                                                                                                    	,"6"   ,"1021006" ,"201701" ,""       ,"2" })
	aAdd( aBody, {""	,"81b7b651-1023-0833-1a9f-82e427228bad" ,"1" ,"2" ,"1" ,"ENTRADAS PARA BALANÇO DE MASSA"                                                                                                                                	,"20"  ,"1021020" ,"200612" ,""       ,"4" })
	aAdd( aBody, {""	,"8e2cde5a-be48-7e63-9453-d6bb5032daf8" ,"1" ,"2" ,"1" ,"ENTRADA POR TRANSFERÊNCIA DE TITULARIDADE"                                                                                                                     	,"22"  ,"1021022" ,"201701" ,""       ,"4" })
	aAdd( aBody, {""	,"fd613101-8089-a166-b4f1-04485c9901db" ,"1" ,"2" ,"1" ,"TOTAL DE ENTRADAS OPERACIONAIS"                                                                                                                                	,"998" ,"1021998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"a3238062-6d4a-3179-2c75-1722a99282af" ,"1" ,"2" ,"1" ,"OUTRAS ENTRADAS OPERACIONAIS"                                                                                                                                  	,"999" ,"1021999" ,"200409" ,"201701" ,"4" })
	aAdd( aBody, {""	,"15ccc62b-beb9-2a6c-d303-0a3ee328f0ab" ,"1" ,"2" ,"2" ,"PERDAS ACIDENTAIS"                                                                                                                                             	,"1"   ,"1022001" ,"200409" ,""       ,"2" })
	aAdd( aBody, {""	,"9fda3312-62dc-af56-d97f-63bc80d8dd9d" ,"1" ,"2" ,"2" ,"CONSUMO PRÓPRIO DE PRODUTO DE ORIGEM INTERNA"                                                                                                                  	,"2"   ,"1022002" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"0662e67e-5cb1-5cb6-84bf-01445203c8ca" ,"1" ,"2" ,"2" ,"CONSUMO PRÓPRIO DE PRODUTO DE ORIGEM EXTERNA"                                                                                                                  	,"3"   ,"1022003" ,"200409" ,"201701" ,"4" })
	aAdd( aBody, {""	,"30006a69-4530-a84f-6de5-1ba4ddc2c681" ,"1" ,"2" ,"2" ,"PERDAS DE PROCESSO"                                                                                                                                            	,"4"   ,"1022004" ,"200409" ,""       ,"2" })
	aAdd( aBody, {""	,"1438e4c7-9932-e9aa-bb91-d47b042f1256" ,"1" ,"2" ,"2" ,"PROCESSAMENTO EM UNIDADE DE PROCESSAMENTO DE GÁS NATURAL"                                                                                                      	,"5"   ,"1022005" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"be269293-893b-daab-f488-5911a5f06f61" ,"1" ,"2" ,"2" ,"SEPARAÇÃO DE CONDENSADO"                                                                                                                                       	,"6"   ,"1022006" ,"200409" ,"201701" ,"4" })
	aAdd( aBody, {""	,"4b8a5d74-a150-b4f2-c364-63ba93f04804" ,"1" ,"2" ,"2" ,"REPROC.NAS UNIDADES DE DESTILAÇÃO PRIMÁRIA"                                                                                                                    	,"7"   ,"1022007" ,"200409" ,"201701" ,"4" })
	aAdd( aBody, {""	,"b14ff10b-371b-b77b-cd5b-c79069f82674" ,"1" ,"2" ,"2" ,"CARGA FRESCA PROC.EM UNIDADES DE DESTIL. PRIMÁRIA"                                                                                                             	,"8"   ,"1022008" ,"200409" ,"200912" ,"4" })
	aAdd( aBody, {""	,"a7b89ebb-b631-1117-f8e9-b8c2b5bc4977" ,"1" ,"2" ,"2" ,"PROCESSAMENTO EM UNIDADE DE DESTILAÇÃO"                                                                                                                        	,"8"   ,"1022008" ,"201001" ,""       ,"4" })
	aAdd( aBody, {""	,"7c9afa2c-a3b5-4ede-5384-15de5aedb198" ,"1" ,"2" ,"2" ,"PROCESSAMENTO EM UNIDADES DE CRAQUEAMENTO"                                                                                                                     	,"9"   ,"1022009" ,"200409" ,"201005" ,"4" })
	aAdd( aBody, {""	,"8b2e54aa-1be3-92e6-324f-debfb70d2a12" ,"1" ,"2" ,"2" ,"PROCESSAMENTO EM UNIDADES DE HIDROTRATAMENTO"                                                                                                                  	,"10"  ,"1022010" ,"200409" ,"201005" ,"4" })
	aAdd( aBody, {""	,"c9f1bcc8-879d-a352-e21c-a9e34d7c471b" ,"1" ,"2" ,"2" ,"PROCESSAMENTO EM UNIDADES DE COQUEAMENTO"                                                                                                                      	,"11"  ,"1022011" ,"200409" ,"201005" ,"4" })
	aAdd( aBody, {""	,"8111d2d7-73a0-07db-e27b-dce22d251d0a" ,"1" ,"2" ,"2" ,"PROCESSAMENTO EM UNIDADES DE REFORMA DE REFINARIAS"                                                                                                            	,"12"  ,"1022012" ,"200409" ,"201005" ,"4" })
	aAdd( aBody, {""	,"58bfe3f7-c677-1365-a874-bf9b1e9c0e27" ,"1" ,"2" ,"2" ,"PROCESSAMENTO EM UNID.DE PIRÓLISE DE REFINARIAS"                                                                                                               	,"13"  ,"1022013" ,"200409" ,"200912" ,"4" })
	aAdd( aBody, {""	,"c05cb5f2-f443-6ef8-2eb4-4f0069f1e117" ,"1" ,"2" ,"2" ,"PROCESSAMENTO EM OUTRAS UNIDADES DA REFINARIA"                                                                                                                 	,"13"  ,"1022013" ,"201001" ,"201110" ,"4" })
	aAdd( aBody, {""	,"0f5e4a9e-9d96-998a-10bf-0bb2b34ecce8" ,"1" ,"2" ,"2" ,"PROCESSAMENTO EM OUTRAS UNIDADES"                                                                                                                              	,"13"  ,"1022013" ,"201111" ,"201701" ,"4" })
	aAdd( aBody, {""	,"ce1234ef-7d0f-a6b3-c036-3499a5d4c83f" ,"1" ,"2" ,"2" ,"PROCESSAMENTO EM CENTRAL DE MATÉRIAS PRIMAS PETROQUÍMICAS OU PRODUTOR DE SOLVENTES"                                                                            	,"14"  ,"1022014" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"e18cdc60-629c-ce9f-c0d9-21229a93e689" ,"1" ,"2" ,"2" ,"SAÍDA PARA PRODUÇÃO POR MISTURA"                                                                                                                               	,"15"  ,"1022015" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"2a8ffb89-dffc-db61-7810-5cb85641290f" ,"1" ,"2" ,"2" ,"ABSORÇÃO DE GÁS NATURAL ÚMIDO"                                                                                                                                 	,"16"  ,"1022016" ,"200409" ,"201701" ,"2" })
	aAdd( aBody, {""	,"ff32022b-f22f-416d-4a45-af494be33be7" ,"1" ,"2" ,"2" ,"DEVOLUÇÃO DE PRODUTO ARMAZENADO OU TRANSPORTADO"                                                                                                               	,"17"  ,"1022017" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"bacc700c-c029-9975-2c00-e6d592673c21" ,"1" ,"2" ,"2" ,"SAÍDA PARA REPROCESSAMENTO"                                                                                                                                    	,"18"  ,"1022018" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"c8cd27b5-f3eb-2782-e805-b986ae58960d" ,"1" ,"2" ,"2" ,"CONSUMO EM TERMELÉTRICA"                                                                                                                                       	,"19"  ,"1022019" ,"200409" ,"200611" ,"4" })
	aAdd( aBody, {""	,"93a26191-422b-8fc3-2adb-829acf313df1" ,"1" ,"2" ,"2" ,"FORNECIMENTO INTERNO DE REFINARIA E UPGN"                                                                                                                      	,"19"  ,"1022019" ,"200612" ,"201701" ,"4" })
	aAdd( aBody, {""	,"1456d68b-e5b6-b930-6ce9-1c8698156f7f" ,"1" ,"2" ,"2" ,"SAÍDAS PARA BALANÇO DE MASSA"                                                                                                                                  	,"20"  ,"1022020" ,"200612" ,"201701" ,"4" })
	aAdd( aBody, {""	,"f59f5d01-26c5-bdd1-bb83-79a0fbfa338f" ,"1" ,"2" ,"2" ,"PROCESSAMENTO EM PLANTA DE BIOCOMBUSTÍVEL"                                                                                                                     	,"21"  ,"1022021" ,"201701" ,""       ,"4" })
	aAdd( aBody, {""	,"31a162d2-435f-a8e4-6646-8c9299b05dc3" ,"1" ,"2" ,"2" ,"TOTAL DE SAÍDAS OPERACIONAIS"                                                                                                                                  	,"998" ,"1022998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"cb9e341f-57f6-3a3b-6654-ef649398506e" ,"1" ,"2" ,"2" ,"OUTRAS SAÍDAS OPERACIONAIS"                                                                                                                                    	,"999" ,"1022999" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"6143a07b-0a0d-d7a2-df5e-69812d2aea29" ,"1" ,"3" ,"1" ,"RETORNO DE UNIDADE INTERNA DO INFORMANTE"                                                                                                                      	,"1"   ,"1031001" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"f8da5130-4081-5220-8508-4c0b67455fb1" ,"1" ,"3" ,"1" ,"TOTAL DE RETORNOS P/UNIDADE INTERNA DO INFORMANTE"                                                                                                             	,"998" ,"1031998" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"aa940854-9148-1a23-5f61-582ff4c9ad7d" ,"1" ,"3" ,"2" ,"REMESSA PARA UNIDADE INTERNA DO INFORMANTE"                                                                                                                    	,"1"   ,"1032001" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"c7e9b93e-e8a6-8362-1e5b-d24879ef6b9e" ,"1" ,"3" ,"2" ,"RETORNO DE UNIDADE INTERNA DO INFORMANTE"                                                                                                                      	,"2"   ,"1032002" ,"200409" ,"200506" ,"1" })
	aAdd( aBody, {""	,"35510610-2bfb-e557-31c4-c5bf96a76219" ,"1" ,"3" ,"2" ,"TOTAL DE REMESSAS DE UNIDADE INTERNA DO INFORMANTE"                                                                                                            	,"998" ,"1032998" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"71aa87a8-5d1c-c13c-5bb2-f5d9fdc9d1a4" ,"1" ,"4" ,"1" ,"RETORNO DE UNIDADE EXTERNA DO INFORMANTE"                                                                                                                      	,"1"   ,"1041001" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"e4b95f40-edd1-932b-394f-5d7bcd79bbd3" ,"1" ,"4" ,"1" ,"RECEBIMENTO DE PRODUTO PROCESSADO EM INSTALAÇÃO DE TERCEIRO"                                                                                                   	,"2"   ,"1041002" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"bb404f54-ff65-17dd-8511-d3e946fa58cc" ,"1" ,"4" ,"1" ,"RECEBIMENTO DE PRODUTO DE TERCEIRO PARA PROCESSAMENTO"                                                                                                         	,"3"   ,"1041003" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"9df4f317-7c2a-ec50-e6de-abe179eeb479" ,"1" ,"4" ,"1" ,"TOTAL DE ENTRADAS DE PROCESSAMENTO EXTERNO"                                                                                                                    	,"998" ,"1041998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"a185a5cf-cf72-79a6-585f-c3eb737a6be3" ,"1" ,"4" ,"1" ,"OUTRAS ENTRADAS DE PROC.EXTERNO NÃO ESPECIFICADAS"                                                                                                             	,"999" ,"1041999" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"cc9394ad-4f94-c65d-102c-46143b772682" ,"1" ,"4" ,"2" ,"REMESSA PARA UNIDADE EXTERNA DO INFORMANTE"                                                                                                                    	,"1"   ,"1042001" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"ffbd37f5-83af-8309-54b6-37a271337760" ,"1" ,"4" ,"2" ,"REMESSA DE PRODUTO PARA PROCESSAMENTO EM INSTALAÇÃO DE TERCEIRO"                                                                                               	,"2"   ,"1042002" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"089a0d4a-bb61-c5d6-754c-ad355ff34244" ,"1" ,"4" ,"2" ,"REMESSA DE PRODUTO DE TERCEIRO APÓS PROCESSAMENTO"                                                                                                             	,"3"   ,"1042003" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"5fa4eb34-610b-79ea-6e0f-6c2c114c5a31" ,"1" ,"4" ,"2" ,"TOTAL DE SAÍDAS DE PROCESSAMENTO EXTERNO"                                                                                                                      	,"998" ,"1042998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"24b342cd-4152-4aa9-bc22-7999996a337f" ,"1" ,"4" ,"2" ,"OUTRAS SAÍDAS DE PROC.EXTERNO NÃO ESPECIFICADAS"                                                                                                               	,"999" ,"1042999" ,"200409" ,"201701" ,"1" })
	aAdd( aBody, {""	,"2cd9d869-bc7e-e108-67b5-2a47b844a98a" ,"1" ,"5" ,"1" ,"RECEBIMENTO DE PRODUTO DE INSTALAÇÃO PERTENCENTE À MESMA EMPRESA INFORMANTE"                                                                                   	,"1"   ,"1051001" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"faa57b00-9904-ecea-98f6-210d763c4516" ,"1" ,"5" ,"1" ,"TOTAL DE ENTRADA DE TRANSFERÊNCIA ENTRE INSTALAÇÕES"                                                                                                           	,"998" ,"1051998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"d58005ad-aefc-459b-1369-548be1c6e4e5" ,"1" ,"5" ,"2" ,"REMESSA DE PRODUTO PARA INSTALAÇÃO PERTENCENTE À MESMA EMPRESA INFORMANTE"                                                                                     	,"1"   ,"1052001" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"900c7f1e-aae3-f4e1-c307-29d09d4acbbb" ,"1" ,"5" ,"2" ,"TOTAL DE SAÍDA DE TRANSFERÊNCIA ENTRE INSTALAÇÕES"                                                                                                             	,"998" ,"1052998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"ca0a7f41-f9e2-4fea-855c-492b133849f7" ,"1" ,"6" ,"1" ,"ENTRADA POR TRANSFERÊNCIA DE OUTRO PRODUTO"                                                                                                                    	,"1"   ,"1061001" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"56f864c9-291b-0420-2c78-f0dbb6cda9e8" ,"1" ,"6" ,"1" ,"RECEB.P/TRANSF.DE OUTRO PROD.DE CARREG. P/OPERADOR"                                                                                                            	,"2"   ,"1061002" ,"200409" ,"201701" ,"4" })
	aAdd( aBody, {""	,"516c4149-1ae2-1e94-efd4-7284eccfee34" ,"1" ,"6" ,"1" ,"RECEB.P/TRANSF.DE OUTRO PROD.DE OPERADOR P/CARREG."                                                                                                            	,"3"   ,"1061003" ,"200409" ,"201701" ,"4" })
	aAdd( aBody, {""	,"9efc967e-4a3f-e83a-d1a6-11ff19d30620" ,"1" ,"6" ,"1" ,"TOTAL DE ENTRADAS POR TRANSFERÊNCIA ENTRE PRODUTOS"                                                                                                            	,"998" ,"1061998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"2b276405-8b2e-1b38-803f-6c6b28474bca" ,"1" ,"6" ,"2" ,"SAÍDAS POR TRANSFERÊNCIA PARA OUTRO PRODUTO"                                                                                                                   	,"1"   ,"1062001" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"5f2ec557-471d-0d27-89f5-8e9eeda40ca9" ,"1" ,"6" ,"2" ,"SAÍDAS POR TRANSFER.P/OUTRO PROD.DE CARREG.P/OPER"                                                                                                             	,"2"   ,"1062002" ,"200409" ,"201701" ,"4" })
	aAdd( aBody, {""	,"ee3518df-b60b-f9c7-284c-090223ed3e7e" ,"1" ,"6" ,"2" ,"SAÍDAS POR TRANSFER.P/OUTRO PROD.DE OPER.P/CARREG"                                                                                                             	,"3"   ,"1062003" ,"200409" ,"201701" ,"4" })
	aAdd( aBody, {""	,"71fa8852-69e8-261c-f29a-7232a6b21ede" ,"1" ,"6" ,"2" ,"TOTAL DE SAÍDAS POR TRANSFERÊNCIAS ENTRE PRODUTOS"                                                                                                             	,"998" ,"1062998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"94b84c2f-0165-8d73-1d87-ab07a6326c14" ,"1" ,"7" ,"1" ,"ENTRADA EM DUTOS"                                                                                                                                              	,"1"   ,"1071001" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"f7a43bd4-cad3-6c23-90d4-6430c25bfadc" ,"1" ,"7" ,"1" ,"SOBRAS DE PROCESSO DE TRANSPORTES"                                                                                                                             	,"2"   ,"1071002" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"238e01ca-a451-899a-c53e-e9f66e3090db" ,"1" ,"7" ,"1" ,"TOTAL DE ENTRADAS EM TRANSPORTE DE DUTOS"                                                                                                                      	,"998" ,"1071998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"f83d38ed-5047-8bda-91c4-1a45ea7b17e7" ,"1" ,"7" ,"2" ,"SAÍDA DE DUTOS"                                                                                                                                                	,"1"   ,"1072001" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"97342f52-f65e-2ada-4b0e-0c3d35834e09" ,"1" ,"7" ,"2" ,"PERDAS DE PROCESSO EM TRANSPORTES"                                                                                                                             	,"2"   ,"1072002" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"c184288b-362d-c133-11b5-e3ff65f5b9d8" ,"1" ,"7" ,"2" ,"TOTAL DE SAÍDAS EM TRANSPORTE DE DUTOS"                                                                                                                        	,"998" ,"1072998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"e228accc-6b6b-731e-3b05-36170d9a3d78" ,"1" ,"8" ,"0" ,"RECEBIMENTO DE PRODUTOS DE TERCEIROS PARA ARMAZENAMENTO EM TERMINAL DE LUBRIFICANTES"                                                                          	,"1"   ,"1080001" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"a002c371-e4f2-274b-8dc8-2434d46e1e60" ,"1" ,"8" ,"0" ,"DEVOLUÇÃO DE PRODUTOS DE TERCEIROS ARMAZENADO OU TRANSPORTADO  EM TERMINAL DE LUBRIFICANTES"                                                                   	,"2"   ,"1080002" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"2bdf9465-c3de-aba2-13a0-9ca9a7098540" ,"1" ,"8" ,"0" ,"PERDAS DE PRODUTOS DE TERCEIROS EM TERMINAL DE LUBRIFICANTES"                                                                                                  	,"3"   ,"1080003" ,"201701" ,""       ,"1" })
	aAdd( aBody, {""	,"35d96783-7e3e-0c53-74c2-3d5f53a29adb" ,"1" ,"8" ,"0" ,"SOBRAS DE PRODUTOS DE TERCEIROS EM TERMINAL DE LUBRIFICANTES"                                                                                                  	,"4"   ,"1080004" ,"201701" ,""       ,"1" })
	aAdd( aBody, {""	,"a1b99b68-913f-9c95-b0e4-f4f9dbe5c760" ,"2" ,"1" ,"0" ,"IMPORTAÇÃO POR CONTA E ORDEM DE TERCEIROS"                                                                                                                     	,"1"   ,"2010001" ,"201611" ,""       ,"4" })
	aAdd( aBody, {""	,"a84b464a-20bd-e3b3-f613-dd3be033c85f" ,"2" ,"1" ,"0" ,"EXPORTAÇÃO POR CONTA E ORDEM DE TERCEIROS"                                                                                                                     	,"2"   ,"2010002" ,"201611" ,""       ,"4" })
	aAdd( aBody, {""	,"48b60659-8fa9-abe8-c5f6-251d298f7c8c" ,"2" ,"1" ,"1" ,"IMPORTAÇÃO DE PRODUTOS"                                                                                                                                        	,"1"   ,"2011001" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"b868e638-c93b-c24c-e63b-0185f19d8452" ,"2" ,"1" ,"1" ,"COMPRA POR CONTA E ORDEM DE TERCEIROS"                                                                                                                         	,"2"   ,"2011002" ,"200409" ,"201611" ,"1" })
	aAdd( aBody, {""	,"b7d43ff5-fc5e-9cec-46f5-eaac1e6ac098" ,"2" ,"1" ,"1" ,"DEVOLUÇÃO DE EXPORTAÇÃO"                                                                                                                                       	,"3"   ,"2011003" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"857630ae-fdc2-430b-56bd-eea3975c5cbd" ,"2" ,"1" ,"1" ,"TOTAL DE ENTRADAS COMERCIAIS INTERNACIONAIS"                                                                                                                   	,"998" ,"2011998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"bbed180e-4aab-55ff-176a-b614e477f5fd" ,"2" ,"1" ,"2" ,"EXPORTAÇÃO DE PRODUTOS"                                                                                                                                        	,"1"   ,"2012001" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"6a90ec35-b58b-284b-ac4f-49c55cf15dfe" ,"2" ,"1" ,"2" ,"VENDA POR CONTA E ORDEM DE TERCEIROS"                                                                                                                          	,"2"   ,"2012002" ,"200409" ,"201611" ,"1" })
	aAdd( aBody, {""	,"a072db10-0e4e-382a-e5ad-9e3bcbe13e75" ,"2" ,"1" ,"2" ,"DEVOLUÇÃO DE IMPORTAÇÃO"                                                                                                                                       	,"3"   ,"2012003" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"99259663-a175-841d-cc0f-36490986d31d" ,"2" ,"1" ,"2" ,"EXPORTAÇÃO PARA NAVIOS OU AERONAVES EM TRÂNSITO"                                                                                                               	,"4"   ,"2012004" ,"201701" ,""       ,"1" })
	aAdd( aBody, {""	,"2e77a6dc-ac36-7034-920f-90e52b6e78a9" ,"2" ,"1" ,"2" ,"TOTAL DE SAÍDAS COMERCIAIS INTERNACIONAIS"                                                                                                                     	,"998" ,"2012998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"a143b456-0d0e-7176-d2f3-364152b571a0" ,"2" ,"2" ,"1" ,"RECEBIMENTO DE PRODUTO IMPORTADO (EM TERMINAL)"                                                                                                                	,"1"   ,"2021001" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"91db3f20-c158-c494-42c4-19c1b222ddab" ,"2" ,"2" ,"1" ,"TOTAL DE ENTRADAS OPERACIONAIS INTERNACIONAIS"                                                                                                                 	,"998" ,"2021998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"709a7ef3-427f-ebeb-e996-aa2930b94e18" ,"2" ,"2" ,"2" ,"ENTREGA DE PRODUTOS PARA EXPORTAÇÃO (EM TERMINAIS)"                                                                                                            	,"2"   ,"2022002" ,"200409" ,""       ,"1" })
	aAdd( aBody, {""	,"bb45273a-f483-9bbe-a19b-b46ea2daa4d7" ,"2" ,"2" ,"2" ,"TOTAL DE SAÍDAS OPERACIONAIS INTERNACIONAIS"                                                                                                                   	,"998" ,"2022998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"302ccbbc-c5dd-4c41-021b-0231a985a1df" ,"3" ,"1" ,"0" ,"ESTOQUE INICIAL EM TERCEIROS"                                                                                                                                  	,"1"   ,"3010001" ,"200409" ,""       ,"3" })
	aAdd( aBody, {""	,"db42f8a6-41e4-9472-8af5-97e985b9082f" ,"3" ,"1" ,"0" ,"ESTOQUE INICIAL DE TERCEIROS"                                                                                                                                  	,"2"   ,"3010002" ,"200409" ,""       ,"3" })
	aAdd( aBody, {""	,"ff2b2dfa-2ecd-ce1f-58ae-79c91dea2dbc" ,"3" ,"1" ,"0" ,"ESTOQUE INICIAL PRÓPRIO"                                                                                                                                       	,"3"   ,"3010003" ,"200409" ,""       ,"3" })
	aAdd( aBody, {""	,"f0341637-81fa-0e84-4faa-9f7320ed8590" ,"3" ,"1" ,"0" ,"ESTOQUE INICIAL S/MOV.DE VENDA P/ENTREGA FUTURA"                                                                                                               	,"4"   ,"3010004" ,"200409" ,"201701" ,"3" })
	aAdd( aBody, {""	,"4b7b96bf-b6f1-3f75-0371-d7823dcae0b6" ,"3" ,"2" ,"0" ,"ESTOQUE FINAL EM TERCEIROS"                                                                                                                                    	,"1"   ,"3020001" ,"200409" ,""       ,"3" })
	aAdd( aBody, {""	,"32f4cf18-5df1-29a4-c4a5-c10aebc83d4e" ,"3" ,"2" ,"0" ,"ESTOQUE FINAL DE TERCEIROS"                                                                                                                                    	,"2"   ,"3020002" ,"200409" ,""       ,"3" })
	aAdd( aBody, {""	,"74749fe4-b3ca-cff6-5fc2-b0172bd55d5a" ,"3" ,"2" ,"0" ,"ESTOQUE FINAL PRÓPRIO"                                                                                                                                         	,"3"   ,"3020003" ,"200409" ,""       ,"3" })
	aAdd( aBody, {""	,"92b80c18-b8a6-4e52-bd2e-743553a7f827" ,"3" ,"2" ,"0" ,"ESTOQUE FINAL S/MOV.DE VENDA P/ENTREGA FUTURA"                                                                                                                 	,"4"   ,"3020004" ,"200409" ,"201701" ,"4" })
	aAdd( aBody, {""	,"12012aea-ab0a-904d-ce03-6a58a7d5984e" ,"3" ,"3" ,"0" ,"FIEL DEPOSITÁRIO EM TERCEIROS"                                                                                                                                 	,"1"   ,"3030001" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"90b9b7ee-b8ea-9d4a-5ac5-ff36d550e183" ,"3" ,"3" ,"0" ,"FIEL DEPOSITÁRIO DE TERCEIROS"                                                                                                                                 	,"2"   ,"3030002" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"2a1a60e4-e956-83e6-2a35-07d06d483c04" ,"3" ,"3" ,"0" ,"FIEL DEPOSITÁRIO PRÓPRIO"                                                                                                                                      	,"3"   ,"3030003" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"7cffe337-4445-b0b2-0405-0806011804ad" ,"3" ,"3" ,"0" ,"EM TRÂNSITO"                                                                                                                                                   	,"4"   ,"3030004" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"a7c935a4-f3ba-845f-515a-8a9768e3b912" ,"4" ,"1" ,"1" ,"TOTAL GERAL DE ENTRADAS"                                                                                                                                       	,"998" ,"4011998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"2150fabd-760f-d3b5-23d1-a0ed8f7977f9" ,"4" ,"1" ,"2" ,"TOTAL GERAL DE SAÍDAS"                                                                                                                                         	,"998" ,"4012998" ,"200409" ,""       ,"5" })
	aAdd( aBody, {""	,"a38c0407-5ec3-7659-8b43-d02cded0dc6f" ,"4" ,"2" ,"0" ,"AQUISIÇÃO DE BOTIJÕES"                                                                                                                                         	,"1"   ,"4020001" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"84f0dc0c-974d-d12d-fb17-4f3e577e55a7" ,"4" ,"2" ,"0" ,"REQUALIFICAÇÃO DE BOTIJÕES"                                                                                                                                    	,"11"  ,"4020011" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"bfba7fa3-3e6c-1ca1-3ebe-f29a3f1fd2b6" ,"4" ,"2" ,"0" ,"INUTILIZAÇÃO DE BOTIJÕES"                                                                                                                                      	,"12"  ,"4020012" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"e6b93eba-59bb-146f-cedc-9e78ca111fc4" ,"4" ,"2" ,"0" ,"QUANTIDADE TOTAL DE BOTIJÕES EM USO"                                                                                                                           	,"13"  ,"4020013" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"e895eb76-c3b6-4d3d-4587-751704b1b774" ,"4" ,"3" ,"0" ,"ÓLEO LUBRIFICANTE DISPENSADO DE COLETA"                                                                                                                        	,"1"   ,"4030001" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"f78011a8-cede-b5b2-ef50-416a6b10948b" ,"4" ,"3" ,"0" ,"ÓLEO LUBRIFICANTE COLETADO CONTRATADO"                                                                                                                         	,"2"   ,"4030002" ,"200409" ,""       ,"4" })
	aAdd( aBody, {""	,"8c0fddfb-e8c3-cc70-7fd3-2bbabff3234a" ,"4" ,"3" ,"0" ,"RECEBIMENTO DE DEVOLUÇÃO DE DISPENSADO DE COLETA"                                                                                                              	,"3"   ,"4030003" ,"200409" ,""       ,"4" })

	aAdd( aRet, { aHeader, aBody } )

EndIf

Return( aRet )
