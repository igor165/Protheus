 #include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSR475
Relatorio de Produtos coletivo empresarial ou empresário individual

@author  Totvs
@version P12
@since   29/03/2018
/*/
//-------------------------------------------------------------------  

 
Function PLSR475()

Private  cTitulo   		:= "Relatorio de Produtos coletivo empresarial ou empresário individual"
                                              
RptStatus({|lEnd| Impr475Rel()},cTitulo)
 
Return 
 
Static Function Impr475Rel()
 
private	aParambox	:=	{}
private	aRet		:= {}
private 	cAliasTrb := "TRB"
 

 
aadd(aParamBox, {1, "Produto De"				,Space(12) ,"@!",""                           ,""		,""		,50	,.F.})     
aadd(aParamBox, {1, "Produto Ate"				,Space(12)	,"@!",""										,""		,""		,50	,.T.})
aAdd(aParamBox, {3, "Empreend.Individual:"	,1, {"1-Sim","2-Nâo","3-Ambos"},65,"",.T.,})
                                                                                                                                     
if paramBox(aParambox, "Parâmetros"	, @aRet, , , .T. /*lCentered*/, 0, 0, , , .T. /*lCanSave*/, .T. /*lUserSave*/)
  	cursorWait() //Mostra Ampulheta
	MsAguarde({||  SelDadosRel()  }, "Aguarde...", "Em Processamento...")
  	cursorArrow() //Libera Ampulheta	 
Endif 
 
 
Return



/*
{Protheus.doc} SelDados 
Seleciona Dados
@class N/A
@from  N/A
@param N/A
@attrib N/A
@protected 
@author TOTVS
@version 12.17
@since 07/03/2018
@return N/A
@sample SelDados
@obs N/A
@project 
@menu N/A
@history N/A
*/ 
Function SelDadosRel() 

Local	cEmpInd		:=""
Local	cQuery			:=""
Local	lAbortPrint	:= .F.
Local	nLimite		:= 80
Local 	li 				:= 60
Local  wnrel
Local  cString  		:= "BI3"
Local  cNomeProg 		:= "PLSR475"                               
Local  cTamanho 		:= "M"
Local 	cNtaJco		:= ""
Local  lTitulo		:= .F.
 
PRIVATE aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }

m_pag	:= 1

 
 wnrel:=SetPrint(cString,cNomeProg,"",@cTitulo,"", "", "",.F.,.F.,.F.,cTamanho,,.F.)
 
 SetDefault(aReturn,cString)
 

If aRet[3]=1
	cEmpInd:='1'
ElseIf aRet[3]=2
	cEmpInd:='2'
Endif	


cQuery += " SELECT " + CRLF 
cQuery += "     BI3_FILIAL,BT6_CODINT,BT6_CODIGO,BT6_NUMCON,BT6_VERCON,BT6_SUBCON,BT6_VERSUB,BT6_CODPRO,BT6_VERSAO,BI3_NREDUZ,BI3_EMPIND,BI3_NATJCO,BI3_CODIGO,BI3_VERSAO,BI3_NREDUZ,BG9_CODIGO,BG9_DESCRI,BQB_DATFIN   " + CRLF 
cQuery += "  FROM " + RetSqlName("BI3") + "  ,"+ RetSqlName("BT6") + ",  "+ RetSqlName("BG9") + ",  "+ RetSqlName("BQB") + "  " + CRLF 
cQuery += " WHERE BI3_FILIAL	= '" + xFilial ("BI3") + "' " + CRLF 
cQuery += "   AND BT6_FILIAL	= '" + xFilial ("BT6") + "' " + CRLF
cQuery += "   AND BG9_FILIAL	= '" + xFilial ("BG9") + "' " + CRLF
cQuery += "   AND BT6_CODPRO    BETWEEN '" + aRet[1] + "' AND '" + aRet[2] + "' " + CRLF


cQuery += "   AND BT6_CODPRO	= BI3_CODIGO " + CRLF 
cQuery += "   AND BT6_VERSAO	= BI3_VERSAO " + CRLF
cQuery += "   AND BT6_CODINT	= BI3_CODINT " + CRLF
If aRet[3] <>  3
	cQuery += "   AND BI3_EMPIND	= '" + cEmpInd + "' " + CRLF
Endif	
//*******************************//--tratamento sql/oracle

cQuery += "   AND BT6_CODINT = BG9_CODINT " + CRLF
cQuery += "   AND BT6_CODIGO = BG9_CODIGO " + CRLF


cQuery += "   AND BQB_FILIAL	= '" + xFilial ("BQB") + "' " + CRLF

if AllTrim(TcGetDB()) $ "DB2/ORACLE"
	cQuery += "   AND BQB_CODIGO		=  BT6_CODINT||BT6_CODIGO  " + CRLF
Else
	cQuery += "   AND BQB_CODIGO		=  BT6_CODINT+BT6_CODIGO  " + CRLF
Endif	
cQuery += "   AND BQB_NUMCON =  BT6_NUMCON " + CRLF		
cQuery += "   AND BQB_VERSAO =  BT6_VERCON " + CRLF
	



