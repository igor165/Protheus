#INCLUDE 'PROTHEUS.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "LOJA865.CH"

Static aLocais     := {}
Static cBProdLine  := "{|| { aProdutos[oListProd:nat,1], Left(aProdutos[oListProd:nat,2],40), Str(aProdutos[oListProd:nat,3],15,2), Str(aProdutos[oListProd:nat,4],15), Left(aProdutos[oListProd:nat,5],7), Left(aProdutos[oListProd:nat,6],10),Left(aProdutos[oListProd:nat,7],10) } }"
Static cBArmazLine := "{|| { aArmazens[oListArmaz:nat,1], aArmazens[oListArmaz:nat,2], aArmazens[oListArmaz:nat,3], '' } }"
Static cBCategLine := "{|| { aCategoria[oListCateg:nat,1], aCategoria[oListCateg:nat,2], aCategoria[oListCateg:nat,3]} }"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LOJA865  บAutor  ณ Antonio C Ferreira บ Data ณ  09/04/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina Central de Cadastros do e-Commerce.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Webservice                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function LOJA865()

Local nOpcA       := 0        //Confirmacao de gravacao
Local aObj        := {}       //Matriz para dimensionamento da tela de dialogo
Local aSizeAut    := {}       //Matriz para dimensionamento da tela de dialogo
Local aInfo       := {}       //Matriz para dimensionamento da tela de dialogo
Local aPObj       := {}       //Matriz para dimensionamento da tela de dialogo
Local oDlg        := nil      //Objeto do dialogo
                   
Local oStatus     := nil        //Objeto do campo Status             
Local cStatus     := STR0002    //Valor do campo Status                           //"Nใo e-Commerce"
Local oProduto    := nil        //Objeto do campo produto
Local cProduto    := Space(30)  //Valor do campo produto
Local oProdutoPai := nil        //Objeto do campo Produto pai
Local cProdutoPai := ""         //Valor do campo Produto pai
Local cXProdPai   := ""         //Campo auxiliar para produto pai 
Local aProdutos   := {}         //matriz para listar os produtos filhos
Local oListProd   := nil        //Objeto da lista de produtos filhos 
Local oPrecoCheio := nil        //Objeto do campo PrecoCheio
Local nPrecoCheio := 0          //Valor do campo Precocheio
Local nPrecoTab   := 0          //Valor do campo PrecoTab
Local oFornecedor := nil        //Objeto do campo Fornecedor
Local cFornecedor := STR0003    //Valor do campo Fornecedor                        //"<< SEM FORNECEDOR >>"
Local oListCateg  := nil        //Objeto da lista de categorias 
Local aCategoria  := {}         //matriz para listar as categorias
Local oListArmaz  := nil        //Objeto da lista de armazens
Local aArmazens   := {}         //matriz dos aramazens da tabela MF6.
Local oCheckBox1  := nil        //Objeto dos CheckBoxes com o status se o produto podera ou nao ser exportado para o e-Commerce
Local oIcon01     := nil        //Icone 01 informando se o produto esta flegado para e-Commerce 
Local oIcon02     := nil        //Icone 02 informando se o preco cheio foi cadastrado para e-Commerce.
Local oIcon03     := nil        //Icone 03 informando se o Estoque Minimo foi cadastrado para e-Commerce
Local oIcon04     := nil        //Icone 04 informando se o produto foi amarrado a alguma categoria para e-Commerce
Local oIcon05     := nil        //Icone 05 informando se os Armazens do produto foram cadastrados para e-Commerce 
Local oIcon06     := nil        //Icone 06 informando se o arquivo IntEcomm.ini foi configurado para este grupo de empresa/filial com o endereco WS do e-Commerce 
Local oFonte      := nil        //Objeto do fonte do dialogo
Local oEstqMinimo := nil        //Objeto do campo EstqMinimo
Local nEstqMinimo := 0          //Valor do campo Estoque Minimo
Local oBtn1       := nil        //Botao para gravar os campos do dialogo
Local oBtn2       := nil        //Botao para acessar o cadastro de produtos 
Local oBtn3       := nil        //Botao para acessar o cadastro de Tabela de grade
Local oBtn4       := nil        //Botao para acessar o cadastro de Grade de Produto
Local oBtn5       := nil        //Botao para acessar o cadastro de Complemento de Produto
Local oBtn6       := nil        //Botao para acessar o cadastro de Categorias
Local oBtn7       := nil        //Botao para acessar o cadastro de Amarracao Categoria X Produto
Local oBtn8       := nil        //Botao para acessar o cadastro de Fornecedor
Local oBtn9       := nil        //Botao para acessar o cadastro de Amarracao Produto X Fornecedor
Local oBtnA       := nil        //Botao para gerar os Armazens e-commerce baseado na tabela MF6 
Local oBtnB       := nil        //Botao para sair do dialogo.
Local oIntEcomm   := nil        //Objeto da descri็ใo IntEcomm

Local lIntEcomm   := LJ861Emps("LOJA865", cEmpAnt, cFilAnt,,) //Verifica se o arquivo IntEcomm.ini esta configurado para este Grupo de empresa/filial.

Local nCor      := 239

Local cCadastro := STR0001  //"Central de Cadastros do e-Commerce"

nOpcA:=0
                
aObj := {}

aSizeAut  := MsAdvSize()

// Serแ utilizado tr๊s แreas na janela
// 1- Enchoice, sendo 80 pontos pixel
// 2- MsGetDados, o que sobrar em pontos pixel ้ para este objeto
// 3- Rodap้ que ้ a pr๓pria janela, sendo 15 pontos pixel

aProdutos  := {{"",Space(48),0,0,"", "", ""}} //{Produto, Descricao, Preco de tabela (SB0), Estoque, e-commerce, linha, coluna}
             
aCategoria := {{"",Space(25),""}} //{Categoria, Descricao, Categoria Pai}             

aArmazens  := {{"","",0}} //{Filial, Armazem, Estoque Disponivel, Branco}

