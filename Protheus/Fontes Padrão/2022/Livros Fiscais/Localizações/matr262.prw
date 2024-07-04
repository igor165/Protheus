#INCLUDE "MATR262.CH"
#Include "Protheus.ch"

Static __lDefTop	:= IfDefTopCTB()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MATR262 ³ Autor ³ Bruno Schmidt /Julio C.Guerato ³ Data ³ 01.08.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Guia de Abate de Estoque 						                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ MATR262                                                    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³06/07/15³PCREQ-4256³Se elimina la funcion AjustSx1() que  ³±±
±±³            ³        ³          ³hace modificacion a SX1 por motivo de ³±±
±±³            ³        ³          ³adecuacion a fuentes a nuevas estruc- ³±±
±±³            ³        ³          ³turas SX para Version 12.             ³±±
±±³M.Camargo   ³09.11.15³PCREQ-4262³Merge sistemico v12.1.8		           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATR262()
Local lOk		 := .T.
Local lImpR4	 := FindFunction( "TRepInUse" ) .And. TRepInUse()
Local cPerg		 := 'MATR262'

Private titulo	 := ""
Private nomeprog := STR0005 //MATR262  
Private cAbatEst := ""      //Numero do Documento de Abate 

//Objeto Relatorio
Private oPrint    

//Verifica Ambiente 
If !__lDefTop
	MsgAlert(STR0001) 
	lOk := .F.
Endif  
           

//Inicia Processo de Impressao  
If lOk
	If Pergunte(cPerg,.T.)
		oPrint:= tNewMsprinter():New(STR0003)
		oPrint:SetPortrait()  
		oPrint:SetLandscape()  //Orientacao da Pagina - Paissagem  
		ImpRel()   
		oPrint:Preview()
	Endif
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ImpRel    º Autor ³Julio C.Guerato     º Data ³ 05/10/2011   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ ImpRel(nReg)								 	               º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³ nReg = Quantidade de Registros p/compor LayOut              º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±º Desc.    ³ Impressao do relatorio                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Static Function ImpRel() 
Local cAlias   	   := ""       // Alias com dados para impressao 
Local cCusto   	   := IF(MV_PAR09==1,"D3_CUSTO1","D3_CUSFF1")
Local cPictQt  	   := PesqPict("SD3","D3_QUANT")
Local cPictPco 	   := PesqPict("SD3","D3_CUSTO1")  
Local nValItem     := 0     // Valor Unitário do produto
Local nTotGeral    := 0     // Total Geral         
Local nPos         := 0     // Posicao da Guia do array  
Local nX           := 0     // Variavel de trabalho
Local aNrGuia      := {}    // Guias de abates que serao impressas   
LOCAL lFim         := .F. 

//Controle de Linhas por pagina
Local nReg         :=0      // Nro Total de Registros a serem impressos 
Local nRegPrint    :=0      // Nro Registros Impressos na Página
Local nRegPrintTot :=0      // Nro Registros Total já impressos  

//Controle de Linhas / Página / Guia
Private lin  	   := 50    // Distancia da linha vertical da margem esquerda
Private lin1   	   := 330   // Distancia da linha vertical da margem superior
Private lin2   	   := 1950  // Tamanho vertical da linha - Pagina sem Total 
Private lin3   	   := 2240  // Tamanho vertical da linha - Pagina com Total
Private nRegPag	   := 35    // Nro de Registros por página sem Total
Private nRegPagTot := 29    // Nro de Registros por página com Total 
Private nRegPagImp := 0     // Nro de Registros a serem impressos por página 
Private nPag       := 1     // Nro da Página   
Private cDtEmisGuia:= ""    // Data de Emissão da Guia

//Controle de Fontes
Private oFont08    := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)  //Fonte08
Private oFont09    := TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)  //Fonte09
Private oFont10    := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)  //Fonte10
Private oFont11    := TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)  //Fonte11
Private oFont12    := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)  //Fonte12
Private oFont14    := TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)  //Fonte14
Private oFont10n   := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)  //Fonte10 Negrito	
Private oFont12n   := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)  //Fonte12 Negrito	 

//Obter Dados
cAlias:=ObtemDados() 

//Obtem Nro de Registros da Tabela de acordo com a guia que sera impressa         
(cAlias)->(dbGoTop()) 
Do While !((cAlias)->(Eof())) 
	nPos:=Ascan(aNrGuia,{|x| x[1]== (cAlias)->D3_NRABATE})
	If nPos==0
		AADD(aNrGuia,{(cAlias)->D3_NRABATE,1,(cAlias)->D3_EMISSAO})
	Else
		aNrGuia[nPos,2]:=aNrGuia[nPos,2]+1
	EndIf
	nReg+=1
	(cAlias)->(dbSkip())
Enddo 

