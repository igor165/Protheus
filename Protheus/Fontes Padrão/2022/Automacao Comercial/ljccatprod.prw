#INCLUDE "PROTHEUS.CH"   
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LJCCATPROD.CH"

#DEFINE CATEGORIA   1     				//Codigo da Categoria
#DEFINE DESCRICAO   2     				//Descricao da Categoria
#DEFINE CATEGPAI    3     				//Codigo da Categoria Pai

Function LJCCATPROD() ;Return   // "dummy" function - Internal Use

                                        	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณLJCProdEquiv   บAutor  ณVendas Clientes     บ Data ณ  02/12/09บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณClasse responsavel pela integracao dos produtos equivalentes  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja\FrontLoja                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/     
Class LJCProdEquiv   

	Data aCategoria                             //array com as categorias pais 
	Data aCatFilhos                             //array com as categorias filhos
	
	Data alstBusca								//array com o conteudo do listBox busca
	Data aRetProd                               //array com os produtos retornados
	
	Method New()                               	//metodo construtor
	Method TelaPescCat()                        //metodo que monta a tela de pesquisa de produtos na Categoria de Produtos
	Method TelaResult()                         //metodo que monta a tela com o resultado dos produtos equivalentes
	Method SetCbx()								//metodo responsavel em atualizar o ComboBox Filho e ListBox
	Method AddLinha()                           //metodo que adiciona linha no ListBox.
	Method DelLinha()                           //metodo que deleta linha no ListBox.
	Method SetListResult()                      //metodo que atualiza as informacoes do listbox result
	Method LimpaTela()                          //metodo responsvel em limpar a tela
	Method Resolucao()		                    //metodo auxiliar ajusta a resolucao da tela
	
	Method SelProdutos()                        //metodo que seleciona produtos das categorias escolhidas
	Method SelProdEqui()                        //metodo que seleciona produtos equivalentes a outro produto
	Method RetProdutos()			            //metodo que retorna os produtos da consulta
	Method ConsultaCat()						//metodo auxiliar para chamada do SelCategorias
	Method SelCategorias()                      //metodo que retorna as categorias 
	Method RetCatFilhos()			            //metodo que retorna os filhos de uma determinada categoria
	
	Method MontaArray() 						//metodo responsavel em retornar as categorias sem repetilas

EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNew       บAutor  ณMicrosiga           บ Data ณ  02/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo Construtor                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LJCProdEquiv                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Method New() Class LJCProdEquiv  

	Self:aCategoria  := { {}, {}}
	Self:aCatFilhos  := {} 

	Self:alstBusca	 := {} 
	Self:aRetProd    := {}
	
Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTelaPescCatบAutor  ณMicrosiga           บ Data ณ  02/12/09   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria tela de consulta por categoria.						   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LJCProdEquiv                                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TelaPescCat() Class LJCProdEquiv  
	Local aProds     := {}  
	Local oDlgCateg	 := Nil			
	Local acbxCatego := Self:aCategoria[DESCRICAO]
	Local ccbxCatego := acbxCatego[1]
	Local olstCatSup := Nil
	Local alstCatSup := acbxCatego
	Local acbxCatFil := Self:RetCatFilhos(Self:aCategoria[CATEGORIA][1])
	Local ccbxCatFil := ""
	Local olstCatFil := Nil
	Local alstCatFil := acbxCatFil
	Local obtnAdici  := Nil
	Local olstBusca  := Nil
	Local alstBusca  := {""}
	Local obtnExclui := Nil
	Local obtnBusca  := Nil
	Local obtnLimpa  := Nil
	Local obtnInser  := Nil
	Local olstResul  := Nil
	Local alstResul  := {}
	Local nList      := 1  
	Local oOK        := LoadBitmap(GetResources(),'br_verde')
	Local oNO        := LoadBitmap(GetResources(),'br_vermelho')
	Local aHeaders   := {"", STR0001, STR0002, STR0003} //##"Codigo" ##"Descri็ใo" ##"Quantidade"
	Local aTamHead   := {20,50,70,50} 
	Local cbLine     := "{||{ If(alstResul[olstResul:nAt,01],oOK,oNO),alstResul[olstResul:nAt,02],"+;
						"alstResul[olstResul:nAt,03],alstResul[olstResul:nAT,04] } }"

	If Len(acbxCatFil) > 0
		ccbxCatFil := acbxCatFil[1]
	EndIf   

   	AADD(alstResul, {.F., "", "", ""})

	DEFINE MSDIALOG oDlgCateg TITLE STR0004 FROM ::Resolucao(178),::Resolucao(181) TO ::Resolucao(624),::Resolucao(853) PIXEL //"Pesquisa de Produtos"
	
		// Grupo Selecionar Categorias
		@ ::Resolucao(003),::Resolucao(002) TO ::Resolucao(097),::Resolucao(337) LABEL STR0005 PIXEL OF oDlgCateg //"Selecionar Categorias"
		                        
		// Grupo Categoria Superior
		@ ::Resolucao(013),::Resolucao(008) TO ::Resolucao(093),::Resolucao(150) LABEL STR0006 PIXEL OF oDlgCateg //"Categoria Superior"
		ocbxCatego := TComboBox():New(::Resolucao(023),::Resolucao(012),{|u|if(PCount()>0,ccbxCatego:=u,ccbxCatego)},;
                      acbxCatego,::Resolucao(135),::Resolucao(010),oDlgCateg,,{|| Self:SetCbx(Self:aCategoria[CATEGORIA][ocbxCatego:nAt], @acbxCatFil, @alstCatFil, @ocbxCatFil, @olstCatFil) };
                      ,,,,.T.,,,,,,,,,'ccbxCatego')
		olstCatSup := TListBox():New(::Resolucao(036),::Resolucao(012),{|u|If(Pcount()>0,nList:=u,nList)},;
	          		   alstCatSup,::Resolucao(135),::Resolucao(053),,oDlgCateg,,,,.T.)
		olstCatSup:SetArray(alstCatSup)
		
		// Grupo Categoria Filho
		@ ::Resolucao(013),::Resolucao(154) TO ::Resolucao(093),::Resolucao(296) LABEL STR0007 PIXEL OF oDlgCateg  //"Categoria Filho"
		ocbxCatFil := TComboBox():New(::Resolucao(023),::Resolucao(157),{|u|if(PCount()>0,ccbxCatFil:=u,ccbxCatFil)},;
                      acbxCatFil,::Resolucao(135),::Resolucao(010),oDlgCateg,,{|| };
                      ,,,,.T.,,,,,,,,,'ccbxCatFil')
		olstCatFil := TListBox():New(::Resolucao(036),::Resolucao(157),{|u|If(Pcount()>0,nList:=u,nList)},;
	          		   alstCatFil,::Resolucao(135),::Resolucao(053),,oDlgCateg,,,,.T.)
		olstCatFil:SetArray(alstCatFil)
		obtnAdici  := TButton():New( ::Resolucao(080),::Resolucao(297), STR0008,oDlgCateg,{|| Self:AddLinha(@olstBusca, Self:aCategoria[CATEGORIA][ocbxCatego:nAt], ccbxCatFil, alstCatFil)},; 
                   ::Resolucao(037),::Resolucao(012),,,.F.,.T.,.F.,,.F.,,,.F. ) //"Adicionar"
	                            
		// Grupo Filtro de Busca
		@ ::Resolucao(097),::Resolucao(002) TO ::Resolucao(161),::Resolucao(337) LABEL STR0009 PIXEL OF oDlgCateg //"Filtro de Busca"
		olstBusca := TListBox():New(::Resolucao(105), ::Resolucao(004),{|u|If(Pcount()>0,nList:=u,nList)},;
	          		  alstBusca,::Resolucao(291),::Resolucao(052),,oDlgCateg,,,,.T.)
		olstBusca:SetArray(alstBusca)	          		  
		obtnExclui := TButton():New( ::Resolucao(106),::Resolucao(297), STR0010,oDlgCateg,{|| alstResul := Self:DelLinha(@olstBusca), olstResul:SetArray(alstResul), olstResul:bLine:= &(cbLine) },;
                   ::Resolucao(037),::Resolucao(012),,,.F.,.T.,.F.,,.F.,,,.F. ) //"Excluir"
		obtnBusca  := TButton():New( ::Resolucao(145),::Resolucao(297), STR0011,oDlgCateg,; 
				   {|| aProds := Self:SelProdutos(Self:alstBusca, Self:alstBusca, 1, 3), alstResul := Self:SetListResult(aProds), olstResul:SetArray(alstResul), olstResul:bLine:= &(cbLine)},;
                   ::Resolucao(037),::Resolucao(012),,,.F.,.T.,.F.,,.F.,,,.F. ) //"Buscar"

		// Grupo Resultado
		@ ::Resolucao(161),::Resolucao(002) TO ::Resolucao(225),::Resolucao(337) LABEL STR0012 PIXEL OF oDlgCateg //"Resultado"
		olstResul := TCBrowse():New( ::Resolucao(168),::Resolucao(004),::Resolucao(291),::Resolucao(052), ,aHeaders,aTamHead,;
	    		     oDlgCateg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
		// Seta o vetor a ser utilizado
		olstResul:SetArray(alstResul)          
		// Monta a linha a ser exibina no Browse
		olstResul:bLine := {||{ If(alstResul[olstResul:nAt,01],oOK,oNO),alstResul[olstResul:nAt,02],alstResul[olstResul:nAt,03],;	
        		            alstResul[olstResul:nAT,04] } }
		// Evento de DuploClick (troca o valor do primeiro elemento do Vetor)	    
        olstResul:bLDblClick := {|| alstResul[olstResul:nAt][1] := !alstResul[olstResul:nAt][1],olstResul:DrawSelect() }
		                           
		obtnLimpa  := TButton():New( ::Resolucao(168),::Resolucao(297), STR0019,oDlgCateg,{|| alstResul := Self:LimpaTela(@olstBusca), olstResul:SetArray(alstResul), olstResul:bLine:= &(cbLine)},; //"Limpa"
	               ::Resolucao(037),::Resolucao(012),,,.F.,.T.,.F.,,.F.,,,.F. )
		
		obtnInser  := TButton():New( ::Resolucao(208),::Resolucao(297), STR0013,oDlgCateg,{|| Self:aRetProd := Self:RetProdutos(alstResul), oDlgCateg:End() },; //"Inserir"
	               ::Resolucao(037),::Resolucao(012),,,.F.,.T.,.F.,,.F.,,,.F. )
	
	ACTIVATE MSDIALOG oDlgCateg CENTERED
	
Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTelaResultบAutor  ณMicrosiga           บ Data ณ  02/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria tela com os produtos equivalentes.					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcCodProd - Codigo do produto.								  บฑฑ
ฑฑบ          ณcGrpProd - Grupo do produto.								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LJCProdEquiv                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TelaResult(cCodProd, cGrpProd) Class LJCProdEquiv
	Local oDlg       := Nil
	Local alstResul  := {}
	Local olstResul  := Nil             
	Local aHeaders   := {"", STR0001, STR0002, STR0003} //##"Codigo" ##"Descri็ใo" ##"Quantidade"
	Local aTamHead   := {20,60,150,40}
	Local oOK        := LoadBitmap(GetResources(),'br_verde')
	Local oNO        := LoadBitmap(GetResources(),'br_vermelho')
	Local obtnInser  := Nil  
	Local aProds     := {}
		
	// Carrega o array do Grid
   	aProds 	  := Self:SelProdEqui(cCodProd, cGrpProd)  
   	
   	If !Empty(aProds)
	   	alstResul := Self:SetListResult(aProds)
	
		DEFINE MSDIALOG oDlg TITLE STR0014 FROM ::Resolucao(178),::Resolucao(181) TO ::Resolucao(361),::Resolucao(689) PIXEL //"Produtos Equivalentes"
		
			// Cria as Grupo Resultado
			@ ::Resolucao(001),::Resolucao(003) TO ::Resolucao(076),::Resolucao(253) LABEL STR0012 PIXEL OF oDlg  //"Resultado"
			
			// Cria o Grid de Resultado
			olstResul := TCBrowse():New( ::Resolucao(007),::Resolucao(006),::Resolucao(243),::Resolucao(064), ,aHeaders,aTamHead,;
		    		     oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
			olstResul:SetArray(alstResul)          
			olstResul:bLine := {||{ If(alstResul[olstResul:nAt,01],oOK,oNO),alstResul[olstResul:nAt,02],alstResul[olstResul:nAt,03],;	
	        		            alstResul[olstResul:nAT,04] } }
	        olstResul:bLDblClick := {|| alstResul[olstResul:nAt][1] := !alstResul[olstResul:nAt][1],olstResul:DrawSelect() }
		          		   
			// Cria Botao Inserir
			obtnInser  := TButton():New( ::Resolucao(077),::Resolucao(215), STR0013,oDlg,{|| Self:aRetProd := Self:RetProdutos(alstResul), oDlg:End() },; //"Inserir"
		               ::Resolucao(037),::Resolucao(012),,,.F.,.T.,.F.,,.F.,,,.F. )
			
		ACTIVATE MSDIALOG oDlg CENTERED 
	Else	
		MsgAlert(STR0018) //"Nao Existe Categorias Cadastradas."	    
	EndIf  
	
Return Self 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณSetCbx	บAutor  ณVendas Clientes     บ Data ณ  15/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em atualizar o ComboBox Filho e ListBox. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLJCProdEquiv                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SetCbx(cCategoria, aComboBox, aListBox, oComboBox, oListBox) Class LJCProdEquiv
	aComboBox := Self:RetCatFilhos(cCategoria)  
	If Len(aComboBox) == 0
		aComboBox := {""}	
	EndIf
	oComboBox:SetItems(aComboBox) 
	
	aListBox := aComboBox
	oListBox:SetArray(aListBox)
Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณAddLinha  บAutor  ณVendas Clientes     บ Data ณ  15/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que adiciona linha no ListBox.						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLJCProdEquiv                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AddLinha(oList, cCategoria, cDesFilho, aFilhos) Class LJCProdEquiv  
    Local nPos       := Ascan(Self:aCategoria[CATEGORIA],{|x| x == cCategoria}) 
    Local cDescCate  := Self:aCategoria[DESCRICAO][nPos]
	Local cCatFilho  := ""
	Local cDesCatFil := ""
	Local nCont      := 1 
	Local nTam    	 := Len(Self:aCatFilhos)   
	Local nTamCod    := TAMSX3("ACU_COD")[1]
	Local nTamDesc   := TAMSX3("ACU_DESC")[1] 
	Local cEspaco    := Space(8)
	
	For nCont := 1 To nTam
		nPos := Ascan(Self:aCatFilhos[nCont][CATEGPAI], {|x| x == cCategoria} ) 
		If nPos > 0  
			aFilhos := Self:aCatFilhos[nCont][DESCRICAO]		
			nPos    := Ascan(aFilhos, {|x| ALLTRIM(x) == ALLTRIM(cDesFilho)} ) 
			cCatFilho  := Self:aCatFilhos[nCont][CATEGORIA][nPos]
			cDesCatFil := Self:aCatFilhos[nCont][DESCRICAO][nPos]
			Exit 
		EndIf	
	Next nCont
	
	oList:Insert(STR0015 + "  " + PADR(cCategoria, nTamCod ) + cEspaco +;  //"CATEGORIA SUPERIOR:"    
				 STR0016 + "  " + PADR(cDescCate , nTamDesc) + "  |  " +;	//"DESCRICAO:"
	             STR0017 + "  " + PADR(cCatFilho , nTamCod ) + cEspaco +; 	//"CATEGORIA INFERIOR:"
	             STR0016 + "  " + PADR(cDesCatFil, nTamDesc),; 				//"DESCRICAO:"
	             oList:Len() )
   	AADD(Self:alstBusca, {cCategoria, cDescCate, cCatFilho, cDesCatFil} )
   	
Return Self   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณDelLinha  บAutor  ณVendas Clientes     บ Data ณ  15/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDeleta uma determinada linha de um ListBox				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLJCProdEquiv                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoList - ListBox que vai ser alterado						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method DelLinha(oList) Class LJCProdEquiv  
	Local nPos   := oList:nAt
	Local aAux   := ACLONE(Self:alstBusca)
	Local nCont  := 1
	Local nTam   := 0  
	Local aRet   := {}
	
	AADD(aRet, {.F., "", "", ""})
    
    Self:alstBusca := {}
    
    If !Empty(aAux)
		If nPos > 0 
			oList:Del(nPos)	
			ADEL(aAux, nPos)
		EndIf            
			
		nTam := Len(aAux)
			
		While nCont <= nTam .AND. aAux[nCont] <> Nil
			AADD(Self:alstBusca, aAux[nCont])
			nCont++  
		End
	EndIf

Return aRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณSetListResultบAutor  ณVendas Clientes     บ Data ณ  15/12/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza as informacoes do listbox result.					 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLJCProdEquiv                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoList   - ListBox olstResul								     บฑฑ
ฑฑบ			 ณaChkBox - Array com os CheckBox                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SetListResult(aProdutos) Class LJCProdEquiv
	Local nTamResult := 0 
	Local nCont      := 1
	Local aDados     := {}
	
	AADD(aDados, {.F., "", "", ""})
	                    
	nTamResult := Len(aProdutos) 

	If nTamResult >= 1
		aDados := {}
		For nCont:= 1 To nTamResult    
			AADD( aDados, {.F., ALLTRIM(aProdutos[nCont][1]), ALLTRIM(aProdutos[nCont][2]), ALLTRIM(aProdutos[nCont][3]) } )
		Next nTamResult
	EndIf
	
Return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณSetListResultบAutor  ณVendas Clientes     บ Data ณ  15/12/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em limpar a tela.							 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLJCProdEquiv                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LimpaTela( olstBusca ) Class LJCProdEquiv  
	Local aRet := {}

    //Limpa Busca
    Self:alstBusca := {}
	olstBusca:SetArray( {""} )	          		  
	
	//Limpa Result
	AADD(aRet, {.F., "", "", ""})  
	
	//Limpa Produtos Retornados
	Self:aRetProd    := {}

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณResolucao บAutor  ณVendas Clientes     บ Data ณ  15/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao responsavel por manter o Layout independente da      บฑฑ
ฑฑบ          ณresolucao horizontal do Monitor do Usuario.    			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLJCProdEquiv                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - nTam)											  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Resolucao(nTam) Class LJCProdEquiv
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	
	If nHRes == 640	
	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).OR.(nHRes == 800)	
	// Resolucao 800x600
		nTam *= 1
	Else	
	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

