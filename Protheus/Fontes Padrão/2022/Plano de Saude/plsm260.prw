#include "Protheus.ch"
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF
#define MOEDA "@E 9999999.99"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLSM260  บAutor  ณMicrosiga           บ Data ณ  23/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Selecao e envio de informacoes referentes a Dmed           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLSM260()
Local nOpca      	:= 0
Local aSays      	:= {}
Local aButtons   	:= {}
Local cCadastro  	:= FunDesc() //"Declara็ใo DMED"

Static lCMPCUS		:= .F. // Verifica se existem os campos BFQ_CMPCUS e BSP_CMPCUS para definir os eventos de lan็amentos ou lan็amentos de cobran็a que serใo considerados no custo.
Private cPerg    	:= "PLSM260"/**/
Private cTpDoc	 	:= GetNewPar('MV_PLDM001','VL') //Indica quais tipos de titulos o sistema deve considerar para somatoria do valor financeiro. Sem parโmetro considera o tipo 'VL' (E5_TIPODOC)
Private cTpBaixa 	:= GetNewPar('MV_PLDM002','DAC') //Indica motivos de baixa de tํtulos a receber que nใo serใo considerados no valor financeiro. Sem o parโmetro considera o motivo DAC - E5_MOTBX
Private cCodNEve 	:= GetNewPar("MV_PLDM003","") //Indica c๓digos de lan็amentos de cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODTIP
Private cCodEve		:= GetNewPar("MV_PLDM004","") //Indica c๓digos de eventos de lan็amentos da cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODEVE
Private lPLSA001 	:= If(GetNewPar("MV_PLDM005","1") == "1",.T.,.F.) //Indica a rotina de reembolso utilizada pelo cliente para gera็ใo da DMED. 1=Novo reembolso(PLSA001); 2=Antigo Reemb.(PLSA987)
Private cTpLanc  	:= GetNewPar("MV_PLDM006","") //Verbas da gestใo de pessoal que nใo deverใo ser consideradas para gera็ใo da DMED
Private cPeriGpe 	:= GetNewPar("MV_PLDM007","") //Altera perํodo da folha, quando nใo informado considera o perํodo padrใo, exemplo: 201002;201101
Private cCodTit  	:= GetNewPar("MV_PLCDTIT","T") //Codigo Identificador de titular do plano
Private cCpf	 	:= GetNewPar('MV_PLDMCPF','') //Informe um CPF para processar a Dmed apenas para o mesmo, parametro NAO publicado no boletim
Private cSituaca	:= GetNewPar('MV_PLDM008','')//Lista de E5_SITUACA a serem desconsiderados
Private cBanco   	:= Alltrim(Upper(TCGetDb()))

cTpDoc   := Replace(Replace(AllTrim(cTpDoc),", ",",")," ,",",")
cTpBaixa := Replace(Replace(AllTrim(cTpBaixa),", ",",")," ,",",")
cTpLanc  := Replace(Replace(AllTrim(cTpLanc),", ",",")," ,",",")
cCodNeve := Replace(Replace(AllTrim(cCodNeve),", ",",")," ,",",")
cCodEve  := Replace(Replace(AllTrim(cCodEve),", ",",")," ,",",")

cTpDoc   := IIf(!Empty(cTpDoc),"'" + Replace(AllTrim(cTpDoc),",","','") + "'","")
cTpBaixa := IIf(!Empty(cTpBaixa),"'" + Replace(AllTrim(cTpBaixa),",","','") + "'","")
cTpLanc  := IIf(!Empty(cTpLanc),"'" + Replace(AllTrim(cTpLanc),",","','") + "'","")
cCodNeve := IIf(!Empty(cCodNeve),"'" + Replace(AllTrim(cCodNEve),",","','") + "'","")
cCodEve  := IIf(!Empty(cCodEve),"'" + Replace(AllTrim(cCodEve),",","','") + "'","")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta texto para janela de processamento                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aSays,"Gera็ใo do arquivo Dmed")//Aplicacao de reducao de custo nas contas medicas
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta botoes para janela de processamento                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.)}})
aAdd(aButtons, { 1,.T.,{|| nOpca := 1, If( ConaOk() .And. M260Perg(),FechaBatch(),nOpca := 0)}}) //Processamento
aAdd(aButtons, { 2,.T.,{|| FechaBatch()}})

SX3->(DbSetOrder(2))
lCMPCUS := SX3->(MsSeek("BFQ_CMPCUS")) .AND. SX3->(MsSeek("BSP_CMPCUS")) .AND. GetNewPar("MV_CMPCUS",.F.) == .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Exibe janela de processamento                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
FormBatch(cCadastro, aSays, aButtons, , 160)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processa importacao do arquivo texto                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpca == 1
	Processa( {||PLSM260Pro() },"Dmed - Declara็ใo de servi็os m้dicos e de sa๚de","Processando...",.T. )
EndIf

Return .T.

