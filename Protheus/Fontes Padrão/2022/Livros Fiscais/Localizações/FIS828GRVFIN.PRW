#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
//#INCLUDE 'FISA828.CH'
#INCLUDE "TBICONN.CH"

FUNCTION FIS828GRVFIN(cCoe)

Local aCabsComp     :=	{}
Local aCabsVend     :=	{}
Local aItensOpr	    :=	{}	
Local aItensDed	    :=	{}
Local aAreaNJC		:= NJC->(GetArea())	
Local aAreaNL3		:= NL3->(GetArea())	
Local aAreaNL4		:= NL4->(GetArea())	
Local aAreaSF2		:= SF2->(GetArea())	
Local aAreaSF1		:= SF2->(GetArea())	
Local aAreaSD1		:= SD1->(GetArea())	
Local aAreaSD2		:= SD2->(GetArea())	
Local aAreaSFE      := SFE->(GetArea())
Local cNumLiq       := ""
Local cFornec       := ""
Local cLojForn      := ""
Local cCondPago     := ""
Local cProduto      := ""
Local nTotOpera     := 0
Local nTotDeduc     := 0
Local nItemOp       := 0
Local nItemDed      := 0
Local cTesCab       := ""
Local lDesc         := .T.
Local cTabItem      := ""
Local cTabela       := ""
Local lRecPag       := IIF(NJC->NJC_ESPLIQ == "1",.T.,.F.) // True = Pagar/Compra , Falso = Receber/Venda
Local lError        := .F.
Local aSB1          := {}  
Local cTpDocCom     := ""
Local cTpDocVen     := ""
Local cTipoDocv     := ""
Local cTipoDocC     := ""
Local cEspecieC     := ""
Local cEspecieV     := ""
Local cNatureza		:= ""
Local cCert         := ""
Local cImpuesto     := ""
Local cRem          := ""
Local cRSer         := ""

//Pontos de entrada 
Local lF828G1  := ExistBlock("F828G1")
Local lF828G2  := ExistBlock("F828G2")
Local lF828G3  := ExistBlock("F828G3")
Local lF828G4  := ExistBlock("F828G4")
Local lF828G5  := ExistBlock("F828G5")
Local lF828G6  := ExistBlock("F828G6")
Local lF828G7  := ExistBlock("F828G7")
Local lF828G8  := ExistBlock("F828G8")
Local lF828G9  := ExistBlock("F828G9")
Local lF828G10 := ExistBlock("F828G10")

Local aF828G1  := {}
Local aF828G2  := {}
Local aF828G3  := {}
Local aF828G4  := {}
Local aF828G5  := {}
Local aF828G6  := {}
Local aF828G7  := {}
Local aF828G8  := {}
Local aF828G9  := {}
Local aF828G10 := {}
//---

Local lCondSF1	:=.F.
Local lCondSF2	:=.F.
Local lProp		:=.F.
Local cPVAux	:= ""
Local cSerNf	:= ""
Local cSerND	:= ""
Local cSerNC	:= ""
Local nVlImpRet	:= 0
Local lAutomato := IsBlind()
Local cTesCanje := ""
PRIVATE lMsErroAuto := .F.
Private aCerts			:= {}
Private cLocxNFPV	:= ""
Private lGerDupl	:= .T.

Default cCoe := cValToChar(Randomize( 100000000, 999999999 ))


        //Tabela NJC já vem posicionada portanto carregos as informaçoes necessarias.
cNumLiq     := cCoe  // NJC_CODLIQ
cFornec     := iif(lRecPag,NJC->NJC_VENDED,NJC->NJC_CODPRO)  // TESTE COM CLIENTE //INFORMAÇÃO
cLojForn    := iif(lRecPag,NJC->NJC_LOJAVE,NJC->NJC_TIENDA)  //INFORMAÇÃO
cCondPago   := NJC->NJC_CODPGO
cProduto    := NJC->NJC_PROD
cTesCab     := NJC->NJC_TES 
nQtdCab     := NJC->NJC_PESSCE
nVlrCab     := NJC->NJC_PRECO
nTotCab     := nQtdCab * nVlrCab
aSB1        := GetAdvFVal("SB1", { "B1_UM", "B1_LOCPAD"}, xFilial("SB1")+cProduto, 1, { "", ""})
nCredDeb    := NJC->NJC_CREDEB
cNatureza 	:= IIf(!Empty(NJC->NJC_NATUR),NJC->NJC_NATUR, "01")

IF lRecPag  // True = Pagar/Compra , Falso = Receber/Venda
    cTabItem      := "D1" 
    cTabela       := "SF1"   
Else 
    cTabItem      := "D2"
    cTabela       := "SF2" 
EndIF

IF cTabela == "SF1" // Liquidaçaõ de Compras

    IF NJC->NJC_TPLIQ == "1"  // Liquidação primaria

        IF  NJC->NJC_TIPO == "2" // Liquidação Final

                cTpDocCom   :=  "9"  // NDP
                cTipoDocC   :=  "C"
                cEspecieC   :=  "NDP"
                cTpDocVen   :=  "2" // NCP
                cTipoDocV   :=  "C"
                cEspecieV   :=  "NDC"

        Else // Liquidação Total e Parcial

            cTpDocCom :=  "10"  // NORMAL
            cTipoDocC :=  "N"
            cEspecieC   :=  "NF"
            cTpDocVen :=  "1"  // NORMAL                
            cTipoDocv :=  "N"                
            cEspecieV   :=  "NF"
        
        EndIF

    Else    // liquidação secundaria.

        IF  NJC->NJC_TIPO == "2" // Liquidação Final

            cTpDocCom :=  "9"   // NDP
            cTipoDocC := "D"
            cEspecieC   :=  "NDP"
            cTpDocVen :=  "7"    // NCP
            cTipoDocv := "D"
            cEspecieV   :=  "NCP"

        ELSE // Liquidação Total e Parcial

            cTpDocCom :=  "10" // NORMAL
            cTipoDocC :=  "N"
            cEspecieC   :=  "NF"
            cTpDocVen :=  "7" // NCP
            cTipoDocv :=  "D"                
            cEspecieV   :=  "NCP"

        EndIF

    EndIf
Else // Liquidaçaõ de Vendas
    IF  NJC->NJC_TIPO == "2" // Liquidação Final                          

        cTpDocVen :=  "2"   // NDC
        cTipoDocv := "C"
        cEspecieV :=  "NDC"
        cTpDocCom :=  "4" // NCC
        cTipoDocC := "D"
        cEspecieC :=  "NCC"

    ELSE // Liquidação Total e Parcial

        cTpDocVen :=  "1"  // NORMAL
        cTpDocCom :=  "4"  //NCC
        cTipoDocv := "N"
        cTipoDocC := "D"
        cEspecieC   :=  "NCC"
        cEspecieV   :=  "NF"

    EndIF