Return Int(nTam)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณSelProdutos บAutor  ณVendas Clientes     บ Data ณ  17/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em selecionar os produtos dependendo das	บฑฑ
ฑฑบ          ณcategorias selecionadas.										บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLJCProdEquiv                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaDados - Com os produtos retornados no select.				บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SelProdutos(aCategoria, aCatFilho, nPosCatP, nPosCatF, cProdEqui) Class LJCProdEquiv   
	Local cAlias  := "ACVTMP"  
	Local cQuery  := ""
	Local cFilACV := xFilial("ACV")
	Local cFilSB1 := xFilial("SB1")
	Local cFilSB2 := xFilial("SB2") 
	Local cGrpSb1 := Space(TAMSX3("B1_GRUPO")[1])
	Local aCate   := {}
	Local aCatFil := {}
	Local nCont   := 1 
	Local nCont2  := 1 
	Local nTamCat := 0
	Local nTamFil := 0   
	Local nTamFilF:= 0
	Local nPosIni := 0   
	Local nTam    := 1   
	Local aDados  := {} 
	Local cQtda   := ""  
	Local aAuxFilhos := {} 
	Local aFilFilhos := {}     
	
	DEFAULT cProdEqui := ""

	//monta array para where sem repeticoes
	aCate   := Self:MontaArray(aCategoria, nPosCatP)

	//monta array para where sem repeticoes
	aCatFil := Self:MontaArray(aCatFilho, nPosCatF)
	 
	//verifica se categoras filhos tem filhos
	For nCont:= 1 To Len(aCatFil)
		Self:SelCategorias(aCatFil[nCont], .F., {}, {}, {}, @aAuxFilhos)	
		//AADD(aCatFil, aAuxFil[nCont])
	Next nCont
	
	//monta array com filhos dos filhos da categoria
	For nCont:=1 To Len(aAuxFilhos)
		For nCont2:=1 To Len(aAuxFilhos[nCont][1])
			AADD(aFilFilhos, aAuxFilhos[nCont][1][nCont2])			
		Next nCont2	
	Next nCont
	
	If Len(aCate) > 0 .OR. Len(aCatFil) > 0
		
		nTamCat := Len(aCate) 
		
		nTamFil := Len(aCatFil)  
		
		nTamFilF:= Len(aFilFilhos)
	
		If Select(cAlias) > 0
			(cAlias)->(DbCloseArea())
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe existir o campo, Ordena por ACV-> ACV_SEQPRDณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ACV->(FieldPos("ACV_SEQPRD")) > 0
			cQuery := "SELECT DISTINCT(SB1.B1_COD), SB1.B1_DESC, SB2.B2_QATU, ACV.ACV_CATEGO,ACV.ACV_SEQPRD "
		Else
			cQuery := "SELECT DISTINCT(SB1.B1_COD), SB1.B1_DESC, SB2.B2_QATU, ACV.ACV_CATEGO "
		EndIf		
		cQuery += "FROM " + RetSqlName("ACV") + " ACV JOIN " + RetSqlName("SB1") + " SB1 "  
		cQuery += "ON (ACV.ACV_CODPRO = SB1.B1_COD OR " 
		cQuery += "(SB1.B1_GRUPO <> '" + cGrpSb1 + "' AND ACV.ACV_GRUPO = SB1.B1_GRUPO) ) AND "
	 	cQuery += "SB1.B1_FILIAL = '" + cFilSB1 + "' AND "
	 	cQuery += "SB1.D_E_L_E_T_= ' ' "  
		cQuery += "LEFT JOIN " + RetSqlName("SB2") + " SB2 ON ACV.ACV_CODPRO = SB2.B2_COD AND "	
		cQuery += "SB2.B2_FILIAL = '" + cFilSB2 + "' AND "
		cQuery += "SB2.D_E_L_E_T_= ' ' "
	
		cQuery += "WHERE " 

		//adiciona categorias pais
		For nCont := 1 to nTamCat
			cQuery += "ACV.ACV_CATEGO = '" + aCate[nCont] + "' OR "  		   	
		Next nCont

		//adiciona categorias filhos dos filhos           
		For nCont := 1 to nTamFilF
			cQuery += "ACV.ACV_CATEGO = '" + aFilFilhos[nCont] + "' OR "  		   			
		Next nCont
		
		//adiciona categorias filhos
		For nCont := 1 to nTamFil
			cQuery += "ACV.ACV_CATEGO = '" + aCatFil[nCont] + "' OR "  		   	
		Next nCont
		 
		nPosIni := Len(cQuery) - 3
		nTam	:= Len(cQuery) - nPosIni
		If ALLTRIM(SUBSTR(cQuery, nPosIni, nTam)) == "OR"
			cQuery := STUFF(cQuery, nPosIni, nTam, "AND ")
		EndIf     

		If ACV->(FieldPos("ACV_SEQPRD")) > 0
			cQuery += "SB1.B1_COD <> '"+cProdEqui+"' AND "
		EndIf
		cQuery += "ACV.ACV_FILIAL = '" + cFilACV + "' AND "
		cQuery += "ACV.D_E_L_E_T_= ' ' "
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe existir o campo, Ordena por ACV-> ACV_SEQPRDณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ACV->(FieldPos("ACV_SEQPRD")) > 0
			cQuery += "ORDER BY ACV.ACV_SEQPRD"
		Else
			cQuery += "ORDER BY SB1.B1_COD"
		EndIf
		cQuery := ChangeQuery(cQuery)
		
		DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
		DbGoTop()	  
		
		While !(cAlias)->(Eof())
			cQtda := CVALTOCHAR((cAlias)->B2_QATU)
			If Empty(cQtda)
				cQtda := "0"			
			EndIf          
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณNao adiciona produto repetidoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If Len(aDados) > 0
				If Ascan(aDados,{|x| x[1] == (cAlias)->B1_COD}) == 0
				   	AADD(aDados, {(cAlias)->B1_COD, (cAlias)->B1_DESC, cQtda} )              				
				EndIf
			Else	
			   	AADD(aDados, {(cAlias)->B1_COD, (cAlias)->B1_DESC, cQtda} )              
		   	EndIf
		   	
			(cAlias)->(DbSkip())
		End                      
		
	EndIf

