#Include "TOPCONN.CH"
#Include "Protheus.Ch"
#Include "Fisr004.Ch"
    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fisr004   ºAutor  ³ROBERTO SOUZA       º Data ³  23/07/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de ICMS Complementar                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFIS, SIGAFAT                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista Resp.³  Data  ³ Manutencao Efetuada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º              ³  /  /  ³                                               º±±
±±º              ³  /  /  ³                                               º±±
±±º              ³  /  /  ³                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fisr004()

	Local   oReport
	Local   cAlias  := GetNextAlias()
	Local   cPerg      := "FSR004"
	Local 	lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

	Private cPrograma  := "Fisr004"
	Private cCadastro  := OemToAnsi(STR0001) //"Relatório de ICMS Complementar"
	Private cAliasSA2	:= "SA2"
             
	If lVerpesssen
		Pergunte(cPerg,.F.)

		oReport:= ReportDef(cAlias, cPerg)
		oReport:PrintDialog()
	EndIf

Return

Static Function ReportPrint(oReport,cAlias)
    
	Local cCampos	:= ""               
	local oSection1 := oReport:Section(1)
	Local cBranco   := ' '
	Local cFilSFT   := xFilial("SFT")
	Local cFilSA2   := xFilial("SA2")
	Local aAreaFT   := SFT->(GetArea())
	Local aAreaA2   := SA2->(GetArea())

	#IFDEF TOP
		//If (TcSrvType ()<>"AS/400")

	 		If SerieNfId("SFT",3,"FT_SERIE") == "FT_SDOC"                                          
				cCampos += ", SFT.FT_SDOC" 
			Endif
	 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos que serao adicionados a query somente se existirem na base³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cCampos)
				cCampos := "%%"
			Else       
				cCampos := "% " + cCampos + " %"
			Endif  

			oSection1:BeginQuery()
		
			BeginSQL Alias cAlias
			
				SELECT 
				SFT.FT_ENTRADA,
				SFT.FT_NFISCAL,
				SFT.FT_SERIE,
				SFT.FT_CLIEFOR,
				SFT.FT_LOJA,
				SFT.FT_FORMULA,
				SFT.FT_TIPO,
				SA2.A2_NREDUZ,
				SA2.A2_CGC,
				SA2.A2_EST,
				(CASE WHEN DEV.DVALCONT > 0 THEN SFT.FT_VALCONT - DEV.DVALCONT ELSE SFT.FT_VALCONT - 0 END) VALCONT,
				(CASE WHEN DEV.DBASEICM > 0 THEN SFT.FT_BASEICM - DEV.DBASEICM ELSE SFT.FT_BASEICM - 0 END) BASEICM,
				(CASE WHEN DEV.DVALICM  > 0 THEN SFT.FT_VALICM - DEV.DVALICM   ELSE SFT.FT_VALICM  - 0 END) VALICM,
				(CASE WHEN DEV.DICMSCOM > 0 THEN SFT.FT_ICMSCOM - DEV.DICMSCOM ELSE SFT.FT_ICMSCOM - 0 END) ICMSCOM,
				SFT.FT_OBSERV 
				%Exp:cCampos%

				FROM 
				%TABLE:SFT% SFT
				INNER JOIN %TABLE:SA2% SA2 ON (SA2.A2_FILIAL = %Exp:cFilSA2%
				AND SFT.FT_CLIEFOR = SA2.A2_COD
				AND SFT.FT_LOJA = SA2.A2_LOJA
				AND SA2.%NOTDEL%)
				LEFT JOIN
				(SELECT FT_FILIAL AS DFILIAL,
				FT_VALCONT AS DVALCONT,
				FT_BASEICM AS DBASEICM,
				FT_VALICM AS DVALICM,
				FT_ICMSCOM AS DICMSCOM,
				FT_NFORI AS DNFORI,
				FT_SERORI AS DSERORI,
				FT_ITEMORI AS DITEMORI,
				FT_DTCANC AS DDTCANC,
				FT_ENTRADA AS DENTRADA,
				FT_TIPO AS DTIPO,
				D_E_L_E_T_
				FROM %TABLE:SFT%) DEV ON (DEV.DFILIAL = %Exp:cFilSFT%
				AND DEV.DNFORI = SFT.FT_NFISCAL
				AND DEV.DSERORI = SFT.FT_SERIE
				AND DEV.DITEMORI = SFT.FT_ITEM
				AND DEV.DDTCANC =''
				AND DEV.DENTRADA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				AND DEV.DTIPO = 'D' AND DEV.D_E_L_E_T_ = ' ')
				WHERE SFT.FT_FILIAL = %Exp:cFilSFT%
				AND SFT.FT_ENTRADA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				AND SFT.FT_ICMSCOM > 0
				AND SFT.FT_PDDES = 0
				AND SFT.FT_TIPOMOV ='E' AND SFT.FT_TIPO NOT IN('D', 'B')
				AND SFT.FT_DTCANC = %Exp:cBranco%
				AND SFT.%NOTDEL%

			EndSQL
		
			oSection1:EndQuery()
			
			oReport:SetMeter((cAlias)->(RecCount()))
 
			DbSelectArea(cAlias) 
			DbGotop()
	
	        oSection1:Cell("FT_TIPO"    ):SetTitle(STR0022)                   // 'TIPO'
			oSection1:Cell("FT_ENTRADA" ):SetTitle(STR0005)					  // 'EMISSÃO'
			oSection1:Cell("FT_NFISCAL" ):SetTitle(STR0006)					  // 'NOTA FISCAL'
			oSection1:Cell(SerieNfId("SFT",3,"FT_SERIE")   ):SetTitle(STR0007)// 'SERIE'
			oSection1:Cell("FT_CLIEFOR" ):SetTitle(STR0008)					  // 'COD FOR'
			oSection1:Cell("FT_LOJA"    ):SetTitle(STR0009)					  // 'LOJA'
			oSection1:Cell("A2_NREDUZ"  ):SetTitle(STR0010)					  // 'NOME FORNECEDOR'
			oSection1:Cell("A2_CGC"     ):SetTitle(STR0011)					  // 'CNPJ / CPF'
			oSection1:Cell("A2_EST"     ):SetTitle(STR0012)					  // 'UF'
			oSection1:Cell("FT_VALCONT" ):SetTitle(STR0013)					  // 'VALOR'
			oSection1:Cell("FT_BASEICM" ):SetTitle(STR0014)					  // 'BASE ICMS'
			oSection1:Cell("FT_VALICM"  ):SetTitle(STR0015)					  // 'VALOR ICMS'
			oSection1:Cell("FT_ICMSCOM" ):SetTitle(STR0016)					  // 'ICMS COMPLEMENTAR'
			oSection1:Cell("FT_OBSERV"  ):SetTitle(STR0017)					  // 'OBSERVAÇÕES'
		
		    oSection1:Cell("FT_TIPO"    ):SetBlock ( { || iiF((cAlias)->VALCONT + (cAlias)->BASEICM + (cAlias)->VALICM + (cAlias)->ICMSCOM,"","D" ) } )
			oSection1:Cell("FT_ENTRADA" ):SetBlock ( { || (cAlias)->FT_ENTRADA                               								        } )
			oSection1:Cell("FT_NFISCAL" ):SetBlock ( { || (cAlias)->FT_NFISCAL 								 								        } )
			oSection1:Cell(SerieNfId("SFT",3,"FT_SERIE")   ):SetBlock ( { || SerieNfId(cAlias,2,"FT_SERIE")  								        } )				
			oSection1:Cell("FT_CLIEFOR" ):SetBlock ( { || (cAlias)->FT_CLIEFOR 								 								        } )
			oSection1:Cell("FT_LOJA"    ):SetBlock ( { || (cAlias)->FT_LOJA    								 								        } )
			oSection1:Cell("A2_NREDUZ"  ):SetBlock ( { || (cAlias)->A2_NREDUZ  								 								        } )
			oSection1:Cell("A2_CGC"     ):SetBlock ( { || (cAlias)->A2_CGC     								 								        } )
			oSection1:Cell("A2_EST"     ):SetBlock ( { || (cAlias)->A2_EST     								 								        } )
			oSection1:Cell("FT_VALCONT" ):SetBlock ( { || (cAlias)->VALCONT 							 								            } )
			oSection1:Cell("FT_BASEICM" ):SetBlock ( { || (cAlias)->BASEICM							 							         	        } )
			oSection1:Cell("FT_VALICM"  ):SetBlock ( { || (cAlias)->VALICM  							 							    	        } )
			oSection1:Cell("FT_ICMSCOM" ):SetBlock ( { || (cAlias)->ICMSCOM 							 		      						        } )
			oSection1:Cell("FT_OBSERV"  ):SetBlock ( { || IIF (!Empty((cAlias)->FT_FORMULA),Formula((cAlias)->FT_FORMULA),(cAlias)->FT_OBSERV)      } )
		 
			oSection1:Print()
			
			oReport:SetMeter((cAlias)->(RecCount()))						
		//Else
	#ELSE
	
			DbSelectArea("SFT")
			SFT->(DbSetOrder(3))//FT_FILIAL, FT_CLIEFOR, FT_LOJA, FT_NFISCAL, FT_SERIE, R_E_C_N_O_, D_E_L_E_T_
			SFT->(DbGoTop("SFT"))
			
			DbSelectArea("SA2")
			SA2->(DbSetOrder(1))//A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_, D_E_L_E_T_
			
			While !(SFT->(Eof())) .AND. SFT->FT_FILIAL = cFilSFT
			
				If (SFT->FT_ENTRADA >= MV_PAR01 .AND. SFT->FT_ENTRADA <= MV_PAR02 ) .AND. ;					
					Val(SubStr(SFT->FT_CFOP,1,1)) < 5 .AND. Empty(SFT->FT_DTCANC) .AND. ;
					SFT->FT_ICMSCOM > 0 //ICMS Complementar - DIFERENCIAL DE ALIQUOTA
					 
					SA2->(DbGoTop("SA2"))
					If SA2->(DbSeek(xFilial("SA2")+SFT->FT_CLIEFOR+SFT->FT_LOJA))
					 
						oSection1:Cell("FT_ENTRADA" ):SetTitle(STR0005)// 'EMISSÃO'
						oSection1:Cell("FT_NFISCAL" ):SetTitle(STR0006)// 'NOTA FISCAL'
						oSection1:Cell("FT_SERIE"   ):SetTitle(STR0007)// 'SERIE'
						oSection1:Cell("FT_CLIEFOR" ):SetTitle(STR0008)// 'COD FOR'
						oSection1:Cell("FT_LOJA"    ):SetTitle(STR0009)// 'LOJA'
						oSection1:Cell("A2_NREDUZ"  ):SetTitle(STR0010)// 'NOME FORNECEDOR'
						oSection1:Cell("A2_CGC"     ):SetTitle(STR0011)// 'CNPJ / CPF'
						oSection1:Cell("A2_EST"     ):SetTitle(STR0012)// 'UF'
						oSection1:Cell("FT_VALCONT" ):SetTitle(STR0013)// 'VALOR'
						oSection1:Cell("FT_BASEICM" ):SetTitle(STR0014)// 'BASE ICMS'
						oSection1:Cell("FT_VALICM"  ):SetTitle(STR0015)// 'VALOR ICMS'
						oSection1:Cell("FT_ICMSCOM" ):SetTitle(STR0016)// 'ICMS COMPLEMENTAR'
						oSection1:Cell("FT_OBSERV"  ):SetTitle(STR0017)// 'OBSERVAÇÕES'
					
						oSection1:Cell("FT_ENTRADA" ):SetValue(SFT->(FT_ENTRADA ))
						oSection1:Cell("FT_NFISCAL" ):SetValue(SFT->(FT_NFISCAL ))
						oSection1:Cell("FT_SERIE"   ):SetValue(SFT->(FT_SERIE   ))
						oSection1:Cell("FT_CLIEFOR" ):SetValue(SFT->(FT_CLIEFOR ))
						oSection1:Cell("FT_LOJA"    ):SetValue(SFT->(FT_LOJA    ))
						oSection1:Cell("A2_NREDUZ"  ):SetValue(SA2->(A2_NREDUZ  ))
						oSection1:Cell("A2_CGC"     ):SetValue(SA2->(A2_CGC     ))
						oSection1:Cell("A2_EST"     ):SetValue(SA2->(A2_EST     ))
						oSection1:Cell("FT_VALCONT" ):SetValue(SFT->(VALCONT    ))
						oSection1:Cell("FT_BASEICM" ):SetValue(SFT->(BASEICM    ))
						oSection1:Cell("FT_VALICM"  ):SetValue(SFT->(VALICM     ))
						oSection1:Cell("FT_ICMSCOM" ):SetValue(SFT->(ICMSCOM    ))
						oSection1:Cell("FT_OBSERV"  ):SetValue({ || IIF (!Empty(SFT->(FT_FORMULA)),Formula(SFT->(FT_FORMULA)),SFT->(FT_OBSERV))  } )
					 
						oSection1:PrintLine()
					 							 
					EndIf
				EndIf
				
				SFT->(DbSkip())
			EndDo
		//EndIf
	#ENDIF
	
 	RestArea(aAreaFT)
 	RestArea(aAreaA2)
