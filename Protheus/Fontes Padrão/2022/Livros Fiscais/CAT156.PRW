#Include "CAT156.CH"
#Include "PROTHEUS.CH" 
              
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCAT156    บAutor  ณVitor Felipe        บ Data ณ  12/04/11	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreparacao do meio magnetico CAT156 - Disciplina o cumpri-  บฑฑ
ฑฑบ          ณmento de obrigacoes acessorias pelos prestadores de servico บฑฑ
ฑฑบ          ณde intermediacao comercial em anbiente virtual e pelos      บฑฑ
ฑฑบ			 ณprestadores de servicos realacionados a comercio eletronico บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CAT156()

Local	lEnd		:=	.F. 
Local	aWizard		:=	{}
Local	cFileDest	:=	"CAT156.TXT"
Local	cNomWiz		:=	"CAT156"
Local	lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

If lVerpesssen .And. (MontWiz (cNomWiz))
	
	Processa({||PrCat156(@lEnd, aWizard, @cFileDest)})
	
	If File(cFileDest)
		MsgInfo(STR0001 + cFileDest + STR0002) //"Arquivo "###" gerado com sucesso!"
	Else
		MsgAlert (STR0003) //"Nใo foi possํvel gerar o arquivo!"
	EndIf
	
EndIf

Return()  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrCat156  บAutor  ณNatalia Antonucci   บ Data ณ  27/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao principal de processamento do arq. magnetico CAT156  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrCat156(lEnd,aWizard,cFileDest) 

Local cFilDe   := ""
Local cFilAte  := "" 
Local cPeriodo := ""
Local cDir     := ""
Local cNomeCfp := "CAT156"
Local cAliasSD2:= "SD2"
Local cAliasSA1:= "SA1"
Local cAliasSC6:= "SC6"
Local cAliasSF4:= "SF4"
Local cAliasSB1:= "SB1"                                     
Local cFiltro  := "" 
Local cAntCCG  := ""
Local cIndex   := "" 
Local cCampo   := ""
Local cCampoCod:= ""
Local cCodServ := "" 
Local cSer 	   := "" 
Local dDataDe  := ctod("//")
Local dDataAte := ctod("//")                                    
Local nIndex   := 0 
Local nPos     := 0 
Local nReg0000 := 0
Local nReg0001 := 1 
Local nReg0010 := 0
Local nReg0990 := 1
Local nReg5001 := 1 
Local nReg5020 := 0
Local nReg5030 := 0
Local nReg5040 := 0
Local nReg5050 := 0
Local nReg5060 := 0    
Local nReg5070 := 0
Local nReg5990 := 1 
Local nReg9001 := 1
Local nReg9990 := 1 
Local nReg9900 := 1 
Local cCodSerSB1 := GetNewPar("MV_CSER156","")
Local lCodSerSB1 := !Empty(cCodSerSB1)  
Local lTop 	  := .F.
Local lCodPag := .F.
Local lIPWeb  := .F.
Local lPagCom := .F.
Local aArq := {}  
Local cCpoD2  := "%" + "SD2.D2_EMISSAO,SD2.D2_PICM,SD2.D2_COD, SD2.D2_QUANT,SD2.D2_CODISS,SD2.D2_TES,SD2.D2_DESC,SD2.D2_NFORI,SD2.D2_SERIORI,"+;
				 "SD2.D2_ITEMORI,SD2.D2_TES,SD2.D2_PRCVEN,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_EST,SD2.D2_TOTAL,"+;
				 "SD2.D2_PEDIDO,SD2.D2_ITEM" + ",D2_VCAT156," + "%"


#IFDEF TOP
	Local 	aFilClone	:= {}
	Private lSelFil		:= .F.
	Private lAglFil		:= .F.  
	Private aFilsCalc	:= {}
	
#ENDIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtribuo o conteudo do CFP gerado pelo wizard no array aWizardณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (!xMagLeWiz (cNomeCfp, @aWizard, .T.))
	Return	//Se por algum motivo a leitura do CFP falhar aborto a rotina.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriacao do TRB para ser alimentado durante o processamento da rotinaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GeraArq(@aArq)  //Geracao da estrutura do TRB  

cPeriodo := Alltrim(aWizard[1][1])
cDir     := Alltrim(aWizard[1][3])

Do Case
	Case SubStr(aWizard[1][1],1,2) == "1T"
		dDataDe  := CTOD("01/01/"+substr(cperiodo,3,4))
		dDataAte := lastdate( ctod("01/03/"+substr(cperiodo,3,4)))
	Case SubStr(aWizard[1][1],1,2) == "2T"
		dDataDe  := CTOD("01/04/"+substr(cperiodo,3,4))
		dDataAte := lastdate( ctod("01/06/"+substr(cperiodo,3,4)))
	Case SubStr(aWizard[1][1],1,2) == "3T"	      
	    dDataDe  := CTOD("01/07/"+substr(cperiodo,3,4))
		dDataAte := lastdate( ctod("01/09/"+substr(cperiodo,3,4)))
	Case SubStr(aWizard[1][1],1,2) == "4T"
		dDataDe  := CTOD("01/10/"+substr(cperiodo,3,4))
		dDataAte := lastdate( ctod("01/12/"+substr(cperiodo,3,4)))
EndCase   

#IFDEF TOP
	lSelFil	:= ('1' $ aWizard[1][10])
	lAglFil	:= ('1' $ aWizard[1][11])
	If lSelFil
		aFilsCalc	:=	MatFilCalc(.T., , , lAglFil, , IIf(lAglFil, 2, 0) )
		If ( Len(aFilsCalc) >= 1 )
			aFilClone	:= aSort(aFilsCalc, , , { | x,y | x[2] < y[2] } )	
			cFilDe		:= aFilClone[01][02]
			cFilAte		:= aFilClone[Len(aFilClone)][02]
		Endif
	Else
		Aadd(aFilsCalc,{.T., SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC,SM0->M0_INSC})
		cFilDe		:= cFilAte	:= cFilAnt
	EndIf

