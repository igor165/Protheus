#include "Protheus.ch"
#Include "lojpesq.ch"
#include "Rwmake.ch"
#include "topconn.ch"  
#Include "vkey.ch"


Static _lLjCNVDA	:= Nil				// Indica se existe integracao com cenario de vendas e se esta trabalhando com as tabelas e Precos DA0 e DA1 ou SB0.
Static _cTabPad 	:= Nil				// Tabela padrão preco de venda
Static _lMvArrefat  := Nil 				// Controle de arredondamento "N"= trunca e "S"= arredonda
Static _cAcessEst	:= "" 				// Visualiza estoque outras lojas via Pesquisa Unificada de Produto do Venda Assistida
Static _cTipoDB 	:= Upper(TCGetDB())	// Tipo de Banco de Dados
Static _lInfQtd 	:= Nil 				// Permite definir se  ao selecionar um produto na tela de pesquisa, será  aberta uma tela para informar a quantidade.
Static _cMvLjTGar	:= Nil				// Tipo do item de garantia

Static _nItem  		:= Nil
Static _nPosPrd		:= Nil
Static _nPosQua		:= Nil
Static _nPosUni		:= Nil
Static _nPosDtProd  := Nil
Static _nPosDtLocal := Nil

//------------------------------------------------------------------
/*/{Protheus.doc} LOJPESQ()
Pesquisa de Produtos Varejo
@type Functoin

@author Marcos Iurato Junior
@since 21/10/2019
@version P12.1.25

@param nOpcao, numerico, Opção da consulta

@return nil, nil, retorno nil
/*/
//------------------------------------------------------------------
Function LOJPESQ(nOpcao)  

Local oEstTempTable
Local oTempTable   		
Local oSSTempTable 		
Local oSGTempTable 		
Local oBrowse 																						//Objeto Browse Principal
Local oBrw02																						//Objeto Browse do Estoque
Local oGet_1																						//Objeto get preco do produto
Local oGet_2																						//Objeto get saldo estoque produto
Local oGet_3																						//Objeto get Modelo produto
Local oGet_4																						//Objeto get Fabricante produto
Local oGet_5																						//Objeto get caracteristica do produto
Local aArea 			:= GetArea()																//Salva área
Local aPesqE			:= { .T., "", "" , "", 0, 0}
Local lRet    			:= .F.          
Local nEstStatus		:= 0																		//Estatus do estoque
Local cCampPrc			:= "" 																		//Indica se existe integracao com cenario de vendas e se esta trabalhando com as tabelas e Precos DA0 e DA1 ou SB0.  
Local cProd      		:= Space(50)																//Codigo do Produto
Local cLocPad     		:= Space(TAMSX3("B1_LOCPAD")[1])											//Local Padrão do Estoque
Local cReadVar			:= ReadVar()
Local cPathImg			:= AllTrim(SuperGetMV("MV_LJIMAGE", .T., ""))								//Pasta onde esta localizada as fotos dos produtos
Local cExtImg  			:= AllTrim(SuperGetMV("MV_LJIMGEX", .T., ".jpg"))	 						//Extensão das imagens Opcional
Local cRealName   		:= "" 																		//Variavel auxiliar da tabela temporaria principal, para utilização da TCSqlExec()
Local cAliasTmp   		:= GetNextAlias()															//Tabela temporaria. Pesquisa Principal.
Local cEstRealName		:= ""																		//Variavel auxiliar da tabela temporaria estoque, para utilização da TCSqlExec()
Local cTabTmp         	:= GetNextAlias()															//Tabela temporaria. 
Local cSSRealName		:= ""																		//Variavel auxiliar da tabela temporaria, para utilização da TCSqlExec()
Local cTabTmp1        	:= GetNextAlias()   														//Tabela temporaria 1. Produtos Similares
Local cSGRealName		:= ""																		//Variavel auxiliar da tabela temporaria 2, para utilização da TCSqlExec()
Local cTabTmp2        	:= GetNextAlias()															//Tabela temporaria 2. Sugestão de Vendas
Local lAltFoco    		:= .T. 
Local lSetTlPesq 		:= ExistFunc("LJ7SetTlPesq") 												// Verifica se a função LJ7SetTlPesq existe, esta função é do fonte LOJA701A

Static cCaracPro		:= Space(02)																//Caracteristicas do Produto


//Inicia Variáveis ESTÁTICAS
_lLjCNVDA	:= SuperGetMv("MV_LJCNVDA",,.F.)  											// Indica se existe integracao com cenario de vendas e se esta trabalhando com as tabelas e Precos DA0 e DA1 ou SB0.
_cTabPad 	:= SuperGetMv("MV_TABPAD")													// Tabela padrão preco de venda
_lMvArrefat := SuperGetMv("MV_ARREFAT",,"S") == "S" 									// Controle de arredondamento "N"= trunca e "S"= arredonda
_nItem 		:= aScan( aHeader, {|x| AllTrim(Upper(x[2]))  == "LR_ITEM"	  }) 			// Posição do Item no aCols da Venda Assistida
_nPosPrd  	:= aScan( aHeader, {|x| Alltrim(Upper(x[2]))  == "LR_PRODUTO" }) 			// Posição do Produto no aCols da Venda Assistida
_nPosQua  	:= aScan( aHeader, {|x| Alltrim(Upper(x[2]))  == "LR_QUANT"   }) 			// Posição da Quantidade no aCols da Venda Assistida
_nPosUni  	:= aScan( aHeader, {|x| Alltrim(Upper(x[2]))  == "LR_VRUNIT"  }) 			// Posição do Valor Unitário no aCols da Venda Assistida
_nPosDtProd	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO" }) 			// Posição do Produto no aColsDet da Venda Assistida
_nPosDtLocal:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_LOCAL"   }) 			// Posição do Local de estoque no aColsDet da Venda Assistida
_cAcessEst  := Substr(Posicione("SLF",1,xFilial("SLF")+xNumCaixa(),"LF_ACESSO"),46,1) 	// Visualiza estoque outras lojas via Pesquisa Unificada de Produto do Venda Assistida
_lInfQtd 	:= SuperGetMv("MV_LJINFQT",,.T.)											// Permite definir se  ao selecionar um produto na tela de pesquisa, será  aberta uma tela para informar a quantidade.
_cMvLjTGar	:= AllTrim( SuperGetMV("MV_LJTPGAR",,"GE") )								// Tipo do item de garantia


cCampPrc 	:= IIF(_lLjCNVDA, "DA1_PRCVEN", "B0_PRV"+_cTabPad) 							// Indica se existe integracao com cenario de vendas e se esta trabalhando com as tabelas e Precos DA0 e DA1 ou SB0.  

//Cria tabela Temporaria Estoque
aStru := {{"B2_FILIAL" , "C" , TAMSX3("B2_FILIAL")[1], 0 },;
          {"B2_LOCAL"  , "C" , TAMSX3("B2_LOCAL")[1], 0 },;
		  {"B2_LOCALIZ", "C" , TAMSX3("B2_LOCALIZ")[1], 0 },;
          {"B2_QATU"   , "N" , TAMSX3("B2_QATU")[1], TAMSX3("B2_QATU")[2] },;
		  {"B2_RESERVA", "N" , TAMSX3("B2_RESERVA")[1], TAMSX3("B2_RESERVA")[2] }}

//Cria a tabela temporária com base na estrutura
oEstTempTable 	:= LjCrTmpTbl(cTabTmp, aStru, {"B2_FILIAL","B2_LOCAL"})
cEstRealName 	:= oEstTempTable:GetRealName()
cEstRealName 	:= StrTran(cEstRealName,"dbo.","")	//Para funcionar a query, preciso omitir o 'dbo.' para utilizar em TCSqlExec().	
cTabTmp  		:= oEstTempTable:GetAlias()

//Cria tabela temporária dos Produtos similares
aStru1 := {{"B1_FILIAL"		, "C" , TAMSX3("B1_FILIAL")[1]	, 0 },;
       	   {"B1_COD"		, "C" , TAMSX3("B1_COD")[1]		, 0 },;
		   {"B1_DESC"		, "C" , TAMSX3("B1_DESC")[1]	, 0 },;
	       {"B1_UM"		    , "C" , TAMSX3("B1_UM")[1]		, 0 },;
		   {cCampPrc		, "N" , TAMSX3(cCampPrc)[1]		, 2 },;
           {"B5_CODCLI" 	, "C" , TAMSX3("B5_CODCLI")[1]	, 0 },;
           {"B2_LOCAL"    	, "C" , TAMSX3("B2_LOCAL")[1]	, 0 },;
	       {"B2_LOCALIZ"   	, "C" , TAMSX3("B2_LOCALIZ")[1]	, 0 },;
    	   {"B2_QATU"	    , "N" , TAMSX3("B2_QATU")[1]	, TAMSX3("B2_QATU")[2] },;
		   {"B2_RESERVA"	, "N" , TAMSX3("B2_RESERVA")[1] , TAMSX3("B2_RESERVA")[2] }}