/*                                                                           '
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma  ณPLSM260ProบAutor  ณMicrosiga                       บ Data ณ  02/23/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.     ณ Selecao e envio de informacoes referentes a Dmed, abaixo o layout do    บฑฑ
ฑฑบ          ณ arquivo a ser criado                                                    บฑฑ
ฑฑบ          ณ                                                                         บฑฑ
ฑฑบ          ณ aDmed                                                                   บฑฑ
ฑฑบ          ณ 1 - mv_par01 ( Ano referencia )                                         บฑฑ
ฑฑบ          ณ 2 - mv_par02 ( Ano calendario )                                         บฑฑ
ฑฑบ          ณ 3 - mv_par03 S - Retificadora;N - Original ( Indicador  retiricadora )  บฑฑ
ฑฑบ          ณ 4 - mv_par04 ( Numero do recibo )                                       บฑฑ
ฑฑบ          ณ 5 - aRESPO										  					   บฑฑ
ฑฑบ          ณ 5.1 - mv_par05 ( Cpf )								  				   บฑฑ
ฑฑบ          ณ 5.2 - mv_par06 ( Nome )								  				   บฑฑ
ฑฑบ          ณ 5.3 - mv_par07 ( DDD )								  				   บฑฑ
ฑฑบ          ณ 5.4 - mv_par08 ( Telefone )								  			   บฑฑ
ฑฑบ          ณ 5.5 - mv_par09 ( Ramal )									  			   บฑฑ
ฑฑบ          ณ 5.6 - mv_par10 ( Fax )								  				   บฑฑ
ฑฑบ          ณ 5.7 - mv_par11 ( Email )									  			   บฑฑ
ฑฑบ          ณ 6 aDECPJ											  					   บฑฑ
ฑฑบ          ณ 6.1 - M0_CGC ( CNPJ )								  				   บฑฑ
ฑฑบ          ณ 6.2 - M0_NOMECOM ( Nome empresarial )					  			   บฑฑ
ฑฑบ          ณ 6.3 - 2 ( Tipo declarante )								  			   บฑฑ
ฑฑบ          ณ 6.4 - BA0_SUSEP ( Registro ANS )							  			   บฑฑ
ฑฑบ          ณ 6.5 - M0_CNES ( CNES )								  				   บฑฑ
ฑฑบ          ณ 6.6 - mv_par12 ( CPF responsavel pelo CNPJ )					  		   บฑฑ
ฑฑบ          ณ 6.7 - mv_par13 (S - Declaracao especial,N  - Nao e especial )		   บฑฑ
ฑฑบ          ณ 6.8 - mv_par14 ( Data do evento )									   บฑฑ
ฑฑบ          ณ 7 - aTOP																   บฑฑ
ฑฑบ          ณ 7.1 - BA1_CPFUSR ( BA1_TIPUSR = MV_PLCDTIT )							   บฑฑ
ฑฑบ          ณ 7.2 - BA1_NOMUSR ( Nome )											   บฑฑ
ฑฑบ          ณ 7.3 - BM1_VALOR ( Valor pago no ano com o titular )				  	   บฑฑ
ฑฑบ          ณ 7.4 - aRTOP															   บฑฑ
ฑฑบ          ณ 7.4.1 - BAU_CPFCGC - CPF/CNPJ do prestador de servico. BAU_TIPPE (F,J)  บฑฑ
ฑฑบ          ณ 7.4.2 - BAU_NOME/BAU_NFANTA ( Nome/Fantasia do prestador de servico )   บฑฑ
ฑฑบ          ณ 7.4.3 - B44_VLRPAG ( Valor reembolso do ano calendario ) 		  	   บฑฑ
ฑฑบ          ณ 7.4.4 - B44_VLRPAG ( Valor reembolso de anos anteriores )		  	   บฑฑ
ฑฑบ          ณ 7.5 - aDTOP															   บฑฑ
ฑฑบ          ณ 7.5.1 - BA1_CPFUSR ( BA1_TIPUSR <> MV_PLCDTIT ) (CPF dependente)		   บฑฑ
ฑฑบ          ณ 7.5.2 - BA1_DATNAS ( Data nascimento )			    				   บฑฑ
ฑฑบ          ณ 7.5.3 - BA1_NOMUSR ( Nome )											   บฑฑ
ฑฑบ          ณ 7.5.4 - BA1_GRAUPA ( Relacao dependencia )							   บฑฑ
ฑฑบ          ณ 7.5.5 - Utilizacao ( Valor pago no ano com o dependente )			   บฑฑ
ฑฑบ          ณ 7.5.6 - aRDTOP														   บฑฑ
ฑฑบ          ณ 7.5.6.1 - BAU_CPFCGC ( CPF/CNPJ prestador de servico BAU_TIPPE (F,J)    บฑฑ
ฑฑบ          ณ 7.5.6.2 - BAU_NOME/BAU_NFANTA ( Nome/Fantasia do prestador de servico ) บฑฑ
ฑฑบ          ณ 7.5.6.3 - B44_VLRPAG ( Valor reembolso do ano calendario )			   บฑฑ
ฑฑบ          ณ 7.5.6.4 - B44_VLRPAG ( Valor reembolso de anos anteriores )			   บฑฑ
ฑฑบ          ณ 8 - {} ( HSP )														   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                                 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSM260Pro(lAutomato)
Local lProcess	:= .T. //Indica se processa ou nแo a DMED
Local cArqLog   := "PLSDmed_" + Dtos(dDataBase) + "_" + Replace(Time(),":","") + ".LOG" // Nome do arquivo de log da execucao
Local lRetPto  := .T. // Retorno do ponto de entrada indicado para continuar ou nao o processamento		//Solicitacao CEMIG
Private lRestIr	:= IIf(B45->(FieldPos("B45_RESTIR")) <= 0, .F., .T.)
DEFAULT lAutomato := .F.

If B5A->(FieldPos("B5A_MATVID")) <= 0
    If !lAutomato
	    MsgInfo("Ambiente para processamento da DMED desatualizado. Execute o compatibilizador UPDPLS9Z.")
    EndIf
	Return .F.
EndIf

If B5A->(FieldPos("B5A_VLRANT")) <= 0
    If !lAutomato
	    MsgInfo("Ambiente para processamento da DMED desatualizado. Execute o compatibilizador UPDPLS0M.")
    EndIf
	Return .F.
EndIf

If ExistBlock("M260OK")								//Solicitacao CEMIG
	lRetPto := ExecBlock("M260OK",.F.,.F.,)		//Solicitacao CEMIG
	If !lRetPto										//Solicitacao CEMIG
		Return .F.										//Solicitacao CEMIG
	EndIf												//Solicitacao CEMIG
EndIf													//Solicitacao CEMIG


If !lAutomato
    Pergunte(cPerg,.F.)
    IncProc("Consultando registros a serem processados")
    ProcessMessage()
EndIf

If Empty(mv_par01)
	mv_par01 := 2019
EndIf

If mv_par18 == 2  //Gravacao do arquivo texto a ser transmitido para a receita
	M260File(cArqLog,lAutomato)                 
Else //Vou apenas calcular a Dmed ( gravar a tabela B5A )

	If mv_par18 == 3 //Verifica se ha dados para a parametrizacao proposta e avisa o usuario

		lProcess := M260Check()

		If !lProcess
            If !lAutomato
			    If MsgYesNo("Encontrado dados para a DMED do ano calendario "+StrZero(mv_par02,4)+"."+CHR(10)+"Deseja Continuar?","ATENCAO: Operacao Irreversivel")            	
					M260DelB5A(cArqLog)
					lProcess := .T.
				EndIf
			Else
				Return
			EndIf

		EndIf

	EndIf	

	If lProcess

		If !mv_par16 == 1//Atualizacao da Dmed com o custo medico recebido pelo financeiro
			M260Fin(cArqLog,lAutomato)
		EndIf

		If !mv_par16 == 2//Atualizacao da Dmed com o custo medico descontado em folha
			M260GPE(cArqlog,cCodTit,lAutomato)
		EndIf

		//Atualizacao da Dmed com os valores reembolsados
		M260Reemb(AllTrim(Str(mv_par01)),AllTrim(Str(mv_par02)),cArqlog,lAutomato)

		//Fim de processamento
        If !lAutomato
		    MsgInfo("Cแlculo da Dmed concluํdo com sucesso.")
        EndIf

	EndIf

EndIf
   
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณM260Reem  บAutor  ณMicrosiga           บ Data ณ  03/03/11                             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para escrever no arquivo Dmed os valores de reembolso dos beneficiarios:บฑฑ
ฑฑบ          ณ                                                                                      บฑฑ
ฑฑบ          ณ3.6 - Registro de informacao de reembolso do titular do plano ( identificador RTOP )  บฑฑ
ฑฑบ          ณ3.8 - Registro de informacao de reembolso do dependente ( identificador RDTOP )       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAPLS                                                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M260Reemb(cAnoRef,cAnoCal,cArqlog,lAutomato)
Local cChvB5A := "" //Chave para indice da B5A
Local cIdeReg := "" //Tipo de registro 2=RTOP; 4=RDTOP
Local cTpRda  := "" //Tipo de Rda 1=PF; 2=PJ
Local lGerReg := .F.
Local lCPFB44 := B44->(FieldPos("B44_CPFEXE")) > 0
Local lM260GRV:= ExistBlock("M260GRV")
Local aStru	  := {{"VLRB45","N",14,2}}
Local aTit	  := {}
Local cSql    := ""
Local cSqlSel := ""
Local cSqlFrm := ""
Local cSqlWhr := ""
Local cSqlSel1:= ""
Local cSqlFrm1:= ""
Local cSqlWhr1:= ""
Local cMatric := ""
Local cSqlFI8 := ""
Local cData	  := ""
Local oTempTable
Local nPos	  := 0	 
Local nVlrFK2 := 0
Local lGERDMD := BQC->(FieldPos("BQC_GERDMD")) > 0
Local lFLDMED := B44->(FieldPos("B44_FLDMED")) > 0
Local lREVERT := B44->(FieldPos("B44_REVERT")) <> 0
Local lBK6CPF := BK6->(FieldPos("BK6_CPF")) > 0
Local lB5AVLRANT := B5A->(FieldPos("B5A_VLRANT"))>0
Local lDMEDPJN := GetNewPar("MV_DMEDPJ ","N") == "N"
Local lDMEDPJS := GetNewPar("MV_DMEDPJ ","N") == "S"
Local cGerDmd   := ""
Local cMvPar02 := StrZero(mv_par02,4)
Local cPLSNCREG := GetNewPar("MV_PLSNCRE","NCC")
Local lStrTPLS := FindFunction("StrTPLS")

If !lAutomato
    IncProc("Calculando valores reembolsados...")
    //PlsLogFil("Calculo do reembolso - inํcio: " + Dtos(dDataBase) + " " + Time(),cArqLog)
    ProcessMessage()
EndIf

If lPLSA001 // Nova rotina de reembolso - PLSA001
	
	If mv_par21 == 1 .Or. !lCPFB44 //Considera BB0

		cSqlSel := " SELECT B45.B45_DATPRO DATPRO, B45.B45_MATRIC MATRIC, "
		cSqlSel += " BA1.BA1_CPFUSR CPFDEP, BA1.BA1_NOMUSR NOMUSR, BA1.BA1_TIPUSU TIPUSU, BA1.BA1_DATNAS DATNAS,BA1.BA1_GRAUPA GRAUPA, BA1.BA1_MATVID MATVID, "	
		cSqlSel += " BA1.BA1_CODINT CODINT, BA1.BA1_CODEMP CODEMP, BA1.BA1_CONEMP CONEMP, BA1.BA1_VERCON VERCON, BA1.BA1_SUBCON SUBCON, BA1.BA1_VERSUB VERSUB, " 		
		cSqlSel += " SA1.A1_COD CODCLI, SA1.A1_LOJA LOJCLI, SA1.A1_COD CLIBA3, SA1.A1_LOJA LOJBA3,SA1.A1_CGC, "
		cSqlSel += " BK6_NOME NOMRDA, BK6_CGC CPFRDA, B45.B45_VLRPAG VALOR, B44.R_E_C_N_O_ REGB44, "
		cSqlSel += " B44.B44_ANOAUT ANOAUT, B44.B44_MESAUT MESAUT, B44.B44_NUMAUT NUMAUT, "
		cSqlSel += " SA1.A1_CGC CPFTIT,SA1.A1_PESSOA PESSOA, SA1.A1_NOME NOME, B44_PREFIX, B44_NUM, B44_TIPO "
				
		If lBK6CPF
			cSqlSel += ", BK6.BK6_CPF CPFPRE "
		Else
			cSqlSel += ", BK6.BK6_CGC CPFPRE "
		EndIf		
		cSqlFrm := " FROM " + RetSqlName("B44") + " B44 " 
		
		cSqlFrm += " JOIN "+ RetSqlName("B45") + " B45 " 
		cSqlFrm += " ON  B45_FILIAL = B44.B44_FILIAL " 
		cSqlFrm += " AND B45_OPEMOV = B44_OPEMOV " 
		cSqlFrm += " AND B45_ANOAUT = B44_ANOAUT " 
		cSqlFrm += " AND B45_MESAUT = B44_MESAUT " 
		cSqlFrm += " AND B45_NUMAUT = B44_NUMAUT " 
		cSqlFrm += " AND B45_CODPEG = B44_CODPEG "
		cSqlFrm += " JOIN "+ RetSqlName("BK6") + " BK6 ON B45_CODREF = BK6_CGC," + RetSqlName("BB0") + " BB0," + RetSqlName("BA1") + " BA1," + RetSqlName("SA1")+" SA1 "		
		
		cSqlWhr := " WHERE B44_FILIAL = '" + xFilial("B44") + "' AND BB0_FILIAL = '" + xFilial("BB0") + "' AND BA1_FILIAL = '" + xFilial("BA1") + "' AND A1_FILIAL = '" + xFilial("SA1") + "'"
		If AllTrim(TcGetDB()) $ "DB2/ORACLE"
			cSqlWhr += " AND B45.B45_MATRIC = (BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO) "
		Else
			cSqlWhr += " AND B45.B45_MATRIC = BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO "
		EndIf

		If !Empty(AllTrim(cCpf)) //Processa a Dmed apenas para o CPF MV_PLDMCPF
			cSqlWhr += "AND BA1_CPFUSR = '" + cCpf + "' "
		EndIf			
		
		cSqlWhr += " AND B44_CODCLI = A1_COD AND B44_LOJA = A1_LOJA AND B44_ANOPAG = '" + cAnoCal + "'"
		
		If lDMEDPJN		
				cSqlWhr += " AND A1_PESSOA   = 'F' "					
		EndIf

		cSqlWhr += " AND B44.D_E_L_E_T_ = ' ' AND BB0.D_E_L_E_T_ = ' ' AND BA1.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' "
		// Analisa flag de processado na DMED
		If lFLDMED .And. mv_par18 == 1
			cSqlWhr += "AND B44.B44_FLDMED = ' '  "
		EndIf       
		
		IF lREVERT 
			cSqlWhr += " AND (B44_REVERT = 'F' or B44_REVERT = ' ')  "			
		endif						
		
		cSqlWhr += " GROUP BY B45_DATPRO, B45_MATRIC, BA1.BA1_CPFUSR, BA1.BA1_NOMUSR, BA1.BA1_TIPUSU, BA1.BA1_DATNAS, "
		cSqlWhr += " BA1.BA1_GRAUPA, BA1.BA1_MATVID, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_COD, SA1.A1_LOJA, "
		cSqlWhr += " SA1.A1_CGC, BK6_NOME, BK6_CGC, B45_VLRPAG, B44.R_E_C_N_O_, B44_ANOAUT, "
		cSqlWhr += " B44_MESAUT, B44_NUMAUT, SA1.A1_CGC, SA1.A1_NOME,SA1.A1_PESSOA, B44_PREFIX, B44_NUM, B44_TIPO "
		If lBK6CPF
			cSqlWhr += ", BK6_CPF"
		EndIf 
		cSqlWhr += "  ,BA1.BA1_CODINT , BA1.BA1_CODEMP , BA1.BA1_CONEMP , BA1.BA1_VERCON , BA1.BA1_SUBCON, BA1.BA1_VERSUB  "

				
			
		cSqlSel1 :="  UNION "
		cSqlSel1 += " SELECT B45.B45_DATPRO DATPRO, B45.B45_MATRIC MATRIC, "
		cSqlSel1 += " BA1.BA1_CPFUSR CPFDEP, BA1.BA1_NOMUSR NOMUSR, BA1.BA1_TIPUSU TIPUSU, BA1.BA1_DATNAS DATNAS,BA1.BA1_GRAUPA GRAUPA, BA1.BA1_MATVID MATVID, "
		cSqlSel1 += "  BA1.BA1_CODINT CODINT, BA1.BA1_CODEMP CODEMP, BA1.BA1_CONEMP CONEMP, BA1.BA1_VERCON VERCON, BA1.BA1_SUBCON SUBCON, BA1.BA1_VERSUB VERSUB, " 		
		cSqlSel1 += " SA1.A1_COD CODCLI, SA1.A1_LOJA LOJCLI, SA1.A1_COD CLIBA3, SA1.A1_LOJA LOJBA3,SA1.A1_CGC, "
		cSqlSel1 += " BK6.BK6_NOME NOMRDA, BK6.BK6_CGC CPFRDA, B45.B45_VLRPAG VALOR, B44.R_E_C_N_O_ REGB44, "	
		cSqlSel1 += " B44.B44_ANOAUT ANOAUT, B44.B44_MESAUT MESAUT, B44.B44_NUMAUT NUMAUT, "
		cSqlSel1 += " SA1.A1_CGC CPFTIT,SA1.A1_PESSOA PESSOA, SA1.A1_NOME NOME, B44_PREFIX, B44_NUM, B44_TIPO "	
		
		If lBK6CPF
			cSqlSel1 += ", BK6.BK6_CPF CPFPRE "
		Else
			cSqlSel1 += ", BK6.BK6_CGC CPFPRE "
		EndIf
		
		cSqlFrm1 := " FROM " + RetSqlName("B44") + " B44 "
		
		 cSqlFrm1 += " JOIN "+ RetSqlName("B45") + " B45 ON B44_CODPEG = B45_CODPEG," + RetSqlName("BK6") + " BK6," + RetSqlName("BA1") + " BA1," + RetSqlName("SA1")+" SA1 "

		
		cSqlWhr1 := " WHERE B44_FILIAL = '" + xFilial("B44") + "' AND BK6_FILIAL = '" + xFilial("BK6") + "' AND BA1_FILIAL = '" + xFilial("BA1") + "' AND A1_FILIAL = '" + xFilial("SA1") + "'"
		cSqlWhr1 += " AND B44_CODREF = BK6_CODIGO "
		If AllTrim(TcGetDB()) $ "DB2/ORACLE"
			cSqlWhr1 += " AND B45.B45_MATRIC = (BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO) "
		Else
			cSqlWhr1 += " AND B45.B45_MATRIC = BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO "		
		EndIf
		
		If !Empty(AllTrim(cCpf)) //Processa a Dmed apenas para o CPF MV_PLDMCPF
			cSqlWhr1 += "AND BA1_CPFUSR = '" + cCpf + "' "
		EndIf			
		
		cSqlWhr1 += " AND B44_CODCLI = A1_COD AND B44_LOJA = A1_LOJA AND B44_ANOPAG = '" + cAnoCal + "'"
		cSqlWhr1 += " AND B44.D_E_L_E_T_ = ' ' AND BK6.D_E_L_E_T_ = ' ' AND BA1.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' '    AND B44_REGEXE = ' '	 "
		
		If lDMEDPJN				
			cSqlWhr1 += " AND SA1.A1_PESSOA   = 'F' " 			
		EndIf
		// Analisa flag de processado na DMED
		If lFLDMED .And. mv_par18 == 1
			cSqlWhr1 += " AND B44.B44_FLDMED = ' '  "
		EndIf
		
		IF lREVERT
			cSqlWhr1 += " AND (B44_REVERT = 'F' or B44_REVERT = ' ')  "
		endif	
		
		cSqlWhr1 += " GROUP BY B45_DATPRO, B45_MATRIC, BA1.BA1_CPFUSR, BA1.BA1_NOMUSR, BA1.BA1_TIPUSU, BA1.BA1_DATNAS, "
		cSqlWhr1 += " BA1.BA1_GRAUPA, BA1.BA1_MATVID, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_COD, SA1.A1_LOJA, "
		cSqlWhr1 += " SA1.A1_CGC, BK6_NOME, BK6_CGC, B45_VLRPAG, B44.R_E_C_N_O_, B44_ANOAUT, "
		cSqlWhr1 += " B44_MESAUT, B44_NUMAUT, SA1.A1_CGC, SA1.A1_NOME, SA1.A1_PESSOA , B44_PREFIX, B44_NUM, B44_TIPO "
		If lBK6CPF
			cSqlWhr1 += ", BK6_CPF"
		EndIf 	
		cSqlWhr1 += " ,BA1.BA1_CODINT , BA1.BA1_CODEMP , BA1.BA1_CONEMP , BA1.BA1_VERCON , BA1.BA1_SUBCON, BA1.BA1_VERSUB  " 						
		
	Else //mv_par21 == 2 considera B44_CPFEXE
		
		cSqlSel := " SELECT B45.B45_DATPRO DATPRO, B45.B45_MATRIC MATRIC, "
		cSqlSel += " BA1.BA1_CPFUSR CPFDEP, BA1.BA1_NOMUSR NOMUSR, BA1.BA1_TIPUSU TIPUSU, BA1.BA1_DATNAS DATNAS,BA1.BA1_GRAUPA GRAUPA, BA1.BA1_MATVID MATVID, "
		cSqlSel += " BA1.BA1_CODINT CODINT, BA1.BA1_CODEMP CODEMP, BA1.BA1_CONEMP CONEMP, BA1.BA1_VERCON VERCON, BA1.BA1_SUBCON SUBCON, BA1.BA1_VERSUB VERSUB, " 		
		cSqlSel += " SA1.A1_COD CODCLI, SA1.A1_LOJA LOJCLI, SA1.A1_COD CLIBA3, SA1.A1_LOJA LOJBA3,SA1.A1_CGC, "
		cSqlSel += " BK6.BK6_NOME NOMRDA, BK6.BK6_CGC CPFRDA, B45.B45_VLRPAG VALOR, B44.R_E_C_N_O_ REGB44, " 
		cSqlSel += " B44.B44_ANOAUT ANOAUT, B44.B44_MESAUT MESAUT, B44.B44_NUMAUT NUMAUT, "
		cSqlSel += " SA1.A1_CGC CPFTIT, SA1.A1_PESSOA PESSOA , SA1.A1_NOME NOME, B44_PREFIX, B44_NUM, B44_TIPO "		

		If lBK6CPF
			cSqlSel += ", BK6.BK6_CPF CPFPRE "
		Else
			cSqlSel += ", BK6.BK6_CGC CPFPRE "
		EndIf
		
		cSqlFrm := " FROM " + RetSqlName("B44") + " B44 "			
		
		cSqlFrm += " JOIN "+ RetSqlName("B45") + " B45 ON B44_CODPEG = B45_CODPEG JOIN "+ RetSqlName("BK6") + " BK6 ON B45_CODREF = BK6_CGC," + RetSqlName("BA1") + " BA1," + RetSqlName("SA1")+" SA1 "
		
		cSqlWhr := " WHERE B44_FILIAL = '" + xFilial("B44") + "' AND BA1_FILIAL = '" + xFilial("BA1") + "' AND A1_FILIAL = '" + xFilial("SA1") + "'"
		If AllTrim(TcGetDB()) $ "DB2/ORACLE"
			cSqlWhr += " AND B45.B45_MATRIC = (BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO) "
		Else
			cSqlWhr += " AND B45.B45_MATRIC = BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO "
		EndIf	
		
		If !Empty(AllTrim(cCpf)) //Processa a Dmed apenas para o CPF MV_PLDMCPF
			cSqlWhr += "AND BA1_CPFUSR = '" + cCpf + "' "
		EndIf				
		
		cSqlWhr += " AND B44_CODCLI = A1_COD AND B44_LOJA = A1_LOJA AND B44_ANOPAG = '" + cAnoCal + "'"
		cSqlWhr += " AND B44.D_E_L_E_T_ = ' ' AND BA1.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' "
		If lDMEDPJN					
				cSqlWhr += " AND SA1.A1_PESSOA   = 'F' " 			
		EndIf
		// Analisa flag de processado na DMED
		If lFLDMED .And. mv_par18 == 1
			cSqlWhr += "AND B44.B44_FLDMED = ' '  "
		EndIf
		
		IF lREVERT
			cSqlWhr += " AND (B44_REVERT = 'F' or B44_REVERT = ' ')  "
		endif

		cSqlWhr += " GROUP BY B45_DATPRO, B45_MATRIC, BA1_CPFUSR, BA1_NOMUSR, BA1_TIPUSU, BA1_DATNAS, "
		cSqlWhr += " BA1_GRAUPA, BA1.BA1_MATVID, A1_COD, A1_LOJA, A1_COD, A1_LOJA , A1_CGC, "
		cSqlWhr += " BK6_NOME, BK6_CGC, B45_VLRPAG, B44.R_E_C_N_O_, B44_ANOAUT, B44_MESAUT, B44_NUMAUT, "
		cSqlWhr += " SA1.A1_CGC, SA1.A1_NOME, SA1.A1_PESSOA ,B44_PREFIX, B44_NUM, B44_TIPO "
		If lBK6CPF
			cSqlWhr += ", BK6_CPF"
		EndIf 
		cSqlWhr += " ,BA1.BA1_CODINT , BA1.BA1_CODEMP , BA1.BA1_CONEMP , BA1.BA1_VERCON , BA1.BA1_SUBCON, BA1.BA1_VERSUB  " 						
					

	EndIf
	
Else // Rotina antiga de reembolso - PLSA987                                  

	cSqlSel := "SELECT BKD.BKD_DATA DATPRO, BKD.BKD_CODINT CODINT, BKD.BKD_CODEMP CODEMP, BKD.BKD_MATRIC MATRIC, BKD.BKD_TIPREG TIPREG, BKD.BKD_DIGITO DIGITO, "
	cSqlSel += "BA1.BA1_CPFUSR CPFDEP, BA1.BA1_NOMUSR NOMUSR, BA1.BA1_TIPUSU TIPUSU, BA1.BA1_DATNAS DATNAS, BA1.BA1_GRAUPA GRAUPA,BA1.BA1_MATVID MATVID, "
	cSqlSel += "BA1.BA1_CODCLI CODCLI, BA1.BA1_LOJA LOJCLI, BA3.BA3_CODCLI CLIBA3, BA3.BA3_LOJA LOJBA3, "
	cSqlSel += "BKD.BKD_ANOBAS ANOAUT, BKD.BKD_MESBAS MESAUT, BKD.BKD_CODRBS NUMAUT, "
	cSqlSel += "BK6.BK6_NOME NOMRDA, BK6.BK6_CGC CPFRDA, BKD.BKD_VLRREM VALOR, BKD.R_E_C_N_O_ REGBKD "

	If lBK6CPF
		cSqlSel += ", BK6.BK6_CPF CPFPRE "
	Else
		cSqlSel += ", BK6.BK6_CGC CPFPRE "
	EndIf 
	 
	cSqlFrm := "FROM "+RetSqlName("BKD")+" BKD, "+RetSqlName("BK6")+" BK6, "+RetSqlName("BA1")+" BA1, "+RetSqlName("BA3")+" BA3 "

	cSqlWhr := "WHERE BKD_FILIAL = '"+xFilial("BKD")+"' AND BA1_FILIAL = '"+xFilial("BA1")+"' AND BK6_FILIAL = '"+xFilial("BK6")+"' "
	cSqlWhr += "AND BKD_CODCRE = BK6_CODIGO "
	cSqlWhr += "AND BKD_CODINT = BA1_CODINT AND BKD_CODEMP = BA1_CODEMP AND BKD_MATRIC = BA1_MATRIC AND BKD_TIPREG = BA1_TIPREG "
	
	If !Empty(AllTrim(cCpf)) //Processa a Dmed apenas para o CPF MV_PLDMCPF
		cSqlWhr += "AND BA1_CPFUSR = '" + cCpf + "' "
		EndIf		
	
	cSqlWhr += "AND BKD_DIGITO = BA1_DIGITO "
	cSqlWhr += "AND BKD_CODINT = BA3_CODINT AND BKD_CODEMP = BA3_CODEMP AND BKD_MATRIC = BA3_MATRIC "
	cSqlWhr += "AND BKD_DATVEN BETWEEN '"+cMvPar02+"0101' AND '"+cMvPar02+"1231' "
	cSqlWhr += "AND BKD.D_E_L_E_T_ = ' ' AND BK6.D_E_L_E_T_ = ' ' AND BA1.D_E_L_E_T_ = ' ' "
	// Analisa flag de processado na DMED
	If lFLDMED .And. mv_par18 == 1
		cSqlWhr += "AND BKD.BKD_FLDMED = ' '  "		 
	EndIf

EndIf

If ExistBlock("M260SQRE")
	cSql := ExecBlock("M260SQRE",.F.,.F.,{cSqlSel,cSqlFrm,cSqlWhr,cAnoRef,cAnoCal})
	//PlsLogFil("Reembolso - Consulta alterada pelo ponto de entrada M260SQRE.",cArqLog)
Else
	cSql := cSqlSel+cSqlFrm+cSqlWhr+cSqlSel1+cSqlFrm1+cSqlWhr1
EndIf
 
cStm := ChangeQuery(cSql)//18-01
//PlsLogFil("Reembolso - Consulta executada: " + cStm,cArqLog)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cStm),"REEM",.F.,.T.)

TcSetField("REEM","DATPRO","D",08,0)
TcSetField("REEM","DATNAS","D",08,0)
TcSetField("REEM","VALOR" ,"N",17,2)    

If lPLSA001 // Nova rotina de reembolso - PLSA001
	TcSetField("REEM","REGB44","N",17,0)
Else
	TcSetField("REEM","REGBKD","N",17,0)
EndIf

BA1->(dbSetOrder(1))
dbSelectArea("B5A")

While !REEM->(Eof())
	
	If lGERDMD
		BQC->(dbSetOrder(1))
		if BQC->(msSeek(xFilial("BQC") + REEM->CODINT + REEM->CODEMP + REEM->CONEMP + REEM->VERCON + REEM->SUBCON + REEM->VERSUB))
			cGerDmd := BQC->BQC_GERDMD
			If cGerDmd == '0' .AND. BQC->BQC_COBNIV == "1"
				REEM->(dbSkip())
				Loop					
			EndIf
		EndIf
	EndIf
	
    If !lAutomato
	    IncProc("Gravando valor de reembolso de " + AllTrim(REEM->NOMUSR))
        ProcessMessage()
    EndIf
	
	// Tipo de registro 2=RTOP; 4=RDTOP
	cIdeReg	:= IIf( REEM->TIPUSU == cCodTit,'2', "4")

	// Tipo de Rda 1=PF; 2=PJ
	cTpRda	:= IIf(Len(REEM->CPFRDA)==14, "2", "1" )
	// Matricula - para o reembolso novo (B45) a matricula ้ gravada em unico campo/ no velho ้ desmembrado
	cMatric	:= Iif(lPLSA001, REEM->MATRIC, REEM->CODINT+REEM->CODEMP+REEM->MATRIC+REEM->TIPREG+REEM->DIGITO)
	nVlrFK2	:= 0

	If cIdeReg == "2"
		cChvB5A := xFilial("B5A") + cAnoCal + cIdeReg + AllTrim(REEM->CPFDEP) + cTpRda + REEM->CPFRDA
		B5A->(DbSetOrder(2))
	Else
		cChvB5A := xFilial("B5A") + cAnoCal + cIdeReg + cMatric + cTpRda + REEM->CPFRDA
		B5A->(DbSetOrder(3))
	EndIf

	If lRestIr .And. lPLSA001
		if( select( "REST" ) > 0 )
			REST->( dbCloseArea() )
		endIf

		cStm	:= "SELECT SUM(B45.B45_VLRPAG) VLRB45 " 
		cStm	+= "FROM "+ RetSqlName('B45')+" B45 " 
		cStm	+= "WHERE  B45.D_E_L_E_T_ = ' ' AND B45_FILIAL = '"+ xFilial('B45') +"' AND B45_RESTIR <> '0' "
		cStm	+= "AND B45_OPEMOV ='"+Left(cMatric,4)+"' AND B45_ANOAUT = '"+REEM->ANOAUT+"' AND B45_MESAUT ='"+REEM->MESAUT+"' "
		cStm	+= "AND B45_NUMAUT ='"+REEM->NUMAUT+"' "
		cStm	+= "GROUP BY B45_OPEMOV, B45_ANOAUT, B45_MESAUT, B45_NUMAUT "	
		cStm 	:= ChangeQuery(cStm)
		
		//PlsLogFil("Reembolso - Consulta executada: " + cStm,cArqLog)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cStm),"REST",.F.,.T.)
		// Se nใo achou nada pode ter somente itens nใo restituiveis, grava 0 para abater valor
		If REST->(EOF())
			if( select( "REST" ) > 0 )
				REST->( dbCloseArea() )
			endIf
		
			//--< Cria็ใo do objeto FWTemporaryTable >---
			oTempTable := FWTemporaryTable():New( "REST" )
			oTempTable:SetFields( aStru )
			oTempTable:AddIndex( "INDRST",{ "VLRB45" } )
			
			oTempTable:Create()
			If !(GetRpoRelease() >= "12.1.027")			
				RecLock('REST',.T.)
					REST->VLRB45	:= 0
				msUnlock()		
			EndIf
			
		EndIf
		
	EndIf	

	If lPLSA001 
		nPos := aScan(aTit, REEM->B44_PREFIX + REEM->B44_NUM)		
		If nPos <= 0
			aAdd(aTit, REEM->B44_PREFIX + REEM->B44_NUM)
			
			cSqlFI8 := " SELECT FI8_PRFDES, FI8_NUMDES "
			cSqlFI8 += " FROM " + RetSqlName('FI8') 
			cSqlFI8 += " WHERE FI8_FILIAL =  '" + xFilial('FI8')+ "' " 
			cSqlFI8 += " AND FI8_PRFORI = '" + REEM->B44_PREFIX +  "' "
			cSqlFI8 += " AND FI8_NUMORI = '" + REEM->B44_NUM 	+  "' "
			cSqlFI8 += " AND D_E_L_E_T_ = ' ' "
			
			cSqlFI8 := ChangeQuery(cSqlFI8)		
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlFI8),"TrbFI8",.F.,.T.)
			
			While !TrbFI8->(Eof())
			    nVlrFK2 += PL260Bx(TrbFI8->FI8_PRFDES, AllTrim(TrbFI8->FI8_NUMDES), @cData,,cPLSNCREG)
				TrbFI8->(dbSkip())	
			EndDo
			
			TrbFI8->(dbCloseArea())					
			nVlrFK2 += PL260Bx(REEM->B44_PREFIX, AllTrim(REEM->B44_NUM), @cData, REEM->B44_TIPO,cPLSNCREG)
		EndIf		
	EndIf
	
	If !lPLSA001		
		nVlrFK2 := REEM->VALOR
	EndIf

	cData	:= Iif(lPLSA001, cData, SubStr(DtoS(REEM->DATPRO),1,4))
	If nVlrFK2 > 0
		If !B5A->(DbSeek(cChvB5A)) 
			// Posiciona BA1 nos dados do titular
			BA1->(dbSeek(xFilial("BA1")+Substr(cMatric,1,14)+cCodTit, .F.))
	
			// Tipo de registro 2=RTOP; 4=RDTOP
			cIdeReg	:= Iif(REEM->TIPUSU == cCodTit,Iif(lPLSA001.and. mv_par20 == 1 .And. AllTrim(BA1->BA1_CPFUSR) != AllTrim(REEM->A1_CGC),'4','2'), "4")
			
			// Grava novo registro
			B5A->(RecLock("B5A",.T.))
			B5A->B5A_FILIAL := xFilial("B5A")
			If lPLSA001
				B5A->B5A_CODINT := left(REEM->MATRIC,4)
				B5A->B5A_CODEMP := Substr(REEM->MATRIC,5,4)
				B5A->B5A_MATRIC := substr(REEM->MATRIC,9,6)
				B5A->B5A_TIPREG := substr(REEM->MATRIC,15,2)
				B5A->B5A_DIGITO := substr(REEM->MATRIC,17,1)
			Else
				B5A->B5A_CODINT := REEM->CODINT
				B5A->B5A_CODEMP := REEM->CODEMP
				B5A->B5A_MATRIC := REEM->MATRIC
				B5A->B5A_TIPREG := REEM->TIPREG
				If !lStrTPLS
					B5A->B5A_DIGITO := Iif(!Empty(REEM->DIGITO),REEM->DIGITO,Modulo11(REEM->(CODINT+CODEMP+MATRIC+TIPREG)))
				Else
					B5A->B5A_DIGITO := Iif(!Empty(REEM->DIGITO),REEM->DIGITO,Modulo11(StrTPLS(REEM->(CODINT+CODEMP+MATRIC+TIPREG))))
				EndIf
			Endif			
			B5A->B5A_NOMUSR := REEM->NOMUSR
			B5A->B5A_RELDEP := Iif(REEM->TIPUSU == cCodTit,"01",M260GrPa(REEM->GRAUPA))
			B5A->B5A_DATNAS := REEM->DATNAS
			B5A->B5A_CPFTIT := BA1->BA1_CPFUSR
			B5A->B5A_CPFDEP := REEM->CPFDEP	//CPFDEP ja e o cpf do BA1 
			B5A->B5A_CODCLI := IIf(!Empty(REEM->CODCLI), REEM->CODCLI, REEM->CLIBA3)
			B5A->B5A_LOJCLI := IIf(!Empty(REEM->LOJCLI), REEM->LOJCLI, REEM->LOJBA3)
						
			If cData < cAnoCal .And. lB5AVLRANT
				B5A->B5A_VLRANT := nVlrFK2                                             
			Else
				B5A->B5A_VLRREE := nVlrFK2									
			EndIf			
	
			B5A->B5A_TPRDA  := cTpRda
			B5A->B5A_CPFRDA := Iif(!Empty(REEM->CPFRDA),REEM->CPFRDA,REEM->CPFPRE)
			B5A->B5A_NOMRDA := REEM->NOMRDA
			B5A->B5A_IDEREG := cIdeReg
			B5A->B5A_ANODCL := cAnoCal
			B5A->B5A_STATUS := "1"
			B5A->B5A_MATVID := REEM->MATVID
			B5A->(msUnlock())
			lGerReg := .T.
		Else // Se o colaborador ja foi gravado para o ano cAnoCal eu atualizo seu B5A_VLRREE
			B5A->(RecLock("B5A",.F.))		
			
			If cData < cAnoCal .And. lB5AVLRANT
				B5A->B5A_VLRANT += nVlrFK2                                     
			Else
				B5A->B5A_VLRREE += nVlrFK2									
			EndIf			
			
			B5A->(msUnlock())
		EndIf
	EndIf
	
	If lM260GRV
		ExecBlock("M260GRV",.F.,.F.,{B5A->(Recno()),lGerReg})
		//PlsLogFil("Reembolso - Recno " + AllTrim(Str(B5A->(Recno()))) + " sofreu manuten็ใo pelo ponto de entrada M260GRV.",cArqLog)
	EndIf

	If lGerReg .And. REEM->TIPUSU != cCodTit //Cetesb
		M260GerReg(B5A->B5A_CODINT,B5A->B5A_CODEMP,B5A->B5A_MATRIC,B5A->B5A_TIPREG,B5A->B5A_DIGITO,REEM->TIPUSU,Iif(mv_par20 == 2 .Or. !lPLSA001,BA1->BA1_CPFUSR,REEM->A1_CGC),B5A->B5A_CODCLI,B5A->B5A_LOJCLI,cTpLanc,cCodNEve,cCodEve,IIf( REEM->TIPUSU == cCodTit,'2','4'),cAnoCal,cArqlog)
		lGerReg := .F.
	EndIf
	
	If lPLSA001
		B44->(dbGoto(REEM->REGB44))
		If Empty(B44->B44_FLDMED)
			RecLock("B44",.F.)
				B44->B44_FLDMED	:= 'S'
			B44->(msUnlock())
		EndIf
	EndIF
	
	REEM->(dbSkip())

EndDo

//Vou marcar os reembolsos encontrados como processado para a Dmed
If !lPLSA001 	
	REEM->(dbGoTop())
	While !REEM->(Eof())
		BKD->(dbGoto(REEM->REGBKD))
		If Empty(BKD->BKD_FLDMED)
			RecLock("BKD",.F.)
			BKD->BKD_FLDMED	:= 'S'
			BKD->(msUnlock())
		EndIf
		REEM->(dbSkip())
	EndDo
EndIf

REEM->(dbCloseArea())

if( select( "REST" ) > 0 ) .And. ValType(oTempTable) <> 'U'
	oTempTable:delete()
endIf

//PlsLogFil("Calculo do reembolso - t้rmino: " + Dtos(dDataBase) + " " + Time(),cArqLog)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ M260Perg บAutor  ณMicrosiga           บ Data ณ  03/21/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao criada para validar o preenchimento das perguntas   บฑฑ
ฑฑบ          ณ SX1                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M260Perg()
Local lRet := .T.
Local cMsg := ""

If Empty(mv_par01)
	lRet := .F.
	cMsg := "Ano de refer๊ncia" + CRLF
EndIf

If Empty(mv_par02)
	lRet := .F.
	cMsg += "Ano calendแrio" + CRLF
EndIf

If Empty(mv_par05)
	lRet := .F.
	cMsg += "CPF do responsแvel" + CRLF
EndIf

If Empty(mv_par06) 
	lRet := .F.
	cMsg += "Nome do responsแvel" + CRLF
EndIf

If Empty(mv_par07) 
	lRet := .F.
	cMsg += "DDD do responsแvel" + CRLF
EndIf

If Empty(mv_par08) 
	lRet := .F.
	cMsg += "Telefone do responsแvel" + CRLF
EndIf

If Empty(mv_par12) 
	lRet := .F.
	cMsg += "CPF declarante" + CRLF
EndIf

If !lRet
	MsgInfo("Informe os parโmetros: " + CRLF  + CRLF + cMsg)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ M260GPE  บAutor  ณMicrosiga           บ Data ณ  17/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para informar na Dmed os valores de beneficia-บฑฑ
ฑฑบ          ณcom desconto em folha                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAPLS                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M260GPE(cArqlog,cCodTit,lAutomato)
Local cSql	   := ''
Local cLastCPF := ''
Local lM260GRV := ExistBlock("M260GRV")
Local lFLDMED  :=  BM1->(FieldPos("BM1_FLDMED")) > 0
Local cMvPar02 := StrZero(mv_par02,4)
Local lStrTPLS := FindFunction("StrTPLS")

If !lAutomato
    IncProc("Filtrando beneficiแrios com desconto em folha...")
    //PlsLogFil("Beneficiแrios com desconto em folha - inํcio: " + Dtos(dDataBase) + " " + Time(),cArqLog)
    ProcessMessage()
EndIf
 
If !lCMPCUS
	cSql := "SELECT BM1.BM1_ANO ANO,BM1.BM1_MES MES, BM1.BM1_CODINT CODINT, BM1.BM1_CODEMP CODEMP, BM1.BM1_MATRIC MATRIC, BM1.BM1_TIPREG TIPREG, BA1.BA1_NOMUSR AS NOMUSR, "
	cSql += "BM1.BM1_TIPO TIPO, BA1.BA1_CPFUSR CPFUSR, BA1.BA1_DATNAS DATNASC, BA1.BA1_GRAUPA GRAUPA, BM1.BM1_CODEVE CODEVE, BM1.BM1_DIGITO DIGITO, BM1.BM1_VALOR VALOR,BA1.BA1_MATVID MATVID, "
	cSql += "BM1.R_E_C_N_O_ REGBM1, BA1.BA1_TIPUSU TIPUSU, BM1.BM1_AGMTFU MATFUN, BM1.BM1_AGFTFU FILFUN  FROM " + RetSqlName("BM1") + " BM1, " + RetSqlName("BA1") + " BA1 "
	cSql += "WHERE BM1_FILIAL = '"+xFilial('BM1')+"' "+"AND BA1_FILIAL = '"+xFilial('BA1')+"' AND BM1.BM1_CODINT = BA1.BA1_CODINT "
	cSql += "AND BM1.BM1_CODEMP = BA1.BA1_CODEMP AND BA1.BA1_MATRIC = BM1.BM1_MATRIC AND BA1.BA1_TIPREG = BM1.BM1_TIPREG "
	cSql += "AND BM1.BM1_AGMTFU > ' ' "
	
	If !Empty(cPeriGpe) //Periodo da folha alterado via parametro MV_PLDM007
		cSql += "AND ( (BM1.BM1_ANO = '" + SubStr(cPeriGpe,1,4) + "' AND BM1.BM1_MES >= '" + SubStr(cPeriGpe,5,2) + "') OR "
		cSql += "(BM1.BM1_ANO = '" + SubStr(cPeriGpe,8,4) + "' AND BM1.BM1_MES <= '" + SubStr(cPeriGpe,12,2) + "')) "
	Else //Periodo da folha padrao - fevereiro a janeiro
		cSql += "AND ( (BM1.BM1_ANO = '" + cMvPar02 + "' AND BM1.BM1_MES >= '02') OR "
		cSql += "(BM1.BM1_ANO = '" + StrZero(mv_par01,4) + "' AND BM1.BM1_MES = '01')) "
	EndIf

	If !Empty(cTpLanc)
		cSql += "AND ( BM1.BM1_AGMTFU > ' ' AND BM1.BM1_CODTIP NOT IN (" + cTpLanc + ") ) " // MV_PLDM006 Verbas da gestใo de pessoal que nใo deverใo ser consideradas para gera็ใo da DMED
	EndIf
	
	If !Empty(AllTrim(cCodEve))
		cSql += "AND BM1.BM1_CODEVE NOT IN (" + cCodEve + ") " //MV_PLDM004 Indica c๓digos de eventos de lan็amentos da cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODEVE
	EndIf

	If !Empty(AllTrim(cCpf)) //Processa a Dmed apenas para o CPF MV_PLDMDCPF
		cSql += "AND BA1_MATRIC = '" + cCpf + "' "
	EndIf
	
	If lFLDMED .And. mv_par18 == 1 // Analisa flag de processado na DMED
		cSql += "AND BM1.BM1_FLDMED = ' '  "
	EndIf
	
	cSql += "AND BA1.D_E_L_E_T_=' ' AND BM1.D_E_L_E_T_=' ' "

	cSql += "ORDER BY BM1_AGFTFU, BM1_AGMTFU, BM1_MATRIC,BM1_TIPREG "
Else
	cSql := "SELECT BM1.BM1_ANO ANO,BM1.BM1_MES MES, BM1.BM1_CODINT CODINT, BM1.BM1_CODEMP CODEMP, BM1.BM1_MATRIC MATRIC, BM1.BM1_TIPREG TIPREG, BA1.BA1_NOMUSR AS NOMUSR, "
	cSql += "BM1.BM1_TIPO TIPO, BA1.BA1_CPFUSR CPFUSR, BA1.BA1_DATNAS DATNASC, BA1.BA1_GRAUPA GRAUPA, BM1.BM1_CODEVE CODEVE, BM1.BM1_DIGITO DIGITO, BM1.BM1_VALOR VALOR,BA1.BA1_MATVID MATVID, "
	cSql += "BM1.R_E_C_N_O_ REGBM1, BA1.BA1_TIPUSU TIPUSU, BM1.BM1_AGMTFU MATFUN, BM1.BM1_AGFTFU FILFUN, "  

	cSql += " BSP.BSP_CMPCUS BSPCMPCUS " //Vem do left join

	cSql += "FROM " + RetSqlName("BM1") + " BM1 "
	cSql += "INNER JOIN "+RetSqlName("BFQ")+" BFQ ON BM1.BM1_CODINT = BFQ.BFQ_CODINT "
	cSql += "AND BM1.BM1_CODTIP = BFQ.BFQ_PROPRI || BFQ.BFQ_CODLAN "

	cSql += "LEFT OUTER JOIN "+RetSqlName("BSP")+" BSP ON BM1.BM1_CODEVE = BSP.BSP_CODSER AND BM1.BM1_CODTIP = BSP.BSP_CODLAN AND BM1.BM1_TIPO = BSP.BSP_TIPSER "
	cSql += "AND (BSP.BSP_CMPCUS = ' ' OR BSP.BSP_CMPCUS = '1') AND BSP.BSP_FILIAL = ' ' AND BSP.D_E_L_E_T_ = ' ' "

	csql += ", " + RetSqlName("BA1") + " BA1 "
	cSql += "WHERE BM1_FILIAL = '"+xFilial('BM1')+"' "+"AND BA1_FILIAL = '"+xFilial('BA1')+"' AND BM1.BM1_CODINT = BA1.BA1_CODINT "
	cSql += "AND BM1.BM1_CODEMP = BA1.BA1_CODEMP AND BA1.BA1_MATRIC = BM1.BM1_MATRIC AND BA1.BA1_TIPREG = BM1.BM1_TIPREG "
	cSql += "AND BM1.BM1_AGMTFU > ' ' "
	
	If !Empty(cPeriGpe) //Periodo da folha alterado via parametro MV_PLDM007
		cSql += "AND ( (BM1.BM1_ANO = '" + SubStr(cPeriGpe,1,4) + "' AND BM1.BM1_MES >= '" + SubStr(cPeriGpe,5,2) + "') OR "
		cSql += "(BM1.BM1_ANO = '" + SubStr(cPeriGpe,8,4) + "' AND BM1.BM1_MES <= '" + SubStr(cPeriGpe,12,2) + "')) "
	Else //Periodo da folha padrao - fevereiro a janeiro
		cSql += "AND ( (BM1.BM1_ANO = '" + cMvPar02 + "' AND BM1.BM1_MES >= '02') OR "
		cSql += "(BM1.BM1_ANO = '" + StrZero(mv_par01,4) + "' AND BM1.BM1_MES = '01')) "
	EndIf

	If !Empty(cTpLanc)
		cSql += "AND ( BM1.BM1_AGMTFU > ' ' AND BM1.BM1_CODTIP NOT IN (" + cTpLanc + ") ) " // MV_PLDM006 Verbas da gestใo de pessoal que nใo deverใo ser consideradas para gera็ใo da DMED
	EndIf
	
	If !Empty(AllTrim(cCodEve))
		cSql += "AND BM1.BM1_CODEVE NOT IN (" + cCodEve + ") " //MV_PLDM004 Indica c๓digos de eventos de lan็amentos da cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODEVE
	EndIf		

	If !Empty(AllTrim(cCpf)) //Processa a Dmed apenas para o CPF MV_PLDMCPF
		cSql += "AND BA1_MATRIC = '" + cCpf + "' "
	EndIf
	
	If lFLDMED .And. mv_par18 == 1 // Analisa flag de processado na DMED
		cSql += "AND BM1.BM1_FLDMED = ' '  "
	EndIf
	cSql += "AND (BFQ.BFQ_CMPCUS = ' ' OR BFQ.BFQ_CMPCUS = '1') "	
	cSql += "AND BFQ.BFQ_FILIAL = '" + xFilial("BFQ") + "' AND BA1.D_E_L_E_T_=' ' AND BM1.D_E_L_E_T_=' ' AND BFQ.D_E_L_E_T_ = ' '"			
	cSql += "ORDER BY BM1_AGFTFU, BM1_AGMTFU, BM1_MATRIC, BM1_TIPREG "
EndIf
cSql := ChangeQuery(cSql)
		
If ExistBlock("PLM260CMP")
	cSql := ExecBlock("PLM260CMP",.F.,.F.,{cSql,"GPE"})
	cSql := ChangeQuery(cSql)
	//PlsLogFil("GPE - executado o ponto de entrada PLM260CMP",cArqLog)
EndIf

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"DGPE",.F.,.T.)
//PlsLogFil("GPE - Consulta executada: " + cSql,cArqLog)
TcSetField("DGPE","DATNASC","D",08,0)
TcSetField("DGPE","VALOR"  ,"N",17,2)

dbSelectArea("B5A")
B5A->(dbSetOrder(3))
cLastCPF := ''

While !DGPE->(Eof())

	If !lAutomato
		IncProc( IIf( DGPE->TIPUSU == cCodTit, "Colaborador: ", "Dependente: ") + DGPE->NOMUSR )
		ProcessMessage()
	EndIf

	If lCMPCUS .AND. (!EMPTY(DGPE->BSPCMPCUS) .AND. DGPE->BSPCMPCUS <> "1")
		DGPE->(dbSkip())
		Loop
	EndIf

	If DGPE->CPFUSR <> cLastCPF .And. DGPE->TIPUSU == cCodTit
		cLastCPF := DGPE->CPFUSR
	EndIf

		B5A->(RecLock("B5A",.T.))
		B5A->B5A_FILIAL := xFilial("B5A")
		B5A->B5A_CODINT := DGPE->CODINT
		B5A->B5A_CODEMP := DGPE->CODEMP
		B5A->B5A_MATRIC := DGPE->MATRIC
		B5A->B5A_TIPREG := DGPE->TIPREG
		If !lStrTPLS
			B5A->B5A_DIGITO := Iif(!Empty(DGPE->DIGITO),DGPE->DIGITO,Modulo11(DGPE->(CODINT+CODEMP+MATRIC+TIPREG)))
		Else
			B5A->B5A_DIGITO := Iif(!Empty(DGPE->DIGITO),DGPE->DIGITO,Modulo11(StrTPLS(DGPE->(CODINT+CODEMP+MATRIC+TIPREG))))
		EndIf
		B5A->B5A_NOMUSR := DGPE->NOMUSR
		If DGPE->TIPUSU == cCodTit
			B5A->B5A_CPFTIT := DGPE->CPFUSR
		Else
			B5A->B5A_CPFTIT := Posicione("BA1",1,xFilial("BA1")+DGPE->(CODINT+CODEMP+MATRIC)+cCodTit,"BA1_CPFUSR")
		EndIf
		B5A->B5A_CPFDEP := DGPE->CPFUSR
		B5A->B5A_DATNAS := DGPE->DATNASC
		B5A->B5A_RELDEP := IIf( DGPE->TIPUSU == cCodTit, '01', M260GrPa(DGPE->GRAUPA) )//Resgatar o historico porque isso foi alterado
		B5A->B5A_VLRGPE := IIf( DGPE->TIPO == '1', DGPE->VALOR, -DGPE->VALOR )
		B5A->B5A_IDEREG := IIf( DGPE->TIPUSU == cCodTit, '1', '3')
		B5A->B5A_ANODCL := cMvPar02
		B5A->B5A_MATVID := DGPE->MATVID
		B5A->B5A_STATUS := '1'
		B5A->(msUnlock())
	
		If lM260GRV
			ExecBlock("M260GRV",.F.,.F.,{B5A->(Recno()),DGPE->TIPUSU != cCodTit})
			//PlsLogFil("GPE - Recno " + AllTrim(Str(B5A->(Recno()))) + " sofreu manuten็ใo pelo ponto de entrada M260GRV.",cArqLog)
		EndIf
	
	If DGPE->TIPUSU != cCodTit
		M260GerReg(B5A->B5A_CODINT,B5A->B5A_CODEMP,B5A->B5A_MATRIC,B5A->B5A_TIPREG,B5A->B5A_DIGITO,cCodTit,B5A->B5A_CPFTIT,'','',cTpLanc,cCodNEve,cCodEve,'3',B5A->B5A_ANODCL,cArqLog)
	EndIf
	
	DGPE->(dbSkip())

EndDo

If lFLDMED
	DGPE->(dbGoTop())
	While !DGPE->(Eof())
		BM1->(dbGoto(DGPE->REGBM1))
		If Empty(BM1->BM1_FLDMED)
			RecLock("BM1",.F.)
			BM1->BM1_FLDMED	:= 'S'
			BM1->(msUnlock())
		EndIf
		DGPE->(dbSkip())
	EndDo
EndIf	
DGPE->(dbCloseArea())

//PlsLogFil("Beneficiแrios com desconto em folha - t้rmino: " + Dtos(dDataBase) + " " + Time(),cArqLog)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM260GrPa  บAutor  ณMicrosiga           บ Data ณ  03/17/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para retornar o grau de parentesco do beneficiบฑฑ
ฑฑบ          ณa ser informado para a Dmed                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAPLS                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function M260GrPa(cGrpPau)
Local cRet := ""

dbSelectArea("BRP")
BRP->(dbSetOrder(1))

If BRP->(dbSeek(xFilial("BRP")+cGrpPau))
	cRet := BRP->BRP_CODSIB
Else
	Do Case
		Case cGrpPau == '03'
			cRet := '03'
		Case cGrpPau $ '04,05'
			cRet := '04'
		Case cGrpPau $ '06,07'
			cRet := '06'
		Case cGrpPau $ '08,09'
			cRet := '08'
		Case cGrpPau $ '10,11'
			cRet := '10'
		OtherWise
			cRet := '10'
	EndCase
EndIf

// Seguran็a contra erro no arquivo
If !AllTrim(cRet) $ '03 04 06 08 10'
	cRet	:= '10'
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ M260Fin  บAutor  ณMicrosiga           บ Data ณ  29/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo da Dmed pelos CPFs que tiveram movimento financeiroบฑฑ
ฑฑบ          ณ no ano declarado                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M260Fin(cArqLog,lAutomato)
Local cSqlSel := ""
Local cSqlFrm := ""
Local cSqlWhr := ""
Local lGerReg := .F. // Preciso gerar o registro do titular ?
Local lPL260SE5 := ExistBlock("PL260SE5")
Local lPLM260CMP:= ExistBlock("PLM260CMP")
Local lM260GRV  := ExistBlock("M260GRV")
Local lGERDMD   := BQC->(FieldPos("BQC_GERDMD")) > 0
Local lE5DMED   := SE5->(FieldPos("E5_FLDMED")) > 0
Local lDMEDPJN  := GetNewPar("MV_DMEDPJ ","N") == "N"
Local lPLSUNI   := GetNewPar("MV_PLSUNI","1") == "1"
Local cGerDmd   := ""
Local cMvPar02  := StrZero(mv_par02,4)
Local cSituac   := StrTran(cSituaca,",","','")
Local lStrTPLS	:= FindFunction("StrTPLS")
local aTmpTit	:= {}

If !lAutomato
    IncProc("Filtrando clientes com movimento financeiro...")
    //PlsLogFil("CPF com tํtulos financeiro - Inํcio: " + Dtos(dDataBase) + " " + Time(),cArqLog)
    ProcessMessage()
EndIf

// POSICIONA INDICE DE BUSCA DO ARQUIVO DE Dmed - 'B5A_FILIAL + B5A_ANODCL + B5A_IDEREG + B5A_CODINT + B5A_CODEMP + B5A_MATRIC + B5A_TIPREG + B5A_DIGITO + B5A_TPRDA + B5A_CPFRDA'
dbSelectArea("B5A")
B5A->(dbSetOrder(3))

// VERIFICA TODOS OS CPFS QUE TIVERAM PAGAMENTO NO ANO PARAMETRIZADO
cSqlSel := "SELECT SA1.A1_CGC CPF, SA1.A1_COD CODIGO, SA1.A1_LOJA LOJA, SA1.A1_PESSOA "
cSqlFrm := "FROM "+RetSqlName("SE5")+" SE5, "+RetSqlName("SA1")+" SA1 "
cSqlWhr := "WHERE SE5.E5_FILIAL = '"+xFilial("SE5")+"' AND SA1.A1_FILIAL   = '"+xFilial("SA1")+"' "
cSqlWhr += "AND SE5.E5_CLIFOR   = SA1.A1_COD AND SE5.E5_LOJA     = SA1.A1_LOJA "
cSqlWhr += "AND SE5.E5_DATA    >= '"+cMvPar02+"0101' AND SE5.E5_DATA <= '"+cMvPar02+"1231' "
cSqlWhr += "AND (SE5.E5_RECPAG = 'R' OR (SE5.E5_RECPAG = 'P' AND SE5.E5_TIPO = 'NCC' ) ) "

If lDMEDPJN 
	cSqlWhr += " AND SA1.A1_PESSOA   = 'F' "
EndIf

If !Empty(cTpDoc)
	cSqlWhr += "AND SE5.E5_TIPODOC IN ("+cTpDoc+") "
EndIf

If !Empty(cTpBaixa)
	cSqlWhr += "AND SE5.E5_MOTBX NOT IN ("+cTpBaixa+") "
EndIf

If !Empty(cSituaca)
	cSqlWhr += "AND SE5.E5_SITUACA NOT IN ('" + cSituac + "') "
EndIf

cSqlWhr += "AND SE5.D_E_L_E_T_  = ' ' AND SA1.D_E_L_E_T_  = ' ' "

If lE5DMED .And. mv_par18 == 1 //Verifico se o movimento ja foi processado para a Dmed
	cSqlWhr	+= "AND SE5.E5_FLDMED = ' ' "
EndIf

If !Empty(cCpf) //Processo movimento apenas para o CPF MV_PLDMCPF
	cSqlWhr += "AND SA1.A1_CGC = '"+cCpf+"' " 
EndIf

cSqlWhr += "GROUP BY SA1.A1_CGC, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_PESSOA "

If ExistBlock("PLM260FIN")
	cSql := ExecBlock("PLM260FIN",.F.,.F.,{cSqlSel,cSqlFrm,cSqlWhr})
	//PlsLogFil("FIN - executado o ponto de entrada PLM260FIN",cArqlog)
	cSql := ChangeQuery(cSql)
Else
	cSql := ChangeQuery(cSqlSel+cSqlFrm+cSqlWhr)
EndIf

//PlsLogFil("FIN - Consulta executada: " + cSql,cArqLog)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

While !TRB1->(Eof())
    If !lAutomato
	    IncProc("Calculando valor para o CPF "+TRB1->CPF+"...")
        ProcessMessage()
    EndIF

	// VERIFICA TODOS OS PAGAMENTO POR CPF
	cSql := "SELECT SE5.E5_VALOR VLRSE5, SE5.E5_PREFIXO PREFIXO, SE5.E5_NUMERO NUMERO, SE5.E5_PARCELA PARC, "
	cSql += "SE5.E5_TIPO TIPO, SE5.E5_TIPODOC TPDOC, SE5.E5_MOTBX MOTBX, MAX(SE5.R_E_C_N_O_) REGSE5 "
	cSql += "FROM "+RetSqlName("SE5")+" SE5 "
	cSql += "WHERE SE5.E5_FILIAL = '"+xFilial("SE5")+"' "
	cSql += "AND SE5.E5_CLIFOR   = '"+TRB1->CODIGO+"' "
	cSql += "AND SE5.E5_LOJA     = '"+TRB1->LOJA+"' "
	cSql += "AND SE5.E5_DATA    >= '"+cMvPar02+"0101' AND SE5.E5_DATA <= '"+cMvPar02+"1231' "
	cSql += "AND (SE5.E5_RECPAG = 'R' OR (SE5.E5_RECPAG = 'P' AND SE5.E5_TIPO = 'NCC' ) ) "
	
	If !Empty(cTpDoc)
		cSql += "AND SE5.E5_TIPODOC IN ("+cTpDoc+") " // MV_PLDM001
	EndIf
	
	If !Empty(cTpBaixa)
		cSql += "AND SE5.E5_MOTBX NOT IN ("+cTpBaixa+") " // MV_PLDM002
	EndIf

	If !Empty(cSituaca)
		cSql += "AND SE5.E5_SITUACA NOT IN ('" + cSituac + "') "
	EndIf
	
	cSql += "AND SE5.D_E_L_E_T_  = ' ' "
	cSql += "GROUP BY SE5.E5_VALOR, SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA,SE5.E5_TIPO, SE5.E5_TIPODOC, SE5.E5_MOTBX "
	cSql += "ORDER BY SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, SE5.E5_TIPO "
	
	If lPL260SE5
		//PlsLogFil("SE5 - Consulta antes do PE PL260SE5: " + cSql,cArqLog)
		cSql := ExecBlock("PL260SE5",.F.,.F.,{cSql})
		//PlsLogFil("SE5 - Consulta depois do PE PL260SE5: " + cSql,cArqLog)
	EndIf
	
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB2",.F.,.T.)
	TcSetField("TRB2","VLRSE5","N",17,2)
	cTitProc := ""

	While !TRB2->(Eof())

		If lPLSUNI
			If cTitProc == TRB2->PREFIXO+TRB2->NUMERO+TRB2->PARC+TRB2->TIPO 
				TRB2->(dbSkip())
				Loop
			Else
				cTitProc := TRB2->PREFIXO+TRB2->NUMERO+TRB2->PARC+TRB2->TIPO
			EndIf
		EndIf	
	
		If !lCMPCUS	
			// LEVANTA A COMPOSICAO DO TITULO POR PAGAMENTO
			cSql := "SELECT BM1.BM1_CODINT CODINT, BM1.BM1_CODEMP CODEMP, BM1.BM1_MATRIC MATRIC, BM1.BM1_TIPREG TIPREG, "
			cSql += "BM1.BM1_DIGITO DIGITO, BM1.BM1_TIPO TIPO, BM1.BM1_VALOR VLRBM1, "
			cSql += " BM1.BM1_CONEMP CONEMP , BM1.BM1_VERCON VERCON, BM1.BM1_SUBCON SUBCON,BM1.BM1_VERSUB   "	
			cSql += "FROM "+RetSqlName("BM1")+" BM1 "						

			cSql += "WHERE BM1.BM1_FILIAL = '"+xFilial("BM1")+"' "
			cSql += "AND BM1.BM1_PREFIX = '"+TRB2->PREFIXO+"' "
			cSql += "AND BM1.BM1_NUMTIT = '"+TRB2->NUMERO+"' "
			cSql += "AND BM1.BM1_PARCEL = '"+TRB2->PARC+"' "
			cSql += "AND BM1.BM1_TIPTIT = '"+TRB2->TIPO+"' "
			
			If !Empty(cTpLanc) .and. !Empty(cCodNEve)
				cSql += "AND ( ( BM1.BM1_AGMTFU != ' ' AND BM1.BM1_CODTIP NOT IN (" + cTpLanc + ") ) " // MV_PLDM006 Verbas da gestใo de pessoal que nใo deverใo ser consideradas para gera็ใo da DMED
				cSql += "OR ( BM1.BM1_AGMTFU = ' '  AND BM1.BM1_CODTIP NOT IN (" + cCodNEve + ") ) ) " // MV_PLDM003 Indica c๓digos de lan็amentos de cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODTIP
			ElseIf !Empty(cTpLanc)
				cSql += "AND ( BM1.BM1_AGMTFU != ' ' AND BM1.BM1_CODTIP NOT IN (" + cTpLanc + ") ) " // MV_PLDM006 Verbas da gestใo de pessoal que nใo deverใo ser consideradas para gera็ใo da DMED
			ElseIf !Empty(cCodNEve)
				cSql += "AND ( BM1.BM1_AGMTFU = ' '  AND BM1.BM1_CODTIP NOT IN (" + cCodNEve + ") ) " // MV_PLDM003 Indica c๓digos de lan็amentos de cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODTIP
			EndIf
			
			If !Empty(AllTrim(cCodEve))
				cSql += "AND BM1.BM1_CODEVE NOT IN (" + cCodEve + ") " //MV_PLDM004 Indica c๓digos de eventos de lan็amentos da cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODEVE
			EndIf				
			cSql += " AND BM1.D_E_L_E_T_ = ' ' "			
						
		Else //
			// LEVANTA A COMPOSICAO DO TITULO POR PAGAMENTO
			cSql := "SELECT BM1.BM1_CODINT CODINT, BM1.BM1_CODEMP CODEMP, BM1.BM1_MATRIC MATRIC, BM1.BM1_TIPREG TIPREG, "
			cSql += "BM1.BM1_DIGITO DIGITO, BM1.BM1_TIPO TIPO, BM1.BM1_VALOR VLRBM1, "
			cSql += " BM1.BM1_CONEMP CONEMP , BM1.BM1_VERCON VERCON, BM1.BM1_SUBCON SUBCON,BM1.BM1_VERSUB VERSUB,  "						
			cSql += " BSP.BSP_CMPCUS BSPCMPCUS " //Vem do left join

			cSql += "FROM "+RetSqlName("BM1")+" BM1 "
			cSql += "INNER JOIN "+RetSqlName("BFQ")+" BFQ ON BM1.BM1_CODINT = BFQ.BFQ_CODINT "
			cSql += "AND BM1.BM1_CODTIP = BFQ.BFQ_PROPRI || BFQ.BFQ_CODLAN "			
			
			cSql += "LEFT OUTER JOIN "+RetSqlName("BSP")+" BSP ON BM1.BM1_CODEVE = BSP.BSP_CODSER AND BM1.BM1_CODTIP = BSP.BSP_CODLAN AND BM1.BM1_TIPO = BSP.BSP_TIPSER "
			cSql += "AND (BSP.BSP_CMPCUS = ' ' OR BSP.BSP_CMPCUS = '1') AND BSP.BSP_FILIAL = ' ' AND BSP.D_E_L_E_T_ = ' ' "
			
			cSql += "WHERE BM1.BM1_FILIAL = '"+xFilial("BM1")+"' "
			cSql += "AND BM1.BM1_PREFIX = '"+TRB2->PREFIXO+"' "
			cSql += "AND BM1.BM1_NUMTIT = '"+TRB2->NUMERO+"' "
			cSql += "AND BM1.BM1_PARCEL = '"+TRB2->PARC+"' "
			cSql += "AND BM1.BM1_TIPTIT = '"+TRB2->TIPO+"' "
			
			If !Empty(cTpLanc) .and. !Empty(cCodNEve)
				cSql += "AND ( ( BM1.BM1_AGMTFU != ' ' AND BM1.BM1_CODTIP NOT IN (" + cTpLanc + ") ) " // MV_PLDM006 Verbas da gestใo de pessoal que nใo deverใo ser consideradas para gera็ใo da DMED
				cSql += "OR ( BM1.BM1_AGMTFU = ' '  AND BM1.BM1_CODTIP NOT IN (" + cCodNEve + ") ) ) " // MV_PLDM003 Indica c๓digos de lan็amentos de cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODTIP
			ElseIf !Empty(cTpLanc)
				cSql += "AND ( BM1.BM1_AGMTFU != ' ' AND BM1.BM1_CODTIP NOT IN (" + cTpLanc + ") ) " // MV_PLDM006 Verbas da gestใo de pessoal que nใo deverใo ser consideradas para gera็ใo da DMED
			ElseIf !Empty(cCodNEve)
				cSql += "AND ( BM1.BM1_AGMTFU = ' '  AND BM1.BM1_CODTIP NOT IN (" + cCodNEve + ") ) " // MV_PLDM003 Indica c๓digos de lan็amentos de cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODTIP
			EndIf
			
			If !Empty(AllTrim(cCodEve))
				cSql += "AND BM1.BM1_CODEVE NOT IN (" + cCodEve + ") " //MV_PLDM004 Indica c๓digos de eventos de lan็amentos da cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODEVE
			EndIf

			cSql += "AND (BFQ.BFQ_CMPCUS = ' ' OR BFQ.BFQ_CMPCUS = '1') "				
			cSql += "AND BFQ.BFQ_FILIAL = '" + xFilial("BFQ") + "' AND BM1.D_E_L_E_T_ = ' ' AND BFQ.D_E_L_E_T_ = ' '"
			
		EndIf

		If lPLM260CMP //Ponto de entrada criado para manipular a composicao (BM1) do titulo encontrado na movimentacao financeira (SE5)
			cSql := ExecBlock("PLM260CMP",.F.,.F.,{cSql,"FIN",TRB2->PREFIXO,TRB2->NUMERO,TRB2->PARC,TRB2->TIPO})
			//PlsLogFil("FIN - Executado o ponto de entrada PLM260CMP",cArqlog)
		EndIf

		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB3",.F.,.T.)
		TcSetField("TRB3","VLRBM1","N",17,2)

		//Verifico titular
		If !TRB3->(Eof())
			aTmpTit := M260Usr(TRB3->CODINT,TRB3->CODEMP,TRB3->MATRIC,TRB3->TIPREG,TRB3->DIGITO,TRB1->CPF,TRB1->A1_PESSOA,cGerDmd, lDMEDPJN)
		Endif	

		While !TRB3->(Eof())
			
			If lGERDMD
				BQC->(dbSetOrder(1))
				if BQC->(msSeek(xFilial("BQC") + TRB3->CODINT + TRB3->CODEMP + TRB3->CONEMP + TRB3->VERCON + TRB3->SUBCON + TRB3->VERSUB))
					cGerDmd := BQC->BQC_GERDMD 
					If cGerDmd == '0' .AND. BQC->BQC_COBNIV == "1"     
							TRB3->(dbSkip())
							Loop						
					EndIf
				EndIf
			EndIf

			If lCMPCUS .AND. (!EMPTY(TRB3->BSPCMPCUS) .AND. TRB3->BSPCMPCUS <> "1")
				TRB3->(dbSkip())
				Loop
			EndIf



			If !B5A->(dbSeek(xFilial("B5A") + cMvPar02 + 'Z' + TRB3->(CODINT + CODEMP + MATRIC + TIPREG + DIGITO),.F.))
				RecLock("B5A",.T.)
				B5A->B5A_FILIAL	:= xFilial("B5A")
				B5A->B5A_CODINT	:= TRB3->CODINT
				B5A->B5A_CODEMP	:= TRB3->CODEMP
				B5A->B5A_MATRIC	:= TRB3->MATRIC
				B5A->B5A_TIPREG	:= TRB3->TIPREG
				If !lStrTPLS
					B5A->B5A_DIGITO	:= Iif(!Empty(TRB3->DIGITO),TRB3->DIGITO,Modulo11(TRB3->(CODINT+CODEMP+MATRIC+TIPREG)))
				Else
					B5A->B5A_DIGITO	:= Iif(!Empty(TRB3->DIGITO),TRB3->DIGITO,Modulo11(StrTPLS(TRB3->(CODINT+CODEMP+MATRIC+TIPREG))))
				EndIf
			
				aTmp := M260Usr(TRB3->CODINT,TRB3->CODEMP,TRB3->MATRIC,TRB3->TIPREG,TRB3->DIGITO,TRB1->CPF,TRB1->A1_PESSOA,cGerDmd, lDMEDPJN)

				B5A->B5A_MATVID := aTmp[2]
			/*	If mv_par20 == 1 .AND.  TRB1->A1_PESSOA = 'F'
					B5A->B5A_CPFTIT	:= TRB1->CPF
				Else
					B5A->B5A_CPFTIT := If(!aTmp[3],aTmpTit[1],aTmp[1]) // Considera CPF do usuario
				EndIf*/
				B5A->B5A_CPFTIT := If(!aTmp[3],aTmpTit[1],aTmp[1]) // Considera CPF do usuario
				B5A->B5A_CODCLI	:= TRB1->CODIGO
				B5A->B5A_LOJCLI	:= TRB1->LOJA
								
			    If TRB1->A1_PESSOA <> 'J'  
			    	B5A->B5A_VLRFIN	:= TRB2->VLRSE5
			    Else
			    	B5A->B5A_VLRFIN	:= MVlrFam(TRB2->PREFIXO, TRB2->NUMERO, TRB2->PARC, TRB2->TIPO, cTpLanc, cCodNEve, TRB3->CODINT, TRB3->CODEMP,TRB3->MATRIC,;
												TRB3->CONEMP , TRB3->VERCON , TRB3->SUBCON , TRB3->VERSUB)	
			    EndIf
			    
				B5A->B5A_VLRCUS	:= IIf( TRB3->TIPO == '1', TRB3->VLRBM1, -TRB3->VLRBM1 )
				B5A->B5A_IDEREG	:= 'Z' // STATUS PARA CLASSIFICAR O DEPENDENTE
				B5A->B5A_ANODCL	:= cMvPar02
				B5A->B5A_STATUS	:= '1' // STATUS DIGITADO - NAO ENVIADO AINDA
				lGerReg := .T.			
			Else
				RecLock("B5A",.F.)
				B5A->B5A_VLRCUS	+= IIf( TRB3->TIPO == '1', TRB3->VLRBM1, -TRB3->VLRBM1 )
			EndIf
			B5A->(MsUnlock())
	
			If lM260GRV
				ExecBlock("M260GRV",.F.,.F.,{B5A->(Recno()),lGerReg})
				//PlsLogFil("FIN - Recno " + AllTrim(Str(B5A->(Recno()))) + " sofreu manuten็ใo pelo ponto de entrada M260GRV.",cArqLog)
			EndIf

			TRB3->(dbSkip())

		EndDo
		
		If lGerReg // Vou verificar se preciso gerar o registro do titular
			M260GerReg(B5A->B5A_CODINT,B5A->B5A_CODEMP,B5A->B5A_MATRIC,B5A->B5A_TIPREG,B5A->B5A_DIGITO,cCodTit,B5A->B5A_CPFTIT,B5A->B5A_CODCLI,B5A->B5A_LOJCLI,cTpLanc,cCodEve,cCodEve,'3',B5A->B5A_ANODCL,cArqLog)
			lGerReg := .F.
		EndIf
		
		TRB3->(dbCloseArea())

		TRB2->(dbSkip())

	EndDo

	If lE5DMED
		TRB2->(dbGoTop())
		While !TRB2->(Eof())
			SE5->(dbGoto(TRB2->(REGSE5)))
			If Empty(SE5->E5_FLDMED)
				RecLock("SE5",.F.)
				SE5->E5_FLDMED	:= 'S'
				SE5->(msUnlock())
			EndIf	
			TRB2->(dbSkip())
		EndDo
	EndIf
	TRB2->(dbCloseArea())

	TRB1->(dbSkip())