EndIF

cLocxNFPV	:="0001"
cTpDocCom   := STRZERO(VAL(cTpDocCom), 2, 0) 

// Crio os cabeçalhos Entrada e Saida
// Podemos ter que gerar fatura dos dois tipos.


If (lRecPag .and.  NJC->NJC_TIPO == "2" .and. NJC->NJC_TPLIQ=="1") .or. (NJC->NJC_TPLIQ=="1" .And. lRecPag .And.  NJC->NJC_TIPO == "1");
	.or.  (!lRecPag .And.  NJC->NJC_TPLIQ=="2")
	lProp := .T.  
EndIf 

//Se obtienen las series a ser utilizadas
Fis828GSer(NJC->NJC_ESPLIQ, NJC->NJC_TPLIQ, @cSerNF, @cSerND, @cSerNC)

// Cabeçalho Fatura de Entrada.
cSerieSF1:=IIF(cTpDocCom == "04",cSerNC,cSerNf) 
aAdd(aCabsComp, {"F1_FILIAL ", xFilial('SF1'),  Nil})
aAdd(aCabsComp, {'F1_TIPO   ', cTipoDocC     ,  Nil})
aAdd(aCabsComp, {'F1_TIPODOC', cTpDocCom     ,  Nil})	
aAdd(aCabsComp, {'F1_FORMUL ', 'N'			 ,  Nil})	
aAdd(aCabsComp, {'F1_SERIE  ', cSerieSF1     ,  Nil})	//INFORMAÇÃO
aAdd(aCabsComp, {'F1_DOC    ', cNumLiq 		 ,  Nil})	
aAdd(aCabsComp, {'F1_EMISSAO', dDataBase	 ,  Nil})	
aAdd(aCabsComp, {'F1_FORNECE', cFornec		 ,  Nil})	
aAdd(aCabsComp, {'F1_LOJA   ', cLojForn      ,  Nil})	
aAdd(aCabsComp, {'F1_ESPECIE', cEspecieC   	 ,  Nil})
aAdd(aCabsComp, {'F1_PV'     , cLocxNFPV     ,  Nil}) //INFORMAÇÃO	
aAdd(aCabsComp, {"F1_MOEDA"  , 1             ,  Nil})	
aAdd(aCabsComp, {"F1_TXMOEDA", 1             ,  Nil}) 
aadd(aCabsComp, {'F1_NATUREZ', cNatureza     ,  Nil})	 //INFORMAÇÃO
aAdd(aCabsComp, {"F1_DTDIGIT", dDataBase     ,  Nil}) 
IF cTpDocCom == "04" // NCC
    aAdd(aCabsComp, {"F1_TPVENT", "B"        ,  Nil})  //INFORMAÇÃO
EndIF
 
cSerieSF2:= IIF(cTpDocVen == "2",cSerND,cSerNf)

// Cabeçalho Fatura de Saida.
aAdd(aCabsVend, {"F2_FILIAL ", xFilial('SF2'),  Nil})
aAdd(aCabsVend, {'F2_TIPO   ', cTipoDocv     ,  Nil})
aAdd(aCabsVend, {'F2_TIPODOC', cTpDocVen     ,  Nil})	
If lProp
	aAdd(aCabsVend, {'F2_FORMUL ', 'S'			 ,  Nil})	
Else
	aAdd(aCabsVend, {'F2_FORMUL ', 'N'			 ,  Nil})
EndIf
aAdd(aCabsVend, {'F2_SERIE  ', cSerieSF2   ,  Nil})	//INFORMAÇÃO
aAdd(aCabsVend, {'F2_DOC    ', cNumLiq 		 ,  Nil})	
aAdd(aCabsVend, {'F2_EMISSAO', dDataBase	 ,  Nil})	
aAdd(aCabsVend, {'F2_CLIENTE', cFornec		 ,  Nil})	
aAdd(aCabsVend, {'F2_LOJA   ', cLojForn      ,  Nil})	
aAdd(aCabsVend, {'F2_ESPECIE', cEspecieV   	 ,  Nil})
aAdd(aCabsVend, {'F2_TPVENT' , '1'      	 ,  Nil})    //INFORMAÇÃO
aAdd(aCabsVend, {'F2_PV'     , cLocxNFPV   	 ,  Nil})	 //INFORMAÇÃO
aAdd(aCabsVend, {"F2_MOEDA"  , 1             ,  Nil})	
aAdd(aCabsVend, {"F2_TXMOEDA", 1             ,  Nil}) 
aadd(aCabsVend, {'F2_NATUREZ', cNatureza     ,  Nil})	//INFORMAÇÃO
aAdd(aCabsVend, {"F2_DTDIGIT", dDataBase     ,  Nil}) 
IF cTpDocVen == "2" // NDC
    aAdd(aCabsVend, {"F2_IDIOMA", "1"        ,  Nil}) //INFORMAÇÃO
    aAdd(aCabsVend, {"F2_PAISENT", "063"     ,  Nil}) //INFORMAÇÃO
    aAdd(aCabsVend, {"F2_INCOTER", "CIP"     ,  Nil}) //INFORMAÇÃO
    aAdd(aCabsVend, {"F2_TPNFEXP", "1"       ,  Nil}) //INFORMAÇÃO
EndIF