//Fonte para o Listbox poder alinha os numeros com casa decimal.
DEFINE FONT oFonte NAME "Courier" SIZE 0, -11 

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	oPanel:= tPanel():New(02, 02, "", oDlg,,,,/*Cor Texto*/,RGB(nCor,nCor,nCor)/*Cor Fundo*/, aSizeAut[3]-1,aSizeAut[4]+5,.T.,.T.)
                                  
	@ 014,010  SAY STR0004	             SIZE 60, 09 OF oPanel PIXEL     //"Produto:"
	@ 012,035  MSGET oProduto Var cProduto   SIZE 125, 09  Picture("@!") F3 "SB1" OF oPanel PIXEL ;
                     Valid( LJ865Produto(cProduto, @oIcon01, @oStatus, @cStatus,; 
                                         @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,; 
                                         @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,; 
                                         @aProdutos, @oListProd, @oIcon04, @aCategoria,; 
                                         @oListCateg, @oIcon05, @aArmazens, @oListArmaz, @oIntEcomm, @oIcon06) )

	@ 011,163 ICON oIcon01 RESOURCE "UnChecked" When(.F.) OF oPanel PIXEL    //[] UnChecked / [ok] Checked / [X] NoChecked 

	@ 014,175  SAY oStatus Prompt cStatus	SIZE 60, 09 Color CLR_HRED OF oPanel PIXEL     

	@ 014,240  SAY STR0005              SIZE 65, 09 OF oPanel PIXEL     //"Pre็o Cheio(Pai):"
	@ 012,283  MSGET oPrecoCheio Var nPrecoCheio    SIZE 65, 09 Picture PesqPict("SB1","B1_PRV1") OF oPanel PIXEL Valid(LJ865Valor(nPrecoCheio, nil))
	
	@ 011,370 ICON oIcon02 RESOURCE "NoChecked" When(.F.) OF oPanel PIXEL    //[] UnChecked / [ok] Checked / [X] NoChecked 
	@ 014,382  SAY STR0006	          SIZE 60, 09 OF oPanel PIXEL      //"Pre็o Tabela:"
	@ 012,417  MSGET oPrecoTab Var nPrecoTab  SIZE 70, 09 Picture PesqPict("SB0","B0_PRV1") OF oPanel PIXEL Valid(LJ865Valor(nPrecoTab, @oIcon02))
      
	If  lIntEcomm
		@ 027,010 ICON oIcon06 RESOURCE "Checked" When(.F.) OF oPanel PIXEL    //[] UnChecked / [ok] Checked / [X] NoChecked 
		@ 030,022  SAY oIntEcomm Prompt STR0046 SIZE 150, 09 Color CLR_HBLUE OF oPanel PIXEL      //"Configura็ใo IntEcomm.ini"
	Else
		@ 027,010 ICON oIcon06 RESOURCE "NoChecked" When(.F.) OF oPanel PIXEL    //[] UnChecked / [ok] Checked / [X] NoChecked 
		@ 030,022  SAY oIntEcomm Prompt STR0046 SIZE 150, 09 Color CLR_HRED OF oPanel PIXEL      //"Configura็ใo IntEcomm.ini"
    EndIf
	
	@ 030,242  SAY STR0007                   SIZE 65, 09 OF oPanel PIXEL      //"Estoque Mํnimo:"
	@ 028,283  MSGET oEstqMinimo Var nEstqMinimo    SIZE 65, 09 Picture PesqPict("SB2","B2_QATU") OF oPanel PIXEL Valid(LJ865Valor(nEstqMinimo, nil)) 
    
	@ 027,370 ICON oIcon03 RESOURCE "NoChecked" When(.F.) OF oPanel PIXEL    //[] UnChecked / [ok] Checked / [X] NoChecked 
	@ 030,382  SAY STR0008	           SIZE 060, 09 OF oPanel PIXEL     //"Fornecedor:"
	@ 030,418  SAY oFornecedor Var cFornecedor SIZE 200, 09 OF oPanel PIXEL     

	@ 046,010  SAY STR0009   SIZE 100, 09 OF oPanel PIXEL     //"Produtos filhos do produto: "
	@ 046,076  SAY oProdutoPai Prompt cProdutoPai 	SIZE 200, 09 OF oPanel PIXEL     
	@ 056,010 ListBox oListProd Fields HEADER STR0011, STR0012, STR0043, STR0017, STR0048, STR0049, STR0050 Size 335,110 Pixel  //"C๓digo"##"Descri็ใo"##"     Pre็o Tabela"##"Estoque Disponํvel"#"E-commerce"# "Linha"# "Coluna"
	oListProd:SetFont(oFonte)
	oListProd:SetArray(aProdutos)
	If  (Len(aProdutos) > 0) 
		oListProd:bLine := &(cBProdLine)
	EndIf	
	
	@ 166,010 ICON oIcon04 RESOURCE "NoChecked" When(.F.) OF oPanel PIXEL    //[] UnChecked / [ok] Checked / [X] NoChecked 
	@ 169,022  SAY STR0010	      SIZE 140, 09 OF oPanel PIXEL     //"Categorias do Produto:"
	@ 169,078  SAY oProdutoPai Prompt cProdutoPai SIZE 048, 09 OF oPanel PIXEL
	
	@ 179,010 ListBox oListCateg Fields HEADER STR0011, STR0012, STR0013 Size 180,100 Pixel  //"C๓digo"##"Descri็ใo"##"Pai"
	oListCateg:SetFont(oFonte)
	oListCateg:SetArray(aCategoria)
	If  (Len(aCategoria) > 0)
		oListCateg:bLine := &(cBCategLine)
	EndIf	

	@ 166,195 ICON oIcon05 RESOURCE "NoChecked" When(.F.) OF oPanel PIXEL    //[] UnChecked / [ok] Checked / [X] NoChecked 
	@ 169,207  SAY STR0014	   SIZE 140, 09 OF oPanel PIXEL      //"Armaz้ns do produto:"
	@ 169,265  SAY oProduto Var cProduto       SIZE 050, 09 OF oPanel PIXEL     
	@ 179,195 ListBox oListArmaz Fields HEADER STR0015, STR0016, STR0017 Size 150,100 Pixel  //"Filial"##"Armaz้m"##"Estoque Disponํvel"
	oListArmaz:SetFont(oFonte)
	oListArmaz:SetArray(aArmazens)
	If  (Len(aArmazens) > 0)
		oListArmaz:bLine := &(cBArmazLine)
	EndIf
	
	//Linha
	@ 051,350 TO 235,520 Prompt STR0018 Color RGB(0,128,255)	OF oPanel PIXEL       //"CADASTROS NECESSมRIOS PARA E-COMMERCE"

	@ 061,360 BUTTON oBtn1 Prompt STR0019 SIZE 150,015 PIXEL Action( LJ865GrPreco(cProduto, nPrecoCheio, @oIcon02, nPrecoTab,; 
	                                                                               nEstqMinimo, @cXProdPai, @cProdutoPai, @aProdutos,;
	                                                                               @oListProd) ) OF oPanel   //"Gravar campos alterados acima!"
	oBtn1:nClrText := RGB(0,0,255)

	@ 076,360 BUTTON oBtn2 Prompt STR0020 SIZE 150,015 PIXEL Action( LJ865CadProd(cProduto, @oIcon01, @oStatus, @cStatus,; 
	                                                                               @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,; 
	                                                                               @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,;
	                                                                               @aProdutos, @oListProd, @oIcon04, @aCategoria,; 
	                                                                               @oListCateg, @oIcon05, @aArmazens, @oListArmaz,;
	                                                                               @oIntEcomm, @oIcon06) ) OF oPanel  //"Produto (Simples)"
	oBtn2:nClrText := RGB(0,0,255)

	@ 091,360 BUTTON oBtn3 Prompt STR0021 SIZE 150,015 PIXEL Action( LJ865TabGrad(cProduto, @oIcon01, @oStatus, @cStatus,; 
	                                                                               @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,; 
	                                                                               @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,; 
	                                                                               @aProdutos, @oListProd, @oIcon04, @aCategoria,; 
	                                                                               @oListCateg, @oIcon05, @aArmazens, @oListArmaz,;
	                                                                               @oIntEcomm, @oIcon06) ) OF oPanel  //"Tabela de Grade"
	oBtn3:nClrText := RGB(0,0,255)

	@ 106,360 BUTTON oBtn4 Prompt STR0022 SIZE 150,015 PIXEL Action( LJ865GradPro(cProduto, @oIcon01, @oStatus, @cStatus,; 
	                                                                               @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,; 
	                                                                               @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,; 
	                                                                               @aProdutos, @oListProd, @oIcon04, @aCategoria,; 
	                                                                               @oListCateg, @oIcon05, @aArmazens, @oListArmaz,;
	                                                                               @oIntEcomm, @oIcon06) ) OF oPanel   //"Grade de Produto (Pai e Filho-SKU)"
	oBtn4:nClrText := RGB(0,0,255)

	@ 121,360 BUTTON oBtn5 Prompt STR0023 SIZE 150,015 PIXEL Action( LJ865Complem(cProduto, @oIcon01, @oStatus, @cStatus,; 
	                                                                               @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,; 
	                                                                               @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,; 
	                                                                               @aProdutos, @oListProd, @oIcon04, @aCategoria,; 
	                                                                               @oListCateg, @oIcon05, @aArmazens, @oListArmaz,; 
	                                                                               @oIntEcomm, @oIcon06) ) OF oPanel   //"Complemento de Produto"
	oBtn5:nClrText := RGB(0,0,255)

	@ 136,360 BUTTON oBtn6 Prompt STR0024 SIZE 150,015 PIXEL Action( LJ865Categ(cProduto, @oIcon01, @oStatus, @cStatus,; 
	                                                                             @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,; 
	                                                                             @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,; 
	                                                                             @aProdutos, @oListProd, @oIcon04, @aCategoria,; 
	                                                                             @oListCateg, @oIcon05, @aArmazens, @oListArmaz,; 
	                                                                             @oIntEcomm, @oIcon06) ) OF oPanel     //"Categoria"
	oBtn6:nClrText := RGB(0,0,255)

	@ 151,360 BUTTON oBtn7 Prompt STR0025 SIZE 150,015 PIXEL Action( LJ865CatProd(cProduto, @oIcon01, @oStatus, @cStatus,; 
	                                                                               @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,; 
	                                                                               @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,; 
	                                                                               @aProdutos, @oListProd, @oIcon04, @aCategoria,; 
	                                                                               @oListCateg, @oIcon05, @aArmazens, @oListArmaz,; 
	                                                                               @oIntEcomm, @oIcon06) ) OF oPanel   //"Categoria X Produto"
	oBtn7:nClrText := RGB(0,0,255)
  
	@ 166,360 BUTTON oBtn8 Prompt STR0026 SIZE 150,015 PIXEL Action( LJ865Fornece(cProduto, @oIcon01, @oStatus, @cStatus,; 
	                                                                               @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,; 
	                                                                               @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,; 
	                                                                               @aProdutos, @oListProd, @oIcon04, @aCategoria,; 
	                                                                               @oListCateg, @oIcon05, @aArmazens, @oListArmaz,; 
	                                                                               @oIntEcomm, @oIcon06) ) OF oPanel    //"Fornecedor"
	oBtn8:nClrText := RGB(0,0,255)

	@ 181,360 BUTTON oBtn9 Prompt STR0027 SIZE 150,015 PIXEL Action( LJ865ProdFor(cProduto, @oIcon01, @oStatus, @cStatus,; 
	                                                                               @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,; 
	                                                                               @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,; 
	                                                                               @aProdutos, @oListProd, @oIcon04, @aCategoria,; 
	                                                                               @oListCateg, @oIcon05, @aArmazens, @oListArmaz,; 
	                                                                               @oIntEcomm, @oIcon06) ) OF oPanel     //"Produto X Fornecedor"
	oBtn9:nClrText := RGB(0,0,255)

	@ 196,360 BUTTON oBtnA Prompt STR0028 SIZE 150,015 PIXEL Action( LJ865GerEstq(cProduto, @oIcon05, @aArmazens, @oListArmaz) ) OF oPanel  //"Gerar Armaz้ns e-Commerce"
	oBtnA:nClrText := RGB(0,0,255)

	@ 211,360 BUTTON oBtnB Prompt STR0029 SIZE 150,015 PIXEL Action( LJ865GrPreco(cProduto, nPrecoCheio, @oIcon02, nPrecoTab,; 
	                                                                               nEstqMinimo, @cXProdPai, @cProdutoPai, @aProdutos,; 
	                                                                               @oListProd), oDlg:End() ) OF oPanel  //"<<< SAIR >>>"
	oBtnB:nClrText := RGB(0,0,255)

ACTIVATE MSDIALOG oDLG 

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LJ865Valor บ Autor ณ Antonio C Ferreira บ Data ณ 12/04/2013  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validar campos numericos.                                    บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnValor - valor a ser validado                                 บฑฑ
ฑฑบ          ณoIcon  - Icone que ira apresentar o status do valor na tela   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ865Valor(nValor, oIcon)

Local lRet := .T.

Default nValor  := 0
Default oIcon   := nil

If  (nValor < 0)
    Alert(STR0030)   //"Valor negativo nใo permitido!"
    lRet := .F.
