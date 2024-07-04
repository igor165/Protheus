#INCLUDE "LOJA701.CH"
#INCLUDE "PROTHEUS.CH"                             
#INCLUDE "TCBROWSE.CH"
#INCLUDE "LOJA7034.CH"

/*----------------------------------------------------------	 
 Funcao para consulta multi Filial de estoque

@author  	Carlos MOta
@version 	P11 
@build		
@since 		24/09/2013
@return 	Nil														  	  
---------------------------------------------------------- */ 
Function LOJA7034(cFil,cProduto,cLocalProd) 
Local aProduto		:= {} // Array do Produto
Local aConsulta		:= {} // Array contendo todas informações que serão exibidas no grid
Local aParam			:= {} // Vetor de Retorno da selecao das filiais     
Local aLocal			:= {} // Vetor para armazenar os Locais de Estoque
Local nPosProd		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao do codigo do produto
Local nPosDtLocal  	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_LOCAL"})				// Posicao do local (armazem)
Local cFilBkp	   		:= cFilAnt							// Guarda a filial atual 
Local n1            	:= 0
Local nScan         	:= 0

Default cFil			:= Space(FWGETTAMFILIAL)				// Codigo da Filial
Default cProduto  	:= Space(TamSX3("B1_COD")[1])  	   	// Codigo do Produto 
Default cLocalProd	:= Space(TamSX3("B1_LOCPAD")[1])  	// Codigo do Local  

If !Empty(alltrim(cProduto))   
		aadd(aLocal,cFil+cLocalProd)
		aParam      := SelEmpFil(cProduto,cLocalProd)
		If Len(aParam) = 2 .AND. Valtype(aParam[1]) = 'A' .AND. Valtype(aParam[2]) = 'L'
              For n1=1 to Len(aParam[1])
              	  cFil       := aParam[1][n1][2]
              	  cLocalProd := aParam[1][n1][4]
              	  aProduto   := {}
              	  aProduto   := LJXEst(cFil, cProduto, cLocalProd)
                  If Valtype(aProduto[1][1]) != 'L'
                    	aProduto[1][1] := cFil
                     aadd(aConsulta,aProduto)
                  Endif
                  
              Next n1
		Endif
Endif   
If len(aConsulta) > 0
   Lj7EstMGrid(aConsulta)
Endif
Return .T.

/*----------------------------------------------------------	 
 Funcao para consulta multi Filial de estoque

@author  	Carlos MOta
@version 	P11 
@build		
@since 		24/09/2013
@return 	Nil														  	  
---------------------------------------------------------- */ 
Static Function Lj7EstMGrid(aConsulta)
Local oDlg      := Nil    
Local oFont     := Nil
Local aSize     := MsAdvSize( .T. )
Local oBtnImprime 
Local oBtnImp
Local aPosObj   := {}
Local aObjects  := {}
Local aInfo     := {}
Local apLegenda := {}		
Local apHeader  := {}
Local apHeader2 := {}
Local apBrowse  := {} 
Local apBrowse2 := {}   
Local oBrowse   := Nil
Local oBrowse2  := Nil	

Local oPanel1		:= Nil        
Local oGrp1		:= Nil
Local oGrp2		:= Nil    
Local n1       	:= 0    

Local cFil		 	:= Space(FWGETTAMFILIAL)				// Codigo da Filial
Local cProduto   	:= Space(TamSX3("B1_COD")[1])    	// Codigo do Produto 
Local cProdDes   	:= Space(TamSX3("B1_DESC")[1])     // Descricao do Produto
Local cLocalProd 	:= Space(TamSX3("B1_LOCPAD")[1])  	// Codigo do Local              
Local cGrupo     	:= Space(TamSX3("B1_GRUPO")[1])  	// Grupo do Produto
Local cGrupDes   	:= Space(TamSX3("BM_DESC")[1])  	// Grupo do Produto 
Local cTipo      	:= Space(TamSX3("B1_TIPO")[1])		// Tipo do Produto
Local cUN        	:= ''   
Local cImagem    	:= ''
Local oBmp     
Local aFt			:= {}
Local oFt        
Local nTtEstoque 	:= 0