If NJC->NJC_TIPO <> "2" // Se não for liquidação final, item 01 é referente ao cabeçalho da liquidação.

    lDesc := .F.   //Acrescenta o desconto ao primeiro item
    aAdd(aItensOpr, {})
    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_FILIAL" , xFilial(cTabela)           ,Nil})
    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_DOC"    , cNumLiq                    ,Nil}) //INFORMAÇÃO
    IF cTabela == "SF1"
        aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_FORNECE", cFornec                    ,Nil}) //INFORMAÇÃO
        aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_SERIE"  , cSerieSF1                      ,Nil}) //INFORMAÇÃO
    Else
        aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_CLIENTE", cFornec                    ,Nil}) //INFORMAÇÃO
        aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_SERIE"  , cSerieSF2                        ,Nil}) //INFORMAÇÃO
    EndIF
    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_LOJA"   , cLojForn                   ,Nil}) //INFORMAÇÃO
    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_EMISSAO", dDataBase                  ,Nil})
    AAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_DTDIGIT", dDataBase                  ,Nil})
    IF cTabela == "SF1"
        aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_ESPECIE", cEspecieC               ,Nil})
        aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_TIPODOC", cTpDocCom               ,Nil})
        aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_TIPO"   , cTipoDocC               ,Nil})
    Else
        aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_ESPECIE", cEspecieV               ,Nil})
        aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_TIPODOC", cTpDocVen               ,Nil})
        aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_TIPO"   , cTipoDocV               ,Nil})
    EndIF
    
    If  lProp
    	aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_FORMUL" , "S"                        ,Nil})    
    Else
    	aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_FORMUL" , "N"                        ,Nil})
    EndIf
    
    
    
    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_ITEM"   , cValToChar(nItemOp := nItemOp + 1 )     ,Nil})
    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_COD   " , cProduto                   ,Nil})
    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_UM     ", aSB1[1]                    ,Nil})
    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_QUANT  ", nQtdCab                    ,Nil})
    IF cTabela == "SF1"
        aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_VUNIT  ", nVlrCab                    ,Nil})
        If !lCondSF1 .And. Posicione("SF4",1,xFilial("SF4")+cTesCab,"F4_DUPLIC") =="S"
        	lCondSF1	:=.T.
    	EndIf
    Else
        aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_PRCVEN  ", nVlrCab                    ,Nil})
        If !lCondSF2 .And. Posicione("SF4",1,xFilial("SF4")+cTesCab,"F4_DUPLIC") =="S"
        	lCondSF2	:=.T.
    	EndIf
    EndIf
    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_TOTAL  ",ROUND(nTotCab,MsDecimais(1)),Nil})
    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_LOCAL  ", aSB1[2]                    ,Nil})		
    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_TES    ",cTesCab                     ,Nil})
    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_CF    ",Posicione("SF4",1,xFilial("SF4")+cTesCab,"F4_CF") ,Nil})
EndIF