EndDo
TRB1->(dbCloseArea())

//PlsLogFil("CPF com tํtulos financeiro - T้rmino: " + Dtos(dDataBase) + " " + Time(),cArqLog)

Processa( {||M260Class(cArqLog,lAutomato) },"Dmed - Declara็ใo de servi็os m้dicos e de sa๚de","Classificando dependentes...",.T. )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ M260File  บAutor  ณMicrosiga          บ Data ณ  03/28/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Escreve o arquivo texto a ser enviado para a receita       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M260File(cArqLog,lAutomato)
Local cArqDmed         := AllTrim(mv_par15) //Caminho a ser concatenado para formar o nome do arquivo
Local cInicio,cTermino := "" //Data e horario do inicio e termino do processamento
Local cSUSEP           := "" //BA0->BA0_SUSEP - codigo de registro da operadora na ANS

cArqDmed += AllTrim(SM0->M0_CGC) + "-Dmed-" + AllTrim(Str(mv_par01)) + "-" + AllTrim(Str(mv_par02)) + "-" + If(mv_par03 == 1,'ORIG','RETI') + "-" + If(mv_par03 == 1,'N','S') + ".txt"

cInicio := Dtos(dDataBase) + " " + Time()

FErase(cArqDmed)
nArqDmed := FCreate(cArqDmed)