//Cria a tabela temporária com base na estrutura
oSSTempTable 	:= LjCrTmpTbl(cTabTmp1, aStru1, {"B1_FILIAL","B1_COD"})
cSSRealName 	:= oSSTempTable:GetRealName()
cSSRealName 	:= StrTran(cSSRealName,"dbo.","")	//Para funcionar a query, preciso omitir o 'dbo.' para utilizar em TCSqlExec().	
cTabTmp1  		:= oSSTempTable:GetAlias()

//Cria tabela temporária dos Produtos de Sugestão de vendas
aStru2 := {{"B1_FILIAL"		, "C" , TAMSX3("B1_FILIAL")[1]	, 0 },;
       	   {"B1_COD"		, "C" , TAMSX3("B1_COD")[1]		, 0 },;
		   {"B1_DESC"		, "C" , TAMSX3("B1_DESC")[1]	, 0 },;
           {"B1_UM"		    , "C" , TAMSX3("B1_UM")[1]		, 0 },;
		   {cCampPrc		, "N" , TAMSX3(cCampPrc)[1]		, 2 },;
       	   {"B5_CODCLI" 	, "C" , TAMSX3("B5_CODCLI")[1]	, 0 },;
       	   {"B2_LOCAL"    	, "C" , TAMSX3("B2_LOCAL")[1]	, 0 },;
           {"B2_LOCALIZ"   	, "C" , TAMSX3("B2_LOCALIZ")[1]	, 0 },;
   	       {"B2_QATU"	    , "N" , TAMSX3("B2_QATU")[1]	, TAMSX3("B2_QATU")[2] },;
		   {"B2_RESERVA"    , "N" , TAMSX3("B2_RESERVA")[1] , TAMSX3("B2_RESERVA")[2] }}

//Cria a tabela temporária com base na estrutura
oSGTempTable 	:= LjCrTmpTbl(cTabTmp2, aStru2, {"B1_FILIAL","B1_COD"})
cSGRealName 	:= oSGTempTable:GetRealName()
cSGRealName 	:= StrTran(cSGRealName,"dbo.","")	//Para funcionar a query, preciso omitir o 'dbo.' para utilizar em TCSqlExec().	
cTabTmp2  		:= oSGTempTable:GetAlias()


//----------------------------------------------------------------------------------
//Especificar FunName() dos fontes que utilizaram a consulta fora do Venda Assitida
//----------------------------------------------------------------------------------
If (Upper(Alltrim(FunName())) $ "LOJA701")
	aHeader701:= aClone(aHeader)
	aCols701  := aClone(aCols)
Endif

//Cria tabela temporária auxiliar da pesquisa
aHeader  := {{"B1_FILIAL"   , "C" , TAMSX3("B1_FILIAL")[1] , 0 },;
            {"B1_COD"       , "C" , TAMSX3("B1_COD")[1]    , 0 },;
            {"B1_DESC"      , "C" , TAMSX3("B1_DESC")[1]   , 0 },;
            {"B1_UM"        , "C" , TAMSX3("B1_UM")[1]     , 0 },;
            {"B5_CODCLI"    , "C" , TAMSX3("B5_CODCLI")[1] , 0 },;
			{"B1_LOCPAD"    , "C" , TAMSX3("B1_LOCPAD")[1] , 0 },;
            {"B1_FABRIC"    , "C" , TAMSX3("B1_FABRIC")[1] , 0 },;
			{"B1_MODELO"    , "C" , TAMSX3("B1_MODELO")[1] , 0 },;
			{"CARACB5"      , "C" , 2000 				   , 0 }}

//Cria a tabela temporária com base na estrutura
oTempTable := LjCrTmpTbl(cAliasTmp, aHeader, {"B1_FILIAL","B1_COD"})
cRealName := oTempTable:GetRealName()
cRealName := StrTran(cRealName,"dbo.","")	//Para funcionar a query, preciso omitir o 'dbo.' para utilizar em TCSqlExec().	
cAliasTmp := oTempTable:GetAlias()

Dbselectarea(cAliasTmp)

If Upper(Alltrim(FunName())) == "LOJA701"
   Lj7SetKEYs(.F.)          
   SetKey(17,Nil)
   SetKey(18,Nil)
   SetKey(20,Nil)
   Lj7SetKEYs(.T.)
   //Ao acionar a tecla F2, visualiza cadastro do produto
   SetKey(VK_F2,{|| LOJPESQB()} )  
EndIf

DEFINE MSDIALOG oDlg1 FROM  120,100 TO C(128),C(200) TITLE OemToAnsi(STR0001)  // Venda Assistida - Pesquisa Unificada de Produto
    									
@ 07,10  SAY STR0002 PIXEL   //Pesquisar
@ 05,40  MSGET o_Get1 VAR cProd Picture("@!") ON CHANGE (LOJPESQC(cProd, cRealName, oBrw02, cCampPrc, cLocPad, cPathImg, cExtImg, cAliasTmp, cEstRealName,;
			 	cTabTmp, cSSRealName, cTabTmp1, cSGRealName, cTabTmp2, oGet_1, oGet_2, oGet_3, oGet_4, oGet_5)) Of oDlg1 PIXEL SIZE C(155),C(10)
o_Get1:cPlaceHold := STR0036 //"Digite para pesquisar o produto..."

oMsdb := TCBrowse():New(23, 05, C(245), C(112), Nil, Nil, Nil, odlg1, , , , , , , , , , , , .F., cAliasTmp, .T., , .F., , , ) 
oMsdb:AddColumn( TCColumn():New(STR0003     ,{|| (cAliasTmp)->B1_COD  	},,,,"LEFT"	,070,.f.,.F.,,,,.F.))   //Código
oMsdb:AddColumn( TCColumn():New(STR0004     ,{|| (cAliasTmp)->B1_DESC  	},,,,"LEFT"	,170,.f.,.F.,,,,.F.))	//Descrição
oMsdb:AddColumn( TCColumn():New(STR0005     ,{|| (cAliasTmp)->B1_UM    	},,,,"LEFT"	,022,.f.,.F.,,,,.F.))	//UM
oMsdb:AddColumn( TCColumn():New(STR0006		,{|| (cAliasTmp)->B5_CODCLI	},,,,"LEFT"	,060,.f.,.F.,,,,.F.))	//Cod.Forn/Fabric
oMsdb:lVScroll 		:= .T.
oMsdb:nScrollType 	:= 0 
oMsdb:Cargo      	:= .T. 
oMsdb:bChange    	:= {|| aPesqE := LOJPESQE(0, oBrw02, cCampPrc, cLocPad, cPathImg, cExtImg, cAliasTmp, cEstRealName, cTabTmp, cSSRealName, cTabTmp1,;
											  cSGRealName, cTabTmp2, oGet_1, oGet_2, oGet_3, oGet_4, oGet_5) } 
oMsdb:nColPos    	:= 1
oMsdb:blDblClick 	:= {|| IIF(!EMPTY( (cAliasTmp)->B1_COD ),IIF(Upper(Alltrim(FunName())) $ "LOJA701",(cCodProd := (cAliasTmp)->B1_COD, cLocPad := (cAliasTmp)->B1_LOCPAD,;
										lRet:=LOJPESQD(nOpcao, oBrowse, cProd, cCampPrc, cLocPad, cAliasTmp)), (&cReadVar := (cAliasTmp)->B1_COD, oDlg1:END() ) ), )}
oMsdb:bRClicked 	:= {|| LOJPESQB() }

// Pesquisar
@ 06,238 BUTTON STR0002  ACTION(LOJPESQC(cProd, cRealName, oBrw02, cCampPrc, cLocPad, cPathImg, cExtImg,cAliasTmp, cEstRealName, cTabTmp, cSSRealName, cTabTmp1,;
 									     cSGRealName, cTabTmp2, oGet_1, oGet_2, oGet_3, oGet_4, oGet_5)) OF oDlg1 PIXEL SIZE C(40),C(10) 

DEFINE SBUTTON FROM 06, 290 TYPE 1 ENABLE ACTION(oDlg1:End())

@ 005,325 TO C(131),C(476) Label  STR0032 OF oDlg1 PIXEL  //"Detalhes do Produto"
@ 015,330 SAY STR0011 PIXEL		//Preço
@ 013,370 MSGET oGet_1 VAR aPesqE[6] Picture(X3Picture("L2_VRUNIT")) When .F. Of oDlg1 PIXEL SIZE C(50),C(05)
@ 024,330 SAY STR0012 PIXEL		//Estoque Venda
@ 022,370 MSGET oGet_2 VAR aPesqE[5] Picture(X3Picture("B2_QATU")) When .F. Of oDlg1 PIXEL SIZE C(50),C(05)
@ 033,330 SAY STR0013 PIXEL		//Modelo
@ 031,370 MSGET oGet_3 VAR aPesqE[3] Picture("@!") When .F. Of oDlg1 PIXEL SIZE C(70),C(05)
@ 042,330 SAY STR0014 PIXEL		//Fabricante
@ 040,370 GET oGet_4 Var aPesqE[2] Picture("@!") When .F. Of oDlg1 PIXEL SIZE C(70),C(05)
@ 051,330 SAY STR0015 PIXEL		//Características
@ 058,330 GET oGet_5 Var cCaracPro MEMO Size C(100),C(83) READONLY PIXEL OF oDlg1