#ELSE
	cFilDe   := Alltrim(aWizard[1][8]) 
	cFilAte  := Alltrim(aWizard[1][9])                                                                                             
#ENDIF


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTrata Diretorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (SubStr (cDir, Len (cDir), 1)<>"\")
	cDir	+=	"\"
EndIf
cFileDest	:=	cDir+AllTrim(aWizard[1][4]) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefinicao da ordem das tabelasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea ("SA1")	//Cadastro do Cliente
SA1->(DbSetOrder (1))			
DbSelectArea ("SF4")	//Cadastro de TES
SF4->(DbSetOrder (1))
DbSelectArea ("SD2")	//Itens das Nfs de Saida
SD2->(DbSetOrder (3))
DbSelectArea ("SB1")	//Cadastro de Produtos
SB1->(DbSetOrder (1))
DbSelectArea ("SC6")	//Pedido de Venda
SC6->(DbSetOrder (2))	

DbSelectArea ("SM0")
SM0->(DbSeek (cEmpAnt+cFilDe,.T.))

Do While !SM0->(Eof ()) .And. (FWGrpCompany()==cEmpAnt) .And. (FWCodFil()<=cFilAte)
	cFilAnt	:= FWCodFil()
	DbSelectArea("SD2")                        	
	SD2->(DbSetOrder(3))
	#IFDEF TOP
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe foram selecionadas as filiais, identifica se a filial posicionada esta selecionada no arrayณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lSelFil .and. ( ( nPosFil := aScan(aFilsCalc,{|x| Alltrim(x[2]) == Alltrim(SM0->M0_CODFIL)}) ) = 0 .or. !aFilsCalc[nPosFil,1] )
			SM0->(dbSkip())
			Loop
		EndIf 	    	    		

    	If (TcSrvType ()<>"AS/400")
   			 lTop 	:= .T.           	
			    cAliasSD2	:=	GetNextAlias()      	           
		       	cCampo := "%"  
		       	cCampoCod:= "%" 
		       	If lCodSerSB1
		       		cCampo += ",SB1." + cCodSerSB1
		       		cCampoCod += "SB1." + cCodSerSB1 + " IN ('1000','1100','1300','1400','1500') AND "
		       	Endif
		    	cCampo += "%"
		    	cCampoCod+= "%"     		  		   	
		    	BeginSql Alias cAliasSD2
				COLUMN D2_EMISSAO AS DATE   
				SELECT %Exp:cCpoD2%
					   SB1.B1_DESC, SB1.B1_UM,SB1.B1_COD,SC6.C6_PRODUTO,SC6.C6_NUM,SC6.C6_ITEM,
				       SA1.A1_COD,SA1.A1_NOME,SA1.A1_EMAIL,SA1.A1_DDD,SA1.A1_TEL,SA1.A1_INSCR,SA1.A1_EST,SA1.A1_COD_MUN,SA1.A1_END,SA1.A1_MUN,
				       SA1.A1_CEP,SA1.A1_CONTATO,SA1.A1_LOJA,SA1.A1_CGC,SA1.A1_IPWEB,SA1.A1_HPAGE,SA1.A1_DTINIV,SA1.A1_DTFIMV,SF4.F4_CODIGO,
				       SF4.F4_CODPAG,SC6.C6_DESCRI,SF4.F4_PAGCOM
				       %Exp:cCampo%
				FROM %table:SD2% SD2
				JOIN %table:SB1% SB1 ON SB1.B1_COD = SD2.D2_COD AND SB1.%NotDel% 
				JOIN %table:SF4% SF4 ON SF4.F4_CODIGO = SD2.D2_TES AND SF4.%NotDel%
				JOIN %table:SA1% SA1 ON SA1.A1_COD = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA AND SA1.%NotDel%
				LEFT JOIN %table:SC6% SC6 ON SC6.C6_PRODUTO = SD2.D2_COD AND SC6.C6_NUM = SD2.D2_PEDIDO AND SC6.C6_ITEM = SD2.D2_ITEM AND SC6.%NotDel% 									
			  	WHERE SD2.D2_FILIAL = %xFilial:SD2% AND		                     
				      SD2.D2_EMISSAO >=%Exp:dDataDe% AND
	       			  SD2.D2_EMISSAO <=%Exp:dDataAte% AND				      
	 				  SD2.D2_TIPO <> 'D' AND
	 				  SD2.D2_TIPO <> 'B' AND
	 				  %Exp:cCampoCod%
					  SD2.%NotDel%        
				ORDER BY SA1.A1_CGC,1			 				  				  		            
	    	EndSql                      
 		Else	                  
	#ENDIF        
			cIndex	:= CriaTrab(NIL,.F.)
			cFiltro	:= "D2_FILIAL == '" + xFilial("SD2") + "' .AND. "
			cFiltro += "dtos(D2_EMISSAO) >= '"+dtos(dDataDe)+"' .AND. " 
			cFiltro += "dtos(D2_EMISSAO) <= '"+dtos(dDataAte)+"' .AND. "  
			cFiltro += "D2_TIPO <> 'D' .AND. D2_TIPO <> 'B'"
		    IndRegua (cAliasSD2, cIndex, SD2->(IndexKey ()),, cFiltro)
	  		nIndex := RetIndex(cAliasSD2)
		    
			#IFNDEF TOP
				dbSetIndex(cIndex+OrdBagExt())
			#ENDIF			
			dbSelectArea(cAliasSD2)
		    dbSetOrder(nIndex+1)
		 
	#IFDEF TOP
		Endif
	#ENDIF 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPara ambiente TOP, as tabelas abaixos estao no JOIN e o alias eh o mesmo da queryณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lTop
		cAliasSF4	:=	cAliasSD2
		cAliasSB1	:=	cAliasSD2
		cAliasSA1	:=	cAliasSD2
		cAliasSC6	:=  cAliasSD2
	Endif
        
	DbSelectArea (cAliasSD2)
	(cAliasSD2)->(DbGoTop ())

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGravacao registro Reg0000 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Reg0000(aWizard,@nReg0000)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAbertura dos Blocos 0,5 e 9  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Reg0001(!(cAliasSD2)->(EOF()))
	Reg5001(!(cAliasSD2)->(EOF()))
	Reg9001(!(cAliasSD2)->(EOF()))

	ProcRegua ((cAliasSD2)->(RecCount()))	   
    nPos  	:= 1
	While !(cAliasSD2)->(EOF())
   		cAntCCG := (cAliasSA1)->A1_CGC
   		cSer	:= ""
		If !lTop
			SB1->(dbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD))
			SA1->(dbSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
			SF4->(dbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
			SC6->(dbSeek(xFilial("SC6")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_PEDIDO+(cAliasSD2)->D2_ITEM))
   		Endif
   	    
   	    Reg0010(cAliasSA1,@nReg0010)  
   								
		While !(cAliasSD2)->(EOF()) .AND. cAntCCG == (cAliasSA1)->A1_CGC
			
	   		cCodserv  := Iif(lCodSerSB1,  (cAliasSB1)->(FieldGet(FieldPos(cCodSerSB1))) ,"")
			//ฺฤฤฤฤฤฤฤฤฟ
			//ณ5020    ณ
			//ภฤฤฤฤฤฤฤฤู
	
			If cSer <> cCodserv
				RecLock("SER",.T.)
				SER->SER_TPREG	:= "5020" 
				SER->SER_CNPJ	:= (cAliasSA1)->A1_CGC
				SER->SER_CODSER	:= cCodserv
				SER->(MsUnlock())
		        cSer:= cCodserv 
		        nReg5020++
	        Endif 
	  
		    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณDetalhamento das Saidas.                             ณ
		    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Do Case
			
				Case cCodserv == "1000" 	//Intermediacao Comercial	   		
			   		RecLock("COM",.T.)
					COM->COM_TPREG	:= "5030" 
					COM->COM_CNPJ	:= (cAliasSA1)->A1_CGC
					COM->COM_DOPER	:= (cAliasSD2)->D2_EMISSAO
					COM->COM_DOC	:= (cAliasSD2)->D2_DOC 
					COM->COM_PAGCO	:= (cAliasSF4)->F4_PAGCOM
					COM->COM_DESC   := IIF(!Empty((cAliasSC6)->C6_DESCRI),Alltrim((cAliasSC6)->C6_DESCRI),(cAliasSB1)->B1_DESC)
					COM->COM_UNID   := (cAliasSB1)->B1_UM
				   	COM->COM_QUANT  := Transform((cAliasSD2)->D2_QUANT,"@E 999,999.9999")
					COM->COM_VALUN  := (cAliasSD2)->D2_PRCVEN
					COM->COM_VALTOT := (cAliasSD2)->D2_TOTAL
					COM->COM_VALDES := Iif((cAliasSD2)->D2_DESC==0,Alltrim(Transform((cAliasSD2)->D2_DESC,"@E 999,999.99")),(cAliasSD2)->D2_DESC)
					COM->COM_CODPAG	:= (cAliasSF4)->F4_CODPAG
					COM->COM_UFCOMP := (cAliasSD2)->D2_EST
					COM->(MsUnlock())
					nReg5030++			   		
			   					   		
				Case cCodserv == "1100" //Hospedagem de Sites e Banco de Dados.
			   		RecLock("HOS",.T.)
					HOS->HOS_TPREG	:= "5040" 
					HOS->HOS_CNPJ	:= (cAliasSA1)->A1_CGC
					HOS->HOS_IPUSER	:= (cAliasSA1)->A1_IPWEB
					HOS->HOS_URL	:= (cAliasSA1)->A1_HPAGE
					HOS->HOS_DTIN	:= (cAliasSA1)->A1_DTINIV
					HOS->HOS_DTFIM  := (cAliasSA1)->A1_DTFIMV
					HOS->(MsUnlock())
					nReg5040++
				
				Case cCodserv == "1300" //Gataway de Pagamentos.
					RecLock("HOS",.T.)
					GAT->GAT_TPREG	:= "5050" 
					GAT->GAT_CNPJ	:= (cAliasSA1)->A1_CGC
					GAT->GAT_DTIN	:= (cAliasSA1)->A1_DTINIV
					GAT->GAT_DTFIM	:= (cAliasSA1)->A1_DTFIMV
					GAT->GAT_DTOPER	:= (cAliasSD2)->D2_EMISSAO
					GAT->GAT_CODPAG := (cAliasSF4)->F4_CODPAG   
					GAT->GAT_UFOPER	:= (cAliasSD2)->D2_EST
					GAT->(MsUnlock())
					nReg5050++  
					
				Case cCodserv == "1500" //Lojas Virtuais.
			       	RecLock("VIR",.T.)
					VIR->VIR_TPREG	:= "5060" 
					VIR->VIR_CNPJ	:= (cAliasSA1)->A1_CGC
					VIR->VIR_IPUSR	:= (cAliasSA1)->A1_IPWEB
					VIR->VIR_URL	:= (cAliasSA1)->A1_HPAGE
					VIR->VIR_DTINI	:= (cAliasSA1)->A1_DTINIV
					VIR->VIR_DTFIM := (cAliasSA1)->A1_DTFIMV
					VIR->VIR_DTOPER	:= (cAliasSD2)->D2_EMISSAO
					VIR->VIR_UFCOMP :=	(cAliasSD2)->D2_EST
					VIR->(MsUnlock())
					nReg5060++  

				Case cCodserv == "1400" //Itermediacao Financeira.
					RecLock("FIN",.T.)
					FIN->FIN_TPREG	:= "5070" 
					FIN->FIN_CNPJ	:= (cAliasSA1)->A1_CGC
					FIN->FIN_DTOPER	:= (cAliasSD2)->D2_EMISSAO
					FIN->FIN_NUMOP	:= (cAliasSD2)->D2_DOC
					FIN->FIN_DESC	:= IIF(!Empty((cAliasSC6)->C6_DESCRI),Alltrim((cAliasSC6)->C6_DESCRI),(cAliasSB1)->B1_DESC)
					If  !Empty((cAliasSD2)->D2_VCAT156)
						FIN->FIN_VALTOT := (cAliasSD2)->D2_VCAT156
					Else 
						FIN->FIN_VALTOT := (cAliasSD2)->D2_TOTAL 
					EndIf
					FIN->FIN_CODPAG	:= (cAliasSF4)->F4_CODPAG
					FIN->FIN_UFCOMP := (cAliasSD2)->D2_EST 
					FIN->(MsUnlock())
					nReg5070++ 	
				EndCase	  
		   		(cAliasSD2)->(DbSkip())
   		EndDo
   	
	Enddo
	#IFDEF TOP
		If (TcSrvType ()<>"AS/400")
			DbSelectArea (cAliasSD2)
			(cAliasSD2)->(DbCloseArea ())
		Else
	#ENDIF
			RetIndex("SD2")
			FErase(cIndex+OrdBagExt ())
	#IFDEF TOP
		EndIf
	#ENDIF
	
	SM0->(DbSkip())    
	
EndDo
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEncerramentos   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Reg0990(nReg0000,nReg0001,nReg0010,nReg0990) 

Reg5990(nReg5001,nReg5020,nReg5030,nReg5040,nReg5050,nReg5060,nReg5070,nReg5990)

Reg9900({{"0000",nReg0000},;
{"0001",nReg0001},;
{"0010",nReg0010},;
{"0990",nReg0990},;
{"5001",nReg5001},;
{"5020",nReg5020},;
{"5030",nReg5030},;
{"5040",nReg5040},;
{"5050",nReg5050},;
{"5060",nReg5060},;
{"5070",nReg5070},;
{"5990",nReg5990},;
{"9001",nReg9001}},@nReg9900) 
                   
Reg9900({{"9900",nReg9900}},@nReg9900) 

nReg9990:= Reg9990(nReg9001+(nReg9900-1)+nReg9990)

Reg9999(nReg0000+nReg0001+nReg0010+nReg0990+nReg5001+nReg5020+nReg5030+nReg5040+nReg5050+nReg5060+nReg5070+nReg5990+nReg9001+nReg9990)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravacao do TXT ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GeraReg(,cFileDest)		
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//|Apaga arquivos temporarios    ณ  
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
CatDelArq(aArq)

Return (.T.)
			
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg0000   บAutor  ณNatalia Antonucci   บ Data ณ  27/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abertura do arquivo digital e identificacao do contribuinteบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ0 - um por arquivo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reg0000(aWizard,nReg0000)

RecLock("EMP",.T.)
EMP->EMP_TPREG	:= "0000" 
EMP->EMP_ECOMM	:= "ECOMM"
EMP->EMP_VERSAO	:=	SubStr(aWizard[1][2],1,3)
EMP->EMP_PERIOD	:=	SubStr(aWizard[1][1],1,6) 
EMP->EMP_NOME	:= SM0->M0_NOMECOM
EMP->EMP_CNPJ   := ConvType(VldIE(Iif (RetPessoa(SM0->M0_CGC) == "J", SM0->M0_CGC, "")))
EMP->EMP_IE     := ConvType(VldIE(SM0->M0_INSC,.F.,.F.))
EMP->EMP_CODMUN := Iif (Upper(SM0->M0_ESTENT) == "EX","",Iif(Len(Alltrim(SM0->M0_CODMUN))<=5,UfCodIBGE(SM0->M0_ESTENT),"")+SM0->M0_CODMUN)
EMP->EMP_ENDER  := Alltrim(SM0->M0_ENDCOB)+" "+ AllTrim(SM0->M0_CIDCOB)+" "+SM0->M0_ESTCOB
EMP->EMP_CEP    := SM0->M0_CEPCOB
EMP->EMP_CONTA  := aWizard[1][5]
EMP->EMP_EMAIL	:= aWizard[1][6]
EMP->EMP_FONE   := aWizard[1][7]
EMP->(MsUnlock())
nReg0000++

Return (.T.)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg0001   บAutor  ณNatalia Antonucci   บ Data ณ  27/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abertura do Bloco 0                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ0 - um por arquivo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reg0001(lCont)  

RecLock("AB0",.T.)
AB0->AB0_TPREG	:= "0001" 
AB0->AB0_MOV	:= Iif(lCont,"0","1")
AB0->(MsUnlock())

Return (.T.)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg0990   บAutor  ณNatalia Antonucci   บ Data ณ  27/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Encerramento do Bloco 0                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ0 - um por arquivo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reg0990(nReg0000,nReg0001,nReg0010,nReg0990)  

RecLock("EN0",.T.)
EN0->EN0_TPREG	:= "0990" 
EN0->EN0_LINHA	:= str(nReg0000+nReg0001+nReg0010+nReg0990)
EN0->(MsUnlock())

Return (.T.) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg5001   บAutor  ณNatalia Antonucci   บ Data ณ  27/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abertura do Bloco 5                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ0 - um por arquivo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reg5001(lCont)  

RecLock("AB5",.T.)
AB5->AB5_TPREG	:= "5001" 
AB5->AB5_MOV	:= Iif(lCont,"0","1")
AB5->(MsUnlock())

Return (.T.) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg0010   บAutor  ณNatalia Antonucci   บ Data ณ  27/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTabela de cliente.			                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ2 - varios por arquivo                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Reg0010 (cAliasSA1,nReg0010) 

RecLock("CLI",.T.)
CLI->CLI_TPREG	:= "0010" 
CLI->CLI_NOME	:= (cAliasSA1)->A1_NOME
CLI->CLI_CNPJ	:= (cAliasSA1)->A1_CGC
CLI->CLI_IE		:= (cAliasSA1)->A1_INSCR
CLI->CLI_CODMUN	:= IIf(Upper((cAliasSA1)->A1_EST)<>"SP","",Iif(Len(Alltrim((cAliasSA1)->A1_COD_MUN))<=5,UfCodIBGE((cAliasSA1)->A1_EST),"")+(cAliasSA1)->A1_COD_MUN)
CLI->CLI_ENDER  := AllTrim((cAliasSA1)->A1_END)+" "+AllTrim((cAliasSA1)->A1_MUN)+" "+(cAliasSA1)->A1_EST
CLI->CLI_CEP   	:= IIf(Upper((cAliasSA1)->A1_EST)<>"SP","",(cAliasSA1)->A1_CEP)
CLI->CLI_CONTA  := (cAliasSA1)->A1_CONTATO
CLI->CLI_EMAIL  := (cAliasSA1)->A1_EMAIL
CLI->CLI_FONE	:= AllTrim((cAliasSA1)->A1_DDD)+AllTrim((cAliasSA1)->A1_TEL)
CLI->CLI_URL  	:= (cAliasSA1)->A1_HPAGE
CLI->(MsUnlock())
nReg0010++ 
         
Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg5990   บAutor  ณNatalia Antonucci   บ Data ณ  27/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Encerramento do Bloco 5                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ0 - um por arquivo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reg5990(nReg5001,nReg5020,nReg5030,nReg5040,nReg5050,nReg5060,nReg5070,nReg5990)  

RecLock("EN5",.T.)
EN5->EN5_TPREG	:= "5990" 
EN5->EN5_LINHA	:= STR(nReg5001+nReg5020+nReg5030+nReg5040+nReg5050+nReg5060+nReg5070+nReg5990)
EN5->(MsUnlock())

Return (.T.) 
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg9001   บAutor  ณNatalia Antonucci   บ Data ณ  27/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abertura do Bloco 9                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ0 - um por arquivo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reg9001(lCont)  

RecLock("AB9",.T.)
AB9->AB9_TPREG	:= "9001" 
AB9->AB9_MOV	:= Iif(lCont,"0","1")
AB9->(MsUnlock())

Return (.T.) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg9990   บAutor  ณNatalia Antonucci   บ Data ณ  27/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Encerramento do bloco 9                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ0 - um por arquivo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reg9990(nReg9990)  

RecLock("EN9",.T.)
EN9->EN9_TPREG	:= "9990" 
EN9->EN9_LINHA	:= STR(nReg9990)
EN9->(MsUnlock())

Return (nReg9990)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg9900   บAutor  ณNatalia Antonucci   บ Data ณ  27/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Registro do Arquivo                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ0 - um por arquivo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reg9900(aReg,nReg9900)  

Local nX  := 0  

For nX:= 1 to Len(aReg)
	If aReg[nX][2] > 0
		RecLock("RAR",.T.)
		RAR->RAR_TPREG	:= "9900" 
		RAR->RAR_BLC	:= aReg[nX][1] 
		RAR->RAR_REGBLC := STR(aReg[nX][2]) 
		RAR->(MsUnlock())
		nReg9900++ 
	Endif                                    
Next nX            

Return (.T.)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg9990   บAutor  ณNatalia Antonucci   บ Data ณ  27/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Encerramento do Arquivo Digital                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ0 - um por arquivo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reg9999(nReg9999)


RecLock("ENC",.T.)
ENC->ENC_TPREG	:= "9999" 
ENC->ENC_LINHA	:= str(nReg9999)
ENC->(MsUnlock())

Return (.T.)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraTrb   บAutor  ณNatalia Antonucci   บ Data ณ  27/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGeracao da estrutura do TRB                                 บฑฑ
ฑฑบ          ณGeracao da estrutura do TRB utilizado em todo processamento บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet -> .T.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณArq   -> Nome fisico do TRB criado 		                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                           
Static Function GeraArq(aArq)

Local	aCmp	:=	{}
Local	cArq	:=	""  

aCmp	:=	{}
aAdd (aCmp, {"EMP_TPREG",	"C", 	004,	   							0})
aAdd (aCmp, {"EMP_ECOMM",	"C", 	005,								0}) 
aAdd (aCmp, {"EMP_VERSAO",	"C", 	003,			 					0}) 
aAdd (aCmp, {"EMP_PERIOD",	"C", 	006,			 					0})
aAdd (aCmp, {"EMP_NOME",	"C", 	999,			 					0})     
aAdd (aCmp, {"EMP_CNPJ",	"C", 	014,			 					0})
aAdd (aCmp, {"EMP_IE",		"C", 	014,			 					0})  
aAdd (aCmp, {"EMP_CODMUN",	"C", 	999,			 					0})
aAdd (aCmp, {"EMP_ENDER",	"C", 	999,			  					0})  
aAdd (aCmp, {"EMP_CEP",		"C", 	008,			  			  		0})
aAdd (aCmp, {"EMP_CONTA",	"C", 	999,			  			  		0})
aAdd (aCmp, {"EMP_EMAIL",	"C", 	999,			  			  		0})
aAdd (aCmp, {"EMP_FONE",	"C", 	999,			  					0})   
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, "EMP")
IndRegua ("EMP", cArq, "EMP_CNPJ")
aAdd (aArq, {"EMP", cArq}) 

aCmp	:=	{}
aAdd (aCmp, {"AB0_TPREG",	"C", 	004,	   							0})
aAdd (aCmp, {"AB0_MOV",		"C", 	001,			 					0}) 
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, "AB0")
IndRegua ("AB0", cArq, "AB0_TPREG")
aAdd (aArq, {"AB0", cArq}) 