If !lAutomato
	If nArqDmed <= 0
		MsgInfo("Nใo foi possํvel criar o arquivo " + cArqDmed)

		Return .F.
	EndIf
EndIf

dbSelectArea("BA0")
BA0->(dbSetOrder(1))

If BA0->(dbSeek(xFilial("BA0")+PlsIntPad()))
	cSUSEP := AllTrim(BA0->BA0_SUSEP)
Else
    If !lAutomato
	    MsgInfo("N๚mero de registro da operadora na ANS nใo encontrado ou inดvalido." + CLRF +;
		    	"Operadora: " + PlsIntPad() + " - Num Reg ANS ( BA0_SUSEP ).")
    EndIf
	FClose(nArqDmed)
	FErase(nArqDmed)
	Return .F.
EndIf


//PlsLogFil("Gera็ใo do arquivo Dmed - Inํcio: " + Dtos(dDatabase) + " " + Time(),cArqLog)
If !lAutomato
//3.1 - Registro de informacao da declaracao ( identificador Dmed )
FWrite(nArqDmed,"Dmed|" +; // Identificador de registro
	AllTrim(Str(mv_par01)) + "|" +; // Ano referencia
	AllTrim(Str(mv_par02)) + "|" +; // Ano calendario
	If(mv_par03 == 1,'N','S') + "|" +; // Identificador de re1tificadora	
	If(mv_par03 == 1,"",mv_par04) + "| |" + CRLF) // Numero do recibo