Default aConsulta	:= {}

DEFINE FONT oFt NAME "Arial" SIZE 10,22 BOLD 

aAdd(aFt, oFt)

If Len(aConsulta) > 0 .AND. Len(aConsulta[1]) > 0 .AND. ValType(aConsulta[1][1][1]) != 'L'
       cFil     := cFilant
       cProduto := aConsulta[1][1][2]
       cProdDes := aConsulta[1][1][6]
       cGrupo   := aConsulta[1][1][5]
       cUn      := aConsulta[1][1][4]
       cGrupDes := Posicione("SBM",1,xFilial("SBM")+cGrupo,"SBM->BM_DESC")  
       cImagem  := SB1->B1_BITMAP   
       cTipo    := SB1->B1_TIPO
Else
	Return nil
Endif

DEFINE MSDIALOG oDlg FROM 20, 20 to aSize[6]-20,aSize[5]-20 TITLE STR0001 Of oMainWnd PIXEL	
		
		oFWLayer := FWLayer():new()
		oFWLayer :Init(oDlg)
	
		oFWLayer:addLine('Lin01',30,.F.) 
		oFWLayer:addLine('Lin02',40,.F.) 
		oFWLayer:addLine('Lin03',30,.F.)    
		
		If !Empty(cimagem)
			oFWLayer:addCollumn(STR0002,080,.T.,'Lin01')
			oFWLayer:addWindow (STR0002,"Win01",STR0002,100,.F.,.F., ,'Lin01') 
			oWin01  := oFWLayer:GetWinPanel(STR0002,"Win01",'Lin01') 

			oFWLayer:addCollumn(STR0003,020,.T.,'Lin01')
			oFWLayer:addWindow (STR0003,"Win011",'Foto',100,.F.,.F., ,'Lin01') 
			oWin011  := oFWLayer:GetWinPanel(STR0003,"Win011",'Lin01') 
	  	    
			oBmp := TBmpRep():New(1,01,200,200,Alltrim(SB1->B1_BITMAP),.T.,oWin011,,,.F.,.F.,,,,)			
			Showbitmap(oBmp,SB1->B1_BITMAP,"")
			
		Else 
			oFWLayer:addCollumn(STR0002,100,.T.,'Lin01') // Produto  
			oFWLayer:addWindow (STR0002,"Win01",STR0002,100,.F.,.F., ,'Lin01') // Produto 
			oWin01  := oFWLayer:GetWinPanel(STR0002,"Win01",'Lin01') // Produto 
        Endif
        
       @ 002,002 Say STR0004 Pixel Of oWin01 // Código
		@ 010,002 MSGET cProduto SIZE 063,08 OF oWin01 PIXEL When .F.
       @ 002,070 Say STR0005 Pixel Of oWin01 // Descrição
		@ 010,070 MSGET cProdDes SIZE 150,08 OF oWin01 PIXEL When .F. 
		@ 002,225 Say STR0006 Pixel Of oWin01 // Unidade
		@ 010,225 MSGET cUn SIZE 019,08 OF oWin01 PIXEL When .F. 
			@ 002,250 Say STR0007 Pixel Of oWin01 // "Tipo"
		@ 010,250 MSGET cTipo SIZE 019,08 OF oWin01 PIXEL When .F. 
		
		@ 002,280 Say STR0008 Pixel of oWin01 //"Grupo"
		@ 010,280 MSGET cGrupo SIZE 019,08 OF oWin01 PIXEL When .F. 
       @ 002,310 Say STR0005 Pixel Of oWin01 // "Descrição"
		@ 010,310 MSGET cGrupDes SIZE 130,08 OF oWin01 PIXEL When .F.
	    
		oFWLayer:addCollumn(STR0009,100,.T.,'Lin02') // 'Estoque'  
       oFWLayer:addWindow (STR0009,"Win02",STR0010	,100,.F.,.F., ,'Lin02') // "Estoque Multi Filiais"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              

	  	oWin02  := oFWLayer:GetWinPanel(STR0009,"Win02",'Lin02') // Estoque 
	  	
	  	FMakeGrd(@apHeader)    // Gera dados para o Browse                           
		oBrowse := TcBrowse():New(20,10,230,60,,apHeader,;
	    						   {20,50,20,50,50,45,45,45,45,45,45,45,45,45},oWin02,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
		oBrowse :Align	      := CONTROL_ALIGN_ALLCLIENT
		FMakeCol(@apBrowse,aConsulta,@oBrowse)
            	
     	oFWLayer:addCollumn(STR0011,060,.T.,'Lin03')  // Totais
       oFWLayer:addWindow (STR0011,"Win03",STR0011	,100,.F.,.F., ,'Lin03') //// Totais 
	  	oWin03  := oFWLayer:GetWinPanel(STR0011,"Win03",'Lin03') //// Totais 
        
       FMakeGrd2(@apHeader2)    // Gera dados para o Browse
       oBrowse2 := TcBrowse():New(01,01,400,60,,apHeader2,;
	    						   {20,180,60,01},oWin03,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
		oBrowse2 :Align	      := CONTROL_ALIGN_ALLCLIENT
   		
		FMakeCol2(@apBrowse2,aConsulta,@oBrowse2,@nTtEstoque)
		
		oFWLayer:addCollumn('TT',040,.T.,'Lin03')
		oFWLayer:addWindow ('TT',"Win031",STR0012,100,.F.,.F., ,'Lin03') // Total selecionado 
	  	oWin031  := oFWLayer:GetWinPanel('TT',"Win031",'Lin03') 
        

       @ 10,030 TO 50,210 LABEL STR0013 OF oWin031  PIXEL // Total Geral em Estoque
		@ 30,075 SAY nTtEstoque Picture "@E 999,999,999,999,999,999.99"  SIZE 150,35 OF oWin031 PIXEL FONT aFt[1]

       DEFINE SBUTTON FROM 045, 215 TYPE 1 ACTION (oDlg:End()) ENABLE PIXEL OF oWin031
       	
Activate MsDialog oDlg Centered   
Return Nil

/*----------------------------------------------------------	 
 Funcao para consulta multi Filial de estoque

@author  	Carlos MOta
@version 	P11 
@build		
@since 		24/09/2013
@return 	Nil														  	  
---------------------------------------------------------- */ 
Static Function FMakeGrd(apHeader)

Default apHeader := {}

	apHeader :=	{STR0014;  //Filial
   					,STR0005; // Descrição
   					,STR0015;  //Armazem   			
              	,STR0005;  //Descrição
   					,STR0016; // Estoque Atual
   					,STR0017; //Preço de Venda 1
   					,STR0018; //Preço de Venda 2
   					,STR0019; //Preço de Venda 3
   					,STR0020; //Preço de Venda 4
   					,STR0021; //Preço de Venda 5
   					,STR0022; //Preço de Venda 6
   					,STR0023; //Preço de Venda 7
   					,STR0024; //Preço de Venda 8
   					,STR0025} //Preço de Venda 9

Return Nil    




/*----------------------------------------------------------	 
 Funcao para consulta multi Filial de estoque

@author  	Carlos MOta
@version 	P11 
@build		
@since 		24/09/2013
@return 	Nil														  	  
---------------------------------------------------------- */ 
Static Function FMakeGrd2(apHeader2)

Default apHeader2 := {}

	apHeader2 :={STR0014	 ;   
   				,STR0005 ;    
   				,STR0016; 
   				,''}              
Return Nil

/*----------------------------------------------------------	 
 Funcao para consulta multi Filial de estoque

@author  	Carlos MOta
@version 	P11 
@build		
@since 		24/09/2013
@return 	Nil														  	  
---------------------------------------------------------- */ 

Static Function FMakeCol(apBrowse,aConsulta,oBrowse)
Local n1      := 0   
Local n2      := 0
Local lR7		:= GetRpoRelease ("R7")
Local cDesFil := ''
Local cDesArm := ''       
Local nScan   := 0

Default apBrowse := {}
Default aConsulta := {}
Default oBrowse := Nil

	For n1=1 to len(aConsulta)		
	   cDesFil := Posicione("SM0",1,cEmpant+aConsulta[n1][1][1],"SM0->M0_FILIAL") 
	   If lR7
	      cDesArm:=  Posicione("NNR",1,xfilial("NNR")+aConsulta[n1][1][3],"NNR->NNR_DESCRI") 
	   Endif
			Aadd(apBrowse,{aConsulta[n1][1][1],; //01
			              cDesFil,;//02
			              aConsulta[n1][1][3],;//03
			              cDesArm,;//04
			              transform(aConsulta[n1][1][8] ,"@E  99,999,999,999,999,999.99"),;//05
							transform(aConsulta[n1][1][9] ,"@E  9,999,999,999,999,999.99"),;//06
							transform(aConsulta[n1][1][10],"@E  9,999,999,999,999,999.99"),;//07
							transform(aConsulta[n1][1][11],"@E  9,999,999,999,999,999.99"),;//08
							transform(aConsulta[n1][1][12],"@E  9,999,999,999,999,999.99"),;//09
							transform(aConsulta[n1][1][13],"@E  9,999,999,999,999,999.99"),;//10
							transform(aConsulta[n1][1][14],"@E  9,999,999,999,999,999.99"),;//11
							transform(aConsulta[n1][1][15],"@E  9,999,999,999,999,999.99"),;//12
							transform(aConsulta[n1][1][16],"@E  9,999,999,999,999,999.99"),;//13
							transform(aConsulta[n1][1][17],"@E  9,999,999,999,999,999.99")})//14

	Next n1 
	
	oBrowse:SetArray(apBrowse)
	
	oBrowse:bLine := {||{apBrowse[oBrowse:nAt,01]; 
	   						,apBrowse[oBrowse:nAt,02]; 
	                    	,apBrowse[oBrowse:nAt,03];
	                    	,apBrowse[oBrowse:nAt,04];
	                    	,apBrowse[oBrowse:nAt,05];
	                    	,apBrowse[oBrowse:nAt,06]; 
	                    	,apBrowse[oBrowse:nAt,07];
	                    	,apBrowse[oBrowse:nAt,08];
	                    	,apBrowse[oBrowse:nAt,09];
	                    	,apBrowse[oBrowse:nAt,10];
	                    	,apBrowse[oBrowse:nAt,11];
	                    	,apBrowse[oBrowse:nAt,12];
	                    	,apBrowse[oBrowse:nAt,13];
	                    	,apBrowse[oBrowse:nAt,14]}}
Return Nil


/*----------------------------------------------------------	 
 Funcao para consulta multi Filial de estoque

@author  	Carlos MOta
@version 	P11 
@build		
@since 		24/09/2013
@return 	Nil														  	  
---------------------------------------------------------- */ 
Static Function FMakeCol2(apBrowse2,aConsulta,oBrowse2,nTtEstoque)
Local n1      := 0   
Local n2      := 0
Local lR7		:= GetRpoRelease ("R7")
Local cDesFil := ''
Local cDesArm := ''       
Local nScan   := 0

Default apBrowse2	:= {}
Default aConsulta	:= {}
Default oBrowse2	:= Nil
Default nTtEstoque	:= 0


nTtEstoque := 0
	For n1=1 to len(aConsulta)		
		cDesFil := Posicione("SM0",1,cEmpant+aConsulta[n1][1][1],"SM0->M0_FILIAL") 
		nScan := aScan(apBrowse2,{|x|x[1] == aConsulta[n1][1][1]})
	       If nScan = 0
	           aadd(apBrowse2,{aConsulta[n1][1][1],cDesFil,aConsulta[n1][1][8],''})
	        Else 
	           apBrowse2[nScan][3]+= aConsulta[n1][1][8]
	        Endif
	        nTtEstoque += aConsulta[n1][1][8]
	Next n1 
	
	For n1=1 to Len(apBrowse2)
	    apBrowse2[n1][3] := transform(apBrowse2[n1][3] ,"@E  99,999,999,999,999,999.99")
	Next n1
   
	oBrowse2:SetArray(apBrowse2)
	
	oBrowse2:bLine := {||{apBrowse2[oBrowse2:nAt,01]; 
	                     ,apBrowse2[oBrowse2:nAt,02]; 
	                     ,apBrowse2[oBrowse2:nAt,03];
	                     ,apBrowse2[oBrowse2:nAt,04]}}
Return Nil

/*----------------------------------------------------------	 
 Funcao Generica para escolha de Empresa, montado pelo SM0 
 Retorna vetor contendo as selecoes feitas.                 
 Se nao For marcada nenhuma o vetor volta vazio.  

@author  	Carlos MOta
@version 	P11 
@build		
@since 		24/09/2013
@return 	Nil														  	  
---------------------------------------------------------- */ 
Static Function SelEmpFil(cProduto,cLocalProd)
Local   aSalvAmb := GetArea()
Local   aSalvSM0 := {}
Local   aRet     := {}
Local   aVetor   := {}
Local   aVetor2  := {} 
Local   oDlg     := NIL
Local   oChkMar  := NIL
Local   oChkLoc  := NIL
Local   oLbx     := NIL
Local   oMascEmp := NIL
Local   oMascFil := NIL
Local   oButMarc := NIL
Local   oButDMar := NIL
Local   oButInv  := NIL
Local   oSay     := NIL
Local   oOk      := LoadBitmap( GetResources(), "LBOK" )
Local   oNo      := LoadBitmap( GetResources(), "LBNO" )
Local   lChk     := .F.
Local   lOk      := .F.
Local   lTeveMarc:= .F.
Local   cVar     := ""
Local   cNomEmp  := ""
Local   cMascEmp := "??"
Local   cMascFil := "??" 
Local   lAllLocal:= .F.
Local   aMarcadas:= {}
Local   n1       := 0  

Default cProduto    := SB1->B1_PRODUTO
Default cLocalProd  := SB1->B1_LOCPAD

dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()
                                                       
While !SM0->( EOF() )

	If SM0->M0_CODIGO = cEmpAnt 
		aAdd(  aVetor2, { (AllTrim(SM0->M0_CODIGO + SM0->M0_CODFIL) = AllTrim(cEmpAnt + cFilAnt)),;
		                   SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )                  


	For n1=1 to Len(aVetor2)
	    DbSelectArea("SB2")
	    cFil := aVetor2[n1][3]
	    DbSeek(cFil+cProduto,.T.)
	    While !Eof() .AND. SB2->B2_COD = cProduto
	    	cLocalPrd := SB2->B2_LOCAL
	    	aAdd(  aVetor, {  (AllTrim(SM0->M0_CODIGO + SM0->M0_CODFIL) =  aVetor2[n1][2]+aVetor2[n1][3]) .AND. (cLocalProd = cLocalPrd)  ,;
	    	                   aVetor2[n1][2],aVetor2[n1][3],aVetor2[n1][4],aVetor2[n1][5] ,cLocalPrd} )
	    	SB2->(DbSkip())
	    End 
	Next n1

If Len(aVetor) = 0 
	For n1=1 to Len(aVetor2)
	    If aVetor2[n1][2] == cEmpant 
	    	aAdd(  aVetor, {  .T.  ,;
	    	                   aVetor2[n1][2],aVetor2[n1][3],aVetor2[n1][4],aVetor2[n1][5] ,SB1->B1_LOCPAD} )
	    End 
	Next n1
Endif

Define MSDialog  oDlg Title "" From 0, 0 To 270, 396 Pixel

oDlg:cToolTip := STR0026 // Tela para Múltiplas Seleções de Empresas/Filiais

oDlg:cTitle   := STR0027 // Selecione a(s) Filial (s) para Consulta

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", STR0014, STR0005, STR0015 Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 3], ;
aVetor[oLbx:nAt, 5],;
aVetor[oLbx:nAt, 6]}}

oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk      Prompt STR0028   Message  Size 40, 007 Pixel Of oDlg; //Marca/Desmarca Filiais
on Click MarcaTodos( lChk, @aVetor, oLbx )                                         

Define SButton From 120, 128 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop STR0029  Enable Of oDlg //Confirma a Seleção
Define SButton From 120, 161 Type 2 Action (  aRet := {},aVetor:= {} ,RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop STR0030 Enable Of oDlg //Abandona a Seleção
Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
Return ({aRet,lAllLocal})

/*----------------------------------------------------------	 
 Funcao Auxiliar para marcar/desmarcar todos os itens 

@author  	Carlos MOta
@version 	P11 
@build		
@since 		29/09/2013
@return 	Nil														  	  
---------------------------------------------------------- */ 
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

Default lMarca := .T.
Default aVetor := {}
Default oLbx := Nil
 
For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL

/*----------------------------------------------------------	 
 Funcao para verificar se estao todos marcardos ou nao 

@author  	Carlos MOta
@version 	P11 
@build		
@since 		24/09/2013
@return 	Nil														  	  
---------------------------------------------------------- */ 
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

Default aVetor := {}
Default lChk	:= .T.
Default oChkMar := Nil

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL                        

/*----------------------------------------------------------	 
 Funcao que monta o retorno com as selecoes 

@author  	Carlos MOta
@version 	P11 
@build		
@since 		24/09/2013
@return 	Nil														  	  
---------------------------------------------------------- */ 
Static Function RetSelecao( aRet, aVetor )
Local  nI     := 0    

Default aRet := {}
Default aVetor := {}

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3],aVetor[nI][6] } )
	EndIf