Return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณSelProdEqui บAutor  ณVendas Clientes     บ Data ณ  17/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSeleciona produtos equivalentes a outro produto, pelas        บฑฑ
ฑฑบ          ณcategorias desse produtos.				    		    	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLJCProdEquiv                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - nTam)											    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SelProdEqui(cCodProd, cGruProd) Class LJCProdEquiv   
	Local cAlias  := "ACVPRO"   
	Local cQuery  := ""
	Local aCatFil := {} 
	Local aRet    := {}

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
	cQuery := "SELECT ACV_CATEGO, ACV_CODPRO, ACV_GRUPO "
	cQuery += "FROM " + RetSqlName("ACV") + " "
	cQuery += "WHERE ACV_CODPRO = '" + cCodProd + "' "
	If !Empty(cGruProd)
		cQuery += "OR ACV_GRUPO = '" + cGruProd + "' " 
	EndIf	    
	cQuery += "AND ACV_FILIAL = '" + xFilial("ACV") + "' AND "
	cQuery += "D_E_L_E_T_= ' ' "
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe existir o campo, Ordena por ACV-> ACV_SEQPRDณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ACV->(FieldPos("ACV_SEQPRD")) > 0
		cQuery += "ORDER BY ACV_SEQPRD"
	Else	
		cQuery += "ORDER BY ACV_CATEGO"
	EndIf			
	cQuery := ChangeQuery(cQuery)
	
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
	DbGoTop()  
	
	While !(cAlias)->(Eof()) 
	   	AADD(aCatFil, {(cAlias)->ACV_CATEGO} )              
		(cAlias)->(DbSkip())
	End                      
    
	If !Empty(aCatFil)
		aRet := Self:SelProdutos( {}, aCatFil, 0, 1, cCodProd )
	EndIf	
	