//3.2 - Registro do responsavel pelo preenchimento ( identificador RESPO )
FWrite(nArqDmed,"RESPO" + "|" +; // Identificador de registro
	mv_par05 + "|" +; // CPF
	AllTrim(mv_par06) + "|" +; // Nome
	AllTrim(Str(mv_par07)) + "|" +; // DDD
	AllTrim(Str(mv_par08)) + "|" +; // Telefone
	AllTrim(Str(mv_par09)) + "|" +; // Ramal
	AllTrim(Str(mv_par10)) + "|" +; // Fax
	AllTrim(mv_par11) + "|" + CRLF ) // Email

//3.3 - Registro de informacao do declarante pessoa juridica ( identificador DECPJ )
FWrite(nArqDmed,"DECPJ|" +; //Identificador de registro
	SM0->M0_CGC + "|" +; // CNPJ
	AllTrim(SM0->M0_NOMECOM) + "|" +; // Nome
	AllTrim(Str(mv_par17)) + "|" +; // Tipo do declarante
	If(mv_par17 == 2,cSUSEP,"") + "|" +; // Registro ANS
	/*SM0->M0_CNES +*/ "|" +; // CNES
	mv_par12 + "|" +; // CPF responsavel perante o CNPJ
	If(mv_par13 == 1,'S','N') + "|" +; // Indicador de situacao da declaracao
	If(mv_par13 == 1,Dtos(mv_par14),'') + "|" +; // Data do evento
	If(mv_par23 == 1,'S','N') + "|" + CRLF ); //Indicador declarante possui registro ANS

//3.4 - Registro de informacao da operadora de plano privado de assistencia a saude ( identificador OPPAS )
If mv_par17 == 2 // Operadora de Saude
	FWrite(nArqDmed,"OPPAS|" + CRLF)
Else // Prestador de servico
	FWrite(nArqDmed,"PSS|" + CRLF)//3.9. Registro de informa็ใo do prestador de servi็o de sa๚de (identificador PSS)
EndIf

EndIF
//Gravacao dos registro provenientes da B5A
M260B5AT(nArqDmed,cArqLog,cArqDmed,lAutomato)

//3.12 - Registro identificador do termino da declaracao ( identificador FIMDmed )
If !lAutomato
	FWrite(nArqDmed,"FIMDmed|" + CRLF)
	FClose(nArqDmed)
EndIF

cTermino := Dtos(dDataBase) + " " + Time()
//PlsLogFil("Arquivo para envio da Dmed gerado com sucesso!" + CRLF + cArqDmed + CRLF + "Inicio: " + cInicio + "  - Termino: " + cTermino,cArqLog)
If !lAutomato
	MsgInfo("Arquivo para envio da Dmed gerado com sucesso!" + CRLF + cArqDmed + CRLF + "Inicio: " + cInicio + "  - Termino: " + cTermino)
EndIF

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDecIdeReg บAutor  ณMicrosiga           บ Data ณ  31/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Decode dos tipos de registros                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DecIdeReg(cIdeReg)
Local cRet := ""

If mv_par17 == 2 // Operadora de saude

	Do Case
		Case cIdeReg == "1"
			cRet := "TOP"
		Case cIdeReg == "2"
			cRet := "RTOP"
		Case cIdeReg == "3"
			cRet := "DTOP"
		Case cIdeReg == "4"
			cRet := "RDTOP"
		OtherWise
			cRet := "ZZZ"
	EndCase
	
Else // Prestador de servico

	Do Case
		Case cIdeReg == "1"
			cRet := "RPPSS"
		Case cIdeReg == "3"
			cRet := "BRPPSS"
		OtherWise
			cRet := "ZZZ"
	EndCase
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM260DTOP  บAutor  ณMicrosiga           บ Data ณ  31/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava registro TOP zerado para DTOP sem registro TOP        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAPLS                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
cIdeReg - tipo de registro a ser criado
cAlias - area de trabalho corrente
cArqLog - arquivo de log que esta sendo gravado
*/
Static Function M260DTOP(cIdeReg,cAlias,cArqLog,lAutomato)
Local cLinTxt := "" //Registro a ser gravado no arquivo
Local lCPFDep := .F. // Define se envia CPF em branco para dependente menor de idade que tenha CPF igual ao do titular
Local nInd	  := IIF(MV_PAR20 == 1,4,IIF(cIdeReg<>"1",2,1))
Local cChave  := IIF(mv_par20 == 1,cAlias+"->B5A_CPFTIT",IIf(cIdeReg<>"1",cAlias+"->(B5A_CODINT+B5A_CODEMP+B5A_MATRIC+B5A_TIPREG+B5A_DIGITO)" ,cAlias+"->(B5A_CODINT+B5A_CODEMP+B5A_MATRIC)"+ "+ '" + cCodTit+ "' "))
cLinTxt := DecIdeReg(cIdeReg) + "|"

If mv_par16 == 1//Processamento da folha - GPE
	nInd := 4
	cChave := cAlias+"->B5A_CPFTIT" 
EndIf
                                                              
Do Case

	Case cIdeReg == '1'

		BA1->(dbSetOrder(nInd))
		If BA1->(dbSeek(xFilial("BA1")+&(cChave)))
			cLinTxt += AllTrim(&(cAlias+"->B5A_CPFTIT")) + "|"
			cLinTxt += AllTrim(&(cAlias+"->B5A_NOMUSR")) + "|"
			cLinTxt += AllTrim(Replace(Transform(IIf(&(cAlias+"->B5A_VLRCUS")+&(cAlias+"->B5A_VLRGPE")<0,0,&(cAlias+"->B5A_VLRCUS")+&(cAlias+"->B5A_VLRGPE")),MOEDA),',','')) + "|"
			//PlsLogFil("Registro TOP gerado para DTOP "+&(cAlias+"->B5A_CPFTIT")+" - "+&(cAlias+"->B5A_NOMUSR")+" - "+cLinTxt,cArqLog)
		Else
			cLinTxt := ""
			//PlsLogFil("Beneficiario nao encontrado para criar o registro TOP "+&(cAlias+"->(B5A_CODINT+B5A_CODEMP+B5A_MATRIC)")+cCodTit,cArqLog)
		EndIf

	Case cIdeReg == '3'

		BA1->(dbSetOrder(nInd))
		If BA1->(dbSeek(xFilial("BA1")+&(cChave)))

			//Enviar registros de dependentes com CPF igual a branco quando o dependente for menor de idade e o CPF for igual ao do titular
			If mv_par22 == 2 .And. BA1->BA1_CPFUSR == &(cAlias+"->B5A_CPFTIT") .And. Calc_Idade(dDataBase,BA1->BA1_DATNAS) < 18
				lCPFDep := .T.
			EndIf

			cLinTxt += Iif(!lCPFDep,AllTrim(BA1->BA1_CPFUSR),"") +"|"
			cLinTxt += AllTrim(BA1->BA1_DATNAS) +"|"
			cLinTxt += AllTrim(Subs(BA1->BA1_NOMUSR,1,60)) +"|"
			cLinTxt += AllTrim(M260GrPa(BA1->BA1_GRAUPA)) + "|"
			cLinTxt += AllTrim(Replace(Transform(0,MOEDA),',','')) +"|"
			//PlsLogFil("Registro DTOP gerado para RDTOP "+AllTrim(BA1->BA1_CPFUSR)+" - "+AllTrim(Subs(BA1->BA1_NOMUSR,1,60))+" - "+cLinTxt,cArqLog)
		Else
			cLinTxt := ""
			//PlsLogFil("Beneficiario nao encontrado para criar o registro DTOP "+&(cAlias+"->(B5A_CODINT+B5A_CODEMP+B5A_MATRIC+B5A_TIPREG+B5A_DIGITO)"),cArqLog)
		EndIf

	OtherWise

		cLinTxt := ""
		//PlsLogFil("Tipo de registro desconhecido " + cIdeReg,cArqLog)

EndCase

Return(cLinTxt)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM260DelB5AบAutor  ณMicrosiga           บ Data ณ  07/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para eliminacao de registros da tabela B5A quando   บฑฑ
ฑฑบ          ณ esta ja' estiver preenchida.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M260DelB5A(cArqLog)
Local cSql := ""

IncProc("Eliminando registros da tabela B5A...")
ProcessMessage()
cSql := "DELETE FROM "+RetSqlName("B5A")+" WHERE B5A_FILIAL = '"+xFilial("B5A")+"' AND B5A_ANODCL = '"+StrZero(mv_par02,4)+"' "
TcSqlExec(cSql)
//PlsLogFil("Executado o reprocessamento da DMED " + Dtos(dDataBase) + Time(),cArqLog)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSM260   บAutor  ณMicrosiga           บ Data ณ  04/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que avalia se a DMED pode ser gerada, pois nao ha'  บฑฑ
ฑฑบ          ณ registros no B5A, ou avisa se deve ser reprocessada.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M260Check()
Local lRet	:= .T.

B5A->(dbSetOrder(1))
If B5A->(dbSeek(xFilial("B5A")+StrZero(mv_par02,4),.F.))
	lRet := .F.
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ M260ClassบAutor  ณMicrosiga           บ Data ณ  03/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a declaracao da Dmed com os dados do beneficiariosบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M260Class(cArqLog,lAutomato)
Local cSql := ""
Local cUpd := ""
Local lPto := .F.
Local lPM260CLS := ExistBlock("PM260CLS")
Local lPM260CLA := ExistBlock("PM260CLA")

//MsgInfo("Processamento concluํdo. Inํcio da classifica็ใo.")

cSql := "SELECT B5A_NOMUSR, BA1_NOMUSR, B5A_CPFDEP, BA1_CPFUSR, B5A_RELDEP, BA1_GRAUPA, B5A_DATNAS, BA1_DATNAS, B5A_CPFTIT,  " 
cSql += RetSqlName("B5A") + ".R_E_C_N_O_ RECB5A, BA1_TIPUSU "
cSql += "FROM " + RetSqlName("B5A") + ", " + RetSqlName("BA1") + " "
cSql += "WHERE B5A_FILIAL='" + xFilial("B5A") + "' AND BA1_FILIAL='" + xFilial("BA1") + "' "
cSql += "AND B5A_ANODCL='" + AllTrim(Str(mv_par02)) + "' "
cSql += "AND B5A_IDEREG='Z' "
cSql += "AND B5A_CODINT=BA1_CODINT "
cSql += "AND B5A_CODEMP=BA1_CODEMP "
cSql += "AND B5A_MATRIC=BA1_MATRIC "
cSql += "AND B5A_TIPREG=BA1_TIPREG "
cSql += "AND B5A_DIGITO=BA1_DIGITO "
cSql += "AND " + RetSqlName("B5A") + ".D_E_L_E_T_=' ' "
cSql += "AND " + RetSqlName("BA1") + ".D_E_L_E_T_=' ' "

cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)
//PlsLogFil("Classificacao pelo BA1 - inํcio: " + Dtos(dDataBase) + " " + Time(),cArqLog)
//PlsLogFil("Consulta executada: " + cSql,cArqLog)
If !lAutomato
    ProcessMessage()
    ProcRegua(0)
EndIF

While !TRB1->(Eof())
	If !lAutomato
	    IncProc("Classificando: " + TRB1->BA1_NOMUSR)
    EndIF
	
	If lPM260CLS // Classificacao da B5A por ponto de entrada
		ExecBlock("PM260CLS",.F.,.F.,{AllTrim(Str(TRB1->RECB5A))})
		lPto := .T.
	Else
		
		If Empty(TRB1->B5A_NOMUSR) .Or. Empty(TRB1->B5A_CPFDEP) .Or. Empty(TRB1->B5A_RELDEP) .Or. Empty(TRB1->B5A_DATNAS)
			cUpd := "UPDATE " + RetSqlName("B5A") + " SET "
			cUpd += "B5A_NOMUSR='" + SUBSTR(TRB1->BA1_NOMUSR,1,TamSX3("B5A_NOMUSR")[1]) + "', "

			If TRB1->BA1_TIPUSU <> GetNewPar("MV_PLCDTIT","T")
				cUpd += "B5A_CPFDEP='" + TRB1->BA1_CPFUSR + "', "
			EndiF	
			
			cUpd += "B5A_DATNAS='" + TRB1->BA1_DATNAS + "', "
			cUpd += "B5A_RELDEP='" + M260GrPa(TRB1->BA1_GRAUPA) + "' "
	
			If mv_par20 == 1 // Considera CPF do responsavel financeiro
				If TRB1->B5A_CPFTIT == TRB1->BA1_CPFUSR
					cUpd += ", B5A_IDEREG='1' "
				Else
					cUpd += ", B5A_IDEREG='3' "
				EndIf
			Else // Considera CPF do usuario
				If cCodTit == TRB1->BA1_TIPUSU
					cUpd += ", B5A_IDEREG='1' "
				Else
					cUpd += ", B5A_IDEREG='3' "
				EndIf
			EndIf
			
			cUpd += "WHERE R_E_C_N_O_=" + AllTrim(Str(TRB1->RECB5A))
			TCSQLEXEC(cUpd)
			If SubStr(cBanco,1,6) == "ORACLE"
				TCSQLEXEC("COMMIT")
			Endif

			If lPM260CLA // Alteracao da Classificacao da B5A por ponto de entrada
				ExecBlock("PM260CLA",.F.,.F.,{AllTrim(Str(TRB1->RECB5A))})
				lPto := .T.
			EndIf
		
		EndIf
		
	EndIf
	
	TRB1->(dbSkip())
	
EndDo

TRB1->(dbCloseArea())