cQuery += "   AND "+RetSqlName("BI3")+".D_E_L_E_T_ = ' ' " + CRLF 
cQuery += "   AND "+RetSqlName("BT6")+".D_E_L_E_T_ = ' ' " + CRLF
cQuery += "   AND "+RetSqlName("BG9")+".D_E_L_E_T_ = ' ' " + CRLF
cQuery += "   AND "+RetSqlName("BQB")+".D_E_L_E_T_ = ' ' " + CRLF
cQuery += " ORDER BY BT6_CODINT,BT6_CODPRO,BT6_VERSAO,BT6_CODIGO,BT6_NUMCON,BT6_VERCON,BT6_SUBCON,BT6_VERSUB " + CRLF
cQuery := ChangeQuery(cQuery)

//----------------------------------------------------------------
// Pega uma sequencia de alias para o temporario.               
//----------------------------------------------------------------

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTrb, .F., .T.)
dbSelectArea(cAliasTrb)
(cAliasTrb)->(dbGoTop())
 


While !(cAliasTrb)->( Eof() )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se foi abortada a impressao...                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If Interrupcao(lAbortPrint)
		@ ++Li, 00 pSay "******** Impressao abortada pelo operador ********" 
		Exit
	Endif

   If li > 58
		cabec(cTitulo,'','',cNomeProg,cTamanho,GetMv("MV_COMP"))
		lTitulo := .T.
		li := 5
	EndIf

    MsProcTxt("Produto "+" - "+(cAliasTrb)->BI3_CODIGO)
    
    cProdSaude:= (cAliasTrb)->BI3_CODIGO
    cCodGrupo	:= (cAliasTrb)->BG9_CODIGO
    cNtaJco	:= (cAliasTrb)->BI3_NATJCO
    
    li += 2
    @ li, 000 Psay "Produto : "+(cAliasTrb)->BI3_CODIGO+" - "+(cAliasTrb)->BI3_NREDUZ + Space(10)+ GetSx3Cache("BI3_NATJCO","X3_TITULO")+ ":  "+cNtaJco + space(10)+ GetSx3Cache("BI3_EMPIND","X3_TITULO")+ ":  " + iif((cAliasTrb)->BI3_EMPIND="1","Sim","Não") 
    
    While  (cAliasTrb)->BI3_CODIGO == cProdSaude
    
    	cCodGrupo	:= (cAliasTrb)->BG9_CODIGO
    	
    	If (cAliasTrb)->BI3_NATJCO = "2"
    		cNtaJco:='Fisica'
		ElseIf (cAliasTrb)->BI3_NATJCO = "3"
			cNtaJco:= 'Empresarial'
		ElseIf (cAliasTrb)->BI3_NATJCO = "4"
			cNtaJco:= 'Adesao'
		Else
			cNtaJco:= 'Beneficente' 
		Endif	
		
		While  cProdSaude == (cAliasTrb)->BI3_CODIGO .and. cCodGrupo	== (cAliasTrb)->BG9_CODIGO
			cCodContrat:= (cAliasTrb)->BT6_NUMCON
    		cVerContrat:= (cAliasTrb)->BT6_VERCON
    		cSubContrat:= (cAliasTrb)->BT6_SUBCON
    		cVerSubCont:= (cAliasTrb)->BT6_VERSUB
    		
    		li+=2
			@ li, 010 Psay "Grupo Empresa: "+(cAliasTrb)->BG9_CODIGO+" - "+Alltrim((cAliasTrb)->BG9_DESCRI)
    		

			While  cProdSaude ==(cAliasTrb)->BI3_CODIGO .and. cCodGrupo	== (cAliasTrb)->BG9_CODIGO 
				
			
			   If li > 58
   					li+=2
					@ Li, 010 pSAY REPLICATE("_", 122)
					cabec(cTitulo,'','',cNomeProg,cTamanho,GetMv("MV_COMP"))
					lTitulo := .T.
					li := 7
			       @ li, 000 Psay "Produto : "+(cAliasTrb)->BI3_CODIGO+" - "+BI3->BI3_NREDUZ + Space(10)+ GetSx3Cache("BI3_NATJCO","X3_TITULO")+ ":  "+cNtaJco + space(10)+ GetSx3Cache("BI3_EMPIND","X3_TITULO")+ ":  " + iif((cAliasTrb)->BI3_EMPIND="1","Sim","Não")
				Else
					li+=2
					@ li, 015 Psay "Contrato: "+(cAliasTrb)->BT6_NUMCON+" -  Versão: "+(cAliasTrb)->BT6_VERCON+ space(10)+ "Sub Contrato: "+(cAliasTrb)->BT6_SUBCON+" -  Versão: "+(cAliasTrb)->BT6_VERSUB+space(10)+ "Vigencia : " + dtoc(stod((cAliasTrb)->BQB_DATFIN )) 
				EndIf  
				(cAliasTrb)->( dbSkip() )
				
				If  !lTitulo .and. cProdSaude ==(cAliasTrb)->BI3_CODIGO .and. cCodGrupo	<> (cAliasTrb)->BG9_CODIGO
					li+=2
					@ Li, 010 pSAY REPLICATE("_", 122)
				Endif		   
				lTitulo := .F.
				
			Enddo
		Enddo
	Enddo
	li+=2
	@ Li, 000 pSAY REPLICATE("_", 132)				
Enddo



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime rodade padrao do produto Microsiga                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Roda(0,space(10),cTamanho)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera impressao                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  aReturn[5] == 1
    Set Printer To
    Ourspool(wnrel)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do Relat¢rio                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Return
                                      
                                  

 