oBrw02 := TCBrowse():New(013,463,C(110),C(50),,,,odlg1,,,,,,,,,,,,.F.,cTabTmp,.T.,,.F.,,)  
oBrw02:AddColumn( TCColumn():New(STR0007, {||(cTabTmp)->B2_FILIAL                               	},,,,"LEFT"  ,015,.f.,.F.,,,,.F.))							//Filial
oBrw02:AddColumn( TCColumn():New(STR0008, {||(cTabTmp)->B2_LOCAL								    },,,,"LEFT"  ,029,.f.,.F.,,,,.F.))							//Local
oBrw02:AddColumn( TCColumn():New(STR0009, {||(cTabTmp)->B2_LOCALIZ         	                		},,,,"LEFT"  ,035,.f.,.F.,,,,.F.))							//Nome
oBrw02:AddColumn( TCColumn():New(STR0010, {||Transform( ((cTabTmp)->B2_QATU - (cTabTmp)->B2_RESERVA), X3Picture("B2_QATU"))	},,,,"RIGHT" ,022,.f.,.F.,,,,.F.))	//Saldo Estoque

@ 167,02 TO C(192),C(476) Label STR0016 OF oDlg1 PIXEL   // Produto Similar
oBrw03 := TCBrowse():New(175,05,C(469),C(052),,,,odlg1,,,,,,,,,,,,.F.,cTabTmp1,.T.,,.F.,,)  
oBrw03:AddColumn( TCColumn():New(STR0003, {||(cTabTmp1)->B1_COD                           				},,,,"LEFT"   ,070,.f.,.F.,,,,.F.))								//Código
oBrw03:AddColumn( TCColumn():New(STR0004, {||(cTabTmp1)->B1_DESC                        				},,,,"LEFT"   ,180,.f.,.F.,,,,.F.))								//Descrição
oBrw03:AddColumn( TCColumn():New(STR0005, {||(cTabTmp1)->B1_UM                               			},,,,"LEFT"   ,022,.f.,.F.,,,,.F.))								//UM
oBrw03:AddColumn( TCColumn():New(STR0011, {||Transform((cTabTmp1)->&(cCampPrc), X3Picture("L2_VRUNIT"))	},,,,"RIGHT"  ,065,.f.,.F.,,,,.F.))								//Preço
oBrw03:AddColumn( TCColumn():New(STR0017, {||(cTabTmp1)->B5_CODCLI                       				},,,,"LEFT"   ,070,.f.,.F.,,,,.F.))								//Cod.Fonec.
oBrw03:AddColumn( TCColumn():New(STR0018, {||(cTabTmp1)->B2_LOCAL                         				},,,,"LEFT"   ,040,.f.,.F.,,,,.F.))								//Armazém
oBrw03:AddColumn( TCColumn():New(STR0019, {||(cTabTmp1)->B2_LOCALIZ                          			},,,,"LEFT"   ,040,.f.,.F.,,,,.F.))								//Localização
oBrw03:AddColumn( TCColumn():New(STR0010, {||Transform( ((cTabTmp1)->B2_QATU - (cTabTmp1)->B2_RESERVA), X3Picture("B2_QATU"))		},,,,"RIGHT"  ,022,.f.,.F.,,,,.F.)) //Saldo Estoque     
oBrw03:blDblClick := {|| IIF(Upper(Alltrim(FunName())) $ "LOJA701",(cCodProd := (cTabTmp1)->B1_COD, cLocPad := (cTabTmp1)->B2_LOCAL,;
							 lRet:=LOJPESQD(nOpcao, oBrowse, cProd, cCampPrc, cLocPad, cAliasTmp)), (&cReadVar := (cTabTmp1)->B1_CODIGO,oDlg1:END())) }
oBrw03:bChange  := {|| lAltFoco := .F. }

@ 245,02 TO C(253),C(476) Label STR0020 OF oDlg1 PIXEL  // Sugestão de Vendas (Cross Sell)
oBrw04 := TCBrowse():New(253,05,C(469),C(052),,,,odlg1,,,,,,,     ,,,,,.F.,cTabTmp2,.T.,,.F.,,)  
oBrw04:AddColumn( TCColumn():New(STR0003, {||(cTabTmp2)->B1_COD                           				},,,,"LEFT"   ,070,.f.,.F.,,,,.F.))								//Código
oBrw04:AddColumn( TCColumn():New(STR0004, {||(cTabTmp2)->B1_DESC                        				},,,,"LEFT"   ,180,.f.,.F.,,,,.F.))								//Descrição
oBrw04:AddColumn( TCColumn():New(STR0005, {||(cTabTmp2)->B1_UM                               			},,,,"LEFT"   ,022,.f.,.F.,,,,.F.))								//UM
oBrw04:AddColumn( TCColumn():New(STR0011, {||Transform((cTabTmp2)->&(cCampPrc), X3Picture("L2_VRUNIT"))	},,,,"RIGHT"  ,065,.f.,.F.,,,,.F.))								//Preço
oBrw04:AddColumn( TCColumn():New(STR0017, {||(cTabTmp2)->B5_CODCLI                       				},,,,"LEFT"   ,070,.f.,.F.,,,,.F.))								//Cod.Fonec.
oBrw04:AddColumn( TCColumn():New(STR0018, {||(cTabTmp2)->B2_LOCAL                       	   			},,,,"LEFT"   ,040,.f.,.F.,,,,.F.))								//Armazém
oBrw04:AddColumn( TCColumn():New(STR0019, {||(cTabTmp2)->B2_LOCALIZ                          			},,,,"LEFT"   ,040,.f.,.F.,,,,.F.))								//Localização
oBrw04:AddColumn( TCColumn():New(STR0010, {||Transform( ((cTabTmp2)->B2_QATU - (cTabTmp2)->B2_RESERVA), X3Picture("B2_QATU"))		},,,,"RIGHT"  ,022,.f.,.F.,,,,.F.))	//Saldo Estoque
oBrw04:blDblClick	:= {|| IIF(Upper(Alltrim(FunName())) $ "LOJA701",(cCodProd := (cTabTmp2)->B1_COD, cLocPad := (cTabTmp2)->B2_LOCAL,;
						 lRet:=LOJPESQD(nOpcao, oBrowse, cProd, cCampPrc, cLocPad, cAliasTmp)), (&cReadVar := (cTabTmp2)->B1_CODIGO,oDlg1:END())) }
oBrw04:bChange	:= {|| lAltFoco := .F. }

ACTIVATE MSDIALOG oDlg1         

If Upper(Alltrim(FunName())) == "LOJA701"
   SetKey(17,{|| LOJPESQ()})  
   
   SetKey(VK_F2,{|| })
   
   Lj7SetKEYs(.T.)
Endif

//---------------------------------------------------------------------------------
//Especificar FunName() dos fontes que utilizaram a consulta fora do Venda Assitida
//---------------------------------------------------------------------------------
If (Upper(Alltrim(FunName())) $ "LOJA701")
	aHeader    := aClone(aHeader701)   
	aCols      := aClone(aCols701)   
Endif

Dbselectarea("SB1")                                               
DbClearFil() 

Retindex("SB1")
RestArea(aArea)

LJ7SetTlPesq(.T.)

//---------------------------------
//Exclui tabelas Temporárias
//---------------------------------
oEstTempTable:Delete()
oTempTable:Delete()
oSSTempTable:Delete()
oSGTempTable:Delete()

Return(lRet)     


//------------------------------------------------------------------
/*/{Protheus.doc} LOJPESQB()
Visualiza o Cadastro do Produto
@type function

@author Marcos Iurato Junior
@since 05/11/2019
@version P12.1.25

@return, logico, .T.
/*/
//------------------------------------------------------------------
Static Function LOJPESQB()

AxVisual("SB1",SB1->(Recno()),2)
Return(.T.)                                           


