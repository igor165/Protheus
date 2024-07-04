#include "RDIATSC.CH"
#include "RwMake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RDiatSC   �Autor  �Demetrio De Los Rios� Data �  09/07/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Relatorio que imprime movimentos do mes em questao         ���
���          � documentos de entrada/saida com/sem beneficio DIAT - SC    ���
�������������������������������������������������������������������������͹��
���Uso       � RDiatSC                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function RDiatSC()

Local oReport     
Local cPerg := "RELDIAT"

If FindFunction("TRepInUse") .And. TRepInUse()
	If Pergunte(cPerg,.T.)
		oReport := RDefDiat(cPerg)
		oReport:SetParam(cPerg)
		oReport:PrintDialog()
	EndIf 
EndIf
      

Return  
    
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RDefDiat  �Autor  �Demetrio De Los Rios� Data �  09/07/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao principal do relatorio                              ���
�������������������������������������������������������������������������͹��
���Uso       � RDiatSC                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RDefDiat()

Local oSection1	:= NIL  
Local oSection2	:= NIL    
Local oSection3	:= NIL  
Local oSection4	:= NIL  
Local cAlias	:= GetNextAlias() 
Local cAlias2	:= GetNextAlias() 
Local cAlias3	:= GetNextAlias() 
Local cAlias4	:= GetNextAlias()     
Local cAliSFT	:= "SFT"
Local oReport := TReport():New(FunName(),STR0002,"RelDiat",{|oReport| PrintReport(oReport,cAlias,cAlias2,cAlias3,cAlias4)},STR0001)//"Este relatorio ira imprimir a relacao dos documentos emitidos no Regime Especial - DIAT-SC."//"Movimentos - Beneficio DIAT"
          
oSection1 := TRSection():New(oReport,OemToAnsi(STR0003),{cAliSFT},,.F.,.F.)      //"Entradas - Importa��o com Beneficio"
TRCell():New(oSection1,"FT_EMISSAO",cAlias)		;TRCell():New(oSection1,"FT_NFISCAL",cAlias)	;TRCell():New(oSection1,"FT_SERIE",cAlias) 
TRCell():New(oSection1,"FT_ITEM",cAlias)		;TRCell():New(oSection1,"CD5_NDI",cAlias)		;TRCell():New(oSection1,"FT_VALCONT",cAlias)       
TRCell():New(oSection1,"FT_BASEICM",cAlias)		;TRCell():New(oSection1,"FT_ALIQICM",cAlias)	;TRCell():New(oSection1,"FT_VALICM",cAlias)  
TRCell():New(oSection1,"FT_CRDPRES",cAlias)		;TRCell():New(oSection1,"FT_OBSERV",cAlias)       
oSection1:SetHeaderPage(.F.)

oSection2 := TRSection():New(oReport,OemToAnsi(STR0004),{cAliSFT},,.F.,.F.)      //"Entradas - Importa��o sem Beneficio"
TRCell():New(oSection2,"FT_EMISSAO",cAlias2)	;TRCell():New(oSection2,"FT_NFISCAL",cAlias2)	;TRCell():New(oSection2,"FT_SERIE",cAlias2)   
TRCell():New(oSection2,"FT_ITEM",cAlias)		;TRCell():New(oSection2,"CD5_NDI",cAlias2)		;TRCell():New(oSection2,"FT_VALCONT",cAlias2)       
TRCell():New(oSection2,"FT_BASEICM",cAlias2)	;TRCell():New(oSection2,"FT_ALIQICM",cAlias2)	;TRCell():New(oSection2,"FT_VALICM",cAlias2)  
TRCell():New(oSection2,"FT_CRDPRES",cAlias2)	;TRCell():New(oSection2,"FT_OBSERV",cAlias2)                                                                                                                
oSection2:SetHeaderPage(.F.) 

oSection3 := TRSection():New(oReport,OemToAnsi(STR0005),{cAliSFT},,.F.,.F.)      //"Sa�das - com Beneficio"
TRCell():New(oSection3,"FT_EMISSAO",cAlias3)	;TRCell():New(oSection3,"FT_NFISCAL",cAlias3)	;TRCell():New(oSection3,"FT_SERIE",cAlias3)   
TRCell():New(oSection3,"FT_ITEM",cAlias3)		;TRCell():New(oSection3,"CD5_NDI",cAlias3)		;TRCell():New(oSection3,"FT_VALCONT",cAlias3)       
TRCell():New(oSection3,"FT_BASEICM",cAlias3)	;TRCell():New(oSection3,"FT_ALIQICM",cAlias3)	;TRCell():New(oSection3,"FT_VALICM",cAlias3)  
TRCell():New(oSection3,"FT_CRDPRES",cAlias3)	;TRCell():New(oSection3,"FT_OBSERV",cAlias3) 
oSection3:SetHeaderPage(.F.)