EndIf

If  lRet .And. !( Empty(oIcon) )
	If  (nValor > 0)
	    oIcon:SetBmp("Checked")
	Else
	    oIcon:SetBmp("NoChecked")
	EndIf    
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ865GrPrecoบ Autor ณ Antonio C Ferreira บ Data ณ 16/04/2013  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava os pre็os e qtde mํnima no cadastro do produto pai.    บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cProduto - codigo do produto                                 บฑฑ
ฑฑบ          ณ nPrecoCheio - Valor do preco cheio                           บฑฑ
ฑฑบ          ณ oIcon02 - apresenta o status do preco na tela                บฑฑ
ฑฑบ          ณ nPrecoTab - Valor do preco de tabela                         บฑฑ
ฑฑบ          ณ nEstqMinimo - valor do estoque minimo                        บฑฑ
ฑฑบ          ณ cXProdPai - campo auxiliar para o produto pai                บฑฑ
ฑฑบ          ณ cProdutoPai - valor do produto pai                           บฑฑ
ฑฑบ          ณ aProdutos - lista de produtos filhos                         บฑฑ
ฑฑบ          ณ oListProd - objeto da lista de produtos filhos               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ865GrPreco(cProduto, nPrecoCheio, oIcon02, nPrecoTab,;
                             nEstqMinimo, cXProdPai, cProdutoPai, aProdutos,;
                             oListProd)

Local lOk1 		 := .F.       //Confirmacao da gravacao do Preco Cheio
Local lOk2 		 := .F.       //Confirmacao da gravacao do preco de tabela
Local lOk3 		 := .F.       //Confirmacao da gravacao do estoque minimo
Local nXPrecoTab := 0         //Variavel auxiliar para o preco de tabela
Local cCmpPreco  := "B0_PRV"+AllTrim(SuperGetMV("MV_LJECOMT",,SuperGetMV("MV_TABPAD")))  //Campo da tabela de preco para o e-commerce

Default cProduto    := ""
Default nPrecoCheio := 0
Default oIcon02     := nil
Default nPrecoTab   := 0
Default nEstqMinimo := 0
Default cXProdPai   := ""
Default cProdutoPai := ""
Default aProdutos   := {}
Default oListProd   := nil

Begin Sequence

    If  Empty(cProduto)
        Break
    EndIf    
    
    SB1->( DbSetOrder(1) )
    
    If  !( SB1->(DbSeek(xFilial("SB1")+cProduto)) ) .Or. (Alltrim(SB1->B1_COD) <> Alltrim(cProduto))
        Alert(STR0031)    //"Produto nใo encontrado no cadastro!"
        Break
    EndIf    
    
    cXProdPai := SB1->B1_PRODPAI
    
    If  !( Empty(cXProdPai) )
	    If  !( SB1->(DbSeek(xFilial("SB1")+cXProdPai)) )
	        Alert(STR0032 + cXProdPai)    //"Produto pai nใo encontrado no cadastro! Produto: "
	        Break
	    EndIf    
    EndIf

    If  (nPrecoCheio <> SB1->B1_PRV1) //Preco Cheio pelo Produto Pai (SB1)
    	lOk1 := (Aviso(STR0033, STR0034 + Alltrim(Transform(nPrecoCheio,PesqPict("SB1","B1_PRV1"))) + "?",{STR0044,STR0045}) == 1)  //"Mensagem do Usuแrio"##"Deseja alterar o pre็o Cheio para: "##"Sim"##"Nใo"
    EndIf
	
	nXPrecoTab   := Posicione("SB0",1,xFilial("SB0")+cProduto,cCmpPreco)
	
	If  (nPrecoTab <> nXPrecoTab)  //Preco de tabela pelo Produto Filho (SB0)
    	lOk2 := (Aviso(STR0033, STR0035 + Alltrim(Transform(nPrecoTab,PesqPict("SB1","B1_PRV1"))) + "?",{STR0044,STR0045}) == 1)    //"Mensagem do Usuแrio"##"Deseja alterar o pre็o de Tabela para: "##"Sim"##"Nใo"
    EndIf
		
    If  !( Empty(cXProdPai) )
	    SB1->(DbSeek(xFilial("SB1")+cProduto))  //Volta para o filho
    EndIf

	If  (nEstqMinimo <> SB1->B1_EMIN)  //Estoque minimo pelo Produto Filho (SB1)
    	lOk3 := (Aviso(STR0033, STR0036 + Alltrim(Transform(nEstqMinimo,PesqPict("SB2","B2_QATU"))) + "?",{STR0044,STR0045}) == 1)  //"Mensagem do Usuแrio"##"Deseja alterar o Estoque Mํnimo para: "##"Sim"##"Nใo"
    EndIf
		
    If  lOk3
	    If  !( SB1->(SoftLock("SB1")) )
	        Alert(STR0037 + cProduto)   //"Nใo foi possํvel travar o registro no Cadastro de Produto! Produto: "
	        Break
	    EndIf
    
    	SB1->B1_EMIN := nEstqMinimo   //Estoque minimo pelo Produto Filho (SB1)
    	SB1->( MsUnLock() )
    EndIf
    
    If  lOk1
    	If  !( Empty(cXProdPai) )
    		SB1->(DbSeek(xFilial("SB1")+cXProdPai))
    	EndIf	
    	
	    If  !( SB1->(SoftLock("SB1")) )
	        Alert(STR0038 + cXProdPai)     //"Nใo foi possํvel travar o registro no Cadastro de Produto! Produto pai: "
	        Break
	    EndIf
    
    	SB1->B1_PRV1 := nPrecoCheio   //Preco Cheio pelo Produto Pai (SB1) 
    	SB1->( MsUnLock() )
    EndIf

    If  lOk2
    
        SB0->( DbSetOrder( 1 ) )
        If  !( SB0->(DbSeek(xFilial("SB0")+cProduto)) ) 
	        Alert(STR0047 + cProduto)   //"Produto nใo encontrado no Cadastro de Tabela de Pre็o! Produto: "
	        Break
	   EndIf
    
	    If  !( SB0->(SoftLock("SB0")) )
	        Alert(STR0039 + cProduto)   //"Nใo foi possํvel travar o registro no Cadastro de Tabela de Pre็o! Produto: "
	        Break
	    EndIf
    
    	    SB0->( FieldPut(FieldPos(cCmpPreco), nPrecoTab) )  //Preco de tabela pelo Produto Filho (SB0)
    	    SB0->( MsUnLock() )

		If  !( Empty(oIcon02) ) .And. (nPrecoTab > 0)
			oIcon02:SetBmp("Checked")
		ElseIf !( Empty(oIcon02) )	
			oIcon02:SetBmp("NoChecked")
		EndIf
		
		LJ865ProdPai(cProduto, @cXProdPai, @cProdutoPai, @aProdutos,; 
		             @oListProd, @oIcon02, @nPrecoCheio, @nPrecoTab,; 
		             @nEstqMinimo)
		
    EndIf
    
End Sequence

Return .T.    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ865Produtoบ Autor ณ Antonio C Ferreira บ Data ณ 09/04/2013  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verificar os dados e-Commerce que o produto ja possui.       บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cProduto - codigo do produto                                 บฑฑ
ฑฑบ          ณ oIcon01 - apresenta o status se o produto ้ e-commerce       บฑฑ
ฑฑบ          ณ oStatus - Objeto do Status do produto                        บฑฑ
ฑฑบ          ณ cStatus - Valor do Status do produto                         บฑฑ
ฑฑบ          ณ nPrecoCheio - Valor do preco cheio                           บฑฑ
ฑฑบ          ณ oIcon02 - apresenta o status do preco na tela                บฑฑ
ฑฑบ          ณ nPrecoTab - Valor do preco de tabela                         บฑฑ
ฑฑบ          ณ nEstqMinimo - valor do estoque minimo                        บฑฑ
ฑฑบ          ณ oIcon03 - apresenta o status do fornecedor                   บฑฑ
ฑฑบ          ณ cFornecedor - valor do fornecedor                            บฑฑ
ฑฑบ          ณ cXProdPai - campo auxiliar para o produto pai                บฑฑ
ฑฑบ          ณ cProdutoPai - valor do produto pai                           บฑฑ
ฑฑบ          ณ aProdutos - lista de produtos filhos                         บฑฑ
ฑฑบ          ณ oListProd - objeto da lista de produtos filhos               บฑฑ
ฑฑบ          ณ oIcon04 - apresenta o status da categoria                    บฑฑ
ฑฑบ          ณ aCategoria - matriz com a lista de categorias do produto     บฑฑ
ฑฑบ          ณ oListCateg - objeto para a lista de categorias do produto    บฑฑ
ฑฑบ          ณ oIcon05 - apresenta o status do armazem do produto           บฑฑ
ฑฑบ          ณ aArmazens - matriz com a lista de aramazens do produto       บฑฑ
ฑฑบ          ณ oListArmaz - objeto para a lista de armazens do produto      บฑฑ
ฑฑบ          ณ oIntEcomm -objeto de verificacao da configuracao IntEcomm.iniบฑฑ
ฑฑบ          ณ oIcon06 - apresenta o status da configuracao IntEcomm.ini    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ865Produto(cProduto, oIcon01, oStatus, cStatus,;
                             nPrecoCheio, oIcon02, nPrecoTab, nEstqMinimo,;
                             oIcon03, cFornecedor, cXProdPai, cProdutoPai,;
                             aProdutos, oListProd, oIcon04, aCategoria,;
                             oListCateg, oIcon05, aArmazens, oListArmaz,; 
                             oIntEcomm, oIcon06)