//------------------------------------------------------------------
/*/{Protheus.doc} LOJPESQC()
Faz Filtro na tabela SB1 / verifica se a informação digitada 
se trata de um código de barras

@type function

@author Marcos Iurato Junior
@since 05/11/2019
@version P12.1.25

@param cProd, caracter, Código do produto
@param cRealName, caracter, Nome real do arquivo temporario
@param oBrw02, objeto, Browse 2, Objeto Browse do Estoque
@param cCampPrc, caracter, Campo do preço
@param cLocPad, caracter, Local no estoque
@param cPathImg, caracter, Diretorio da imagem do produto
@param cExtImg, caracter, Verifica se existe a imgame ou não
@param cAliasTmp, caracter, Alias do arquivo temporário
@param cEstRealName, caracter, Nome real do arquivo temporario do estoque
@param cTabTmp, caracter, Tabela temporária
@param cSSRealName, caracter, Nome real do arquivo temporario
@param cTabTmp1, caracter, Tabela temporária 1
@param cSGRealName, caracter, Nome real do arquivo temporario
@param cTabTmp2, caracter, Tabela temporária 2
@param oGet_1, objeto, Get Preço
@param oGet_2, objeto, Get Estoque de venda
@param oGet_3, objeto, Get Modelo
@param oGet_4, objeto, Get Fabricante
@param oGet_5, objeto, Get Caracteristicas do produto

@return, logico, .T.
/*/
//------------------------------------------------------------------
Static Function LOJPESQC(cProd, cRealName, oBrw02, cCampPrc, cLocPad, cPathImg, cExtImg, cAliasTmp, cEstRealName,;
 						 cTabTmp, cSSRealName, cTabTmp1, cSGRealName, cTabTmp2, oGet_1, oGet_2, oGet_3, oGet_4, oGet_5)

Local aPesq     := {}
Local nX		:= 1
Local nY		:= 1
Local nStatus	:= 0
Local cErrorQry	:= ""
Local cProduto  := AllTrim(cProd)
Local cPro 		:= " "
Local cQry      := ""
Local cCampos	:= ""
Local cDelete 	:= ""

For nX := 1 To Len(cProduto)
	   
	If nX == 1 .AND. AT(" ",cProduto) <> 0 
		aadd(aPesq,SubStr(cProduto,nX,AT(" ",cProduto)-1))
		nX += AT(" ",cProduto)-1
		cPro := SubStr(cProduto,AT(" ",cProduto)+1,len(cProduto))
	Else 
		If AT(" ",IIF(Empty(cPro),cProduto,cPro)) == 0   
			aadd(aPesq,SubStr(IIF(Empty(cPro),cProduto,cPro),1,len(IIF(Empty(cPro),cProduto,cPro)) ) )
			nX := Len(cProduto)
		Else
			aadd(aPesq,SubStr(cProduto,nX,AT(" ",cPro) ) )
            nX += AT(" ",cPro)-1
			cPro :=SubStr(cProduto,nX+1,len(cProduto) )
		EndIf
	EndIf
Next nX

cCampos  := "B1_FILIAL, B1_COD, B1_DESC, B1_UM, B1_LOCPAD, B1_FABRIC, B1_MODELO" 

cQry := " SELECT " + cCampos + ", "
If "ORACLE" $ _cTipoDB
	cQry += " NVL(B5_CODCLI,' ') AS B5_CODCLI,"
	cQry += " NVL(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(B5_ECCARAC, 4000, 1)),' ') AS CARACB5" 
ElseIf "POSTGRES" $ _cTipoDB
	cQry += " COALESCE(B5_CODCLI,' ') AS B5_CODCLI, "
	cQry += " COALESCE( CAST(B5_ECCARAC AS VARCHAR), ' ') CARACB5 "
Else
	cQry += " ISNULL(B5_CODCLI,' ') AS B5_CODCLI,"
	cQry += " ISNULL(CAST(CAST(B5_ECCARAC AS VARBINARY(8000)) AS VARCHAR(8000)),' ') AS CARACB5" 
EndIf
cQry += " FROM " + RetSqlName("SB1") + " SB1 "
cQry += "	LEFT JOIN "+RetSqlName("SB5")+" SB5 ON SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
cQry += "					AND SB5.B5_COD = B1_COD"
cQry += "					AND SB5.D_E_L_E_T_ = ' '"
cQry += "	LEFT JOIN "+RetSqlName("SLK")+" SLK ON SLK.LK_FILIAL = '"+xFilial("SLK")+"'"
cQry += "					AND SLK.LK_CODIGO = B1_COD"
cQry += "					AND SLK.D_E_L_E_T_ = ' '"
cQry += " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "'"

If Len(aPesq) > 0
    For nY := 1 To Len(aPesq)
		cQry += " AND (UPPER(SB1.B1_DESC) Like '%" 	+ aPesq[nY] +"%' "
		cQry += " OR UPPER(SB1.B1_COD) Like '%" 	+ aPesq[nY]	+"%' "
		cQry += " OR UPPER(SB5.B5_CODCLI) Like '%"	+ aPesq[nY] +"%' "
		cQry += " OR UPPER(SB1.B1_FABRIC) Like '%"	+ aPesq[nY] +"%' "
		cQry += " OR UPPER(SB1.B1_MODELO) Like '%"	+ aPesq[nY] +"%' "
		cQry += " OR UPPER(SLK.LK_CODBAR) Like '%"	+ aPesq[nY] +"%' "
		If "ORACLE" $ _cTipoDB
			cQry += " OR UPPER(NVL(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(B5_ECCARAC, 4000, 1)),' ')) Like '%" + aPesq[nY] + "%')"
		ElseIf "POSTGRES" $ _cTipoDB
			cQry += " OR CAST(B5_ECCARAC AS VARCHAR) Like '%" + aPesq[nY] + "%')"
		Else
			cQry += " OR UPPER(ISNULL(CAST(CAST(B5_ECCARAC AS VARBINARY(8000)) AS VARCHAR(8000)),' ')) Like '%" + aPesq[nY] + "%')"
		EndIf
   	Next nY
Endif
cQry += " AND SB1.B1_MSBLQL <> '1' " 
cQry += " AND SB1.D_E_L_E_T_ = ' ' " 
cQry += " ORDER BY B1_FILIAL, B1_DESC, B1_COD, B1_UM, B5_CODCLI, B1_LOCPAD, B1_FABRIC, B1_MODELO" 

//Executa dois comandos (DELETE/INSERT) de uma só vez para diminuir I/O no banco de dados
cDelete := " DELETE FROM " + cRealName +";"
nStatus := TCSqlExec( cDelete + " INSERT INTO " + cRealName + " ( " +cCampos+", B5_CODCLI, CARACB5 ) " + cQry )

If nStatus == 0
	Dbselectarea(cAliasTmp)
	(cAliasTmp)->(DbGotop())

	LOJPESQE(0, oBrw02, cCampPrc, cLocPad, cPathImg, cExtImg, cAliasTmp, cEstRealName, cTabTmp,;
			cSSRealName, cTabTmp1, cSGRealName, cTabTmp2, oGet_1, oGet_2, oGet_3, oGet_4, oGet_5)
Else
	cErrorQry := TCSQLError()
	LjGrvLog("LOJPESQ", "LOJPESQC | Falha na manipulação da tabela temporaria " + cRealName + " | Erro: " + cErrorQry, nStatus)
	Final(STR0037 + " " + cRealName, cErrorQry) //"Falha na manipulação da tabela temporária"
EndIf

oMsdb:Refresh()

Return(.T.)


//------------------------------------------------------------------
/*/{Protheus.doc} LOJPESQD()
 Atualiza Acols do orçamento com informações do produto 
selecionado (informando ou não a Quandidade)

@type function

@author Marcos Iurato Junior
@since 05/11/2019
@version P12.1.25

@param nOpcao, numérico, 
@param oBrowse, objeto, Browse principal
@param cProd, caracter, Codigo do produto
@param cCampPrc, caracter, Campo do preço
@param cLocPad, caracter, Local padrão de armazenagem do produto
@param cAliasTmp, caracter, Alias temporario

@return, logico, .T.
/*/
//------------------------------------------------------------------
Static Function LOJPESQD(nOpcao, oBrowse, cProd, cCampPrc, cLocPad, cAliasTmp)

Local lRet			:= .T.
Local oDlg6
Local aHeaderAux 	:= {}
Local aColsAux 		:= {}
Local aColsDetAux 	:= {}
Local nZ			   	
Local nyQ	
Local nRegSX3   	:= SX3->(Recno())
Local nOrdSX3   	:= SX3->(indexOrd())
Local nRegSB1   	:= SB1->(Recno())
Local nOrdSB1   	:= SB1->(indexOrd())
Local nOpca     	:= 0
Local nquant 		:= 1
Local nQuant2 		:= 0
Local nPreco		:= 0
Local cProduto 		:= ""    
Local lKit			:= .F. 															// Identifica se o produto é Kit
Local cbkpReadVar 	:= ReadVar()

If nOpcao == 1
   oDlg1:End()
   Return(.T.)              
Endif

aHeaderAux  := aClone(aHeader)
aColsAux    := aClone(aCols)
aColsDetAux := aClone(aColsDet)
aHeader     := aClone(aHeader701)   
aCols       := aClone(aCols701)   

