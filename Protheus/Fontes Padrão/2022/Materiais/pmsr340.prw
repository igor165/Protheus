#INCLUDE "Protheus.ch"
#INCLUDE "pmsr340.ch"
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

//----------------------------RELEASE 4--------------------------------------//

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PMSR340   �Autor  �Paulo Carnelossi    � Data �  10/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Implementa��o do relat�rio utilizando TReport              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 8+                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PMSR340()
	Local oReport
	If PMSBLKINT()
		Return Nil
	EndIf

	oReport := ReportDef()

	If !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf	

	oReport:PrintDialog()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PMSR340   �Autor  �Paulo Carnelossi    � Data �  10/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Implementa��o do relat�rio utilizando TReport              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 8+                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()
Local cPerg			:= "PMR340"
Local cDesc1   := STR0001 //"Este relatorio ira imprimir uma relacao de eventos do projeto"
Local cDesc2   := "" 
Local cDesc3   := ""

Local oReport
Local oProjeto
Local oEdt
Local oTarefa
Local oEvento

Local aOrdem  := {STR0003,; //"PROJETO+EDT+TAREFA+DATA PRV. CALC."
                   STR0004,; //"PROJETO+EDT+TAREFA+DATA REALIZADA"
                   STR0005,; //"DATA PRV. CALC."
                   STR0006} //"DATA REALIZADA"

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������

oReport := TReport():New("PMSR340",STR0002, cPerg, ;
			{|oReport| ReportPrint(oReport)},;
			cDesc1 )
oReport:SetLandScape()