/*If !lPto
	PlsLogFil("Classificacao pelo BA1 - t้rmino: " + Dtos(dDataBase) + " " + Time(),cArqLog)
Else
	PlsLogFil("Classificacao pelo ponto de entrada - t้rmino: " + Dtos(dDataBase) + " " + Time(),cArqLog)
EndIf*/

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ M260Usr  บAutor  ณTOTVS S/A           บ Data ณ  15/07/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o CPF e matricula da vida do usuario                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAPLS                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M260Usr(cCodInt,cCodEmp,cMatric,cTipReg,cDigito,cCpf,cPessoa,cGerDmd,lDMEDPJN)
Local cRetCpf := ""
Local cMatVid := ""
Local AreaTmp := GetArea()
Local lTitular:=.F.
DEFAULT cGerDmd := " "

dbSelectArea("BA1")
BA1->(dbSetOrder(2))
If lDMEDPJN .AND. cGerDmd <> '1'
	If BA1->(dbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+cTipReg+cDigito))
		cRetCpf := BA1->BA1_CPFUSR
		cMatVid := BA1->BA1_MATVID
	Else
		If BA1->(dbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+cTipReg+cDigito))
			cMatVid := BA1->BA1_MATVID
		EndIf
		cRetCpf := cCpf
	EndIf
Else
	If cPessoa == 'J' .and. BA1->(dbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+'00')) .AND. cGerDmd == '1'
		cRetCpf := BA1->BA1_CPFUSR
		If BA1->(dbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+cTipReg+cDigito))
			cMatVid := BA1->BA1_MATVID
		ElseIf BA1->(dbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+cTipReg))
			cMatVid := BA1->BA1_MATVID
		EndIf

	Else
		If BA1->(dbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+cTipReg))
			cMatVid := BA1->BA1_MATVID
		EndIf
		cRetCpf := cCpf
	EndIf
EndIf
RestArea(AreaTmp)

If GetNewPar("MV_PLCDTIT","T") == BA1->BA1_TIPUSU

	lTitular:=.T.
EndiF



Return {cRetCpf,cMatVid,lTitular}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ M260B5AT บAutor  ณMicrosiga           บ Data ณ  15/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Escreve no arquivo texto os registros TOP e RTOP           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M260B5AT(nArqDmed,cArqLog,cArqDmed,lAutomato)
Local cSqlB5A  := "" // Query para o arquivo textoLocal cLinTxt  := "" // Linha a ser gravada no arquivo texto
Local lLinTxt  := .T. // Indica se o registro da B5A e valido para ser gravado no arquivo
Local nTRBB5A  := 0 // Posicao da regua
Local cLastCPF := '' // Ultimo CPF posicionado
Local cMudaCpf := ''
Local cCodInt  := '' // Matricula da ultima familia posicionada
Local cCodemp  := ''
Local cMatric  := ''
Local cTipReg  := ''
Local cDigito  := '' 
Local cMatAux  := ''
Local lRetPto  := .T. // Retorno do ponto de entrada indicado se o registro sera ignorado
Local lErro	   := .F.    
Local lPM260B5A:= ExistBlock("PM260B5A")    
Local cNomUsr  := ""
Local lDMEDPJN := GetNewPar("MV_DMEDPJ ","N") == "N"
Local lDMEDPJS := GetNewPar("MV_DMEDPJ ","N") == "S"
Local cMvPar02 := StrZero(mv_par02,4)
DEFAULT nArqDmed := ""
DEFAULT cArqLog	 := ""
DEFAULT cArqDmed := ""

If cBanco == "MSSQL"
	
	cSqlB5A := "SELECT REPLICATE('0',14-LEN(B5A_CPFTIT))+B5A_CPFTIT CPFTITO,B5A_CPFTIT, B5A_IDEREG, B5A_CPFRDA, B5A_NOMRDA,B5A_NOMUSR, "
	cSqlB5A += " REPLICATE('0',14-LEN(B5A_CPFRDA))+B5A_CPFRDA CPFRDAO,SUM(B5A_VLRCUS) B5A_VLRCUS, SUM(B5A_VLRREE) B5A_VLRREE, "
	cSqlB5A += " SUM(B5A_VLRGPE) B5A_VLRGPE, SUM(B5A_VLRANT) B5A_VLRANT "
	
	If mv_par20 == 2
		cSqlB5A += " ,B5A_CODINT, B5A_CODEMP, B5A_MATRIC, B5A_TIPREG, B5A_DIGITO "
	EndIf
	
ElseIf cBanco == "ORACLE"
	
	cSqlB5A := "SELECT LPAD(TRIM(B5A_CPFTIT),14,'0') CPFTITO,B5A_CPFTIT, B5A_IDEREG, B5A_CPFRDA, B5A_NOMRDA,B5A_NOMUSR, "
	cSqlB5A += " LPAD(TRIM(B5A_CPFRDA),14,'0') CPFRDAO,SUM(B5A_VLRCUS) B5A_VLRCUS, SUM(B5A_VLRREE) B5A_VLRREE, "
	cSqlB5A += " SUM(B5A_VLRGPE) B5A_VLRGPE, SUM(B5A_VLRANT) B5A_VLRANT "
	
	If mv_par20 == 2 .and. lDMEDPJN
		cSqlB5A += " , B5A_CODINT, B5A_CODEMP, B5A_MATRIC, B5A_TIPREG, B5A_DIGITO "
	EndIf
	
Else
	
	cSqlB5A := "SELECT B5A_CPFTIT CPFTITO,B5A_CPFTIT, B5A_IDEREG, B5A_CPFRDA, B5A_NOMRDA,B5A_NOMUSR , "
	cSqlB5A += " B5A_CPFRDA CPFRDAO,SUM(B5A_VLRCUS) B5A_VLRCUS, SUM(B5A_VLRREE) B5A_VLRREE, "
	cSqlB5A += " SUM(B5A_VLRGPE) B5A_VLRGPE, SUM(B5A_VLRANT) B5A_VLRANT "
	
	If mv_par20 == 2
		cSqlB5A += " ,B5A_CODINT, B5A_CODEMP, B5A_MATRIC, B5A_TIPREG, B5A_DIGITO "
	EndIf
	
EndIf

cSqlB5A += " FROM " + RetSqlName("B5A")
cSqlB5A += " WHERE B5A_FILIAL = '" + xFilial("B5A") + "' AND B5A_ANODCL = '" + cMvPar02 + "' AND D_E_L_E_T_ = ' ' "
cSqlB5A += " AND B5A_IDEREG IN ('1','2') " // Apenas registro do tipo TOP e RTOP

//If !Empty(cCpf)
//	cSqlB5A += " AND B5A_CODINT+B5A_CODEMP+B5A_MATRIC='" +cCpf+ "' "
//EndIf

If cBanco == "MSSQL"              

	cSqlB5A += " GROUP BY REPLICATE('0',14-LEN(B5A_CPFTIT))+B5A_CPFTIT, B5A_CPFTIT, B5A_IDEREG, REPLICATE('0',14-LEN(B5A_CPFRDA))+B5A_CPFRDA,B5A_CPFRDA, B5A_NOMRDA,B5A_NOMUSR "	

	If mv_par20 == 2
		 cSqlB5A += " , B5A_CODINT, B5A_CODEMP, B5A_MATRIC, B5A_TIPREG, B5A_DIGITO "	
	EndIf
	
	cSqlB5A += " ORDER BY B5A_CPFTIT, B5A_IDEREG"
	
ElseIf cBanco == "ORACLE"
	
	cSqlB5A += " GROUP BY LPAD(TRIM(B5A_CPFTIT),14,'0'), B5A_CPFTIT, B5A_IDEREG, LPAD(TRIM(B5A_CPFRDA),14,'0'),B5A_CPFRDA, B5A_NOMRDA,B5A_NOMUSR " 
	
	If mv_par20 == 2 .and. lDMEDPJN
   		cSqlB5A += " , B5A_CODINT, B5A_CODEMP, B5A_MATRIC, B5A_TIPREG, B5A_DIGITO "
	EndIf
	   		
	cSqlB5A += " ORDER BY B5A_CPFTIT, B5A_IDEREG"
	
Else                               
	
	cSqlB5A += " GROUP BY B5A_CPFTIT, B5A_CPFTIT, B5A_IDEREG, B5A_CPFRDA,B5A_CPFRDA, B5A_NOMRDA,B5A_NOMUSR "

	If mv_par20 == 2	
		cSqlB5A += " , B5A_CODINT, B5A_CODEMP, B5A_MATRIC, B5A_TIPREG, B5A_DIGITO "
	EndIf		
	
	cSqlB5A += " ORDER BY B5A_CPFTIT, B5A_IDEREG"

EndIf

cSqlB5A := ChangeQuery(cSqlB5A)

If ExistBlock("P260B5AI")
	cSqlB5A := ExecBlock("P260B5AI",.F.,.F.,{cSqlB5A})
	//PlsLogFil("Consulta alterada pelo ponto de entrada P260B5AI.",cArqLog)
EndIf

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlB5A),"TRBT",.F.,.T.)

//PlsLogFil("M260B5AT - Consulta executada: " + cSqlB5A,cArqLog)

SA1->(dbSetOrder(3))
BA1->(dbSetOrder(1))
B5A->(dbSetOrder(1))

If !lAutomato
    IncProc("Grava็ใo do arquivo Dmed")
    //PlsLogFil("Grava็ใo do arquivo Dmed - inํcio: " + Dtos(dDataBase) + " " + Time(),cArqLog)
    ProcessMessage()
EndIf

While !TRBT->(Eof())
	
	lErro	 := .F.
	cMudaCpf := TRBT->B5A_CPFTIT
	
	If mv_par20==1 .or. lDMEDPJS
		If B5A->(dbSeek(xFilial("B5A")+cMvPar02+TRBT->B5A_CPFTIT+TRBT->B5A_IDEREG))
			cCodInt := B5A->B5A_CODINT
			cCodemp := B5A->B5A_CODEMP
			cMatric := B5A->B5A_MATRIC
			cTipReg := B5A->B5A_TIPREG
			cDigito := B5A->B5A_DIGITO  
			cNomUsr	:= B5A->B5A_NOMUSR  
		EndIf	
	Else 
		cCodInt := TRBT->B5A_CODINT
		cCodemp := TRBT->B5A_CODEMP
		cMatric := TRBT->B5A_MATRIC
		cTipReg := TRBT->B5A_TIPREG
		cDigito := TRBT->B5A_DIGITO
		cNomUsr	:= TRBT->B5A_NOMUSR
	EndIf          
	
	cMatAux := cCodInt+cCodemp+cMatric 
			
	While !TRBT->(Eof()) .And. (TRBT->B5A_CPFTIT == cMudaCpf .Or. (mv_par20 == 1 .or. lDMEDPJS))

		If mv_par20==1 .or. lDMEDPJS
			If B5A->(dbSeek(xFilial("B5A")+cMvPar02+TRBT->B5A_CPFTIT+TRBT->B5A_IDEREG))
				cCodInt := B5A->B5A_CODINT
				cCodemp := B5A->B5A_CODEMP
				cMatric := B5A->B5A_MATRIC
				cTipReg := B5A->B5A_TIPREG
				cDigito := B5A->B5A_DIGITO
				cNomUsr	:= B5A->B5A_NOMUSR  				
			EndIf	
		Else 
			cCodInt := TRBT->B5A_CODINT
			cCodemp := TRBT->B5A_CODEMP
			cMatric := TRBT->B5A_MATRIC
			cTipReg := TRBT->B5A_TIPREG
			cDigito := TRBT->B5A_DIGITO
			cNomUsr	:= TRBT->B5A_NOMUSR  			
		EndIf          
		
		lErro := .F.
		lLinTxt := .T.
		nTRBB5A++
        If !lAutomato
		    IncProc(AllTrim(Str(nTRBB5A)) + " - " +  AllTrim(cNomUsr))
        EndIf
		
		lRetPto  := .T.
		If lPM260B5A
			lRetPto := ExecBlock("PM260B5A",.F.,.F.,{TRBT->B5A_IDEREG,cCodInt+cCodemp+cMatric+cTipReg+cDigito,TRBT->B5A_CPFTIT})
		EndIf
		
		If !lRetPto //Registro ignorado pelo ponto de entrada
			lErro	 := .T.
			//PlsLogFil("Registro ignorado pelo ponto de entrada PM260B5A: "+TRBT->B5A_IDEREG+" - "+cCodInt+cCodemp+cMatric+cTipReg+cDigito+" - "+TRBT->B5A_CPFTIT,cArqLog)
			TRBT->(dbSkip())
			Loop
		EndIf
		
		If Empty(TRBT->B5A_CPFTIT) // Nao gravo no arquivo texto titular sem CPF
			lErro	 := .T.
			//PlsLogFil("Registro ignorado por nใo conter CPF do titular: " + TRBT->B5A_IDEREG+" - "+/*cCodInt+cCodemp+cMatric+cTipReg+cDigito+*/" - "+TRBT->B5A_CPFTIT,cArqLog)
			cLastCPF := TRBT->B5A_CPFTIT
			//cMatAux  := cCodInt+cCodemp+cMatric
			TRBT->(dbSkip())
			Loop
		EndIf
		
		Do Case
			//3.5. - Registro de informa็ใo do titular do plano (identificador TOP)
			Case TRBT->B5A_IDEREG == '1' // TOP/RPPSS
				cLinTxt	:= DecIdeReg(TRBT->B5A_IDEREG) + "|"
				cLinTxt += AllTrim(TRBT->B5A_CPFTIT) + "|"
				cLinTxt += AllTrim(cNomUsr) + "|"
				If mv_par17 == 2 // Operadora de saude
				cLinTxt += AllTrim(Replace(Transform(IIf(TRBT->B5A_VLRCUS+TRBT->B5A_VLRGPE<0,0,TRBT->B5A_VLRCUS+TRBT->B5A_VLRGPE),MOEDA),',',''))+"|"
				Else // Prestador de Servi็o
					If(TRBT->B5A_VLRCUS+TRBT->B5A_VLRGPE<=0)
						cLinTxt += ''+"|"
					Else
						cLinTxt += AllTrim(Replace(Transform(TRBT->B5A_VLRCUS+TRBT->B5A_VLRGPE,MOEDA),',',''))+"|"
					EndIf
				EndIf
				cLastCPF := TRBT->B5A_CPFTIT
				cMatAux  := cCodInt+cCodemp+cMatric
			//3.6. - Registro de informa็ใo de reembolso do titular do plano (identificador RTOP)
			Case TRBT->B5A_IDEREG == '2' // RTOP

				//Considera CPF do usuario e mudou a familia				Considera CPF do resp. fin. e mudou o CPF
			
				If (mv_par20 == 1 .or. lDMEDPJS) .And. cLastCPF != TRBT->B5A_CPFTIT .And. mv_par16 <> 1//Se cons cpf do usu = nao e mudou cpf e diferente de folha
					cLinTxt	:= M260DTOP('1','TRBT',cArqLog,lAutomato) // Vou gerar o registro TOP
					If !Empty(cLinTxt)
						LimpaCarac(@cLinTxt)
						FWrite(nArqDmed,cLinTxt + CRLF)
					Else
						lLinTxt := .F.
					EndIf
				ElseIf mv_par20 == 2 .And. ( cMatAux != cCodInt+cCodemp+cMatric .Or.cLastCPF != TRBT->B5A_CPFTIT )
					cLinTxt	:= M260DTOP('1','TRBT',cArqLog,lAutomato) // Vou gerar o registro TOP
					If !Empty(cLinTxt)
						LimpaCarac(@cLinTxt)
						FWrite(nArqDmed,cLinTxt + CRLF)
					Else
						lLinTxt := .F.
					EndIf
				EndIf    

				cLinTxt  := DecIdeReg(TRBT->B5A_IDEREG)	+ "|"
				cLinTxt  += AllTrim(TRBT->B5A_CPFRDA)	+ "|"
				cLinTxt  += AllTrim(TRBT->B5A_NOMRDA)  	+ "|"
				cLinTxt  += AllTrim(Replace(Transform(IIf(TRBT->B5A_VLRREE<0,0,TRBT->B5A_VLRREE),MOEDA),',','')) + "|"
				cLinTxt  += AllTrim(Replace(Transform(IIf(TRBT->B5A_VLRANT<0,0,TRBT->B5A_VLRANT),MOEDA),',','')) + "|"
				cLastCPF := TRBT->B5A_CPFTIT
				cMatAux  := cCodInt+cCodemp+cMatric
				
			OtherWise // Nao classificado
				lErro	 := .T.
				lLinTxt  := .F.
				//PlsLogFil("Registro DMED sem classifica็ใo: " + TRBT->B5A_IDEREG+" - "+cCodInt+cCodemp+cMatric+cTipReg+cDigito+" - "+TRBT->B5A_CPFTIT +" - " + cNomUsr,cArqLog)
		EndCase
		
		If lLinTxt // "Tudo" ok vou gravar o registro no arquivo texto
			LimpaCarac(@cLinTxt)
			If !lAutomato
				FWrite(nArqDmed,cLinTxt + CRLF)
			EndIF
		//Else
			//PlsLogFil("Nใo foi possํvel gravar o registro: "+cLinTxt,cArqLog)
		EndIf

		TRBT->(dbSkip())
		If !lErro .And. cMudaCpf <> TRBT->B5A_CPFTIT //.And. mv_par16 <> 2 //Se mudou o CPF e estou processando somente GPE
			M260B5AD(nArqDmed,cArqLog,cArqDmed,cLastCPF,Substr(cMatAux,1,4),Substr(cMatAux,5,4),Substr(cMatAux,9,6),lAutomato)//Chama a escrita de dependentes
		EndIf

		cMudaCpf := TRBT->B5A_CPFTIT
		
	EndDo

EndDo

TRBT->(dbCloseArea())

//Vou atualizar o movimento do ano como enviado (B5A_STATUS=2)
cUpd := "UPDATE " + RetSqlName("B5A") + " SET B5A_STATUS='2' WHERE B5A_FILIAL = '" + xFilial("B5A") + "' AND B5A_ANODCL = '" + cMvPar02 + "' AND D_E_L_E_T_ = ' '"

If ExistBlock("P260B5AT")
	cUpd := ExecBlock("P260B5AT",.F.,.F.,{cUpd})
	//PlsLogFil("Update alterado pelo ponto de entrada P260B5AT.",cArqLog)
EndIf

TCSQLEXEC(cUpd)
If SubStr(cBanco,1,6) == "ORACLE"
	TCSQLEXEC("COMMIT")
Endif

//PlsLogFil("Grava็ใo do arquivo Dmed - t้rmino: " + Dtos(dDataBase) + " " + Time(),cArqLog)

Return Nil
					
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ M260B5AD บAutor  ณMicrosiga           บ Data ณ  15/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Escreve no arquivo texto os registros DTOP e RDTOP         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M260B5AD(nArqDmed,cArqLog,cArqDmed,cCpfTit,cCodInt,cCodEmp,cMatric,lAutomato)
Local cSqlDep  := "" // Query dos registros DTOP e RDTOP
Local cLinTxt  := "" // Linha a ser gravada no arquivo texto
Local cLastDep := "" // Ultimo dependente gravado como DTOP 
Local cDepPos  := "Iif(mv_par20 == 1 .or. GetNewPar('MV_DMEDPJ','N') == 'S',TRBD->(B5A_CPFTIT+B5A_CPFDEP+B5A_MATVID) ,TRBD->(B5A_CODINT+B5A_CODEMP+B5A_MATRIC+B5A_TIPREG+B5A_DIGITO))" // Dependente posicionado
Local lLinTxt  := .T. // Indica se o registro da B5A e valido para ser gravado no arquivo
Local lRetPto  := .T. // Retorno do ponto de entrada para ignorar o registro posicionado
Local lCPFDep  := .F. // Define se envia CPF em branco para dependente menor de idade que tenha CPF igual ao do titular
Local lPM260B5A:= ExistBlock("PM260B5A")
Local lDMEDPJS := GetNewPar("MV_DMEDPJ ","N") == "S"


