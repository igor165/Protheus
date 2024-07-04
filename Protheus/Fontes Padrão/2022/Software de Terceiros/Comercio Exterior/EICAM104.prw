#include "protheus.ch"
#include "topconn.ch"
#include "EICAM104.ch"

/*###############################################################################################
# 							  __   "   __                                                       #
#                           ( __ \ | / __ )  Kazoolo                                            #
#                            ( _ / | \ _ )   Codefacttory                                       #
#################################################################################################
# Programa:      # EICAM104()	                                                                #
#################################################################################################
# Descrição:     # Função para verificar se o relatório personalizável do Protheus está 		#
#				 # disponivel, em caso positivo executa as função FDefReL() e PrintDialog()		#
#################################################################################################
# Autor:         # Cleber Cintra Barbosa                                                        #
#################################################################################################
# Data:           # 12/05/10			                                                                #
#################################################################################################
# Palavras Chave: # Relatório Personalizável											        #
###############################################################################################*/ 
           
Function EICAM104()

	Local 	clPar		:= "AM10401"  
	Private olReport	:= NIL    
	 		                                 
      /*FParamE(clPar)*/	
      If !SX1->(DbSeek("AM10401"))
         clPar := "KZR014"
		EndIf
   	If TRepInUse()
		Pergunte(clPar,.F.) 
		olReport := FDefReL(clPar)
		olReport :PrintDialog()			
	EndIf           
	
Return Nil                

/*###############################################################################################
# 							  __   "   __                                                       #
#                           ( __ \ | / __ )  Kazoolo                                            #
#                            ( _ / | \ _ )   Codefacttory                                       #
#################################################################################################
# Programa:      # FDefReL()	                                                                #                    
#################################################################################################
# Descrição:     # Função para criação do objeto TREPORT e das duas seções do relatório, 		#
#				 # está função recebe por parêmetro o nome que foi dado aos parêmetros 			#
#################################################################################################
# Autor:         # Cleber Cintra Barbosa                                                        #
#################################################################################################
# Data:           # 			                                                                #
#################################################################################################
# Palavras Chave: # Seções olSection e ol2Sec 													#
###############################################################################################*/ 

Static Function FDefReL(clPar)
	  	   
	Local clNomeProg := "EICAM104"     
	Local clTitle    := STR0001     
	Local clDesc     := ""   	
	
	olReport := TReport():New(clNomeProg,clTitle,clPar,{|olReport| FVerif()},clDesc)	  
	//olReport:LHEADERVISIBLE		:= .F. 
	//olReport:LFOOTERVISIBLE  	:= .F.
	olReport:LPARAMPAGE			:= .F.
	olReport:oPage:NPAPERSIZE	:= 9
	olReport:SetLandScape(.T.) 	
		 
	olSection := TRSection():New(olReport,"Armazenagem",{"EWG"})
	 
		TRCell():New(olSection,"EWG_CODARM"	,"temp" , STR0002)
		TRCell():New(olSection,"EWG_LOJARM"	,"temp" , STR0003)  
		TRCell():New(olSection,"A2_NREDUZ"	,"temp" , STR0004)  
		TRCell():New(olSection,"EWG_HAWB"  	,"temp" , STR0005)   
		TRCell():New(olSection,"EWG_CODPAR"	,"temp" , STR0006)    
		TRCell():New(olSection,"EWG_CODTAB"	,"temp" , STR0007) 
		TRCell():New(olSection,"EWE_DESTAB"	,"temp" , STR0008) 
		TRCell():New(olSection,"EWG_DT_INI" ,"temp" , STR0009) 						
		TRCell():New(olSection,"EWG_DT_FIM"	,"temp" , STR0010) 
		TRCell():New(olSection,"EWG_VL_PRV"	,"temp" , STR0011,"@e 999,999,999,999,999.99") 
		TRCell():New(olSection,"EWG_VL_TOT"	,"temp" , STR0012,"@e 999,999,999,999,999.99") 
		TRCell():New(olSection,"EWG_TOTAL"	,"temp" , STR0013,"@e 999,999,999,999,999.99") 						
		TRCell():New(olSection,"EWG_DT_VEN"	,"temp" , STR0014)
		
	  	TRFunction():New(olSection:Cell("EWG_VL_PRV"),,"SUM",,STR0011,"@R 999,999,999.99 ",,.T.,.F.,.F.,)   
		TRFunction():New(olSection:Cell("EWG_VL_TOT"),,"SUM",,STR0015,"@R 999,999,999.99 ",,.T.,.F.,.F.,)    
		//TRFunction():New(olSection:Cell("EWG_TOTAL") ,,"SUM",,STR0015,"@R 999,999,999.99 ",,.T.,.F.,.F.,)    				
		
	ol2Sec := TRSection():New(olReport,"Armazenagem",{"EWH"})			
			
		TRCell():New(ol2Sec,"EWH_LINHA"	,"Anali" , STR0016)
		TRCell():New(ol2Sec,"EWD_CODSRV","Anali" , STR0017)
		TRCell():New(ol2Sec,"EWD_DESSRV","Anali" , STR0018)  
		TRCell():New(ol2Sec,"EWH_CODPRC","Anali" , STR0019)  
		TRCell():New(ol2Sec,"EW8_DESPRC","Anali" , STR0020)   
		TRCell():New(ol2Sec,"EWH_QTD"	,"Anali" , STR0021)    
		TRCell():New(ol2Sec,"EWH_PRCTOT","Anali" , STR0022) 
		TRCell():New(ol2Sec,"EWH_VL_PRV","Anali" , STR0011) 
		TRCell():New(ol2Sec,"EWH_VL_TOT","Anali" , STR0023) 						
		TRCell():New(ol2Sec,"EWH_TOTAL" ,"Anali" , STR0013)

		TRFunction():New(ol2Sec:Cell("EWH_VL_PRV"),,"SUM",,STR0011,"@R 999,999,999.99 ",,.T.,.F.,.F.,)   
		TRFunction():New(ol2Sec:Cell("EWH_VL_TOT"),,"SUM",,STR0015,"@R 999,999,999.99 ",,.T.,.F.,.F.,)   
	   //TRFunction():New(ol2Sec:Cell("EWH_TOTAL") ,,"SUM",,STR0015,"@R 999,999,999.99 ",,.T.,.F.,.F.,)   		

	olReport:SetTotalText("TOTAL GERAL")	

