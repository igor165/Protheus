#INCLUDE "PCOXTREE.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "DbTree.ch"

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ PCOxTree      ºAutor  ³Fernando R. Muscalu º Data ³ 10/09/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Construtor da Tree 			                           	       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaPco                                                     	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aCfgTree     = Array com as configurações da Tree     	       º±±   
±±º          ³ aSeek        = Array de busca do valores                        º±±
±±º          ³ aShellTree   = Array com dimensões da tela    			       º±±
±±º          ³ aAllTrees    = Array contendo a Tree  						   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PCOxTree(aCfgTree,aSeek,aShellTree,aAllTrees,oNewTree)

Local cSeekKey		:= ""
Local nNodeOrigins	:= 0
Local lTreeView		:= .t.
Local oTree
Local cKey			:= ""

Local oTPanel1	:= Nil
Local oTPanel2	:= Nil

Default aShellTree		:= {}
Default aAllTrees		:= array(2)
Default oNewTree		:= ""

/*==================================================================================================================================================

Mapa de aCfgTree

aConfigTree[1] - Alias da Tabela                                    	
aConfigTree[2] - Campo para o noh filho
aConfigTree[3] - Campo para o noh pai

aConfigTree[4] - array com o o indice de busca do filho
	aConfigTree[4,1] - nro do indice de busca
	aConfigTree[4,n] - Campo que nao sera buscado. Atente-se que, na verdade este e um recurso 
					para os campos da direita que nao sao considerados dentro de uma busca.
aConfigTree[5] - array com o o indice de busca do pai
	aConfigTree[5,1] - nro do indice de busca
	aConfigTree[5,n] - Campo que nao sera buscado. Atente-se que, na verdade este e um recurso 
					para os campos da direita que nao sao considerados dentro de uma busca.
aConfigTree[6] - Descricao do No
aConfigTree[7] - Codigo de Bloco para a propriedade bAction da Tree
aConfigTree[8] - Codigo de Bloco para a propriedade bRClicked da Tree
aConfigTree[9] - Codigo de Bloco para a propriedade bDvlClicked da Tree                                                                           
aConfigTree[10] - Array com os icones dos nos
	aConfigTree[10,1] - Icone da Imagem exibida quando fechado
	aConfigTree[10,2] - Imagem exibida quando aberto	

Mapa de aSeek

aSeek[1] - Filial
aSeek[n] - conteudo para o campo da busca, lembrando deve respeitar a ordem em que aparece na chave de busca do SIX	

Mapa de aShellTree

aShellTree[1] - Valor da dimensao horizontal
aShellTree[2] - Valor da dimensao vertical
aShellTree[3] - Objeto da dialog

Mapa de aAllTrees

aAllTrees[1] - tree original
aAllTrees[2] - tree de comparacao

Objeto oNewTree - uso interno do PCO
	Como utiliza-lo fora do PCO:
	* Usa-lo como backup do objeto tree original, o objeto da montagem da tela, ou de aAllTrees[1]
	
	- No contexto da tela de simulacao do PCO ele e utilizado para reconstruir a arvore orignal com os icones modificados de acordo com as estruturas
	comparadas. 
==================================================================================================================================================*/

lTreeView := Iif(len(aShellTree) > 0,.t.,.f.)

If lTreeView
	
	//Instacia-se o objeto arvore, colocando-o na janela TreeWin
	oTree := xTree():New(0,0,aShellTree[2],aShellTree[1],aShellTree[3])
	
	//alinha a Tree dentro da Janela, e sempre a deixa na mesma dimensão,
   	//caso a estrutura seja maior que a janela, automaticamente surge uma barra de rolagem 
	oTree:Align	:= CONTROL_ALIGN_ALLCLIENT
Else 
	//Instancia-se um objeto tree, mas nao o aloca para dentro de nenhuma janela
	oTree:= xTree():New()
Endif

//Monta a chave de busca pelo noh pai	
cSeekKey := GetSearchReg(aCfgTree[1],aCfgTree[5],aCfgTree[3],(aCfgTree[1])->&(aCfgTree[2]),aSeek)

//Ordena por pai e por filho
(aCfgTree[1])->(DbSetOrder(aCfgTree[5,1])) 

//Encontrar o primeiro noh pai, ou seja, o no raiz
If (aCfgTree[1])->(DbSeek(cSeekKey)) 	
	BuildTreeChild((aCfgTree[1])->&(aCfgTree[2]),oTree,aCfgTree,aAllTrees,aSeek,lTreeView,oNewTree)	
Endif
	
If aAllTrees[1] == nil
	aAlltrees[1] := oTree
Else
	If !lTreeView
		aAlltrees[2] := oTree
	Endif	