If cBanco == "MSSQL"
	If mv_par20 == 1
		cSqlDep := "SELECT REPLICATE('0',14-LEN(B5A_CPFTIT))+B5A_CPFTIT CPFTITO, B5A_CPFTIT, B5A_CPFDEP, B5A_MATVID, B5A_NOMUSR, B5A_IDEREG, B5A_CPFRDA, B5A_NOMRDA, "
		cSqlDep += "REPLICATE('0',14-LEN(B5A_CPFDEP))+B5A_CPFDEP CPFDEPO, B5A_DATNAS, MIN(B5A_RELDEP) B5A_RELDEP, "
		cSqlDep += "REPLICATE('0',14-LEN(B5A_CPFRDA))+B5A_CPFRDA CPFRDAO, SUM(B5A_VLRCUS) B5A_VLRCUS, SUM(B5A_VLRANT) B5A_VLRANT, "
		cSQLDep	+= "SUM(B5A_VLRREE) B5A_VLRREE, SUM(B5A_VLRGPE) B5A_VLRGPE"
	Else
		cSqlDep := "SELECT REPLICATE('0',14-LEN(B5A_CPFTIT))+B5A_CPFTIT CPFTITO, B5A_CPFTIT, B5A_CPFDEP, B5A_MATVID, B5A_NOMUSR, B5A_IDEREG, B5A_CPFRDA, B5A_NOMRDA, B5A_CODINT, "
		cSqlDep += "REPLICATE('0',14-LEN(B5A_CPFDEP))+B5A_CPFDEP CPFDEPO, B5A_CODEMP, B5A_MATRIC, B5A_TIPREG, B5A_DIGITO, B5A_DATNAS, B5A_RELDEP, "
		cSqlDep += "REPLICATE('0',14-LEN(B5A_CPFRDA))+B5A_CPFRDA CPFRDAO, SUM(B5A_VLRCUS) B5A_VLRCUS, SUM(B5A_VLRANT) B5A_VLRANT, "
		cSQLDep	+= "SUM(B5A_VLRREE) B5A_VLRREE, SUM(B5A_VLRGPE) B5A_VLRGPE"
	EndIf
ElseIf cBanco == "ORACLE"
	If mv_par20 == 1 .or. lDMEDPJS
		cSqlDep := "SELECT LPAD(TRIM(B5A_CPFTIT),14,'0') CPFTITO, B5A_CPFTIT, B5A_CPFDEP, B5A_MATVID, B5A_NOMUSR, B5A_IDEREG, B5A_CPFRDA, B5A_NOMRDA, "
		cSqlDep += "LPAD(TRIM(B5A_CPFDEP),14,'0') CPFDEPO, B5A_DATNAS, MIN(B5A_RELDEP) B5A_RELDEP, "
		cSqlDep += "LPAD(TRIM(B5A_CPFRDA),14,'0') CPFRDAO, SUM(B5A_VLRCUS) B5A_VLRCUS, SUM(B5A_VLRREE) B5A_VLRREE, SUM(B5A_VLRANT) B5A_VLRANT, "
		cSqlDep += "SUM(B5A_VLRGPE) B5A_VLRGPE"
	Else
		cSqlDep := "SELECT LPAD(TRIM(B5A_CPFTIT),14,'0') CPFTITO, B5A_CPFTIT, B5A_CPFDEP, B5A_MATVID, B5A_NOMUSR, B5A_IDEREG, B5A_CPFRDA, B5A_NOMRDA, B5A_CODINT, "
		cSqlDep += "LPAD(TRIM(B5A_CPFDEP),14,'0') CPFDEPO, B5A_CODEMP, B5A_MATRIC, B5A_TIPREG, B5A_DIGITO, B5A_DATNAS, MIN(B5A_RELDEP) B5A_RELDEP, "
		cSqlDep += "LPAD(TRIM(B5A_CPFRDA),14,'0') CPFRDAO, SUM(B5A_VLRCUS) B5A_VLRCUS, SUM(B5A_VLRREE) B5A_VLRREE, SUM(B5A_VLRANT) B5A_VLRANT, "
		cSqlDep += "SUM(B5A_VLRGPE) B5A_VLRGPE"
	EndIf
Else
	If mv_par20 == 1
		cSqlDep := "SELECT B5A_CPFTIT CPFTITO, B5A_CPFTIT, B5A_CPFDEP, B5A_MATVID, B5A_NOMUSR, B5A_IDEREG, B5A_CPFRDA, B5A_NOMRDA, "
		cSqlDep += "B5A_CPFDEP CPFDEPO, B5A_DATNAS, MIN(B5A_RELDEP) B5A_RELDEP, "
		cSqlDep += "B5A_CPFRDA CPFRDAO, SUM(B5A_VLRCUS) B5A_VLRCUS, SUM(B5A_VLRREE) B5A_VLRREE, SUM(B5A_VLRANT) B5A_VLRANT, "
		cSqlDep += "SUM(B5A_VLRGPE) B5A_VLRGPE"
	Else
		cSqlDep := "SELECT B5A_CPFTIT CPFTITO, B5A_CPFTIT, B5A_CPFDEP, B5A_MATVID, B5A_NOMUSR, B5A_IDEREG, B5A_CPFRDA, B5A_NOMRDA, B5A_CODINT, "
		cSqlDep += "B5A_CPFDEP CPFDEPO, B5A_CODEMP, B5A_MATRIC, B5A_TIPREG, B5A_DIGITO, B5A_DATNAS, MIN(B5A_RELDEP) B5A_RELDEP, "
		cSqlDep += "B5A_CPFRDA CPFRDAO, SUM(B5A_VLRCUS) B5A_VLRCUS, SUM(B5A_VLRREE) B5A_VLRREE, SUM(B5A_VLRANT) B5A_VLRANT, "
		cSqlDep += "SUM(B5A_VLRGPE) B5A_VLRGPE"
	EndIf
EndIf
cSqlDep += " FROM " + RetSqlName("B5A") + " WHERE B5A_FILIAL = '" + xFilial("B5A") + "'"
cSqlDep += " AND B5A_ANODCL = '" + StrZero(mv_par02,4) + "'"

If (mv_par20 == 1 .And. cCpfTit != Nil) .or. lDMEDPJS // Se nao considero o CPF do usuario, e sim do cliente, vou filtrar o CPF do titular tambem
	cSqlDep += " AND B5A_CPFTIT = '" + cCpfTit + "'"
Else
	cSqlDep += " AND B5A_CODINT='" + cCodInt + "' AND B5A_CODEMP='" + cCodEmp + "' AND B5A_MATRIC='" + cMatric + "'"
EndIf
	
cSqlDep += " AND B5A_IDEREG IN ('3','4') AND D_E_L_E_T_ = ' ' " // Apenas registros DTOP e RDTOP

If cBanco == "MSSQL"
	If mv_par20 == 1
		cSqlDep += " GROUP BY B5A_IDEREG, REPLICATE('0',14-LEN(B5A_CPFTIT))+B5A_CPFTIT,B5A_CPFTIT, REPLICATE('0',14-LEN(B5A_CPFDEP))+B5A_CPFDEP,B5A_CPFDEP, B5A_MATVID, B5A_NOMUSR, REPLICATE('0',14-LEN(B5A_CPFRDA))+B5A_CPFRDA, B5A_CPFRDA, B5A_NOMRDA, B5A_DATNAS, B5A_RELDEP "
		cSqlDep += " ORDER BY REPLICATE('0',14-LEN(B5A_CPFDEP))+B5A_CPFDEP, REPLICATE('0',14-LEN(B5A_CPFTIT))+B5A_CPFTIT,B5A_IDEREG,B5A_DATNAS, REPLICATE('0',14-LEN(B5A_CPFRDA))+B5A_CPFRDA"
	Else
		cSqlDep += " GROUP BY B5A_IDEREG, REPLICATE('0',14-LEN(B5A_CPFTIT))+B5A_CPFTIT,B5A_CPFTIT, REPLICATE('0',14-LEN(B5A_CPFDEP))+B5A_CPFDEP,B5A_CPFDEP, B5A_MATVID, B5A_NOMUSR, REPLICATE('0',14-LEN(B5A_CPFRDA))+B5A_CPFRDA, B5A_CPFRDA, B5A_NOMRDA, B5A_CODINT, B5A_CODEMP, B5A_MATRIC, B5A_TIPREG, B5A_DIGITO, B5A_DATNAS, B5A_RELDEP "
		cSqlDep += " ORDER BY REPLICATE('0',14-LEN(B5A_CPFDEP))+B5A_CPFDEP, REPLICATE('0',14-LEN(B5A_CPFTIT))+B5A_CPFTIT, B5A_IDEREG,B5A_DATNAS, REPLICATE('0',14-LEN(B5A_CPFRDA))+B5A_CPFRDA"
	EndIf
ElseIf cBanco == "ORACLE"
	If mv_par20 == 1 .or. lDMEDPJS
		cSqlDep += " GROUP BY B5A_IDEREG, LPAD(TRIM(B5A_CPFTIT),14,'0'),B5A_CPFTIT, LPAD(TRIM(B5A_CPFDEP),14,'0'),B5A_CPFDEP, B5A_MATVID, B5A_NOMUSR, LPAD(TRIM(B5A_CPFRDA),14,'0'), B5A_CPFRDA, B5A_NOMRDA, B5A_DATNAS, B5A_RELDEP "
		cSqlDep += " ORDER BY NVL(LPAD(TRIM(B5A_CPFDEP),14,'0'),' '), NVL(LPAD(TRIM(B5A_CPFTIT),14,'0'),' '),B5A_IDEREG,B5A_DATNAS, LPAD(TRIM(B5A_CPFRDA),14,'0')+B5A_CPFRDA"
	Else
		cSqlDep += " GROUP BY B5A_IDEREG, LPAD(TRIM(B5A_CPFTIT),14,'0'),B5A_CPFTIT, LPAD(TRIM(B5A_CPFDEP),14,'0'),B5A_CPFDEP, B5A_MATVID, B5A_NOMUSR, LPAD(TRIM(B5A_CPFRDA),14,'0'), B5A_CPFRDA, B5A_NOMRDA, B5A_CODINT, B5A_CODEMP, B5A_MATRIC, B5A_TIPREG, B5A_DIGITO, B5A_DATNAS, B5A_RELDEP "
		cSqlDep += " ORDER BY CASE WHEN NVL(LPAD(TRIM(B5A_CPFDEP),14,'0'),' ') = ' ' THEN LPAD('',14,'0') END, CASE WHEN NVL(LPAD(TRIM(B5A_CPFDEP),14,'0'),' ') <> ' ' THEN LPAD(TRIM(B5A_CPFDEP),14,'0') END, B5A_IDEREG,B5A_DATNAS, LPAD(TRIM(B5A_CPFRDA),14,'0')+B5A_CPFRDA"
	EndIf
Else
	If mv_par20 == 1
		cSqlDep += " GROUP BY B5A_IDEREG, B5A_CPFTIT,B5A_CPFTIT, B5A_CPFDEP,B5A_CPFDEP, B5A_MATVID, B5A_NOMUSR, B5A_CPFRDA, B5A_CPFRDA, B5A_NOMRDA, B5A_DATNAS, B5A_RELDEP "
		cSqlDep += " ORDER BY B5A_CPFDEP, B5A_CPFTIT, B5A_IDEREG,B5A_DATNAS, B5A_CPFRDA"
	Else
		cSqlDep += " GROUP BY B5A_IDEREG, B5A_CPFTIT,B5A_CPFTIT, B5A_CPFDEP,B5A_CPFDEP, B5A_MATVID, B5A_NOMUSR, B5A_CPFRDA, B5A_CPFRDA, B5A_NOMRDA, B5A_CODINT, B5A_CODEMP, B5A_MATRIC, B5A_TIPREG, B5A_DIGITO, B5A_DATNAS, B5A_RELDEP "
		cSqlDep += " ORDER BY B5A_CPFDEP, B5A_CPFTIT, B5A_IDEREG,B5A_DATNAS, B5A_CPFRDA"
	EndIf
EndIf

cSqlDep := ChangeQuery(cSqlDep)

If ExistBlock("P260B5AD")
	cSqlDep := ExecBlock("P260B5AD",.F.,.F.,{cSqlDep})
	//PlsLogFil("Consulta alterada pelo ponto de entrada P260B5AD.",cArqLog)
EndIf

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlDep),"TRBD",.F.,.T.)

While !TRBD->(Eof())
	
	lRetPto := .T. 
	lLinTxt := .T.
	lCPFDep := .F.

	If lPM260B5A
		lRetPto := ExecBlock("PM260B5A",.F.,.F.,{TRBD->B5A_IDEREG,TRBD->(B5A_CODINT+B5A_CODEMP+B5A_MATRIC+B5A_TIPREG+B5A_DIGITO),TRBD->B5A_CPFTIT})
	EndIf
	
	If !lRetPto //Registro ignorado pelo ponto de entrada
		//PlsLogFil("Registro ignorado pelo ponto de entrada: "+TRBD->B5A_IDEREG+" - "+TRBD->(B5A_CODINT+B5A_CODEMP+B5A_MATRIC+B5A_TIPREG+B5A_DIGITO)+" - "+TRBD->B5A_CPFTIT,cArqLog)
		cLastDep := &(cDepPos)
		TRBT->(dbSkip())
		Loop
	EndIf
	
	//Enviar registros de dependentes com CPF igual a branco, quando o dependente for menor de idade e o CPF do dependente for igual ao do titular
	If mv_par22 == 2 .And. TRBD->B5A_CPFDEP == TRBD->B5A_CPFTIT .And. Calc_Idade(dDataBase,STOD(TRBD->B5A_DATNAS)) < 18//verificar se existe algum mv_ no protheus que configura maioridade de acordo com a receita federal
		lCPFDep := .T.
		//PlsLogFil("Registro "+TRBD->B5A_IDEREG+" - "+&(cDepPos)+" - "+AllTrim(TRBD->B5A_NOMUSR)+" enviado com CPF vazio, pois CPF do dependente esta igual ao do titular: "+TRBD->B5A_CPFTIT,cArqLog)
	EndIf

	Do Case

		Case TRBD->B5A_IDEREG == '3' // DTOP/BRPPSS
			cLinTxt := DecIdeReg(TRBD->B5A_IDEREG) + "|"
			cLinTxt += Iif(!lCPFDep,AllTrim(TRBD->B5A_CPFDEP),"") + "|"
			cLinTxt += AllTrim(TRBD->B5A_DATNAS) + "|"
			cLinTxt += AllTrim(TRBD->B5A_NOMUSR) + "|"
			If mv_par17 == 2 // Operadora de saude
				cLinTxt += AllTrim(TRBD->B5A_RELDEP) + "|"
			EndIf
			cLinTxt += AllTrim(Replace(Transform(IIf(TRBD->(B5A_VLRCUS+B5A_VLRGPE)<0,0,TRBD->(B5A_VLRCUS+B5A_VLRGPE)),MOEDA),',',''))+"|"
			cLastDep := &(cDepPos)
			
		Case TRBD->B5A_IDEREG == '4' // RDTOP

			//Considera CPF do usuario e mudou o dependente
			If cLastDep != &(cDepPos)
				cLinTxt	:= M260DTOP('3','TRBD',cArqLog)//Vou gerar o registro DTOP
				If !Empty(cLinTxt)
					LimpaCarac(@cLinTxt)
					If !lAutomato
						FWrite(nArqDmed,cLinTxt + CRLF)
					EndIF
				Else
					lLinTxt := .F.
				EndIf
			EndIf

			cLinTxt := DecIdeReg(TRBD->B5A_IDEREG) + "|"
			cLinTxt += AllTrim(TRBD->B5A_CPFRDA) 	+ "|"
			cLinTxt += AllTrim(TRBD->B5A_NOMRDA) 	+ "|"
			cLinTxt += AllTrim(Replace(Transform(IIf(TRBD->B5A_VLRREE<0,0,TRBD->B5A_VLRREE),MOEDA),',','')) + "|"
			cLinTxt += AllTrim(Replace(Transform(IIf(TRBD->B5A_VLRANT<0,0,TRBD->B5A_VLRANT),MOEDA),',','')) + "|"
			cLastDep := &(cDepPos)
			
		OtherWise // Nao classificado
			lLinTxt := .F.
			//PlsLogFil("Registro DMED sem classifica็ใo: "+TRBD->B5A_IDEREG+" - "+&(cDepPos)+" - "+TRBD->B5A_CPFTIT+" - "+TRBD->B5A_NOMUSR,cArqLog)
	EndCase
	
	If lLinTxt // "Tudo" ok vou gravar o registro no arquivo texto
		LimpaCarac(@cLinTxt)
		If !lAutomato
			FWrite(nArqDmed,cLinTxt + CRLF)
		EndIF
	//Else
		//PlsLogFil("Nใo foi possํvel gravar o registro: "+cLinTxt,cArqLog)
	EndIf
	
	TRBD->(dbSkip())
	
EndDo

TRBD->(dbCloseArea())

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM260GerRegบ Autor ณ TOTVS S/A          บ Data ณ  16/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera o registro B5A para um registro que nao tem seu prece  บฑฑ
ฑฑบ          ณdente                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M260GerReg(cCodInt,cCodEmp,cMatric,cTipReg,cDigito,cTipUsu,cCpfTit,cCodCli,cLoja,cTpLanc,cCodNEve,cCodEve,cIdeReg,cAnoCal,cArqLog)
Local cGerTit := ""
Local lGrvTit := .F.
Local cMvPar02 := StrZero(mv_par02,4)

dbSelectArea("SA1")
SA1->(dbSetOrder(1))