Return olReport


/*###############################################################################################
# 							  __   "   __                                                       #
#                           ( __ \ | / __ )  Kazoolo                                            #
#                            ( _ / | \ _ )   Codefacttory                                       #
#################################################################################################
# Programa:      # FPrintReport()                                                               #
#################################################################################################
# Descrição:     # Função que monta as querys e faz a impressão daquela referente ao parâmetro  #
#				 # escolhido pelo usuário no no combo Box Modo de Impressão						#
#################################################################################################
# Autor:         # Cleber Cintra Barbosa                                                        #
#################################################################################################
# Data:           # 12/05/10			                                                                #
#################################################################################################
# Palavras Chave: # Query, Modo de Impressão													#
###############################################################################################*/ 


Static Function FPrintReport()

	Local	clQuery		:= ""
	Private olSection	:= olReport:Section(1)
 	Private ol2Sec		:= olReport:Section(2) 		
	
	If mv_par01 == 2
		
		clQuery := "SELECT A2_NREDUZ,EWE_CODARM,EWE_LOJARM,EWE_CODTAB,EWE_DESTAB,EWE_NROPRO,EWE_DT_VAL,EWE_OBS,EWG_CODARM,EWG_LOJARM,EWG_HAWB,EWG_CODPAR,EWG_CODTAB,EWG_DT_INI,EWG_DT_FIM,EWG_VL_PRV,EWG_VL_TOT,(EWG_VL_TOT - EWG_VL_PRV) as EWG_TOTAL,EWG_DT_VEN "
		clQuery += "FROM " + RetSqlName("EWG") + " EWG " 

		clQuery += "INNER JOIN " + RetSqlName("EWE") + " EWE "		
		clQuery += "ON EWG_CODARM = EWE_CODARM "              
		clQuery += "AND EWG_LOJARM = EWE_LOJARM "              
		clQuery += "AND EWE_FILIAL = '" + xFilial("EWE") + "' "
		clQuery += "AND EWE.D_E_L_E_T_ = ' ' "	

		clQuery += "INNER JOIN " + RetSqlName("SA2") + " SA2 "
		clQuery += "ON EWG_CODARM = A2_COD "
		clQuery += "AND EWG_LOJARM = A2_LOJA "
		clQuery += "AND A2_FILIAL = '" + xFilial("SA2") + "' "
		clQuery += "AND SA2.D_E_L_E_T_ = ' ' "

		clQuery += "WHERE	EWG_FILIAL = '" + xFilial("EWG") + "' "
		clQuery += "AND		EWG.D_E_L_E_T_ = ' ' "
		clQuery += "AND		EWG_HAWB   = '" + MV_PAR02 + "' "		
		clQuery += "AND		EWG_CODARM = '" + MV_PAR03 + "' "
		clQuery += "AND		EWG_LOJARM = '" + MV_PAR04 + "' "
	
		If mv_par05 == 1
			clQuery += "AND EWG_DT_FIM = '' "
		Elseif mv_par05 == 2 
			clQuery += "AND EWG_DT_FIM <> '' "
		Endif		
		
		If mv_par06 == 1
			clQuery += "ORDER BY EWG_CODARM "
		Elseif mv_par06 == 2
			clQuery += "ORDER BY EWG_DT_INI "
		Elseif mv_par06 == 3
			clQuery += "ORDER BY EWG_VL_TOT "
		Elseif mv_par06 == 4
			clQuery += "ORDER BY EWG_VL_PRV "
		Endif
	
		TcQuery clQuery New Alias "temp"
			
		TcSetField("temp","EWG_DT_INI","D")
		TcSetField("temp","EWG_DT_FIM","D")
		TcSetField("temp","EWG_DT_VEN","D")
		TcSetField("temp","EWG_PRVFIM","D")
		
	   /*	If mv_par06 == 1
			TRFunction():New(olSection:Cell("EWG_VL_PRV"),,"SUM",,STR0024,"@R 999,999,999.99 ",{|| EWG_VL_PRV + EWG_VL_TOT + EWG_TOTAL},.T.,.F.,.F.,)
		EndIF*/
		olSection:Init()
		FCabec()
		While temp->(!EOF())
			clAux:= temp->EWG_CODARM
			While clAux == TEMP->EWG_CODARM
				olSection:PrintLine()
				olReport:SkipLine(1)
				temp->(DBSkip())
			Enddo
		EndDo
		olSection:Finish()
		temp->(DBCloseArea()) 

	Elseif mv_par01 == 1
	
		clQuery := "SELECT EW8_CODPRC,EW8_DESPRC,EW8_FORMUL,EWD_CODSRV,EWD_DESSRV,EWD_CODPRC,EWD_CDTFIM,EWH_LINHA,EWH_CODSRV,EWH_CODPRC,EWH_QTD,EWH_PRCTOT,EWH_VL_PRV,EWH_VL_TOT,(EWH_VL_TOT - EWH_VL_PRV) as EWH_TOTAL "
		clQuery += "FROM " + RetSqlName("EWH") + " EWH "

		clQuery += "INNER JOIN " + RetSqlName("EWD") + " EWD "
		clQuery += "ON EWH_CODSRV = EWD_CODSRV "
		clQuery += "AND	EWD_FILIAL = '" + xFilial("EWD") + "' "		
		clQuery += "AND EWD.D_E_L_E_T_ = ' ' " 

		clQuery += "INNER JOIN " + RetSqlName("EW8") + " EW8 " 
		clQuery += "ON EW8_CODPRC = EWD_CODPRC " 
		clQuery += "AND	EW8_FILIAL = '" + xFilial("EW8") + "' "		
		clQuery += "AND EW8.D_E_L_E_T_ = ' ' " 
	
		clQuery += "WHERE	EWH_FILIAL = '" + xFilial("EWH") + "' "
		clQuery += "AND		EWH.D_E_L_E_T_ = ' ' " 
		clQuery += "AND		EWH_HAWB   = '" + MV_PAR02 + "' "		
	
		If mv_par05 == 1
			clQuery += "AND EWH_DT_FIM = '' "
		Elseif mv_par05 == 2 
			clQuery += "AND EWH_DT_FIM <> '' "
		Endif
		
		If mv_par06 == 1
			clQuery += "ORDER BY EWH_CODPAR "
		Elseif mv_par06 == 2
			clQuery += "ORDER BY EWH_DT_INI "
		Elseif mv_par06 == 3
			clQuery += "ORDER BY EWH_VL_TOT "
		Elseif mv_par06 == 4
			clQuery += "ORDER BY EWH_VL_PRV "
		Endif
	
		TcQuery clQuery New Alias "Anali"
			
		TcSetField("Anali","EWH_DT_INI","D")
		TcSetField("Anali","EWH_DT_FIM","D")
		TcSetField("Anali","EWH_PRVFIM","D")
		
	   /*	If mv_par06 == 1
			TRFunction():New(ol2Sec:Cell("EWH_VL_PRV"),,"SUM",,STR0024,"@R 999,999,999.99 ",{|| EWH_VL_PRV + EWH_VL_TOT + EWH_TOTAL},.T.,.F.,.F.,)
		EndIF*/

		ol2Sec:Init()
		FCabec()
		olReport:SkipLine(4)
		While Anali->(!EOF())
			ol2Sec:PrintLine()
			olReport:SkipLine(1)
			Anali->(DBSkip())
		EndDo
		ol2Sec:Finish()
		Anali->(DBCloseArea())	
		
	Endif

