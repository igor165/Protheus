#INCLUDE "Matr983.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATR983   º Autor ³ Angelica N. Rabelo º Data ³  19/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Demonstrativo das operacoes no periodo que originaram o    º±±
±±º          ³ calculo do valor do CRED. ICMS relativo a Oper. Propria    º±±
±±º          ³ do Substituo (art. 271 do RICMS/SP) 						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MATR983

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1       := STR0001			//"Este programa tem como objetivo imprimir relatorio "
Local cDesc2       := STR0002			//"de acordo com os parametros informados pelo usuario."
Local cDesc3       := STR0003   		//"Controle de crédito de ICMS não destacado"
Local cPict        := ""
Local titulo       := STR0003			//"Controle de crédito de ICMS não destacado"
Local nLin         := 80
Local Cabec1       := "------------------------------------------Registro de Saída--------------------------------------------------------------+-------------------------------Registro de Entrada-----------------------------------+--Apuração--
Local Cabec2       := "Emissão  Produto                          Quantidade Doc./Série    ClienteLj    Base Icms Alíq.  Estorno Deb   Valor ICMS|Digitac. Emissão    Quantidade Doc./Série    Fornec/Lj    Base Icms Alíq. Estorno Crd|  Crédito
Local Cabec3       := "------------------------------Registro de Saida----------------------------Documentos de Fornecedores Optantes do Simples Nacional-------------------------------Registro de Entrada---------------------------+--Apuração--
Local Cabec4       := "Emissão  Produto                          Quantidade Doc./Série    ClienteLj    Base Icms Alíq.  Estorno Deb   Valor ICMS|Digitac. Emissão    Quantidade Doc./Série    Fornec/Lj    Base Icms Alíq. Estorno Crd|Créd.Simples
//- -------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------+------------------------------
//- 				   99/99/99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 9.999.999,99 999999999/XXX XXXXXX/XX 9.999.999,99 99,99 9.999.999,99 9.999.999,99|99/99/99 99/99/99 9.999.999,99 999999999/XXX XXXXXX/XX 9.999.999,99 99,99 9999.999,99|9.999.999,99
//								 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22        23
//					   012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//- 						T O T A L   A P U R A Ç Ã O                                               9.999.999,99                    9.999.999,99|                                                           9.999.999,99        9.999.999,99|9.999.999,99
Local imprime      := .T.
Local aOrd         := {}
Local cErro        := STR0004	        //"Tabela CDM (Controle do Credito ICMS Nao Destacado) não foi encontrada no dicionário."
Local cSolucao     := STR0005           //"Esta tabela CDM é necessária para a geração da rotina, portanto será necessário efetuar os procedimentos destacados no boletim do compatibilizador UPDFIS que cria esta tabela e informa como alimentá-la em movimentações anteriores."	                        
Private lEnd       := .F.
Private lAbortPrint:= .F.
Private CbTxt      := ""
Private limite     := 220
Private tamanho    := "G"
Private nomeprog   := "MATR983" 
Private nTipo      := 15
Private aReturn    := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   := 0
Private cPerg      := "MTR983"
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "MTR983" 
Private cString    := "CDM"		 

pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RunReport(Cabec1,Cabec2,Cabec3,Cabec4,Titulo,nLin) },Titulo)            

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ 			         º Data ³  18/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Cabec3,Cabec4,Titulo,nLin)

Local cAlias      := "CDM"
Local cSimples	  := ""
Local nTotBsSaida := 0
Local nEstordeb   := 0  
Local nTotBsEnt   := 0 
Local nTotICMEnt  := 0
Local nTotICMSai  := 0 
Local nTotCredito := 0 
Local nBssai  := 0
Local nAlqsai := 0
Local nTotEstDeb := 0
Local nIcmsai := 0
Local nEstorn := 0
Local nAliqent:= 0
Local nBsent  := 0
Local nIcment := 0
Local cSelect := ""