oSection4 := TRSection():New(oReport,OemToAnsi(STR0006),{cAliSFT},,.F.,.F.)      //"Sa�das - sem Beneficio"
TRCell():New(oSection4,"FT_EMISSAO",cAlias4)	;TRCell():New(oSection4,"FT_NFISCAL",cAlias4) 	;TRCell():New(oSection4,"FT_SERIE",cAlias4)   
TRCell():New(oSection4,"FT_ITEM",cAlias4)		;TRCell():New(oSection4,"CD5_NDI",cAlias4)		;TRCell():New(oSection4,"FT_VALCONT",cAlias4)       
TRCell():New(oSection4,"FT_BASEICM",cAlias4)	;TRCell():New(oSection4,"FT_ALIQICM",cAlias4)	;TRCell():New(oSection4,"FT_VALICM",cAlias4)  
TRCell():New(oSection4,"FT_CRDPRES",cAlias4)	;TRCell():New(oSection4,"FT_OBSERV",cAlias4)   
oSection4:SetHeaderPage(.F.)

oSection1:SetAutoSize()
oSection2:SetAutoSize()         
oSection3:SetAutoSize() 
oSection4:SetAutoSize()   
oReport:SetTotalInLine(.T.)
oReport:ParamReadOnly()

Return oReport         


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PrintReport�Autor �Demetrio De Los Rios� Data �  09/07/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta as Sections, Query principal e chama rotina que      ���
���          � executa o relatorio pra cada secao                         ���       
�������������������������������������������������������������������������͹��
���Parametros� oReport = Objeto principal do relatorio                    ���
���          � cAlias1;cAlias2;cAlias3;cAlias4 = Alias respectivos de     ���
���          � cada secao                                                 ���
�������������������������������������������������������������������������͹��
���Uso       � RDiatSC                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PrintReport(oReport,cAlias1,cAlias2,cAlias3,cAlias4)  

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local oSection3 := oReport:Section(3) 
Local oSection4 := oReport:Section(4)    
Local lSigaEIC	:= SuperGetMv("MV_EASY")=="S"    
Local cCampo	:= GetNewPar("MV_PRDDIAT","")  
Local lFTDiat	:= !Empty(cCampo)
Local cSelect 	:= ""
Local cFrom 	:= ""
Local cWhere	:= ""
Local cOrderBy 	:= ""     
Local nCont		:= 0  
Local aTxtTot	:= {STR0007,STR0010,STR0016}
Local aSetField	:= {}  
Local cTpMov	:= ""                            
Local aSection 	:= {	{oSection1,STR0008,	{STR0007,STR0010,STR0009},"E"," AND SFT.FT_B1DIAT='1'" ,cAlias1},;
					  	{oSection2,STR0011,	aTxtTot					 ,"E"," AND SFT.FT_B1DIAT<>'1'",cAlias2} ,;
					  	{oSection3,STR0012,	aTxtTot					 ,"S"," AND SFT.FT_B1DIAT='1'" ,cAlias3} ,;
					  	{oSection4,STR0013,	aTxtTot					 ,"S"," AND SFT.FT_B1DIAT<>'1'",cAlias4}}  

