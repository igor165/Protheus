#INCLUDE "GimPB.ch"
#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GimPB     �Autor  �Mary C. Hergert     � Data � 14/03/2005  ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta wizard com as informacoes necessarias a GIMPB         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GimPB(lProcWiz)                     
       
	Local aRetorno := GimPBWiz(@lProcWiz)

Return(aRetorno) 

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �GimPBWiz    �Autor  �Mary C. Hergert     � Data � 14/03/2005  ���
���������������������������������������������������������������������������͹��
���Desc.     �Monta a wizard com as perguntas necessarias                   ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       �GimPB                                                         ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function GimPBWiz(lProcWiz)   

	//������������������������Ŀ
	//�Declaracao das variaveis�
	//��������������������������
	Local aTxtPre 		:= {}
	Local aPaineis 		:= {}
	Local cTitObj1		:= ""
	Local aRetorno		:= {}
	
	Local nPos			:= 0
	
	//�����������������������������������������Ŀ
	//�Monta wizard com as perguntas necessarias�
	//�������������������������������������������
	aAdd(aTxtPre,STR0001) //"GIM - Paraiba"
	aAdd(aTxtPre,STR0002) //"Aten��o"
	aAdd(aTxtPre,STR0003) //"Preencha corretamente as informa��es solicitadas."
	aAdd(aTxtPre,STR0004+STR0005)	//"Esta rotina ira gerar as informacoes referentes a GIM-PB"
									//"Guia de Informa��es Mensais - Para�ba"
	//�������������������������������������Ŀ
	//�Painel 1 - Informacoes Gerais        �
	//���������������������������������������
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0006) //"Assistente de parametriza��o" 
	aAdd(aPaineis[nPos],STR0007) //"Informacoes sobre a Empresa"
	aAdd(aPaineis[nPos],{})
	//
	cTitObj1 :=	STR0008 //"Versao do programa da GIM: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,Replicate("X",4),1,,,,4})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0009 //"Regime de Pagamento: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{3,,,,,{STR0010,STR0011,STR0046},,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0012 //"E-mail do Contribuinte: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,Replicate("X",40),1,,,,40})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0013 //"Inicio das Atividades da Empresa: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0031 //"Numero de Funcionarios: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"999",2,0,,,3})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0032 //"Receita Bruta Anual referente ao ano anterior: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@E 9999999999.99",2,2,,,13})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	//���������������������������������������Ŀ
	//�Painel 2 - Informacoes Sobre o Contador|
	//�����������������������������������������
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0006) //"Assistente de parametriza��o" 
	aAdd(aPaineis[nPos],STR0014) //"Informa��es sobre o Contador"
	aAdd(aPaineis[nPos],{})

   	cTitObj1 :=	STR0015 //"CPF/CNPJ: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,Replicate("X",14),1,,,,14})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //
   	cTitObj1 :=	STR0016 //"CRC: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,Replicate("X",10),1,,,,10})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //
   	cTitObj1 :=	STR0017 //"Nome: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,Replicate("X",40),1,,,,40})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //
   	cTitObj1 :=	STR0018 //"Telefone: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,Replicate("X",12),1,,,,12})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //
   	cTitObj1 :=	STR0019 //"E-mail: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,Replicate("X",40),1,,,,40})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //

	//�������������������������������������Ŀ
	//�Painel 3 - Saldos e Despesas         �
	//���������������������������������������
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0006) //"Assistente de parametriza��o" 
	aAdd(aPaineis[nPos],STR0020) //"Saldos e Despesas"
	aAdd(aPaineis[nPos],{})

	cTitObj1 :=	STR0021 //"Saldo em Caixa: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@E 9999999999.99",2,2,,,13})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0022 //"Saldo em Banco: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@E 9999999999.99",2,2,,,13})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //
	cTitObj1 :=	STR0023 //"Depesas com pessoal, terc., pro-labore: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@E 9999999999.99",2,2,,,13})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0024 //"Outros Impostos e Encargos: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@E 9999999999.99",2,2,,,13})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0025 //"Despesas Gerais: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@E 9999999999.99",2,2,,,13})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//

	//�������������������������������������Ŀ
	//�Painel 5 - Credito Presumido         �
	//���������������������������������������
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0006) //"Assistente de parametriza��o" 
	aAdd(aPaineis[nPos],STR0026) //"Credito Presumido (apenas para Regime de Apura��o Normal)"
	aAdd(aPaineis[nPos],{})

	cTitObj1 :=	STR0027 //"Outros Regimes Especiais: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@E 9999999999.99",2,2,,,13})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //
	cTitObj1 :=	STR0028 //"TARE: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@E 9999999999.99",2,2,,,13})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //
	cTitObj1 :=	STR0029 //"Previs�o no RICMS: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@E 9999999999.99",2,2,,,13})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //
	cTitObj1 :=	STR0030 //"FAIN: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@E 9999999999.99",2,2,,,13})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //                                          
	cTitObj1 :=	STR0033 //"Cheque Habita��o: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@E 9999999999.99",2,2,,,13})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //
	cTitObj1 :=	STR0034 //"Cheque Educa��o: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@E 9999999999.99",2,2,,,13})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //
    cTitObj1 :=	STR0035 //"Gol de Placa: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@E 99999999999.99",2,2,,,13})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //
    cTitObj1 :=	STR0036 //"FIC(Fundo Incentivo a Cultura): "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@E 99999999999.99",2,2,,,13})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //
    //�������������������������������������������������������������������Ŀ
	//�Painel 6 - Informa��o do n�mero do recibo da GIM do m�s anterior.  |
 	//���������������������������������������������������������������������
   
   	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0006) //"Assistente de parametriza��o" 
	aAdd(aPaineis[nPos],STR0037) //"Informa��o do n�mero do recibo da GIM do m�s anterior."
	aAdd(aPaineis[nPos],{}) 
   
   	cTitObj1 :=	STR0038 //"N�mero do Recibo: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,Replicate("X",32),1,,,,32})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	// 
 	cTitObj1 :=	STR0039 //"Situa��o: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,Replicate("X",1),1,,,,1})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    //
	cTitObj1 := STR0040 //"Data da situa��o: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,}) 
	
	//���������������������������������������Ŀ
	//�Painel 7 - Informa��o Simples Nacional |
 	//�����������������������������������������
   	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0006) //"Assistente de parametriza��o" 
	aAdd(aPaineis[nPos],STR0041) //"Informa��o Simples Nacional"
	aAdd(aPaineis[nPos],{}) 
    		
	cTitObj1 :=	STR0042 //"Cat. Estabelecimento : "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{3,,,,,{STR0043,STR0044,STR0045},,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
    
	lProcWiz :=	xMagWizard(aTxtPre,aPaineis,"GimPB")
	
	If lProcWiz 
		aRetorno := GimPBLeWiz()
	Endif
	
