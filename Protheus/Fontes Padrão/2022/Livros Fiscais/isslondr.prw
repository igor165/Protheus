/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ISSLONDR  �Autor  �Mary C. Hergert     � Data �  23/02/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Gera um temporario para apresentar as informacoes dos cli-  ���
���          �entes e fornecedores do arquivo ISSQN de Lonfrina - PR      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ISSLondr(nOpcao,aDados,aTmp)

If nOpcao == 1
	// Cria o temporario
	aTmp := LondrCria()
ElseIf nOpcao == 2
	// Carrega as informacoes
	LondrCar(aDados)	
Else                          
	// Deleta o temporario
	LondrDel(aTmp)
Endif
	                            
Return aTmp

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LondrCar  �Autor  �Mary C. Hergert     � Data �  23/02/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria o arquivo temporario.                                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LondrCria(aDados)

Local aStru := {}
Local cArq 	:= ""  

aAdd(aStru,{"CPF_CNPJ" ,"C",TamSX3("A1_CGC")[01],0})
aAdd(aStru,{"IE"       ,"C",TamSX3("A1_INSCR")[01],0})
aAdd(aStru,{"NOME"     ,"C",TamSX3("A1_NOME")[01],0})
aAdd(aStru,{"ENDERECO" ,"C",TamSX3("A1_END")[01],0})
aAdd(aStru,{"NUMEND"   ,"C",10,0})
aAdd(aStru,{"COMPLEND" ,"C",40,0})
aAdd(aStru,{"BAIRRO"   ,"C",TamSX3("A1_BAIRRO")[01],0})
aAdd(aStru,{"CIDADE"   ,"C",TamSX3("A1_MUN")[01],0})
aAdd(aStru,{"UF"       ,"C",TamSX3("A1_EST")[01],0})
aAdd(aStru,{"CEP"      ,"C",TamSX3("A1_CEP")[01],0})
aAdd(aStru,{"TEL"      ,"C",TamSX3("A1_TEL")[01],0})
aAdd(aStru,{"EMAIL"    ,"C",TamSX3("A1_EMAIL")[01],0})
cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"TMP")
IndRegua("TMP",cArq,"CPF_CNPJ")
TMP->(dbClearIndex())
TMP->(dbSetIndex(cArq+OrdBagExt()))
TMP->(dbSetOrder(1))

Return {cArq,"TMP"}

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LondrCar  �Autor  �Mary C. Hergert     � Data �  23/02/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega o arquivo temporario.                               ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LondrCar(aDados)

Local aEnd	:= {}

If !TMP->(dbSeek(aDados[01]))
	aEnd := FisGetEnd(aDados[04])
	RecLock("TMP",.T.)           
	TMP->CPF_CNPJ 	:= aDados[01]
	TMP->IE 		:= aDados[02]
	TMP->NOME 		:= aDados[03]
	TMP->ENDERECO 	:= aEnd[01]
	TMP->NUMEND		:= aEnd[03]
	TMP->COMPLEND	:= aEnd[04]
	TMP->BAIRRO 	:= aDados[05]
	TMP->CIDADE 	:= aDados[06]
	TMP->UF 		:= aDados[07]
	TMP->CEP 		:= aRetDig(aDados[08],.F.,"")
	TMP->TEL 		:= aRetDig(aDados[09],.F.,"")
	TMP->EMAIL 		:= aDados[10]
	MsUnLock()
Endif

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LondrCar  �Autor  �Mary C. Hergert     � Data �  23/02/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Deleta o arquivo temporario.                                ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LondrDel(aTmp)
                                                
Local aAreaDel := GetArea()

If File(aTmp[1]+GetDBExtension())
	dbSelectArea(aTmp[2])
	dbCloseArea()
	Ferase(aTmp[1]+GetDBExtension())
	Ferase(aTmp[1]+OrdBagExt())
Endif	

RestArea(aAreaDel)

Return .T.