Local cFlag       := ""  //Status do produto no cadastro de complemento de produtos
Local lIntEcomm   := LJ861Emps("LOJA865", cEmpAnt, cFilAnt,,) //Verifica se o arquivo IntEcomm.ini esta configurado para este Grupo de empresa/filial. 
Local cFilSA2	  := xFilial("SA2") //Filial do Fornecedor   
Local cFilACU     := xFilial("ACU") //Filial da Categoria

Default cProduto    := ""
Default oIcon01     := nil
Default oStatus     := nil
Default cStatus     := ""
Default nPrecoCheio := 0
Default oIcon02     := nil
Default nPrecoTab   := 0
Default nEstqMinimo := 0
Default oIcon03     := nil
Default cFornecedor := ""
Default cXProdPai   := ""
Default cProdutoPai := ""
Default aProdutos   := {}
Default oListProd   := nil
Default oIcon04     := nil
Default aCategoria  := {}
Default oListCateg  := nil
Default oIcon05     := nil
Default aArmazens   := {}
Default oListArmaz  := nil
Default oIntEcomm   := nil
Default oIcon06     := nil

Begin Sequence

    If  Empty(cProduto)
        Break
    EndIf    
    
    SB1->( DbSetOrder(1) )
    
    If  !( SB1->(DbSeek(xFilial("SB1")+cProduto)) ) .Or. (Alltrim(SB1->B1_COD) <> Alltrim(cProduto))
        Alert(STR0031)  //"Produto nใo encontrado no cadastro!"
        Break
    EndIf             
    
   	LJ865ProdPai(cProduto, @cXProdPai, @cProdutoPai, @aProdutos,; 
   	             @oListProd, @oIcon02, @nPrecoCheio, @nPrecoTab,; 
   	             @nEstqMinimo)  

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerificando o Status do produto para e-Commerce                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   	cFlag := Posicione("SB5",1,xFilial("SB5")+cXProdPai,"B5_ECFLAG")       
	
	             
	If  Empty(cFlag) .And. !( Empty(oIcon01) )
		oIcon01:SetBmp("NoChecked")
		oStatus:SetColor( CLR_RED, GetSysColor( 15 ) )
		cStatus := STR0002  //"Nใo e-Commerce"
	ElseIf (cFlag == "2")  .And. !( Empty(oIcon01) )
		oIcon01:SetBmp("Checked")  //Mesmo que seja Inativo, ้ e-Commerce entใo estแ ok.
		oStatus:SetColor( CLR_HRED, GetSysColor( 15 ) )
		cStatus := STR0040  //"Inativo e-Commerce"
	ElseIf  !( Empty(oIcon01) )
		oIcon01:SetBmp("Checked")
		oStatus:SetColor( CLR_GREEN, GetSysColor( 15 ) )
		cStatus := STR0041  //"Ativo e-Commerce"
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณApresenta o status da configuracao para o arquivo IntEcomm.ini            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If  !( lIntEcomm )
		oIcon06:SetBmp("NoChecked")
		oIntEcomm:SetColor( CLR_HRED, GetSysColor( 15 ) )
	ElseIf  !( Empty(oIcon01) )
		oIcon06:SetBmp("Checked")
		oIntEcomm:SetColor( CLR_HBLUE, GetSysColor( 15 ) )
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerificando Amarracao com o Fornecedor                                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA                                                                                                                                        
	
	DbSelectArea("SA5")
	DbSetOrder(2)  //A5_FILIAL+A5_PRODUTO+A5_FORNECE+A5_LOJA
	
	DbSeek(xFilial("SA5")+cXProdPai)

	Do  While !( Eof() ) .And. (A5_FILIAL+A5_PRODUTO == xFilial("SA5")+PadR(cXProdPai,Len(A5_PRODUTO)))
	    If  !( Empty(A5_ECFLAG) )
	    	Exit
	    EndIf
	
		DbSkip()
	EndDo	
	
	If  !( Eof() ) .And. (A5_FILIAL+A5_PRODUTO == xFilial("SA5")+PadR(cXProdPai,Len(A5_PRODUTO))) .And. !( Empty(A5_ECFLAG) ) .And. !( Empty(oIcon03) )  .AND. ;
		SA2->(DbSeek(cFilSA2+SA5->(A5_FORNECE+A5_LOJA)))
		If SA2->A2_ECFLAG <> ' '
			oIcon03:SetBmp("Checked")
		Else 
			oIcon03:SetBmp("NoChecked")
		EndIf
		cFornecedor := A5_FORNECE+"/"+A5_LOJA + " - " + SA2->A2_NOME
	ElseIf  !( Empty(oIcon03) )
		oIcon03:SetBmp("NoChecked")
		cFornecedor := STR0003  //"<< SEM FORNECEDOR >>"
	EndIf


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCategorias - pai e filhos                                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    ACU->(DbSetOrder(1)) //ACU_FILIAL + ACU_COD
    DbSelectArea("ACV")
    DbSetOrder(5)  //ACV_FILIAL+ACV_CODPRO+ACV_CATEGO
	DbSeek(xFilial("ACV")+cXProdPai)
	              
	aCategorias := {}
	
	Do  While !( Eof() ) .And. (Alltrim(ACV_CODPRO) == Alltrim(cXProdPai))
		//{Categoria, Descricao, Categoria Pai} 
		If ACU->(DbSeek(cFilACU + ACV->ACV_CATEGO)) .AND. !Empty(ACU->ACU_ECFLAG)   //Somente Categorias e-commerce              
			Aadd(aCategorias, {ACV_CATEGO, ACU->ACU_DESC, ACU->ACU_CODPAI})
        EndIf     
        DbSkip()
    EndDo    

	If  !( Empty(oListCateg) )
		oListCateg:SetArray(aCategorias)
		If  (Len(aCategorias) > 0)
			oListCateg:bLine := &(cBCategLine)
		EndIf
		oListCateg:Refresh()
	EndIf    

	If  (Len(aCategorias) > 0) .And. !( Empty(oIcon04) )
	    oIcon04:SetBmp("Checked")
	ElseIf  !( Empty(oIcon04) )
	    oIcon04:SetBmp("NoChecked")
	EndIf    
	
	LJ865Armazem(cProduto, @oIcon05, @aArmazens, @oListArmaz)
	                               
End Sequence

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ865ProdPaiบ Autor ณ Antonio C Ferreira บ Data ณ 16/04/2013  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verificar os Produtos do e-Commerce.                         บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cProduto - codigo do produto                                 บฑฑ
ฑฑบ          ณ cXProdPai - campo auxiliar para o produto pai                บฑฑ
ฑฑบ          ณ cProdutoPai - valor do produto pai                           บฑฑ
ฑฑบ          ณ aProdutos - lista de produtos filhos                         บฑฑ
ฑฑบ          ณ oListProd - objeto da lista de produtos filhos               บฑฑ
ฑฑบ          ณ oIcon02 - apresenta o status do preco na tela                บฑฑ
ฑฑบ          ณ nPrecoCheio - Valor do preco cheio                           บฑฑ
ฑฑบ          ณ nPrecoTab - Valor do preco de tabela                         บฑฑ
ฑฑบ          ณ nEstqMinimo - valor do estoque minimo                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ865ProdPai(cProduto, cXProdPai, cProdutoPai, aProdutos,;
                             oListProd, oIcon02, nPrecoCheio, nPrecoTab,;
                             nEstqMinimo)

Local nA         := 0	
Local cRaizPai   := ""          //Raiz do codigo de produto no cadastro de grade
Local aMascRaiz  := &("{"+SuperGetMV("MV_MASCGRD",,"11,2,2")+"}")  //Cria vetor com os dados da Mascara da grade
Local cCmpPreco  := "B0_PRV"+AllTrim(SuperGetMV("MV_LJECOMT",,SuperGetMV("MV_TABPAD")))  //Campo da tabela de preco para o e-Commerce
Local aArmazens  := {}
Local nEstoque   := 0 
Local cZerosLin  := Replicate("0",aMascRaiz[2])   //Codigo zerado no tamanho da linha da grade para ser utilizado em condicao na MF2.
Local cZerosCol  := Replicate("0",aMascRaiz[3])   //Codigo zerado no tamanho da coluna da grade para ser utilizado em condicao na MF2.
Local cFilSB4 	 := xFilial("SB4")                  //Filial SB4
Local cFilSBV    := xFilial ("SBV")                 //Filial SBV
Local cLinha	 := "" //Descri็ใo da Linha
Local cColuna	 := "" //Descri็ใo da Coluna


Default cProduto    := ""
Default cXProdPai   := ""
Default cProdutoPai := ""
Default aProdutos   := {}
Default oListProd   := nil
Default oIcon02     := nil
Default nPrecoCheio := 0
Default nPrecoTab   := 0
Default nEstqMinimo := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProdutos pai e filhos                                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If  Empty(SB1->B1_PRODPAI)
    cXProdPai := SB1->B1_COD
    cRaizPai  := ""
Else    
	cXProdPai := SB1->B1_PRODPAI 
	cRaizPai  := Left(cXProdPai, aMascRaiz[1])
EndIf	

cProdutoPai := Alltrim(cXProdPai) + " - " + Alltrim(Posicione("SB5",1,xFilial("SB5")+cXProdPai,"B5_CEME"))

If  Empty(cRaizPai)
    aProdutos := {{"",Space(48),0, 0,"", "", ""}} //{Produto, Descricao, Preco de tabela (SB0), Branco, e-commerce, linha, coluna}