Return(aRetorno)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �GimPBLeWiz  �Autor  �Mary C. Hergert     � Data � 14/03/2005  ���
���������������������������������������������������������������������������͹��
���Desc.     �Le a wizard com as perguntas necessarias                      ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       �GimPB                                                         ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function GimPBLeWiz()   

	//������������������������Ŀ
	//�Declaracao das variaveis�
	//��������������������������
   
	Local aWizard		:= {}
	Local aRetorno		:= {}
	
	xMagLeWiz("GimPB",@aWizard,.T.)
	
	//"01 - Versao do programa da GIM: "
	Aadd(aRetorno,Alltrim(aWizard[01][01]))
	//"02 - Regime de Pagamento: "               
	If SubStr(Alltrim(aWizard[01][02]),1,1) == "E" 
		Aadd(aRetorno,"1")
	Elseif SubStr(Alltrim(aWizard[01][02]),1,1) == "P"
		Aadd(aRetorno,"7")
	Else
		Aadd(aRetorno,"3")
	Endif						
	//"03 - E-mail do Contribuinte: "            
	Aadd(aRetorno,Alltrim(aWizard[01][03]))
	//"04 - Inicio das Atividades da Empresa: "  
	Aadd(aRetorno,cTod(SubStr(Alltrim(aWizard[01][04]),7,2) + "/" + SubStr(Alltrim(aWizard[01][04]),5,2) + "/" + SubStr(Alltrim(aWizard[01][04]),1,4)))
	//"05 - CPF/CNPJ: "                          
	Aadd(aRetorno,Alltrim(aWizard[02][01]))
	//"06 - CRC: "                               
	Aadd(aRetorno,Alltrim(aWizard[02][02]))
	//"07 - Nome: "                              
	Aadd(aRetorno,Alltrim(aWizard[02][03]))
	//"08 - Telefone: "                          
	Aadd(aRetorno,Alltrim(aWizard[02][04]))
	//"09 - E-mail: "                            
	Aadd(aRetorno,Alltrim(aWizard[02][05]))
	//"10 - Saldo em Caixa: "                    
	Aadd(aRetorno,Val(aWizard[03][01]))
	//"11 - Saldo em Banco: "                
	Aadd(aRetorno,Val(aWizard[03][02]))
	//"12 - Depesas com pessoal, terc., pro-labore: "
	Aadd(aRetorno,Val(aWizard[03][03]))
	//"13 - Outros Impostos e Encargos: "    
	Aadd(aRetorno,Val(aWizard[03][04]))
	//"14 - Despesas Gerais: "               
	Aadd(aRetorno,Val(aWizard[03][05]))
	//"15 - Outros Regimes Especiais: "      
	Aadd(aRetorno,Val(aWizard[04][01]))
	//"16 - TARE: "                          
	Aadd(aRetorno,Val(aWizard[04][02]))
	//"17 - Previs�o no RICMS: "             
	Aadd(aRetorno,Val(aWizard[04][03]))
	//"18 - FAIN: "                          
	Aadd(aRetorno,Val(aWizard[04][04]))   
	//"19 - Numero de Funcion�rios: "
	Aadd(aRetorno,Val(aWizard[01][05]))   		
	//"20 - Receita Bruta Anual referente ao ano anterior: "
	Aadd(aRetorno,Val(aWizard[01][06]))   
	//"21 - Cheque Habita��o: "                      
	Aadd(aRetorno,Val(aWizard[04][05]))   		
	//"22 - Cheque Educa��o: "                       
	Aadd(aRetorno,Val(aWizard[04][06]))   		
	//"23 - Gol de Placa: "
	Aadd(aRetorno,Val(aWizard[04][07]))   		
	//"24 - FIC(Fundo de Incentivo a Cultura): "                       
	Aadd(aRetorno,Val(aWizard[04][08]))   		
	//"25 - N�mero do Recibo: "                       
	Aadd(aRetorno,Alltrim(aWizard[05][01]))  		
	//"26 - Situa��o: " 
	Aadd(aRetorno,Alltrim(aWizard[05][02]))                      
	//"27 - Data Situa��o: "                       
	Aadd(aRetorno,cTod(SubStr(Alltrim(aWizard[05][03]),7,2) + "/" + SubStr(Alltrim(aWizard[05][03]),5,2) + "/" + SubStr(Alltrim(aWizard[05][03]),1,4)))
	//"28 - Cat. Estabelecimento : " 
	Aadd(aRetorno,SubStr(Alltrim(aWizard[06][01]),1,1))
Return(aRetorno)
	