aCmp	:=	{}
aAdd (aCmp, {"CLI_TPREG",	"C", 	004,   								0})
aAdd (aCmp, {"CLI_NOME",	"C", 	TamSX3("A1_NOME")[1],				0}) 
aAdd (aCmp, {"CLI_CNPJ",	"C", 	TamSX3("A1_CGC")[1],				0}) 
aAdd (aCmp, {"CLI_IE",		"C", 	TamSX3("A1_INSCR")[1],				0})
aAdd (aCmp, {"CLI_CODMUN",	"C", 	TamSX3("A1_COD_MUN")[1]+2,			0})     
aAdd (aCmp, {"CLI_ENDER",	"C", 	TamSX3("A1_END")[1],				0})
aAdd (aCmp, {"CLI_CEP",		"C", 	008,								0})  
aAdd (aCmp, {"CLI_CONTA",	"C", 	TamSX3("A1_CONTATO")[1],			0})
aAdd (aCmp, {"CLI_EMAIL",	"C", 	TamSX3("A1_EMAIL")[1],				0})
aAdd (aCmp, {"CLI_FONE",	"C", 	011,   								0})  
aAdd (aCmp, {"CLI_URL",		"C", 	TamSX3("A1_HPAGE")[1],				0})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, "CLI")
IndRegua ("CLI", cArq, "CLI_CNPJ")
aAdd (aArq, {"CLI", cArq})  