If cIdeReg == '3' //DTOP
	If !lCMPCUS	
		cGerTit := "SELECT R_E_C_N_O_ "
		cGerTit += " FROM " + RetSqlName("BM1") + " BM1  WHERE BM1_FILIAL = '" + xFilial("BM1") + "' AND BM1_ANO='" + cMvPar02 + "'"
		cGerTit += " AND BM1_CODINT='" + cCodInt + "' AND BM1_CODEMP='" + cCodEmp + "' AND BM1_MATRIC='" + cMatric + "' AND BM1_TIPREG='" +cTipReg+"' "
		If !Empty(cTpLanc) .and. !Empty(cCodNEve)
			cGerTit += "AND ( ( BM1.BM1_AGMTFU != ' ' AND BM1.BM1_CODTIP NOT IN (" + cTpLanc + ") ) " // MV_PLDM006 Verbas da gestใo de pessoal que nใo deverใo ser consideradas para gera็ใo da DMED
			cGerTit += "OR ( BM1.BM1_AGMTFU = ' '  AND BM1.BM1_CODTIP NOT IN (" + cCodNEve + ") ) ) " // MV_PLDM003 Indica c๓digos de lan็amentos de cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODTIP
		ElseIf !Empty(cTpLanc)
			cGerTit += "AND ( BM1.BM1_AGMTFU != ' ' AND BM1.BM1_CODTIP NOT IN (" + cTpLanc + ") ) " // MV_PLDM006 Verbas da gestใo de pessoal que nใo deverใo ser consideradas para gera็ใo da DMED
		ElseIf !Empty(cCodNEve)
			cGerTit += "AND ( BM1.BM1_AGMTFU = ' '  AND BM1.BM1_CODTIP NOT IN (" + cCodNEve + ") ) " // MV_PLDM003 Indica c๓digos de lan็amentos de cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODTIP
		EndIf
		
		If !Empty(AllTrim(cCodEve))
			cGerTit += "AND BM1.BM1_CODEVE NOT IN (" + cCodEve + ") " //MV_PLDM004 Indica c๓digos de eventos de lan็amentos da cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODEVE
		EndIf		

		cGerTit += " AND D_E_L_E_T_=' '"

	Else
		cGerTit := "SELECT BM1.R_E_C_N_O_, BM1.BM1_CODTIP, "

		cGerTit += " BSP.BSP_CMPCUS BSPCMPCUS " //Vem do left join

		cGerTit += " FROM " + RetSqlName("BM1") + " BM1 "  
		cGerTit += " INNER JOIN "+RetSqlName("BFQ")+" BFQ ON BM1.BM1_CODINT = BFQ.BFQ_CODINT "
		cGerTit += " AND BM1.BM1_CODTIP = BFQ.BFQ_PROPRI || BFQ.BFQ_CODLAN "		

		cGerTit += "LEFT OUTER JOIN "+RetSqlName("BSP")+" BSP ON BM1.BM1_CODEVE = BSP.BSP_CODSER AND BM1.BM1_CODTIP = BSP.BSP_CODLAN AND BM1.BM1_TIPO = BSP.BSP_TIPSER "
		cGerTit += "AND (BSP.BSP_CMPCUS = ' ' OR BSP.BSP_CMPCUS = '1') AND BSP.BSP_FILIAL = ' ' AND BSP.D_E_L_E_T_ = ' ' "

		cGerTit += " WHERE BM1.BM1_FILIAL = '" + xFilial("BM1") + "' AND BM1.BM1_ANO='" + cMvPar02 + "'"
		cGerTit += " AND BM1.BM1_CODINT='" + cCodInt + "' AND BM1.BM1_CODEMP='" + cCodEmp + "' AND BM1.BM1_MATRIC='" + cMatric + "' AND BM1.BM1_TIPREG='" +cTipReg+"'"

		If !Empty(cTpLanc) .and. !Empty(cCodNEve)
			cGerTit += "AND ( ( BM1.BM1_AGMTFU != ' ' AND BM1.BM1_CODTIP NOT IN (" + cTpLanc + ") ) " // MV_PLDM006 Verbas da gestใo de pessoal que nใo deverใo ser consideradas para gera็ใo da DMED
			cGerTit += "OR ( BM1.BM1_AGMTFU = ' '  AND BM1.BM1_CODTIP NOT IN (" + cCodNEve + ") ) ) " // MV_PLDM003 Indica c๓digos de lan็amentos de cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODTIP
		ElseIf !Empty(cTpLanc)
			cGerTit += "AND ( BM1.BM1_AGMTFU != ' ' AND BM1.BM1_CODTIP NOT IN (" + cTpLanc + ") ) " // MV_PLDM006 Verbas da gestใo de pessoal que nใo deverใo ser consideradas para gera็ใo da DMED
		ElseIf !Empty(cCodNEve)
			cGerTit += "AND ( BM1.BM1_AGMTFU = ' '  AND BM1.BM1_CODTIP NOT IN (" + cCodNEve + ") ) " // MV_PLDM003 Indica c๓digos de lan็amentos de cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODTIP
		EndIf
		
		If !Empty(AllTrim(cCodEve))
			cGerTit += "AND BM1.BM1_CODEVE NOT IN (" + cCodEve + ") " //MV_PLDM004 Indica c๓digos de eventos de lan็amentos da cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODEVE
		EndIf		
		cGerTit += " AND (BFQ.BFQ_CMPCUS = ' ' OR BFQ.BFQ_CMPCUS = '1')"
		cGerTit += " AND BFQ.BFQ_FILIAL = '" + xFilial("BFQ") + "' AND BM1.D_E_L_E_T_ = ' ' AND BFQ.D_E_L_E_T_ = ' '"
	EndIf
	cGerTit := ChangeQuery(cGerTit)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cGerTit),"GERT",.F.,.T.)
	
	If GERT->(Eof()) .And. (mv_par20 == 2 .Or. (mv_par20 == 1 .And. SA1->(dbSeek(xFilial("SA1")+cCodCli+cLoja))))
		lGrvTit := .T.
	Else
   		While !GERT->(Eof()) 
   		    If mv_par20 == 2 .Or. (mv_par20 == 1 .And. SA1->(dbSeek(xFilial("SA1")+cCodCli+cLoja))) //.And. (!lCMPCUS .Or. (!EMPTY(GERT->BSPCMPCUS) .AND. GERT->BSPCMPCUS <> "1"))
   		    	lGrvTit := .T.
			Else
				Exit
   		    EndIf
			GERT->(dbSkip())
		EndDo
	EndIf
	GERT->(dbCloseArea())
		
ElseIf cIdeReg == '2' .Or. cIdeReg == '4' //RTOP,RDTOP
		
	cGerTit := "SELECT R_E_C_N_O_ FROM " + RetSqlName("B5A") + " WHERE B5A_FILIAL = '" + xFilial("B5A") + "' "
	If cIdeReg == '2'
		cGerTit += "AND B5A_CODINT='"+cCodInt+"' AND B5A_CODEMP='"+cCodEmp+"' AND B5A_MATRIC='"+cMatric+"' AND B5A_TIPREG='" +cTipReg+"' AND B5A_ANODCL='"+cAnoCal+"' AND B5A_IDEREG='1'"
	Else
		cGerTit += "AND B5A_CODINT='"+cCodInt+"' AND B5A_CODEMP='"+cCodEmp+"' AND B5A_MATRIC='"+cMatric+"' AND B5A_ANODCL='"+cAnoCal+"' AND B5A_IDEREG='3'"
	EndIf
	cGerTit := ChangeQuery(cGerTit)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cGerTit),"GERT",.F.,.T.)
	
	If GERT->(Eof()) .And. (mv_par20 == 2 .Or. (mv_par20 == 1 .And. lCMPCUS .And. SA1->(dbSeek(xFilial("SA1")+cCpfTit))))
		lGrvTit := .T.
	EndIf
	GERT->(dbCloseArea())		
//Else
	//PlsLogFil("Tipo de registro nao esperado para ser criado familia: "+cCodInt+cCodEmp+cMatric+cTipReg+" - Registro: "+cIdeReg,cArqLog)
EndIf

If lGrvTit
	BA1->(dbSetOrder(Iif(cIdeReg == '4',2,1)))
	If !BA1->(dbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+Iif(cIdeReg == '4',cTipReg+cDigito,cCodTit)))
		//PlsLogFil("Nใo foi possํvel criar o registro zerado de titular para a matricula: " + cCodInt+cCodEmp+cMatric,cArqLog)
		Return Nil
	EndIf
	RecLock("B5A",.T.)
	B5A->B5A_FILIAL	:= xFilial("B5A")
	B5A->B5A_CODINT	:= BA1->BA1_CODINT
	B5A->B5A_CODEMP	:= BA1->BA1_CODEMP
	B5A->B5A_MATRIC	:= BA1->BA1_MATRIC
	B5A->B5A_TIPREG	:= BA1->BA1_TIPREG
	B5A->B5A_DIGITO	:= BA1->BA1_DIGITO
	B5A->B5A_NOMUSR	:= Iif(mv_par20 == 2 .Or. mv_par16 == 1,BA1->BA1_NOMUSR,SA1->A1_NOME)//Qdo processo so a folha o nome vem do BA1 tambem
	B5A->B5A_RELDEP := M260GrPa(BA1->BA1_GRAUPA)
	B5A->B5A_DATNAS := BA1->BA1_DATNAS
	If !Empty(cCpfTit)
		B5A->B5A_CPFTIT := cCpfTit
	Else
		B5A->B5A_CPFTIT := BA1->BA1_CPFUSR
	EndIf
	B5A->B5A_CPFDEP := If(GetNewPar("MV_PLCDTIT","T") <> BA1->BA1_TIPUSU ,BA1->BA1_CPFUSR,'')
	B5A->B5A_CODCLI	:= cCodCli
	B5A->B5A_LOJCLI	:= cLoja
	B5A->B5A_VLRFIN	:= 0
	B5A->B5A_VLRGPE	:= 0
	B5A->B5A_VLRCUS	:= 0
	B5A->B5A_VLRREE	:= 0
	B5A->B5A_TPRDA	:= ''
	B5A->B5A_CPFRDA	:= ''
	B5A->B5A_NOMRDA	:= '' 
	If cIdeReg == '2'
		B5A->B5A_IDEREG	:= '1'
	ElseIf cIdeReg == '4'
		B5A->B5A_IDEREG	:= '3'
	ElseIf cIdeReg == '3'
		B5A->B5A_IDEREG	:= '1'
	EndIf
	B5A->B5A_ANODCL	:= cMvPar02
	B5A->B5A_STATUS	:= '1'
	B5A->B5A_MATVID := BA1->BA1_MATVID
	B5A->(msUnLock())
	
	
	If ExistBlock("M260GRV")
		ExecBlock("M260GRV",.F.,.F.,{B5A->(Recno()),.T.})
		//PlsLogFil("M260GerReg - Recno " + AllTrim(Str(B5A->(Recno()))) + " sofreu manuten็ใo pelo ponto de entrada M260GRV.",cArqLog)
	EndIf

	//PlsLogFil("Registro "+DecIdeReg(B5A->B5A_IDEREG)+" criado com valores zerado R_E_C_N_O_: " + AllTrim(Str(B5A->(Recno()))),cArqLog)
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLimpaCaracบAutor  ณ TOTVS S/A          บ Data ณ  26/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetira caracteres invalidos para a linha do arquivo DMED    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LimpaCarac(cLinTxt)

cLinTxt := StrTran(cLinTxt,"-","")
cLinTxt := StrTran(cLinTxt,"`","")
cLinTxt := StrTran(cLinTxt,"'","")
cLinTxt := StrTran(cLinTxt,".","")

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PL260Bx
Procura nas FKs a data e o valor da baixa do titulo.

@author  Lucas Nonato
@version P12
@since   19/12/2017
/*/
//-------------------------------------------------------------------
Function PL260Bx(cPrefix, cNum, cData, cTipo, cTipoP)

	local nRet		:= 0
	local cSql		:= ""
	local cChave 	:= ""
	local cAlias	:= ""
	local lM260Bx   := ExistBlock("M260Bx")
	local aRetBx    := {}

	DEFAULT cData	:= ""
	DEFAULT cTipo	:= ""

	SE1->(dbSetOrder(1)) 	// E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
	SE2->(dbSetOrder(1)) 	// E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA
	if alltrim(cTipo) == alltrim(cTipoP) .and. SE1->(MsSeek(xFilial("SE1") + cPrefix + cNum ))
		cChave	:= SE1->E1_FILIAL + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
		cAlias	:= "SE1"
	elseif SE2->(MsSeek(xFilial("SE2") + cPrefix + cNum ))
		cChave	:= SE2->E2_FILIAL + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
		cAlias	:= "SE2"
	endif

	If lM260Bx .and. !Empty(cAlias)
		aRetBx := ExecBlock("M260Bx",.F.,.F.,{cAlias})		
		nRet   := aRetBx[1]
		cData  := aRetBx[2]

	Else
		if cAlias == "SE1"
			cSql += " SELECT FK1_DATA DATA, FK1_VALOR VALOR"
		else
			cSql += " SELECT FK2_DATA DATA, FK2_VALOR VALOR"
		endif
		cSql += " FROM " + RetSqlName("FK7") + " FK7 "

		if cAlias == "SE1"
			// FK1_FILIAL, FK1_IDDOC
			cSql += " INNER JOIN " + RetSqlName("FK1") + " FK1 "
			cSql += " ON FK1_FILIAL = '" + xFilial("FK1") + "' "
			cSql += " AND FK1_IDDOC = FK7_IDDOC"
			cSql += " AND FK1_MOTBX <> 'LIQ' "
			cSql += " AND SUBSTRING(FK1_DATA, 1, 4) = '" + cValToChar(mv_par02) + "' "
			cSql += " AND FK1.D_E_L_E_T_ = ' ' "
		else
			// FK2_FILIAL, FK2_IDDOC
			cSql += " INNER JOIN " + RetSqlName("FK2") + " FK2 "
			cSql += " ON FK2_FILIAL = '" + xFilial("FK2") + "' "
			cSql += " AND FK2_IDDOC = FK7_IDDOC"
			cSql += " AND FK2_MOTBX <> 'LIQ' "	
			cSql += " AND SUBSTRING(FK2_DATA, 1, 4) = '" + cValToChar(mv_par02) + "' " "
			cSql += " AND FK2.D_E_L_E_T_ = ' ' "
		endif

		// FK7_FILIAL, FK7_ALIAS, FK7_CHAVE
		cSql += " WHERE FK7_FILIAL = '" + xFilial("FK7") + "' "
		cSql += " AND FK7_ALIAS = '" + cAlias + "' "
		cSql += " AND FK7_CHAVE = '" + cChave + "' "
		cSql += " AND FK7.D_E_L_E_T_ = ' ' 
		cSql := ChangeQuery(cSql)	

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbVlr",.F.,.T.)

		While !TrbVlr->(Eof())
			nRet += TrbVlr->VALOR
			cData := SubStr(TrbVlr->DATA,1,4)
			TrbVlr->(dbSkip())	
		EndDo

		TrbVlr->(dbCloseArea())				
	
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MVlrFam
Retorna o valor financeiro por familia.

@author  Roberto Barbosa
@version P12
@since   19/12/2019
/*/
//-------------------------------------------------------------------
Function MVlrFam(cPrefix, cNumTit, cParcel, cTipTit, cTpLanc, cCodNEve, cCODINT, cCODEMP, cMATRIC, cCONEMP, cVERCON, cSUBCON, cVERSUB)
Local cSql := ""
Local nVlrFin := 0

	If !lCMPCUS
		cSql += " SELECT SUM(BM1.BM1_VALOR) VLRBM1 "	
		cSql += "FROM "+RetSqlName("BM1")+" BM1 "						

		cSql += " WHERE BM1.BM1_FILIAL = '"+xFilial("BM1")+"' "
		cSql += " AND BM1.BM1_CODINT = '" + cCODINT +"' "
		cSql += " AND BM1.BM1_CODEMP = '" + cCODEMP +"' "
		cSql += " AND BM1.BM1_CONEMP = '" + cCONEMP +"' "	
		cSql += " AND BM1.BM1_VERCON = '" + cVERCON +"' "
		cSql += " AND BM1.BM1_SUBCON = '" + cSUBCON +"' "
		cSql += " AND BM1.BM1_VERSUB = '" + cVERSUB +"' "
		cSql += " AND BM1.BM1_MATRIC = '" + cMATRIC +"' "	

		cSql += " AND BM1.BM1_PREFIX = '"+cPrefix+"' "
		cSql += " AND BM1.BM1_NUMTIT = '"+cNumTit+"' "
		cSql += " AND BM1.BM1_PARCEL = '"+cParcel+"' "
		cSql += " AND BM1.BM1_TIPTIT = '"+cTipTit+"' "

		If !Empty(cTpLanc) .and. !Empty(cCodNEve)
			cSql += "AND ( ( BM1.BM1_AGMTFU != ' ' AND BM1.BM1_CODTIP NOT IN (" + cTpLanc + ") ) " // MV_PLDM006 Verbas da gestใo de pessoal que nใo deverใo ser consideradas para gera็ใo da DMED
			cSql += "OR ( BM1.BM1_AGMTFU = ' '  AND BM1.BM1_CODTIP NOT IN (" + cCodNEve + ") ) ) " // MV_PLDM003 Indica c๓digos de lan็amentos de cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODTIP
		ElseIf !Empty(cTpLanc)
			cSql += "AND ( BM1.BM1_AGMTFU != ' ' AND BM1.BM1_CODTIP NOT IN (" + cTpLanc + ") ) " // MV_PLDM006 Verbas da gestใo de pessoal que nใo deverใo ser consideradas para gera็ใo da DMED
		ElseIf !Empty(cCodNEve)
			cSql += "AND ( BM1.BM1_AGMTFU = ' '  AND BM1.BM1_CODTIP NOT IN (" + cCodNEve + ") ) " // MV_PLDM003 Indica c๓digos de lan็amentos de cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODTIP
		EndIf

		If !Empty(AllTrim(cCodEve))
			cSql += "AND BM1.BM1_CODEVE NOT IN (" + cCodEve + ") " //MV_PLDM004 Indica c๓digos de eventos de lan็amentos da cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODEVE
		EndIf						
		cSql += " AND BM1.D_E_L_E_T_ = ' ' "

	Else

		cSql := " SELECT SUM(BM1.BM1_VALOR) VLRBM1 "
		
		cSql += " FROM "+RetSqlName("BM1")+" BM1 "
		cSql += " INNER JOIN "+RetSqlName("BFQ")+" BFQ ON BM1.BM1_CODINT = BFQ.BFQ_CODINT "
		cSql += " AND BM1.BM1_CODTIP = BFQ.BFQ_PROPRI || BFQ.BFQ_CODLAN "			

		cSql += " LEFT OUTER JOIN "+RetSqlName("BSP")+" BSP ON BM1.BM1_CODEVE = BSP.BSP_CODSER AND BM1.BM1_CODTIP = BSP.BSP_CODLAN AND BM1.BM1_TIPO = BSP.BSP_TIPSER "
		cSql += " AND (BSP.BSP_CMPCUS = ' ' OR BSP.BSP_CMPCUS = '1') AND BSP.BSP_FILIAL = ' ' AND BSP.D_E_L_E_T_ = ' ' "

		cSql += " WHERE BM1.BM1_FILIAL = '"+xFilial("BM1")+"' "
		cSql += " AND BM1.BM1_CODINT = '" + cCODINT +"' "
		cSql += " AND BM1.BM1_CODEMP = '" + cCODEMP +"' "
		cSql += " AND BM1.BM1_CONEMP = '" + cCONEMP +"' "	
		cSql += " AND BM1.BM1_VERCON = '" + cVERCON +"' "
		cSql += " AND BM1.BM1_SUBCON = '" + cSUBCON +"' "
		cSql += " AND BM1.BM1_VERSUB = '" + cVERSUB +"' "
		cSql += " AND BM1.BM1_MATRIC = '" + cMATRIC +"' "
		
		cSql += " AND BM1.BM1_PREFIX = '"+cPrefix+"' "
		cSql += " AND BM1.BM1_NUMTIT = '"+cNumTit+"' "
		cSql += " AND BM1.BM1_PARCEL = '"+cParcel+"' "
		cSql += " AND BM1.BM1_TIPTIT = '"+cTipTit+"' "

		If !Empty(cTpLanc) .and. !Empty(cCodNEve)
			cSql += "AND ( ( BM1.BM1_AGMTFU != ' ' AND BM1.BM1_CODTIP NOT IN (" + cTpLanc + ") ) " // MV_PLDM006 Verbas da gestใo de pessoal que nใo deverใo ser consideradas para gera็ใo da DMED
			cSql += "OR ( BM1.BM1_AGMTFU = ' '  AND BM1.BM1_CODTIP NOT IN (" + cCodNEve + ") ) ) " // MV_PLDM003 Indica c๓digos de lan็amentos de cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODTIP
		ElseIf !Empty(cTpLanc)
			cSql += "AND ( BM1.BM1_AGMTFU != ' ' AND BM1.BM1_CODTIP NOT IN (" + cTpLanc + ") ) " // MV_PLDM006 Verbas da gestใo de pessoal que nใo deverใo ser consideradas para gera็ใo da DMED
		ElseIf !Empty(cCodNEve)
			cSql += "AND ( BM1.BM1_AGMTFU = ' '  AND BM1.BM1_CODTIP NOT IN (" + cCodNEve + ") ) " // MV_PLDM003 Indica c๓digos de lan็amentos de cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODTIP
		EndIf

		If !Empty(AllTrim(cCodEve))
			cSql += "AND BM1.BM1_CODEVE NOT IN (" + cCodEve + ") " //MV_PLDM004 Indica c๓digos de eventos de lan็amentos da cobran็a que nใo serใo considerados na composi็ใo do custo BM1_CODEVE
		EndIf

		cSql += "AND (BFQ.BFQ_CMPCUS = ' ' OR BFQ.BFQ_CMPCUS = '1') "				
		cSql += "AND BFQ.BFQ_FILIAL = '" + xFilial("BFQ") + "' AND BM1.D_E_L_E_T_ = ' ' AND BFQ.D_E_L_E_T_ = ' '"

	EndIf

	cSql := ChangeQuery(cSql) 
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBVFIN",.F.,.T.)

	IF !TRBVFIN->(Eof())
		nVlrFin += TRBVFIN->VLRBM1
	EndIf

	TRBVFIN->(dbCloseArea())

Return nVlrFin