If _lInfQtd		
	
	DEFINE MSDIALOG oDlg6 FROM  69,90 TO 155,421 TITLE OemToAnsi(STR0022) PIXEL		//Informar Quantidade
	@ 2, 2 TO 25, 160 OF oDlg6 PIXEL 
	@ 7, 38 MSGET nquant Picture X3Picture("L2_QUANT") SIZE 94, 10 VALID nquant > 0 Of oDlg6 PIXEL SIZE 50,10
	@ 8, 09 SAY OemToAnsi(STR0023)  SIZE 44, 07 OF oDlg6 PIXEL 						//Qtd. Venda
	DEFINE SBUTTON FROM 29, 101 TYPE 1 ENABLE ACTION(nOpca:=1, oDLg6:End())
	DEFINE SBUTTON FROM 29, 131 TYPE 2 ENABLE ACTION(oDlg6:End())
	ACTIVATE MSDIALOG oDlg6 Centered
	
Else
	nquant := 1
	nOpca   := 1
EndIf      

If _lLjCNVDA  // Indica se existe integracao com cenario de vendas e se esta trabalhando com as tabelas e Precos DA0 e DA1 ou SB0.
	nPreco := posicione("DA1",1,xFilial("DA1")+_cTabPad+alltrim(cProduto),"DA1_PRCVEN")
Else
	nPreco := posicione("SB0",1,xFilial("SB0")+alltrim(cProduto), cCampPrc)
Endif
                         
If nOpca == 1 .And. nPreco > 0

	cProduto := cCodProd
	nQuant2  := nquant

  Eval(oGetVa:oBrowse:bGotFocus)

    If Empty(aCols[Len(acols),2])
       nZ := Len(acols)
       aCols[nZ,_nPosPrd] := cProduto
       aCols[nZ,_nPosQua] := nQuant2
    Else
       nZ := Len(aCols)+1
       AADD(aCols,Array(Len(aHeader)+1))
       For nyQ := 1 To Len(aHeader)  
         If !(aHeader[nyQ,2] $ "L2_ALI_WT|L2_REC_WT")
            aCols[nZ,nyQ] := CriaVar(aHeader[nyQ,2]) 
         ElseIf aHeader[nyQ,2] == "L2_ALI_WT"
            If Len(aCols) == 1  
            	aCols[nZ,nyQ] := "SL2"
            EndIf    
         ElseIf aHeader[nyQ,2] == "L2_REC_WT"
            aCols[nZ,nyQ] := 0               
         Endif
       Next
       oGetVa:oBrowse:nAt := nZ
       aCols[nZ,1]        		:= StrZero(Len(aCols),2)
       aCols[nZ,_nPosPrd]  		:= cProduto
       aCols[nZ,_nPosQua]  		:= nQuant2
       aCols[nZ,Len(aHeader)+1] := .F.
    Endif
    
	/*********** Produto ***********/
	M->LR_PRODUTO := aCols[nZ,_nPosPrd]

	If AllTrim( GetAdvFVal("SB1","B1_TIPO",xFilial('SB1') + cProduto,1) ) == "KT"
		aCols[nZ,_nPosPrd] := Space(TamSX3("LR_PRODUTO")[1])
		If Type("n") == "N"
			n := Len(aCols)
		EndIf

		cbkpReadVar := ReadVar()
		__ReadVar	:= "LR_PRODUTO"

		LjKitProd(@aCols, _nItem, cProduto, nQuant2)

		__ReadVar 	:= cbkpReadVar

		lKit := .T.

	ElseIf AllTrim( GetAdvFVal("SB1","B1_TIPO",xFilial('SB1') + cProduto,1) ) == _cMvLjTGar
		If isBlind()
			ConOut( STR0034 + " "  + STR0033) // "anteção" + "A venda de um produto tipo garantia estendida é permitida somente amarrada a um produto com cobertura."
		Else
			Aviso( STR0034 ,STR0033, {STR0035}) //"anteção" + "A venda de um produto tipo garantia estendida é permitida somente amarrada a um produto com cobertura." + "ok"
		EndIf
		lRet := .F.	
	EndIf

	If !lKit .AND. lRet
    	
		// Fazer tratamento para Kit, Bonus, Garantia	 
		SX3->(dbSetOrder(2))
		SX3->(dbSeek("LR_PRODUTO"))
		If ExistTrigger("LR_PRODUTO") .and. nZ != Nil
			RunTrigger(2,nZ)
		EndIf

		/*********** Quant ***********/
		M->LR_QUANT          := aCols[nZ,_nPosQua]

		If Lj7VlItem()
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("LR_QUANT"))
			IF ExistTrigger("LR_QUANT")
				M->LR_QUANT  := aCols[nZ,_nPosQua]
				RunTrigger(2,nZ)
			EndIf	

			//***** Local / Armazem ********* /
			M->LR_LOCAL := cLocPad   
			aColsDetAux   := aClone(aColsDet)
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("LR_LOCAL"))

			IF ExistTrigger("LR_LOCAL")
				M->LR_LOCAL  := cLocPad
				RunTrigger(2,nZ)
			EndIf
		Else
			lRet := .F.
		EndIf

	EndIf	
  	  
ElseIf nPreco == 0
	MsgAlert(STR0024) //Produto cadastrado sem preço
	lRet := .F.
Endif

If !lRet .AND. Len(aCols) > 1 .AND. aCols[Len(aCols),_nPosUni] == 0 // Valida se o ultimo item do aCols foi negado, caso positivo ele é retirado
	ASize( aCols, Len(aCols)-1)
	lRet := .T.
EndIf

If lRet
	
	Dbselectarea("SB1")
	dbSetOrder(nOrdSB1)
	dbGoto(nRegSB1)

	SX3->(dbSetOrder(nOrdSX3))
	SX3->(dbGoto(nRegSX3))	 	  	  
				
	oGetVa:oBrowse:nColPos := aScan(aHeader,{ |X| Upper(AllTrim(x[2])) == "LR_PRODUTO" })        
	oGetva:oBrowse:nRowPos := Len(aCols)
	oGetva:oBrowse:nLen    := Len(aCols)                
	oGetVa:lNewLine := .F.
	oGetva:oBrowse:Refresh()         
	cProd := Space(45)		     
	o_Get1:SetFocus()            

	// Tivemos que chamar a LJ7Vlitem aqui para criar o acolsdet antes da Lj7Prod
	Lj7VlItem( 	Nil, Nil, Nil, Nil,;
				Nil, Nil, Nil, Nil,;
				Nil, Nil, Nil, Nil)

	Lj7Prod(.T.,,.T.,,,IIF(lKit,1,0))

	aHeader701:= aClone(aHeader)
	aCols701  := aClone(aCols)

	aHeader := aClone(aHeaderAux)
	aCols   := aClone(aColsAux)

	For nZ := 1 To Len(aColsDet)
		If ValType(aColsDet[nZ][_nPosDtLocal]) == "U"
			cProduto := aColsDet[nZ][_nPosDtProd]
			aColsDet[nZ][_nPosDtLocal] := GetAdvFVal("SB1","B1_LOCPAD",xFilial('SB1') + cProduto,1)
		EndIf
	Next nY	
	
EndIf

aSize(aHeaderAux,0)
aSize(aColsAux,0)
aSize(aColsDetAux,0)
aHeaderAux 	:= nil
aColsAux 	:= nil
aColsDetAux := nil

Return( lRet )
//------------------------------------------------------------------
/*/{Protheus.doc} LOJPESQE()
Informações de Preço/Fabricante/Aplicação
@type function

@author Marcos Iurato Junior
@since 05/11/2019
@version P12.1.25

@param nOpc, numerico, 
@param oBrw02, objeto, Browse 2
@param cCampPrc, caracter, Campo do preço
@param cLocPad, caracter, Local no estoque
@param cPathImg, caracter, Diretorio da imagem do produto
@param cExtImg, caracter, Verifica se existe a imgame ou não
@param cAliasTmp, caracter, Alias do arquivo temporário
@param cEstRealName, caracter, Nome real do arquivo temporario do estoque
@param cTabTmp, caracter, Tabela temporária
@param cSSRealName, caracter, Nome real do arquivo temporario
@param cTabTmp1, caracter, Tabela temporária 1
@param cSGRealName, caracter, Nome real do arquivo temporario
@param cTabTmp2, caracter, Tabela temporária 2
@param oGet_1, objeto, Get Preço
@param oGet_2, objeto, Get Estoque de venda
@param oGet_3, objeto, Get Modelo
@param oGet_4, objeto, Get Fabricante
@param oGet_5, objeto, Get Caracteristicas do produto

@return, array, logico e inf. Preco, Fabricante e Aplicação
/*/
//------------------------------------------------------------------
Static Function LOJPESQE(nOpc, oBrw02, cCampPrc, cLocPad, cPathImg, cExtImg, cAliasTmp, cEstRealName,;
						 cTabTmp, cSSRealName, cTabTmp1, cSGRealName, cTabTmp2, oGet_1, oGet_2, oGet_3, oGet_4, oGet_5)
           