//Imprime o LayOut do relatorio de acordo com as Guias de Abates  
For nX=1 to Len(aNrGuia)  
	cAbatEst:=aNrGuia[nX][1]
	nReg:=aNrGuia[nX][2]  
	cDtEmisGuia:=aNrGuia[nX][3]
	If nReg<=nRegPag 
    	nRegPagImp:=(nReg/nRegPag)*100
		If nRegPagImp>=88
			nRegPagImp:=nRegPagTot
			ImpLayout(nRegPag+1)
		Else
			nRegPagImp:=nRegPagTot
			ImpLayout(nRegPagTot)   
		EndIF
	Else   
		ImpLayout(nRegPag+1)
		nRegPagImp:=nRegPag   
	EndIf

	//Processa impressao do relatorio //  
	DbSelectArea(cAlias)
	(cAlias)->(dbGoTop()) 
	nLin	 := 445      
	nRegPrint:= 0   
	nValItem := 0  
	nTotGeral:= 0 
	nPag	 := 1
	
	While !((cAlias)->(Eof()))
		If (cAlias)->D3_NRABATE == cAbatEst
			If nRegPrint>=nRegPagImp					  
				oPrint:EndPage() 
				nPag+=1
			
				//Controle de saldo de página
				If (nReg-nRegPrintTot)<=nRegPag 
			    	nRegPagImp:=(nRegPrint/nRegPag)*100
					If nRegPagImp>=88 .And. nRegPagImp<100
						nRegPagImp:=nRegPagTot
						ImpLayout(nRegPag+1)
					Else
						nRegPagImp:=nRegPagTot
						ImpLayout(nRegPagTot)   
					EndIF
				Else   
					ImpLayout(nRegPag+1)
					nRegPagImp:=nRegPag   
				EndIf  
			
				nLin:=445 
				nRegPrint:=0
			EndIf    
		
			nValItem:=(cAlias)->&cCusto/(cAlias)->D3_QUANT
			nTotGeral:=nTotGeral+(cAlias)->&cCusto
			
			oPrint:Say(nLin,0080,(cAlias)->D3_COD  ,oFont08)
			oPrint:Say(nLin,0950,(cAlias)->B1_DESC ,oFont08)
			oPrint:Say(nLin,1900,Transform((cAlias)->D3_QUANT,cPictQt) ,oFont08)
			oPrint:Say(nLin,2345,(cAlias)->D3_UM   ,oFont08)
			oPrint:Say(nLin,2550,Transform(nValItem,cPictPco) ,oFont08)  
			oPrint:Say(nLin,2950,Transform((cAlias)->&cCusto,cPictPco) ,oFont08)  
		
			nRegPrintTot+=1
			nRegPrint+=1
	    	nLin+=50
	  	EndIf
	    (cAlias)->(dbSkip())
	EndDo    

	//Total Geral   
	oPrint:Say(1975,2900,Transform(nTotGeral,cPictPco) ,oFont10n) 
	oPrint:EndPage()  
Next nX

//Fecha Area
DbCloseArea()

Return()  