Return() 

/*###############################################################################################
# 							  __   "   __                                                       #
#                           ( __ \ | / __ )  Kazoolo                                            #
#                            ( _ / | \ _ )   Codefacttory                                       #
#################################################################################################
# Programa:      # FParamE()                                                               		#
#################################################################################################
# Descrição:     # Função para a criação dos parâmetros, esta função recebe por parâmetro o     #
#				 # o nome que foi atribuido aos parâmetros 										#
#################################################################################################
# Autor:         # Cleber Cintra Barbosa	                                                    #
#################################################################################################
# Data:           # 12/05/10			                                                                #
#################################################################################################
# Palavras Chave: # Parâmetros 																	#
###############################################################################################*/ 
/*  //NCF - 23/10/2018 - Função descontinuada conforme regras do SonnarQube TOTVS              
Static Function FParamE(clPar)
	
	PutSx1(clPar,"01","Tipo de Relatório","","","mv_ch1","N",01,0,0,"C","","","","","MV_PAR01","Analítico","","","","Sintético","","",;
				"","","","","","","","","",,,,"")
				
	PutSx1(clPar,"02","Processo de Importação","","","mv_ch2","C",17,0,0,"G","ExistCpo('EWG')","EWG","","","MV_PAR02","","","","","","","",;
				"","","","","","","","","",,,,"")
				
	PutSx1(clPar,"03","Código do Armazem","","","mv_ch3","C",06,0,0,"G","ExistCpo('SA2')","SA2","","","MV_PAR03","","","","","","","",;
				"","","","","","","","","",,,,"")

	PutSx1(clPar,"04","Loja do Armazem","","","mv_ch4","C",02,0,0,"G","ExistCpo('SA2', mv_par03 + mv_par04)","SA22","","","MV_PAR04","","","","","","","",;
				"","","","","","","","","",,,,"")
				
	PutSx1(clPar,"05","Filtro por Situação","","","mv_ch5","N",01,0,0,"C","","","","","MV_PAR05","Previsto","","","","Realizado","","",;
				"Ambos","","","","","","","","",,,,"")
			
	PutSx1(clPar,"06","Ordenar por","","","mv_ch6","N",1,0,0,"C","","","","","MV_PAR06","Armazém","","","","Data inicio Armaz.","",;
				"","Vlr. Realizado","","","Vlr Previsto","","","","","",,,,"")
				
Return Nil 
*/
/*###############################################################################################
# 							  __   "   __                                                       #
#                           ( __ \ | / __ )  Kazoolo                                            #
#                            ( _ / | \ _ )   Codefacttory                                       #
#################################################################################################
# Programa:      # FCabec()  		                                                            #
#################################################################################################
# Descrição:     # Função para criação do cabeçalho do relatório								#
#################################################################################################
# Autor:         # Cleber Cintra Barbosa						                                #
#################################################################################################
# Data:           # 12/05/10			                                                                #
#################################################################################################
# Palavras Chave: # Cabeçalho																    #
###############################################################################################*/ 