Else 
    SB4->(DbSetOrder(1)) //B4_FILIAL+B4_COD                                                                                                                                                
    SBV->(DbSetOrder(1)) //BV_FILIAL+BV_TABELA+BV_CHAVE                                                                                                                                    
    
    DbSelectArea("SB1")
	DbSeek(xFilial("SB1")+cRaizPai)       
	
	              
	aProdutos := {}
	
	Do  While !( SB1->(Eof()) ) .And. (Alltrim(Left(SB1->B1_COD,aMascRaiz[1])) == Alltrim(cRaizPai))
	
		If  (Alltrim(SB1->B1_PRODPAI) == Alltrim(cXProdPai))
		    nEstoque := 0
		    LJ865Armazem(SB1->B1_COD, NIL, @aArmazens, NIL)
		    For nA := 1 to Len(aArmazens)
		        nEstoque += aArmazens[nA][3]  //Soma dos estoques e-commerce.
		    Next nA    
			
			//Apura as varia็๕es de Linha e Coluna
			
			
			cLinha := ""
			cColuna := "" 
			
			cLinha := Substr(SB1->B1_COD,aMascRaiz[1]+1, aMascRaiz[2] )
			cColuna := Substr(SB1->B1_COD,aMascRaiz[1]+aMascRaiz[2]+1, aMascRaiz[3])
			
			If  (cLinha   <> cZerosLin  .OR. cColuna   <> cZerosCol )   .AND.  SB4->(DbSeek(cFilSB4 + Left(SB1->B1_COD,aMascRaiz[1] ) ) )
				
				If cLinha <>  cZerosLin  .AND. SBV->(DbSeek(cFilSBV+SB4->B4_LINHA + cLinha)) 
					cLinha := SBV->BV_DESCRI
				Else
					cLinha := ""
				EndIf
				
				If cColuna <>  cZerosCol  .AND. SBV->(DbSeek(cFilSBV+SB4->B4_COLUNA + cColuna)) 
					cColuna := SBV->BV_DESCRI
				Else
					cColuna := ""
				EndIf

			EndIf
			//{Produto, Descricao, Preco de tabela (SB0), Branco, e-commece}                     
			SB1->( aadd(aProdutos, {IIF( AllTrim(SB1->B1_COD) == AllTRim(cXProdPai),">>","")+B1_COD, B1_DESC, Posicione("SB0",1,xFilial("SB0")+B1_COD,cCmpPreco), nEstoque, IIF(SB0->B0_ECFLAG == "1", STR0051, IIF(SB0->B0_ECFLAG == "2" , STR0052, "")), cLinha, cColuna}) )  //"Ativo"#"Inativo"
		EndIf	
            
        SB1->( DbSkip() )
    EndDo    
EndIf	             

If  !( Empty(oListProd) )
	oListProd:SetArray(aProdutos)
	If  (Len(aProdutos) > 0)
		oListProd:bLine := &(cBProdLine) 
	EndIf
	oListProd:Refresh()
EndIf
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerificando os Precos e Qtde Minima                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPrecoTab   := Posicione("SB0",1,xFilial("SB0")+cProduto,"B0_PRV"+AllTrim(SuperGetMV("MV_LJECOMT",,SuperGetMV("MV_TABPAD"))))

If  (nPrecoTab > 0) .And. !( Empty(oIcon02) )
	oIcon02:SetBmp("Checked")
ElseIf  !( Empty(oIcon02) )
	oIcon02:SetBmp("NoChecked")
EndIf
	
nEstqMinimo := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_EMIN")

nPrecoCheio := Posicione("SB1",1,xFilial("SB1")+cXProdPai,"B1_PRV1")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ865Armazemบ Autor ณ Antonio C Ferreira บ Data ณ 16/04/2013  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verificar os Armazens do e-Commerce.                         บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cProduto - codigo do produto                                 บฑฑ
ฑฑบ          ณ oIcon05 - apresenta o status do armazem do produto           บฑฑ
ฑฑบ          ณ aArmazens - matriz com a lista de aramazens do produto       บฑฑ
ฑฑบ          ณ oListArmaz - objeto para a lista de armazens do produto      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ865Armazem(cProduto, oIcon05, aArmazens, oListArmaz)
        
Local nA       := 0   //Contador para o comando For
Local nLenLoc  := 0   //Tamanho da matriz aLocais

Default cProduto    := ""
Default oIcon05     := nil
Default aArmazens   := {}
Default oListArmaz  := nil

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArmazens e-Commerce - Tabela MF6                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If  Empty(aLocais)
    DbSelectArea("MF6")
    DbSeek(xFilial("MF6"))
    
    While !( Eof() )                      
        If  (Ascan(aLocais, {|x| (x[1] == MF6_XFILIA) .And. (x[2] == MF6_LOCAL)}) <= 0)
    		aadd(aLocais, {MF6_XFILIA, MF6_LOCAL})
    	EndIf
    		
        DbSkip()
    End    
EndIf
                       
nLenLoc := Len(aLocais)

aArmazens := {}

For nA := 1 to nLenLoc

	If  SB2->( DbSeek(Left(aLocais[nA][1]+Space(10),Len(B2_FILIAL))+PadR(cProduto,Len(B2_COD))+aLocais[nA][2]) )
		//{Filial, Armazem, Estoque Disponivel, Branco}
		aadd( aArmazens, {aLocais[nA][1], aLocais[nA][2], SaldoSB2(), ""} )
	EndIf

Next nA
                       
If  !( Empty(oListArmaz) )
	oListArmaz:SetArray(aArmazens)
	If  (Len(aArmazens) > 0)
		oListArmaz:bLine := &(cBArmazLine) 
	EndIf
	oListArmaz:Refresh()
EndIf	
                      
//Tem que ter todos os armazens do e-Commerce
If  !( Empty(oIcon05) ) .And. ((nLenLoc <= 0) .Or. (Len(aArmazens) < nLenLoc))
	oIcon05:SetBmp("NoChecked")
ElseIf  !( Empty(oIcon05) )
	oIcon05:SetBmp("Checked")
EndIf	

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ865GerEstqบ Autor ณ Antonio C Ferreira บ Data ณ 16/04/2013  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gerar os Armazens do e-Commerce.                             บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cProduto - codigo do produto                                 บฑฑ
ฑฑบ          ณ oIcon05 - apresenta o status do armazem do produto           บฑฑ
ฑฑบ          ณ aArmazens - matriz com a lista de aramazens do produto       บฑฑ
ฑฑบ          ณ oListArmaz - objeto para a lista de armazens do produto      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ865GerEstq(cProduto, oIcon05, aArmazens, oListArmaz) 

Local nA       := 0   //Contador para o comando For
Local nLenLoc  := 0   //Tamanho da matriz aLocais
Local cFilDes  := ""  //Filial para criacao do armazem
Local cLocal   := ""  //Local para o Armazem

Default cProduto    := ""
Default oIcon05     := nil
Default aArmazens   := {}
Default oListArmaz  := nil

If  Empty(aLocais)
	LJ865Armazem(cProduto, @oIcon05, @aArmazens, @oListArmaz) //Obtem os valores de aLocais
EndIf

Begin Sequence

    If  Empty(cProduto)
        Break
    EndIf    
    
    SB1->( DbSetOrder(1) )
    
    If  !( SB1->(DbSeek(xFilial("SB1")+cProduto)) ) .Or. (Alltrim(SB1->B1_COD) <> Alltrim(cProduto))
        Alert(STR0031)  //"Produto nใo encontrado no cadastro!"
        Break
    EndIf    

	If  Empty(aLocais)
		Alert(STR0042)  //"Armazens do e-Commerce nใo definidos! Verificar o Cadastro de Range de CEP!"
		Break
	EndIf

	nLenLoc := Len(aLocais)
	
	For nA := 1 to nLenLoc
	
	    cFilDes := Left(aLocais[nA][1]+Space(10),Len(SB2->B2_FILIAL))
	    cLocal  := aLocais[nA][2]
	    
		If  !( SB2->(DbSeek(cFilDes+PadR(cProduto,Len(B2_COD))+cLocal)) )
			//{Filial, Armazem, Estoque Disponivel, Branco}
			CriaSB2(cProduto,cLocal,cFilDes)
			SB2->( MsUnLock() )
		EndIf
	
	Next nA
	
	LJ865Armazem(cProduto, @oIcon05, @aArmazens, @oListArmaz)  //Obtem os dados dos Armazens do e-Commerce deste Produto

End Sequence

Return .T.	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ865CadProdบ Autor ณ Antonio C Ferreira บ Data ณ 16/04/2013  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamar o Cadastro de Produtos.                               บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cProduto - codigo do produto                                 บฑฑ
ฑฑบ          ณ oIcon01 - apresenta o status se o produto ้ e-commerce       บฑฑ
ฑฑบ          ณ oStatus - Objeto do Status do produto                        บฑฑ
ฑฑบ          ณ cStatus - Valor do Status do produto                         บฑฑ
ฑฑบ          ณ nPrecoCheio - Valor do preco cheio                           บฑฑ
ฑฑบ          ณ oIcon02 - apresenta o status do preco na tela                บฑฑ
ฑฑบ          ณ nPrecoTab - Valor do preco de tabela                         บฑฑ
ฑฑบ          ณ nEstqMinimo - valor do estoque minimo                        บฑฑ
ฑฑบ          ณ oIcon03 - apresenta o status do fornecedor                   บฑฑ
ฑฑบ          ณ cFornecedor - valor do fornecedor                            บฑฑ
ฑฑบ          ณ cXProdPai - campo auxiliar para o produto pai                บฑฑ
ฑฑบ          ณ cProdutoPai - valor do produto pai                           บฑฑ
ฑฑบ          ณ aProdutos - lista de produtos filhos                         บฑฑ
ฑฑบ          ณ oListProd - objeto da lista de produtos filhos               บฑฑ
ฑฑบ          ณ oIcon04 - apresenta o status da categoria                    บฑฑ
ฑฑบ          ณ aCategoria - matriz com a lista de categorias do produto     บฑฑ
ฑฑบ          ณ oListCateg - objeto para a lista de categorias do produto    บฑฑ
ฑฑบ          ณ oIcon05 - apresenta o status do armazem do produto           บฑฑ
ฑฑบ          ณ aArmazens - matriz com a lista de aramazens do produto       บฑฑ
ฑฑบ          ณ oListArmaz - objeto para a lista de armazens do produto      บฑฑ
ฑฑบ          ณ oIntEcomm -objeto de verificacao da configuracao IntEcomm.iniบฑฑ
ฑฑบ          ณ oIcon06 - apresenta o status da configuracao IntEcomm.ini    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ865CadProd(cProduto, oIcon01, oStatus, cStatus,;
                             nPrecoCheio, oIcon02, nPrecoTab, nEstqMinimo,;
                             oIcon03, cFornecedor, cXProdPai, cProdutoPai,;
                             aProdutos, oListProd, oIcon04, aCategoria,;
                             oListCateg, oIcon05, aArmazens, oListArmaz,; 
                             oIntEcomm, oIcon06) 