//��������������������������������������������������������������Ŀ
//� Executa o relatorio somente se a Diat estiver implementada   �
//����������������������������������������������������������������              
If lFTDiat     
                    
	//��������������������������������������������������������������Ŀ
	//� Imprime Mes/Ano de referencia                                �
	//����������������������������������������������������������������
	oReport:PrintText(STR0014+Space(1)+StrZero(Month(MV_PAR01),2)+"/"+StrZero(Year(MV_PAR01),4) )       //'M�S/ANO DE REFER�NCIA:'
	oReport:SkipLine();oReport:SkipLine()
	                         
	//��������������������������������������������������������������Ŀ
	//� Estrutura Principal da Query                                 �
	//����������������������������������������������������������������
	//���������������������������������������Ŀ
	//� Campos - SELECT                       �
	//�����������������������������������������
	cSelect := "%"
	cSelect += " SFT.FT_EMISSAO " 
	cSelect += ", SFT.FT_NFISCAL "  
	cSelect += ", SFT.FT_SERIE "
	cSelect += ", SFT."+SerieNfId('SFT',3,'FT_SERIE')+" FT_SERIEX "
	cSelect += ", SFT.FT_VALCONT "
	cSelect += ", SFT.FT_CLIEFOR "
	cSelect += ", SFT.FT_LOJA "   
	cSelect += ", SFT.FT_ITEM "     
	cSelect += ", SFT.FT_BASEICM "
	cSelect += ", SFT.FT_ALIQICM "
	cSelect += ", SFT.FT_VALICM "
	cSelect += ", SFT.FT_CRDPRES "   
	cSelect += ", SFT.FT_OBSERV "
	cSelect += ", CD5.CD5_NDI"
	cSelect += "%"        	 
	//���������������������������������������Ŀ
	//� Tabelas - FROM / JOIN                 �
	//�����������������������������������������
	cFrom := "% "
	cFrom += RetSqlName("SFT")+ " SFT " 
	cFrom += " LEFT JOIN " + RetSqlName("CD5") + " CD5 "
	cFrom += " ON CD5.CD5_FILIAL='" + xFilial("CD5") + "' AND CD5.CD5_DOC = SFT.FT_NFISCAL "
	cFrom += " AND CD5.CD5_SERIE=SFT.FT_SERIE AND CD5.CD5_FORNEC=SFT.FT_CLIEFOR AND CD5.CD5_LOJA=SFT.FT_LOJA"
	cFrom += " AND CD5.D_E_L_E_T_=' '"
	cFrom += "%"
	//���������������������������������������Ŀ
	//� Condicoes - WHERE                     �
	//�����������������������������������������
	cWhere := "% " 
	cWhere += " SFT.FT_FILIAL ='" + MV_PAR03 + "' "
	cWhere += " AND SFT.FT_EMISSAO BETWEEN '" + DToS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "   
	cWhere += " AND SFT.FT_DTCANC = ' ' "    
	cWhere += " AND SFT.D_E_L_E_T_=' ' "     
	      
	cOrderBy :=	" ORDER BY 1,2,3%"                                
	aAdd(aSetField,{"FT_EMISSAO","D",8,0})    
	
	For nCont:=1 to Len(aSection)    
		//�������������������������������������������������Ŀ
		//� Funcao que executa relatorio para cada SECTION  �
		//���������������������������������������������������    
		cTpMov := " AND SFT.FT_TIPOMOV = '"+aSection[nCont,4]+ "' " 
		FExecSec(oReport,aSection[nCont,3],cSelect,cFrom,cWhere,cOrderBy,cTpMov,aSection[nCont,5],aSection[nCont,6],aSection[nCont,1],aSection[nCont,2],lSigaEIC,aSetField)
	Next nCont    
	 
EndIf                    

Return      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FExecSec  �Autor  �Demetrio De Los Rios� Data �  09/07/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao principal executada para cada Section               ���
�������������������������������������������������������������������������͹��
���Parametros� oReport = Objeto principal do relatorio                    ���
���          � aTextTot = Array contendo Descricao dos totais             ���    
���          � cSelect = Estrura principal do Select da query             ���
���          � cFrom = Estrutura principal do FROM da query               ���
���          � cWhere = Condicoes principais da query                     ���
���          � cOrderBy = Ordenacao da query principal                    ���    
���          � cTpMov = 'E' ou 'S' para uso na query principal            ���
���          � cAuxWhere = Filtro do campo utilizado na implementacao DIAT���
���          � cAlias = Alias da Section corrente                         ���
���          � oSection = Secao corrente                                  ���
���          � cPrintText = Titulo da Secao                               ���
���          � lSigaEIC = Logico se possui integracao com EIC             ���
���          � aSetField = Array com campos para TcSetField               ���
�������������������������������������������������������������������������͹��
���Uso       � RDiatSC                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FExecSec(oReport,aTextTot,cSelect,cFrom,cWhere,cOrderBy,cTpMov,cAuxWhere,cAlias,oSection,cPrintText,lSigaEIC,aSetField)
                 
Local aInfEIC 		:= {}	   					// Array utilizado para retorno das informacoes do SIGAEIC       
Local nTotVal  		:= 0	   					// Variavel para acumular TOTAL de Valor Contabil
Local nTotICM		:= 0						// Variavel para acumular TOTAL de Valor ICMS
Local nTotCrdPr		:= 0   						// Variavel para acumular TOTAL de Valor Credito Presumido
Local cDi			:= "" 						// Numero da DI  
Local lPrintTot		:= .F.     					// Caso haja informacoes impressas, imprime totalizadores 
Local nI			:= 0        		   		// Contador
Local cPict 		:= '@E 999,999,999.99'  	// Picture dos Totalizadores    
Local cNotInfo 		:= STR0015//'N�o h� informa��es para essa se��o.'