DbSelectArea("NL4")
DbSetOrder(1)
IF Dbseek(xFilial("NL4")+NJC->NJC_CODLIQ)
    While NL4->(!Eof()) .And. NJC->NJC_CODLIQ == NL4->NL4_CODLIQ 
        IF NJC->NJC_CODLIQ == NL4->NL4_CODLIQ
            IF NL4->NL4_TIPO == "1"

                IF lRecPag // True = Pagar/Compra , Falso = Receber/Venda - inverto o alias para montar o array com as deduções.
                    cTabItem      := "D1" 
                    cTabela       := "SF1"
                Else
                    cTabItem      := "D2"
                    cTabela       := "SF2"
                EndIF

                aAdd(aItensOpr, {})
                aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_FILIAL" , xFilial(cTabela)           ,Nil})
                aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_DOC"    , cNumLiq                    ,Nil})
                
                IF cTabela == "SF1"
                	 aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_SERIE"  ,  cSerieSF1                    ,Nil})
                    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_FORNECE", cFornec                    ,Nil})
                Else
                 	aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_SERIE"  , cSerieSF2                        ,Nil})
                    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_CLIENTE", cFornec                    ,Nil})
                EndIF
                aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_LOJA"   , cLojForn                   ,Nil})
                aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_EMISSAO", dDataBase                  ,Nil})
                AAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_DTDIGIT", dDataBase                  ,Nil})
                IF cTabela == "SF1"
                    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_ESPECIE", cEspecieC                  ,Nil})
                    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_TIPODOC", cTpDocCom                  ,Nil})
                    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_TIPO"   , cTipoDocC                  ,Nil})
                Else
                    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_ESPECIE", cEspecieV                  ,Nil})
                    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_TIPODOC", cTpDocVen                    ,Nil})
                    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_TIPO"   , cTipoDocV                    ,Nil})
                EndIF
                If lProp
                	aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_FORMUL" , "S"                        ,Nil})
                Else
                	aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_FORMUL" , "N"                        ,Nil})
                Endif
                aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_ITEM"   , cValToChar(nItemOp + 1)     ,Nil})
                cprod:=""
                cprod:=Posicione("FR8",1,xFilial("FR8")+NL4->NL4_TIPDED,"FR8_CODPRO")
                If !Empty(cprod)
                	cProduto:= cprod
                EndIf
                aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_COD    ", cProduto                   ,Nil})
                
                aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_UM     ", aSB1[1]                    ,Nil})
                aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_QUANT  ", NL4->NL4_QUANT                    ,Nil})
                IF cTabela == "SF1"
                    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_VUNIT  ", iif(NL4->NL4_PRECIO == 0, NL4->NL4_IMPORT / NL4->NL4_QUANT , NL4->NL4_PRECIO )                      ,Nil})
                    If !lCondSF1 .And. Posicione("SF4",1,xFilial("SF4")+NL4->NL4_CODTES ,"F4_DUPLIC") =="S"
                		lCondSF1	:=.T.
        			EndIf
                Else
                    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_PRCVEN  ", iif(NL4->NL4_PRECIO == 0, NL4->NL4_IMPORT / NL4->NL4_QUANT , NL4->NL4_PRECIO )                     ,Nil})
                    If !lCondSF2 .And. Posicione("SF4",1,xFilial("SF4")+NL4->NL4_CODTES ,"F4_DUPLIC") =="S"
                    	lCondSF2	:=.T.
                    EndIf
                EndIF                
                aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_TOTAL  ", NL4->NL4_IMPORT                    ,Nil})
                aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_LOCAL  ", aSB1[2]                    ,Nil})		
                aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_TES    ", NL4->NL4_CODTES   ,Nil})
                aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_CF    ",Posicione("SF4",1,xFilial("SF4")+NL4->NL4_CODTES ,"F4_CF") ,Nil})
                if !lDesc
                    aAdd(aItensOpr[Len(aItensOpr)], {cTabItem+"_DESCON   ",0                           ,Nil})
                EndIF
                nTotOpera += NL4->NL4_IMPORT
            Else
                IF lRecPag // True = Pagar/Compra , Falso = Receber/Venda - inverto o alias para montar o array com as deduções.
                    cTabItem      := "D2"
                    cTabela       := "SF2"
                Else
                    cTabItem      := "D1" 
                    cTabela       := "SF1" 
                EndIF

                aAdd(aItensDed, {})
                aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_FILIAL" , xFilial(cTabela)             ,Nil})
                aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_DOC"    , cNumLiq                    ,Nil})
                 
                IF cTabela == "SF1" 
                	aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_SERIE"  , cSerieSF1                       ,Nil})
                    aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_FORNECE", cFornec                    ,Nil})
                Else
                	aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_SERIE"  , cSerieSF2                      ,Nil})
                    aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_CLIENTE", cFornec                    ,Nil})
                EndIF
                aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_LOJA"   , cLojForn                   ,Nil})
                aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_EMISSAO", dDataBase                  ,Nil})
                aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_DTDIGIT", dDataBase                  ,Nil})
                IF cTabela == "SF1" // Liquidaçaõ de Compras
                    aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_ESPECIE", cEspecieC  ,Nil})
                    aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_TIPODOC", cTpDocCom  ,Nil}) 
                    aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_TIPO"   , cTipoDocC  ,Nil})
                Else // Liquidaçaõ de Vendas
                    aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_ESPECIE", cEspecieV   ,Nil})
                    aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_TIPODOC", cTpDocVen   ,Nil}) 
                    aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_TIPO"   , cTipoDocV   ,Nil})
                EndIF
                If lProp
                	aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_FORMUL" , "S"                        ,Nil})
                Else
                	aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_FORMUL" , "N"                        ,Nil})
                EndIf
                aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_ITEM"   , cValToChar(nItemDed + 1)    ,Nil})
                cprod:=""
                cprod:=Posicione("FR8",1,xFilial("FR8")+NL4->NL4_TIPDED,"FR8_CODPRO")
                If !Empty(cprod)
                	cProduto:= cprod
                EndIf
                aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_COD    ", cProduto                   ,Nil})
                aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_UM     ", aSB1[1]                    ,Nil})
                aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_QUANT  ", NL4->NL4_QUANT                      ,Nil})
                IF cTabela == "SF1"
                    aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_VUNIT  ", iif(NL4->NL4_PRECIO == 0, NL4->NL4_IMPORT / NL4->NL4_QUANT , NL4->NL4_PRECIO )                      ,Nil})
                    If !lCondSF1 .And. Posicione("SF4",1,xFilial("SF4")+NL4->NL4_CODTES ,"F4_DUPLIC") =="S"
                		lCondSF1	:=.T.
        			EndIf   
                Else
                    aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_PRCVEN  ", iif(NL4->NL4_PRECIO == 0, NL4->NL4_IMPORT / NL4->NL4_QUANT , NL4->NL4_PRECIO )                     ,Nil})
                    If !lCondSF2 .And. Posicione("SF4",1,xFilial("SF4")+NL4->NL4_CODTES ,"F4_DUPLIC") =="S"
                		lCondSF2	:=.T.
        			EndIf
                EndIf
                aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_TOTAL  ",  NL4->NL4_IMPORT                     ,Nil})
                aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_LOCAL  ", aSB1[2]                    ,Nil})		
                aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_TES    ",NL4->NL4_CODTES               ,Nil})
                aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_CF    ",Posicione("SF4",1,xFilial("SF4")+NL4->NL4_CODTES ,"F4_CF") ,Nil})
                if !lDesc
                    aAdd(aItensDed[Len(aItensDed)], {cTabItem+"_DESCON   ",0                           ,Nil})
                EndIf
                If lRecPag .And. cTesCanje <> "1"
                    cTesCanje := Posicione("SF4",1,xFilial("SF4")+NL4->NL4_CODTES ,"F4_CANJE")
                EndIf
                nTotDeduc += NL4->NL4_IMPORT
                If !(!lRecPag .and. NJC->NJC_TIPO == "2")  .and.  SF4->( MsSeek( xFilial("SF4")+NL4->NL4_CODTES) )
                	If SFC->( MsSeek( xFilial("SFC")+SF4->F4_CODIGO) )
                		While SFC ->( !Eof() .And. SFC->FC_FILIAL+SFC->FC_TES == xFilial("SFC")+SF4->F4_CODIGO )
                			If SFB->( MsSeek( xFilial("SFB")+SFC->FC_IMPOSTO ) )
                				nTotDeduc += &("NL4->NL4_VALIM"+SFB->FB_CPOLVRO)
                			EndIf	
                			SFC->( DbSkip() )
                		Enddo 
                	EndIf
                EndIf
            EndIf
        
            //Acumular Impostos
            
            
            If (!lRecPag .and. NJC->NJC_TIPO == "2")  .and.  SF4->( MsSeek( xFilial("SF4")+NL4->NL4_CODTES) )
                
                If (nCredDeb >0  .And. NL4->NL4_TIPO == "2")  .Or. (nCredDeb <0  .And. NL4->NL4_TIPO == "1")
	                If SFC->( MsSeek( xFilial("SFC")+SF4->F4_CODIGO) )
	               		While SFC ->( !Eof() .And. SFC->FC_FILIAL+SFC->FC_TES == xFilial("SFC")+SF4->F4_CODIGO )
	               			If SFB->( MsSeek( xFilial("SFB")+SFC->FC_IMPOSTO ) )
	               				nVlImpRet += &("NL4->NL4_VALIM"+SFB->FB_CPOLVRO)
	              			EndIf	
	               			SFC->( DbSkip() )
	               		Enddo 
	            	EndIf
	            EndIf	
	        EndIf  
        EndIf
        NL4->(DBSKIP())

    EndDo
    If cTesCanje <> "" .And. SF2->(ColumnPos( "F2_CANJE" )) > 0
        aAdd(aCabsVend, {"F2_CANJE" , cTesCanje ,  Nil})
    EndIf
ENDIF

aAreaAtual:=GetArea()
DbSelectArea("FKR")
FKR->(DBSETORDER(1)) //FKR_FILIAL+FKR_CODIGO+FKR_TIPO
If !(!lRecPag .and. NJC->NJC_TIPO == "2") .And. FKR->(MsSeek(xFilial("FKR")+ NJC->NJC_CODLIQ))
	While FKR->(!Eof()) 
		If  FKR->FKR_CODIGO == NJC->NJC_CODLIQ
			nTotDeduc +=  FKR->FKR_RETENC
		EndIf
		FKR->(dBsKIP())  
	EndDo	
EndIf    	

RestArea(aAreaAtual)

If lCondSF1 
	aAdd(aCabsComp, {'F1_COND   ',  cCondPago      ,  Nil})
EndIf

If lCondSF2
	aAdd(aCabsVend, {'F2_COND   ', cCondPago       ,  Nil})
EndIf