Default cProduto    := ""
Default oIcon01     := nil
Default oStatus     := nil
Default cStatus     := ""
Default nPrecoCheio := 0
Default oIcon02     := nil
Default nPrecoTab   := 0
Default nEstqMinimo := 0
Default oIcon03     := nil
Default cFornecedor := ""
Default cXProdPai   := ""
Default cProdutoPai := ""
Default aProdutos   := {}
Default oListProd   := nil
Default oIcon04     := nil
Default aCategoria  := {}
Default oListCateg  := nil
Default oIcon05     := nil
Default aArmazens   := {}
Default oListArmaz  := nil
Default oIntEcomm   := nil
Default oIcon06     := nil

SetFunName("LOJA110")

LOJA110()

SetFunName("LOJA865")

//Atualiza os dados da Tela
LJ865Produto(cProduto, @oIcon01, @oStatus, @cStatus,;
             @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,;
             @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,;
             @aProdutos, @oListProd, @oIcon04, @aCategoria,;
             @oListCateg, @oIcon05, @aArmazens, @oListArmaz,; 
             @oIntEcomm, @oIcon06)

Return .T. 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ865TabGradบ Autor ณ Antonio C Ferreira บ Data ณ 16/04/2013  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamar o Cadastro de Tabela de Grade.                        บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cProduto - codigo do produto                                 บฑฑ
ฑฑบ          ณ oIcon01 - apresenta o status se o produto ้ e-commerce       บฑฑ
ฑฑบ          ณ oStatus - Objeto do Status do produto                        บฑฑ
ฑฑบ          ณ cStatus - Valor do Status do produto                         บฑฑ
ฑฑบ          ณ nPrecoCheio - Valor do preco cheio                           บฑฑ
ฑฑบ          ณ oIcon02 - apresenta o status do preco na tela                บฑฑ
ฑฑบ          ณ nPrecoTab - Valor do preco de tabela                         บฑฑ
ฑฑบ          ณ nEstqMinimo - valor do estoque minimo                        บฑฑ
ฑฑบ          ณ oIcon03 - apresenta o status do fornecedor                   บฑฑ
ฑฑบ          ณ cFornecedor - valor do fornecedor                            บฑฑ
ฑฑบ          ณ cXProdPai - campo auxiliar para o produto pai                บฑฑ
ฑฑบ          ณ cProdutoPai - valor do produto pai                           บฑฑ
ฑฑบ          ณ aProdutos - lista de produtos filhos                         บฑฑ
ฑฑบ          ณ oListProd - objeto da lista de produtos filhos               บฑฑ
ฑฑบ          ณ oIcon04 - apresenta o status da categoria                    บฑฑ
ฑฑบ          ณ aCategoria - matriz com a lista de categorias do produto     บฑฑ
ฑฑบ          ณ oListCateg - objeto para a lista de categorias do produto    บฑฑ
ฑฑบ          ณ oIcon05 - apresenta o status do armazem do produto           บฑฑ
ฑฑบ          ณ aArmazens - matriz com a lista de aramazens do produto       บฑฑ
ฑฑบ          ณ oListArmaz - objeto para a lista de armazens do produto      บฑฑ
ฑฑบ          ณ oIntEcomm -objeto de verificacao da configuracao IntEcomm.iniบฑฑ
ฑฑบ          ณ oIcon06 - apresenta o status da configuracao IntEcomm.ini    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ865TabGrad(cProduto, oIcon01, oStatus, cStatus,;
                             nPrecoCheio, oIcon02, nPrecoTab, nEstqMinimo,;
                             oIcon03, cFornecedor, cXProdPai, cProdutoPai,;
                             aProdutos, oListProd, oIcon04, aCategoria,;
                             oListCateg, oIcon05, aArmazens, oListArmaz,; 
                             oIntEcomm, oIcon06)

Default cProduto    := ""
Default oIcon01     := nil
Default oStatus     := nil
Default cStatus     := ""
Default nPrecoCheio := 0
Default oIcon02     := nil
Default nPrecoTab   := 0
Default nEstqMinimo := 0
Default oIcon03     := nil
Default cFornecedor := ""
Default cXProdPai   := ""
Default cProdutoPai := ""
Default aProdutos   := {}
Default oListProd   := nil
Default oIcon04     := nil
Default aCategoria  := {}
Default oListCateg  := nil
Default oIcon05     := nil
Default aArmazens   := {}
Default oListArmaz  := nil
Default oIntEcomm   := nil
Default oIcon06     := nil

SetFunName("MATA551")

MATA551()

SetFunName("LOJA865")

//Atualiza os dados da Tela
LJ865Produto(cProduto, @oIcon01, @oStatus, @cStatus,;
             @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,;
             @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,;
             @aProdutos, @oListProd, @oIcon04, @aCategoria,; 
             @oListCateg, @oIcon05, @aArmazens, @oListArmaz,; 
             @oIntEcomm, @oIcon06)

Return .T. 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ865GradProบ Autor ณ Antonio C Ferreira บ Data ณ 16/04/2013  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamar o Cadastro de Grade de Produto.                       บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cProduto - codigo do produto                                 บฑฑ
ฑฑบ          ณ oIcon01 - apresenta o status se o produto ้ e-commerce       บฑฑ
ฑฑบ          ณ oStatus - Objeto do Status do produto                        บฑฑ
ฑฑบ          ณ cStatus - Valor do Status do produto                         บฑฑ
ฑฑบ          ณ nPrecoCheio - Valor do preco cheio                           บฑฑ
ฑฑบ          ณ oIcon02 - apresenta o status do preco na tela                บฑฑ
ฑฑบ          ณ nPrecoTab - Valor do preco de tabela                         บฑฑ
ฑฑบ          ณ nEstqMinimo - valor do estoque minimo                        บฑฑ
ฑฑบ          ณ oIcon03 - apresenta o status do fornecedor                   บฑฑ
ฑฑบ          ณ cFornecedor - valor do fornecedor                            บฑฑ
ฑฑบ          ณ cXProdPai - campo auxiliar para o produto pai                บฑฑ
ฑฑบ          ณ cProdutoPai - valor do produto pai                           บฑฑ
ฑฑบ          ณ aProdutos - lista de produtos filhos                         บฑฑ
ฑฑบ          ณ oListProd - objeto da lista de produtos filhos               บฑฑ
ฑฑบ          ณ oIcon04 - apresenta o status da categoria                    บฑฑ
ฑฑบ          ณ aCategoria - matriz com a lista de categorias do produto     บฑฑ
ฑฑบ          ณ oListCateg - objeto para a lista de categorias do produto    บฑฑ
ฑฑบ          ณ oIcon05 - apresenta o status do armazem do produto           บฑฑ
ฑฑบ          ณ aArmazens - matriz com a lista de aramazens do produto       บฑฑ
ฑฑบ          ณ oListArmaz - objeto para a lista de armazens do produto      บฑฑ
ฑฑบ          ณ oIntEcomm -objeto de verificacao da configuracao IntEcomm.iniบฑฑ
ฑฑบ          ณ oIcon06 - apresenta o status da configuracao IntEcomm.ini    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ865GradPro(cProduto, oIcon01, oStatus, cStatus,;
                             nPrecoCheio, oIcon02, nPrecoTab, nEstqMinimo,;
                             oIcon03, cFornecedor, cXProdPai, cProdutoPai,;
                             aProdutos, oListProd, oIcon04, aCategoria,;
                             oListCateg, oIcon05, aArmazens, oListArmaz,; 
                             oIntEcomm, oIcon06)

Default cProduto    := ""
Default oIcon01     := nil
Default oStatus     := nil
Default cStatus     := ""
Default nPrecoCheio := 0
Default oIcon02     := nil
Default nPrecoTab   := 0
Default nEstqMinimo := 0
Default oIcon03     := nil
Default cFornecedor := ""
Default cXProdPai   := ""
Default cProdutoPai := ""
Default aProdutos   := {}
Default oListProd   := nil
Default oIcon04     := nil
Default aCategoria  := {}
Default oListCateg  := nil
Default oIcon05     := nil
Default aArmazens   := {}
Default oListArmaz  := nil
Default oIntEcomm   := nil
Default oIcon06     := nil

SetFunName("MATA550")

MATA550()

SetFunName("LOJA865")