aCmp	:=	{}
aAdd (aCmp, {"EN0_TPREG",	"C", 	004,	   							0})
aAdd (aCmp, {"EN0_LINHA",	"C", 	999,								0}) 
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, "EN0")
IndRegua ("EN0", cArq, "EN0_TPREG")
aAdd (aArq, {"EN0", cArq}) 

aCmp	:=	{}
aAdd (aCmp, {"AB5_TPREG",	"C", 	004,	   		   					0})
aAdd (aCmp, {"AB5_MOV",		"C", 	001,			   					0}) 
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, "AB5")
IndRegua ("AB5", cArq, "AB5_TPREG")
aAdd (aArq, {"AB5", cArq}) 

aCmp	:=	{}
aAdd (aCmp, {"SER_TPREG",	"C", 	004,	   		   					0})
aAdd (aCmp, {"SER_CNPJ",	"C", 	TamSX3("A1_CGC")[1],				0}) 
aAdd (aCmp, {"SER_CODSER",	"C", 	004,								0})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, "SER")
IndRegua ("SER", cArq, "SER_CNPJ+SER_CODSER")
aAdd (aArq, {"SER", cArq})

aCmp	:=	{}
aAdd (aCmp, {"COM_TPREG",	"C", 	004,	   		   					0})
aAdd (aCmp, {"COM_CNPJ",	"C", 	TamSX3("A1_CGC")[1],				0}) 
aAdd (aCmp, {"COM_DOPER",	"D", 	TamSX3("D2_EMISSAO")[1],			0})
aAdd (aCmp, {"COM_DOC",		"C", 	TamSX3("A1_CGC")[1],				0})     
aAdd (aCmp, {"COM_PAGCO",	"C", 	TamSX3("F4_PAGCOM")[1],				0})
aAdd (aCmp, {"COM_DESC",	"C", 	TamSX3("B1_DESC")[1],				0})  
aAdd (aCmp, {"COM_UNID",	"C", 	TamSX3("B1_UM")[1],			 		0})
aAdd (aCmp, {"COM_QUANT",	"C", 	TamSX3("D2_QUANT")[1],				4})  
aAdd (aCmp, {"COM_VALUN",	"N", 	TamSX3("D2_PRCVEN")[1],				2})
aAdd (aCmp, {"COM_VALTOT",	"N", 	TamSX3("D2_TOTAL")[1],				2})
aAdd (aCmp, {"COM_VALDES",	"C", 	TamSX3("D2_DESC")[1],				2})
aAdd (aCmp, {"COM_CODPAG",	"C", 	TamSX3("F4_CODPAG")[1],				0}) 
aAdd (aCmp, {"COM_UFCOMP",	"C", 	TamSX3("D2_EST")[1],				0})    
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, "COM")
IndRegua ("COM", cArq, "COM_DOC+COM_DESC")
aAdd (aArq, {"COM", cArq})
                                 