Default lSigaEIC 	:= .F.
    
//���������������������������������Ŀ
//� Monta Query                     �
//�����������������������������������
#IFDEF TOP
	If (TcSrvType ()<>"AS/400")  
		oSection:BeginQuery()
		BeginSql Alias cAlias
			SELECT 
				%Exp:cSelect%
			FROM 
				%Exp:cFrom%
			WHERE 
				%Exp:cWhere+cTpMov+cAuxWhere+cOrderBy%
		EndSql                                 
		oSection:EndQuery()
		For nI := 1 To Len(aSetField)
			TcSetField(cAlias,aSetField[nI,1],aSetField[nI,2],aSetField[nI,3],aSetField[nI,4])
		Next
	EndIf
#ENDIF	   

oSection:Init()             
oReport:PrintText(cPrintText)
While (cAlias)->(!EOF())  .AND. !oReport:Cancel()
 	
	oSection:Cell("FT_EMISSAO"):SetBlock({|| 	(cAlias)->FT_EMISSAO	} ) 
	oSection:Cell("FT_NFISCAL"):SetBlock({|| 	(cAlias)->FT_NFISCAL  	} )  
	oSection:Cell("FT_SERIE"):SetBlock({|| 		(cAlias)->FT_SERIEX		} )
	oSection:Cell("FT_VALCONT"):SetBlock({|| 	(cAlias)->FT_VALCONT	} )  
	oSection:Cell("FT_BASEICM"):SetBlock({|| 	(cAlias)->FT_BASEICM	} )
	oSection:Cell("FT_ITEM"):SetBlock({|| 		(cAlias)->FT_ITEM		} )
	oSection:Cell("FT_ALIQICM"):SetBlock({|| 	(cAlias)->FT_ALIQICM	} )
	oSection:Cell("FT_VALICM"):SetBlock({|| 	(cAlias)->FT_VALICM		} )
	oSection:Cell("FT_CRDPRES"):SetBlock({|| 	(cAlias)->FT_CRDPRES	} )  
	oSection:Cell("FT_OBSERV"):SetBlock({|| 	(cAlias)->FT_OBSERV		} )
    
	//�����������������������������������������������������������������������������������������Ŀ
	//� Informacoes da DI - Caso tenha integracao com SIGAEIC ou complemento da Nota            �
	//�������������������������������������������������������������������������������������������
	If lSigaEIC                                                                             
		aInfEIC := (cAlias)->(AvGetImpSped(xFilial("SF1"),FT_NFISCAL,FT_SERIE,FT_CLIEFOR,FT_LOJA))   
		cDi := Iif(Len(aInfEIC)>0,aInfEIC[1,2,2,2,1],"") 
		oSection:Cell("CD5_NDI" ):SetBlock({|| cDi } ) 
	Else
		oSection:Cell("CD5_NDI" ):SetBlock({|| AllTrim(cValToChar((cAlias)->CD5_NDI))} ) 
	EndIf            

	//���������������������������������Ŀ
	//� Totalizadores                   �
	//�����������������������������������
	nTotVal 	+= (cAlias)->FT_VALCONT        
	nTotICM		+= (cAlias)->FT_VALICM
	nTotCrdPr   += (cAlias)->FT_CRDPRES
  	lPrintTot 	:= .T. 
	oSection:PrintLine()
	oReport:IncMeter()   
	
	(cAlias)->(dbSkip())   
EndDo                
      
//�����������������������������������������������������������������������������������������Ŀ
//� Impressao de totalizadores - Totalizacao manual devido ao layout pedido pelo cliente    �
//�������������������������������������������������������������������������������������������
If lPrintTot  
	oReport:SkipLine()       
	
	// Total Valor Contabil
	If nTotVal>0
		oReport:PrintText(aTextTot[1]+Space(3) + PadL(Transform(nTotVal,cPict),15)  )    
	EndIf    
	
	// Total Valor ICMS
	If nTotICM>0	
		oReport:PrintText(aTextTot[2]+Space(7) + PadL(Transform(nTotICM,cPict),15)  )     
	EndIf              
	
	// Total Valor Credito Presumido
	If nTotCrdPr>0
		oReport:PrintText(aTextTot[3]+ PadL(Transform(nTotCrdPr,cPict),15)  )
	EndIf        
Else 
	oReport:PrintText(cNotInfo) // Nao ha informacoes para essa secao 
EndIf  

oReport:SkipLine();oReport:SkipLine()        
oSection:Finish()  
(cAlias)->(dbCloseArea())

Return Nil   