Local aRetPsqG 	:= {0, "01"}  // 1 - Quantidade do estoque | 2 - Local padrão do Estoque
Local nPreco   	:= 0
Local cFabric  	:= ""
Local cModelo  	:= ""
Local cProduto 	:= (cAliasTmp)->B1_COD
Local cCliente	:= M->LQ_CLIENTE
Local cLojaCli	:= M->LQ_LOJA
Local cLocal 	:= "" //Local padrão do Estoque

cFabric		:= Alltrim((cAliasTmp)->B1_FABRIC)
cModelo		:= Alltrim((cAliasTmp)->B1_MODELO)
cCaracPro	:= Alltrim((cAliasTmp)->CARACB5)

If GetAdvFVal("SB1","B1_TIPO",xFilial('SB1') + cProduto,1) == "KT"

	nPreco := LJVLRKIT(cProduto)

ElseIf SuperGetMv("MV_LJCNVDA",,.F.)  // Indica se existe integracao com cenario de vendas e se esta trabalhando com as tabelas e Precos DA0 e DA1 ou SB0.
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + cProduto) )
	_cTabPad := LjXETabPre(cCliente,cLojaCli)
	nPreco 	:= GetAdvFVal("DA1","DA1_PRCVEN",xFilial('DA1') + _cTabPad + cProduto,1)	
Else
	nPreco := posicione("SB0",1,xFilial("SB0")+alltrim(cProduto), cCampPrc)
Endif

aRetPsqG := LOJPESQG(oBrw02, cLocPad, cAliasTmp, cEstRealName, cTabTmp, oGet_1, oGet_2, oGet_3, oGet_4, oGet_5)	// Dados do Estoque

cLocal := aRetPsqG[1] 

oBrw02:Refresh()
oGet_1:CTEXT := nPreco
oGet_2:CTEXT := cLocal
oGet_3:CTEXT := cModelo
oGet_4:CTEXT := cFabric
oGet_5:Refresh()

LOJPESQJ(cPathImg, cExtImg, cAliasTmp) 							// Foto
LOJPESQH(cSSRealName, cTabTmp1, cCampPrc, aRetPsqG[2])	// Produtos Similares
LOJPESQK(cSGRealName, cTabTmp2, cCampPrc, aRetPsqG[2]) // Sugestão de Vendas (Cross Sell)

aSize(aRetPsqG,0)
aRetPsqG := nil 

Return({.T., cFabric, cModelo, cCaracPro, cLocal, nPreco})

//-----------------------------------------------------------------------
/*/{Protheus.doc} LOJPESQG()
Função responsavel em trazer a informações do Estoque.
@type function

@author Marcos Iurato Junior
@since 05/11/2019
@version P12.1.25

@param oBrw02, objeto, 
@param cLocPad, caracter, Local no estoque
@param cAliasTmp, caracter, Alias do arquivo temporário
@param cEstRealName, caracter, Nome real do arquivo temporario do estoque
@param cTabTmp, caracter, Tabela temporária
@param oGet_1, objeto, Get Preço
@param oGet_2, objeto, Get Estoque de venda
@param oGet_3, objeto, Get Modelo
@param oGet_4, objeto, Get Fabricante
@param oGet_5, objeto, Get Caracteristicas do produto

@return, logico, .T.
/*/
//----------------------------------------------------------------------
Static Function LOJPESQG(oBrw02, cLocPad, cAliasTmp, cEstRealName, cTabTmp, oGet_1, oGet_2, oGet_3, oGet_4, oGet_5)

Local cQry 			:= ""
Local nEstStatus	:= 0
Local cErrorQry		:= ""
Local nEstAll		:= 0
Local cEstCampos  	:= ""
Local cDelete      	:= ""

cLocPad := posicione("SB1", 1, xFilial("SB1")+alltrim((cAliasTmp)->B1_COD), "B1_LOCPAD")

cEstCampos  := "B2_FILIAL, B2_LOCAL, B2_LOCALIZ, B2_QATU, B2_RESERVA" 
//---------------------------------
//Query com informações do Estoque
//---------------------------------
cQry := " SELECT " + cEstCampos
cQry += " FROM "+RetSqlName("SB2")+" SB2"
cQry += " INNER Join "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
cQry += "								AND SB1.B1_COD = SB2.B2_COD"
cQry += "								AND SB1.D_E_L_E_T_ = ' '"
If _cAcessEst == "S" //Visualiza estoque em outras lojas
	cQry += " WHERE SB2.B2_COD = '"+(cAliasTmp)->B1_COD+"'"  
Else 
	cQry += " WHERE SB2.B2_FILIAL = '"+xFilial("SB2")+"'"
	cQry += "  AND SB2.B2_COD = '"+(cAliasTmp)->B1_COD+"'"  
EndIf
cQry += "  AND SB2.B2_LOCAL = '"+cLocPad+"'"
cQry += "  AND SB2.D_E_L_E_T_ = ' '"
cQry += " ORDER BY B2_FILIAL,B2_LOCAL"

//Executa dois comandos (DELETE/INSERT) de uma só vez para diminuir I/O no banco de dados
cDelete    := "DELETE FROM " + cEstRealName+";"
nEstStatus := TCSqlExec(cDelete + " INSERT INTO " + cEstRealName + " ( " +cEstCampos+" ) " + cQry )

If nEstStatus == 0
	Dbselectarea(cTabTmp)
	(cTabTmp)->(DbGotop())

	While !(cTabTmp)->(Eof()) .and. (cTabTmp)->B2_LOCAL == cLocPad
		If (cTabTmp)->B2_FILIAL == xFilial("SB2") 
			nEstAll := (cTabTmp)->B2_QATU - (cTabTmp)->B2_RESERVA
		EndIf
		(cTabTmp)->(Dbskip())
	End 

	Dbselectarea(cTabTmp)
	(cTabTmp)->(DbGotop())
Else
	cErrorQry := TCSQLError()
	LjGrvLog("LOJPESQ", "LOJPESQG | Falha na manipulação da tabela temporaria " + cEstRealName + " | Erro: " + cErrorQry, nEstStatus)
	Final(STR0037 + " " + cEstRealName, cErrorQry) //"Falha na manipulação da tabela temporária"
EndIf

oBrw02:Refresh()

Return({nEstAll, cLocPad})              


//---------------------------------------------------------------------------------
/*/{Protheus.doc} LOJPESQH()
Le os dados dos Produtos similares
@type function

@author Marcos Iurato Junior
@since 05/11/2019
@version P12.1.25

@param cSSRealName, caracter, Nome real do arquivo dos produtos similares
@param cTabTmp1, caracter, Nome da tabela temporaria contendo os registros similares
@param cCampPrc, caracter, Campo do preço
@param cLocPad, caracter, Local no estoque

@return, logico, .T.
/*/
//---------------------------------------------------------------------------------
Static Function LOJPESQH(cSSRealName, cTabTmp1, cCampPrc, cLocPad)

Local cQry 		:= ""
Local nStatus 	:= 0
Local cErrorQry	:= ""
Local nValorKit	:= 0								// Valor do Kir
Local cProduto	:= ""								// Codigo do Produto
Local cFunIsNull:= IIf("ORACLE" $ _cTipoDB,"NVL",IIf("POSTGRES" $ _cTipoDB,"COALESCE","ISNULL")) //Função a ser utilizada de acordo com o Banco de Dados Utilizado
Local cDelete 	:= ""

Default cTabTmp1 := "DA1_PRCVEN"

SB0->(dbSeek(xFilial("SB0") + SB1->B1_COD) )

