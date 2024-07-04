#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOTVS.CH"
#INCLUDE "LOJA861.CH"

Static aDataExp := {}           //Obtem a qtde de vez que uma data exportacao e gravada pelos metodos
Static aLocais  := {}           //Armazens do e-Commerce localizados no MF6

Static lECLJAUTO   := .F.      //Execauto para eCommerce


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LOJA861  º Autor ³ Antonio C Ferreira º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Processamento de job para envio de Dados via WebService.   º±±
±±º          ³ Exportacao.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³lECJob - Se esta executando via Job ou pelo Protheus.       º±±
±±º          ³cECEmpresa - Codigo da Empresa para a preparacao do ambienteº±±
±±º          ³cECFilial - Codigo da Filial para a preparacao do ambiente  º±±
±±º          ³cECTarefa - Grupo de tarefa de execucao dos webservices.    º±±
±±º          ³cECJob - Nome do Job que esta executando a rotina.          º±±
±±º          ³cECIntervalo - Intervalo para a execucao da rotina.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function LOJA861(lECJob, cECEmpresa, cECFilial, cECTarefa,;
                 cECJob, cECIntervalo)

Local lOk        := .T.      //Retorna falso caso ocorra algum erro na execucao. 
Local cArq       := ""       //Nome do arquivo que ira gerar no diretorio system do Protheus para o controle do tempo de execucao           
Local nA         := 0        //Contador para processar as empresas e filiais passadas pelos parametros do JOB.
Local nEmpresas  := 0        //Calcula a quantidade de empresas passadas pelos parametros do JOB.
Local cXEmpresa  := ""       //Codigo da empresa ou Grupo de Empresa a ser processado.
Local cXFilial   := ""       //Codigo da Filial a ser processado.
Local aEmps      := {}      //Empresas que serao processadas pelo Job. 

Local lDepurar   := (Type("cFilAnt") == "U")   //Se esta sendo depurado pelo DevStudio ou esta executando pelo Protheus.

DEFAULT lECJob     	:= "F"
DEFAULT cECEmpresa 	:= "99"
DEFAULT cECFilial  	:= "01"
DEFAULT cECTarefa  	:= "A"
DEFAULT cECJob     	:= "JOB01"
DEFAULT cECIntervalo:= "02:00"   
                
cArq   := cECJob+".tmp"

lECJob := (lECJob == "T")  //Passa para valor logico.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o intervalo venceu para poder executar o job.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  lECJob .And. !( LJ861Exec(cArq, cECJob, cECIntervalo) )
	    Return .T.  //Cancela a execucao antes de preparar o ambiente.
	EndIf    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a quantidade de empresas/filiais que devem ser processadas.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( LJ861Emps("LOJA861", cECEmpresa, cECFilial, @nEmpresas, @aEmps) )
	    Return .F.  //Cancela a execucao antes de preparar o ambiente.
	EndIf    

LjGrvLog( "", "LOJA861: " + STR0001 + " " + STR0008 + " Job: " + cECJob + " - " + Time() + "[VERSION  21/01/2014 15:51] ")    //"Iniciando processamento de Exportacao!"##"Gerando a intermediaria!"

Begin Sequence
	
	For nA := 1 to nEmpresas
		cXEmpresa := aEmps[nA][1]
		cXFilial  := aEmps[nA][2]    

		If  lECJob .Or. lDepurar
			RpcClearEnv()   //Caso tenha algum ambiente em aberto, fechar!
			LjGrvLog( "", "LOJA861: " + STR0045 + cXEmpresa + "/" + cXFilial + " - " + Time())  //"Iniciando Empresa/Filial: "
			RpcSetType( 3 )
			If  !( RpcSetEnv( cXEmpresa, cXFilial,,,"LOJ" ) )
				LjGrvLog( "", "LOJA861: " + STR0046)   //"Parametros de Empresa e Filial incorretos! Cancelando Execução!"
				lOk := .F.
				Break
			EndIf 	
		ElseIf (nA > 1)
			Exit         //Caso nao seja Job devera sair para nao processar mais de uma vez na mesma empresa e filial.
		EndIf	
		
		aDataExp := LJ861DTExp() //Obtem a qtde de vez que uma data exportacao e gravada pelos metodos.
		aLocais := {} //Reinicia os locais de estoque
	
		DbSelectArea("MF1")
		DbSetOrder(1)  //MF1_FILIAL+MF1_ECFLAG+MF1_ECTARF+MF1_ECSEQ.
		
		DbSeek(xFilial("MF1")+"A"+cECTarefa)
		
		While !( MF1->( Eof() ) ) .And. MF1->(MF1_FILIAL+MF1_ECFLAG+MF1_ECTARF == xFilial("MF1")+"A"+cECTarefa)
		  
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Interrupcao pelo parametro MV_LJECOMX                                     ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  (SuperGetMV("MV_LJECOMX",,"1") == "0")  //0=Nao executar / 1=Executar
		        LjGrvLog( "", "LOJA861: " + STR0003 + " Job: " + cECJob)  //"Execução interrompida pelo parâmetro MV_LJECOMX!"
		        Break
		    EndIf    
	
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Processa os ativos                                                        ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			LJ861Inter(cECJob,,  cECEmpresa, cECFilial)  //Processa com o MF1 posicionado, podendo ser utilizado tambem por outras rotinas.
		
			MF1->( DbSkip() )
		End	
	Next nA
	
	
End Sequence


If  lECJob .Or. lDepurar
	RpcClearEnv()
          
	If  lECJob .And. lOk
		MemoWrit(cArq,DtoS(Date())+','+Time())
	EndIf	
EndIf

LjGrvLog( "", "LOJA861: " + STR0047 + " - " + Time())  //"Finalizando o processo!"

Return lOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ861Exec º Autor ³ Antonio C Ferreira º Data ³  05/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se o intervalo do Job venceu para executa-lo.     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cArq - Nome do arquivo criado no system.                    º±±
±±º          ³cECJob - Nome do Job que esta executando a rotina.          º±±
±±º          ³cECIntervalo - Intervalo para a execucao da rotina.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                  

Static Function LJ861Exec(cArq, cECJob, cECIntervalo)

Local lOk      := .T.     //Retorna .T. caso seja o momento de executar a rotina conforme a ultima execucao e o parametro cECIntervalo
Local cTempAnt := ""      //Obtem o a data e hora do ultimo processamento do arquivo gravado na pasta system do Protheus.
Local dDataAtu := Date()  //Data atual
Local cHoraAtu := Time()  //Hora atual             
Local dData    := CtoD(Space(8))   //Data da ultima execucao
Local cHora    := ""      //Hora da ultima execucao
Local nRs      := 0       //Resultado fracionado da subtracao da data e hora atual com a data e hora da ultima execucao
Local cMinuto  := ""      //Resulta do nRS onde a fracao eh multiplicada 60 para converter a fracao em minutos
Local aTemp    := {}     //Obtem a data e hora da ultima execucao no vetor.

Default cArq         := ""
Default cECJob       := ""
Default cECIntervalo := ""

set date format "dd/mm/yy"
               
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Arquivo da ultima execucao do job ja existe.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  File(cArq)      
    cTempAnt := MemoRead(cArq) //Le os Dados do Tempo do Final da ultima execucao deste job no arquivo .tmp
    aTemp    := &("{'" + StrTran(cTempAnt,",","','") + "'}")
EndIf     
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula os minutos passados desde a ultima execucao.                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  !( Empty(cTempAnt) )
    dData := StoD(aTemp[1])
    cHora := aTemp[2]
                
    nRs := SubtHoras(dData, cHora, dDataAtu, cHoraAtu)
    cMinuto := StrTran(StrZero(int(nRs) + (((nRs - int(nRs)) * 60)/100),5,2),'.',':')
                
    If  (dData >= Date()) .And. (cECIntervalo > cMinuto)
        lOk := .F.
    EndIf
EndIf
	
Return lOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ861Emps º Autor ³ Antonio C Ferreira º Data ³  31/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica as empresas e filiais que deverao ser processadas.º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cECEmpresa - Grupo de Empresas que deverao ser processadas. º±±
±±º          ³cECFilial - Filiais que deverao ser processados.            º±±
±±º          ³nEmpresa - Calcula a quantidade de empresas a ser processadaº±±
±±º          ³aEmps - Retorna as empresas e filiais em matriz.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                  

Function LJ861Emps(cPrograma, cECEmpresa, cECFilial, nEmpresa, aEmps)

Local lOk          := .T.     //Retorna .F. caso os parametros de empresa e filial não estejam configurados corretamente.
           
Local nA           := 0                                                 //Contador generico para o FOR
Local nB           := 0                                                 //Contador generico para o FOR
Local nX           := 0                                                 //Variavel auxiliar
Local aXEmps       := &( "{'" + StrTran(cECEmpresa,",","','") + "'}")  //Monta o vetor conforme o parametro passado. Exemplo: "01,03" => {'01','03'}
Local nTEmps       := Len(aXEmps)                                       //Tamanho de aXEmps
Local aXFils       := &( "{'" + StrTran(cECFilial,",","','") + "'}")   //Monta o vetor conforme o parametro passado. Exemplo: "0010003,0030003" => {'0010003','0030003'}
Local nTFils       := Len(aXFils)                                       //Tamanho de aXFils
Local cLocalizacao := ""                                                //Endereco configurado para o Webservice do grupo de empresa e filial atual.
Local nHandle      := 0                                                 //Variavel de manipulacao do arquivo de configuracao intecomm.ini
Local cConfiguracao:= ""                                                //Dados de configuracao do arquivo intecomm.ini.
Local aConfiguracao:= {}                                                //Vetor com os dados do arquivo intecomm.ini.
Local nTConf       := 0                                                 //Tamanho de aConfiguracao

Default cPrograma  := "LOJA861"
Default cECEmpresa := cEmpAnt
Default cECFilial  := cFilAnt
Default nEmpresa   := 0
Default aEmps      := {}

aEmps := {}