IF lDesc // Verifica se não é liquidação final para acrescentar o desconto ao primeiro item.
    IF lRecPag  // True = Pagar/Compra , Falso = Receber/Venda
        IF nCredDeb >= 0  // Credito/Debito           
            cTabItem      := "D1" 
            cTabela       := "SF1"  
            IF Len(aItensOpr) > 0 
                aAdd(aItensOpr[1], {cTabItem+"_VALDESC   ",nTotDeduc                           ,Nil}) // Acrescenta o desconto com o total de deduções.
            EndIF
            cTabItem      := "D2"
            cTabela       := "SF2" 
            IF Len(aItensDed) > 0
                aAdd(aItensDed[1], {cTabItem+"_DESCON   ",nTotDeduc                           ,Nil}) // Acrescenta o desconto com o total de deduções. 
            EndIF
        Else
            cTabItem      := "D1" 
            cTabela       := "SF1"  
            IF Len(aItensOpr) > 0
                aAdd(aItensOpr[1], {cTabItem+"_VALDESC   ",nTotOpera                           ,Nil}) // Acrescenta o desconto com o total de deduções.
            EndIf
            cTabItem      := "D2"
            cTabela       := "SF2"
            IF Len(aItensDed) > 0
                aAdd(aItensDed[1], {cTabItem+"_DESCON   ",nTotOpera                           ,Nil}) // Acrescenta o desconto com o total de deduções. 
            EndIF
        EndIF
    Else
    	If (!lRecPag .and. NJC->NJC_TIPO == "2")  // LSG Final ventas
    		IF nCredDeb >= 0  // Credito/Debito   
    			aAdd(aCabsComp, {"F1_DESCONT", nTotDeduc,  Nil}) 
    			aAdd(aCabsVend, {"F2_DESCONT", nTotDeduc +nVlImpRet,  Nil}) 
	        Else
	        	aAdd(aCabsComp, {"F1_DESCONT", nTotOpera +nVlImpRet,  Nil}) 
	        	aAdd(aCabsVend, {"F2_DESCONT", nTotOpera,  Nil}) 
	        EndIf
    	Else
    	
  			IF nCredDeb >= 0  // Credito/Debito   
	            cTabItem      := "D2"
	            cTabela       := "SF2" 
	            IF Len(aItensOpr) > 0
	                aAdd(aItensOpr[1], {cTabItem+"_DESCON",nTotDeduc                           ,Nil}) // Acrescenta o desconto com o total de deduções.
	            EndIf
	          cTabItem      := "D1" 
	            cTabela       := "SF1"  
	            IF Len(aItensDed) > 0
	                aAdd(aItensDed[1], {cTabItem+"_VALDESC",nTotDeduc                           ,Nil}) // Acrescenta o desconto com o total de deduções.
	            EndIf
	        Else
	            cTabItem      := "D2"
	            cTabela       := "SF2" 
	            IF Len(aItensOpr) > 0
	                aAdd(aItensOpr[1], {cTabItem+"_DESCON",nTotOpera                           ,Nil}) // Acrescenta o desconto com o total de deduções.
	            EndIf
	            aAdd(aCabsComp, {"F1_DESCONT", nTotDeduc     ,  Nil}) 
	            
	            cTabItem      := "D1" 
	            cTabela       := "SF1"  
	            IF Len(aItensDed) > 0
	                aAdd(aItensDed[1], {cTabItem+"_VALDESC",nTotOpera                           ,Nil}) // Acrescenta o desconto com o total de deduções.
	            EndIF
	        EndIF
	    EndIf    
    EndIF
Else
    IF Len(aItensOpr) > 0
        IF lRecPag  // True = Pagar/Compra , Falso = Receber/Venda
            cTabItem      := "D1" 
            cTabela       := "SF1"  
            //aAdd(aItensOpr[1], {cTabItem+"_VALDESC   ",nTotDeduc                           ,Nil}) // Acrescenta o desconto com o total de deduções. 
            aAdd(aCabsComp, {"F1_DESCONT", nTotDeduc     ,  Nil}) 
        Else
            cTabItem      := "D2"
            cTabela       := "SF2" 
            aAdd(aCabsVend, {"F2_DESCONT", nTotDeduc     ,  Nil}) 
            //aAdd(aItensOpr[1], {cTabItem+"_DESCON   ",nTotDeduc  ,Nil})
           // aAdd(aItensOpr[1], {cTabItem+"_DESCON   ",IIF(nTotDeduc > nTotOpera,nTotOpera,nTotDeduc)  ,Nil}) // Acrescenta o desconto com o total de deduções.
        EndIF
    EndIf
ENDIF

If SF1->(ColumnPos( "F1_EST" )) > 0
	aAdd(aCabsComp, {"F1_EST",NJC->NJC_PROVEN,  Nil}) 
EndIf
If SF1->(ColumnPos( "F1_PROVENT" )) > 0
	aAdd(aCabsComp, {"F1_PROVENT",NJC->NJC_PROVEN,  Nil}) 
EndIf

If SF2->(ColumnPos( "F2_EST" )) > 0
	aAdd(aCabsVend, {"F2_EST",NJC->NJC_PROVEN,  Nil}) 
EndIf
If SF2->(ColumnPos( "F2_PROVENT" )) > 0
	aAdd(aCabsVend, {"F2_PROVENT",NJC->NJC_PROVEN,  Nil}) 
EndIf

cLIq:="1" // No Genero retencion na Liquidacion

IF lRecPag .And. NJC->NJC_TPLIQ == "1" // Pagar Primaria
	cLIq:= "2"   // Genero retencion na Liquidacion
EndIf
       	
If SF2->(ColumnPos( "F2_LIQGR" )) > 0
	aAdd(aCabsVend, {"F2_LIQGR",cLIq,  Nil}) 
EndIf
If SF1->(ColumnPos( "F1_LIQGR" )) > 0
	aAdd(aCabsComp, {"F1_LIQGR",cLIq,  Nil}) 
EndIf

If NJC->NJC_TPLIQ == "1"
	aAdd(aCabsComp, {"F1_RG1415","033",  Nil}) 
	aAdd(aCabsVend, {"F2_RG1415","033",  Nil})
Else
	aAdd(aCabsComp, {"F1_RG1415","331",  Nil}) 
	aAdd(aCabsVend, {"F2_RG1415","331",  Nil})	
EndIf


//Se coloca el punto de venta con el cual se realizará la grabación para el correcto funcionamiento y se respalda el que está actualmente.
Pergunte("PVXARG",.F.)
cPVAux := MV_PAR01
SetMVValue("PVXARG","MV_PAR01",cLocxNFPV)