//Atualiza os dados da Tela
LJ865Produto(cProduto, @oIcon01, @oStatus, @cStatus,; 
             @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,; 
             @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,; 
             @aProdutos, @oListProd, @oIcon04, @aCategoria,; 
             @oListCateg, @oIcon05, @aArmazens, @oListArmaz,; 
             @oIntEcomm, @oIcon06)

Return .T. 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ865Complemบ Autor ณ Antonio C Ferreira บ Data ณ 16/04/2013  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamar o Cadastro de Complemento de Produto.                 บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cProduto - codigo do produto                                 บฑฑ
ฑฑบ          ณ oIcon01 - apresenta o status se o produto ้ e-commerce       บฑฑ
ฑฑบ          ณ oStatus - Objeto do Status do produto                        บฑฑ
ฑฑบ          ณ cStatus - Valor do Status do produto                         บฑฑ
ฑฑบ          ณ nPrecoCheio - Valor do preco cheio                           บฑฑ
ฑฑบ          ณ oIcon02 - apresenta o status do preco na tela                บฑฑ
ฑฑบ          ณ nPrecoTab - Valor do preco de tabela                         บฑฑ
ฑฑบ          ณ nEstqMinimo - valor do estoque minimo                        บฑฑ
ฑฑบ          ณ oIcon03 - apresenta o status do fornecedor                   บฑฑ
ฑฑบ          ณ cFornecedor - valor do fornecedor                            บฑฑ
ฑฑบ          ณ cXProdPai - campo auxiliar para o produto pai                บฑฑ
ฑฑบ          ณ cProdutoPai - valor do produto pai                           บฑฑ
ฑฑบ          ณ aProdutos - lista de produtos filhos                         บฑฑ
ฑฑบ          ณ oListProd - objeto da lista de produtos filhos               บฑฑ
ฑฑบ          ณ oIcon04 - apresenta o status da categoria                    บฑฑ
ฑฑบ          ณ aCategoria - matriz com a lista de categorias do produto     บฑฑ
ฑฑบ          ณ oListCateg - objeto para a lista de categorias do produto    บฑฑ
ฑฑบ          ณ oIcon05 - apresenta o status do armazem do produto           บฑฑ
ฑฑบ          ณ aArmazens - matriz com a lista de aramazens do produto       บฑฑ
ฑฑบ          ณ oListArmaz - objeto para a lista de armazens do produto      บฑฑ
ฑฑบ          ณ oIntEcomm -objeto de verificacao da configuracao IntEcomm.iniบฑฑ
ฑฑบ          ณ oIcon06 - apresenta o status da configuracao IntEcomm.ini    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ865Complem(cProduto, oIcon01, oStatus, cStatus,; 
                             nPrecoCheio, oIcon02, nPrecoTab, nEstqMinimo,; 
                             oIcon03, cFornecedor, cXProdPai, cProdutoPai,; 
                             aProdutos, oListProd, oIcon04, aCategoria,; 
                             oListCateg, oIcon05, aArmazens, oListArmaz,; 
                             oIntEcomm, oIcon06)

Default cProduto    := ""
Default oIcon01     := nil
Default oStatus     := nil
Default cStatus     := ""
Default nPrecoCheio := 0
Default oIcon02     := nil
Default nPrecoTab   := 0
Default nEstqMinimo := 0
Default oIcon03     := nil
Default cFornecedor := ""
Default cXProdPai   := ""
Default cProdutoPai := ""
Default aProdutos   := {}
Default oListProd   := nil
Default oIcon04     := nil
Default aCategoria  := {}
Default oListCateg  := nil
Default oIcon05     := nil
Default aArmazens   := {}
Default oListArmaz  := nil
Default oIntEcomm   := nil
Default oIcon06     := nil

SetFunName("MATA180")

MATA180()

SetFunName("LOJA865")

//Atualiza os dados da Tela
LJ865Produto(cProduto, @oIcon01, @oStatus, @cStatus,; 
             @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,; 
             @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,; 
             @aProdutos, @oListProd, @oIcon04, @aCategoria,; 
             @oListCateg, @oIcon05, @aArmazens, @oListArmaz,; 
             @oIntEcomm, @oIcon06)

Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LJ865Categ บ Autor ณ Antonio C Ferreira บ Data ณ 16/04/2013  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamar o Cadastro de Categoria.                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cProduto - codigo do produto                                 บฑฑ
ฑฑบ          ณ oIcon01 - apresenta o status se o produto ้ e-commerce       บฑฑ
ฑฑบ          ณ oStatus - Objeto do Status do produto                        บฑฑ
ฑฑบ          ณ cStatus - Valor do Status do produto                         บฑฑ
ฑฑบ          ณ nPrecoCheio - Valor do preco cheio                           บฑฑ
ฑฑบ          ณ oIcon02 - apresenta o status do preco na tela                บฑฑ
ฑฑบ          ณ nPrecoTab - Valor do preco de tabela                         บฑฑ
ฑฑบ          ณ nEstqMinimo - valor do estoque minimo                        บฑฑ
ฑฑบ          ณ oIcon03 - apresenta o status do fornecedor                   บฑฑ
ฑฑบ          ณ cFornecedor - valor do fornecedor                            บฑฑ
ฑฑบ          ณ cXProdPai - campo auxiliar para o produto pai                บฑฑ
ฑฑบ          ณ cProdutoPai - valor do produto pai                           บฑฑ
ฑฑบ          ณ aProdutos - lista de produtos filhos                         บฑฑ
ฑฑบ          ณ oListProd - objeto da lista de produtos filhos               บฑฑ
ฑฑบ          ณ oIcon04 - apresenta o status da categoria                    บฑฑ
ฑฑบ          ณ aCategoria - matriz com a lista de categorias do produto     บฑฑ
ฑฑบ          ณ oListCateg - objeto para a lista de categorias do produto    บฑฑ
ฑฑบ          ณ oIcon05 - apresenta o status do armazem do produto           บฑฑ
ฑฑบ          ณ aArmazens - matriz com a lista de aramazens do produto       บฑฑ
ฑฑบ          ณ oListArmaz - objeto para a lista de armazens do produto      บฑฑ
ฑฑบ          ณ oIntEcomm -objeto de verificacao da configuracao IntEcomm.iniบฑฑ
ฑฑบ          ณ oIcon06 - apresenta o status da configuracao IntEcomm.ini    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ865Categ(cProduto, oIcon01, oStatus, cStatus,; 
                           nPrecoCheio, oIcon02, nPrecoTab, nEstqMinimo,; 
                           oIcon03, cFornecedor, cXProdPai, cProdutoPai,; 
                           aProdutos, oListProd, oIcon04, aCategoria,; 
                           oListCateg, oIcon05, aArmazens, oListArmaz,; 
                           oIntEcomm, oIcon06)

Default cProduto    := ""
Default oIcon01     := nil
Default oStatus     := nil
Default cStatus     := ""
Default nPrecoCheio := 0
Default oIcon02     := nil
Default nPrecoTab   := 0
Default nEstqMinimo := 0
Default oIcon03     := nil
Default cFornecedor := ""
Default cXProdPai   := ""
Default cProdutoPai := ""
Default aProdutos   := {}
Default oListProd   := nil
Default oIcon04     := nil
Default aCategoria  := {}
Default oListCateg  := nil
Default oIcon05     := nil
Default aArmazens   := {}
Default oListArmaz  := nil
Default oIntEcomm   := nil
Default oIcon06     := nil

SetFunName("FATA140")

FATA140()

SetFunName("LOJA865")

//Atualiza os dados da Tela
LJ865Produto(cProduto, @oIcon01, @oStatus, @cStatus,;
             @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,; 
             @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,; 
             @aProdutos, @oListProd, @oIcon04, @aCategoria,; 
             @oListCateg, @oIcon05, @aArmazens, @oListArmaz,; 
             @oIntEcomm, @oIcon06)

Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ865CatProdบ Autor ณ Antonio C Ferreira บ Data ณ 16/04/2013  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamar o Cadastro de Amarracao Categoria X Produto.          บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cProduto - codigo do produto                                 บฑฑ
ฑฑบ          ณ oIcon01 - apresenta o status se o produto ้ e-commerce       บฑฑ
ฑฑบ          ณ oStatus - Objeto do Status do produto                        บฑฑ
ฑฑบ          ณ cStatus - Valor do Status do produto                         บฑฑ
ฑฑบ          ณ nPrecoCheio - Valor do preco cheio                           บฑฑ
ฑฑบ          ณ oIcon02 - apresenta o status do preco na tela                บฑฑ
ฑฑบ          ณ nPrecoTab - Valor do preco de tabela                         บฑฑ
ฑฑบ          ณ nEstqMinimo - valor do estoque minimo                        บฑฑ
ฑฑบ          ณ oIcon03 - apresenta o status do fornecedor                   บฑฑ
ฑฑบ          ณ cFornecedor - valor do fornecedor                            บฑฑ
ฑฑบ          ณ cXProdPai - campo auxiliar para o produto pai                บฑฑ
ฑฑบ          ณ cProdutoPai - valor do produto pai                           บฑฑ
ฑฑบ          ณ aProdutos - lista de produtos filhos                         บฑฑ
ฑฑบ          ณ oListProd - objeto da lista de produtos filhos               บฑฑ
ฑฑบ          ณ oIcon04 - apresenta o status da categoria                    บฑฑ
ฑฑบ          ณ aCategoria - matriz com a lista de categorias do produto     บฑฑ
ฑฑบ          ณ oListCateg - objeto para a lista de categorias do produto    บฑฑ
ฑฑบ          ณ oIcon05 - apresenta o status do armazem do produto           บฑฑ
ฑฑบ          ณ aArmazens - matriz com a lista de aramazens do produto       บฑฑ
ฑฑบ          ณ oListArmaz - objeto para a lista de armazens do produto      บฑฑ
ฑฑบ          ณ oIntEcomm -objeto de verificacao da configuracao IntEcomm.iniบฑฑ
ฑฑบ          ณ oIcon06 - apresenta o status da configuracao IntEcomm.ini    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ865CatProd(cProduto, oIcon01, oStatus, cStatus,; 
                             nPrecoCheio, oIcon02, nPrecoTab, nEstqMinimo,; 
                             oIcon03, cFornecedor, cXProdPai, cProdutoPai,;
                             aProdutos, oListProd, oIcon04, aCategoria,; 
                             oListCateg, oIcon05, aArmazens, oListArmaz,; 
                             oIntEcomm, oIcon06)