Static Function FCabec()
	
	Local clAux:= 1
	
	olReport:PrintText(STR0001,olReport:Row() + (clAux*1000),olReport:Col() + clAux*1000)
	
	For clAux:= olReport:Row() to 10                                                                        
	    olReport:PrintText(" ",olReport:Row() + (clAux*10),olReport:Col())
	Next clAux

Return

/*###############################################################################################
# 							  __   "   __                                                       #
#                           ( __ \ | / __ )  Kazoolo                                            #
#                            ( _ / | \ _ )   Codefacttory                                       #
#################################################################################################
# Programa:      # FVerif()  		                                                            #
#################################################################################################
# Descrição:     # Verifica se o modo de impressão escolhidor foi Retrato, em caso positivo, 	#
#				 # exibe mensagem ao usuario.													#
#################################################################################################
# Autor:         # CLEBER CINTRA BARBOSA	                                                        #
#################################################################################################
# Data:           # 12/05/2010			                                                        #
#################################################################################################
# Palavras Chave: # Verifica modo de impressão											        #
###############################################################################################*/

Static Function FVerif()
	Local llFlag := .T.
	
	If olReport:GetOrientation() == 1
    	AVISO(STR0025,STR0026, {STR0027})
    	lLFlag := !llFlag
    	EICAM104()
	Else
		FPrintReport()        	
    EndIF
Return (llFlag)