Endif		

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³BuildTreeChild ºAutor  ³Fernando R. Muscalu º Data ³ 10/09/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Construtor dos filhos de cada Pai                       	       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaPco                                                     	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cFather      = Codigo do Pai                               	   º±±
±±º          ³  oTree        = Objeto oTree                                    º±±
±±º          ³  aCfgTree     = Array com as configurações da Tree              º±±
±±º          ³  aAllTrees    = Array contendo a Tree    			           º±±
±±º          ³  lTreeView    = Se existe dimensões da tela					   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function BuildTreeChild(cFather,oTree,aCfgTree,aAllTrees,aSeek,lTreeView,oNewTree)

Local cSeekKey			:= 	""

Local aAreaTab			:= (aCfgTree[1])->(GetArea())                                            
Local bBlockSeek		:= {|x| x := GetSearchReg(aCfgTree[1],aCfgTree[4],aCfgTree[2],cFather), x}
Local nPos				:= 0

Local aSrcTree		:= If( len(aCfgTree) > 9, {aCfgTree[10,1],aCfgTree[10,2]} , {"FOLDER516","FOLDER616"} )

Local aRetGetAdv	:= {}
Local cCODescri		:= ""
Local nI			:= 0

cSeekKey := GetSearchReg(aCfgTree[1],aCfgTree[5],aCfgTree[3],cFather)

(aCfgTree[1])->( DbSetOrder((aCfgTree[5,1]))) //Ordena por pai e por filho

//busca se filho e pai                     	
If (aCfgTree[1])->(DbSeek(cSeekKey))  
	//Se o Filho tambem e pai, entao ele e um no pai e deve ser adicionado como tal                   
	If Valtype(oNewTree) <> "C"
		If oNewTree:TreeSeek(Alltrim(cFather))
			If ( nPos := aScan(oNewTree:aNodes, {|x| alltrim(x[2]) == alltrim(oNewTree:CurrentNodeId) } ) ) > 0
				aRetGetAdv := GetAdvfVal(aCfgTree[1],aCfgTree[6],Eval(bBlockSeek),aCfgTree[4,1],"")
				For nI:=1 To Len(aRetGetAdv)
					cCODescri := AllTrim(aRetGetAdv[1])
					cCODescri += "-"+AllTrim(aRetGetAdv[2])
				Next
				oTree:AddItem(alltrim( cCODescri ),Alltrim( cFather ),oNewTree:aNodes[nPos,5],oNewTree:aNodes[nPos,6],2,aCfgTree[7],aCfgTree[8],aCfgTree[9]) //2  e filho, 1 e mesmo
				//Precisa posicionar no noh que foi incluido, pois nao fica posicionado pelo metodo addItem()
				oTree:TreeSeek(Alltrim( cFather ))
			Endif
		Endif	
	Else
		// GetAdvfVal(aCfgTree[1],aCfgTree[6],Eval(bBlockSeek),aCfgTree[4,1],"")
		aRetGetAdv := GetAdvfVal(aCfgTree[1],aCfgTree[6],Eval(bBlockSeek),aCfgTree[4,1],"")
		For nI:=1 To Len(aRetGetAdv)
			cCODescri := AllTrim(aRetGetAdv[1])
			cCODescri += "-"+AllTrim(aRetGetAdv[2])
		Next
		//oTree:AddTree(Alltrim(aCfgTree[6]),aSrcTree[1],aSrcTree[2],Alltrim(cFather),aCfgTree[7],aCfgTree[8],aCfgTree[9])
		oTree:AddTree(Alltrim(cCODescri),aSrcTree[1],aSrcTree[2],Alltrim(cFather),aCfgTree[7],aCfgTree[8],aCfgTree[9])
	Endif

    While (aCfgTree[1])->(!EOF()) .AND. Alltrim(cFather) == Alltrim((aCfgTree[1])->&(aCfgTree[3]))
		//Passa o filho para saber se ele é pai	    	
    	BuildTreeChild((aCfgTree[1])->&(aCfgTree[2]),oTree,aCfgTree,aSeek,aAllTrees,lTreeView,oNewTree)
    	
    	If Valtype(oNewTree) <> "C" 
    		//Precisa posicionar no noh O o pai, para que o proximo filho do mesmo pai fique integro,
    		//sem este posicionamento o filho pertenceria ao filho anterior que foi incluido
			oTree:TreeSeek(Alltrim((aCfgTree[1])->&(aCfgTree[3])))
		Endif
    	
    	(aCfgTree[1])->(DbSkip())    	
    EndDo

	If Valtype(oNewTree) == "C"     
   		oTree:EndTree() //encerra arvore filha
   	Endif	