aCmp	:=	{}
aAdd (aCmp, {"HOS_TPREG",	"C", 	004,	   		   					0})
aAdd (aCmp, {"HOS_CNPJ",	"C", 	TamSX3("A1_CGC")[1],				0}) 
aAdd (aCmp, {"HOS_IPUSER",	"C", 	TamSX3("A1_IPWEB")[1],				0}) 
aAdd (aCmp, {"HOS_URL",		"C", 	TamSX3("A1_HPAGE")[1],				0})
aAdd (aCmp, {"HOS_DTIN",	"C",   	008,		   						0})  
aAdd (aCmp, {"HOS_DTFIM",	"C",   	008,		  						0})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, "HOS")
IndRegua ("HOS", cArq, "HOS_CNPJ")
aAdd (aArq, {"HOS", cArq})  

aCmp	:=	{}
aAdd (aCmp, {"GAT_TPREG",	"C", 	004,	   		  					0})
aAdd (aCmp, {"GAT_CNPJ",	"C", 	TamSX3("A1_CGC")[1],				0}) 
aAdd (aCmp, {"GAT_DTIN",	"C", 	008,		   						0})
aAdd (aCmp, {"GAT_DTFIM",	"C", 	008,		   						0})     
aAdd (aCmp, {"GAT_DTOPER",	"D", 	TamSX3("A1_DTFIMV")[1],				0})
aAdd (aCmp, {"GAT_CODPAG",	"C", 	TamSX3("F4_CODPAG")[1],				0})
aAdd (aCmp, {"GAT_UFOPER",	"C", 	TamSX3("D2_EST")[1],				0})    
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, "GAT")
IndRegua ("GAT", cArq, "GAT_CNPJ")
aAdd (aArq, {"GAT", cArq}) 