Next nI

Return NIL  

/*----------------------------------------------------------	 
 Funcao para consulta multi Filial de estoque

@author  	Carlos MOta
@version 	P11 
@build		
@since 		24/09/2013
@return 	Nil														  	  
---------------------------------------------------------- */ 
Static Function LJXEst(cFil, cProduto, cLocalProd)

Local aProdEst		:= {}		 	// Array de retorno da funcao com informacoes do estoque do produto
Local lContinua 	:= .T. 			// Retorno
Local  nSdSb2       := 0
                                            
DEFAULT cFil	 	:= ""        	// Codigo da Filial
DEFAULT cProduto	:= ""    	 	// Codigo do Produto
DEFAULT cLocalProd	:= ""    	 	// Codigo do Local

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz posicionamento do estoque do produto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cFil := SubStr(cFil, 1, FWGETTAMFILIAL)

DbSelectArea("SB2")
DbSetOrder(1)//B2_FILIAL+B2_COD+B2_LOCAL  
If DbSeek(cFil + cProduto + cLocalProd,.T.)
   nSdSb2 := SaldoSb2()
Else
   nSdSb2 := 0
Endif

DbSelectArea("SB0")
DbSetOrder(1)//B0_FILIAL+B0_COD
DbSeek(cFil + cProduto,.T.)