#IFDEF TOP
	
	If (SerieNfId("CDM",3,"CDM_SERIES")<>"CDM_SERIES")
		cSelect:="%"+SerieNfId("CDM",3,"CDM_SERIES")+",%"
	Else
		cSelect:="%%"
	Endif
	
	If TcSrvType()<>"AS/400"							          		                             
    	lQuery   :=.T.   
       cAlias   := GetNextAlias()                                   
    	BeginSql Alias cAlias			
		SELECT CDM_FILIAL,CDM_DTSAI,CDM_DOCSAI,CDM_SERIES,CDM_NSEQS,CDM_FORNEC,CDM_LJFOR,CDM.R_E_C_N_O_ REGCDM   

    		FROM %Table:CDM% CDM
			WHERE CDM_FILIAL = %xFilial:CDM%
			AND CDM_DTSAI >= %Exp:mv_par01%
			AND CDM_DTSAI <= %Exp:mv_par02%
			AND CDM_TIPO IN('M','L','E','D') 
			AND CDM.%NotDel%
		ORDER BY CDM_FILIAL, CDM_DTSAI, CDM_DOCSAI, CDM_SERIES, CDM_NSEQS                        	             
		EndSql 

        dbSelectArea(cAlias)         
		 
	Else

           
#ENDIF                                                       
                     		
		cCDM    :=	CriaTrab(Nil,.F.)
	    cChave	:=  CDM->(IndexKey())		
		cCondicao 	:= "CDM_FILIAL == '" + xFilial("CDM") + "' .AND. "
		cCondicao 	+= "dtos(CDM_DTSAI) >= '"+DToS (mv_par01)+"' .AND. " 
		cCondicao 	+= "dtos(CDM_DTSAI) <= '"+DToS (mv_par02)+"' .AND. "
		cCondicao 	+= "CDM_TIPO $ 'MLED'"
	    IndRegua(cAlias,cCDM,cChave,,cCondicao)            
	    
		#IFNDEF TOP
			DbSetIndex(cCDM+OrdBagExt())
		#ENDIF     
		dbSelectarea(cAlias)           
		(cAlias)->(dbGotop())

#IFDEF TOP
    Endif    
#ENDIF 

ProcRegua(LastRec())                	           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetRegua(RecCount())
 