Return aRet
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณRetProdutos บAutor  ณVendas Clientes     บ Data ณ  17/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os produtos da consulta								บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaCodProd - Contendo o codigos dos produtos					บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLJCProdEquiv                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoGrid - Grid com os produtos.									บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method RetProdutos(aGrid) Class LJCProdEquiv 
	Local aCodProd := {}   
    Local nTam     := Len(aGrid)
    Local nCont    := 1
    Local nCodProdu:= 2
	
	For nCont:=1 To nTam
		
		If aGrid[nCont][1]
			AADD(aCodProd, aGrid[nCont][nCodProdu])
		EndIf
	
	Next nCont    

Return aCodProd

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณRetCatFilhosบAutor  ณVendas Clientes     บ Data ณ  15/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna todas as descricoes das categorias que estao abaixo   บฑฑ
ฑฑบ			 ณde uma determinada categoria.								    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaFilhos - Contendo a descricao das categorias filhos.		    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcCategoria - Categoria pai para busca. 					    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLJCProdEquiv                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method RetCatFilhos(cCategoria) Class LJCProdEquiv 
	Local aFilhos 	 := {}   
	Local nTam    	 := Len(Self:aCatFilhos)   
	Local nCont      := 1 
	Local nPos       := 0
	      
	For nCont := 1 To nTam
		nPos := Ascan(Self:aCatFilhos[nCont][CATEGPAI], {|x| x == cCategoria} ) 
		If nPos > 0
			aFilhos := Self:aCatFilhos[nCont][DESCRICAO]		
			Exit 
		EndIf	
	Next nCont