IF lRecPag // True = Pagar/Compra , Falso = Receber/Venda

    // Caso seja liquidação a pagar/compras
    // é gerado uma nota de entrada com os itens da operação.
    If NJC->NJC_TIPO <> "2" // Se não for liquidação final, item 01 é referente ao cabeçalho.
        IF Len(aItensOpr) > 0 
            IF lF828G1
                aF828G1  := ExecBlock("F828G1" ,.F.,.F.,{aCabsComp,aItensOpr})
                If ValType(aF828G1) == "A" .And. Len(aF828G1) >0
                    If ValType(aF828G1[1]) == "A"
                        aCabsComp := aClone(aF828G1[1])
                    EndIf
                    If ValType(aF828G1[2]) == "A" 
                        aItensOpr := aClone(aF828G1[2])
                    EndIf
                EndIF
            EndIF

            MSExecAuto({|x,y,z,a| MATA101N(x,y,z,a)},aCabsComp,aItensOpr,3)	 //3-Incluir, 5-Excluir e 6-Cancelar
        
            If !lMsErroAuto		
                ConOut(OemToAnsi("Documento gerado com sucesso!"))	
            Else		
                ConOut(OemToAnsi("Erro na inclusão"))
                If !lAutomato		
                	MostraErro()
                EndIf
                lError := .T.	
            EndIf       
            ConOut("Fim  : "+Time())

        EndIF

        IF Len(aItensDed) > 0  .And. NJC->NJC_TPLIQ=="1" 
            If !lError// é gerada uma nota de saida apenas com os itens das deduções.
                IF lF828G2
                    aF828G2  := ExecBlock("F828G2" ,.F.,.F.,{aCabsVend,aItensDed})
                    If ValType(aF828G2) == "A" .And. Len(aF828G2) >0
                        If ValType(aF828G2[1]) == "A"
                            aCabsVend := aClone(aF828G2[1])
                        EndIf
                        If ValType(aF828G2[2]) == "A" 
                            aItensDed := aClone(aF828G2[2])
                        EndIf
                    EndIF
                EndIF

                MSExecAuto( { |x,y,z| Mata467n(x,y,z) }, aCabsVend, aItensDed, 3 )   //3-Incluir, 5-Excluir e 6-Cancelar
                If !lMsErroAuto		
                    ConOut(OemToAnsi("Documento gerado com sucesso!"))		
                Else		
                    ConOut("Erro na inclusao!")
                    If !lAutomato	
                    	MostraErro()
                    EndIf
                    lError := .T.
                EndIf	
                ConOut("Fim  : "+Time())
            EndIf
        EndIF
        
        IF Len(aItensDed) > 0   .And. NJC->NJC_TPLIQ=="2" 

            IF lF828G3
                aF828G3  := ExecBlock("F828G3" ,.F.,.F.,{aCabsVend,aItensDed})
                If ValType(aF828G3) == "A" .And. Len(aF828G3) >0
                    If ValType(aF828G3[1]) == "A"
                        aCabsVend := aClone(aF828G3[1])
                    EndIf
                    If ValType(aF828G3[2]) == "A" 
                        aItensDed := aClone(aF828G3[2])
                    EndIf
                EndIF
            EndIF
            
            MSExecAuto({|x,y,z,a| MATA466N(x,y,z,a)},aCabsVend,aItensDed,3)	 //3-Incluir, 5-Excluir e 6-Cancelar
        
            If !lMsErroAuto		
                ConOut(OemToAnsi("Documento gerado com sucesso!"))
            Else		
                ConOut(OemToAnsi("Erro na inclusão"))		
                If !lAutomato
                	MostraErro()
                EndIf
                lError := .T.	
            EndIf       
            ConOut("Fim  : "+Time())
        EndIf
    Else
        IF Len(aItensOpr) > 0  
            IF lF828G4
                aF828G4  := ExecBlock("F828G4" ,.F.,.F.,{aCabsComp,aItensOpr})
                If ValType(aF828G4) == "A" .And. Len(aF828G4) >0
                    If ValType(aF828G4[1]) == "A"
                        aCabsComp := aClone(aF828G4[1])
                    EndIf
                    If ValType(aF828G4[2]) == "A" 
                        aItensOpr := aClone(aF828G4[2])
                    EndIf
                EndIF
            EndIF
            MSExecAuto({|x,y,z,a| MATA466N(x,y,z,a)},aCabsComp,aItensOpr,3)	 //3-Incluir, 5-Excluir e 6-Cancelar
        
            If !lMsErroAuto		
                ConOut(OemToAnsi("Documento gerado com sucesso!"))
            Else		
                ConOut(OemToAnsi("Erro na inclusão"))		
                If !lAutomato
                	MostraErro()
                EndIf
                lError := .T.	
            EndIf       
            ConOut("Fim  : "+Time())

        EndIF
        If NJC->NJC_TPLIQ=="1"
            IF Len(aItensDed) > 0 
	            If !lError// é gerada uma nota de saida apenas com os itens das deduções.
                     IF lF828G5
                        aF828G5  := ExecBlock("F828G5" ,.F.,.F.,{aCabsVend,aItensDed})
                        If ValType(aF828G5) == "A" .And. Len(aF828G5) >0
                            If ValType(aF828G5[1]) == "A"
                                aCabsVend := aClone(aF828G5[1])
                            EndIf
                            If ValType(aF828G5[2]) == "A" 
                                aItensDed := aClone(aF828G5[2])
                            EndIf
                        EndIF
                    EndIF
	                MSExecAuto( { |x,y,z| MATA465N(x,y,z) }, aCabsVend, aItensDed, 3 )   //3-Incluir, 5-Excluir e 6-Cancelar
	                If !lMsErroAuto		
	                    ConOut(OemToAnsi("Documento gerado com sucesso!"))		
	                Else		
	                    ConOut("Erro na inclusao!")	
	                    If !lAutomato
	                    	MostraErro()
	                    EndIf
	                    lError := .T.
	                EndIf	
	                ConOut("Fim  : "+Time())
	            EndIf
	        EndIF    
        
        
        Else
	        IF Len(aItensDed) > 0 
	            If !lError// é gerada uma nota de saida apenas com os itens das deduções.
                    IF lF828G6
                        aF828G6  := ExecBlock("F828G6" ,.F.,.F.,{aCabsVend,aItensDed})
                        If ValType(aF828G6) == "A" .And. Len(aF828G6) >0
                            If ValType(aF828G6[1]) == "A"
                                aCabsVend := aClone(aF828G6[1])
                            EndIf
                            If ValType(aF828G6[2]) == "A" 
                                aItensDed := aClone(aF828G6[2])
                            EndIf
                        EndIF
                    EndIF
	                MSExecAuto( { |x,y,z| MATA466N(x,y,z) }, aCabsVend, aItensDed, 3 )   //3-Incluir, 5-Excluir e 6-Cancelar
	                If !lMsErroAuto		
	                    ConOut(OemToAnsi("Documento gerado com sucesso!"))		
	                Else		
	                    ConOut("Erro na inclusao!")	
	                    If !lAutomato
	                    	MostraErro()
	                    EndIf
	                    lError := .T.
	                EndIf	
	                ConOut("Fim  : "+Time())
	            EndIf
	        EndIF
	    EndIf
    EndIF