While (cAlias)->(!EOF())    
		
	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	SA2->(MsSeek(xFilial("SA2")+(cAlias)->CDM_FORNEC+(cAlias)->CDM_LJFOR))
				
	nLin := 80
	nTotBsSaida := 0
	nTotEstDeb 	:=0 
	nTotBsEnt   := 0
	nTotICMEnt  := 0
	nTotICMSai  := 0	    
	nTotCredito := 0
	cSimples := SA2->A2_SIMPNAC
	While (cAlias)->(!EOF()) .AND. SA2->A2_SIMPNAC == cSimples
		IncRegua()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If lAbortPrint		
			Exit
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			nLin := 1 + Cabec(Titulo,Iif(SA2->A2_SIMPNAC=="1",Cabec3,Cabec1),Iif(SA2->A2_SIMPNAC=="1",Cabec4,Cabec2),NomeProg,Tamanho,nTipo)
		Endif
	    #IFDEF TOP
			CDM->(dbGoTo((cAlias)->REGCDM))
		#ENDIF
	
	 
	   	If ( (SubStr(ALLTRIM(CDM->CDM_CFENT),1,4)$'1408/1409' .OR. SubStr(ALLTRIM(CDM->CDM_CFSAI),1,4)$'5408/5409') .AND. SuperGetMV("MV_ESTADO")==CDM->CDM_UFSAI ) .OR.;
	 	  ( SuperGetMV("MV_ESTADO")<>CDM->CDM_UFSAI  )
			nBssai	:= CDM->CDM_BSSAI
			nAlqsai := CDM->CDM_ALQSAI
			nEstordeb := CDM->CDM_ESTDEB
			nIcmsai := CDM->CDM_ICMSAI
			nEstorn := CDM->CDM_ESTORN
			nAliqent:= CDM->CDM_ALQENT
			nBsent  := CDM->CDM_BSENT
			nIcment := IIf(CDM->CDM_TIPO == 'D',0,(Iif(CDM->CDM_BASMAN = 0, CDM->CDM_ICMENT, CDM->CDM_BASMAN)))
		Else
			nBssai  := 0
			nAlqsai := 0
			nEstordeb := 0
			nIcmsai := 0
			nEstorn := 0
			nAliqent := 0
			nBsent  := 0
			nIcment := 0
		Endif

		//- ------------------------------Registro de Saida----------------------------Documentos de Fornecedores Optantes do Simples Nacional-------------------------------Registro de Entrada----------------------------+--Apuração--
		//-	Emissão  Produto                          Quantidade Doc./Série    ClienteLj    Base Icms Alíq.  Estorno Deb   Valor ICMS|Digitac. Emissão    Quantidade Doc./Série    Fornec/Lj    Base Icms Alíq. Estorno Cred|  Crédito
		//- ---------------------------------------------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------+------------
		//-           10        20        30        40        50       60         70        80        90       100       110       120       130       140       150       160       170       180       190       200       210      220
		//- 0123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+
		//- 99/99/99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 9.999.999,99 999999999/XXX XXXXXX/XX 9.999.999,99 99,99 9.999.999,99 9.999.999,99|99/99/99 99/99/99 9.999.999,99 999999999/XXX XXXXXX/XX 9.999.999,99 99,99 9.999.999,99|9.999.999,99
		//- 99/99/99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 9.999.999,99 999999999/XXX XXXXXX/XX 9.999.999,99 99,99 9.999.999,99 9.999.999,99|99/99/99 99/99/99 9.999.999,99 999999999/XXX XXXXXX/XX 9.999.999,99 99,99 9.999.999,99|9.999.999,99
		//- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//- T O T A L   A P U R A Ç Ã O                                                  9.999.999,99                    9.999.999,99|                                                       9.999.999,99       9.999.999,99|9.999.999,99
		//- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
	  	@ nLin,000 PSAY Subs(dToc(CDM->CDM_DTSAI),1,6)+Iif(LEN(dToc(CDM->CDM_DTSAI))==10,Subs(dToc(CDM->CDM_DTSAI),9,2),Subs(dToc(CDM->CDM_DTSAI),7,2))
		@ nLin,009 PSAY Subs(CDM->CDM_PRODUT,1,30) PICTURE PESQPICT('SB1','B1_COD')
		@ nLin,040 PSAY CDM->CDM_QTDVDS PICTURE "@E 9,999,999.99"
		@ nLin,053 PSAY CDM->(CDM_DOCSAI)+'/'+SerieNfId("CDM",2,"CDM_SERIES")
		@ nLin,067 PSAY CDM->CDM_CLIENT+'/'+CDM->CDM_LJCLI
		@ nLin,077 PSAY nBssai  PICTURE "@E 9,999,999.99"
		@ nLin,090 PSAY nAlqsai PICTURE "@E 99.99"
		@ nLin,096 PSAY nEstordeb PICTURE "@E 9,999,999.99" 
		@ nLin,109 PSAY nIcmsai PICTURE "@E 9,999,999.99"
		@ nLin,121 PSAY '|'
		@ nLin,122 PSAY Subs(dToc(CDM->CDM_DTDGEN),1,6)+Subs(dToc(CDM->CDM_DTDGEN),9,2)
		@ nLin,131 PSAY Subs(dToc(CDM->CDM_DTENT),1,6)+Subs(dToc(CDM->CDM_DTENT),9,2)
		@ nLin,140 PSAY CDM->CDM_QTDENT PICTURE "@E 9,999,999.99" //
		@ nLin,153 PSAY CDM->(CDM_DOCENT)+'/'+SerieNfId("CDM",2,"CDM_SERIEE")
		@ nLin,167 PSAY CDM->CDM_FORNEC+'/'+CDM->CDM_LJFOR 
		@ nLin,177 PSAY nBsent  PICTURE "@E 9,999,999.99"
		@ nLin,190 PSAY nAliqent PICTURE "@E 99.99"
		@ nLin,196 PSAY nEstorn PICTURE "@E 9999,999.99"
		@ nLin,207 PSAY '|'
		@ nLin,208 PSAY nIcment PICTURE "@E 9,999,999.99"
	
		nLin ++
	    nTotBsSaida += nBssai
		nTotEstDeb  += nEstordeb 
		nTotICMEnt  += nEstorn
		nTotICMSai  += nIcmsai    
		nTotCredito += nIcment
	    	
		(cAlias)->(dbSkip())
	EndDo 
	
	@ nLin,000 PSAY Replicate('-',Limite)
	nLin ++
	@ nLin,000 PSAY 'T O T A L   A P U R A C A O'
	@ nLin,077 PSAY nTotBsSaida PICTURE "@E 9,999,999.99"
	@ nLin,096 PSAY nTotEstDeb PICTURE "@E 9,999,999.99" //ESTORNO DEB
	@ nLin,109 PSAY nTotICMSai  PICTURE "@E 9,999,999.99"
	@ nLin,121 PSAY '|'
	@ nLin,196 PSAY nTotICMEnt  PICTURE "@E 9999,999.99"
	@ nLin,207 PSAY '|'        
	@ nLin,208 PSAY nTotCredito PICTURE "@E 9,999,999.99"  
	nLin ++
	@ nLin,000 PSAY Replicate('-',Limite)
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return