aCmp	:=	{}
aAdd (aCmp, {"VIR_TPREG",	"C", 	004,	   		   					0})
aAdd (aCmp, {"VIR_CNPJ",	"C", 	TamSX3("A1_CGC")[1],				0}) 
aAdd (aCmp, {"VIR_IPUSR",	"C", 	TamSX3("A1_IPWEB")[1],				0})
aAdd (aCmp, {"VIR_URL",		"C", 	TamSX3("A1_HPAGE")[1],				0})     
aAdd (aCmp, {"VIR_DTINI",	"C", 	008,	 	   				     	0})
aAdd (aCmp, {"VIR_DTFIM",	"C",	008,		   	                    0})
aAdd (aCmp, {"VIR_DTOPER",	"D", 	TamSX3("D2_EMISSAO")[1],			0}) 
aAdd (aCmp, {"VIR_UFCOMP",	"C", 	TamSX3("D2_EST")[1],				0})      
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, "VIR")
IndRegua ("VIR", cArq, "VIR_CNPJ")
aAdd (aArq, {"VIR", cArq})

aCmp	:=	{}
aAdd (aCmp, {"FIN_TPREG",	"C", 	004,	   		   					0})
aAdd (aCmp, {"FIN_CNPJ",	"C", 	TamSX3("A1_CGC")[1],				0})  
aAdd (aCmp, {"FIN_DTOPER",	"D", 	TamSX3("D2_EMISSAO")[1],			0})
aAdd (aCmp, {"FIN_NUMOP",	"C", 	TamSX3("D2_DOC")[1],				0})
aAdd (aCmp, {"FIN_DESC",	"C", 	TamSX3("B1_DESC")[1],				0}) 
aAdd (aCmp, {"FIN_VALTOT",	"N", 	TamSX3("D2_TOTAL")[1],				2}) 
aAdd (aCmp, {"FIN_CODPAG",	"C", 	TamSX3("F4_CODPAG")[1],				0}) 
aAdd (aCmp, {"FIN_UFCOMP",	"C", 	TamSX3("D2_EST")[1],				0})        
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, "FIN")
IndRegua ("FIN", cArq, "FIN_NUMOP+FIN_DESC")
aAdd (aArq, {"FIN", cArq})