Begin Sequence

	If  (nTEmps <= 0) .Or. (nTEmps <> nTFils)
		LjGrvLog( "", cPrograma + ":LJ861Emps: " + STR0046)   //"Parametros de Empresa e Filial incorretos! Cancelando Execução!"
		lOk := .F.
		Break
	EndIf
	
	For nA := 1 to nTEmps
	    aadd(aEmps, {Alltrim(aXEmps[nA]), Alltrim(aXFils[nA]), ""})
	Next nA

    nEmpresa := Len(aEmps)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Verifica se os WebServiceLocations estao configurados no INTECOMM.ini     ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	cArquivo := StrTran(GetSrvProfString("Startpath","") + "\INTECOMM.ini","\\","\")  //Arquivo de configuracao com os dados dos enderecos WS dos e-commerces.
   
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Caso o arquivo INTECOMM.ini não exista ira criar um modelo e sair com erro³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
 	If  !( File(cArquivo) )
 		nHandle := FCREATE(cArquivo)
		If  (nHandle <= -1)
       		LjGrvLog( "", cPrograma + ":LJ861Emps: " + STR0048)   //"Problema para criação do arquivo de configuracao intecomm.ini! Cancelando Execução!"
			lOk := .F.
			Break
		EndIf
       
		FWRITE(nHandle, "WEBSERVICELOCATION<" + STR0049 + "><" + STR0050 + "> = <URL - " + STR0051 + ">") //"GRUPO DE EMPRESA"##"FILIAL"##"ENDERECO WEBSERVICE DO E-COMMERCE"
		FCLOSE(nHandle)

   		LjGrvLog( "", cPrograma + ":LJ861Emps: " + STR0052)  //"Arquivo de configuração intecomm.ini não configurado! Cancelando Execução!"
		lOk := .F.
		Break
	EndIf
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Abre o arquivo INTECOMM.ini e passa as configuracoes para um vetor.       ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	nHandle := FOPEN(cArquivo, 0)
	If  (FERROR() <> 0) .And. (nHandle <= -1)
   		LjGrvLog( "", cPrograma + ":LJ861Emps: " + STR0053 + STR(FERROR())) //"Erro de abertura do arquivo de configuração intecomm.ini! Código: "
		lOk := .F.
		Break
	EndIf

    cConfiguracao := FREADSTR(nHandle, 65000)
    
    If  Empty(cConfiguracao)
   		LjGrvLog( "", cPrograma + ":LJ861Emps: " + STR0054)  //"Dados do arquivo de configuração intecomm.ini não encontrados! Cancelando Execução!"
		lOk := .F.
		Break
    EndIf   
    
    FCLOSE(nHandle)
 
    aConfiguracao := &("{'" + StrTran(cConfiguracao,CRLF,"','") + "'}")
    
    nTConf := Len(aConfiguracao)
    
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Obtem as configuracoes para cada grupo de empresa/filial que ira processar.  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	For nA := 1 to nTEmps
	    cLocalizacao := "WEBSERVICELOCATION" + Alltrim(aEmps[nA][1]) + Alltrim(aEmps[nA][2])
	    
	    For nB := 1 to nTConf
	    	aConfiguracao[nB] := Alltrim(aConfiguracao[nB])
	    	
	    	If  Empty(aConfiguracao[nB]) .Or. (Left(aConfiguracao[nB],1) == ";")  //Caso seja linha comentada no INI entao ignora.
	    	    Loop
	    	EndIf    
	    	
	        If  (cLocalizacao == Left(aConfiguracao[nB],Len(cLocalizacao))) //Caso confira a configuracao grava em aEmps.
	            nX := At("=", aConfiguracao[nB])

	            cEndereco := Alltrim(SubStr(aConfiguracao[nB], nX+1))  //Grava o endereco do WS para este grupo de empresa/filial.
	            
			    If  (nX <= 0) .Or. Empty(cEndereco)
			   		LjGrvLog( "", cPrograma + ":LJ861Emps: " + STR0055)  //"Problema na configuração do arquivo intecomm.ini! Cancelando Execução!"
					lOk := .F.
					Break
			    EndIf   
			    
		    	If  (Right(cEndereco,1) != "/")
					cEndereco += "/"
				EndIf

	            aEmps[nA][3] := cEndereco
	            
	            Exit
	        EndIf
	    Next nB
    
	    If  Empty( aEmps[nA][3] )
			LjGrvLog( "", cPrograma + ":LJ861Emps: " + STR0056)  //"WebServiceLocation não configurado para todas as empresas no arquivo INTECOMM.ini! Cancelando Execução!"
			lOk := .F.
			Break
		EndIf
	Next nA
    
End Sequence

Return lOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ861DTExpº Autor ³ Antonio C Ferreira º Data ³  04/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Conta quantos metodos gravam na mesma data de exportacao.  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function LJ861DTExp()
Local aArea		:= GetArea()
Local aAreaMF1	:= MF1->( GetArea() )
Local nPos     := 0   //Posicao encontrada dentro da matriz aDtExp
Local aDtExp   := {}  //Matriz com os campos de exportacao.

DbSelectArea("MF1")
DbSetOrder(1)  //MF1_FILIAL+MF1_ECFLAG+MF1_ECTARF+MF1_ECSEQ
	
DbSeek(xFilial("MF1")+"A")

While !( Eof() ) .And. (MF1_FILIAL+MF1_ECFLAG == xFilial("MF1")+"A")
	  
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Localiza e soma a vez                                                     ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos := Ascan(aDtExp, {|x| x[1] == Alltrim(MF1_ECDTEX) })
	
	If  (nPos <= 0)
	    aadd(aDtExp, {Alltrim(MF1_ECDTEX), 1})
	Else 
		++aDtExp[nPos][2]
	EndIf    
 
	DbSkip()
End

RestArea(aAreaMF1)	
RestArea(aArea)

Return aDtExp


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ861Interº Autor ³ Antonio C Ferreira º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gravacao da Tabela Intermediaria dos dados a serem         º±±
±±º          ³ exportados via webservices. MF1 posicionado.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cECJob - Nome do Job que esta executando a rotina.         º±±
±±º          ³ aParams - Parametros dentro de um vetor que ira atender as º±±
±±º          ³ as condicoes da Query na funcao LJ861Query().              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function LJ861Inter(cECJob, aParams, cECEmpresa, cECFilial)
   
Local nA                            //Contador do comando For
Local nPos                          //Posicao encontrada na matriz aDataExp
Local aAreaSav	     := GetArea()  //Salva a area atual
Local cAliasQry	     := "temp"     //alias para criacao do arquivo temporario
Local aAlias         := &('{"' + StrTran(Alltrim(MF1->MF1_ECALIA),'|','","') + '"}') //Passa os alias do campo para um vetor. Exemplo: SA2|SA5 => {"SA2","SA5"}
Local cAlias	     := aAlias[1]  //alias principal da exportacao
Local xAlias	     := ""         //Alias que sera travado para gravar os campos ???_ECDTEX e ???_ECSEQ.
Local xPref          := ""         //Obtem o prefixo do campo para localizar o alias para travamento.
Local xPos           := ""         //Posiciona o underline (_) para descobrir o prefixo do campo. Exemplo ACV_ECDTEX = xPref = ACV.
Local cSequencia     := ""         //Codigo novo sequencial para a gravacao da tabela intermediaria
Local cQuery 	     := ""         //Query para obter os dados para a geracao da tabela intermediaria.
Local cChave         := ""         //Chave utilizado para verificar se a informacao a ser exportada ja gerou a tabela intermediaria
Local lAchou         := .F.        //Verifica se ja existe uma Intermediaria em aberto, caso contrario cria uma

Local cMensagem      := ""         //Caso gere alguma mensagem de erro sera gravado log de erro e o processo sera interrompido.
Local lIntermediaria := .F.        //Se esta executando baseado na tabela intermediaria ou nao. (para saldo em estoque nao gera intermediaria)

Local cWebService    := Alltrim(MF1->MF1_ECWS)   //WebService utilizado para a exportacao dos dados
Local cOrdem         := Alltrim(MF1->MF1_ECORD)  //Metodo utilizado para a exportacao dos dados
Local cMetodo        := ""         //Definido antes da gravacao da MF3
Local cCpoData       := Alltrim(MF1->MF1_ECDTEX) //Campo para gravacao de que a intermediaria foi exportada.
Local cCpoSeq		 := StrTran(cCpoData,"DTEX","SEQ") //Troca exemplo: L1_ECDTEX fica L1_ECSEQ para gravacao posterior.

Local bCondDtExp     := &("{|| " + AllTrim(MF1->MF1_ECCNDX) + " }")  //Se ira grava a data exportacao neste processo ou em um proximo processo.

Local bCondValida    := &("{|x| " + AllTrim(MF1->MF1_ECFVAL) + " }") //Condicao para valida se sera gerado a intermediaria para este registro. Caso negativo ira gerar log de erro.

Local bOldError      := ErrorBlock( {|x| LJ861VErro(x, @cMensagem) } ) // controla o erro de execucao, por exemplo, no codeblock de parametros (bParametro).
Local aFilEC		   := {} //Filiais e-commerce
Local aFilAlias	   := {} //Filias do Alias
Local aEmpEC		   := {} //Empresas do e-commerce
Local cGrpFilEC	   := FWCompany() //Grupo de empresas
Local cUnFilEC		   := FWUnitBusiness()//Gestao de empresas
Local cEmpEC		   := FWGrpCompany() //Empresas
Local nC 			   := 1 //Contator 1
Local nC2			   := 0 //Contador 2
Local nTamFil		   := 0 //Tamanho da Filial
                            
DEFAULT cECJob   := ""
DEFAULT aParams  := &( "{" + Alltrim(MF1->MF1_ECPARM) + "}" ) //Cria o vetor a partir do campo MF1_PARAMS que deve conter os valores separados por virgula. Ex.: "","zzzzz",0,99999,"","zzzzz"
DEFAULT cECFilial := ""
DEFAULT cECEmpresa := ""
                                                                                                     
Begin Sequence

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Interrupcao pelo parametro MV_LJECOMX                                     ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  (SuperGetMV("MV_LJECOMX",,"1") == "0")  //0=Nao executar / 1=Executar
        LjGrvLog( "", "LOJA861: LJ861Inter: " + STR0003 + " Job: " + cECJob)   //"Execução interrompida pelo parâmetro MV_LJECOMX!"

        If  Empty(cECJob)
        	Aviso(STR0002, STR0003, {"Ok"})  //"Mensagem do Usuário"##"Execução interrompida pelo parâmetro MV_LJECOMX!"
        EndIf
        
        Break
    EndIf    

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Obtem a query condicionada para o filtro dos dados.                       ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( LJ861Query(cWebService, cOrdem, cMetodo, cECJob,;
	                  aAlias, aParams, @cQuery, @cMensagem) )
		Break
	EndIf	

	cQuery := ChangeQuery( cQuery )   

	
	If  (Select(cAliasQry) > 0)
		(cAliasQry)->(dbCloseArea())
	EndIf
	
	DbSelectArea("MF3")
	DbSetOrder(1) //MF3_FILIAL+MF3_ECSEQ
	
	DbSelectArea(cAlias)
	DbSetOrder(Val(MF1->MF1_ECIND))
	aFilAlias:= {} //zera a variavel
	aFilEC := {}
	aEmpEC := {}
	
	If !Empty(cECFilial)
		aFilEC := &( "{'" + StrTran(cECFilial,",","','") + "'}")  
		aEmpEC := &( "{'" + StrTran(cECEmpresa,",","','") + "'}")  
		
		For nC := 1 to Len(aEmpEC)
			If RTrim(aEmpEC[nC]) <> RTrim(cEmpEC)
				aDel(aFilEC, nC)
				nC2++
			EndIf	
		Next
		
		nC--
		If nC2 > 0
			aSize(aFilEC, nC-nC2)
		EndIf
		
		If Len(aFilEC) > 1 //Mais de uma filial no EC
			aFilAlias := Lj861FilAli(cAlias, aFilEC, cUnFilEC, cGrpFilEC	 )
		Else
			aFilAlias := {xFilial("MF3")}
		EndIf
	Else
		aFilAlias := {xFilial("MF3")}
	EndIf
	
                            

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Obtem os dados executando a query.                                        ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbUseArea(.T., "TOPCONN", TcGenQry(Nil, Nil, cQuery), cAliasQry, .F., .T.)
	
	For nA := 1 to Len(aAlias)  
        If  ((cAliasQry)->(FieldPos(aAlias[nA]+"RECNO")) > 0)
            TcSetField( cAliasQry, aAlias[nA]+"RECNO", "N", 10, 0 )
        EndIf     
    Next nA               
                
    SET DELETED OFF 
                
    While (cAliasQry)->( !Eof() )
                          
        xAlias := ""         
        xPos   := At("_", cCpoData)
      	xPref  := Left(cCpoData, xPos-1)  // Obtem o prefixo. Exemplo ACV_ECDTEX = xPref = ACV.

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Posiciona cada registro dos Alias conforme o retorno da Query.            ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        For nA := 1 to Len(aAlias)  
            If  ((cAliasQry)->(FieldPos(aAlias[nA]+"RECNO")) > 0)
                (aAlias[nA])->( dbGoto( (cAliasQry)->(FieldGet(FieldPos(aAlias[nA]+"RECNO")) ) ))
            EndIf
                      
	     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	     //³ Define o alias para travar pelo prefixo do campo gravado no MF1_ECDTEX.   ³
	     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If  !( Empty(xPref) ) .And. (xPref == Right(aAlias[nA], Len(xPref)))  //Exemplo: SA1 & xPref = A1 entao S[A1] = A1 OU ACV & xPref = ACV entao [ACV] = ACV.
                xAlias := aAlias[nA]
            EndIf    
            
        Next nA               
        
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Com o alias para travar definido, trava para gravacao dos campos de controle³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If  Empty(xAlias)
        	xAlias := aAlias[1]
        EndIf
                               
		If  !( Empty(xAlias) ) .And. (xAlias)->(!Eof()) .And. !( (xAlias)->(SoftLock(xAlias)) )
			(cAliasQry)->( dbSkip() ) //Se nao consegue travar passa para o proximo, este sera processado posteriormente.
			Loop
		EndIf
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Pre-validacao dos dados para exportacao do e-commerce.                    ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If  !( Empty(MF1->MF1_ECFVAL) ) .And. !( Eval(bCondValida, @cMensagem) )  
        	SET DELETED ON
			LJ861LogErro(lIntermediaria, cWebService, cOrdem, cAlias+StrZero((cAlias)->(Recno()),7),;
			             cMetodo, cECJob, cMensagem) 
			SET DELETED OFF
			cMensagem := ""
			(cAliasQry)->( dbSkip() )
			Loop
        EndIf    
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Define o metodo, Salvar ou Excluir.                                       ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  (cAlias)->( Deleted() ) .And. !( Empty(MF1->MF1_ECMET2) )
			cMetodo := Alltrim(MF1->MF1_ECMET2)
		Else	
		    cMetodo := Alltrim(MF1->MF1_ECMET1)
		EndIf    	

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Caso nao necessite do intermediario, ira enviar os dados diretamente.     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  (MF1->MF1_ECINTR == "2")
			If  !( LJ861Envio(lIntermediaria, cWebService, cMetodo, cECJob,;
			                  cAlias, cOrdem, @cMensagem) )
			    SET DELETED ON
			    LJ861LogErro(lIntermediaria, cWebService, cOrdem, cAlias+StrZero((cAlias)->(Recno()),7),;
			                 cMetodo, cECJob, cMensagem)
			    SET DELETED OFF
			    cMensagem := ""
			EndIf
			
			(cAliasQry)->( dbSkip() )
			Loop
        EndIf
        
		SET DELETED ON
		MF3->( DbSetOrder(3) ) //MF3_FILIAL+MF3_ECWS+MF3_ECORD+MF3_ECALIA+MF3_ECIND+MF3_ECVCHV
		
		cChave := (cAlias)->( &(IndexKey()) )
		
		nTamFil := Len(aFilAlias)
		
		For nC := 1 to nTamFil
		
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica se ja existe uma Intermediaria em aberto, caso contrario cria uma³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    	lAchou := .F.
			MF3->( DbSetOrder(3) ) //MF3_FILIAL+MF3_ECWS+MF3_ECORD+MF3_ECALIA+MF3_ECIND+MF3_ECVCHV
	     	MF3->( DbSeek(aFilAlias[nC]+MF1->(MF1_ECWS+MF1_ECORD)+cAlias+MF1->MF1_ECIND+RTrim(cChave)) )
	     	
	     	While MF3->( !( Eof() ) .AND. (MF3_FILIAL+MF3_ECWS+MF3_ECORD+MF3_ECALIA+MF3_ECIND+RTrim(MF3_ECVCHV)) == (aFilAlias[nC]+MF1->(MF1_ECWS+MF1_ECORD)+cAlias+MF1->MF1_ECIND+Rtrim(cChave)) )
	     	    If  (MF3->MF3_ECFLAG $ "AE") //Se estiver Em Aberto ou Com Erro...
	     	        LjGrvLog( "", "...")
	     	        LjGrvLog( "", "LOJA861: LJ861Inter: " + STR0004 + xFilial("MF3")+MF1->(MF1_ECWS+MF1_ECORD)+cAlias+MF1->MF1_ECIND+Rtrim(cChave))  //"Encontrado Intermediária em aberto ou com erro! Chave: "
	     	        LjGrvLog( "", "...") 
	     	        cSequencia  := MF3->MF3_ECSEQ	     	        
	     	    	lAchou := .T.
	     	    	Exit
	     	    EndIf
	     	    
	     	    MF3->( DbSkip() )
	     	End    	
	     	
			If  (!lAchou) 
			
		     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		     //³ Obtendo o numero sequencial do intermediario.                             ³
		     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cSequencia := GetSx8Num("MF3","MF3_ECSEQ")
				ConfirmSX8()
				
				MF3->( DbSetOrder(1) ) //MF3_FILIAL+MF3_ECSEQ
				
				If  MF3->( DbSeek(aFilAlias[nC]+cSequencia) )
				    cMensagem := "LOJA861: LJ861Inter: " + STR0005		//"Problema na Numeracao Sequencial do arquivo MF3! Favor verificar!"
					LjGrvLog( "", cMensagem)
					Break
				EndIf
				
		     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		     //³ Gravando a Tabela Intermediaria para registrar a pendencia.               ³
		     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MF3->( RecLock("MF3", .T.) )
				
	            MF3->MF3_FILIAL := aFilAlias[nC]
				MF3->MF3_ECFLAG := "A"  //A-Em Aberto / E-Erro / X-Finalizado/ Z - ignorado
				MF3->MF3_ECSEQ  := cSequencia
				MF3->MF3_ECWS   := cWebService
				MF3->MF3_ECORD  := cOrdem
				MF3->MF3_ECMETO := cMetodo
				MF3->MF3_ECALIA := cAlias
				MF3->MF3_ECIND  := MF1->MF1_ECIND
				MF3->MF3_ECCCHV := (cAlias)->( IndexKey() )
				MF3->MF3_ECVCHV := cChave
				MF3->MF3_ECDATA := Date()
				MF3->MF3_ECHORA := Time()
				
				MF3->( MsUnLock() )
				
			EndIf	

		Next
		
		SET DELETED OFF
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Gravando na Tabela origem a data e a sequencia de exportacao.             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  !( Empty(xAlias) )
   	        nPos := Ascan(aDataExp, {|x| x[1] == Alltrim(MF1->MF1_ECDTEX) })
                       
            If  !( Empty(cCpoData) )
		     	If  Empty(MF1->MF1_ECCNDX) .Or. (nPos <= 0) .Or. (aDataExp[nPos][2] <= 1) .Or. Eval(bCondDtExp)
					(xAlias)->( FieldPut(FieldPos(cCpoData), DtoS(date())) ) //Grava Data de Exportacao se nenhum outro metodo nao for processar tambem para gravar esta data
				EndIf	
				(xAlias)->( FieldPut(FieldPos(cCpoSeq), cSequencia) )
			EndIf
			
			(xAlias)->( MSUnLock() )		
		EndIf	
		
		(cAliasQry)->( dbSkip() ) 
		

	
	End
	SET DELETED ON              
End Sequence

If  !( Empty(cMensagem) )
	LJ861LogErro(lIntermediaria, cWebService, cOrdem, cAlias+StrZero((cAlias)->(Recno()),7),;
	             cMetodo, cECJob, cMensagem)
EndIf	

If  (Select(cAliasQry) > 0)
	(cAliasQry)->(dbCloseArea())
Endif

RestArea( aAreaSav )
ErrorBlock( bOldError )   //Volta ao tratamento de erro padrao.
           
Return Empty(cMensagem)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ861Query º Autor ³ Antonio C Ferreira º Data ³  28/12/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Obtem a query que ira filtrar e processar os dados para    º±±
±±º          ³ exportacao.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cWebService  - WebService para a exportacao                º±±
±±º          ³ cOrdem  - Codigo da Ordem de execucao dos metodos          º±±
±±º          ³ cMetodo  - Metodo para a exportacao                        º±±
±±º          ³ cECJob  - Nome do job que esta executando a rotina         º±±
±±º          ³ aAlias  - Lista de alias que serao verificados dentro da   º±±
±±º          ³ Query. Exemplo: SA2 => __SA2 => SA2010                     º±±
±±º          ³ aParams - Parametros dentro de um vetor que ira atender as º±±
±±º          ³ as condicoes da Query.                                     º±±
±±º          ³ cQuery - Query que sera tratada e executada.               º±±
±±º          ³ cMensagem - Mensagem de erro de execucao do processo.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ861Query(cWebService, cOrdem, cMetodo, cECJob,;
                           aAlias, aParams, cQuery, cMensagem)

Local cXAlias                      //Variavel auxiliar para o alias a ser substituido na Query
Local cXFilial                     //Variavel auxiliar para a filial a ser substituido na Query
Local cXParam                      //Variavel auxiliar para os parametros que serao substiruidos na Query

Local aArea	     := GetArea()     //Gravacao da area atual
Local nA     	 := 0             //Contador para o comando For
Local nLenaAlias := Len(aAlias)   //Tamanho de aAlias
Local nLenaParams:= Len(aParams)  //Tamanho de aParams 
                                                    
//Vetor com os valores de parametros ou valores variados a serem substituidos na query
Local aMV        := {}            //Vetor para os parametros a serem substituidos com aspas
Local nLenaMV    := Len(aMV)      //Tamanho de aMV
Local aXMV       := {AllTrim(SuperGetMV("MV_LJECOMT",,SuperGetMV("MV_TABPAD")))}  //Vetor para os parametros a serem substituidos sem aspas
Local nLenaXMV   := Len(aXMV)     //Tamanho de aXMV

Default cWebService:= ""
Default cOrdem     := ""
Default cMetodo    := ""
Default cECJob     := ""
Default aAlias     := {}
Default aParams    := {}
Default cQuery     := ""
Default cMensagem  := ""

// Ilustrando a funcionalidade
// O Campo MF1_QUERY tera a seguinte Query:
//
//  SELECT SA2.R_E_C_N_O_ SA2RECNO 
//   FROM __SA2 SA2                       ==> Ira substituir __SA2 por RetSqlName('SA2') que eh igual a SA2010 (para empresa 01, por exemplo).
//   INNER JOIN __SA5 SA5
//   ON  SA5.A5_FILIAL  = SA2.A2_FILIAL 
//   AND SA5.A5_FORNECE = SA2.A2_COD 
//   AND SA5.A5_LOJA    = SA2.A2_LOJA  
//   WHERE SA2.A2_FILIAL = __FILIALSA2    ==> Ira substituir __FILIALSA2 por xFilial('SA2')
//     AND SA2.A2_ECSTATU <> ' ' 
//     AND SA2.A2_ECDTEX = ' ' 
//     AND SA2.A2_COD >= __PARAM01        ==> Ira substituir __PARAM01 por '      ' (ou um parametro definido pelo usuario passado por outra rotina)
//     AND SA2.A2_COD <= __PARAM02        ==> Ira substituir __PARAM02 por 'zzzzzz' (ou um parametro definido pelo usuario passado por outra rotina)
//   Group by SA2.R_E_C_N_O_ 

Begin Sequence

	cQuery 	 := Alltrim(MF1->MF1_ECQRY)  //Query para obtenção dos dados

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ MacroSubstitui as palavras chaves na query por valores atuais do sistema. ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nA := 1 to nLenaAlias
	    
	    cXAlias  := "__" + aAlias[nA]
	    cXFilial := "__FILIAL" + aAlias[nA]
	    
	    cQuery := StrTran(cQuery, cXAlias , RetSqlName(aAlias[nA]))           //Substitue os alias da query da empresa e filial atual. Exemplo: __SA2 => SA2010
	    cQuery := StrTran(cQuery, cXFilial, ValToSQL(xFilial(aAlias[nA])))    //Substitue as filiais da query pela filial atual. Exemplo: __FILIALSA2 => "01" ou "  "
	    
	Next nA

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ MacroSubstitui os parametros de filtro conforme os valores no vetor.      ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nA := 1 to nLenaParams
	    
	    cXParam  := "__PARAM" + StrZero(nA,2)  //Parametro a ser substituido na Query. Ex.: __PARAM01, __PARAM02
	                                                                                                                                           
	    //Na query posso ter a seguinte condicao: ... Where ((A1_COD = __PARAM01) AND (A1_DATA = __PARAM02)) AND (A1_VALOR >= __PARAM03)
	    cQuery := StrTran(cQuery, cXParam , ValToSQL(aParams[nA]))  //Substitue valores dos parametros. Exemplo: __PARAM01 => "'000121'" / __PARAM02 => "'20130120'" / __PARAM03 => '120'
	    
	Next nA

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ MacroSubstitui os valores de parametros na query.                         ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nA := 1 to nLenaMV
	    
	    cXParam  := "__MV" + StrZero(nA,2)  //Parametro a ser substituido na Query. Ex.: __MV01, __MV02
	                                                                                                                                           
	    //Na query posso ter a seguinte condicao: ... Where ((A1_COD = __MV01) AND (A1_DATA = __MV02)) AND (A1_VALOR >= __MV03)
	    cQuery := StrTran(cQuery, cXParam , ValToSQL(aMV[nA]))  //Substitue valores dos parametros. Exemplo: __MV01 => "'000121'" / __MV02 => "'20130120'" / __MV03 => '120'
	    
	Next nA

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ MacroSubstitui os valores de parametros na query sem aspas.               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nA := 1 to nLenaXMV
	    
	    cXParam  := "__XMV" + StrZero(nA,2)  //Parametro a ser substituido na Query. Ex.: __XMV01, __XMV02
	                                                                                                                                           
	    //Na query posso ter a seguinte condicao: ... Where ((A1_COD = __XMV01) AND (A1_DATA = __XMV02)) AND (A1_VALOR >= __XMV03)
	    cQuery := StrTran(cQuery, cXParam , aXMV[nA])  //Substitue valores dos parametros. Exemplo: __XMV01 => '000121' / __XMV02 => '20130120' / __XMV03 => 120
	    
	Next nA
 //ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	If  !( Empty(cMensagem) ) .Or. Empty(cQuery)
		cMensagem := STR0006 + CRLF + cMensagem     //" Problema configuração da Query: "
		cQuery := ""
		Break
	EndIf
	
	If  (At("__", cQuery) > 0)
	    cMensagem := STR0007    //" Problema de MacroSubstituicao na Query! "
		Break
	EndIf
	
End Sequence

RestArea(aArea)
        	
Return Empty(cMensagem)

		
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ861ECommº Autor ³ Antonio C Ferreira º Data ³  03/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Leitura da Tabela Intermediaria dos dados a serem          º±±
±±º          ³ exportados via webservices.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³lECJob - Se esta executando via Job ou pelo Protheus.       º±±
±±º          ³cECEmpresa - Codigo da Empresa para a preparacao do ambienteº±±
±±º          ³cECFilial - Codigo da Filial para a preparacao do ambiente  º±±
±±º          ³cECTarefa - Grupo de tarefa de execucao dos webservices.    º±±
±±º          ³cECJob - Nome do Job que esta executando a rotina.          º±±
±±º          ³cECIntervalo - Intervalo para a execucao da rotina.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function LJ861EComm(lECJob, cECEmpresa, cECFilial, cECTarefa,;
                    cECJob, cECIntervalo)

Local lOk        := .T.      //Retorna falso caso ocorra algum erro na execucao. 
Local cArq       := ""       //Nome do arquivo que ira gerar no diretorio system do Protheus para o controle do tempo de execucao           
Local aExecutado := {}       //Se a intermediaria ja foi executada neste processo atual ou nao. Se sim sera ignorada e passara para o proximo.
Local nA         := 0        //Contador para processar as empresas e filiais passadas pelos parametros do JOB.
Local nEmpresas  := 0        //Calcula a quantidade de empresas passadas pelos parametros do JOB.
Local cXEmpresa  := ""       //Codigo da empresa ou Grupo de Empresa a ser processado.
Local cXFilial   := ""       //Codigo da Filial a ser processado.
Local aEmps      := {}      //Empresas que serao processadas pelo Job. 

Local lDepurar   := (Type("cFilAnt") == "U")   //Se esta sendo depurado pelo DevStudio ou esta executando pelo Protheus.

DEFAULT lECJob     	:= "F"
DEFAULT cECEmpresa 	:= "99"
DEFAULT cECFilial  	:= "01"
DEFAULT cECTarefa  	:= "A"
DEFAULT cECJob     	:= "JOB01"
DEFAULT cECIntervalo:= "02:00"
                
cArq   := cECJob+".tmp"

lECJob := (lECJob == "T")  //Passa para valor logico.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o intervalo venceu para poder executar o job.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  lECJob .And. !( LJ861Exec(cArq, cECJob, cECIntervalo) )
	    Return .T.  //Cancela a execucao antes de preparar o ambiente.
	EndIf    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a quantidade de empresas/filiais que devem ser processadas.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( LJ861Emps("LOJA861", cECEmpresa, cECFilial, @nEmpresas, @aEmps) )
	    Return .F.  //Cancela a execucao antes de preparar o ambiente.
	EndIf    

LjGrvLog( "", "LOJA861: LJ861EComm: " + STR0001 + " " + STR0009 + " Job: " + cECJob + " - " + Time() + "[ VERSION  13/01/2014 16:19] ")   //"Iniciando processamento de Exportacao!"##"Lendo a intermediária e enviando os dados!"

//Solicitação GDP 29/07/2014
FWLSEnable(3118)

Begin Sequence
	
	For nA := 1 to nEmpresas
	
		cXEmpresa := aEmps[nA][1]
		cXFilial  := aEmps[nA][2]
	
		If  lECJob .Or. lDepurar
			RpcClearEnv()   //Caso tenha algum ambiente em aberto, fechar!
			
			LjGrvLog( "", "LOJA861: LJ861EComm: " + STR0045 + cXEmpresa + "/" + cXFilial + " - " + Time())  //"Iniciando Empresa/Filial: "
			RpcSetType( 3 )
			If  !( RpcSetEnv( cXEmpresa, cXFilial,,,"LOJ" ) )
				LjGrvLog( "", "LOJA861: LJ861EComm: " + STR0046)  //"Parametros de Empresa e Filial incorretos! Cancelando Execução!"
				lOk := .F.
				Break
			EndIf 	
		ElseIf (nA > 1)
			Exit         //Caso nao seja Job devera sair para nao processar mais de uma vez na mesma empresa e filial.
		EndIf	
		
		DbSelectArea("MF3")
		DbSetOrder(2) //MF3_FILIAL+MF3_ECFLAG+MF3_ECSEQ
		
		DbSeek(xFilial("MF3")+"A")
		
		While !( Eof() ) .And. (MF3_FILIAL+MF3_ECFLAG == xFilial("MF3")+"A")
		
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Interrupcao pelo parametro MV_LJECOMX                                     ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  (SuperGetMV("MV_LJECOMX",,"1") == "0")  //0=Nao executar / 1=Executar
		        LjGrvLog( "", "LOJA861: LJ861EComm: " + STR0003 + " Job: " + cECJob)   //"Execução interrompida pelo parâmetro MV_LJECOMX!"
		        Break
		    EndIf    
	
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Verifica se ja passou pelo registro nesta vez de execucao do Job.         ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If  (Ascan(aExecutado, MF3_ECSEQ) > 0)
		    	DbSkip()
		    	Loop
		    EndIf	
	
	        aadd(aExecutado, MF3_ECSEQ) //Grava aqui o registro mesmo que esteja sendo usado por outro processo/job.
	        
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Registro pode estar travado por outro Job, neste caso passa para o proximo³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  !( SoftLock('MF3') )
			    DbSkip()
			    Loop
			EndIf
			
			LJ861Exp(cECJob)
			
			MSUnLockAll()
			
			DbSeek(xFilial("MF3")+"A")
			
		End		
	
	Next nA
	
End Sequence	
		
If  lECJob .Or. lDepurar
	RpcClearEnv()
          
	If  lECJob .And. lOk
		MemoWrit(cArq,DtoS(Date())+','+Time())
	EndIf	
EndIf

LjGrvLog( "", "LOJA861: LJ861EComm: " + STR0047 + " - " + Time())   //"Finalizando o processo!"

Return lOk
		
		    
		
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LJ861Exp º Autor ³ Antonio C Ferreira º Data ³  03/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Leitura da Tabela Intermediaria dos dados a serem          º±±
±±º          ³ exportados via webservices. MF3 Posicionado.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cECJob - Nome do Job que esta executando a rotina.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function LJ861Exp(cECJob)

Local aArea          := GetArea()       //Salva a area atual
                                         
Local cAlias         := ""              //Alias principal do processo da exportacao.
Local nIndice        := 0               //Indice do alias principal
Local cChave         := ""              //Chave do alias principal
Local cValor         := ""              //Valor da chave do alias principal
Local lAchou         := ""              //Se encontrou o registro no alias principal corresponde ao que gerou a intermediaria
Local cWebService    := ""              //WebService a ser executado para a exportacao dos dados.
Local cOrdem         := ""              //Ordem do processo gravado na intermediaria
Local cMetodo        := ""              //Metodo do WebService a ser executado para a exportacao dos dados.
Local lIntermediaria := .T.  		    //Esta executando baseado na tabela intermediaria. (Saldo de Estoque nao utiliza intermediaria).

Local cMensagem      := ""              //Mensagem de erro de processamento que ira gerar o log de erro.
Local bOldError      := ErrorBlock( {|x| LJ861VErro(x, @cMensagem) } ) // controla o erro de execucao, por exemplo, no codeblock de parametros (bParametro).
Local cCpoSeq	     := ""              //Campo que ira verificar o codigo Sequencial da intermediaria no alias principal.

DEFAULT cECJob    := ""

DbSelectArea("MF1")
DbSetOrder(2) //MF1_FILIAL+MF1_ECFLAG+MF1_ECWS+MF1_ECORD

DbSelectArea("MF3")
		
SET DELETED OFF 
	
Begin Sequence

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Caso nao possa executar, interrompe mesmo que nao seja via job.           ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  (SuperGetMV("MV_LJECOMX",,"1") == "0")  //0=Nao executar / 1=Executar
        LjGrvLog( "", "LJ861Exp: " + STR0003 + cECJob)   //"Execução interrompida pelo parâmetro MV_LJECOMX!"
        
        If  Empty(cECJob)
        	Aviso(STR0002, STR0003, {"Ok"})   //"Execução interrompida pelo parâmetro MV_LJECOMX!"
        EndIf
        
        Break
    EndIf    

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Tenta travar o registro para utilizacao.                                  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( SoftLock('MF3') )
	    Break
	EndIf

    If  !( MF1->( DbSeek(xFilial("MF1")+"A"+MF3->(MF3_ECWS+MF3_ECORD)) ) )
       	cMensagem := "LJ861Exp: " + STR0010 + MF3->MF3_ECWS + STR0011 + MF3->MF3_ECMETO  //"Configuração do WebService não encontrada no MF1! WebService: "##" Método: "
	    Break
    EndIf
    
    cCpoSeq	:= StrTran(Alltrim(MF1->MF1_ECDTEX),"DTEX","SEQ") //Troca exemplo: L1_ECDTEX fica L1_ECSEQ para gravacao posterior.
        
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Dados do WebService e Metodo.                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	cWebService := Alltrim(MF3_ECWS)
 	cOrdem      := Alltrim(MF3_ECORD)
 	cMetodo     := Alltrim(MF3_ECMETO)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Abre o alias e posiciona no registro origem.                              ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAlias  := Alltrim(MF3_ECALIAS)
	nIndice := Val(MF3_ECIND)
	cChave  := Alltrim(MF3_ECCCHV)
	cValor  := MF3_ECVCHV   //Sem Alltrim() tem os espaços da filial no inicio
		
	DbSelectArea(cAlias)
	DbSetOrder(nIndice)
	DbSeek(cValor)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Verifica se esta no registro correto pois se excluir e incluir novamente  ³
 //³ podera utilizar a mesma chave ao registro incluido no cadastro.           ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lAchou := .F.
	
	While !( Eof() ) .And. (PadR(&cChave.,Len(cValor)) == cValor)
	    If  Empty(cCpoSeq) .Or. (FieldPos(cCpoSeq) <= 0) .Or. Empty(FieldGet(FieldPos(cCpoSeq))) .Or. (FieldGet(FieldPos(cCpoSeq))==MF3->MF3_ECSEQ)
	    	lAchou := .T.
	        Exit
	    EndIf
	    
	    DbSkip()
	End        

	DbSelectArea("MF3")
		
	If  !( lAchou ) .And. !( (cAlias)->(DbSeek(cValor)) )
       	cMensagem := "LJ861Exp: " + STR0012 + cWebService + STR0013 + cOrdem + STR0011 + cMetodo + STR0014 + cAlias + STR0015 + Alltrim(MF3_ECIND) + STR0016 + cChave //"Origem dos dados não encontrado! WebService: "##" Ordem: "##" Método: "##" Alias: "##" Indice: "##" Chave: "
	    Break
	EndIf
	
	If  !( LJ861Envio(lIntermediaria, cWebService, cMetodo, cECJob,;
	                  cAlias, cOrdem, @cMensagem) )
	    Break
	EndIf    

	DbSelectArea("MF3")
	MsUnLock()

End Sequence

If  !( Empty(cMensagem) )
	LJ861LogErro(lIntermediaria, cWebService, cOrdem, cAlias+StrZero((cAlias)->(Recno()),7),;
	             cMetodo, cECJob, cMensagem)
EndIf

RestArea(aArea)
ErrorBlock( bOldError )   //Volta ao tratamento de erro padrao.
        	
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ861LogErroº Autor ³ Antonio C Ferreira º Data ³  04/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gravacao do log de erro da exportacao.                       º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lIntermediaria - Se utiliza a tabela intermediaria.          º±±
±±º          ³ cWebService  - WebService para a exportacao                  º±±
±±º          ³ cOrdem  - Codigo da Ordem de execucao dos metodos            º±±
±±º          ³ cChave  - Chave do alias principal do processo.              º±±
±±º          ³ cMetodo  - Metodo para a exportacao                          º±±
±±º          ³ cECJob  - Nome do job que esta executando a rotina           º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ861LogErro(lIntermediaria, cWebService, cOrdem, cChave,;
                             cMetodo, cECJob, cMensagem)

Local aArea      := GetArea()    //Salva a area atual
Local cSequencia := ""           //Codigo Sequencial do registro de log de erro.
Local lRegNovo   := .T.          //Se cria registro novo ou trava um existente.
Local cFilMF4		:= xFilial("MF4") //Filial MF4

Default lIntermediaria := .F.
Default cWebService    := ""
Default cOrdem         := ""
Default cChave         := ""
Default cMetodo        := ""
Default cECJob         := ""
Default cMensagem      := ""

Begin Sequence
	
	If lIntermediaria
		cFilMF4 := MF3->MF3_FILIAL
	Else
		cFilMF4 := xFilial("MF4")
	EndIf
        	       
	If  lIntermediaria .And. !( Empty(MF3->MF3_ECERRO) )
		DbSetOrder(3) //MF4_FILIAL+MF4_ECSEQ
	    If  MF4->( DbSeek(cFilMF4+MF3->MF3_ECERRO) .AND. (MF4_ECFLAG != "Z") )
	    	cSequencia := MF4->MF4_ECSEQ
	    	lRegNovo   := .F.
	    EndIf
	    
    Else
		DbSelectArea("MF4")
		DbSetOrder(2) //MF4_FILIAL+MF4_ECFLAG+MF4_ECWS+MF4_ECORD+MF4_ECCHAV
		If  DbSeek(cFilMF4+"A"+PadR(cWebService,Len(MF4_ECWS))+cOrdem+cChave)
				LjGrvLog( "", "...")
				LjGrvLog( "", "LOJA861: LJ861LogErro: " + STR0017)     //"Log encontrado e não gerado novamente na MF4..."
		
				cSequencia := MF4->MF4_ECSEQ
		    	lRegNovo   := .F.
				LjGrvLog( "", cMensagem)
				LjGrvLog( "", "...") 				 
		EndIf
	    	    

	EndIf

	LjGrvLog( "", "...")
	LjGrvLog( "", cMensagem)
	LjGrvLog( "", "...")

	If  Empty(cSequencia)	    
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Obtendo o numero sequencial do log de erro.                               ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSequencia := GetSx8Num("MF4","MF4_ECSEQ")
		ConfirmSX8()
	EndIf	
		
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Grava o registro do log de erro.                                          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MF4")      
	
	RecLock("MF4", lRegNovo)
	
	MF4->MF4_ECFLAG := 'A' //ABERTO
	MF4->MF4_ECSEQ  := cSequencia
	MF4->MF4_ECWS   := cWebService
	MF4->MF4_ECORD  := cOrdem
	MF4->MF4_ECCHAV := cChave
	MF4->MF4_ECMETO := cMetodo            
	If  lIntermediaria
		MF4->MF4_ECREFE := MF3->MF3_ECSEQ
	EndIf	
	MF4->MF4_ECMENS := cMensagem  
	MF4->MF4_ECJOB  := cECJob
	MF4->MF4_ECDATA := Date()
	MF4->MF4_ECHORA := Time()
	If lRegNovo
		MF4->MF4_FILIAL := cFilMF4
	EndIf
	
	MsUnLock()

	If  lIntermediaria
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Grava os campos de controle da intermediaria.                             ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("MF3")   
		
		MF3->MF3_ECFLAG := 'E' //ERRO
		MF3->MF3_ECRET  := cMensagem  
		
		MF3->MF3_ECJOB  := cECJob
		MF3->MF3_ECDTE  := Date()
		MF3->MF3_ECHRE  := Time()
		
		MF3->MF3_ECERRO := cSequencia
		
		MsUnLock()
	EndIf	

End Sequence

RestArea(aArea)
        	
Return .T. 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ861Envioº Autor ³ Antonio C Ferreira º Data ³  03/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Envio dos dados ao eCommerce com ou sem MF3-Intermediaria  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lIntermediaria - Se utiliza a tabela intermediaria.        º±±
±±º          ³ cWebService  - WebService para a exportacao                º±±
±±º          ³ cMetodo  - Metodo para a exportacao                        º±±
±±º          ³ cECJob  - Nome do job que esta executando a rotina         º±±
±±º          ³ cAlias  - Chave do alias principal do processo.            º±±
±±º          ³ cOrdem  - Codigo da Ordem de execucao dos metodos          º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ861Envio(lIntermediaria, cWebService, cMetodo, cECJob,;
                           cAlias, cOrdem, cMensagem)

Local oObj		  := nil  //Objeto que ira processar o webservice/metodo de exportacao.
Local lExcluir    := .T.  //Indica que se trata de uma exportacao de exclusao.
Local lNaoExcluir := .F.  //Indica que se trata de uma exportacao de uma inclusao ou alteracao.

Local aEntradas   := {}   //Propriedades de entrada do Metodo WS

Local aEmps       := {}   //Empresas que serao processadas pelo Job. 
Local cPrograma   := ""   //Nome do programa que contem o WS

Default lIntermediaria := .F.
Default cWebService    := ""
Default cMetodo        := ""
Default cECJob         := ""
Default cAlias         := ""
Default cOrdem         := ""
Default cMensagem      := ""      

If SuperGetMV("TT_WSDLXML",,.F.)  
	WSDLSaveXML(.T.)
EndIf

Begin Sequence

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cria o objeto para utilizacao do webservice e verifica as entradas.	   ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj := &("WS" + cWebService + "():NEW()")  //Cria o objeto do WebService
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Configura a localizacao do WS conforme configurado no intecomm.ini            ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPrograma    := cWebService + ".asmx"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem o endereco do WS no arquivo de configuracao intecomm.ini            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( LJ861Emps("LOJA861", cEmpAnt, cFilAnt,, @aEmps) )
	    cMensagem := "LOJA861: LJ861Envio: " + STR0055   //"Problema na configuração do arquivo intecomm.ini!"
	    Break
	EndIf    

    oObj:_Url := aEmps[1][3]+cPrograma //Configura o endereco do WS para o grupo de empresa/filial.
	
       
    If  !( LJ861Entradas(@oObj, cWebService, cMetodo, cECJob,;
                         @aEntradas, @cMensagem) )
    	Break
    EndIf

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Executa o metodo do webservice de gravacao ou exclusao.	               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  (cAlias)->( !Deleted() ) .Or. Empty(MF1->MF1_ECMET2)

		If  !( LJ861Metodo(lNaoExcluir, lIntermediaria, cWebService, cOrdem,;
		                   MF1->MF1_ECMET1, cECJob, MF1->MF1_ECCND1, MF1->MF1_ECRET1,;
		                   @oObj, @aEntradas, @cMensagem) )
		    Break
		EndIf    

	ElseIf  !( Empty(MF1->MF1_ECMET2) )

		If  !( LJ861Metodo(lExcluir, lIntermediaria, cWebService, cOrdem,;
		                    MF1->MF1_ECMET2, cECJob, MF1->MF1_ECCND2,;
		                    MF1->MF1_ECRET2, @oObj, @aEntradas,;
		                    @cMensagem) )
		    Break
		EndIf    

    EndIf

End Sequence

Return Empty(cMensagem)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ861Entradas º Autor ³ Antonio C Ferreira º Data ³  07/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Prepara o objeto do webservice com os dados de entrada.        º±±
±±º          ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oObj - Objeto que ira processar o webservice/metodo            º±±
±±º          ³ cWebService  - WebService para a exportacao                    º±±
±±º          ³ cMetodo  - Metodo para a exportacao                            º±±
±±º          ³ cECJob  - Nome do job que esta executando a rotina             º±±
±±º          ³ aEntradas - Parametros de entrada do webservice/metodo         º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ861Entradas(oObj, cWebService, cMetodo, cECJob,;
                              aEntradas, cMensagem)

Local aArea          := GetArea()  //Area atual
Local nA             := 0          //contador do comando For 
Local nLenAEntradas  := 0          //Tamanho da matriz aEntradas
Local cChave         := ""         //Chave para obter o de/para na MF2 para montar os parametros de entrada do webservice/metodo em aEntradas.
Local cTag			 := ""         //Tag do webservice/metodo de exportacao.
Local cECVAL         := ""         //Obtem a expressao do Protheus para processar o valor da Tag do webservice/metodo
Local cXECVAL        := ""        //variavel auxiliar para processar o valor da Tag do webservice/metodo
Local cCondicao      := ""        //Condicao que permitira processar o registro que ira gerar o parametro de entrada do webservice/metodo em aEntradas.
Local bCondicao      := nil       //CodBlock da Condicao que permitira processar o registro que ira gerar o parametro de entrada do webservice/metodo em aEntradas.

Local cMascara    := GetMv("MV_MASCGRD")          //Mascara da Grade de Produtos
Local nGrdTamRaiz := Val(Substr(cMascara,1,2))   //Tamanho do codigo raiz da grade.
Local nGrdTamLin  := Val(Substr(cMascara,4,2))   //Tamanho do codigo da Linha da Grade
Local nGrdTamCol  := Val(Substr(cMascara,7,2))   //Tamanho do codigo da Coluna da Grade
Local nGrdTamLC   := (nGrdTamLin + nGrdTamCol)   //Tamanho somado do codigo da Linha e da Coluna da Grade
Local cZerosLin   := Replicate("0",nGrdTamLin)   //Codigo zerado no tamanho da linha da grade para ser utilizado em condicao na MF2.
Local cZerosCol   := Replicate("0",nGrdTamCol)   //Codigo zerado no tamanho da coluna da grade para ser utilizado em condicao na MF2.

Local nPos           := Ascan(aEntradas, {|x| (x[1] == Alltrim(cWebService)) .And. (x[2] == Alltrim(cMetodo))})

Local lIntermediaria := .T.  //Esta executando baseado na tabela intermediaria

Default oObj           := nil
Default cWebService    := ""
Default cMetodo        := ""
Default cECJob         := ""
Default aEntradas      := {}
Default cMensagem      := ""

Begin Sequence

	If  (nPos <= 0)
	
		DbSelectArea("MF2")   
		DbSetOrder(1) //MF2_FILIAL+MF2_ECWS+MF2_ECMETO+MF2_ECFLAG+MF2_ECSEQ
				
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Parametros de entrada do webservice em Vetor para processar em cada       ³
	 //³ registro posteriormente.                                                  ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cChave := xFilial("MF2")+PadR(cWebService,Len(MF2_ECWS))+PadR(cMetodo,Len(MF2_ECMETO))+"A"
		DbSeek(cChave)
		
		While !( Eof() ) .And. (MF2_FILIAL+MF2_ECWS+MF2_ECMETO+MF2_ECFLAG == cChave)
		    
		    If MF2->(Deleted())
		    	MF2->(DbSkip(1))
		    	Loop
		    EndIf
		    cCondicao := AllTrim(MF2_ECCOND)
		    
		    If  !( Empty(cCondicao) ) .And. (("zGRDTAM" $ cCondicao) .Or. ("zZEROS" $ cCondicao)) 
		        //Macro substiruicao das pseudo variaveis dentro das condicoes na MF2
			    cCondicao := StrTran(cCondicao, "zGRDTAMRAIZ", ValToSQL(nGrdTamRaiz))  //Troca pelo tamanho do codigo raiz da grade de produto.
				cCondicao := StrTran(cCondicao, "zGRDTAMLC"  , ValToSQL(nGrdTamLC))    //Troca pelo tamanho da soma do codigo de linha e coluna da grade de produto.
				cCondicao := StrTran(cCondicao, "zGRDTAMLIN" , ValToSQL(nGrdTamLin))   //Troca pelo tamanho do codigo de linha da grade de produto.
				cCondicao := StrTran(cCondicao, "zGRDTAMCOL" , ValToSQL(nGrdTamCol))   //Troca pelo tamanho do codigo da coluna da grade de produto.
	
				cCondicao := StrTran(cCondicao, "zZEROSLIN"  , cZerosLin)  //Troca pelos zeros, pois linha com, por exemplo, 3 digitos tera o codigo "000" para nao ser enviado para o e-commerce.
				cCondicao := StrTran(cCondicao, "zZEROSCOL"  , cZerosCol)  //Troca pelos zeros, pois coluna com, por exemplo, 3 digitos tera o codigo "000" para nao ser enviado para o e-commerce.
			EndIf
			
			bCondicao := &( "{|| " + cCondicao + "}" )
		
			If  (MF2_ECFLAG == "A")/*A-Ativo/I-Inativo*/ .And. (Empty(cCondicao).Or.(Eval(bCondicao)))
                                                                                                                                                                                
                //Macro substiruicao das pseudo variaveis dentro das formulas na MF2
                cECVAL   := AllTrim(MF2_ECVAL)
			    
		        If  !( Empty(cECVAL) ) .And. (("zGRDTAM" $ cECVAL) .Or. ("zFilial" $ cECVAL)) 
	                cECVAL   := StrTran(cECVAL, "zFilial"    , "LJ861Filial()")        //Troca zFilial pela funcao para poder executar dentro do alias para obter a filial correta.
	                cECVAL   := StrTran(cECVAL, "zGRDTAMRAIZ", ValToSQL(nGrdTamRaiz))  //Troca pelo tamanho do codigo raiz da grade de produto.
	                cECVAL   := StrTran(cECVAL, "zGRDTAMLC"  , ValToSQL(nGrdTamLC))    //Troca pelo tamanho da soma do codigo de linha e coluna da grade de produto.
	                cECVAL   := StrTran(cECVAL, "zGRDTAMLIN" , ValToSQL(nGrdTamLin))   //Troca pelo tamanho do codigo de linha da grade de produto.
				    cECVAL   := StrTran(cECVAL, "zGRDTAMCOL" , ValToSQL(nGrdTamCol))   //Troca pelo tamanho do codigo da coluna da grade de produto.
			    EndIf
			    
			    If  ('[@@]' $ MF2_ECTAG)
			        cXECVAL := cECVAL
			    Else    
				    cXECVAL   := If(Upper(Alltrim(cECVAL))=="NIL", cECVAL, &(cECVAL))
				    cXECVAL   := If((cXECVAL == NIL) .Or. (ValType(cXECVAL) == "C") .And. (cXECVAL == 'NIL'), "NIL", ValToSQL(cXECVAL))
				    cXECVAL   := If(ValType(cXECVAL) == "C" .And. (cXECVAL == 'NIL'), "NIL", cXECVAL)
				    cXECVAL   := StrTran(StrTran(cXECVAL,CHR(13),""),CHR(10),"")
			    EndIf
			    
                If  ("[@@]" $ MF2_ECTAG)  //Propriedade Matriz do Objeto com mais de uma linha, sera passado por referencia para uma funcao preenche-la.
				    cTag     := StrTran(AllTrim(MF2_ECTAG),"[@@]","")
				    aadd( aEntradas, {Alltrim(cWebService), Alltrim(cMetodo), &("{|| " + StrTran(cXECVAL, "@@", "@oObj:"+cTag) + "}")} )
				ElseIf  ("[xx]" $ MF2_ECTAG)  //Propriedade vetor com um unico valor, ira receber um valor pela funcao aadd().
				    cTag     := StrTran(AllTrim(MF2_ECTAG),"[xx]","")
				    aadd( aEntradas, {Alltrim(cWebService), Alltrim(cMetodo), &("{|| aadd(oObj:" + cTag + ", " + cXECVAL + ")}")} )
				Else                                                                    
				    aadd( aEntradas, {Alltrim(cWebService), Alltrim(cMetodo), &("{|| oObj:" + AllTrim(MF2_ECTAG) + " := " + cXECVAL + "}")} )
				EndIf   
			EndIf
			
			DbSkip()
			
		End	
	
		nPos := Ascan(aEntradas, {|x| (x[1] == Alltrim(cWebService)) .And. (x[2] == Alltrim(cMetodo))})
		
	EndIf	            
	
	If  (nPos <= 0)
		cMensagem := STR0018    //" Entradas do webservice não encontradas! "
		Break
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Preenchendo os parametros de entrada do objeto webservice.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLenAEntradas := Len(aEntradas)
	
	For nA := nPos to nLenAEntradas
	
	    If  (Alltrim(aEntradas[nA][1]) != Alltrim(cWebService)) .Or. (Alltrim(aEntradas[nA][2]) != Alltrim(cMetodo))
	    	Exit
	    EndIf
	    
	    Eval(aEntradas[nA][3])  //Popula o objeto conforme codeblock da matriz.
	    	
	Next nA
	
End Sequence

If  !( Empty(cMensagem) )
	cMensagem := STR0019 + CRLF + cMensagem     //" Problema nas entradas do webservice: "
EndIf

RestArea(aArea)
        	
Return Empty(cMensagem)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ861Filial º Autor ³ Antonio C Ferreira º Data ³  01/02/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para obter ou nao a filial conforme parametrizacao. º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ861Filial()

Local cXFilial := Alltrim(xFilial(Alias())) //Obtem a filial da tabela que deve ser exclusiva para retornar a filial.

If  (SuperGetMV("MV_LJECOMF",,"1") != "1")
    cXFilial := ""
EndIf

Return cXFilial    


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ861VErroº Autor ³ Antonio C Ferreira º Data ³  07/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para processar o erro de execucao das rotinas.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oErro - Objeto com a mensagem de erro de execucao          º±±
±±º          ³ cMensagem - Mensagem de erro do processo, ira gerar Log.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ861VErro(oErro, cMensagem)

Default oErro     := nil
Default cMensagem := ""

Begin Sequence

	If  (ValType(oErro) != "O") .Or. (oErro:gencode <= 0)
		Break
	EndIf
	
	cMensagem += STR0020 + oErro:ERRORSTACK + CRLF        //"CODIGO DO ERRO:"
	cMensagem += STR0021 + oErro:DESCRIPTION              //"DESCRICAO DO ERRO:"

End Sequence

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ861DGradeº Autor ³ Antonio C Ferreira º Data ³  06/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Obter a descricao da grade pois somente grava no primeiro   º±±
±±º          ³ registro.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCodigo - Codigo do produto para obter a descricao          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function LJ861DGrade(cCodigo)

Local aArea      := GetArea()  //Salva a area atual
Local cDescricao := ""         //Descricao do produto na grade.

Default cCodigo := ""

SET DELETED ON

DbSelectArea("SBV")
DbSetOrder(1) //BV_FILIAL+BV_TABELA+BV_CHAVE

DbSeek(xFilial("SBV")+cCodigo)

While !( Eof() ) .And. (BV_FILIAL+BV_TABELA == xFilial("SBV")+cCodigo)

	If  !( Empty(BV_DESCTAB) )
		cDescricao := Alltrim(BV_DESCTAB)
		Exit
	EndIf

	DbSkip()
End	

SET DELETED OFF

RestArea(aArea)

Return cDescricao

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LJ861Pos º Autor ³ Antonio C Ferreira º Data ³  07/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ funcao local tirando voltando o filtro de exclusao e       º±±
±±º          ³ chamando o Posicone() padrao.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cAlias - Alias a ser utilizado na busca.                   º±±
±±º          ³ nIndice - indice a ser utilizado na busca.                 º±±
±±º          ³ Chave - chave a ser utilizado na busca.                    º±±
±±º          ³ cRetorno - Campo que tera o valor retornado pela busca.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ861Pos(cAlias, nIndice, cChave, cRetorno)

Default cAlias   := ""
Default nIndice  := 0
Default cChave   := ""
Default cRetorno := ""

SET DELETED ON  

cRetorno := Posicione(cAlias, nIndice, cChave, cRetorno)

SET DELETED OFF

Return cRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ861MLojaº Autor ³ Antonio C Ferreira º Data ³  07/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se utiliza Multi-Loja e obtem o codigo da loja do º±±
±±º          ³ e-commerce para a filial logada.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ861MLoja()

Local aArea     := GetArea()  //Alias atual

Local cCodLoja  := 0          //Loja no e-Commerce para a filial atual.

If  (SuperGetMV("MV_LJECOMZ",,"1") == "1")  //0=Nao Multiloja/1=Multiloja
	cCodLoja  := Val(Tabela("TU", cFilAnt, .F.))
EndIf	        

RestArea(aArea)
        	
Return cCodLoja

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ861LOCAL³ Autor ³   Antonio C Ferreira   ³ Data ³ 27/02/13       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida se o produto a ser exportado tem todos os armazens da MF6   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cMensagem - Mensagem de erro do processo, ira gerar Log.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ861LOCAL(cMensagem)

Local nA                           //contador do comando For.
Local aArea    := GetArea()       //Salva a area atual 
Local nLenLoc  := 0               //Tamanho de aLocais
Local cProduto := SB1->B1_COD     //Codigo do Produto que tera os armazens verificados
Local cFilSX6	:= xFilial("MF6")     //Filial MF6

SET DELETED ON
cMensagem := ""

If  Empty(aLocais)
    DbSelectArea("MF6")
    DbSeek(xFilial("MF6"))
    
    While !( Eof() )  .AND. (MF6_FILIAL ==  cFilSX6  )                 
        If !Deleted() .And.  (Ascan(aLocais, {|x| (x[1] == MF6_XFILIA) .And. (x[2] == MF6_LOCAL)}) <= 0)
    		aadd(aLocais, {Alltrim(MF6_XFILIA), MF6_LOCAL})
    	EndIf
    		
        DbSkip()
    End    
EndIf
                       
SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL

nLenLoc := Len(aLocais)

For nA := 1 to nLenLoc
	If  !( SB2->(DbSeek(Left(aLocais[nA][1]+Space(10),Len(B2_FILIAL))+PadR(cProduto,Len(B2_COD))+aLocais[nA][2])) ) .Or.  SB2->(Deleted())
	    cMensagem += STR0022 + Alltrim(cProduto) + STR0023 + aLocais[nA][2] + STR0024 + aLocais[nA][1] + CRLF   //"Produto: "##" Armazém: "##" Filial: "
	EndIf
Next nA            

If  !( Empty(cMensagem) )
    cMensagem := "LOJA861: LJ861ESTQ: " + STR0025 + CRLF + cMensagem   //"Produto(s) sem armazém do e-commerce cadastrado: "
    LjGrvLog( "", "...")
	LjGrvLog( "", cMensagem)	
    LjGrvLog( "", "...")
EndIf  

SET DELETED OFF  

RestArea(aArea)

Return Empty(cMensagem)
              
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ861Metodoº Autor ³ Antonio C Ferreira º Data ³  07/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Executa os metodos do webservice.                           º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lExcluir - Se refere a uma exclusao ou inclusao/alteracao   º±±
±±º          ³ lIntermediaria - Se utiliza a tabela intermediaria.         º±±
±±º          ³ cWebService  - WebService para a exportacao                 º±±
±±º          ³ cOrdem  - Codigo da Ordem de execucao dos metodos           º±±
±±º          ³ cMetodo  - Metodo para a exportacao                         º±±
±±º          ³ cECJob  - Nome do job que esta executando a rotina          º±±
±±º          ³ cMetCondicao - Condicao que verifica o retorno do metodo    º±±
±±º          ³ cMetRetorno - Dados do Retorno do metodo.                   º±±
±±º          ³ oObj - Objeto configurado com o webservice/metodo           º±±
±±º          ³ aEntradas - Parametros de entrada do webservice/metodo      º±±
±±º          ³ cMensagem - Mensagem de erro do processo, ira gerar Log.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ861Metodo(lExcluir, lIntermediaria, cWebService, cOrdem,;
                            cMetodo, cECJob, cMetCondicao, cMetRetorno,;
                            oObj, aEntradas, cMensagem)

Local aArea          := GetArea()       //Salva a area atual
Local nA		     := 0               //contador do comando For.
Local bMetodo        := &("{|| oObj:" + AllTrim(cMetodo) + "() }")  //CodBlock que ira executar o webservice/metodo.
Local bCondicao      := nil             //CodBlock que ira executar a Condicao que verifica o retorno do metodo apos a sua execucao.
                    
Local bRetorno       := nil             //CodBlock que ira obter os dados de retorno do metodo apos a sua execucao.
Local cGRetorno      := ""              //String com os dados do retorno do metodo que sera gravado na intermediaria ou log de erro.

Default lExcluir       := .F.
Default lIntermediaria := .F.
Default cWebService    := ""
Default cOrdem         := ""
Default cMetodo        := ""
Default cECJob         := ""
Default cMetCondicao   := ""
Default cMetRetorno    := ""
Default oObj           := nil
Default aEntradas      := {}
Default cMensagem      := ""

cWebService := AllTrim(cWebService)
cMetodo     := AllTrim(cMetodo)

Begin Sequence

	If  !( Eval(bMetodo) )
	
		If  !( Empty(GetWSCError(3)) )
			cMensagem := SubStr( GetWSCError(3), At(":", GetWSCError(3) ) + 1 )
		EndIf
		
		Break
	
	EndIf   
	                                                     
	If  !( Empty(cMetCondicao) )
		bCondicao := &("{|| " + AllTrim(cMetCondicao) + " }")
	    If  !( Eval(bCondicao) )
	     	cMensagem := Eval(&("{|| oObj:oWS"+cMetodo+"Result:cDescricao }"))  
	     	Break
	    EndIf
	EndIf     	
	    
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Obtem cada linha do retorno para executar e retornar um valor.            ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRetorno := &("{'" + StrTran(StrTran(Alltrim(cMetRetorno),chr(10),""),chr(13),"','") + "'}")
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Processa cada linha, alimentando cGRetorno.                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nA := 1 to Len(aRetorno)
	    If  Empty(aRetorno[nA])
	        Loop
	    EndIf    
	
	    bRetorno := &( "{|| " + aRetorno[nA] + " }" )
	    
	    cGRetorno += Eval(bRetorno) + CRLF
	Next nA
	
	If  lIntermediaria .And. !( Empty(cMensagem) )
		Break
	EndIf	
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Funcao para finalizar o processo.                                         ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If  !( Empty(MF1->MF1_ECFUNC) )
	 	bExecutar := &("{|| " + AllTrim(MF1->MF1_ECFUNC) + " }")
	 	Eval( bExecutar )
    EndIf

	If  !( Empty(cMensagem) )
		Break
	EndIf	
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Grava os campos de controle da intermediaria finalizando a exportacao.    ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If  lIntermediaria
		DbSelectArea("MF3")   
		
		MF3->MF3_ECFLAG := 'X' //FINALIZADO
		MF3->MF3_ECDTE  := Date()
		MF3->MF3_ECHRE  := Time()
		MF3->MF3_ECJOB  := cECJob
		MF3->MF3_ECRET  := cGRetorno
	EndIf	
	
End Sequence
                                                           
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso ocorra erro de processamento, ira ser retorrnado pelo bOldError.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  !( Empty(cMensagem) )
	cMensagem := STR0026 + cWebService + "/" + cMetodo + CRLF + cMensagem       //"Problema na execução do Webservice/Metodo: "
EndIf

RestArea(aArea)
        	
Return Empty( cMensagem )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ861ESTQ ³ Autor ³   Antonio C Ferreira   ³ Data ³ 15/02/13       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o saldo real e atualiza o campo de saldo de estoque do     ³±±
±±³          ³e-commerce com o mesmo calculo utilizado na Query da MF1.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProduto - Codigo do produto para retornar o saldo de estoque.    ³±±
±±³          ³ lGravar - Se ira gravar o saldo do estoque no campo de controle.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ861ESTQ(cProduto, lGravar)

Local nA
Local aArea    := GetArea()
Local aAreaSB2 := SB2->( GetArea() )
Local nLenLoc  := 0
Local nEstoque := 0    
Local cFilSX6	:= xFilial("MF6")  //Filial MF6
        
Default cProduto := ""
Default lGravar  := .F.

SET DELETED ON

SB2->( DbSetOrder(1) ) //B2_FILIAL+B2_COD+B2_LOCAL

If  Empty(aLocais)
    DbSelectArea("MF6")
    DbSeek(xFilial("MF6"))
    
    While !( Eof() )   .and. (MF6_FILIAL == cFilSX6)                   
        If !Deleted() .And. (Ascan(aLocais, {|x| (x[1] == MF6_XFILIA) .And. (x[2] == MF6_LOCAL)}) <= 0)
    		aadd(aLocais, {Alltrim(MF6_XFILIA), MF6_LOCAL})
    	EndIf
    		
        DbSkip()
    End    
EndIf

nLenLoc := Len(aLocais)

For nA := 1 to nLenLoc
	If  SB2->( DbSeek(Left(aLocais[nA][1]+Space(10),Len(B2_FILIAL))+PadR(cProduto,Len(B2_COD))+aLocais[nA][2]) ) .And. !SB2->(Deleted())
		nEstoque += SaldoSB2() //Soma os armazens do e-commerce relacionados na MF6.
        
		If  lGravar
			If  SB2->( SoftLock("SB2") )  //Se nao conseguir travar ira provavelmente ser enviado novamente no proximo processamento.
				SB2->B2_ECSALDO := SB2->(B2_QATU-B2_RESERVA-B2_QEMPN) //Grava com o mesmo calculo usado na Query da MF1.
				SB2->( MsUnLock() )
			Else
			    LjGrvLog( "", "...")
				LjGrvLog( "", "LOJA861: LJ861ESTQ: " + STR0027 + SB2->B2_COD + STR0023 + SB2->B2_LOCAL + STR0024 + SB2->B2_FILIAL)	//"Não foi possível travar o registro de estoque do produto: "##" Armazém: "##" Filial: "
			    LjGrvLog( "", "...")
			EndIf
		EndIf
	EndIf
Next nA

SET DELETED OFF

RestArea(aAreaSB2)
RestArea(aArea)

Return nEstoque
              
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ861STATS³ Autor ³   Antonio C Ferreira   ³ Data ³ 22/02/13       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Registra a mudanca de Status no campo copia do status.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ861STATS()		                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ861STATS()
                                
If  SB0->( !Eof() .And. SoftLock("SB0") )  //Se nao conseguir travar ira provavelmente ser enviado novamente no proximo processamento.
	SB0->B0_ECFLAX := SB0->B0_ECFLAG
	SB0->( MsUnLock() )
Else
    LjGrvLog( "", "...")
	LjGrvLog( "", "LOJA861: LJ861STATS: " + STR0028 + SB0->B0_COD + STR0024 + SB0->B0_FILIAL)	//"Nao foi possível travar o registro de Tabela de Preco (SB0): "##" Filial: "
    LjGrvLog( "", "...")
EndIf

Return .T.
              
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ861STATX³ Autor ³   Antonio C Ferreira   ³ Data ³ 27/02/13       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Registra a mudanca de Status no campo copia do status.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ861STATX()		                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ861STATX()
    
Local aArea		:= GetArea()  //Area atual
Local lAlsMF5	:= AliasInDic("MF5")
                                
If lAlsMF5
	If  MF5->( !Eof() .And. SoftLock("MF5") )  //Se nao conseguir travar ira provavelmente ser enviado novamente no proximo processamento.
		MF5->MF5_ECSTAX := MF5->MF5_ECSTAT
		MF5->( MsUnLock() )
	Else
	    LjGrvLog( "", "...")
		LjGrvLog( "", "LOJA861: LJ861STATX: " + STR0029 + MF5->MF5_ECALIA + STR0016 + MF5->MF5_ECVCHV)	 //"Nao foi possível travar o registro da Tabela MF5! Alias: "##" Chave: "
	    LjGrvLog( "", "...")
	EndIf
EndIf
	
RestArea( aArea )

Return .T.
              
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ861PRV  ³ Autor ³   Antonio C Ferreira   ³ Data ³ 22/02/13       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Registra a mudanca de Status no campo copia do status.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ861PRV()		                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ861PRV()
                                
If  SB0->( !Eof() .And. SoftLock("SB0") )  //Se nao conseguir travar ira provavelmente ser enviado novamente no proximo processamento.
	SB0->B0_ECPRV := SB0->(FieldGet(FieldPos("B0_PRV"+AllTrim(SuperGetMV("MV_LJECOMT",,SuperGetMV("MV_TABPAD"))))))
	SB0->( MsUnLock() )
Else
    LjGrvLog( "", "...")
	LjGrvLog( "", "LOJA861: LJ861PRV: " + STR0028 + SB0->B0_COD + STR0024 + SB0->B0_FILIAL)	//"Nao foi possível travar o registro de Tabela de Preco (SB0): "##" Filial: "
    LjGrvLog( "", "...")
EndIf

Return .T.
              
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ861SKU  ³ Autor ³   Antonio C Ferreira   ³ Data ³ 26/02/13       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Registra a exportacao da SKU na tabela de preco.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ861SA5()		                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ861SKU()

If  SB0->( !Eof() .And. SoftLock("SB0") )  //Ira registra que os dados do produto foram exportados para esta amarracao ProdutoXFornecedor
	SB0->B0_ECSEQ := MF3->MF3_ECSEQ
	SB0->( MsUnLock() )
Else
    LjGrvLog( "", "...")
	LjGrvLog( "", "LOJA861: LJ861SKU: " + STR0028 + SB0->B0_COD + STR0024 + SB0->B0_FILIAL)	//"Nao foi possível travar o registro de Tabela de Preco (SB0): "##" Filial: "
    LjGrvLog( "", "...")
EndIf

Return .T.
              
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ861SA5  ³ Autor ³   Antonio C Ferreira   ³ Data ³ 23/02/13       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Registra a exportacao do produto na tabela de amarracao.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ861SA5()		                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ861SA5()

If  SA5->( !Eof() .And. SoftLock("SA5") )  //Ira registra que os dados do produto foram exportados para esta amarracao ProdutoXFornecedor
	SA5->A5_ECSEQ := MF3->MF3_ECSEQ
	SA5->( MsUnLock() )
Else
    LjGrvLog( "", "...")
	LjGrvLog( "", "LOJA861: LJ861SA5: " + STR0030 + SA5->A5_PRODUTO + STR0031 + SA5->A5_FORNECE)	  //"Nao foi possível travar o registro da Amarração ProdutoXFornecedor (SA5): "##" Fornecedor: "
    LjGrvLog( "", "...")
EndIf

Return .T.
              
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ861PRD  ³ Autor ³   Antonio C Ferreira   ³ Data ³ 24/02/13        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Libera as tabelas do produto para quando for incluida nova amarracao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ861PRD()		                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ861PRD()
           
SET DELETED ON  

If  ( SB5->(!Eof() .And. SoftLock("SB5")) )  //Libera o produto para que na proxima amarracao seja exportado automaticamente.
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Libera o produto pai para exportacao para quando incluir nova amarracao.  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SB5->B5_ECDTEX := ""
	SB5->( MsUnLock() )
	
	LJ861ZERA(SB5->B5_COD)
Else
    LjGrvLog( "", "...")
	LjGrvLog( "", "LOJA861: LJ861PRD: " + STR0032 + SB5->B5_COD)	  //"Nao foi possível travar o registro do Complemento do Produto (SB5): "
    LjGrvLog( "", "...")
EndIf    
	
	
SET DELETED OFF  

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ861MCatg³ Autor ³   Antonio C Ferreira   ³ Data ³ 29/04/13        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Obtem as Categorias amarradas ao Filtro e-Commerce                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cFiltro - Codigo do filtro para obter as categorias                ³±±
±±³          ³ aCategoria - vetor que recebera a lista de categorias do filtro    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ861MCatg(cFiltro, aCategoria)
           
Local aArea  := GetArea()   //Salva a area atual

Default cFiltro := ""

aCategoria := {}

SET DELETED ON 

DbSelectArea("MFB")
DbSetOrder(2)  //MFB_FILIAL+MFB_ECFILT+MFB_ECCATE

DbSeek(xFilial("MFB")+cFiltro)

While  !( Eof() ) .And. (MFB_FILIAL+MFB_ECFILT == xFilial("MFB")+cFiltro)

	aadd(aCategoria, MFB_ECCATE)
	
	DbSkip()
EndDo	

SET DELETED OFF  

RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ861ZERA ³ Autor ³   Antonio C Ferreira   ³ Data ³ 24/02/13        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Libera as tabelas relacionadas ao produto para nova exportacao.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cProduto - Codigo do produto que tera as tabelas liberadas         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ861ZERA(cProduto)

Local nA       := 0
Local cCodigo  := ""
Local cCategoria := ""           

Default cProduto := ""
                                         
LjGrvLog( "", "...")
LjGrvLog( "", "LOJA861: LJ861ZERA: " + STR0033 + cProduto)     //"Zerando para o Produto: "
LjGrvLog( "", "...")

SB1->( DbSetOrder(1) ) //B1_FILIAL+B1_COD
SB1->( DbSeek(xFilial("SB1")+cProduto) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem o codigo raiz do produto de grade ou codigo do produto normal.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  Empty( SB1->B1_PRODPAI )
    cCodigo := SB1->B1_COD
Else
	cCodigo := SB1->( Left(B1_PRODPAI,Len(Alltrim(B1_PRODPAI))-4) ) //Obtem a raiz do produto sem a variacao da grade.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem os armazens do e-commerce para liberar os estoques para exportacao. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  Empty(aLocais)
	MF6->( DbSetOrder(1) ) //MF6_FILIAL+MF6_CEPDE+MF6_CEPATE
	MF6->( DbGoTop() )
	
	While MF6->( !Eof() )
		MF6->( aadd(aLocais, {Alltrim(MF6_XFILIA), MF6_LOCAL}) )
	
		MF6->( DbSkip() )
	End	
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera as tabelas do produto para exportacao quando for incluida uma nova ³
//³ amarracao.                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SB1->( DbSeek(xFilial("SB1")+cCodigo) )
                                     
While SB1->( !Eof() .And. (B1_FILIAL == xFilial("SB1")) .And. (Left(B1_COD,Len(cCodigo)) == cCodigo) )
    
	SB0->( DbSetOrder(1) ) //B0_FILIAL+B0_COD
	If  SB0->( DbSeek(xFilial("SB0")+SB1->B1_COD) .And. SoftLock("SB0") )
		SB0->B0_ECDTEX := " " //Libera a tabela de preco para que na proxima amarracao do fornecedor seja exportado automaticamente.
		SB0->B0_ECSEQ  := " "
		SB0->( MsUnLock() )
	EndIf
                                             
    For nA := 1 to Len(aLocais)
		SB2->( DbSetOrder(1) ) //B2_FILIAL+B2_COD+B2_LOCAL
		If  SB2->( DbSeek(Left(aLocais[nA][1]+Space(10),Len(B2_FILIAL))+SB1->B1_COD+aLocais[nA][2]) .And. SoftLock("SB2") )
			SB2->B2_ECSALDO := 0  //Libera a estoque para que na proxima amarracao do fornecedor seja exportado automaticamente.
			SB2->( MsUnLock() )
		EndIf
	Next nA	

	ACV->( DbSetOrder(5) ) //ACV_FILIAL+ACV_CODPRO+ACV_CATEGO
	ACV->( DbSeek(xFilial("ACV")+cCodigo) )
	
	While ACV->( !Eof() .And. (ACV_FILIAL == xFilial("ACV")) .And. (Left(ACV_CODPRO,Len(cCodigo)) == cCodigo) )   

        cCategoria := ACV->ACV_CATEGO
                    
        If  ACV->( SoftLock("ACV") )  //Libera a amarracao da categoria para que na proxima amarracao do fornecedor seja exportado automaticamente.
            ACV->ACV_ECDTEX := ""                                            
            ACV->( MsUnLock() )
        EndIf                                    
                               
        MFC->( DbSetOrder(1) ) //MFC_FILIAL+MFC_ECCATE+MFC_ECPROD+MFC_ECFILT+MFC_ECCONT                                                                                                                 
        MFC->( DbSeek(xFilial("MFC")+ cCategoria + cCodigo) )
                
        While MFC->( !Eof() .And. (MFC_FILIAL == xFilial("MFC")) .And. (MFC_ECCATE) == cCategoria .And. (Left(MFC_ECPROD,Len(cCodigo)) == cCodigo) )

            If  MFC->( SoftLock("MFC") )  //Libera a amarracao do filtro produto categoria para que na prox amarracao do fornec seja exportado automaticamente.
                MFC->MFC_ECDTEX := ""
                MFC->( MsUnLock() )
            EndIf
        
            MFC->( DbSkip() )

        End                                     

        ACV->( DbSkip() )                     

    End      

	SB1->( DbSkip() )
End    

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ861ECAuto º Autor ³ Antonio C Ferreira º Data ³  25/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica a variavel _LJECAUTO.                               º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function LJ861ECAuto()

Return lECLJAUTO

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ861JBE1 ³ Autor ³Eduardo Vicente Ferreira³ Data ³ 01/02/13       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Job de Verificação de prazo de vencimento de Boleto, para desfazer ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lECJob - Se esta executando via Job ou pelo Protheus.              ³±±
±±³          ³cECEmpresa - Codigo da Empresa para a preparacao do ambiente       ³±±
±±³          ³cECFilial - Codigo da Filial para a preparacao do ambiente         ³±±
±±³          ³cECTarefa - Grupo de tarefa de execucao dos webservices.           ³±±
±±³          ³cECJob - Nome do Job que esta executando a rotina.                 ³±±
±±³          ³cECIntervalo - Intervalo para a execucao da rotina.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ861JBE1(lECJob, cECEmpresa, cECFilial, cECTarefa,;
                   cECJob, cECIntervalo, cDias)
              
Local lOk           := .T.      //Retorna falso caso ocorra algum erro na execucao. 
Local cArq          := ""             //Nome do arquivo que ira gerar no diretorio system do Protheus para o controle do tempo de execucao           
Local nA            := 0        //Contador para processar as empresas e filiais passadas pelos parametros do JOB.
Local nEmpresas     := 0        //Calcula a quantidade de empresas passadas pelos parametros do JOB.
Local cXEmpresa     := ""       //Codigo da empresa ou Grupo de Empresa a ser processado.
Local cXFilial      := ""       //Codigo da Filial a ser processado.
Local aEmps         := {}      //Empresas que serao processadas pelo Job. 

Local lDepurar      := (Type("cFilAnt") == "U")   //Se esta sendo depurado pelo DevStudio ou esta executando pelo Protheus.

Local lAuto			:= .T.           //Passa a funcao lj140Exc() que esta sendo executado por job/autoexec().
Local cQuery        := ""            //Query para obter os titulos vencidos
Local cPrefixo		:= ""            //Prefixo utilizado pelo titulo do e-commerce
Local cNumTitulo	:= ""            //Numero do titulo do e-commerce
Local dDtVenc		:= Date()        //Data limite do Orcamento
Local aAreaSL1      := {}            //Salva a area do SL1 no meio do processamento 
Local lBaixa		:= .F.			 //Verifica se existe baixa para o título   
Local nTamPref		:= 0 
Local nTamNum		:= 0
Local nDias			:= 0			//Numero de dias 
Local lErroSE1		:= .F.			//errro na exclusão
Local lAlsMF5		:= AliasInDic("MF5")
               
Private lMsErroAuto    := .F.        //Variavel de controle caso ocorra erro no execauto.
Private lFTStartSilenc := .T.        //varivel para nao apresentar mensagem de erro em tela

DEFAULT lECJob     	:= "F"   
DEFAULT cECEmpresa 	:= "99"
DEFAULT cECFilial  	:= "01"
DEFAULT cECTarefa  	:= "A"
DEFAULT cECJob     	:= "JOB01"
DEFAULT cECIntervalo:= "02:00" 
DEFAULT cDias		:= "30"  
nDias := Val(cDias)


If nDias == 0
	nDias := 30
EndIf

cArq := cECJob+".tmp"                  
                          
lECJob := (lECJob == "T")  //Passa para valor logico.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o intervalo venceu para poder executar o job.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  lECJob .And. !( LJ861Exec(cArq, cECJob, cECIntervalo) )
	    Return .T.  //Cancela a execucao antes de preparar o ambiente.
	EndIf    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a quantidade de empresas/filiais que devem ser processadas.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( LJ861Emps("LOJA861", cECEmpresa, cECFilial, @nEmpresas, @aEmps) )
	    Return .F.  //Cancela a execucao antes de preparar o ambiente.
	EndIf    
	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se possui tabela MF5      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !lAlsMF5
	    Return .F.  //Cancela a execucao antes de preparar o ambiente.
	EndIf    

LjGrvLog( "", "LOJA861: LJ861JBE1: " + STR0034 + " Job: " + cECJob + " - " + Time() + "[ VERSION  24/01/2014 12:18] " )    //"Iniciando verificação de Orçamentos e-Commerce pendentes não pagos!"

Begin Sequence
	
	For nA := 1 to nEmpresas
	
		cXEmpresa := aEmps[nA][1]
		cXFilial  := aEmps[nA][2]
	
		If  lECJob .Or. lDepurar
			RpcClearEnv()   //Caso tenha algum ambiente em aberto, fechar!
			
			LjGrvLog( "", "LOJA861: LJ861JBE1: " + STR0045 + cXEmpresa + "/" + cXFilial + " - " + Time())  //"Iniciando Empresa/Filial: "
			RpcSetType( 3 )
			If  !( RpcSetEnv( cXEmpresa, cXFilial,,,"LOJ" ) )
				LjGrvLog( "", "LOJA861: LJ861JBE1: " + STR0046)     //"Parametros de Empresa e Filial incorretos! Cancelando Execução!"
				lOk := .F.
				Break
			EndIf 	
		ElseIf (nA > 1)
			Exit         //Caso nao seja Job devera sair para nao processar mais de uma vez na mesma empresa e filial.
		EndIf	

		nTamPref		:= SE1->(TamSx3("E1_PREFIXO"))[1] 
		nTamNum		:= SE1->(TamSx3("E1_NUM"))[1]


		cQuery := " SELECT SL1.R_E_C_N_O_ SL1RECNO, MF5.R_E_C_N_O_ MF5RECNO, SL1.L1_FORMPG, SL1.L1_FILIAL, SL1.L1_NUM "
		cQuery += " FROM " + RetSQLName("SL1") + " SL1, " + RetSQLName("MF5") + " MF5 "
		cQuery += " WHERE SL1.L1_DTLIM   >= " + ValToSQL(Date()-nDias)
		cQuery += " AND   SL1.L1_DTLIM   <  " + ValToSQL(Date())  
		cQuery += " AND   SL1.L1_ECFLAG    =  '1' "
		cQuery += " AND   MF5.MF5_ECALIA = 'SL1' "
		cQuery += " AND  (MF5.MF5_ECVCHV =  SL1.L1_FILIAL+SL1.L1_NUM) "
		cQuery += " AND   MF5.MF5_ECPEDI <> '' " 
		cQuery += " AND   MF5.MF5_ECPAGO <> '1' "
		cQuery += " AND   SL1.D_E_L_E_T_ =  '' "
		cQuery += " AND   MF5.D_E_L_E_T_ =  '' "
		
		
		If  (Select("TMPSL1") > 0)
			TMPSL1->( DbCloseArea() )
		EndIf	
	
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Obtem os dados executando a query.                                        ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbUseArea(.T., "TOPCONN", TcGenQry(Nil, Nil, cQuery), "TMPSL1", .F., .T.)
		
	    TcSetField( "TMPSL1", "SL1RECNO", "N", 10, 0 )
	    TcSetField( "TMPSL1", "MF5RECNO", "N", 10, 0 )
	
		While !( Eof() )
		
			SL1->(DbGoTo( TMPSL1->SL1RECNO ))  //Posiciona SL1 pelo resultado da Query
			MF5->(DbGoTo( TMPSL1->MF5RECNO ))  //Posiciona MF5 pelo resultado da Query
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processa os títulos de pagamentos realizados com Boleto³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Verifica se a data do orcamento nao pago e maior que a data de vencimento +1
			dDtVenc	:= SL1->L1_DTLIM
			
			If  Alltrim(Str(DOW(dDtVenc))) $ '1|6|7'
				
				While (Alltrim(Str(DOW(dDtVenc))) $ '1|6|7')
					dDtVenc	+= 1
				End
				
			EndIF
			
			If  (dDtVenc >= Date())
				DbSelectArea("TMPSL1")
				DbSkip()
				Loop
			EndIf	
			
		    If  (MF5->MF5_ECPAGO == "1")
	    		//Orcamento ja foi confirmado pagamento!
				DbSelectArea("TMPSL1")
				DbSkip()
				Loop
	    	EndIf
	    
		    If  !( MF5->(SoftLock("MF5")) )
		    	//Nao consegui travar a MF5!
				DbSelectArea("TMPSL1")
				DbSkip()
				Loop
		    EndIf
				
			cPrefixo	:= PadR(MF5->MF5_ECPREF, nTamPref)
			cNumTitulo	:= PadR(MF5->MF5_ECTITU, nTamNum)     
			
			lBaixa := .F.

			SE1->(DbSetOrder(1) )	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			
			SE1->(DbSeek(xFilial("SE1")+cPrefixo+cNumTitulo))
		
			Do While !lBaixa .And. SE1->(!(Eof()) .And. (E1_FILIAL+E1_PREFIXO+E1_NUM == xFilial("SE1")+cPrefixo+cNumTitulo)  .And. AllTrim(E1_TIPO) ==  AllTrim(SL1->L1_FORMPG) )
				lBaixa := SE1->(Round(E1_SALDO,2)) == 0  .Or. ;
						SE1->(ROUND(E1_SALDO,2) # ROUND(E1_VALOR,2) .And. !FXAtuTitCo())   //
				SE1->(DbSkip())                                                            //Baixa do título parcial?
		    EndDo                                                                            
		    
		    If lBaixa
	    		//Já foi realizado baixa para uma das parcelas!
				MF5->( MsUnLock() )
				DbSelectArea("TMPSL1")
				DbSkip()
				Loop		    	
		    EndIf
		    
		    //Validações adicionais:
		    //1) Verifica se existe pedido de reserva associado a este orçamento - não cancela
		                                                                         
			                             
	   		aAreaSL1    := SL1->(GetArea()) 
	   		
	   		LjGrvLog( "", "LOJA 861 VERIFICANDO PEDIDOS DE RESERVAS")
	   		
	   		SL1->(DbSetOrder(14)) //SL1->L1_FILRES + SL1->(L1_ORCRES)
	   		If SL1->(DbSeek(TMPSL1->L1_FILIAL + TMPSL1->L1_NUM))  .And. !Empty(SL1->L1_PEDRES) .And. AllTrim(TMPSL1->L1_FORMPG) <> "FI"   //Orçamento com pedido de reserva gerado
		        LjGrvLog( "", "...")
	    		LjGrvLog( "", "LOJA861: LJ861JBE1: Orçamento com Pedido de Venda["+ SL1->L1_PEDRES+ "] Gerado" + TMPSL1->L1_NUM)     //"Problema encontrado na exclusão do Orçamento! Orçamento: "
		        LjGrvLog( "", "...")
	    		MF5->( MsUnLock() )
				DbSelectArea("TMPSL1")
				DbSkip()
				Loop
	   			RestArea(aAreaSL1)
	   		EndIf
	   		
	   		
	   		RestArea(aAreaSL1)
	   		
	   		lECLJAUTO  := .T.
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancela orcamento e exclui pedido de venda e reservas de estoque³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    
		    If lj140Exc("SL1", SL1->(Recno()), 5,,lAuto, SL1->L1_FILIAL, SL1->L1_NUM) != 1
		        LjGrvLog( "", "...")
	    		LjGrvLog( "", "LOJA861: LJ861JBE1: " + STR0035 + SL1->L1_NUM)     //"Problema encontrado na exclusão do Orçamento! Orçamento: "
		        LjGrvLog( "", "...")
	    		MF5->( MsUnLock() )
				DbSelectArea("TMPSL1")
				DbSkip()
				Loop
	   		EndIf
	    
	   		lECLJAUTO  := .F.
	
			RestArea(aAreaSL1) //Volta a posicao original
	
			If  !( SL1->( Deleted() ) )
		        LjGrvLog( "", "...")
	    		LjGrvLog( "", "LOJA861: LJ861JBE1: " + STR0035 + SL1->L1_NUM)     //"Problema encontrado na exclusão do Orçamento! Orçamento: "
		        LjGrvLog( "", "...")
	
	    		MF5->( MsUnLock() )
	
				DbSelectArea("TMPSL1")
				DbSkip()
				Loop
		    EndIf
				
		    If  MF5->( SoftLock("MF5") )
		        MF5->MF5_ECFLAG := "2"  //Inativo		        
		    EndIf
		    
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui os Titulos do Orcamento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SE1")
			dbSetOrder(1) 	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			
			DbSeek(xFilial("SE1")+cPrefixo+cNumTitulo)
			
			lECLJAUTO  := .T.   
			lErroSE1 := .F.
			
			While !(Eof()) .And. (E1_FILIAL+E1_PREFIXO+E1_NUM == xFilial("SE1")+cPrefixo+cNumTitulo)
			
				lMsErroAuto  := .F.
				
				aTitulo	:= {}
				
				aAdd(aTitulo,{"E1_PREFIXO"	, E1_PREFIXO	, Nil})
				aAdd(aTitulo,{"E1_NUM"		, E1_NUM		, Nil})
				aAdd(aTitulo,{"E1_PARCELA"	, E1_PARCELA	, Nil})
				aAdd(aTitulo,{"E1_TIPO"		, E1_TIPO		, Nil})
				
				MSExecAuto({|x,y| FINA040(x,y)},aTitulo,5)
				
				If lMsErroAuto
					LjGrvLog( "", "LOJA861: LJ861JBE1: " + STR0036 + cPrefixo + "-" + cNumTitulo)    //"Problema encontrado na exclusão do Título! Título: "
					lErroSE1 := .T. //Erro na exclusão
					DisarmTransaction()
					RollBackSX8()
					Exit
				Else
					ConfirmSX8()
				EndIf
				
				SE1->(DbSkip())
				
			End
	
			lECLJAUTO  := .F.
	        
	
			If !lErroSE1 .And. MF5->( SoftLock("MF5") ) //somente libera se houve baixa o título
				MF5->MF5_ECFLAG := "2"  //Inativo 
		     	MF5->MF5_ECDTEX := " "
		    	MF5->MF5_ECSTAT := "5"  // 5-Status e-commerce para cancelado
		    	MF5->( MsUnLock() )
		    ElseIf lErroSE1    
		    		LjGrvLog( "", "LOJA861 -   VERSION 24/01/2014  - problemas na excçusão do título [" + SL1->L1_NUM + "]")
		    		MF5->( MsUnLock() ) //erro no se1
		    EndIf
	
			DbSelectArea("TMPSL1")
			DbSkip()
			
		End
		
		TMPSL1->( DbCloseArea() )

	Next nA
			
End Sequence

If  lECJob .Or. lDepurar
	RpcClearEnv()
          
	If  lECJob .And. lOk
		MemoWrit(cArq,DtoS(Date())+','+Time())
	EndIf	
EndIf

LjGrvLog( "", "LOJA861: LJ861JBE1: " + STR0047 + " - " + Time())  //"Finalizando o processo!"

Return lOk

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³LJ861EC01 ³ Autor ³ Eduardo Vicente 	    ³ Data ³ 02/02/13 	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ 	Verifica se utiliza integração e-commerce e 				 ³±±
±±³			 ³	se o título foi gerado pelo e-commerce e é boleto (FI)		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cE1Num - Numero do titulo e-commerce                        	 ³±±
±±³          ³ cE1Serie - Serie do titulo e-commerce                      	 ³±±
±±³          ³ lTemPed - Se eh obrigado a verificar o pedido no orcamento  	 ³±±
±±³          ³ cFilTit - Filial que foi gerada o título E1_FILORIG           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ861EC01(cE1Num, cE1Serie, lTemPed, cFilTit)
Local aAreaSL1	 := {}
Local aAreaMF5	 := {}
Local aRecSC5	 := {}
Local lRet		 := .F.                              //Retorna verdadeiro se for titulo e-commerce
Local lECommerce := SuperGetMv("MV_LJECOMM",,.F.)    //Verifica se o e-commerce esta ativo     
Local lECCia	 := SuperGetMv("MV_LJECOMO",,.F.)    //Verifica se o e-commerce é Ciashop   
Local lRotCanc	 := .F.                              //Executado pela rotina de cancelamento
Local lAlsSL1	 := AliasInDic("SL1")
Local lAlsMF5	 := AliasInDic("MF5")

DEFAULT cE1Num   := ""
DEFAULT cE1Serie := Iif(lAlsSL1 , Space(TamSx3("L1_SERPED")[1]) , Space(TamSx3("E1_PREFIXO")[1]))
DEFAULT lTemPed  := .F.                              //Delete - //.t. - Baixa
DEFAULT cFilTit  := cFilAnt 

LjGrvLog( cE1Num + " " + cE1Serie, " Localizando o Titulo ", )

//Inserção de validações para filtrar a entrada, essa função é chamada pelo FINA070 em ambientes que não usam o SIGALOJA
If lAlsSL1 .And. SL1->( ColumnPos("L1_FILIAL") ) > 0 .And. !Empty( SL1->(IndexKey(11)) ) .And. !Empty(cE1Num)

	LjGrvLog( cE1Num + " " + cE1Serie, " Passou pela validações ", )

	aAreaSL1 := SL1->( GetArea() )
	aAreaMF5 := MF5->( GetArea() )
	
	SL1->( DbSetOrder(11) )     //L1_FILIAL + L1_SERPED + L1_DOCPED
    If SL1->( DbSeek(xFilial("SL1", cFilTit) + cE1Serie + cE1Num) )

		LjGrvLog( cE1Num + " " + cE1Serie, " Achou os dados na SE1 ", )
	
        //E-commerce Rakuten
        If  lECommerce .And. !lECCia .And. lAlsMF5 .And. ChkFile("MF5") .And. SL1->L1_FORMPG == "FI" .And. SL1->L1_ECFLAG == "1"
			LjGrvLog( cE1Num + " " + cE1Serie, " E-commerce Rakuten ", )

            MF5->( DbSetOrder(1) ) //MF5_FILIAL+MF5_ECALIA+MF5_ECVCHV
        
            If !( Empty( Posicione("MF5",1,xFilial("MF5", cFilTit)+"SL1"+xFilial("SL1", cFilTit)+SL1->L1_NUM,"MF5_ECPEDI") ) ) .And.;
               ( !lTemPed .Or. !Empty( Posicione("SL1",14,xFilial("SL1", cFilTit)+SL1->L1_NUM,"L1_PEDRES") ) )
                lRet := .T.
            EndIf
            
            LjGrvLog(cE1Num + " " + cE1Serie, "Localizando o Titulo no SL1 - Rakuten", lRet)

        //E-commerce CiaShop Antiga
        ElseIf lECommerce .And. lECCia .And. SL1->L1_ECFLAG == "1" .And. !Empty(SL1->L1_PEDRES)
			LjGrvLog( cE1Num + " " + cE1Serie, " E-commerce Ciashop Antiga ", )
            
            If !lTemPed //Exclusão de Título
                //So pode retornar .F. se estiver na rotina de cancelamento de Boleto
                lRotCanc := IsInCallStack("Lj140ExR") //Não pode ser chamado pela integração EC
                lRet := !lRotCanc
            ElseIf lTemPed //Baixa de Título
                lRet :=  SL1->L1_FORMPG == "FI"  //Retorna .T. pois na chamada de baixa de título o título é EC
            EndIf
            
            LjGrvLog(cE1Num + " " + cE1Serie, "Localizando o Titulo no SL1 - CiaShop",  lRet)

        //Integração via Mensagem Única
        ElseIf !lECommerce .And. !lECCia .And. SL1->L1_ORIGEM == "N"
			LjGrvLog( cE1Num + " " + cE1Serie, " Mensagem Unica ", )

            SL1->( DbSetOrder(14) )     //L1_FILIAL+L1_ORCRES
            If	ExistFunc("LjxjPedBlq") .And. SL1->( DbSeek(xFilial("SL1", cFilTit) + SL1->L1_NUM) )

				//Caso não exista o SC5 não deve entrar aqui, quando o orçamento é 'Retira Posterior'- JULIOOOO
				If Lj861VlSC5(@aRecSC5) .And. Len(aRecSC5) > 0 //posiciona para alterar o SC5 correto
					SC5->(dbGoto(aRecSC5[1]))

					//Verifica se tem bloqueio por forma de pagamento
					LjGrvLog( cE1Num + " " + cE1Serie, " Antes de LjxjPedBlq ", )
					lRet := LjxjPedBlq(SL1->L1_NUM)
					LjGrvLog( cE1Num + " " + cE1Serie, " Depois de LjxjPedBlq ", lRet)
				Else
					LjGrvLog( cE1Num + " " + cE1Serie, " Não existe Pedido (SC5) para liberar ")
				EndIf
            EndIf

            LjGrvLog(cE1Num + " " + cE1Serie, "Localizando o Titulo no SL1 - Mensagem Única", lRet)
        EndIf

    EndIf
	
	RestArea(aAreaSL1)
	RestArea(aAreaMF5)
EndIf

LjGrvLog( cE1Num + " " + cE1Serie, "Final de Localizando o Titulo ", lRet)
	
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ LJ861EC02³ Autor ³ Eduardo Vicente Ferreira ³ Data ³ 29/01/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a Liberação do Pedido de Venda, que por sua vez está  ³±±
±±³			 ³ Bloqueado por crédito. Somente para boleto (FI)				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cE1Num - Numero do titulo e-commerce                        	 ³±±
±±³          ³ cE1Serie - Serie do titulo e-commerce                      	 ³±±
±±³          ³ cFilTit - Filial que foi gerada o título E1_FILORIG           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ861EC02(cE1Num, cE1Serie, cFilTit, lValBaixa)
Local nA         := 0                               //Contador do comando For
Local aArea		 := GetArea()                       //Salva a area atual
Local aAreaSL1	 := SL1->( GetArea() )              //Salva a area da tabela SL1
Local aAreaSC9	 := SC9->( GetArea() )              //Salva a area da tabela SC9
Local lRet		 := .T.                             //Retorna verdadeiro se o processo concluiu sem problema
Local cPedido	 := ""                              //Numero do pedido de venda referente ao titulo a ser bloqueado
Local lECommerce := SuperGetMv("MV_LJECOMM",,.F.)   //Verifica se o e-commerce esta ativo   
Local nTamPref   := SE1->(TamSx3("E1_PREFIXO"))[1]  
Local nTamNum	 := SE1->(TamSx3("E1_NUM"))[1]
Local cPrefixo 	 := ""
Local cNumTitulo := ""	
Local lBaixa	 := .F.
Local cStatEC	 := SuperGetMv("MV_LJECOMY",,"7")   //Status do título baixado
Local lECCia 	 := SuperGetMv("MV_LJECOMO",,.F.)   //e-commerce CiaShop?   
Local aAreaSC5 	 := SC5->(GetArea())                //workArea do pedido
Local aAreaSE1	 := SE1->(GetArea())		        //WorkArea SE1
Local nVlrLiber  := 0
Local aRegSC6    := {}
Local lEstoque   := .T.
Local lAltFil    := .F.                             //Alterou a Filial?
Local cFilBkp	 := cFilAnt		                    //Filial original
Local aAreaSM0   := {}			                    //WorkAreaSM0

DEFAULT cE1Num    := ""
DEFAULT cE1Serie  := Space(Len(SL1->L1_SERPED)) 
DEFAULT cFilTit   := cFilAnt 
DEFAULT lValBaixa := .T.                            //Valida Baixa

lAltFil := !(cFilTit == cFilAnt) //Alterou a Filial?

//Verifica se o título foi baixado
lBaixa      := .F.
cPrefixo	:= PadR(cE1Serie, nTamPref)
cNumTitulo	:= PadR(cE1Num  , nTamNum)

If lValBaixa
	SE1->( DbSetOrder(1) )	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
    
    If SE1->( DbSeek(xFilial("SE1", cFilTit) + cPrefixo + cNumTitulo) )
	
        While !SE1->( Eof() ) .And. SE1->E1_FILIAL == xFilial("SE1", cFilTit) .And.;
			 SE1->E1_PREFIXO == cPrefixo .And. SE1->E1_NUM == cNumTitulo

            //Verifica se todas parcelas do titulo foram baixadas
            If ( (lECommerce .Or. lECCia) .And. AllTrim(SE1->E1_TIPO) == "FI" ) .Or.;   //Se E-commerce Rakuten ou CiaShop Antigo
               ( !lECommerce .And. !lECCia )                                            //Não E-commerce Rakuten ou CiaShop Antigo

                If Round(SE1->E1_SALDO, 2) > 0
                    lBaixa := .F.
                    Exit
                Else    
                    lBaixa := .T.
                EndIF
            EndIf

            SE1->( DbSkip() )
        EndDo

    EndIf
	
	RestArea(aAreaSE1)
EndIf

//Localização do orcamento no loja
DbSelectArea("SL1")
SL1->( DbSetOrder(11) )     //L1_FILIAL+L1_SERPED+L1_DOCPED
If !Empty(cE1Num) .And. SL1->( DbSeek(xFilial("SL1", cFilTit) + cE1Serie + cE1Num) )

    //E-commerce Rakuten
    If lECommerce .And. !lECCia .And. SL1->L1_ECFLAG == "1" .And. SL1->L1_FORMPG == "FI"

        If ChkFile("MF5") 
            MF5->( DbSetOrder(1) ) //MF5_FILIAL+MF5_ECALIA+MF5_ECVCHV

            If !( Empty(Posicione("MF5",1,xFilial("MF5",cFilTit)+"SL1"+xFilial("SL1",cFilTit)+SL1->L1_NUM,"MF5_ECPEDI")) )
                
                //Posiciona pelo L1_ORCRES para obter o pedido do orcamento para desbloquear o credito.
                cPedido	 := Posicione("SL1",14,xFilial("SL1", cFilTit)+SL1->L1_NUM,"L1_PEDRES") 

                LjGrvLog(cE1Num + " " + cE1Serie, "Libera Pedido na baixa do Titulo - Rakuten", cPedido)
                
                MF5->( RecLock("MF5",.F.) )
                MF5->MF5_ECPAGO	:= "1"
                If lBaixa     //houve baixa total?
                    MF5->MF5_ECSTAT	:= cStatEC     //Ira avisar ao e-commerce que o pagamento do titulo foi realizado.
                    MF5->MF5_ECDTEX := " "
                EndIf
                MF5->( MsUnlock() )
            EndIf
        EndIf

    //E-commerce CiaShop Antiga
    ElseIf lECommerce .And. lECCia .And. SL1->L1_ECFLAG == "1" .And.  SL1->L1_FORMPG == "FI"

        //Localiza o pedido de Venda e atualiza o status
        If !Empty(SL1->L1_PEDRES) 
            SC5->(DbSetOrder(1)) //C5_FILIAL + C5_NUM
            If SC5->(DbSeek(xFilial("SC5",cFilTit)+SL1->L1_PEDRES)) .And. lBaixa .And. Empty(SC5->C5_NOTA)  //Baixou o pagamento FI após faturar
            
                cPedido := SC5->C5_NUM

                LjGrvLog(cE1Num + " " + cE1Serie, "Libera Pedido na baixa do Titulo - CiaShop", cPedido)

                RecLock("SC5", .F.)
                    SC5->C5_STATUS  := "10" //Pagamento confirmado 
                    SC5->C5_VOLTAPS := "" 
                SC5->( MsUnLock() )

            ElseIf !lBaixa .AND. !lValBaixa .AND. SC5->(Found())
                cPedido := SC5->C5_NUM
            EndIf      

            RestArea(aAreaSC5)
        EndIf

    //Integração via Mensagem Única
    ElseIf !lECommerce .And. !lECCia .And. lBaixa .And. SL1->L1_ORIGEM == "N"

        //Localiza o pedido de Venda e atualiza o status
        SL1->( DbSetOrder(14) )     //L1_FILIAL+L1_ORCRES        
        If SL1->( DbSeek(xFilial("SL1", cFilTit) + SL1->L1_NUM) ) .And. !Empty(SL1->L1_PEDRES)
            
            SC5->( DbSetOrder(1) )  //C5_FILIAL + C5_NUM
            If SC5->( DbSeek(xFilial("SC5",cFilTit) + SL1->L1_PEDRES) ) .And. Empty(SC5->C5_NOTA)
            
                cPedido := SC5->C5_NUM

                LjGrvLog(cE1Num + " " + cE1Serie, "Libera Pedido na baixa do Titulo - Mensagem Única", cPedido)

                RecLock("SC5", .F.)
                    SC5->C5_STATUS  := "10" //Pagamento confirmado 
                    SC5->C5_VOLTAPS := "" 
                SC5->( MsUnLock() )

                If FWHasEai("MATA410B", .T., , .T.)
                    LjGrvLog("Lj861Ec02", "Gera mensagem de Rastreio de Pedido. Pagamento confirmado (MATA410B)")
                    FwIntegDef("MATA410B",,,, "MATA410B")
                EndIf
            Else
                LjGrvLog(cE1Num + " " + cE1Serie, "Pedido não localizado, na baixa do Titulo para Liberação - Mensagem Única", cPedido)
            EndIf      

            RestArea(aAreaSC5)
        EndIf

    EndIf

EndIf

//Desbloqueio de Pedido de Venda, pago por Boleto.
//Houve baixa do título ou libera sem baixar (Gateway de Pagamento)
If lBaixa .Or. !lValBaixa

	If  !Empty(cPedido)
	
		If lAltFil
			aAreaSM0 := SM0->(GetArea())
			cFilBkp	:= cFilAnt
			cFilAnt := cFilTit
		EndIf
		
	    For nA := 1 to 2
	    	nVlrLiber := 0
	    	aRegSC6 := {}
			dbSelectArea("SC9")
			dbSetOrder(3)//C9_FILIAL+C9_PEDIDO+C9_GRUPO+C9_PRODUTO
		
			If  DbSeek(xFilial("SC9", cFilTit)+cPedido)
				While !( Eof() ) .And. (C9_FILIAL+C9_PEDIDO == xFilial("SC9", cFilTit)+cPedido)
					lEstoque := .T.
					If lECCia // Verifica o Bloqueio do estoque nos itens		    	
		    			SC6->(dbSetOrder(1))
						If SC6->(MsSeek(xFilial("SC6", cFilTit)+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)) .And.;
							( Len(aRegSC6) == 0  .Or. Ascan(aRegSC6, {|x| x == SC6->(RecNo()) })  == 0 )

							aadd(aRegSC6,SC6->(RecNo()))
							nVlrLiber += SC6->C6_VALOR
						EndIf								    		
		    		Else
						RecLock("SC9",.F.)
						SC9->C9_BLCRED	:= " "
						SC9->(MsUnlock())	    		
		    		EndIf		    		
					SC9->(dbSkip())
				End
			EndIf
			If Len(aRegSC6) > 0
				dbSelectArea("SC5")
				dbSetOrder(1)
				DbSeek(xFilial("SC5", cFilTit)+cPedido)								
				MaAvalSC5("SC5",3,.F.,.F.,,,,,,cPedido,aRegSC6,.T.,.F.,@nVlrLiber)
			EndIf
			If  (nA >= 2)
			    Exit
			EndIf    
	
			dbSelectArea("SC5")
			dbSetOrder(1)//C5_FILIAL+C5_NUM
			dbSeek(xFilial("SC5", cFilTit)+cPedido)
			
			If  Eof() .Or. Empty(C5_ECVINCU)
			    Exit
			EndIf
			
			DbSeek(C5_FILIAL+Alltrim(C5_ECVINCU))
			cPedido := C5_NUM
		Next nA	
		If lAltFil
			cFilAnt := cFilBkp
			RestArea(aAreaSM0)
		EndIf
	EndIf
EndIf

RestArea(aAreaSC5)	
RestArea(aAreaSC9)
RestArea(aAreaSL1)
RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ LJ861EC03³ Autor ³ Antonio C Ferreira    ³ Data ³ 04/03/13    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o pedido de venda emitiu Nota Fiscal para nao     ³±±
±±³			 ³ permitir o cancelamento da baixa de titulo.Somente Boleto (FI)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cE1Num - Numero do titulo e-commerce                        	 ³±±
±±³          ³ cE1Serie - Serie do titulo e-commerce                      	 ³±±
±±³          ³ cFilTit - Filial que foi gerada o título E1_FILORIG           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ861EC03(cE1Num, cE1Serie, cFilTit)

Local aArea		:= GetArea()             //Salva a area atual
Local aAreaSL1	:= SL1->( GetArea() )   //Salva a area da tabela SL1
Local aAreaSC9	:= SC9->( GetArea() )   //Salva a area da tabela SC9
Local lRet		:= .T.                  //Retorna verdadeiro se o processo concluiu sem problema
Local cPedido	:= ""                   //Numero do pedido de venda referente ao titulo a ser bloqueado
Local lECommerce:= SuperGetMv("MV_LJECOMM",,.F.)  //Verifica se o e-commerce esta ativo
Local lECCia 	:= SuperGetMV("MV_LJECOMO",,.F.)   //e-commerce CiaShop habilitado?
Local lGeraSE1 	:= SuperGetMV("MV_LJECOMS",,.F.)	//Gera contas a Receber?    
Local aAreaSC5 	:= {}   //WorkAreaSC5  
Local cStatus	:= ""	//Status do pedido
Local lConfPgto := .F. //Confirmado pagamento de Market Place?
Local aAreaMGT := {}
Local lStatusPed := AliasInDic("MH6") //Alias do status do pedido existe?
Local aAreaMH6 := {}
Local cC5PedEcom := "" //Pedido e-commerce

DEFAULT cE1Num     := ""
DEFAULT cE1Serie   := Space(Len(SL1->L1_SERPED))
DEFAULT cFilTit	  := cFilAnt

//|__________________________________
//|
//|Localização do orcamento no loja.
//|__________________________________

DbSelectArea("SL1")
DbSetOrder(11) //L1_FILIAL+L1_SERPED+L1_DOCPED

If  !( Empty(cE1Num) ) .And. DbSeek(xFilial("SL1", cFilTit)+cE1Serie+cE1Num) .And. (SL1->L1_FORMPG == "FI") 
	If  lECommerce .And. ChkFile("MF5") .AND. !lECCia 
    	MF5->( DbSetOrder(1) ) //MF5_FILIAL+MF5_ECALIA+MF5_ECVCHV
    	
    	MF5->( DbGoTop() )  //sem esta linha o registro nao sera atualizado.

    	If  !( Empty(Posicione("MF5",1,xFilial("MF5", cFilTit)+"SL1"+xFilial("SL1", cFilTit)+SL1->L1_NUM,"MF5_ECPEDI")) )
    	    If  (Alltrim(MF5->MF5_ECSTAX) == "6") .And. SoftLock("MF5")
    		    //Posiciona pelo L1_ORCRES para obter o pedido do orcamento para bloquear o credito.
				cPedido	 := Posicione("SL1",14,xFilial("SL1", cFilTit)+SL1->L1_NUM,"L1_PEDRES") 
			Else
				Alert(STR0037+CRLF+STR0038)    //"Já processado a confirmação de pagamento no e-Commerce!"##" Não pode cancelar a baixa do Título!"
				lRet := .F.
			EndIf	
		EndIf
	ElseIf lECommerce .AND. lECCia 
			cPedido	 := SL1->L1_PEDRES
			//Localixa o Pedido
			aAreaSC5 := SC5->(GetArea())
			cStatus :=  Posicione("SC5",1,xFilial("SC5", cFilTit)+SL1->L1_PEDRES,"C5_STATUS") 
			
			
			//Verifica se não existe confirmação de pagamento do Pedido por se tratar de uma venda market place que a baixa é realizada 
			//após a emissao da nota
			If (cStatus == AllTrim(SuperGetMv("MV_LJECST1",.F., "30")) .or. cStatus == SuperGetMv("MV_LJECSTF",,"30")) .and. SC5->C5_VOLTAPS <> "1"
				//Verifica se existe confirmação Manual de Pedido Market Place
				aAreaMGT := MGT->(GetArea())
				MGT->(DbSetOrder(2)) //FILIAL + MGT_PEDIDO
				MGT->(DbSeek(xFilial("MGT", cFilTit) + SC5->C5_NUM))
				
				Do While !lConfPgto .AND. MGT->( !Eof()  .AND. MGT_FILIAL = xFilial("MGT", cFilTit) .AND. MGT_PEDIDO = SC5->C5_NUM)
					lConfPgto := AllTrim(MGT->MGT_STATUS) == "LB"
					MGT->(DbSkip(1))
				EndDo
			
				RestArea(aAreaMGT)
				
				If !lConfPgto
					//Verifica se existe a funcionalidade de status do Pedido
					If lStatusPed
						aAreaMH6 := MH6->(GetArea())
						MH6->(dbSetOrder(1))	// MH6_FILIAL+MH6_PDECOM
						cC5PedEcom := PadR(AllTrim(SC5->C5_PEDECOM), TamSx3("C5_PEDECOM")[1]) 
						If MH6->(DbSeek(xFilial("MH6", cFilTit)+cC5PedEcom))
							lConfPgto := AllTrim(MH6->MH6_STATUS) == "10" //Pagamento confirmado
						EndIf
						
						RestArea(aAreaMH6)
					EndIf
				EndIf
			EndIf
			If !lConfPgto  .AND. (cStatus == "30" .AND. SC5->C5_VOLTAPS <> "1"   .OR. ( !Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_SERIE) )) //Pedido Despachado
		    	Alert(STR0039 + SL1->L1_DOC + STR0040 + SL1->L1_SERIE + STR0041 + cPedido + STR0042)    //"Gerada a Nota Fiscal "##" Série: "##" do pedido: "##" correspondente a este título!"
			    lRet := .f.
			EndIf
			
			RestArea(aAreaSC5)
			
	EndIf
EndIf

//|_________________________________________________
//|
//|Verifica se gerou Nota Fiscal no pedido de venda.
//|_________________________________________________

If  lRet .And. !( Empty(cPedido) )  .AND. !lECCia .AND. !lConfPgto
	dbSelectArea("SC9")
	dbSetOrder(3)//C9_FILIAL+C9_PEDIDO+C9_GRUPO+C9_PRODUTO
	
	If  DbSeek(xFilial("SC9", cFilTit)+cPedido)
	
		While (C9_FILIAL+C9_PEDIDO == xFilial("SC9")+cPedido)
			If  !( Empty(C9_NFISCAL) )
			    MF5->( MsUnLock() )
				lRet := .F.
				Exit
			EndIf	
				
			dbSkip()
		End
					
		If  !( lRet )
		    Alert(STR0039 + SC9->C9_NFISCAL + STR0040 + SC9->C9_SERIENF + STR0041 + cPedido + STR0042)    //"Gerada a Nota Fiscal "##" Série: "##" do pedido: "##" correspondente a este título!"
		EndIf    
	
	EndIf
EndIf

RestArea(aAreaSC9)
RestArea(aAreaSL1)
RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LJ861EC04³ Autor ³ Eduardo Vicente Ferreira ³ Data ³ 29/01/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o Bloqueio do Pedido de Venda no cancelamento da baixa³±±
±±³			 ³ do título. Somente boleto (FI)					             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cE1Num - Numero do titulo e-commerce                        	 ³±±
±±³          ³ cE1Serie - Serie do titulo e-commerce                      	 ³±±
±±³          ³ nOpcao - confirmacao do cancelamento da baixa pelo usuario  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ861EC04(cE1Num, cE1Serie, nOpcao, cFilTit)
                                    
Local nA        := 0                     //Contador do comando For
Local aArea		:= GetArea()             //Salva a area atual
Local aAreaSL1	:= SL1->( GetArea() )   //Salva a area da tabela SL1
Local aAreaSC9	:= SC9->( GetArea() )   //Salva a area da tabela SC9
Local lRet		:= .T.                  //Retorna verdadeiro se o processo concluiu sem problema
Local cPedido	:= ""                   //Numero do pedido de venda referente ao titulo a ser bloqueado
Local lECommerce:= SuperGetMv("MV_LJECOMM",,.F.)  //Verifica se o e-commerce esta ativo
Local lECCia 	:= SuperGetMV("MV_LJECOMO",,.F.)    //e-commerce CiaShop
Local lGeraSE1 	:= SuperGetMV("MV_LJECOMS",,.F.)   //Gera Contas a Receber 
Local cStatus 	:= "" //Status do Pedido
Local aAreaSC5	:= SC5->( GetArea() )
Local lSemNota	:= .T. //Sem Nota Fiscal
Local nVlrLiber := 0
Local aRegSC6   := {}
Local lEstoque  := .T.
Local nC 		:= 0
Local lAltFil   := .F. //Alterou a Filial?
Local cFilBkp	:= cFilAnt		//Filial original
Local aAreaSM0  := {}			//WorkAreaSM0

lAltFil   := !(cFilTit == cFilAnt) //Alterou a Filial?

DEFAULT cE1Num     := ""
DEFAULT cE1Serie   := Space(Len(SL1->L1_SERPED))
DEFAULT nOpcao     := 0
DEFAULT cFilTit 	  := cFilAnt

Begin Sequence                             

    If  (nOpcao <> 1)
    	MF5->( MsUnLock() )
    	Break
    EndIf

	//|__________________________________
	//|
	//|Localização do orcamento no loja.
	//|__________________________________
	
	DbSelectArea("SL1")
	DbSetOrder(11) //L1_FILIAL+L1_SERPED+L1_DOCPED
	
	If  !( Empty(cE1Num) ) .And. DbSeek(xFilial("SL1", cFilTit)+cE1Serie+cE1Num) .And. (SL1->L1_FORMPG == "FI")
		If  lECommerce .And. ChkFile("MF5") .and. !lECCia 
	    	MF5->( DbSetOrder(1) ) //MF5_FILIAL+MF5_ECALIA+MF5_ECVCHV
	
	    	If  !( Empty(Posicione("MF5",1,xFilial("MF5", cFilTit)+"SL1"+xFilial("SL1", cFilTit)+SL1->L1_NUM,"MF5_ECPEDI")) )
	   		    //Posiciona pelo L1_ORCRES para obter o pedido do orcamento para bloquear o credito.
				cPedido	 := Posicione("SL1",14,xFilial("SL1", cFilTit)+SL1->L1_NUM,"L1_PEDRES") 
				
				MF5->( RecLock("MF5",.F.) )
				MF5->MF5_ECPAGO	:= "2"
				MF5->MF5_ECSTAT	:= "6"      //Ira avisar ao e-commerce que o pagamento do titulo foi cancelado.
				MF5->MF5_ECDTEX := DtoS(Date())
				MF5->( MsUnlock() )
			EndIf
		ElseIf lECommerce .AND. lECCia 
			//Localiza o Pedido       
			cPedido := SL1->L1_PEDRES
			aAreaSC5 := SC5->(GetArea())
			
			cStatus :=  Posicione("SC5",1,xFilial("SC5", cFilTit)+SL1->L1_PEDRES,"C5_STATUS") 			
	
			If Empty(SC5->C5_NOTA)
				RecLock( "SC5", .F.)
				SC5->C5_STATUS := "05" //Pedido em análise
				SC5->C5_VOLTAPS := "" //
				SC5->(MsUnLock())
			EndIf
 			lSemNota := Empty(SC5->C5_NOTA)
			RestArea(aAreaSC5)			
		EndIf
	EndIf
	
	//|_________________________________________________
	//|
	//|Bloqueio do Pedido de Venda pelo cancelamento da baixa do titulo.
	//|_________________________________________________
	If  !( Empty(cPedido) ) .AND. (!lECCia .OR. lSemNota )
		//Muda a filial no caso de estorno de baixa de título de outra filial
	
		If lAltFil
			aAreaSM0 := SM0->(GetArea())
			cFilBkp	:= cFilAnt
			cFilAnt := cFilTit
		EndIf
		
	    For nA := 1 to 2
	    	aRegSC6 := {}
	    	nVlrLiber := 0
	    	aRecSC9 := {}
			dbSelectArea("SC9")
			dbSetOrder(3)//C9_FILIAL+C9_PEDIDO+C9_GRUPO+C9_PRODUTO
		
			If  DbSeek(xFilial("SC9", cFilTit)+cPedido)
				While !( Eof() ) .And. (C9_FILIAL+C9_PEDIDO == xFilial("SC9",cFilTit)+cPedido)
					
					If lECCia // Verifica o Bloqueio do estoque nos itens		    	
		    			SC6->(dbSetOrder(1))
						If SC6->(MsSeek(xFilial("SC6", cFilTit)+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)) .And. ( Len(aRegSC6) == 0  .Or. Ascan(aRegSC6, {|x| x == SC6->(RecNo()) })  == 0 )                     
							aadd(aRegSC6,SC6->(RecNo()))
							nVlrLiber += SC6->C6_VALOR		    			 			    				  				
		    			EndIf 	
		    			aAdd(aRecSC9, SC9->(Recno()))							    		
		    		Else
						RecLock("SC9",.F.)
						SC9->C9_BLCRED	:= "02"
						SC9->(MsUnlock())
		    		EndIf	
		    			    		
					SC9->(dbSkip())
				End
			EndIf
			
			If Len(aRegSC6) > 0
				dbSelectArea("SC5")
				dbSetOrder(1)
				dBSeek(xFilial("SC5", cFilTit)+cPedido)								
				MaAvalSC5("SC5",4,.F.,.F.,,,,,,cPedido,aRegSC6,.T.,.F.,@nVlrLiber)
				MaAvalSC5("SC5",3,.F.,.F.,,,,,,cPedido,aRegSC6,.T.,.F.,@nVlrLiber)
			EndIf	
					
			If  (nA >= 2)
			    Exit
			EndIf    
	
			dbSelectArea("SC5")
			dbSetOrder(1)//C5_FILIAL+C5_NUM
			dbSeek(xFilial("SC5", cFilTit)+cPedido)
			
			If  Eof() .Or. Empty(C5_ECVINCU)
			    Exit
			EndIf
			
			DbSeek(xFilial("SC5", cFilTit)+C5_ECVINCU)
			cPedido := C5_NUM
		Next nA	
		
		If lAltFil
			cFilAnt := cFilBkp
			RestArea(aAreaSM0)
		EndIf
	
	EndIf
	


End Sequence

RestArea(aAreaSC5)
RestArea(aAreaSC9)
RestArea(aAreaSL1)
RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ861JBPC ³ Autor ³  Antonio C Ferreira    ³ Data ³ 01/02/13       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Job para processar os preços dos produtos pela funcao LjxeValPre() ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lECJob - Se esta executando via Job ou pelo Protheus.              ³±±
±±³          ³cECEmpresa - Codigo da Empresa para a preparacao do ambiente       ³±±
±±³          ³cECFilial - Codigo da Filial para a preparacao do ambiente         ³±±
±±³          ³cECTarefa - Grupo de tarefa de execucao dos webservices.           ³±±
±±³          ³cECJob - Nome do Job que esta executando a rotina.                 ³±±
±±³          ³cECIntervalo - Intervalo para a execucao da rotina.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ861JBPC(lECJob, cECEmpresa, cECFilial, cECTarefa,;
                   cECJob, cECIntervalo)
              
Local lOk           := .T.      //Retorna falso caso ocorra algum erro na execucao. 
Local cArq          := ""             //Nome do arquivo que ira gerar no diretorio system do Protheus para o controle do tempo de execucao           
Local nA            := 0        //Contador para processar as empresas e filiais passadas pelos parametros do JOB.
Local nEmpresas     := 0        //Calcula a quantidade de empresas passadas pelos parametros do JOB.
Local cXEmpresa     := ""       //Codigo da empresa ou Grupo de Empresa a ser processado.
Local cXFilial      := ""       //Codigo da Filial a ser processado.
Local aEmps         := {}      //Empresas que serao processadas pelo Job. 

Local lDepurar      := (Type("cFilAnt") == "U")   //Se esta sendo depurado pelo DevStudio ou esta executando pelo Protheus.

Local cQuery        := ""            //Query para obter os produtos e-commerce para processar o preco de tabela.
Local nPrecoTab		:= 0             //Preco de tabela
Local cTabela       := ""            //Tabela de preco utilizada pelo e-Commerce (SB0).

Private cTabPad     := ""  //Variaveis criadas para evitar erro na funcao Lj7DefTab().
Private aPosCpoDet  := {}  //Variaveis criadas para evitar erro na funcao Lj7DefTab().
Private aColsDet    := {}  //Variaveis criadas para evitar erro na funcao Lj7DefTab().  
Private N           := 100 //Para ficar maior que aColsDet e não gerar erro na funcao Lj7DefTab().
               
DEFAULT lECJob     	:= "F"   
DEFAULT cECEmpresa 	:= "99"
DEFAULT cECFilial  	:= "01"
DEFAULT cECTarefa  	:= "A"
DEFAULT cECJob     	:= "JOB01"
DEFAULT cECIntervalo:= "02:00"

cArq := cECJob+".tmp"                  
                          
lECJob := (lECJob == "T")  //Passa para valor logico.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o intervalo venceu para poder executar o job.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  lECJob .And. !( LJ861Exec(cArq, cECJob, cECIntervalo) )
	    Return .T.  //Cancela a execucao antes de preparar o ambiente.
	EndIf    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a quantidade de empresas/filiais que devem ser processadas.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( LJ861Emps("LOJA861", cECEmpresa, cECFilial, @nEmpresas, @aEmps) )
	    Return .F.  //Cancela a execucao antes de preparar o ambiente.
	EndIf    

LjGrvLog( "", "LOJA861: LJ861JBPC: " + STR0043 + " Job: " + cECJob + " - " + Time())       //"Iniciando processamento dos preços dos produtos e-commerce!"

Begin Sequence
	
	For nA := 1 to nEmpresas
	
		cXEmpresa := aEmps[nA][1]
		cXFilial  := aEmps[nA][2]
	
		If  lECJob .Or. lDepurar
			RpcClearEnv()   //Caso tenha algum ambiente em aberto, fechar!
			
			LjGrvLog( "", "LOJA861: LJ861JBPC: " + STR0045 + cXEmpresa + "/" + cXFilial + " - " + Time())   //"Iniciando Empresa/Filial: "
			RpcSetType( 3 )
			If  !( RpcSetEnv( cXEmpresa, cXFilial,,,"LOJ" ) )
				LjGrvLog( "", "LOJA861: LJ861JBPC: " + STR0046)     //"Parametros de Empresa e Filial incorretos! Cancelando Execução!"
				lOk := .F.
				Break
			EndIf 	
		ElseIf (nA > 1)
			Exit         //Caso nao seja Job devera sair para nao processar mais de uma vez na mesma empresa e filial.
		EndIf	
		
		//Define a tabela e-Commerce
		cTabPad := AllTrim(SuperGetMV("MV_LJECOMT",,SuperGetMV("MV_TABPAD")))  
		cTabela := cTabPad

		//------------------ Produtos e-Commerce simples sem B1_PRODPAI -----------------------------
		cQuery := " SELECT SB0.B0_COD "
		cQuery += " FROM " + RetSQLName("SB1") + " SB1, " + RetSQLName("SB5") + " SB5, " + RetSQLName("SB0") + " SB0, " 
		cQuery +=   RetSQLName("SA5") + " SA5, " + RetSQLName("SA2") + " SA2 "
		cQuery += " WHERE SB1.B1_COD     =  SB0.B0_COD "      //Amarracao tabela de preço
		cQuery += " AND   SB1.B1_COD     =  SB5.B5_COD "      //Amarracao Complemento do Produto
		cQuery += " AND   SB1.B1_COD     =  SA5.A5_PRODUTO "  //Amarracao com o Fornecedor 
		cQuery += " AND   SA5.A5_FORNECE =  SA2.A2_COD "      //Amarracao com o Fornecedor
		cQuery += " AND   SA5.A5_LOJA    =  SA2.A2_LOJA "     //Amarracao com o Fornecedor
		cQuery += " AND   SB1.B1_FILIAL  =  " + ValToSQL(xFilial("SB1"))
		cQuery += " AND   SB0.B0_FILIAL  =  " + ValToSQL(xFilial("SB0"))
		cQuery += " AND   SB5.B5_FILIAL  =  " + ValToSQL(xFilial("SB5"))
		cQuery += " AND   SA5.A5_FILIAL  =  " + ValToSQL(xFilial("SA5"))
		cQuery += " AND   SA2.A2_FILIAL  =  " + ValToSQL(xFilial("SA2"))
		cQuery += " AND   SB1.B1_PRODPAI =  '' "              //Sem Produto Pai - Produto simples
		cQuery += " AND   SA2.A2_ECFLAG  <> '' "              //Fornecedor e-Commerce
		cQuery += " AND   SA5.A5_ECFLAG  <> '' "              //Amarracao FornecedorXProduto e-Commerce
		cQuery += " AND   SB5.B5_ECFLAG  <> '' "              //Complemento do Produto e-Commerce
		cQuery += " AND   SB5.B5_ECSEQ   <> '' "              //Ja enviado para o e-Commerce
		cQuery += " AND   SB0.D_E_L_E_T_ =  '' " 
		cQuery += " AND   SB1.D_E_L_E_T_ =  '' " 
		cQuery += " AND   SA5.D_E_L_E_T_ =  '' " 
		cQuery += " AND   SB5.D_E_L_E_T_ =  '' " 
		cQuery += " AND   SA2.D_E_L_E_T_ =  '' " 
		cQuery += " GROUP BY SB0.B0_COD " 
		cQuery += " UNION ALL "         
		//------------------ Produtos e-Commerce SKUs com B1_PRODPAI -----------------------------
		cQuery += " SELECT SB0.B0_COD "
		cQuery += " FROM " + RetSQLName("SB1") + " SB1 LEFT OUTER JOIN " + RetSQLName("SB5") + " SB5 "
		cQuery += " ON (SB1.B1_PRODPAI = SB5.B5_COD), " + RetSQLName("SB0") + " SB0, "
		cQuery +=   RetSQLName("SA5") + " SA5, " + RetSQLName("SA2") + " SA2 "
		cQuery += " WHERE SB1.B1_COD     =  SB0.B0_COD "       //Amarracao tabela de preço
		cQuery += " AND   SB1.B1_COD     =  SA5.A5_PRODUTO "   //Amarracao com o Fornecedor 
		cQuery += " AND   SA5.A5_FORNECE =  SA2.A2_COD "       //Amarracao com o Fornecedor 
		cQuery += " AND   SA5.A5_LOJA    =  SA2.A2_LOJA "      //Amarracao com o Fornecedor 
		cQuery += " AND   SB1.B1_FILIAL  =  " + ValToSQL(xFilial("SB1"))
		cQuery += " AND   SB0.B0_FILIAL  =  " + ValToSQL(xFilial("SB0"))
		cQuery += " AND   SB5.B5_FILIAL  =  " + ValToSQL(xFilial("SB5"))
		cQuery += " AND   SA5.A5_FILIAL  =  " + ValToSQL(xFilial("SA5"))
		cQuery += " AND   SA2.A2_FILIAL  =  " + ValToSQL(xFilial("SA2"))
		cQuery += " AND   SB1.B1_PRODPAI <> '' "              //Com Produto Pai - SKU
		cQuery += " AND   SA2.A2_ECFLAG  <> '' "              //Fornecedor e-Commerce
		cQuery += " AND   SA5.A5_ECFLAG  <> '' "              //Amarracao FornecedorXProduto e-Commerce
		cQuery += " AND   SB5.B5_ECFLAG  <> '' "              //Complemento do Produto e-Commerce
		cQuery += " AND   SB5.B5_ECSEQ   <> '' "              //Ja enviado para o e-Commerce
		cQuery += " AND   SB0.D_E_L_E_T_ =  '' " 
		cQuery += " AND   SB1.D_E_L_E_T_ =  '' " 
		cQuery += " AND   SA5.D_E_L_E_T_ =  '' " 
		cQuery += " AND   SB5.D_E_L_E_T_ =  '' " 
		cQuery += " AND   SA2.D_E_L_E_T_ =  '' " 
		cQuery += " GROUP BY SB0.B0_COD " 
		
		If  (Select("TMPSB0") > 0)
			TMPSB0->( DbCloseArea() )
		EndIf	
	
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Obtem os dados executando a query.                                        ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbUseArea(.T., "TOPCONN", TcGenQry(Nil, Nil, cQuery), "TMPSB0", .F., .T.)
		
		lECLJAUTO   := .T.  //Seta auto para identificar o processamento e-Commerce na funcao LjxeValPre()
		
		While !( Eof() )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processa os preços pela função do padrao LjxeValPre()  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			LjGrvLog( "", "[LOJA861 04/02/2014 10:40] - Atualizando preços")
			If  LjxeValPre(@nPrecoTab, TMPSB0->B0_COD /*cProduto*/, /*cCliente*/, /*cLoja*/, /*nMoeda*/   , /*nQtdade*/ , /*lProdON*/ )		
			
				SB0->( DbSetOrder(1) )
				SB0->( DbSeek(xFilial("SB0")+TMPSB0->B0_COD) )
	
				If  SB0->( (FieldGet(FieldPos("B0_PRV"+cTabela)) != nPrecoTab) .And. SoftLock("SB0") ) 
					LjGrvLog( "", "[LOJA861 04/02/2014 10:40] - Atualizando preços produto [" + TMPSB0->B0_COD + "] de " + Str(SB0->( (FieldGet(FieldPos("B0_PRV"+cTabela)) )), 14,2)+ "por " + Str(nPrecoTab, 14,2))
					SB0->( FieldPut(FieldPos("B0_PRV"+cTabela), nPrecoTab) )  //Grava o preco na tabela e-Commerce
					SB0->( MsUnLock() )
				EndIF
			
			EndIf	
			
			DbSelectArea("TMPSB0")
			DbSkip()
			
		End
		
		lECLJAUTO   := .F.  //Reseta para falso.
		
		TMPSB0->( DbCloseArea() )
	
	Next nA
	
End Sequence

If  lECJob .Or. lDepurar
	RpcClearEnv()
          
	If  lECJob .And. lOk
		MemoWrit(cArq,DtoS(Date())+','+Time())
	EndIf	
EndIf

LjGrvLog( "", "LOJA861: LJ861JBPC: " + STR0047 + " - " + Time())   //"Finalizando o processo!"

Return lOk              


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj861PedRe ³ Autor ³  Vendas CRM            ³ Data ³ 01/02/13      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o Pedido Reserva (SC5) Gerado                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cL1_OrcRes- Orcamento de Origem.                                   ³±±
±±³          ³cPed_Res - Pedido de Reserva                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj861PedRe(cL1_OrcRes, cPed_Res)

Local aArea := GetArea()
Local aAreaSL1 := SL1->(GetArea())

Default cL1_NUM := ""  

SET DELETED ON
SL1->(DbSetOrder(14)) //Filial + OrcRes

If SL1->( DbSeek(xFilial("SL1") + cL1_OrcRes) )

	cPed_Res := SL1->L1_PEDRES
EndIf 

SET DELETED OFF
RestArea(aAreaSL1)  
RestArea(aArea)

Return cPed_Res

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj861FilAli³ Autor ³  Vendas CRM            ³ Data ³30/04/2014     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna as filiais da Empresa                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias - Alias do arquivo                                          ³±±
±±³          ³cFilEC - Filial e-commerce                                         ³±±
±±³          ³cUnFilEC - Unidade de Negócio e-commerce                           ³±±
±±³          ³cGrpFilEC - Grupo de Empresas e-commerce                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj861FilAli(cAlias, aFilEC, cUnFilEC,  cGrpFilEC)
Local aFilRet 				:= {}	//Retorno da Função
Local nModeAccess 		:= 3	//Modo de acesso
Local cModo 				:= "C"	//Modo de compartilhamento
Local nC 					:= 1	//Contador
Local cGrpTmp 				:= ""	//Grupo de empresas
Local cUniTmp 				:= ""	//Unidade de negócio
Local aDados 				:= {}	//Dados	
Local nLayoutEmp 			:= Len(FWSM0Layout(,1))	//Lay-out da Empresa
Local nLayoutUni 			:= Len(FWSM0Layout(,2))	//Lay-out da Unidade
Local nTam 				:= Len(xFilial(cAlias))  //Lay-out da filial (xfilial)

Default cAlias := ""  //Alias a verificar o compartilhamento
Default aFilEC := {}    //Filiais do Job EC   
Default cUnFilEC := "" //Unidade de negócio do Job
Default cGrpFilEC := ""//Grupo de filiais do Job

Do While (nModeAccess > 0 .AND. cModo == "C")
	cModo := FWModeAccess(cAlias, nModeAccess)
	nModeAccess--
EndDo

nModeAccess++

If nModeAccess == 3 .AND. cModo == "E"
	aFilRet := {xFilial(cAlias)}
Else
	//Mode = 2 ou mode = 3
	For nC := 1 to Len(aFilEC)
		cGrpTmp := Left(aFilEC[nC],nLayoutEmp) 
		cUniTmp := Substr(aFilEC[nC], nLayoutEmp+1, nLayoutUni)
		If cGrpTmp == cGrpFilEC
			If nModeAccess == 2 .AND. cUniTmp <> cUnFilEC
				Loop
			EndIf
			aAdd(aFilRet, PadR(aFilEC[nC], nTam))
		Else
			Loop
		EndIf
	Next
EndIf

Return aFilRet    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj861PrFab³ Autor ³  Vendas CRM            ³ Data ³11/08/2014      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o fornecedor assiciado ao Produto                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias - Alias do arquivo                                          ³±±
±±³          ³cFilEC - Filial e-commerce                                         ³±±
±±³          ³cUnFilEC - Unidade de Negócio e-commerce                           ³±±
±±³          ³cGrpFilEC - Grupo de Empresas e-commerce                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   

Function Lj861PrFab(cZFilial, cCodProd)  

Local cRet := "" //Retorno da Rotina
Local cSA5Fil := xFilial("SA5")   //Filial SA5

Default cZFilial := ""
Default cCodProd := " 


SET DELETED ON

SA5->( DbSetOrder(2)) //A5_FILIAL + A5_PRODUTO    
SA5->( DbSeek( cSA5Fil + cCodProd))

Do While SA5->(!Eof() .AND. RTrim(A5_FILIAL + A5_PRODUTO) == RTrim(cSA5Fil + cCodProd))
	If SA5->A5_ECFLAG <> ' '
		cRet := cZFilial + SA5->(A5_FORNECE + A5_LOJA)
		Exit
	EndIf 
	SA5->(DbSkip(1))
EndDo

SET DELETED OFF   

Return cRet 

/*/{Protheus.doc} Lj861VlSC5
	Valida se tem SC5 para o orçamento
	@type  Function
	@author Julio.Nery
	@since 20/08/2020
	@version P12
	@param aRetRec, array, retorno com o recno da SC5
	@return lTemSC5, lógico, Achou SC5?
/*/
Function Lj861VlSC5(aRetRec)
Local aArea		:= {}
Local aGArea	:= {}
Local aRecnos	:= {}
Local lTemSC5	:= .F.
Local nX		:= 0

If SL1->(ColumnPos("L1_PEDRES")) > 0
	aGArea := GetArea()
	Aadd(aArea,SC5->(GetArea()))
	
	SC5->(dbSetOrder(1)) //C5_FILIAL + C5_NUM
	If !Empty(AllTrim(SL1->L1_PEDRES)) .And.;
		SC5->(dbSeek(SL1->L1_FILIAL + SL1->L1_PEDRES))
		Aadd(aRecnos,SC5->(Recno()))
	EndIf	

	For nX := 1 to Len(aArea)
		RestArea(aArea[nX])
	Next nX
	RestArea(aGArea)

	If Len(aRecnos) > 0
		aRetRec := aClone(aRecnos)
		lTemSC5 := .T.
	EndiF
EndIf

Return lTemSC5