Default cProduto    := ""
Default oIcon01     := nil
Default oStatus     := nil
Default cStatus     := ""
Default nPrecoCheio := 0
Default oIcon02     := nil
Default nPrecoTab   := 0
Default nEstqMinimo := 0
Default oIcon03     := nil
Default cFornecedor := ""
Default cXProdPai   := ""
Default cProdutoPai := ""
Default aProdutos   := {}
Default oListProd   := nil
Default oIcon04     := nil
Default aCategoria  := {}
Default oListCateg  := nil
Default oIcon05     := nil
Default aArmazens   := {}
Default oListArmaz  := nil
Default oIntEcomm   := nil
Default oIcon06     := nil

SetFunName("FATA150")

FATA150()

SetFunName("LOJA865")

//Atualiza os dados da Tela
LJ865Produto(cProduto, @oIcon01, @oStatus, @cStatus,; 
             @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,; 
             @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,; 
             @aProdutos, @oListProd, @oIcon04, @aCategoria,; 
             @oListCateg, @oIcon05, @aArmazens, @oListArmaz,; 
             @oIntEcomm, @oIcon06)

Return .T. 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ865Forneceบ Autor ณ Antonio C Ferreira บ Data ณ 16/04/2013  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamar o Cadastro de Fornecedor.                             บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cProduto - codigo do produto                                 บฑฑ
ฑฑบ          ณ oIcon01 - apresenta o status se o produto ้ e-commerce       บฑฑ
ฑฑบ          ณ oStatus - Objeto do Status do produto                        บฑฑ
ฑฑบ          ณ cStatus - Valor do Status do produto                         บฑฑ
ฑฑบ          ณ nPrecoCheio - Valor do preco cheio                           บฑฑ
ฑฑบ          ณ oIcon02 - apresenta o status do preco na tela                บฑฑ
ฑฑบ          ณ nPrecoTab - Valor do preco de tabela                         บฑฑ
ฑฑบ          ณ nEstqMinimo - valor do estoque minimo                        บฑฑ
ฑฑบ          ณ oIcon03 - apresenta o status do fornecedor                   บฑฑ
ฑฑบ          ณ cFornecedor - valor do fornecedor                            บฑฑ
ฑฑบ          ณ cXProdPai - campo auxiliar para o produto pai                บฑฑ
ฑฑบ          ณ cProdutoPai - valor do produto pai                           บฑฑ
ฑฑบ          ณ aProdutos - lista de produtos filhos                         บฑฑ
ฑฑบ          ณ oListProd - objeto da lista de produtos filhos               บฑฑ
ฑฑบ          ณ oIcon04 - apresenta o status da categoria                    บฑฑ
ฑฑบ          ณ aCategoria - matriz com a lista de categorias do produto     บฑฑ
ฑฑบ          ณ oListCateg - objeto para a lista de categorias do produto    บฑฑ
ฑฑบ          ณ oIcon05 - apresenta o status do armazem do produto           บฑฑ
ฑฑบ          ณ aArmazens - matriz com a lista de aramazens do produto       บฑฑ
ฑฑบ          ณ oListArmaz - objeto para a lista de armazens do produto      บฑฑ
ฑฑบ          ณ oIntEcomm -objeto de verificacao da configuracao IntEcomm.iniบฑฑ
ฑฑบ          ณ oIcon06 - apresenta o status da configuracao IntEcomm.ini    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ865Fornece(cProduto, oIcon01, oStatus, cStatus,; 
                             nPrecoCheio, oIcon02, nPrecoTab, nEstqMinimo,; 
                             oIcon03, cFornecedor, cXProdPai, cProdutoPai,; 
                             aProdutos, oListProd, oIcon04, aCategoria,; 
                             oListCateg, oIcon05, aArmazens, oListArmaz,; 
                             oIntEcomm, oIcon06)

Default cProduto    := ""
Default oIcon01     := nil
Default oStatus     := nil
Default cStatus     := ""
Default nPrecoCheio := 0
Default oIcon02     := nil
Default nPrecoTab   := 0
Default nEstqMinimo := 0
Default oIcon03     := nil
Default cFornecedor := ""
Default cXProdPai   := ""
Default cProdutoPai := ""
Default aProdutos   := {}
Default oListProd   := nil
Default oIcon04     := nil
Default aCategoria  := {}
Default oListCateg  := nil
Default oIcon05     := nil
Default aArmazens   := {}
Default oListArmaz  := nil
Default oIntEcomm   := nil
Default oIcon06     := nil

SetFunName("MATA020")

MATA020()

SetFunName("LOJA865")

//Atualiza os dados da Tela
LJ865Produto(cProduto, @oIcon01, @oStatus, @cStatus,; 
             @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,; 
             @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,; 
             @aProdutos, @oListProd, @oIcon04, @aCategoria,; 
             @oListCateg, @oIcon05, @aArmazens, @oListArmaz,; 
             @oIntEcomm, @oIcon06)

Return .T. 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ865ProdForบ Autor ณ Antonio C Ferreira บ Data ณ 16/04/2013  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamar o Cadastro de Amarracao Produto X Fornecedor.         บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cProduto - codigo do produto                                 บฑฑ
ฑฑบ          ณ oIcon01 - apresenta o status se o produto ้ e-commerce       บฑฑ
ฑฑบ          ณ oStatus - Objeto do Status do produto                        บฑฑ
ฑฑบ          ณ cStatus - Valor do Status do produto                         บฑฑ
ฑฑบ          ณ nPrecoCheio - Valor do preco cheio                           บฑฑ
ฑฑบ          ณ oIcon02 - apresenta o status do preco na tela                บฑฑ
ฑฑบ          ณ nPrecoTab - Valor do preco de tabela                         บฑฑ
ฑฑบ          ณ nEstqMinimo - valor do estoque minimo                        บฑฑ
ฑฑบ          ณ oIcon03 - apresenta o status do fornecedor                   บฑฑ
ฑฑบ          ณ cFornecedor - valor do fornecedor                            บฑฑ
ฑฑบ          ณ cXProdPai - campo auxiliar para o produto pai                บฑฑ
ฑฑบ          ณ cProdutoPai - valor do produto pai                           บฑฑ
ฑฑบ          ณ aProdutos - lista de produtos filhos                         บฑฑ
ฑฑบ          ณ oListProd - objeto da lista de produtos filhos               บฑฑ
ฑฑบ          ณ oIcon04 - apresenta o status da categoria                    บฑฑ
ฑฑบ          ณ aCategoria - matriz com a lista de categorias do produto     บฑฑ
ฑฑบ          ณ oListCateg - objeto para a lista de categorias do produto    บฑฑ
ฑฑบ          ณ oIcon05 - apresenta o status do armazem do produto           บฑฑ
ฑฑบ          ณ aArmazens - matriz com a lista de aramazens do produto       บฑฑ
ฑฑบ          ณ oListArmaz - objeto para a lista de armazens do produto      บฑฑ
ฑฑบ          ณ oIntEcomm -objeto de verificacao da configuracao IntEcomm.iniบฑฑ
ฑฑบ          ณ oIcon06 - apresenta o status da configuracao IntEcomm.ini    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ865ProdFor(cProduto, oIcon01, oStatus, cStatus,; 
                             nPrecoCheio, oIcon02, nPrecoTab, nEstqMinimo,; 
                             oIcon03, cFornecedor, cXProdPai, cProdutoPai,; 
                             aProdutos, oListProd, oIcon04, aCategoria,; 
                             oListCateg, oIcon05, aArmazens, oListArmaz,; 
                             oIntEcomm, oIcon06)

Default cProduto    := ""
Default oIcon01     := nil
Default oStatus     := nil
Default cStatus     := ""
Default nPrecoCheio := 0
Default oIcon02     := nil
Default nPrecoTab   := 0
Default nEstqMinimo := 0
Default oIcon03     := nil
Default cFornecedor := ""
Default cXProdPai   := ""
Default cProdutoPai := ""
Default aProdutos   := {}
Default oListProd   := nil
Default oIcon04     := nil
Default aCategoria  := {}
Default oListCateg  := nil
Default oIcon05     := nil
Default aArmazens   := {}
Default oListArmaz  := nil
Default oIntEcomm   := nil
Default oIcon06     := nil

SetFunName("MATA060")

MATA060()

SetFunName("LOJA865")

//Atualiza os dados da Tela
LJ865Produto(cProduto, @oIcon01, @oStatus, @cStatus,; 
             @nPrecoCheio, @oIcon02, @nPrecoTab, @nEstqMinimo,; 
             @oIcon03, @cFornecedor, @cXProdPai, @cProdutoPai,; 
             @aProdutos, @oListProd, @oIcon04, @aCategoria,; 
             @oListCateg, @oIcon05, @aArmazens, @oListArmaz,; 
             @oIntEcomm, @oIcon06)

Return .T.