aCmp	:=	{}
aAdd (aCmp, {"EN5_TPREG",	"C", 	004,	   		  					0})
aAdd (aCmp, {"EN5_LINHA",	"C", 	999,			  					0}) 
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, "EN5")
IndRegua ("EN5", cArq, "EN5_TPREG")
aAdd (aArq, {"EN5", cArq}) 

aCmp	:=	{}
aAdd (aCmp, {"AB9_TPREG",	"C", 	004,	   		  					0})
aAdd (aCmp, {"AB9_MOV",		"C", 	001,			   					0}) 
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, "AB9")
IndRegua ("AB9", cArq, "AB9_TPREG")
aAdd (aArq, {"AB9", cArq})

aCmp	:=	{}
aAdd (aCmp, {"RAR_TPREG",	"C", 	004,	   		   					0})
aAdd (aCmp, {"RAR_BLC",		"C", 	004,			   					0}) 
aAdd (aCmp, {"RAR_REGBLC",	"C", 	999,			  					0}) 
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, "RAR")
IndRegua ("RAR", cArq, "RAR_TPREG")
aAdd (aArq, {"RAR", cArq})

aCmp	:=	{}
aAdd (aCmp, {"EN9_TPREG",	"C", 	004,	   		   					0})
aAdd (aCmp, {"EN9_LINHA",	"C", 	999,			   					0}) 
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, "EN9")
IndRegua ("EN9", cArq, "EN9_TPREG")
aAdd (aArq, {"EN9", cArq}) 

aCmp	:=	{}
aAdd (aCmp, {"ENC_TPREG",	"C", 	004,	   		  					0})
aAdd (aCmp, {"ENC_LINHA",	"C", 	999,			  					0}) 
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, "ENC")
IndRegua ("ENC", cArq, "ENC_TPREG")
aAdd (aArq, {"ENC", cArq})  
  

Return .T.

 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraReg   บ Autor ณ Natalia Antonucci  บ Data ณ  27/08/12	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRecebe, transforma e retorna a string no formato exigido    บฑฑ
ฑฑบ          ณGrava็ใo do TXT                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcFileDest -> Arquivo Destino                                บฑฑ
ฑฑบ          ณnDec   -> Quantidade de decimais para valores numericos     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeraReg(nDec,cFileDest)

Local cLinha := ""
Local nX := 0  
Local nY := 0  
                                                 
If (File(cFileDest))		
	FErase(cFileDest)
Endif
nHandle	:=	MsFCreate(cFileDest)

default nDec := 2

For nX:=1 to 16
    Do Case
    	Case nX == 1
  	   		dbSelectArea("EMP") 
  		Case nX == 2
  	   		dbSelectArea("AB0") 
  		Case nX == 3
  	   		dbSelectArea("CLI")
  		Case nX == 4
  	   		dbSelectArea("EN0")
  		Case nX == 5
  	   		dbSelectArea("AB5")
  		Case nX == 6
  	   		dbSelectArea("SER") 
  		Case nX == 7
  	   		dbSelectArea("COM") 
  		Case nX == 8
  	   		dbSelectArea("HOS") 
  	 	Case nX == 9
  	   		dbSelectArea("GAT")   
  		Case nX == 10
  	   		dbSelectArea("VIR") 
  		Case nX == 11
  	   		dbSelectArea("FIN")
  		Case nX == 12
  	   		dbSelectArea("EN5")
  		Case nX == 13
  	   		dbSelectArea("AB9")
  		Case nX == 14
  	   		dbSelectArea("RAR") 
  		Case nX == 15
  	   		dbSelectArea("EN9") 
  		Case nX == 16
  	   		dbSelectArea("ENC")
	EndCase
	dbGoTop()
	
	While !eof() 
  		cLinha := ""
		For nY:=1 to FCOUNT()             
			If (ValType(FIELDGET(nY))=="N")
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณTodas as variaveis numericas que nao tiverem definicao de casas decimais     |
				//ณserao convertidas para apresentarem 2 decimais                               ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If (FIELDGET(nY)==0)
					cLinha	+=	"0"+"|"
				Else
					cLinha	+=	AllTrim (StrTran (Str (FIELDGET(nY),,nDec), ".", ","))+"|"
				EndIf
			ElseIf (ValType(FIELDGET(nY))=="C") 
				cLinha	+=	AllTrim (FIELDGET(nY))+"|"
			ElseIf (ValType(FIELDGET(nY))=="D")
				cLinha	+=	StrZero (Day (FIELDGET(nY)), 2)+StrZero (Month (FIELDGET(nY)), 2)+StrZero (Year (FIELDGET(nY)), 4)+"|"
			Else
				cLinha	+=	""                   
			EndIf
			
		Next nY   
		cLinha	:= substr(cLinha,1,len(cLinha)-1)+Chr (13)+Chr (10)
  		FWrite (nHandle, cLinha, Len (cLinha))
		dbskip()
	Enddo	 
	
	dbCloseArea()
	 