//--------------------------------------------------------------
//Query para trazer todas as informações dos produtos similares	
//--------------------------------------------------------------
If _lLjCNVDA
	cSSCampos := "B1_FILIAL, B1_COD, B1_DESC, B1_UM, DA1_PRCVEN, B2_LOCAL, B2_LOCALIZ, B2_QATU, B2_RESERVA"
	
	cQry := " SELECT B1_FILIAL, B1_COD, B1_DESC, B1_UM,"
	cQry += " "+cFunIsNull+"(DA1_PRCVEN,0) AS DA1_PRCVEN,"
	cQry += " B2_LOCAL, B2_LOCALIZ, B2_QATU, B2_RESERVA, "+cFunIsNull+"(B5_CODCLI,' ') AS B5_CODCLI"
	cQry += " FROM "+RetSqlName("SB1")+" SB1"
	cQry += "	LEFT JOIN "+RetSqlName("SB0")+" SB0 ON SB0.B0_FILIAL = '"+xFilial("SB0")+"'"
	cQry += "					AND SB0.B0_COD = B1_COD"
	cQry += "					AND SB0.D_E_L_E_T_ = ' '"
	cQry += "	LEFT JOIN "+RetSqlName("DA1")+" DA1 ON DA1.DA1_FILIAL = '"+xFilial("DA1")+"'"
	cQry += "					AND DA1.DA1_CODTAB = '"+_cTabPad+"'"
	cQry += "					AND DA1.DA1_CODPRO = SB1.B1_COD"
	cQry += "					AND DA1.D_E_L_E_T_ = ' '"
	cQry += "	LEFT JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = '"+xFilial("SB2")+"'"
	cQry += "					AND SB2.B2_COD = SB1.B1_COD"
	cQry += "					AND SB2.B2_LOCAL = '"+cLocPad+"'"
	cQry += "					AND SB2.D_E_L_E_T_ = ' '"
	cQry += "	LEFT JOIN "+RetSqlName("SB5")+" SB5 ON SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
	cQry += "					AND SB5.B5_COD = B1_COD"
	cQry += "					AND SB5.D_E_L_E_T_ = ' '"
	cQry += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cQry += "	AND SB1.B1_COD IN ( SELECT ACV_CODPRO"
	cQry += "							FROM "+RetSqlName("ACV")+" ACV"
	cQry += "							WHERE ACV.ACV_FILIAL = '"+xFilial("ACV")+"'"
	cQry += "								  AND ACV.ACV_CATEGO = '"+SB0->B0_SIMILAR+"'"
	cQry += "								  AND ACV.D_E_L_E_T_ = ' ' )"
	cQry += "	AND SB1.D_E_L_E_T_ = ' '"
		
Else

	cSSCampos := "B1_FILIAL, B1_COD, B1_DESC, B1_UM, " + cCampPrc + ", B2_LOCAL, B2_LOCALIZ, B2_QATU, B2_RESERVA"

	cQry := " SELECT B1_FILIAL, B1_COD, B1_DESC, B1_UM,"
	cQry += " "+cFunIsNull+"(" + cCampPrc + ",0) AS " + cCampPrc + ","
	cQry += " B2_LOCAL, B2_LOCALIZ, B2_QATU, B2_RESERVA, "+cFunIsNull+"(B5_CODCLI,' ') AS B5_CODCLI"
	cQry += " FROM "+RetSqlName("SB1")+" SB1"
	cQry += "	LEFT JOIN "+RetSqlName("SB0")+" SB0 ON SB0.B0_FILIAL = '"+xFilial("SB0")+"'"
	cQry += "					AND SB0.B0_COD = B1_COD"
	cQry += "					AND SB0.D_E_L_E_T_ = ' '"
	cQry += "	LEFT JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = '"+xFilial("SB2")+"'"
	cQry += "					AND SB2.B2_COD = SB1.B1_COD"
	cQry += "					AND SB2.B2_LOCAL = '"+cLocPad+"'"
	cQry += "					AND SB2.D_E_L_E_T_ = ' '"
	cQry += "	LEFT JOIN "+RetSqlName("SB5")+" SB5 ON SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
	cQry += "					AND SB5.B5_COD = B1_COD"
	cQry += "					AND SB5.D_E_L_E_T_ = ' '"
	cQry += "	LEFT JOIN "+RetSqlName("ACV")+" ACV ON ACV.ACV_FILIAL = '"+xFilial("ACV")+"'"
	cQry += "					AND ACV.ACV_CODPRO = B1_COD"
	cQry += "					AND ACV.D_E_L_E_T_ = ' '"
	cQry += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cQry += "	AND SB1.B1_COD IN ( SELECT ACV_CODPRO"
	cQry += "							FROM "+RetSqlName("ACV")+" ACV"
	cQry += "							WHERE ACV.ACV_FILIAL = '"+xFilial("ACV")+"'"
	cQry += "								  AND ACV.ACV_CATEGO = '"+SB0->B0_SIMILAR+"'"
	cQry += "								  AND ACV.D_E_L_E_T_ = ' ' )"
	cQry += "	AND SB1.D_E_L_E_T_ = ' '"

Endif

//Executa dois comandos (DELETE/INSERT) de uma só vez para diminuir I/O no banco de dados
cDelete := " DELETE FROM "+cSSRealName+";"
nStatus := TCSqlExec(cDelete +  " INSERT INTO " + cSSRealName + " ( " + cSSCampos + ", B5_CODCLI) " + cQry )

If nStatus == 0
	Dbselectarea(cTabTmp1)
	(cTabTmp1)->(DbGotop())

	While (cTabTmp1)->(!EOF())
		cProduto := &( (cTabTmp1) + "->B1_COD" )
		If &((cTabTmp1) + "->" + cCampPrc)  == 0 .AND. GetAdvFVal("SB1","B1_TIPO",xFilial('SB1') + cProduto,1) == "KT"
			nValorKit := LJVLRKIT(cProduto)

			Reclock( cTabTmp1, .F. )
			(cTabTmp1)->cCampPrc := nValorKit
			(cTabTmp1)->(MsUnLock())
		EndIf
		(cTabTmp1)->(dbSkip())
	EndDo

	(cTabTmp1)->(DbGotop())

Else
	cErrorQry := TCSQLError()
	LjGrvLog("LOJPESQ","LOJPESQH | Falha na manipulação da tabela temporaria " + cSSRealName + " | Erro: " + cErrorQry, nStatus)
	Final(STR0037 + " " + cSSRealName, cErrorQry) //"Falha na manipulação da tabela temporária"
EndIf

oBrw03:Refresh()

Return(.T.)


//------------------------------------------------------------------
/*/{Protheus.doc} LOJPESQJ()
Chama figura do produto

@type function

@author Marcos Iurato Junior
@since 05/11/2019
@version P12.1.25

@param cPathImg, caracter, Diretorio da imagem do produto
@param cExtImg, caracter, Verifica se existe a imgame ou não
@param cAliasTmp, caracter, Alias temporario

@return, logico, .T.
/*/
//------------------------------------------------------------------
Static Function LOJPESQJ(cPathImg, cExtImg, cAliasTmp)

Local oImg	:= Nil
Local cFotCon := cPathImg + Alltrim((cAliasTmp)->B1_COD) + cExtImg
Local cSFotCo := cPathImg + "semfoto" + cExtImg