DbSelectArea("SB9")
DbSetOrder(1)//B9_FILIAL+B9_COD+B9_LOCAL
DbSeek(cFil + cProduto + cLocalProd,.T.)

If lContinua
	Aadd(aProdEst, {SB1->B1_FILIAL	,;	//01 - Filial
					SB1->B1_COD		,;	//02 - Codigo do produto
					cLocalProd  	,;	//03 - Local do produto				 
					SB1->B1_UM		,;	//04 - Unidade de medida do Produto				 
					SB1->B1_GRUPO	,;	//05 - Grupo do produto
					SB1->B1_DESC	,;	//06 - Descricao do produto 
					SB9->B9_QINI	,;	//07 - Quantidade inicial do produto				
					nSdSb2   		,;	//08 - Saldo atual do produto 
					SB0->B0_PRV1	,;	//09 - Preco 1 
					SB0->B0_PRV2	,;	//10 - Preco 2 
					SB0->B0_PRV3	,;	//11 - Preco 3 
					SB0->B0_PRV4	,;	//12 - Preco 4 
					SB0->B0_PRV5	,;	//13 - Preco 5 
					SB0->B0_PRV6	,;	//14 - Preco 6 
					SB0->B0_PRV7	,;	//15 - Preco 7 
					SB0->B0_PRV8	,;	//16 - Preco 8 
					SB0->B0_PRV9	})	//17 - Preco 9  
Else
	Aadd(aProdEst,{.F.})						
Endif

Return (aProdEst) 
                       