Return aFilhos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณConsultaCat บAutor  ณVendas Clientes     บ Data ณ  15/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo auxiliar para a chamada do methodo SelCategoria.	    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLJCProdEquiv                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ConsultaCat() Class LJCProdEquiv   
	Local cCodVazio  :=CriaVar("ACU_COD",.F.)
	Local aDados  := {}
                       
	Self:SelCategorias(cCodVazio, .F., @aDados, @Self:aCategoria[CATEGORIA], @Self:aCategoria[DESCRICAO], @Self:aCatFilhos)
    
	If !Empty(Self:aCategoria[CATEGORIA])
		Self:TelaPescCat() 
	Else
		MsgAlert(STR0018) //"Nao Existe Categorias Cadastradas."	    
	EndIf	

Return Nil  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณSelCategoriasบAutor  ณVendas Clientes     บ Data ณ  15/12/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSeleciona as Categorias, Pais e Filhos						 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcCodPai    - Codigo da Categoria Pai.		  					 บฑฑ
ฑฑบ          ณlSeek1     - Coluna do array que servira de procura.           บฑฑ
ฑฑบ          ณaDados     - Array com todas as Categorias                     บฑฑ
ฑฑบ   		 ณaCodCate   - Array com os codigos das categorias pais.         บฑฑ
ฑฑบ			 ณaDescCate  - Array com as descricoes das categorias pais.      บฑฑ
ฑฑบ			 ณaCatFilhos - Array com as categorias filhos.                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLJCProdEquiv                                                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SelCategorias(cCodPai, lSeek1, aDados, aCodCate, aDescCate, aCatFilhos)  Class LJCProdEquiv 
	Local nRec		:= 0
	Local aArea		:= GetArea()
	Local nCont		:= 1
	Local nTam      := 1 
	Local lCpBloq	:= (ACU->(FieldPos("ACU_MSBLQL")) > 0)
	Local cTexto    := Space(130)
	Local cCodCargo := ""
	Local nPos      := 0  
	Local aAuxCod	:= {}        
	Local aAuxDes	:= {}        
	Local aAuxPai	:= {}        
	Local nY        := 1  
	
	DEFAULT lSeek1    := .F.
	
	dbSelectArea("ACV")
	dbSetOrder(1)
	
	dbSelectArea("ACU")
	dbSetOrder(2)
	
	//1 FILIAL+COD
	//2 FILIAL+CODPAI
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณProcura por uma categoria nao bloqueada (campo MSBLQL)ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lSeek1
	
		lSeek1:=MsSeek(xFilial("ACU")+cCodPai) .AND. (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))
	
		If !lSeek1 .AND. Found()
			While !lSeek1 .AND. !ACU->(Eof()) .AND. ACU->ACU_FILIAL == xFilial("ACU") .AND. ACU->ACU_CODPAI == cCodPai
				ACU->(DbSkip())
				lSeek1:= (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))			
			End
		EndIf
	
	EndIf
	
	If lSeek1  
		cCodCargo :=ACU_COD
		cTexto	  :=ACU->ACU_DESC                           			
		cCodPai   :=ACU->ACU_CODPAI    
	                                                         
		If !Empty(cCodPai) .And. !Empty(cTexto) .And. !Empty(cCodCargo) 
			AADD( aDados, {cCodCargo, cTexto, cCodPai} ) 
		EndIf                                   
		
		// Enquanto esta regiao for a regiao pai
		While !Eof() .And. ACU_FILIAL+ACU_CODPAI == xFilial("ACU")+cCodPai
			//Salta categorias bloqueadas
			If (lCpBloq  .AND. ACU->ACU_MSBLQL == '1')
				DbSkip()
				Loop
			End   
			cCodCargo:=ACU_COD
			nRec:=Recno()
			cTexto:=ACU->ACU_DESC     
			
			If Empty(ACU_CODPAI) 
				AADD( aCodCate, ACU->ACU_COD)
				AADD( aDescCate, ACU->ACU_DESC)
			EndIF
			
			If Ascan(aDados,{|x| x[1] == ACU->ACU_COD}) == 0
				AADD( aDados, {ACU->ACU_COD, ACU->ACU_DESC, ACU->ACU_CODPAI} ) 
			EndIf 
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณProcura por uma categoria nao bloqueada (campo MSBLQL)ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			lSeek1:=MSSeek(xFilial("ACU")+cCodCargo) .AND. (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))
			
			If !lSeek1 .AND. Found()
				While !lSeek1 .AND. !ACU->(Eof()) .AND. ACU->ACU_FILIAL == xFilial("ACU") .AND. ACU->ACU_CODPAI == cCodCargo
					ACU->(DbSkip())
					lSeek1:= (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))			
				End
			EndIf
			
			If !lSeek1
				If cCodCargo <> aDados[Len(aDados)][1]
					AADD( aDados, {cCodCargo, cTexto, cCodPai} ) 
				EndIf	
			Else
				Self:SelCategorias(ACU_CODPAI, lSeek1, @aDados, @aCodCate, @aDescCate, @aCatFilhos)
			EndIf
			dbGoto(nRec)
			dbSkip()
		End
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณALIMENTA ARRAYS COM INFORMACAO DAS CATEGORIAS FILHOS.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nPos := Ascan(aDados,{|x| Empty(x[3])} ) 
	nTam := Len(aDados)
	If nPos > 0
		ADel(aDados, nPos)
		nTam--
	EndIf	
	
	For nCont:=1 To nTam
		AADD(aAuxCod, aDados[nCont][1] )	
		AADD(aAuxDes, aDados[nCont][2] )	
		AADD(aAuxPai, aDados[nCont][3] )	
	Next nCont 
	
	nPos := 0
	If nTam > 0
		nY := Len(aCatFilhos) 
	    If nY > 0              
		    nTam := Len(aAuxCod) 
	    	For nCont:= 1 To nTam
					nPos := Ascan(aCatFilhos[nY][3], {|x| x == aAuxPai[nCont]} ) 
					If nPos > 0
						Exit
					EndIf
			Next nCont
		EndIf
		If nPos > 0
			nTam := Len(aAuxPai)
			For nCont:= 1 To nTam
				AADD(aCatFilhos[nY][1], aAuxCod[nCont] )	
				AADD(aCatFilhos[nY][2], aAuxDes[nCont] )	
				AADD(aCatFilhos[nY][3], aAuxPai[nCont] )	
			Next nCont 
		Else
			AADD(aCatFilhos, {aAuxCod, aAuxDes, aAuxPai} )	
		EndIf
	EndIf
	
	aDados := {}
	RestArea(aArea)
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณMontaArray  บAutor  ณVendas Clientes     บ Data ณ  15/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Array sem categorias repetidas.							บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaRet - Contendo as Categorias.							    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaBusca   - Array que servira de procura.  					บฑฑ
ฑฑบ          ณnColProc - Coluna do array que servira de procura.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLJCProdEquiv                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method MontaArray(aBusca, nColProc) Class LJCProdEquiv 
	Local nCont    := 1
	Local nPos     := 0
	Local aRet     := {}
	Local aAux     := ACLONE(aBusca)
	Local cProcura := ""
	
	//adequa array com categoria
	For nCont := 1 To Len(aAux)
	    
	    If aAux[nCont] <> Nil
		   	cProcura := aBusca[nCont][nColProc]	    
			nPos := Ascan(aAux,{|x| x[nColProc] == ALLTRIM(cProcura)} ) 
			
			If nPos > 0
			    AADD(aRet, aAux[nPos][nColProc]) 
			    
		   		While nPos > 0
					aAux[nPos][nColProc] := ""
					nPos := Ascan(aAux,{|x| x[nColProc] == ALLTRIM(cProcura)} ) 
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ  Caso cProcura jแ for "" retorna array vazio e sai do loop.	ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If cProcura == ""
				   		aRet :={}
				   		nPos:=0
					EndIf
				End	
			EndIf
		EndIf
	Next nCont
	
Return aRet