oImg := TBitmap():New( 080,463,C(90),C(64), ,"",.T.,odlg1,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
oImg:lStretch:= .T.
oImg:SetEmpty()             
oImg:Load( Nil ,"" )

If !oImg:Load( Nil ,cFotCon  ) 
	If !oImg:Load( Nil ,cSFotCo)	 
		oImg:SetEmpty()
	EndIf
EndIf 

oImg:Refresh()	

Return(.T.)


//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOJPESQK()
Le os dados dos Produtos Sugestão de Vendas (Cross Sell)

@type function

@author Marcos Iurato Junior
@since 05/11/2019
@version P12.1.25

@param cSGRealName, caracter, Nome real do arquivo de sugestão de venda
@param cTabTmp2, caracter, Nome da tabela temporaria contendo os registros de sugestão de venda
@param cCampPrc, caracter, Campo do preço
@param cLocPad, caracter, Local no estoque

@return, logico, .T.
/*/
//-------------------------------------------------------------------------------------------
Static Function LOJPESQK(cSGRealName, cTabTmp2, cCampPrc, cLocPad)

Local cQry 		:= ""
Local nStatus   := 0
Local cErrorQry	:= ""
Local nValorKit	:= 0							// Valor do Kit
Local cFunIsNull:= IIf("ORACLE" $ _cTipoDB,"NVL",IIf("POSTGRES" $ _cTipoDB,"COALESCE","ISNULL")) //Função a ser utilizada de acordo com o Banco de Dados Utilizado
Local cDelete	:= ""

Default cTabTmp2 := "DA1_PRCVEN"

SB0->(dbSeek(xFilial("SB0") + SB1->B1_COD) )

//--------------------------------------------------------------
//Query para trazer todas as informações dos produtos similares	
//--------------------------------------------------------------

If _lLjCNVDA

	cSGCampos := "B1_FILIAL, B1_COD, B1_DESC, B1_UM, DA1_PRCVEN, B2_LOCAL, B2_LOCALIZ, B2_QATU, B2_RESERVA"

	cQry := " SELECT " + "B1_FILIAL, B1_COD, B1_DESC, B1_UM,"
	cQry += " "+cFunIsNull+"(DA1_PRCVEN,0) AS DA1_PRCVEN,"
	cQry += " B2_LOCAL, B2_LOCALIZ, B2_QATU, B2_RESERVA" + " , "+cFunIsNull+"(B5_CODCLI,' ') AS B5_CODCLI"
	cQry += " FROM "+RetSqlName("SB1")+" SB1" 
	cQry += "	LEFT JOIN "+RetSqlName("DA1")+" DA1 ON DA1.DA1_FILIAL = '"+xFilial("DA1")+"'"
	cQry += "						AND DA1.DA1_CODTAB = '"+_cTabPad+"'"
	cQry += "						AND DA1.DA1_CODPRO = SB1.B1_COD"
	cQry += "						AND DA1.D_E_L_E_T_ = ' '"
	cQry += "	LEFT JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = '"+xFilial("SB2")+"'"
	cQry += "					AND SB2.B2_COD = SB1.B1_COD"
	cQry += "					AND SB2.B2_LOCAL = '"+clocPad+"'"
	cQry += "					AND SB2.D_E_L_E_T_ = ' '"
	cQry += "	LEFT JOIN "+RetSqlName("SB5")+" SB5 ON SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
	cQry += "						AND SB5.B5_COD = B1_COD"
	cQry += "						AND SB5.D_E_L_E_T_ = ' '"
	cQry += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cQry += "	AND SB1.B1_COD IN ( SELECT ACV_CODPRO"
	cQry += "							FROM "+RetSqlName("ACV")+" ACV"
	cQry += "							WHERE ACV.ACV_FILIAL = '"+xFilial("ACV")+"'"
	cQry += "								  AND ACV.ACV_CATEGO = '"+SB0->B0_SUGVEN+"'"
	cQry += "								  AND ACV.D_E_L_E_T_ = ' ' )"
	cQry += "	AND SB1.D_E_L_E_T_ = ' '"

Else

	cSGCampos := "B1_FILIAL, B1_COD, B1_DESC, B1_UM, " + cCampPrc + " , B2_LOCAL, B2_LOCALIZ, B2_QATU, B2_RESERVA"

	cQry := " SELECT B1_FILIAL, B1_COD, B1_DESC, B1_UM,"
	cQry += " "+cFunIsNull+"(" + cCampPrc + ",0) AS " + cCampPrc + ","
	cQry += " B2_LOCAL, B2_LOCALIZ, B2_QATU, B2_RESERVA, "+cFunIsNull+"(B5_CODCLI,' ') AS B5_CODCLI"
	cQry += " FROM "+RetSqlName("SB1")+" SB1"
	cQry += "	LEFT JOIN "+RetSqlName("SB0")+" SB0 ON SB0.B0_FILIAL = '"+xFilial("SB0")+"'"
	cQry += "						AND SB0.B0_COD = B1_COD"
	cQry += "						AND SB0.D_E_L_E_T_ = ' '"
	cQry += "	LEFT JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = '"+xFilial("SB2")+"'"
	cQry += "					AND SB2.B2_COD = SB1.B1_COD"
	cQry += "					AND SB2.B2_LOCAL = '"+cLocPad+"'"
	cQry += "					AND SB2.D_E_L_E_T_ = ' '"
	cQry += "	LEFT JOIN "+RetSqlName("SB5")+" SB5 ON SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
	cQry += "						AND SB5.B5_COD = B1_COD"
	cQry += "						AND SB5.D_E_L_E_T_ = ' '"
	cQry += "	LEFT JOIN "+RetSqlName("ACV")+" ACV ON ACV.ACV_FILIAL = '"+xFilial("ACV")+"'"
	cQry += "						AND ACV.ACV_CODPRO = B1_COD"
	cQry += "						AND ACV.D_E_L_E_T_ = ' '"
	cQry += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cQry += "	AND SB1.B1_COD IN ( SELECT ACV_CODPRO"
	cQry += "							FROM "+RetSqlName("ACV")+" ACV"
	cQry += "							WHERE ACV.ACV_FILIAL = '"+xFilial("ACV")+"'"
	cQry += "								  AND ACV.ACV_CATEGO = '"+SB0->B0_SUGVEN+"'"
	cQry += "								  AND ACV.D_E_L_E_T_ = ' ' )"
	cQry += "	AND SB1.D_E_L_E_T_ = ' '"
	
Endif                                                                                                                        

//Executa dois comandos (DELETE/INSERT) de uma só vez para diminuir I/O no banco de dados
cDelete := " DELETE FROM " + cSGRealName+";"
nStatus := TCSqlExec( cDelete + " INSERT INTO " + cSGRealName + " ( " + cSGCampos + ", B5_CODCLI)" +  cQry )

If nStatus == 0

	Dbselectarea(cTabTmp2)
	(cTabTmp2)->(DbGotop())

	While (cTabTmp2)->(!EOF())
		cProduto := &( (cTabTmp2) + "->B1_COD" )
		If &((cTabTmp2) + "->" + cCampPrc) == 0 .AND. GetAdvFVal("SB1","B1_TIPO",xFilial('SB1') + cProduto,1) == "KT"
			nValorKit := LJVLRKIT(cProduto)

			Reclock( cTabTmp2, .F. )
			(cTabTmp2)->&(cCampPrc) := nValorKit
			(cTabTmp2)->(MsUnLock())
		EndIf
		(cTabTmp2)->(dbSkip())
	EndDo

	(cTabTmp2)->(DbGotop())

Else
	cErrorQry := TCSQLError()
	LjGrvLog("LOJPESQ", "LOJPESQK | Falha na manipulação da tabela temporaria " + cSGRealName + " | Erro: " + cErrorQry, nStatus)
	Final(STR0037 + " " + cSGRealName, cErrorQry) //"Falha na manipulação da tabela temporária"
EndIf

oBrw04:Refresh()

Return(.T.)

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} LJVLRKIT()
Retorna valor do Kit

@type function
@author JMM
@since 12/03/2020
@version P12.1.30
@param cProdKit, caracter, código do produto Kit
@return, nValorKit, numerico,  Valor final do Kit
/*/
//-------------------------------------------------------------------------------------------

FuncTion LJVLRKIT(cProdKit)
Local nDesconto		:= 0																		// Valor percentual do desconto
Local nValorKit		:= 0																		// Valor final do Kit
Local cAliasKit		:= GetNextAlias()
Local cQry			:= ""
Local nX			:= 0																		// Contador do For
Local nPrcUnit		:= 0																		// Preço unitário do item do Kit
Local nVlrItem		:= 0 																		// Valor do item do Kit
Local nDecimais 	:= MsDecimais(nMoedaCor)													// Casas decimais que esta trabalhando o sistema
Local cCampPrc		:= "B0_PRV" + _cTabPad  														// Tabela de preço
Local aValorKit		:= {}																		// Array que guarda o valor de cada item do Kit
Local aAreaSB1		:= SB1->(GetArea())

dbSelectArea("MEU")
MEU->(DbSetOrder(1)) // MEU_FILIAL+MEU_CODIGO
If MEU->(dbSeek(xFilial("MEU") + PadR(AllTrim(cProdKit),TamSX3("MEU_CODIGO")[1])))
	If !Empty(MEU->MEU_DESCNT) // Caso o desconto esteja preenchido no cabecalho, esse desconto sera utilizado.
		nDesconto := MEU->MEU_DESCNT
	EndIf
EndIf

cQry := " SELECT MEV_PRODUT, MEV_QTD, MEV_DESCNT" 
cQry += " FROM "+RetSqlName("MEV")+" MEV"
cQry += " WHERE MEV_FILIAL = '" + xFilial("MEV") + "'"
cQry += " AND MEV_CODKIT = '" + cProdKit + "'"
cQry += " AND D_E_L_E_T_ = ' '"

cQry := ChangeQuery( cQry )

dbUseArea(.T.,"TOPCONN",TcGenQry(,, cQry ), cAliasKit ,.T.,.F.)
(cAliasKit)->(dbGoTop())

While (cAliasKit)->( !EOF() )

	If _lLjCNVDA
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + (cAliasKit)->MEV_PRODUT) )
		_cTabPad		:= LjXETabPre(M->LQ_CLIENTE, M->LQ_LOJA)
		nPrcUnit	:= GetAdvFVal("DA1","DA1_PRCVEN",xFilial('DA1') + _cTabPad + (cAliasKit)->MEV_PRODUT,1)
	Else
		nPrcUnit := GetAdvFVal("SB0",cCampPrc,xFilial('SB0') + (cAliasKit)->MEV_PRODUT,1)
	Endif

	If nDesconto > 0
		nPrcUnit := nPrcUnit - ( nPrcUnit * (nDesconto / 100) )
	Else
		nPrcUnit := nPrcUnit - ( nPrcUnit * ((cAliasKit)->MEV_DESCNT / 100) )			
	EndIf

	If _lMvArrefat
		nVlrItem := Round( nPrcUnit * (cAliasKit)->MEV_QTD , nDecimais)
	Else
		nVlrItem := NoRound( nPrcUnit * (cAliasKit)->MEV_QTD, nDecimais)
	EndIf

	aadd( aValorKit, nVlrItem )

	(cAliasKit)->(dbSkip())
EndDo

For nX := 1 To Len(aValorkit)
	nValorKit  += aValorKit[nX]
Next nY

LjGrvLog("LOJPESQ"," LJVLRKIT | Valor do Kit " + cProdKit, nValorKit)

(cAliasKit)->(DBCloseArea())
RestArea(aAreaSB1)

aSize(aValorKit,0)
aValorKit := nil 

Return( nValorKit )