Else

    If NJC->NJC_TIPO <> "2" // Se não for liquidação final, item 01 é referente ao cabeçalho.
        // Caso seja liquidação a receber/faturamento
        IF Len(aItensDed) > 0 
            // é gerada uma nota de entrada apenas com os itens das deduções.
            lGerDupl:=.F.
            IF lF828G7
                aF828G7  := ExecBlock("F828G7" ,.F.,.F.,{aCabsComp,aItensDed})
                If ValType(aF828G7) == "A" .And. Len(aF828G7) >0
                    If ValType(aF828G7[1]) == "A"
                        aCabsComp := aClone(aF828G7[1])
                    EndIf
                    If ValType(aF828G7[2]) == "A" 
                        aItensDed := aClone(aF828G7[2])
                    EndIf
                EndIF
            EndIF
            MSExecAuto({|x,y,z,a| mata465N(x,y,z,a)},aCabsComp,aItensDed,3)	 //3-Incluir, 5-Excluir e 6-Cancelar
            If !lMsErroAuto		
                ConOut(OemToAnsi("Documento gerado com sucesso!"))	
            Else		
                ConOut(OemToAnsi("Erro na inclusão"))		
                If !lAutomato
                	MostraErro()
                EndIf	
                lError := .T.
            EndIf       
            ConOut("Fim  : "+Time())
            SD1->(DBCloseArea())
            SF1->(DBCloseArea())
        EndIF

        // é gerado uma nota de saida com os itens da operação.  
        If !lError
        	lGerDupl:=.T.
            IF Len(aItensOpr) > 0 
                IF lF828G8
                    aF828G8  := ExecBlock("F828G8" ,.F.,.F.,{aCabsVend,aItensOpr})
                    If ValType(aF828G8) == "A" .And. Len(aF828G8) >0
                        If ValType(aF828G8[1]) == "A"
                            aCabsVend := aClone(aF828G8[1])
                        EndIf
                        If ValType(aF828G8[2]) == "A" 
                            aItensOpr := aClone(aF828G8[2])
                        EndIf
                    EndIF
                EndIF
                MSExecAuto( { |x,y,z| Mata467n(x,y,z) }, aCabsVend, aItensOpr, 3 )   //3-Incluir, 5-Excluir e 6-Cancelar
                If !lMsErroAuto		
                    ConOut(OemToAnsi("Documento gerado com sucesso!"))		
                Else		
                    ConOut("Erro na inclusao!")	
                    If !lAutomato
                    	MostraErro()
                    EndIf
                    lError := .T.
                EndIf	
                ConOut("Fim  : "+Time())
            EndIF
        EndIF	        
    Else // Liquidação final
        // Caso seja liquidação a receber/faturamento
        
         
        IF Len(aItensDed) > 0 
            // é gerada uma nota de entrada apenas com os itens das deduções.// NCC
            If nCredDeb <0
            	lGerDupl:=.T.
            Else
            	lGerDupl:=.F.
            ENdIf
            IF lF828G9
                aF828G9  := ExecBlock("F828G9" ,.F.,.F.,{aCabsComp,aItensDed})
                If ValType(aF828G9) == "A" .And. Len(aF828G9) >0
                    If ValType(aF828G9[1]) == "A"
                        aCabsComp := aClone(aF828G9[1])
                    EndIf
                    If ValType(aF828G9[2]) == "A" 
                        aItensDed := aClone(aF828G9[2])
                    EndIf
                EndIF
            EndIF
            MSExecAuto({|x,y,z,a| mata465N(x,y,z,a)},aCabsComp,aItensDed,3)	 //3-Incluir, 5-Excluir e 6-Cancelar
            If !lMsErroAuto		
                ConOut(OemToAnsi("Documento gerado com sucesso!"))
            Else		
                ConOut(OemToAnsi("Erro na inclusão"))		
                If !lAutomato
                	MostraErro()
                EndIf	
                lError := .T.
            EndIf       
            ConOut("Fim  : "+Time())
            SD1->(DBCloseArea())
            SF1->(DBCloseArea())
        EndIF

        // é gerado uma nota de saida com os itens da operação.  
        If !lError
        	If nCredDeb > 0
            	lGerDupl:=.T.
            Else
            	lGerDupl:=.F.
            ENdIf
            
            IF Len(aItensOpr) > 0 
                 IF lF828G10
                    aF828G10  := ExecBlock("F828G10" ,.F.,.F.,{aCabsVend,aItensOpr})
                    If ValType(aF828G10) == "A" .And. Len(aF828G10) >0
                        If ValType(aF828G10[1]) == "A"
                            aCabsVend := aClone(aF828G10[1])
                        EndIf
                        If ValType(aF828G10[2]) == "A" 
                            aItensOpr := aClone(aF828G10[2])
                        EndIf
                    EndIF
                EndIF
                MSExecAuto( { |x,y,z| mata465N(x,y,z) }, aCabsVend, aItensOpr, 3 )   //3-Incluir, 5-Excluir e 6-Cancelar //NDC
                If !lMsErroAuto		
                    ConOut(OemToAnsi("Documento gerado com sucesso!"))		
                Else		
                    ConOut("Erro na inclusao!")	
                    If !lAutomato
                    	MostraErro()
                    EndIf
                    lError := .T.
                EndIf	
                ConOut("Fim  : "+Time())
            EndIF
        EndIF	    

    EndIF

EndIF	

//Se reestablece el punto de venta original
SetMVValue("PVXARG","MV_PAR01",cPVAux)