Else                                                   
	
	//O Filho nao possui filho, logo, ele nao e adicionado como noh de arvore mas sim uma simples folha
	//Um noh folha e aquele que nao possui nos subordinados, ou nos filhos
	(aCfgTree[1])->(dbSetOrder(aCfgTree[4,1]))
	(aCfgTree[1])->(dbSeek(cSeekKey))
	
	If Valtype(oNewTree) <> "C"
		If oNewTree:TreeSeek(Alltrim(cFather))
			If ( nPos := aScan(oNewTree:aNodes, {|x| alltrim(x[2]) == alltrim(oNewTree:CurrentNodeId) } ) ) > 0
				aRetGetAdv := GetAdvfVal(aCfgTree[1],aCfgTree[6],Eval(bBlockSeek),aCfgTree[4,1],"")
				For nI:=1 To Len(aRetGetAdv)
					cCODescri := AllTrim(aRetGetAdv[1])
					cCODescri += "-"+AllTrim(aRetGetAdv[2])
				Next
				//oTree:AddItem(alltrim( (aCfgTree[1])->&(aCfgTree[6,2]) ),alltrim( (aCfgTree[1])->&(aCfgTree[2]) ),oNewTree:aNodes[nPos,5],oNewTree:aNodes[nPos,6],2,aCfgTree[7],aCfgTree[8],aCfgTree[9]) //2  e filho, 1 e mesmo
				oTree:AddItem(alltrim( cCODescri ),alltrim( (aCfgTree[1])->&(aCfgTree[2]) ),oNewTree:aNodes[nPos,5],oNewTree:aNodes[nPos,6],2,aCfgTree[7],aCfgTree[8],aCfgTree[9]) //2  e filho, 1 e mesmo
			Endif
		Endif	
	Else
		aRetGetAdv := GetAdvfVal(aCfgTree[1],aCfgTree[6],Eval(bBlockSeek),aCfgTree[4,1],"")
		For nI:=1 To Len(aRetGetAdv)
			cCODescri := AllTrim(aRetGetAdv[1])
			cCODescri += "-"+AllTrim(aRetGetAdv[2])
		Next
		//oTree:AddTreeItem(alltrim( (aCfgTree[1])->&(aCfgTree[6,2]) ),aSrcTree[1],Alltrim( (aCfgTree[1])->&(aCfgTree[2]) ),aCfgTree[7],aCfgTree[8],aCfgTree[9])	
		oTree:AddTreeItem(alltrim( cCODescri ),aSrcTree[1],Alltrim( (aCfgTree[1])->&(aCfgTree[2]) ),aCfgTree[7],aCfgTree[8],aCfgTree[9])	
	Endif

Endif

//como a recursividade esta dentro de um While, entao, preciso retornar 
//o ponteiro da arvore na posicao que estava antes de comecar o processo recursivo 
RestArea(aAreaTab)
Return()                                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ GetSearchReg  ºAutor  ³Fernando R. Muscalu º Data ³ 10/09/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta a chave de busca			                       	       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaPco                                                     	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³  cAlias       = Alias                                	       º±±
±±º          ³  aIndexSeek   = Array para busca do pai              	       º±±
±±º          ³  cFieldSeek   = Campo nó Pai                         	       º±±
±±º          ³  cValField    = Valor do Pai			   						   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Char - cRetKey                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GetSearchReg(cAlias,aIndexSeek,cFieldSeek,cValField,aSeekValues)

Local nI				:= 0
Local aFields			:= {}
Local cRetKey			:= ""
Local nPos				:= 0

Default cValField		:= ""

Default aSeekValues		:= {}                     

/*
	aIndexSeek - array com o indice de busca
	aIndexSeek[1] - nro do indice de busca
	aIndexSeek[n] - Campo que nao havera na busca, substituido por espacos em branco do tamanho do campo. Atente-se que, na verdade
	este e um recurso para os campos da direita que nao sao considerados dentro de uma busca.
		
*/  

SIX->(DBSEEK(cAlias + alltrim(str(aIndexSeek[1])) ))

aFields := strTokArr(SIX->CHAVE,"+")

If len(aSeekValues) > len(aFields)
	Aviso(	STR0001,;//TITULO DO AVISO //"Index Values Error"
			STR0002 +; //"A chave de busca que foi passada possui mais campos que o índice escolhido "
			CHR(13) +; 
			STR0003 + alltrim(str(len(aFields)))+; //"Qtde de campos do índice: "
			CHR(13) +; 
			STR0004 + alltrim(str(len(aSeekValues))),; //"Qtde de campos da busca: "
			{STR0005},2 ) //"Ok"
    Break
Endif

If Len(aSeekValues) > 0 
	For nI := 1 to len(aSeekValues)
		cRetKey +=	PadR(aSeekValues[nI],TamSX3(aFields[nI])[1])    	
	Next nI
Else
	For nI := 1 to len(aFields)
		
		If aScan( aIndexSeek, alltrim(aFields[nI]) )  == 0
			
			If "FILIAL" $ aFields[nI]
				cRetKey += PadR( xFilial(cAlias),TamSX3(aFields[nI])[1] )
			Else	
				If Alltrim(aFields[nI]) == alltrim(cFieldSeek)
					cRetKey += PadR(cValField,TamSX3(aFields[nI])[1])
				Else
					cRetKey += PadR((cAlias)->&(aFields[nI]),TamSX3(aFields[nI])[1])
				Endif	
			Endif
		Endif
	Next nI	
Endif

Return(cRetKey)