Next nX
If (nHandle>=0)
	FClose(nHandle)
Endif 

Return (cLinha)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontWiz   บAutor  ณVitor Felipe        บ Data ณ  12/04/11	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o Wizard da rotina.                                  บฑฑ
ฑฑบ          ณ Retorna .T. se finalizado com sucesso                      บฑฑ
ฑฑบ          ณ Retorna .F. se foi cancelado                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontWiz(cNomWiz)
Local	aTxtApre	:=	{}
Local	aPaineis	:=	{}
Local	cTitObj1	:=	""
Local	cTitObj2	:=	""
Local	lRet		:=	.T.

//ฺฤฤฤฤฤฤฤฤฟ
//ณPainel 0ณ
//ภฤฤฤฤฤฤฤฤู
aAdd (aTxtApre, "Parโmetros necessแrios.")
aAdd (aTxtApre, "")
aAdd (aTxtApre, "Preencha corretamente as informa็๕es solicitadas.")
aAdd (aTxtApre, "Informa็๕es necessแrias para a gera็ใo do meio-magn้tico CAT156.")

//ฺฤฤฤฤฤฤฤฤฟ
//ณPainel 1ณ
//ภฤฤฤฤฤฤฤฤู
aAdd (aPaineis, {})
nPos	:=	Len (aPaineis)
aAdd (aPaineis[nPos], "Preencha corretamente as informa็๕es solicitadas.")
aAdd (aPaineis[nPos], "Parโmetros para Gera็ใo")
aAdd (aPaineis[nPos], {})

cTitObj1	:=	"Trimestre/Ano de referencia (TTAAAA)";				cTitObj2	:=	"Versao Leiaute"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})

cTitObj1	:=	Replicate ("X", 6);									cTitObj2	:=	Replicate ("X", 3)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,6});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,3})

aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})   
//
cTitObj1	:=	"Diret๓rio do Arquivo Destino";						cTitObj2	:=	"Nome do Arquivo Destino"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", 50);								cTitObj2	:=	Replicate ("X", 20)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Nome do Responsแvel";								cTitObj2	:=  "E-mail do Responsแvel"	
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", 50);									cTitObj2	:=	Replicate ("X", 50)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,50})
//                                                                                                          
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Telefone do Responsแvel"							
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	Replicate ("X", 20)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,20});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Filial de"; 										cTitObj2	:=	"Filial ate"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", 8);									cTitObj2	:=	Replicate ("X", 8)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,20});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//

cTitObj1	:=	"Seleciona Filiais ?";								cTitObj2	:=	"Aglutina sele็ใo por CNPJ+I.E. ?"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
aAdd (aPaineis[nPos][3], {3,,,,,{"1 - Sim","2 - Nใo"},,,,,});  		aAdd (aPaineis[nPos][3], {3,,,,,{"1 - Sim","2 - Nใo"},,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});  							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//

lRet	:=	xMagWizard (aTxtApre, aPaineis, cNomWiz)
Return (lRet) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณConvType  บAutor  ณVitor Felipe        บ Data ณ  12/04/11	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento de caracteres especiais copiadas do NFESEFAZ     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ConvType(xValor,nTam)
Local cNovo := ""

If nTam==Nil
	xValor := AllTrim(xValor)
EndIf

Default nTam := 60
cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
Return(cNovo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldIE     บAutor  ณVitor Felipe        บ Data ณ  12/04/11	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida Incricao Estadual e CGC                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldIE(cInsc,lContr,lIsent)
Local 		cRet	:=	""
Local 		nI		:=	1
Default 	lContr  :=	.T.
Default		lIsent	:=	.T.

For nI:=1 To Len(cInsc)
	If Isdigit(Subs(cInsc,nI,1)) .Or. IsAlpha(Subs(cInsc,nI,1))
		cRet+=Subs(cInsc,nI,1)
	Endif
Next
cRet := AllTrim(cRet)

If lIsent
	If "ISENT"$Upper(cRet)
		cRet := ""
	EndIf
	If !(lContr) .And. !Empty(cRet)
		cRet := "ISENTA"
	EndIf
EndIf
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNoAcento  บAutor  ณVitor Felipe        บ Data ณ  12/04/11	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tratamento para Acentos                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "แ้ํ๓๚"+"มษอำฺ"
Local cCircu := "โ๊๎๔๛"+"ยสฮิÛ"
Local cTrema := "ไ๋๏๖ü"+"ฤหฯึÜ"
Local cCrase := "เ่์๒๙"+"ภศฬาู" 
Local cTio   := "ใ๕"
Local cCecid := "็ว"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next                                                                                                                                                      
For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123 .Or. cChar $ '&'
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
cString := _NoTags(cString)
Return cString


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao   ณCatDelArq  บAutor  ณ Natalia Antonucci  บ Data ณ  27/08/12   บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณ Apaga arquivos temporarios criados para gerar o arquivo     บฑฑ
ฑฑบ         ณ Magnetico                                                   บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ CAT156                                                      บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CatDelArq(aDelArqs)

Local aAreaDel := GetArea()
Local nI := 0

For nI:= 1 To Len(aDelArqs)
	If File(aDelArqs[ni,1]+GetDBExtension())
		If !Empty (aDelArqs[ni,2]) .And. Select(aDelArqs[ni,2]) > 0
			dbSelectArea(aDelArqs[ni,2])
			dbCloseArea()
			Ferase(aDelArqs[ni,1]+GetDBExtension())
			Ferase(aDelArqs[ni,1]+OrdBagExt())
		Endif
	Endif
Next

RestArea(aAreaDel)

Return