Return

 //+-----------------------------------------------------------------------------------------------+
 //! Função para criação da estrutura do relatório.                                                !
 //+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias,cPerg)

	local oReport
	local oSection1

	oReport := TReport():New(cPrograma,Capital(cCadastro),cPerg,{|oReport|ReportPrint(oReport,cAlias)})

 //Primeira seção
	oSection1 := TRSection():New(oReport,cCadastro,{"SFT","SA2"})
    
	TRCell():New( oSection1,"FT_TIPO"   ,"SFT",/*Titulo*/,/*Picture*/,5,/*lPixel*/,/*CodeBlock*/,"CENTER" ,,"RIGHT"  )
	TRCell():New( oSection1,"FT_ENTRADA","SFT",/*Titulo*/,/*Picture*/,20,/*lPixel*/,/*CodeBlock*/,"CENTER" ,,"RIGHT"  )
	TRCell():New( oSection1,"FT_NFISCAL","SFT",/*Titulo*/,/*Picture*/,17,/*lPixel*/,/*CodeBlock*/,"CENTER" ,,"RIGHT"  )
	TRCell():New( oSection1,SerieNfId("SFT",3,"FT_SERIE"),"SFT",/*Titulo*/,/*Picture*/,07,/*lPixel*/,/*CodeBlock*/,"CENTER" ,,"RIGHT"  )
	TRCell():New( oSection1,"FT_CLIEFOR","SFT",/*Titulo*/,/*Picture*/,10,/*lPixel*/,/*CodeBlock*/,"CENTER" ,,"RIGHT"  )
	TRCell():New( oSection1,"FT_LOJA"   ,"SFT",/*Titulo*/,/*Picture*/,06,/*lPixel*/,/*CodeBlock*/,"CENTER" ,,"RIGHT"  )
	TRCell():New( oSection1,"A2_NREDUZ" ,"SA2",/*Titulo*/,/*Picture*/,30,/*lPixel*/,/*CodeBlock*/,"LEFT"   ,,"CENTER" )
	TRCell():New( oSection1,"A2_CGC"    ,"SA2",/*Titulo*/,/*Picture*/,35,/*lPixel*/,/*CodeBlock*/,"CENTER" ,,"CENTER" )
	TRCell():New( oSection1,"A2_EST"    ,"SA2",/*Titulo*/,/*Picture*/,04,/*lPixel*/,/*CodeBlock*/,"CENTER" ,,"CENTER" )
	TRCell():New( oSection1,"FT_VALCONT","SFT",/*Titulo*/,/*Picture*/,23,/*lPixel*/,/*CodeBlock*/,,,)//"RIGHT"  ,,"RIGHT"  )
	TRCell():New( oSection1,"FT_BASEICM","SFT",/*Titulo*/,/*Picture*/,23,/*lPixel*/,/*CodeBlock*/,,,)//"RIGHT"  ,,"RIGHT"  )
	TRCell():New( oSection1,"FT_VALICM" ,"SFT",/*Titulo*/,/*Picture*/,23,/*lPixel*/,/*CodeBlock*/,,,)//"RIGHT"  ,,"RIGHT"  )
	TRCell():New( oSection1,"FT_ICMSCOM","SFT",/*Titulo*/,/*Picture*/,23,/*lPixel*/,/*CodeBlock*/,,,)//"RIGHT"  ,,"RIGHT"  )
	TRCell():New( oSection1,"FT_OBSERV" ,"SFT",/*Titulo*/,/*Picture*/,40,/*lPixel*/,/*CodeBlock*/,"LEFT" ,,"RIGHT"  )
   
	oSection1:SetTotalInLine(.T.)
		
			
	oReport:SetTotalInLine(.T.)
		
	oTotal := TRFunction():New(oSection1:Cell("FT_VALCONT"),Nil,"SUM",/*oBreak2*/,Upper(STR0018),/*"@R 999,999,999.99"*/,/*uFormula*/,.F.,.T.)//"Total Valor Contabil-----"
	oTotal := TRFunction():New(oSection1:Cell("FT_BASEICM"),Nil,"SUM",/*oBreak2*/,Upper(STR0019),/*"@R 999,999,999.99"*/,/*uFormula*/,.F.,.T.)//"Total Base ICMS----------"
	oTotal := TRFunction():New(oSection1:Cell("FT_VALICM") ,Nil,"SUM",/*oBreak2*/,Upper(STR0020),/*"@R 999,999,999.99"*/,/*uFormula*/,.F.,.T.)//"Total Valor ICMS---------"
	oTotal := TRFunction():New(oSection1:Cell("FT_ICMSCOM"),Nil,"SUM",/*oBreak2*/,Upper(STR0021),/*"@R 999,999,999.99"*/,/*uFormula*/,.F.,.T.) //"Total ICMS Complementar---"

Return(oReport)