oProjeto := TRSection():New(oReport, STR0013, {"AF8", "SA1"}, aOrdem /*{}*/, .F., .F.) //"Projeto"
//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
TRCell():New(oProjeto,	"AF8_PROJET","AF8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"AF8_DESCRI","AF8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

TRPosition():New(oProjeto, "SA1", 1, {|| xFilial("SA1") + AF8->AF8_CLIENT})

oProjeto:SetLineStyle()

//-------------------------------------------------------------
oEdt := TRSection():New(oReport, STR0014, { "AFC" },  /*{aOrdem}*/, .F., .F.) //"EDT"

TRCell():New(oEdt,	"AFC_EDT","AFC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEdt,	"AFC_DESCRI","AFC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

oEdt:SetLineStyle()
oEdt:SetLinesBefore(0)


//-------------------------------------------------------------
oTarefa := TRSection():New(oReport, STR0015, { "AF9"}, /*{aOrdem}*/, .F., .F.) //"Tarefa"

TRCell():New(oTarefa,	"AF9_TAREFA","AF9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oTarefa,	"AF9_DESCRI","AF9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

oTarefa:SetLineStyle()
oTarefa:SetLinesBefore(0)

//-------------------------------------------------------------
oEvento := TRSection():New(oReport, STR0016, { "AFP"}, /*{aOrdem}*/, .F., .F.)  //"Eventos"
TRCell():New(oEvento,	"AFP_USO", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEvento,	"AFP_DESCRI", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEvento,	"AFP_DTPREV", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEvento,	"AFP_DTCALC", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEvento,	"AFP_DTATU", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEvento,	"AFP_PERC", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEvento,	"AFP_EMAIL", "AFP",/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
oEvento:Cell("AFP_EMAIL"):SetLineBreak()
TRCell():New(oEvento,	"AFP_CLIENT", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEvento,	"AFP_LOJA", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEvento,	"AFP_NUM", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEvento,	"AFP_VALOR", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEvento,	"AFP_MOEDA", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEvento,	"AFP_COND", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEvento,	"AFP_PREFIX", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEvento,	"AFP_NATURE", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEvento,	"AFP_CTV", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEvento,	"AFP_CTVITE", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEvento,	"AFP_CTVPER", "AFP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)


oEvento:SetHeaderPage()
oEvento:SetLineBreak()
oEvento:SetLinesBefore(0)


Return(oReport)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PMSR340   �Autor  �Paulo Carnelossi    � Data �  10/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Implementa��o do relat�rio utilizando TReport              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 8+                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint(oReport)
Local oProjeto := oReport:Section(1)
Local oEdt := oReport:Section(2)
Local oTarefa := oReport:Section(3)
Local oEvento := oReport:Section(4)
Local nOrdem  := oReport:Section(1):GetOrder()

Local aArea := GetArea()
Local dDataAnt := "01/01/1980"
Local lImpProj := .F.

Do Case
	////////////////////////////////////////////////////
	// FILIAL + PROJETO + EDT + TAREFA + DATA PRV. CALC.
	////////////////////////////////////////////////////
	Case nOrdem == 1     

		//////////////////////////////////
		// ler todos os projetos
		//////////////////////////////////		
		dbSelectArea("AF8")
		AF8->(dbSetOrder(1))
		AF8->(MsSeek(xFilial("AF8") + mv_par01, .T.))
		oProjeto:Init()
		oReport:SetMeter(AF8->(RecCount()))
		While !AF8->(Eof()) .And. AF8->AF8_FILIAL==xFilial("AF8") .And. AF8->AF8_PROJET <= mv_par02
			// pula para o proximo projeto se foi informada
			// uma versao e esta nao e igual ao do projeto
			
			If RetProj()
				AF8->(dbSkip())
				Loop
			EndIf
			
			oReport:IncMeter()
			
			////////////////////////////////////////////
			// ler todas as EDTs do projeto corrente
			////////////////////////////////////////////
			dbSelectArea("AFC")
			AFC->(dbSetOrder(1))
			AFC->(MsSeek(xFilial("AFC") + AF8->AF8_PROJET + AF8->AF8_REVISA))

			oEdt:Init()
			
			While !AFC->(Eof()) .And.;
				AFC->AFC_FILIAL==xFilial("AFC")  .And.;
				AFC->AFC_PROJET==AF8->AF8_PROJET .And.;
				AFC->AFC_REVISA==AF8->AF8_REVISA
				
				lImpProj := .T.
				
				// ler todos os eventos da EDT corrente			
				dbSelectArea("AFP")
				AFP->(dbSetOrder(3))
				AFP->(MsSeek(xFilial("AFP") + AFC->AFC_PROJET + AFC->AFC_REVISA + AFC->AFC_EDT, .T.))
				
				oEvento:Init()
				
				While !AFP->(Eof()) .And.;
					AFP->AFP_FILIAL==AFC->AFC_FILIAL .And.;
					AFP->AFP_PROJET==AFC->AFC_PROJET .And.;
					AFP->AFP_REVISA==AFC->AFC_REVISA .And.;
					AFP->AFP_EDT   ==AFC->AFC_EDT   

					// pula para o proximo evento          
					// se a data prevista calculada esta fora da faixa informada
					// se a data prevista informada esta fora da faixa informada
					// se a data realizada esta fora da faixa informada
					If (AFP->AFP_DTCALC < mv_par03 .Or. AFP->AFP_DTCALC > mv_par04) .Or. (AFP->AFP_DTPREV < mv_par05 .Or. AFP->AFP_DTPREV > mv_par06) .Or. AFP->AFP_DTATU < mv_par07 .Or. AFP->AFP_DTATU > mv_par08
						dbSelectArea("AFP")
						AFP->(dbSkip())
						Loop
					EndIf

					If lImpProj
						
						If ! oProjeto:lPrintHeader
						    oProjeto:PrintHeader()
						EndIf    
						oProjeto:PrintLine()
						
						If ! oEdt:lPrintHeader
							oEdt:PrintHeader()
						EndIf    
						oEdt:PrintLine()
						oReport:SkipLine()
						lImpProj := .F.

					EndIf	
					
					oEvento:PrintLine()

					dbSelectArea("AFP")
					AFP->(dbSkip())
					
				EndDO
			    
			    oEvento:Finish()
			    oReport:SkipLine()
			    
				dbSelectArea("AF9")
				AF9->(dbSetOrder(2))
				AF9->(MsSeek(xFilial("AF9") + AF8->AF8_PROJET + AF8->AF8_REVISA + AFC->AFC_EDT, .T.))
				
				oTarefa:Init()
				
				While !AF9->(Eof()) .And.;
					AF9->AF9_FILIAL==xFilial("AF9") .And.;
					AF9->AF9_PROJET==AF8->AF8_PROJET .And.;
					AF9->AF9_REVISA==AF8->AF8_REVISA .And.;
					AF9->AF9_EDTPAI==AFC->AFC_EDT
					
					lImpProj := .T.
					
					// ler todos os eventos da tarefa corrente			
					dbSelectArea("AFP")
					AFP->(dbSetOrder(3))
					AFP->(MsSeek(xFilial("AFP") + AF9->AF9_PROJET + AF9->AF9_REVISA + Space(TamSX3("AFP_EDT")[1]) + AF9->AF9_TAREFA, .T.))
					
					oEvento:Init()
					
					While !AFP->(Eof()) .And.;
						AFP->AFP_FILIAL==AF9->AF9_FILIAL .And.;
						AFP->AFP_PROJET==AF9->AF9_PROJET .And.;
						AFP->AFP_REVISA==AF9->AF9_REVISA .And.;
						AFP->AFP_EDT   ==Space(TamSX3("AFP_EDT")[1]) .And.;
						AFP->AFP_TAREFA==AF9->AF9_TAREFA
	
						// pula para o proximo evento          
						// se a data prevista calculada esta fora da faixa informada
						// se a data prevista informada esta fora da faixa informada
						// se a data realizada esta fora da faixa informada
						If (AFP->AFP_DTCALC < mv_par03 .Or. AFP->AFP_DTCALC > mv_par04) .Or. (AFP->AFP_DTPREV < mv_par05 .Or. AFP->AFP_DTPREV > mv_par06) .Or. AFP->AFP_DTATU < mv_par07 .Or. AFP->AFP_DTATU > mv_par08
							dbSelectArea("AFP")
							AFP->(dbSkip())
							Loop
						EndIf
						        
						If lImpProj
		
							If ! oProjeto:lPrintHeader
								oProjeto:PrintHeader()
							EndIf    
						    
							oProjeto:PrintLine()

							If ! oTarefa:lPrintHeader
								oTarefa:PrintHeader()
							EndIf    

							oTarefa:PrintLine()
							oReport:SkipLine()
							lImpProj := .F.
							
						EndIf
						
						oEvento:PrintLine()
	
						dbSelectArea("AFP")
						AFP->(dbSkip())
						
					EndDO
					
					oEvento:Finish()
					oReport:SkipLine()
				  
				  dbSelectArea("AF9")
				  AF9->(dbSkip())
				    
				EndDO
                
				oTarefa:Finish()
				
			  dbSelectArea("AFC")
			  AFC->(dbSkip())

			EndDO

			oEdt:Finish()
			oReport:ThinLine()
			
			If oReport:Cancel()
				oReport:SkipLine()
				oReport:PrintText(STR0017) //"*** CANCELADO PELO OPERADOR ***"
				Exit
			EndIf
			
			dbSelectArea("AF8")
			AF8->(dbSkip())
			
		EndDo
        
		oProjeto:Finish()

	//////////////////////////////////////////////////////////////////
	// FILIAL + PROJETO + REVISAO + EDT + TAREFA + DATA PRV. REALIZADA
	//////////////////////////////////////////////////////////////////
	Case nOrdem == 2
		//////////////////////////////////
		// ler todos os projetos
		//////////////////////////////////		
		dbSelectArea("AF8")
		AF8->(dbSetOrder(1))
		AF8->(MsSeek(xFilial("AF8") + mv_par01, .T.))

		oReport:SetMeter(AF8->(RecCount()))
		oProjeto:Init()
		
		While !AF8->(Eof()) .And. AF8->AF8_FILIAL==xFilial("AF8") .And. AF8->AF8_PROJET <= mv_par02
			// pula para o proximo projeto se foi informada
			// uma versao e esta nao e igual ao do projeto
			If RetProj()
				AF8->(dbSkip())
				Loop
			EndIf
			
			oReport:IncMeter()

			////////////////////////////////////////////
			// ler todas as EDTs do projeto corrente
			////////////////////////////////////////////
			dbSelectArea("AFC")
			AFC->(dbSetOrder(1))
			AFC->(MsSeek(xFilial("AFC") + AF8->AF8_PROJET + AF8->AF8_REVISA))

			oReport:SetMeter(AFC->(RecCount()))
			oEdt:Init()
			
			While !AFC->(Eof()) .And.;
				AFC->AFC_FILIAL==xFilial("AFC")  .And.;
				AFC->AFC_PROJET==AF8->AF8_PROJET .And.;
				AFC->AFC_REVISA==AF8->AF8_REVISA
				
				lImpProj := .T.
				
				oReport:IncMeter()
			
				// ler todos os eventos da EDT corrente			
				dbSelectArea("AFP")
				AFP->(dbSetOrder(4))
				AFP->(MsSeek(xFilial("AFP") + AFC->AFC_PROJET + AFC->AFC_REVISA + AFC->AFC_EDT, .T.))
				
				oEvento:Init()
				
				While !AFP->(Eof()) .And.;
					AFP->AFP_FILIAL==AFC->AFC_FILIAL .And.;
					AFP->AFP_PROJET==AFC->AFC_PROJET .And.;
					AFP->AFP_REVISA==AFC->AFC_REVISA .And.;
					AFP->AFP_EDT   ==AFC->AFC_EDT   

					// pula para o proximo evento          
					// se a data prevista calculada esta fora da faixa informada
					// se a data prevista informada esta fora da faixa informada
					// se a data realizada esta fora da faixa informada
					If (AFP->AFP_DTCALC < mv_par03 .Or. AFP->AFP_DTCALC > mv_par04) .Or. (AFP->AFP_DTPREV < mv_par05 .Or. AFP->AFP_DTPREV > mv_par06) .Or. AFP->AFP_DTATU < mv_par07 .Or. AFP->AFP_DTATU > mv_par08
						dbSelectArea("AFP")
						AFP->(dbSkip())
						Loop
					EndIf

					If lImpProj

					    If ! oProjeto:lPrintHeader
						    oProjeto:PrintHeader()
						EndIf    
						oProjeto:PrintLine()

					    If ! oEdt:lPrintHeader
						    oEdt:PrintHeader()
						EndIf    

						oEdt:PrintLine()
						oReport:SkipLine()
						lImpProj := .F.
						
					EndIf	
					
					oEvento:PrintLine()
					
					dbSelectArea("AFP")
					AFP->(dbSkip())
					
				EndDO
				
				oEvento:Finish()
			    oReport:SkipLine()				
			  
				dbSelectArea("AF9")
				AF9->(dbSetOrder(2))
				AF9->(MsSeek(xFilial("AF9") + AF8->AF8_PROJET + AF8->AF8_REVISA + AFC->AFC_EDT, .T.))
				
				oTarefa:Init()
				
				While !AF9->(Eof()) .And.;
					AF9->AF9_FILIAL==xFilial("AF9") .And.;
					AF9->AF9_PROJET==AF8->AF8_PROJET .And.;
					AF9->AF9_REVISA==AF8->AF8_REVISA .And.;
					AF9->AF9_EDTPAI==AFC->AFC_EDT
					
					lImpProj := .T.
					
					// ler todos os eventos da tarefa corrente			
					dbSelectArea("AFP")
					AFP->(dbSetOrder(3))
					AFP->(MsSeek(xFilial("AFP") + AF9->AF9_PROJET + AF9->AF9_REVISA + Space(TamSX3("AFP_EDT")[1]) + AF9->AF9_TAREFA, .T.))
					
					oEvento:Init()
					
					While !AFP->(Eof()) .And.;
						AFP->AFP_FILIAL==AF9->AF9_FILIAL .And.;
						AFP->AFP_PROJET==AF9->AF9_PROJET .And.;
						AFP->AFP_REVISA==AF9->AF9_REVISA .And.;
						AFP->AFP_EDT   ==Space(TamSX3("AFP_EDT")[1]) .And.;
						AFP->AFP_TAREFA==AF9->AF9_TAREFA
	
						// pula para o proximo evento          
						// se a data prevista calculada esta fora da faixa informada
						// se a data prevista informada esta fora da faixa informada
						// se a data realizada esta fora da faixa informada
						If (AFP->AFP_DTCALC < mv_par03 .Or. AFP->AFP_DTCALC > mv_par04) .Or. (AFP->AFP_DTPREV < mv_par05 .Or. AFP->AFP_DTPREV > mv_par06) .Or. AFP->AFP_DTATU < mv_par07 .Or. AFP->AFP_DTATU > mv_par08
							dbSelectArea("AFP")
							AFP->(dbSkip())
							Loop
						EndIf
			        
						If lImpProj
						
					    	If ! oProjeto:lPrintHeader
						    	oProjeto:PrintHeader()
						    EndIf	
					    	oProjeto:PrintLine()
					    	
							If ! oTarefa:lPrintHeader
								oTarefa:PrintHeader()
							EndIf	
							oTarefa:PrintLine()
							oReport:SkipLine()
							lImpProj := .F.
							
						EndIf
						
			            oEvento:PrintLine()
			            
						dbSelectArea("AFP")
						AFP->(dbSkip())
						
					EndDO
					oEvento:Finish()
					oReport:SkipLine()
				  
				  dbSelectArea("AF9")
				  AF9->(dbSkip())
				  
				EndDO
				
				oTarefa:Finish()

			  dbSelectArea("AFC")
			  AFC->(dbSkip())
			  
			EndDO
			
			oEdt:Finish()

			oReport:ThinLine()
			If oReport:Cancel()
				oReport:SkipLine()
				oReport:PrintText(STR0017) //"*** CANCELADO PELO OPERADOR ***"
				Exit
			EndIf
			
			dbSelectArea("AF8")
			AF8->(dbSkip())
			
		EndDO
		
		oProjeto:Finish()


	//////////////////////////////////////////////////////////////////
	// DATA PREVISTA CALCULADA
	//////////////////////////////////////////////////////////////////
	Case nOrdem == 3
	
		// ler todos os eventos da EDT corrente			
		dbSelectArea("AFP")
		AFP->(dbSetOrder(5))
		AFP->(MsSeek(xFilial("AFP") + DToS(mv_par03), .T.))
	  	dDataAnt := AFP->AFP_DTCALC
	  	
	  	oProjeto:Cell("AF8_PROJET"):SetBlock({||AFP->AFP_PROJET})
	  	oProjeto:Cell("AF8_DESCRI"):SetBlock({||Substr(GetProjDesc(AFP->AFP_PROJET), 1, 30)})
	  	
	  	oEdt:Cell("AFC_EDT"):SetBlock({||AFP->AFP_EDT})
	  	oEdt:Cell("AFC_DESCRI"):SetBlock({||GetEDTDesc(AFC->AFC_EDT)})


	  	oTarefa:Cell("AF9_TAREFA"):SetBlock({||AFP->AFP_TAREFA})
	  	oTarefa:Cell("AF9_DESCRI"):SetBlock({||GetTaskDesc(AFP->AFP_TAREFA)})

	  	oEvento:Init()
		oReport:SetMeter(AFP->(RecCount()))
			
		While !AFP->(Eof()) .And. AFP->AFP_DTCALC <= mv_par04
			// pula para o proximo projeto se foi informada
			// uma versao e esta nao e igual ao do projeto
			If RetProj()
				AF8->(dbSkip())
				Loop
			EndIf

			// pula para o proximo evento          
			// se a data prevista calculada esta fora da faixa informada
			// se a data prevista informada esta fora da faixa informada
			// se a data realizada esta fora da faixa informada
			If (AFP->AFP_DTCALC < mv_par03 .Or. AFP->AFP_DTCALC > mv_par04) .Or. (AFP->AFP_DTPREV < mv_par05 .Or. AFP->AFP_DTPREV > mv_par06) .Or. AFP->AFP_DTATU < mv_par07 .Or. AFP->AFP_DTATU > mv_par08
				dbSelectArea("AFP")
				AFP->(dbSkip())
				Loop
			EndIf

			oReport:IncMeter()
			If dDataAnt != AFP->AFP_DTCALC
				oReport:ThinLine()
			EndIf

            oProjeto:Init()
            oProjeto:PrintLine()
            oProjeto:Finish()

			If !Empty(AFP->AFP_EDT)
				oEdt:Init()
				oEdt:PrintLine()
				oEdt:Finish()
				oReport:SkipLine()

			EndIf
			
			If !Empty(AFP->AFP_TAREFA)
				oTarefa:Init()
				oTarefa:PrintLine()
				oTarefa:Finish()
				oReport:SkipLine()
			EndIf
			
			oEvento:PrintLine()
			If oReport:Cancel()
				oReport:SkipLine()
				oReport:PrintText(STR0017) //"*** CANCELADO PELO OPERADOR ***"
				Exit
			EndIf
			
			
			dDataAnt := AFP->AFP_DTCALC
			
			dbSelectArea("AFP")
			AFP->(dbSkip())
			
		EndDO
		
		oEvento:Finish()
	
	//////////////////////////////////////////////////////////////////
	// DATA PREVISTA REALIZADA
	//////////////////////////////////////////////////////////////////
	Case nOrdem == 4	
		dDataAnt := "01/01/1980"
		dbSelectArea("AFP")
		AFP->(dbSetOrder(5))
		AFP->(MsSeek(xFilial("AFP") + DToS(mv_par03), .T.))
		dDataAnt := AFP->AFP_DTATU
		
	  	oProjeto:Cell("AF8_PROJET"):SetBlock({||AFP->AFP_PROJET})
	  	oProjeto:Cell("AF8_DESCRI"):SetBlock({||Substr(GetProjDesc(AFP->AFP_PROJET), 1, 30)})
	  	
	  	oEdt:Cell("AFC_EDT"):SetBlock({||AFP->AFP_EDT})
	  	oEdt:Cell("AFC_DESCRI"):SetBlock({||GetEDTDesc(AFP->AFP_EDT)})
				
	  	oTarefa:Cell("AF9_TAREFA"):SetBlock({||AFP->AFP_TAREFA})
	  	oTarefa:Cell("AF9_DESCRI"):SetBlock({||GetTaskDesc(AFP->AFP_TAREFA)})

	  	oEvento:Init()
		oReport:SetMeter(AFP->(RecCount()))

		While !AFP->(Eof()) .And. AFP->AFP_DTATU <= mv_par04
			// pula para o proximo projeto se foi informada
			// uma versao e esta nao e igual ao do projeto
			If RetProj()
				AF8->(dbSkip())
				Loop
			EndIf	

			// pula para o proximo evento          
			// se a data prevista calculada esta fora da faixa informada
			// se a data prevista informada esta fora da faixa informada
			// se a data realizada esta fora da faixa informada
			If (AFP->AFP_DTCALC < mv_par03 .Or. AFP->AFP_DTCALC > mv_par04) .Or. (AFP->AFP_DTPREV < mv_par05 .Or. AFP->AFP_DTPREV > mv_par06) .Or. AFP->AFP_DTATU < mv_par07 .Or. AFP->AFP_DTATU > mv_par08
				dbSelectArea("AFP")
				AFP->(dbSkip())
				Loop
			EndIf

			If Empty(AFP->AFP_DTATU)
				dDataAnt := AFP->AFP_DTATU
				dbSelectArea("AFP")
				AFP->(dbSkip())
				Loop
			EndIf

			oReport:IncMeter()

			If dDataAnt != AFP->AFP_DTATU .And. !Empty(dDataAnt)
				oReport:ThinLine()
			EndIf
			
			oProjeto:Init()
			oProjeto:PrintLine()
			oProjeto:Finish()
			
			If !Empty(AFP->AFP_EDT)
				oEdt:Init()
				oEdt:PrintLine()
				oEdt:Finish()
				oReport:SkipLine()
			EndIf
			
			If !Empty(AFP->AFP_TAREFA)
				oTarefa:Init()
				oTarefa:PrintLine()
				oTarefa:Finish()
				oReport:SkipLine()
			EndIf
			
			oEvento:PrintLine()
			dDataAnt := AFP->AFP_DTATU
     
			If oReport:Cancel()
				oReport:SkipLine()
				oReport:PrintText(STR0017) //"*** CANCELADO PELO OPERADOR ***"
				Exit
			EndIf
			
			dbSelectArea("AFP")
			AFP->(dbSkip())
			
		EndDO
		
		oEvento:Finish()
	
EndCase	

RestArea(aArea)				

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �GetEDTDesc� Autor � Adriano Ueda          � Data � 15.07.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna a descricao da EDT                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Descricacao da EDT                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cCode - codigo da EDT                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function GetEDTDesc(cCode)
Local aAreaAFC := GetArea("AFC")
Local cBuffer  := ""

dbSelectArea("AFC")
AFC->(dbSetOrder(1))

If AFC->(MSSeek(xFilial("AFC") + cCode))
	cBuffer := AFC->AFC_DESCRI
EndIf

RestArea(aAreaAFC)
Return cBuffer

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �GetTaskCod| Autor � Adriano Ueda          � Data � 15.07.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna a descricao da tarefa                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Retorna a descricao da tarefa informada via codigo          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cCode - codigo da tarefa                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function GetTaskDesc(cCode)
	Local aAreaAF9 := GetArea("AF9")
	Local cBuffer  := ""

	dbSelectArea("AF9")
	AF9->(dbSetOrder(1))

	If AF9->(MSSeek(xFilial("AF9") + cCode))
		cBuffer := AF9->AF9_DESCRI
	EndIf

	RestArea(aAreaAF9)
Return cBuffer

Static Function RetProj()
	Local lRet	:= .F.

	If (!Empty(mv_par09) .And. AF8->AF8_REVISA != mv_par09) .Or. (Empty(mv_par09) .And. AF8->AF8_REVISA != PMSAF8Ver(AF8->AF8_PROJET))
		lRet := .T.
	EndIf

Return lRet