IF !lError .AND. (Len(aItensOpr) > 0 .or. Len(aItensDed) > 0)
        DbSelectArea("FKR")
        FKR->(DBSETORDER(1)) //FKR_FILIAL+FKR_CODIGO+FKR_TIPO
        If FKR->(MsSeek(xFilial("FKR")+ NJC->NJC_CODLIQ))
            While FKR->(!Eof()) 
                if  FKR->FKR_CODIGO == NJC->NJC_CODLIQ

                    DO CASE
                        CASE FKR->FKR_TIPO == "I"
                            cImpuesto :=	"IVA  "
                        CASE FKR->FKR_TIPO == "B"
                            cImpuesto :=	"IB   "
                        CASE FKR->FKR_TIPO == "G"
                            cImpuesto :=	"GANAN"
                        CASE FKR->FKR_TIPO == "E"
                            cImpuesto :=	"SEL  "
                        CASE FKR->FKR_TIPO == "D"
                            cImpuesto :=	"DERC "
                        OTHERWISE
                            cImpuesto :=	"CERT "
                    ENDCASE
                
                    cCert := F850GetCert(cImpuesto ,cFornec+cLojForn+ALLTRIM(cImpuesto))
                
                    Begin Transaction
                    DbSelectArea("SFE")
                    RecLock("SFE",.T.)
                    SFE->FE_FILIAL     := xFilial("SFE")                 //Filial que está gerando o certificado
                    SFE->FE_NROCERT    := cCert                         //Numero Certificado            
                    SFE->FE_EMISSAO    := dDataBase                     //Data Emissao
                    SFE->FE_NFISCAL    := cNumLiq                       //Numero da fatura
                    SFE->FE_SERIE      := cSerieSF1                          //Serie da fatura   
                    IF lRecPag 
                        SFE->FE_FORNECE    := cFornec            //Codigo do Fornecedor
                        SFE->FE_LOJA       := cLojForn           //Loja            
                    Else
                        SFE->FE_CLIENTE    := cFornec           //Codigo do Cliente
                        SFE->FE_LOJCLI     := cLojForn            //Loja            
                    Endif
                    // SFE->FE_TIPO        := iif(lRecPag,"P","R")    
                    SFE->FE_TIPO        := FKR->FKR_TIPO //iif(lRecPag,"P","R")
                    SFE->FE_CONCEPT     := FKR->FKR_CONCEP
                    SFE->FE_EST         := FKR->FKR_EST 
                    SFE->FE_CFO         := FKR->FKR_CFO
                    SFE->FE_ESPECIE     := iif(lRecPag,cEspecieC,cEspecieV) //Especie da Nota
                    SFE->FE_ALIQ        := FKR->FKR_ALIQ                      //Aliquota para o Calculo
                    SFE->FE_VALBASE     := FKR->FKR_VALBAS                  //Base de calculo da retenção
                    SFE->FE_VALIMP      := FKR->FKR_RETENC                    //Valor do imposto da retenção
                    SFE->FE_RETENC      := FKR->FKR_RETENC                      //Valor da retenção            
                    SFE->(MsUnLock())
                    End Transaction
                eNDif   
                FKR->(dBsKIP())  
            EndDo
        EndIF
EndIF 


If !lError
	RecLock("NJC",.F.)
	NJC->NJC_STATUS := "2" 
	
	If (lRecPag .and. NJC->NJC_TPLIQ=="1"  .And.  NJC->NJC_TIPO=="2" ) .or. (!lRecPag  .And. NJC->NJC_TIPO=="2" )
		NJC->NJC_COEAJU:=cCoe 
	Else
		NJC->NJC_COMPRO := cCoe
	EndIf
	
	NJC->(MsUnLock())

    If NJC->NJC_TPLIQ=="2" .AND. lRecPag
        cRem := NJC->NJC_REMITO
		cRSer := NJC->NJC_SERREM 
        DbSelectArea("SD1")
        DbSetOrder(1)
        If  MSSeek(xFilial("SD1") + cRem + cRSer )
            RecLock("SD1",.F.) 
            SD1->D1_COELQ := cCoe
            SD1->(MsUnlock())
        EndIf
        SD1->(dbCloseArea())
    EndIf 

	If SF2->(ColumnPos( "F2_LIQGR" )) > 0
		DbSelectArea("SF2")
		DBSetOrder(1)
		 If SF2->(Dbseek(xFilial("SF2")+Padr(aCabsVend[6][2],TamSX3("F2_DOC")[1]) +Padr(aCabsVend[5][2],TamSX3("F2_SERIE")[1])+aCabsVend[8][2]+aCabsVend[9][2]   ))
			RecLock("SF2",.F.) 
			SF2->F2_LIQGR := cLIq
			SF2->(MsUnlock())
		 EndIf
	EndIf
	If SF1->(ColumnPos( "F1_LIQGR" )) > 0
		DbSelectArea("SF1")
		DBSetOrder(1)
		If SF1->(Dbseek(xFilial("SF1")+Padr(aCabsComp[6][2],TamSX3("F1_DOC")[1])+Padr(aCabsComp[5][2],TamSX3("F1_SERIE")[1])+aCabsComp[8][2]+aCabsComp[9][2]+aCabsComp[2][2]))  
			RecLock("SF1",.F.) 
			SF1->F1_LIQGR := cLIq
			SF1->(MsUnlock())
		EndIf 
	EndIf





EndIf

RestArea(aAreaNJC)
RestArea(aAreaNL3)	
RestArea(aAreaNL4)	
RestArea(aAreaSF1)	
RestArea(aAreaSF2)	
RestArea(aAreaSD1)	
RestArea(aAreaSD2)
RestArea(aAreaSFE)		


Return .T.


//Función para buscar las series configurada en los parametros
// cEspLiq - 1 Pagar, 2 Recibir
// cTipLiq - 1 Primaria , 2 Secundaria
// cSerNF - Serie para Factura (Retornada por parámetro)
// cSerND - Serie para Debito (Retornada por parámetro)
// cSerNC - Serie para Credito (Retornada por parámetro)

// MV_SERLPGC -> Serie LPG Compras
// MV_SERLSGC -> Serie LSG Compras 
// MV_SERLSGV -> Serie LSG Ventas

Static Function Fis828GSer(cEspLiq, cTipLiq, cSerNF, cSerND, cSerNC)
Local cParam	:= ""
Local xValPar

	If cEspLiq == "1"
		If cTipLiq == "1" 
			cParam := "MV_SERLPGC"
		ElseIf cTipLiq == "2"
			cParam := "MV_SERLSGC"
		EndIf
	ElseIf cEspLiq == "2"
		cParam := "MV_SERLSGV"
	EndIf

	
	xValPar := &(GetNewPar (cParam, ""))
	
	If ValType(xValPar) == "A" .and. Len(xValPar) == 3
		cSerNF := xValPar[1]
		cSerND := xValPar[2]
		cSerNC := xValPar[3]
	Else
		cSerNF := "A"
		cSerND := "AD"
		cSerNC := "AC"
	EndIf
	
Return