/*                                                        
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ObtemDados ³ Autor ³ Julio Cesar Guerato ³ Data ³ 06.10.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³ Query para busca de dados a sem impressos                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR262                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/       
Static Function ObtemDados()
Local aStru     := SD3->(dbStruct()) 
Local cQuery	:= ""   
Local cAlias    := ""  
Local i         := 0
                     
cAlias:= GetNextAlias()

cQuery:=" SELECT D3_COD,D3_QUANT,D3_UM,D3_CUSTO1,D3_CUSFF1,B1_DESC, D3_NRABATE, D3_EMISSAO "
cQuery+="   FROM "+RetSqlName("SD3")+" SD3, "+RetSqlName("SB1")+" SB1"
cQuery+="  WHERE D3_FILIAL  = '"+xFilial("SD3")+"'"  
cQuery+="    AND B1_FILIAL  = '"+xFilial("SB1")+"'"
cQuery+="    AND D3_COD     = B1_COD " 
cQuery+="    AND D3_COD     BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
cQuery+="    AND D3_LOCAL   BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'"
cQuery+="    AND D3_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"
cQuery+="    AND D3_NRABATE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
cQuery+="    AND D3_ESTORNO <> 'S'"
cQuery+="    AND D3_STATUS  IN ('OB','EX')"  
cQuery+="    AND SD3.D_E_L_E_T_ =' '"    
cQuery+="    AND SB1.D_E_L_E_T_ =' '"    
cQuery+="  ORDER BY D3_NRABATE, D3_COD "

cQuery:= ChangeQuery(cQuery)  
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAlias, .T., .T. )    

For i:= 1 To Len(aStru)
	If aStru[i,2]<>"C"
		TcSetField(cAlias,aStru[i,1],aStru[i,2],aStru[i,3],aStru[i,4])
	EndIf
Next nCnt 

Return (cAlias)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ImpLayout º Autor ³Julio Cesar Guerato º Data ³  05/10/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±± 
±±ºSintaxe   ³ ImpRel(nRegPar)								 	           º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³ nRegPar = Quantidade de Registros p/compor LayOut           º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±º Desc.    ³ Impressao do Layout	                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpLayout(nRegPar)

Local cFileLogo	 := GetSrvProfString('Startpath','')+'\LGRL'+SM0->M0_CODIGO + '.BMP'

//Inicializa pagina
oPrint:StartPage()

//Desenha Box / Linhas do Relatório      
oPrint:Box(50,50,320,1990)                        // Dados da Empresa (Logo/Nome/CNPJ)

// Nome do Relatório - Guia de Abate
oPrint:Box(50,2000,130,3180)                      

// Data da Baixa - Numero/Data Abate
oPrint:Box(140,2000,320,3180)                     
 
// Código do bem/Descrição/Quantidade/Valor/SubTotal
oPrint:Box(430,50,330,3180)                       

//Primeira linha vertical Detalhe  
oPrint:Line(iif(nRegPar<=nRegPag,lin2,lin3),lin,lin1,lin)

//Segunda linha vertical Detalhe
oPrint:Line(iif(nRegPar<=nRegPag,lin2,lin3),lin+870,lin1,lin+870)            

//Terceira linha vertical Detalhe
oPrint:Line(iif(nRegPar<=nRegPag,lin2,lin3),lin+1800,lin1,lin+1800)          

//Quarta linha vertical Detalhe
oPrint:Line(iif(nRegPar<=nRegPag,lin2,lin3),lin+2200,lin1,lin+2200)       

//Quinta linha vertical Detalhe   
oPrint:Line(iif(nRegPar<=nRegPag,lin2+90,lin3),lin+2400,lin1,lin+2400)     

//Sexta linha vertical Detalhe
oPrint:Line(iif(nRegPar<=nRegPag,lin2+90,lin3),lin+2750,lin1,lin+2750)       

//Setima linha vertical Detalhe
oPrint:Line(iif(nRegPar<=nRegPag,lin2+90,lin3),lin+3130,lin1,lin+3130)       

// Linha Horizontal Fechando Colunas de Detalhe
If nRegPar<=nRegPag
	oPrint:Line(1950,51,1950,3180)  
Else
	oPrint:Line(2242,51,2242,3180) 	               
EndIf

If nRegPar<=nRegPag
	// Linha Total
	oBrush1 := TBrush():New( , RGB(228,224,224) )   
	oPrint:FillRect({1953,2454,2040,3178}, oBrush1 )
	oBrush1:End()

	// Linha Horizontal Fechando Colunas Total
	oPrint:Line(2040,2454,2040,3180)   	               

	// Linha Horizontal Assinatura Responsável
	oPrint:Line(2242,2440,2242,3180)
EndIf

//Insere Dados da Empresa
SX3->( DbSetOrder(2) )
SX3->( MsSeek( "A1_CGC" , .t.))

If SM0->(Eof())
  	SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
Endif 

//Impressao do LOGO //
oPrint:SayBitmap(60,60,cFileLogo,350,250)                        // Logo da Empresa
oPrint:Say(130,  540,  SM0->M0_NOMECOM,oFont10n)                 // Nome da Empresa
oPrint:Say(230,  540,  STR0015+Alltrim( SM0->M0_CGC ),oFont10n)  // CNPJ
oPrint:Say(63,   2300, STR0003, oFont12n)  						  //Guia de Abate

oPrint:Say(165,  2300, STR0005,  oFont10)    		  //Numero do Documento
oPrint:Say(165,  2700, cAbatEst, oFont10)    		  //Numero do Documento

oPrint:Say(215,  2300, STR0014,           oFont10)   //Data do Documento
oPrint:Say(215,  2700, DTOC(cDtEmisGuia), oFont10)   //Data do Documento

oPrint:Say(265,  2300, STR0016,   oFont10)    //Pagina
oPrint:Say(265,  2700, Str(nPag), oFont10)    //Pagina

oPrint:Say(365,  0080, STR0006 ,oFont10n)   //Codigo Produto
oPrint:Say(365,  1200, STR0007 ,oFont10n)   //Descrição
oPrint:Say(365,  1900, STR0008 ,oFont10n)   //Quantidade
oPrint:Say(365,  2295, STR0009 ,oFont10n)   //Unidad
oPrint:Say(365,  2500, STR0010 ,oFont10n)   //Valor
oPrint:Say(365,  2900, STR0011 ,oFont10n)   //Sub-Total  

If nRegPar<=nRegPag
	oPrint:Say(1975, 2550, STR0012 ,oFont10n)   //TOTAL  
	oPrint:Say(2244, 2760, STR0013 ,oFont10)    //Responsavel
EndIf

Return 

