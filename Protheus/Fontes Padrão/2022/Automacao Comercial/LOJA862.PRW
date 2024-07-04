#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include "TOPCONN.CH"
#Include "AP5MAIL.CH"
#Include "TBICONN.CH"
#Include "PROTHEUS.CH"                                                                                                        
#INCLUDE "LOJA862.CH"     

#Define _ECSTATUS_CANCELADO "4|5|8"

Static aXPrincipal  := {}   //Dados da tabela principal ou de cabecalho
Static aXItem       := {}   //Dados dos itens
Static aXIndice     := {}   //Dados do indice para localizar os registros para alteracao dos dados
Static aXMatriz     := {}   //Dados de todas as tabelas envolvidas que serao utilizados em funcoes especificas para cadastros complexos.

Static lECLJAUTO   := .F.      //Execauto para e-Commerce

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LOJA862  º Autor ³ Antonio C Ferreira º Data ³  08/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Processamto de job para recebimento de Dados via WebServiceº±±
±±º          ³ Importação                                                 º±±
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

Function LOJA862(lECJob, cECEmpresa, cECFilial, cECTarefa,;
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
DEFAULT cECIntervalo:= "00:02"

cArq := cECJob+".tmp"                   
                          
lECJob := (lECJob == "T")  //Passa para valor logico.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o intervalo venceu para poder executar o job.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  lECJob .And. !( LJ862Exec(cArq, cECJob, cECIntervalo) )
	    Return .T.  //Cancela a execucao antes de preparar o ambiente.
	EndIf    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a quantidade de empresas/filiais que devem ser processadas.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( LJ861Emps("LOJA862", cECEmpresa, cECFilial, @nEmpresas, @aEmps) )
	    Return .F.  //Cancela a execucao antes de preparar o ambiente.
	EndIf    

ConOut("LOJA862: " + STR0001 + " Job: " + cECJob + " - " + Time() + " [VERSION 06/03/2014 11:42]")  //"Iniciando processamento de Importação!"
//Solicitação GDP 29/07/2014
FWLSEnable(3118)


Begin Sequence
	
	For nA := 1 to nEmpresas
	
		cXEmpresa := aEmps[nA][1]
		cXFilial  := aEmps[nA][2]
	
		If  lECJob .Or. lDepurar
			RpcClearEnv()   //Caso tenha algum ambiente em aberto, fechar!
			
			ConOut("LOJA862: " + STR0064 + cXEmpresa + "/" + cXFilial + " - " + Time() )  //"Iniciando Empresa/Filial: "
			RpcSetType( 3 )
			If  !( RpcSetEnv( cXEmpresa, cXFilial,,,"LOJ" ) )
				ConOut("LOJA862: " + STR0065)    //"Parametros de Empresa e Filial incorretos! Cancelando Execução!"
				lOk := .F.
				Break
			EndIf 	
		ElseIf (nA > 1)
			Exit         //Caso nao seja Job devera sair para nao processar mais de uma vez na mesma empresa e filial.
		EndIf	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se é release 5.11 ou superior.                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  !( GetRpoRelease("R5") )
			ConOut("LOJA862: " + STR0060) //"e-Commerce irá funcionar apenas para Release 11.5 e superior!"
			Break
		EndIf
	
		DbSelectArea("MDY")
		DbSetOrder(1)  //MDY_FILIAL+MDY_ECFLAG+MDY_ECSEQ
		
		DbSeek(xFilial("MDY")+"A"+cECTarefa)
		
		While !( Eof() ) .And. (MDY_FILIAL+MDY_ECFLAG+MDY_ECTARF == xFilial("MDY")+"A"+cECTarefa)
		  
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Interrupcao pelo parametro MV_LJECOMX                                     ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  (SuperGetMV("MV_LJECOMX",,"1") == "0")  //0=Nao executar / 1=Executar
		        ConOut("LOJA862: " + STR0003 + " Job: " + cECJob)   //"Execução interrompida pelo parâmetro MV_LJECOMX!"
		        Break
		    EndIf    
	
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Processa os ativos                                                        ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			LJ862Inter(cECJob)  //Processa com o MDY posicionado, podendo ser utilizado tambem por outras rotinas.
		
			DbSkip()
		End	
	
	Next nA

End Sequence	
    
If  lECJob .Or. lDepurar
	RpcClearEnv()
          
	If  lECJob .And. lOk
		MemoWrit(cArq,DtoS(Date())+','+Time())
	EndIf	
EndIf                  

ConOut("LOJA862: " + STR0066 + " - " + Time())   //"Finalizando o processo!"

Return lOk


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862Exec º Autor ³ Antonio C Ferreira º Data ³  05/02/12   º±±
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

Static Function LJ862Exec(cArq, cECJob, cECIntervalo)

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
    If !Empty(cTempAnt)
    	aTemp    := &("{'" + StrTran(cTempAnt,",","','") + "'}")
    EndIf
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
±±ºPrograma  ³LJ862Interº Autor ³ Antonio C Ferreira º Data ³  08/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gravacao da Tabela Intermediaria dos dados a serem         º±±
±±º          ³ importados via webservices. MDY posicionado.               º±±
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

Function LJ862Inter(cECJob, aParams)
   
Local aAreaSav	     := GetArea()                  //Salva a area atual
Local lRet           := .T.                        //Retorna verdadeiro caso nao ocorra problema no processo
Local cAlias	     := Alltrim(MDY->MDY_ECALIA)   //Alias principal de importacao
Local cSequencia     := ""                         // Codigo sequencial da tabela intermediaria       	
                         
Local cWebService    := Alltrim(MDY->MDY_ECWS)    //WebServiceda da importacao
Local cMetodo        := Alltrim(MDY->MDY_ECMETO)  //Metodo da importacao
Local oObj           := nil                        //Objeto que ira processar o webservice/metodo da importacao
Local bMetodo        := &("{|| oObj:" + cMetodo + "() }")  //CodBlock que ira processar o webservice/metodo da importacao
                    
Local bRetorno       := nil                        //CodBlock que ira processar o retorno do webservice/metodo da importacao
Local cGRetorno      := ""                         //String com os dados do retorno do webservice/metodo para gravar na intermediaria ou log de erro

Local bOldError      := ErrorBlock( {|x| LOJ862Erro(x, @cMensagem) } ) // muda code-block de erro
Local cMensagem      := ""                         //Mensagem de erro no processamento
Local cDescricao     := ""                         //Descricao do erro na execucao do webservice/metodo

Local lIntermediaria := .F.                       //Se ira gerar ou nao a intermediaria 
Local cXML           := ""                        //XML retornado pelo webservice/metodo
Local cXML2          := ""                        //variavel auxiliar para processar o XML
Local nA             := 0                         //Contador do comando For
Local nLenaLista     := 0                         //Tamanho da matriz aLista
Local cMetCondicao   := Alltrim(MDY->MDY_ECCNDM) //Condicao para validar o retorno do metodo
Local bCondMetodo    := nil                       //CodBloc para executar a Condicao para validar o retorno do metodo
Local bCondValida    := &("{|xxPos| " + Alltrim(MDY->MDY_ECCOND) + " }")  //Condicao para validar se os dados do XML estao ok para gravacao
Local bChave         := &("{|xxPos| " + Alltrim(MDY->MDY_ECCHAV) + " }")  //Obtem a chave do XML para verificar se ja gerou a tabela intermediaria

Local aEmps          := {}                        //Empresas que serao processadas pelo Job. 
Local cPrograma      := ""                        //Nome do programa que contem o WS

Local aAreaMEZ		   := NIL

DEFAULT cECJob   := ""
DEFAULT aParams  := {}
                                                                                                     
Begin Sequence

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Erro ao montar os codblocks acima. Se tiver uma linha em branco           ³
 //³ no final do memo(um ENTER) pode ocasionar erro.                           ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If  !( Empty(cMensagem) )
    	Break
    EndIf	

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Interrupcao pelo parametro MV_LJECOMX                                     ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  (SuperGetMV("MV_LJECOMX",,"1") == "0")  //0=Nao executar / 1=Executar
        ConOut("LOJA862: LJ862EComm: " + STR0003 + " Job: " + cECJob)  //"Execução interrompida pelo parâmetro MV_LJECOMX!"

        If  Empty(cECJob)
        	Aviso(STR0002, STR0003,{"Ok"})  //"Mensagem do Usuário"##"Execução interrompida pelo parâmetro MV_LJECOMX!"
        EndIf
        
        Break
    EndIf    

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Obtem a query condicionada para o filtro dos dados.                       ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MEY")
	DbSetOrder(1) //MEY_FILIAL+MEY_ECSEQ
	
	DbSelectArea(cAlias)
	DbSetOrder(Val(MDY->MDY_ECIND))
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cria o objeto para utilizacao do webservice e verifica as entradas.	   ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj := &("WS" + cWebService + "():NEW()")  //Cria o objeto do WebService
	
	ConOut("LOJA862: LJ862Inter: " + "Processando o WebService - início " + cWebService + "/" + cMetodo + Dtos(Date()) + " - " + Time())
        
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Caso esteja definido no ini nova localizacao para WS sera configurado abaixo. ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPrograma    := cWebService + ".asmx"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem o endereco do WS no arquivo de configuracao intecomm.ini            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( LJ861Emps("LOJA862", cEmpAnt, cFilAnt,, @aEmps) )
	    cMensagem := "LOJA862: LJ862Inter: " + STR0067    //"Problema na configuração do arquivo intecomm.ini!"
	    Break
	EndIf    

    oObj:_Url := aEmps[1][3]+cPrograma //Configura o endereco do WS para o grupo de empresa/filial.
	
    If  !( LJ862Entradas(@oObj, MDY->MDY_ECPARO, @cMensagem) )   
    	ConOut("LOJA862: LJ862Inter: " + "Problema ao processar as entradas do job " + cWebService + "/" + cMetodo)
    	lRet := .F.
    	Break
    EndIf

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Executa o metodo.	                                                       ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( Eval(bMetodo) )
		cMensagem := STR0004 + cWebService + "/" + cMetodo   //"Problema na execução do Webservice/Metodo: "
	
		If  !( Empty(GetWSCError(3)) )
			cMensagem += CRLF + SubStr( GetWSCError(3), At(":", GetWSCError(3) ) + 1 )
		EndIf
		
		ConOut("LOJA862: LJ862Inter: " +  cMensagem + " Validacao do Metodo [" + cMetodo + "]")
		
		Break
	EndIf

	If  !( Empty(cMetCondicao) )
		bCondMetodo := &("{|| " + AllTrim(cMetCondicao) + " }")
	    If  !( Eval(bCondMetodo) )                                                                            
	        cDescricao := Eval(&("{|| oObj:oWS"+cMetodo+"Result:cDescricao }"))
	        
	        If  !("NENHUM" $ Upper(cDescricao))
	     	    cMensagem := STR0004 + cWebService + "/" + cMetodo + CRLF + cDescricao    //"Problema na execução do Webservice/Metodo: "
	     	EndIf 
	     	
	     	ConOut("LOJA862: LJ862Inter: " +  cMensagem + " Condicao do Metodo ["+cMetCondicao+"]")   
	     	Break
	    EndIf
	EndIf     	

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Obtem XML e separa o block de cada registro e grava na intermediaria.     ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cXML := StrTran(StrTran(WSGetCXmlREt(), chr(13), ''), chr(10), '')
	
	If  Empty(cXML)
		cMensagem := STR0005 + cWebService + "/" + cMetodo    //"Problema na obtenção do XML do WebService/Metodo: "  
		ConOut("LOJA862: LJ862Inter: " +  cMensagem + " Falha na estrutura do XML 1 ")   
		Break
	EndIf
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Separa o bloco da lista de dados.                                         ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cBlocoFin := Alltrim(MDY->MDY_ECTAGB)
	cBlocoIni := StrTran(cBlocoFin, "/", "")

    nPos  := At(cBlocoIni, cXML)

	cXML2 := SubStr(cXML, nPos+Len(cBlocoIni))

    nPos  := At(cBlocoFin, cXML2)

    cXML2 := Left(cXML2, nPos-1)

	If  Empty(cXML2)
		cMensagem := STR0006 + cWebService + "/" + cMetodo    //"Problema na obtenção do XML do Bloco de Lista de dados do WebService/Metodo: "
		ConOut("LOJA862: LJ862Inter: " +  cMensagem + " Falha na estrutura do XML 2 ") 
		Break
	EndIf
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta a matriz da lista dos dados recebidos.                              ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cBlocoFin := Alltrim(MDY->MDY_ECTAGU)
	cBlocoIni := StrTran(cBlocoFin, "/", "") 

	cLista := StrTran(StrTran(StrTran(cXML2, "'", " "), cBlocoIni, "{'"+cBlocoIni), cBlocoFin, cBlocoFin+"'},")
	cLista := Left(cLista, Len(cLista)-1)

	aLista := &("{" + cLista + "}")

	If  (Len(aLista) <= 0)
		cMensagem := STR0007 + cWebService + "/" + cMetodo    //"Problema na obtenção da Lista de dados do WebService/Metodo: " 
		ConOut("LOJA862: LJ862Inter: " +  cMensagem + " Falha na estrutura do XML aLista ") 
		Break
	EndIf

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Processa a lista de dados e grava a intermediaria.                        ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    nLenaLista := Len(aLista)
    
    For nA := 1 to nLenaLista
    
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Condicao para gravar o XML.                                               ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	If  !( Empty(MDY->MDY_ECCOND) ) .And. !( Eval(bCondValida, nA) )   
    		If !Empty(cChave := Alltrim(Eval(bChave, nA)))
    			ConOut( "LOJA862: LJ862Inter: " + " Registro não gravado pois não atende à condição de validacao [" + MDY->MDY_ECCOND + "] e não processado. Chave EC: [" +  cChave  + "]")
    	  		cChave := ""
    	    EndIf
    	  	Loop
    	EndIf    

	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Verifica se o XML ja foi gravado na intermediaria.                        ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	    cChave := Alltrim(Eval(bChave, nA))
    	    
   	    MEY->( DbSetOrder(4) )  //MEY_FILIAL+MEY_ECFLAG+MEY_ECWS+MEY_ECMETO+MEY_ECCCHV
    	    
   	    If  MEY->( DbSeek(xFilial("MEY") + "A" + PadR(cWebService,Len(MEY->MEY_ECWS)) + PadR(cMetodo,Len(MEY->MEY_ECMETO)) + cChave) )  .Or. ;
   	    	MEY->( DbSeek(xFilial("MEY") + "Z" + PadR(cWebService,Len(MEY->MEY_ECWS)) + PadR(cMetodo,Len(MEY->MEY_ECMETO)) + cChave) )
   	    	
			ConOut( "LOJA862: LJ862Inter: " + " Registro  já existe na tabela [" + "MEY" + "] e não gravado. Chave: [" + MEY->( & (IndexKey())) + "]")
			Loop  
			 	    	
   	    ElseIf MEY->( DbSeek(xFilial("MEY") + "E" + PadR(cWebService,Len(MEY->MEY_ECWS)) + PadR(cMetodo,Len(MEY->MEY_ECMETO)) + cChave) ) 
   	    		
   	    		If AllTrim(MEY->MEY_ECXML) <> AllTrim(aLista[nA][1]) //XML diferente, então deleta o registro   
   	    		
   	    	   	    		
	   	    		//Apaga o Log de Erro, para não ficar sujeira
	   	    		aAreaMEZ		   := MEZ->(GetArea())
	   	    		MEZ->(DbSetOrder(3)) //MEZ_FILIAL + MEZ_ECSEQ
	   	    		If !Empty(MEY->MEY_ECERRO) .And. MEZ->(DbSeek(xFilial("MEZ")+MEY->MEY_ECERRO)) .And. RecLock("MEZ", .F.)
	   	    			MEZ->(DbDelete())
	   	    			MEZ->(MsUnLock())
	   	    		EndIf   	    			   	    		
	   	    		RestArea( aAreaMEZ)
	   	    		
	   	    		If RecLock("MEY", .F.)
	   	    			MEY->(DbDelete())
	   	    			MEY->(MsUnLock())
	   	    		Else   	    	
		 				ConOut( "LOJA862: LJ862Inter: " + " Registro  já existe na tabela [" + "MEY" + "] e não gravado. Chave: [" + MEY->( & (IndexKey())) + "] - registro ignorado pois já esta bloqueado por outro usuário/job")
						Loop   	    	
		   	   		EndIf 
		   	    Else 
					ConOut( "LOJA862: LJ862Inter: " + " Registro  já existe na tabela [" + "MEY" + "] e não gravado. Chave: [" + MEY->( & (IndexKey())) + "]  - XML idêntico ao enviado anteriormente.")
					Loop  
		   	    
		   	    EndIf
 		EndIf
    
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Obtendo o numero sequencial.                                              ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSequencia := GetSx8Num("MEY","MEY_ECSEQ")
		ConfirmSX8()
		       
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Gravando a Tabela Intermediaria para registrar a pendencia.               ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MEY->( RecLock("MEY", .T.) )
		                                                                       
		MEY->MEY_FILIAL := xFilial("MEY")
	    MEY->MEY_ECFLAG := "A"  //A-Em Aberto / E-Erro / X-Finalizado 
		MEY->MEY_ECNVL  := MDY->MDY_ECNVL		
		MEY->MEY_ECSEQ  := cSequencia
		MEY->MEY_ECWS   := cWebService
		MEY->MEY_ECMETO := cMetodo
		MEY->MEY_ECALIA := cAlias
		MEY->MEY_ECIND  := MDY->MDY_ECIND
		MEY->MEY_ECCCHV := cChave
		MEY->MEY_ECVCHV := ""
		MEY->MEY_ECDATA := Date()
		MEY->MEY_ECHORA := Time()
		MEY->MEY_ECXML  := aLista[nA][1]
		
		MEY->( MsUnLock() )                                       
		
	Next nA	
              
End Sequence   

ConOut("LOJA862: LJ862Inter: " + "Processando o WebService - Final " + cWebService + "/" + cMetodo + Dtos(Date()) + " - " + Time())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento de erro de execucao.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  !( Empty(cMensagem) )
	LJ862LogErro(lIntermediaria, cWebService, cMetodo, cECJob, cMensagem)
EndIf

RestArea( aAreaSav )
ErrorBlock( bOldError )   //Volta ao tratamento de erro padrao.
           
Return lRet		


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862Entradasº Autor ³ Antonio C Ferreira º Data ³  08/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Prepara o objeto do webservice com os dados de entrada.       º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oObj - Objeto que processa o webservice/metodo da importacao  º±±
±±º          ³ cParametros - Parametros necessarios para o webservice/metodo º±±
±±º          ³ cMensagem - Mensagem de erro no processo de importacao        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862Entradas(oObj, cParametros, cMensagem)
                                                                     
Local aArea          := GetArea()  //Salva a area atual
Local lRet           := .T.        //Retorna verdadeiro caso o processo ocorreu sem problema
Local nA             := 0          //Contador do comando For
Local nLenAEntradas  := 0          //Tamanho de aEntradas
Local aParametro     := {}        //Vetor com os parametros de entrada do webservice/metodo
Local bParametro     := nil       //Codbloq que ira processar o parametro de entrada alimentando oObj

Default oObj        := nil
Default cParametros := ""
Default cMensagem   := ""

Begin Sequence

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Obtem cada linha do parametro para executar e retornar um valor.          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aParametro := &("{'" + StrTran(StrTran(Alltrim(cParametros),chr(10),""),chr(13),"','") + "'}")
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Processa cada linha, alimentando os parametros de entrada em oObj.        ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nA := 1 to Len(aParametro)
	    
	    If  Empty(aParametro)
	        Loop
	    EndIf    
	
	    bParametro := &( "{|| " + aParametro[nA] + " }" )
	    
	    Eval(bParametro)
	    
	Next nA
	
End Sequence

If  !( Empty(cMensagem) )
	cMensagem := STR0008 + CRLF + cMensagem      //" Problema nas entradas do webservice: "
EndIf

RestArea(aArea)
        	
Return Empty(cMensagem)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJ862Erroº Autor ³ Antonio C Ferreira º Data ³  08/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para processar o erro de execucao das rotinas.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LOJ862Erro(e, cMensagem)

Begin Sequence

	If  (ValType(e) != "O") .Or. (e:gencode <= 0)
		Break
	EndIf

	cMensagem += STR0009 + e:ERRORSTACK + CRLF           //"CODIGO DO ERRO:"
	cMensagem += STR0010 + e:DESCRIPTION                 //"DESCRICAO DO ERRO:"

End Sequence

Return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862LogErroº Autor ³ Antonio C Ferreira º Data ³  08/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gravacao do log de erro da importacao.                       º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lIntermediaria - Se utiliza a tabela intermediaria.          º±±
±±º          ³ cWebService  - WebService para a importacao                  º±±
±±º          ³ cOrdem  - Codigo da Ordem de execucao dos metodos            º±±
±±º          ³ cChave  - Chave do alias principal do processo.              º±±
±±º          ³ cMetodo  - Metodo para a importacao                          º±±
±±º          ³ cECJob  - Nome do job que esta executando a rotina           º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862LogErro(lIntermediaria, cWebService, cMetodo, cECJob,;
                             cMensagem)

Local aArea      := GetArea()    //Salva a area atual
Local cSequencia := ""           //Codigo Sequencial do registro de log de erro.
Local lRegNovo   := .T.          //Se cria registro novo ou trava um existente.
    
DbSelectArea("MF4")
DbSetOrder(3) //MF4_FILIAL+MF4_ECSEQ

Default lIntermediaria := .F.
Default cWebService    := ""
Default cMetodo        := ""
Default cECJob         := ""
Default cMensagem      := ""

Begin Sequence
          
	Conout("...")
	ConOut(cMensagem)
	Conout("...")
        	       
	If  lIntermediaria .And. !( Empty(MEY->MEY_ECERRO) )

	    If  MEZ->( DbSeek(xFilial("MEZ")+MEY->MEY_ECERRO) .And. (MEZ_ECFLAG != "F") )
	    	cSequencia := MEZ->MEZ_ECSEQ
	    	lRegNovo   := .F.
	    EndIf

	EndIf

	If  Empty(cSequencia)	    
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Obtendo o numero sequencial do log de erro.                               ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSequencia := GetSx8Num("MEZ","MEZ_ECSEQ")
		ConfirmSX8()
	EndIf	
		
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Grava o registro do log de erro.                                          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MEZ")      
	
	RecLock("MEZ", lRegNovo)
	
	If lRegNovo
			MEZ->MEZ_FILIAL := xFilial("MEZ")
	EndIf
	
	MEZ->MEZ_ECFLAG := 'A' //ABERTO
	MEZ->MEZ_ECSEQ  := cSequencia
	MEZ->MEZ_ECWS   := cWebService
	MEZ->MEZ_ECMETO := cMetodo
	MEZ->MEZ_ECREFE := MEY->MEY_ECSEQ
	MEZ->MEZ_ECMENS := cMensagem  
	
	MEZ->MEZ_ECJOB  := cECJob
	MEZ->MEZ_ECDATA := Date()
	MEZ->MEZ_ECHORA := Time()



	
	MsUnLock()
                             
	If  lIntermediaria
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Grava os campos de controle da intermediaria.                             ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("MEY")   
		                                      
		If  !("LJ862Validar" $ cMensagem)  //Se for problema na validacao do metodo nao ira gravar como erro, ficara em aberto para validar novamente.
			MEY->MEY_ECFLAG := 'E' //ERRO
		EndIf	
		MEY->MEY_ECRET  := cMensagem  
		
		MEY->MEY_ECJOB  := cECJob
		MEY->MEY_ECDTE  := Date()
		MEY->MEY_ECHRE  := Time()
		
		MEY->MEY_ECERRO := cSequencia
		
		MsUnLock()
	EndIf	

End Sequence

RestArea(aArea)
        	
Return .T. 



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862ECommº Autor ³ Antonio C Ferreira º Data ³  08/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Leitura da Tabela Intermediaria dos dados a serem          º±±
±±º          ³ importados via webservices.                                º±±
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

Function LJ862EComm(lECJob, cECEmpresa, cECFilial, cECTarefa,;
                    cECJob, cECIntervalo)

Local lOk        := .T.      //Retorna falso caso ocorra algum erro na execucao. 
Local cArq       := ""       //Nome do arquivo que ira gerar no diretorio system do Protheus para o controle do tempo de execucao           
Local nA         := 0        //Contador para processar as empresas e filiais passadas pelos parametros do JOB.
Local nEmpresas  := 0        //Calcula a quantidade de empresas passadas pelos parametros do JOB.
Local cXEmpresa  := ""       //Codigo da empresa ou Grupo de Empresa a ser processado.
Local cXFilial   := ""       //Codigo da Filial a ser processado.
Local aEmps      := {}       //Empresas que serao processadas pelo Job. 

Local lDepurar   := (Type("cFilAnt") == "U")   //Se esta sendo depurado pelo DevStudio ou esta executando pelo Protheus.

Local lEmpresa   := .T.                //Variavel que indica que ira trava por empresa na funcao LockbyName()
Local lFilial    := .T.                //Variavel que indica que ira trava por filial na funcao LockbyName()
Local lUsaDisco  := .T.                //Variavel que indica que ira utilizar o disco na funcao LockbyName()

Local cNomeLock  := ""                 //Variavel que indica qual nome da trava na funcao LockbyName()

Local aExecutado := {}                //verifica se o registro da intermediaria ja executou no processo atual, caso positivo, sera ignorado.
Local cFlag		 := "A"
Local nConta	 := 1


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
	If  lECJob .And. !( LJ862Exec(cArq, cECJob, cECIntervalo) )
	    Return .T.  //Cancela a execucao antes de preparar o ambiente.
	EndIf    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a quantidade de empresas/filiais que devem ser processadas.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( LJ861Emps("LOJA862", cECEmpresa, cECFilial, @nEmpresas, @aEmps) )
	    Return .F.  //Cancela a execucao antes de preparar o ambiente.
	EndIf    

ConOut("LOJA862: LJ862EComm: " + STR0011 + " Job: " + cECJob + " - " + Time())    //"Iniciando processamento lendo intermediária e enviando os dados!"
	
Begin Sequence
	
	For nA := 1 to nEmpresas
	
		cXEmpresa := aEmps[nA][1]
		cXFilial  := aEmps[nA][2]
	
		If  lECJob .Or. lDepurar
			RpcClearEnv()   //Caso tenha algum ambiente em aberto, fechar!
			
			ConOut("LOJA862: LJ862EComm: " + STR0064 + cXEmpresa + "/" + cXFilial + " - " + Time())   //"Iniciando Empresa/Filial: "
			RpcSetType( 3 )
			If  !( RpcSetEnv( cXEmpresa, cXFilial,,,"LOJ" ) )
				ConOut("LOJA862: LJ862EComm: " + STR0065)    //"Parametros de Empresa e Filial incorretos! Cancelando Execução!"
				lOk := .F.
				Break
			EndIf 	
		ElseIf (nA > 1)
			Exit         //Caso nao seja Job devera sair para nao processar mais de uma vez na mesma empresa e filial.
		EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se é release 5.11 ou superior.                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  !( GetRpoRelease("R5") )
			ConOut("LOJA862: LJ862EComm: " + STR0060) //"e-Commerce irá funcionar apenas para Release 11.5 e superior!"
			Break
		EndIf
	
		DbSelectArea("MEY")
		DbSetOrder(2) //MEY_FILIAL+MEY_ECFLAG+MEY_ECSEQ
		nConta := 1
		
		Do While nConta <= 2
		
			If nConta == 1
				cFlag := "A"
			Else
				cFlag := "Z"
			EndIf  
			
			DbSeek(xFilial("MEY")+cFlag)
			
			While !( Eof() ) .And. (MEY_FILIAL+MEY_ECFLAG == xFilial("MEY")+cFlag)
			
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³ Interrupcao pelo parametro MV_LJECOMX                                     ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  (SuperGetMV("MV_LJECOMX",,"1") == "0")  //0=Nao executar / 1=Executar
			        ConOut("LOJA862: LJ862EComm: " + STR0003 + " Job: " + cECJob)  //"Execução interrompida pelo parâmetro MV_LJECOMX!"
			        Break
			    EndIf    
			    
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³ Verifica se ja passou pelo registro nesta vez de execucao do Job.         ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    If  (Ascan(aExecutado, MEY_ECSEQ) > 0)
			    	DbSkip()
			    	Loop
			    EndIf	
		
		        aadd(aExecutado, MEY_ECSEQ) //Grava aqui o registro mesmo que esteja sendo usado por outro processo/job.
		        
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³ Registro pode estar travado por outro Job, neste caso passa para o proximo³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  !( SoftLock('MEY') )
					DbSkip()
					Loop
				EndIf
				
			 	cNomeLock := "MEY"+MEY_ECSEQ
			 	
				If  !( LockByName(cNomeLock, lEmpresa, lFilial, lUsaDisco) ) 
				    DbSkip()
				    Loop
				EndIf
		
				LJ862Imp(cECJob)
				
				UnLockByName(cNomeLock, lEmpresa, lFilial, lUsaDisco)
				
				MSUnLockAll()
				
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³ Volta para inicio, pois quando encerra um processo o registro muda de     ³
			 //³ Status indo para o fim do registro.                                       ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSeek(xFilial("MEY")+cFlag)
				
			End
			nConta++
				
		End	
	
	Next nA

End Sequence		

If  lECJob .Or. lDepurar
	RpcClearEnv()
          
	If  lECJob .And. lOk
		MemoWrit(cArq,DtoS(Date())+','+Time())
	EndIf	
EndIf

ConOut("LOJA862: LJ862EComm: " + STR0066 + " - " + Time())   //"Finalizando o processo!"

Return lOk
		
		    
		
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LJ862Imp º Autor ³ Antonio C Ferreira º Data ³  08/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Leitura da Tabela Intermediaria dos dados a serem          º±±
±±º          ³ importados via webservices. MEY Posicionado.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cECJob - Nome do Job que esta executando a rotina.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function LJ862Imp(cECJob)

Local lRet        := .T.             //Retorna verdadeiro caso o processo ocorreu sem problema
Local lValidado   := .F.             //Indica que o registro foi gravado no Protheus e valida para sair da lista de novos do e-Commerce
   
Local aArea          := GetArea()    //Salva a area atual

Local cAlias      := ""              //Alias principal do processo
Local nIndice     := 0				 //Indice do alias principal
Local cWebService := ""              //Webservice da importacao
Local cMetodo     := ""              //Metodo da importacao
Local cXML        := ""              //XML que ira gerar o registro no Protheus
Local oXML        := nil             //Objeto que ira processar o XML
Local cErro       := ""              //Mensagem de erro na geracao do objeto do XML
Local cAviso      := ""              //Mensagem de alerta na geracao do objeto do XML
Local cMensagem   := ""              //Mensagem de erro no processo de importacao, irá gerar o log de erro.
Local cVChave     := ""              //Chave utilizado no e-commerce para validar o registro e sair do listar novos.

Local bCondicao   := nil             //Condicao para poder processar o XML. Ex.: O pedido precisa ter o cliente ja cadastrado no Protheus.
Local lIntermediaria := .T.          //Indica se utiliza a tabela intermediaria ou nao.

Local bOldError   := ErrorBlock( {|x| LOJ862Erro(x, @cMensagem) } ) // controla o erro de execucao, por exemplo, no codeblock de parametros (bParametro).

Local aECampos    := {}              //Relaciona os campos do Protheus as propriedades do objeto oXML
Local lDeleta	 := .F.				//Validação de exclusao

DEFAULT cECJob    := ""

DbSelectArea("MDY")
DbSetOrder(2) //MDY_FILIAL+MDY_ECFLAG+MDY_ECWS+MDY_ECMET1

DbSelectArea("MEY")
		
Begin Sequence

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Caso nao possa executar, interrompe mesmo que nao seja job.               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  (SuperGetMV("MV_LJECOMX",,"1") == "0")  //0=Nao executar / 1=Executar
        ConOut("LOJA862: LJ862Imp: " + STR0003 + " Job: " + cECJob)   //"Execução interrompida pelo parâmetro MV_LJECOMX!"
        
        If  Empty(cECJob)
        	Aviso(STR0002, STR0003, {"Ok"})    //"Mensagem do Usuário"##"Execução interrompida pelo parâmetro MV_LJECOMX!"
        EndIf

		lRet := .F.
        Break
    EndIf    

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Tenta travar o registro para utilizacao.                                  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( SoftLock('MEY') )
		lRet := .F.
	    Break
	EndIf

    If  !( MDY->( DbSeek(xFilial("MDY")+"A"+MEY->(MEY_ECWS+MEY_ECMETO)) ) )
       	cMensagem := "LOJA862: LJ862EComm: " + STR0012 + Alltrim(MEY_ECWS) + STR0015 + Alltrim(MEY_ECMETO) //"Configuração do WebService não encontrada na MDY! WebService: "##" Método: "
        	
		lRet := .F.
	    Break
    EndIf
        
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Dados do WebService e Metodo.                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	cWebService := Alltrim(MEY_ECWS)
 	cMetodo     := Alltrim(MEY_ECMETO)
 	cXML        := Alltrim(MEY_ECXML)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Abre o alias para preparar para a gravacao dos dados.                     ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAlias  := Alltrim(MEY_ECALIAS)
	nIndice := Val(MEY_ECIND)
		
	DbSelectArea(cAlias)
	DbSetOrder(nIndice)

	DbSelectArea("MEY")

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cria o objeto pelo XML gravado na intermediaria.                          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oXML := XmlParser(cXml, "_", @cErro, @cAviso)

    If  !( Empty(cErro) )
       	cMensagem := "LOJA862: LJ862EComm: " + STR0013 + CRLF + STR0014 + Alltrim(MEY->MEY_ECWS) + STR0015 + Alltrim(MEY->MEY_ECMETO) + CRLF + STR0016 + cErro  //"Problema ao gerar o objeto do XML!"##" WebService: "##"Erro: "
        	
		lRet := .F.
	    Break
    EndIf
    
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Caso ja tenha processado a chave ira validar o metodo.                    ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	If  !( Empty(MEY_ECVCHV) )
 	
		cVChave := Alltrim(MEY_ECVCHV)
		
 	    If  Empty(MDY->MDY_ECMETV) .Or. LJ862Validar(cWebService, cAlias, oXML, Alltrim(MEY_ECVCHV), @cMensagem)
			lValidado := .T.	
		EndIf
			
 	 	Break
 	EndIf

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Condicao para processar o XML, exemplo: O Pedido precisa ter o cliente ja ³
 //³ cadastrado para poder processar.                                          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
    If  !( Empty(MDY->MDY_ECCNDP) )
    	bCondicao := &("{|xx, xMens| " + Alltrim(MDY->MDY_ECCNDP) + " }")
    	
    	If  !( Eval(bCondicao, oXML, @cMensagem) )
    	    MEY->MEY_NPROCE := (MEY->MEY_NPROCE + 1)
    	    
    	    If  (MEY->MEY_NPROCE > 05)  //Apos 5 tentativas de gravacao e nao atender a condicao ira gerar Log.
       	        cMensagem := "LOJA862: LJ862EComm: " + STR0017 + CRLF + STR0014 + Alltrim(MEY->MEY_ECWS) + STR0015 + Alltrim(MEY->MEY_ECMETO) + CRLF + STR0016 + STR0018  + CRLF + cMensagem//"Problema na condição de processamento (MDY_ECCNDP)!"##" WebService: "##" Método: "##"Erro: "##"Excedeu número de tentativas de processamento!"
    	    EndIf
    	
		    lRet := .F.
    	    Break
    	EndIf
    EndIf	
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Relaciona os campos do Protheus as propriedades do objeto oXML.           ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
		aECampos  := {}

	 	If  !( LJ862RelCampos(@oXML, @aXPrincipal, @aXItem, @aXIndice, @aXMatriz, @aECampos, @cMensagem) )
			lRet := .F.
	 	    Break
	 	EndIf
	 	lDeleta := .F.
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Executa a funcao ou execauto para a gravacao dos campos.                  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	If  !( LJ862Gravar(cWebService, cMetodo, cAlias, oXML, aXPrincipal, aXItem, aXIndice, aXMatriz, cXML, @cVChave, @cMensagem, cECJob, @lDeleta) )
		lRet := .F.
 	    Break
 	EndIf

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Valicao do metodo tirando a informacao da lista de dados.                 ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	If  Empty(MDY->MDY_ECMETV) .Or. LJ862Validar(cWebService, cAlias, oXML, cVChave, @cMensagem, lDeleta)
		lValidado := .T.
 	EndIf

End Sequence

If  lRet
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Encerra a Intermediaria.                                                  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MEY->( SoftLock('MEY') )  //Confirma a trava logica da tabela intermediaria.
	             
	If  lValidado  
		MEY->MEY_ECFLAG := 'X' //Finalizado 
	EndIf	
	MEY->MEY_ECVCHV := cVChave 
	MEY->MEY_ECJOB  := cECJob
	MEY->MEY_ECDTE  := Date()
	MEY->MEY_ECHRE  := Time()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento de erro de execucao.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  !( Empty(cMensagem) )
	LJ862LogErro(lIntermediaria, cWebService, cMetodo, cECJob, cMensagem)
EndIf

RestArea(aArea)
ErrorBlock( bOldError )   //Volta ao tratamento de erro padrao.
        	
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862Validarº Autor ³ Antonio C Ferreira º Data ³  23/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valicao do metodo tirando a informacao da lista de dados.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cWebService  - WebService para a importacao                  º±±
±±º          ³ cAlias  - Alias principal da importacao                      º±±
±±º          ³ oXML  - Objeto que contem os dados do XML da importacao      º±±
±±º          ³ cChave  - Chave do alias principal do processo.              º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                                  

Static Function LJ862Validar(cWebService, cAlias, oXML, cVChave,;
                             cMensagem, lDeleta)
                             
Local nA                                                     //Contador do comando For
Local aArea       := GetArea()                              //Salva a area atual
Local oObj        := nil                                    //Objeto que ira processar o metodo de Validacao no e-Commerce tirando o registro do listar novos.
Local cMetValidar := Alltrim(MDY->MDY_ECMETV)              //Metodo de validacao gravado na tabela de configuracao MDY
Local bMetValidar := &("{|| oObj:" + cMetValidar + "() }") //CodBlock que ira processar o metodo de validacao.
Local aEntradas   := &("{'" + StrTran(StrTran(Alltrim(MDY->MDY_ECPARV),chr(10),""),chr(13),"','") + "'}")  //Parametros de entrada do metodo de validacao do e-commerce.
Local bEntrada    := nil                                   //CodBlock que ira processar os parametros de entrada do metodo de validacao.

Local aEmps       := {}                                    //Empresas que serao processadas pelo Job. 
Local cPrograma   := ""                                    //Nome do programa que contem o WS


Default cWebService := ""
Default cAlias      := ""
Default oXML        := nil
Default cVChave     := ""
Default cMensagem   := ""
Default lDeleta		:= .F.

Begin Sequence

	If  Empty(cVChave)   .And. !lDeleta
		cMensagem := "LJ862EComm: LJ862Validar:" + STR0014 + cWebService + STR0015 + cMetValidar + ": " + STR0019 //" WebService: "##" Método: "##"Chave da tabela em branco!"
		Break
	EndIf
	
	If  (Len(aEntradas) <= 0)
		cMensagem := "LJ862EComm: LJ862Validar:" + STR0014 + cWebService + STR0015 + cMetValidar + ": " + STR0020   //" WebService: "##" Método: "##"Parâmetros de entrada do método de validação não encontrados!"
		Break
	EndIf
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cria o objeto para utilizacao do webservice e verifica as entradas.	   ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj := &("WS" + cWebService + "():NEW()")  //Cria o objeto do WebService
        
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Caso esteja definido no ini nova localizacao para WS sera configurado abaixo. ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPrograma    := cWebService + ".asmx"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem o endereco do WS no arquivo de configuracao intecomm.ini            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( LJ861Emps("LOJA862", cEmpAnt, cFilAnt,, @aEmps) )
	    cMensagem := "LOJA862: LJ862Validar: " + STR0067   //"Problema na configuração do arquivo intecomm.ini!"
	    Break
	EndIf    

    oObj:_Url := aEmps[1][3]+cPrograma //Configura o endereco do WS para o grupo de empresa/filial.
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Processa os parametros de entrada do WS.                                      ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nA := 1 to Len(aEntradas)
		bEntrada := &( "{|xx,zzChave| " + Alltrim(aEntradas[nA]) + " }" )
		Eval(bEntrada, oXML, Alltrim(cVChave))
	Next nA
	
	If  !( Eval(bMetValidar) )
		cMensagem := "LJ862EComm: LJ862Validar:" + STR0014 + cWebService + STR0015 + cMetValidar + ": " + STR0021   //" WebService: "##" Método: "##"Problema no método validar!"

		If  !( Empty(GetWSCError(3)) )
			cMensagem += CRLF + SubStr( GetWSCError(3), At(":", GetWSCError(3) ) + 1 )
		EndIf
		
		Break
	EndIf

End Sequence

RestArea(aArea)
        	
Return Empty(cMensagem)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862RelCamposº Autor ³ Antonio C Ferreira º Data ³  09/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relaciona as propriedades do objeto oXML com os campos do      º±±
±±º          ³ Protheus.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oXML  - Objeto que contem os dados do XML da importacao        º±±
±±º          ³ aPrincipal - Matriz com os dados do cabecalho                  º±±
±±º          ³ aItem - matriz com os dados dos Itens (caso tenha)             º±±
±±º          ³ aIndice - matriz com os campos do indice para pesquisa         º±±
±±º          ³ aMatriz - matriz com os dados do XML para funcoes especificas  º±±
±±º          ³ aECampos - detalhes dos campos Protheus relacionados ao XML    º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862RelCampos(oXML, aPrincipal, aItem, aIndice,;
                               aMatriz, aECampos, cMensagem)
                             
Local nA             := 0            //Contador do comando For
Local nB             := 0            //Contador do comando For
Local nC             := 0            //Contador do comando For

Local aArea          := GetArea()   //Salva a area atual

Local cChave         := ""          //Chave da tabela intermediaria
Local cAlias         := ""          //Alias da tabela principal da importacao
Local cCampo         := ""          //Campo do Protheus que ira receber

Local cEstrutura     := ""          //Estrutura de matriz dentro do XML. Ex.: Enderecos, telefones e etc.
Local aEstrutura     := ""          //Matriz com as estruturas de matriz dentro do XML.
Local bEstrutura     := nil         //CobBlock para gerar a estrutura de matriz em objeto XML. 
Local oEstrut01      := nil         //Objeto XML 1 para as estruturas de matriz.
Local oEstrut02      := nil         //Objeto XML 2 para as estruturas de matriz.

Local lIntermediaria := .T.  //Esta executando baseado na tabela intermediaria

Local bBloco         := nil         //CodBlock para obter o valor da TAG do XML.
Local bCondicao      := nil         //Condicao para obter o valor da TAG do XML.             

Default oXML       := nil
Default aPrincipal := {}
Default aItem      := {}
Default aIndice    := {}
Default aMatriz    := {}
Default aECampos   := {}
Default cMensagem  := ""

aPrincipal := {}
aItem      := {}
aIndice    := {}
aMatriz    := {}

DbSelectArea("MEL")
DbSetOrder(1) //MEL_FILIAL+MEL_ECWS+MEL_ECMETO+MEL_ECFLAG+MEL_ECSEQ

Begin Sequence
                          
    cChave := xFilial("MEL")+MEY->(MEY_ECWS+MEY_ECMETO)+"A"
    
	DbSeek(cChave)
	                                              
	If  !( Eof() ) .And. (MEL_ECTIPO $ 'MX')
		aadd(aMatriz, {Alltrim(MEL_ECALIA), 1, {}/*Campos*/, {}/*Informacoes Extras*/})  
	EndIf	
	
	While !( Eof() ) .And. (MEL_FILIAL+MEL_ECWS+MEL_ECMETO+MEL_ECFLAG == cChave)
	
		cAlias := Alltrim(MEL_ECALIA)
		cCampo := Alltrim(MEL_ECCAMP)
	                   
	    bCondicao := &( "{|xx| " + Alltrim(MEL_ECCOND) + " }" )
	        
	    If  !( Empty(MEL_ECESTR) )
	    
	        aadd(aECampos, {MEL_ECESTR, MEL_ECSEQ, MEL_ECTIPO, Alltrim(MEL_ECCAMP), Alltrim(MEL_ECTAG), Alltrim(MEL_ECCOND), MEL_ECOBRI})
	    
		ElseIf  Empty(MEL_ECCOND) .Or. Eval(bCondicao, oXML)

	        bBloco := &('{|xx, xMens| ' + Alltrim(MEL_ECTAG) + ' }')
	        xValor := Eval(bBloco, oXML, @cMensagem)
	    
			If  !( Empty(cMensagem) )
				Break
			EndIf	
	
			If  (MEL_ECTIPO == 'P')     //Principal ou Cabecalho do cadastro.
				aadd(aPrincipal, {Alltrim(MEL_ECCAMP), xValor, nil, bBloco, MEL_ECOBRI})
			ElseIf  (MEL_ECTIPO == 'S') //Secundario ou Itens do cadastro
			    aadd(aItem, {Alltrim(MEL_ECCAMP), xValor, nil, bBloco, MEL_ECOBRI})
			ElseIf  (MEL_ECTIPO == 'I') //Indice //Obtem a informacao com brancos no final complementando o tamanho para poder ser usado na chave de pesquisa.
		    	aadd(aIndice, {Alltrim(MEL_ECCAMP), PadR(Alltrim(xValor),Len((cAlias)->(FieldGet(FieldPos(cCampo))))), nil, bBloco}) 
			ElseIf  (MEL_ECTIPO == 'M')     //Matriz dos Campos para ser utilizada em funcao especifica para processar cadastros complexos.
				aadd(aMatriz[1][3], {Alltrim(MEL_ECCAMP), xValor, bBloco, MEL_ECOBRI})
			ElseIf  (MEL_ECTIPO == 'X')     //Matriz das Informacoes Extras para ser utilizada em funcao especifica para processar cadastros complexos.
				aadd(aMatriz[1][4], {Alltrim(MEL_ECCAMP), xValor, bBloco, MEL_ECOBRI})
		    EndIf	

		EndIf
	     
		DbSkip()
	End

	If  !( Empty(cMensagem) )
		Break
	EndIf	
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define a estrutura da Matriz aECampos para facilitar a programacao.       ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#Define drCmpECSTR  aECampos[nC][1]
	#Define drCmpECSEQ  aECampos[nC][2]
	#Define drCmpECTIPO aECampos[nC][3]
	#Define drCmpECCAMP aECampos[nC][4]
	#Define drCmpECTAG  aECampos[nC][5]
	#Define drCmpECCOND aECampos[nC][6]
	#Define drCmpECOBRI aECampos[nC][7]
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Obtem as estruturas matrizes do XML.                                      ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cEstrutura := MDY->MDY_ECESTR
	
	If  !( Empty(cEstrutura) )
	
		aEstrutura := &("{'" + StrTran(StrTran(Alltrim(cEstrutura),chr(10),""),chr(13),"','") + "'}")
		
		For nA := 1 to Len(aEstrutura)
		    aEstrutura[nA] := &("{'" + StrTran(aEstrutura[nA], "|", "','") + "'}")
		Next nA
		
		For nA := 1 to Len(aEstrutura)
		    cEstrutura := aEstrutura[nA][1]
		    cAlias     := aEstrutura[nA][2]

		    bEstrutura    := &( "{|xx| " + Alltrim(aEstrutura[nA][3]) + " }" )
		    oEstrut01     := Eval(bEstrutura, oXML)
		    nLenEstrutura := 1
                                                                       
			If  (ValType(oEstrut01) == "A")
				nLenEstrutura := Len(oEstrut01)
		    EndIf	
		    
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Uma estrutura pode ser um objeto ou matriz de objetos.                    ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    For nB := 1 to nLenEstrutura
		    
				If  (ValType(oEstrut01) == "A")
			    	oEstrut02 := oEstrut01[nB]   //Pega o objeto da Matriz
			    Else	
			    	oEstrut02 := oEstrut01
			    EndIf
			                      
			    If  (aECampos[1][3] $ 'MX')	  //Se o primeiro for M ou X todos os demais serao tb.
			    	aadd(aMatriz, {cAlias, nB, {}/*Campos*/, {}/*Informacoes Extras*/, cEstrutura, bEstrutura})
			    	nX := Len(aMatriz)
			    EndIf
		    
			    For nC := 1 to Len(aECampos)
			        
			        If  (drCmpECSTR != cEstrutura)
			        	Loop
			        EndIf  
	
		      		bCondicao := &( "{|yy,xx| " + Alltrim(drCmpECCOND) + " }" )
		        
			        If  Empty(drCmpECCOND) .Or. Eval(bCondicao, oEstrut02, oXML)
			
				        bBloco := &('{|yy,xx,xItem| ' + Alltrim(drCmpECTAG) + ' }')
				        xValor := Eval(bBloco, oEstrut02, oXML, nB)
				    
						If  (drCmpECTIPO == 'P')     //Principal ou Cabecalho do cadastro.
							aadd(aPrincipal, {Alltrim(drCmpECCAMP), xValor, nil, bBloco, drCmpECOBRI})
						ElseIf  (drCmpECTIPO == 'S') //Secundario ou Itens do cadastro
						    aadd(aItem, {Alltrim(drCmpECCAMP), xValor, nil, bBloco, drCmpECOBRI})
						ElseIf  (drCmpECTIPO == 'I') //Indice //Obtem a informacao com brancos no final complementando o tamanho para poder ser usado na chave de pesquisa.
					    	aadd(aIndice, {Alltrim(drCmpECCAMP), PadR(Alltrim(xValor),TamSX3(drCmpECCAMP)[1]), nil, bBloco}) 
						ElseIf  (drCmpECTIPO == 'M')     //Matriz dos Campos para ser utilizada em funcao especifica para processar cadastros complexos.
							aadd(aMatriz[nX][3], {Alltrim(drCmpECCAMP), xValor, bBloco, drCmpECOBRI})
						ElseIf  (drCmpECTIPO == 'X')     //Matriz das Informacoes Extras para ser utilizada em funcao especifica para processar cadastros complexos.
							aadd(aMatriz[nX][4], {Alltrim(drCmpECCAMP), xValor, bBloco, drCmpECOBRI})
					    EndIf	
			
					EndIf
					
			    Next nC
			    
			Next nB   
			
			If  !( Empty(cMensagem) )
				Break
			EndIf	
	
		Next nA
		
	EndIf	


End Sequence

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento de erro de execucao.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  Empty(cMensagem) .And. ((Len(aPrincipal) <= 0) .And. (Len(aMatriz[1][3]) <= 0))
	cMensagem := STR0022   //"Nenhum campo foi encontrado no relacionamento de campos!"
EndIf

If  !( Empty(cMensagem) )
	cMensagem := STR0023 + CRLF + STR0014 + Alltrim(MEY->MEY_ECWS) + STR0015 + Alltrim(MEY->MEY_ECMETO) + CRLF + cMensagem  //" Problema no relacionamento dos campos! "##" WebService: "##" Método: "
EndIf

RestArea(aArea)
        	
Return Empty(cMensagem)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862Gravarº Autor ³ Antonio C Ferreira º Data ³  09/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava os dados no Protheus.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cWebService - WebService para a importacao                  º±±
±±º          ³ cMetodo - Metodo para a importacao                          º±±
±±º          ³ cAlias - Alias principal da importacao                      º±±
±±º          ³ oXML  - Objeto que contem os dados do XML da importacao     º±±
±±º          ³ aPrincipal - Matriz com os dados do cabecalho               º±±
±±º          ³ aItem - matriz com os dados dos Itens (caso tenha)          º±±
±±º          ³ aIndice - matriz com os campos do indice para pesquisa      º±±
±±º          ³ aMatriz - matriz com os dados do XML para funcao especifica º±±
±±º          ³ cXML - XML que ira gerar o cadastro, sera gravado na MF5    º±±
±±º          ³ cVChave - Chave da tabela principal, sera gravado na MF5    º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                   º±± 
±±º          ³ cECJob - Nome do Job que esta executando a rotina.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862Gravar(cWebService, cMetodo, cAlias, oXML,;
                            aPrincipal, aItem, aIndice, aMatriz,;
                            cXML, cVChave, cMensagem, cECJob,;
                            lDeleta)

Local nA                          //Contador do comando For
Local aArea     := GetArea()     //Salva a area atual
Local bExecAuto := nil           //Ira executar funcoes do padrao ou funcoes especificas para o tratamento da gravacao dos dados do e-Commerce.
Local cChave    := ""            //Chave de busca para verificar se o registro existe ou nao.
Local lAchou    := .F.           //Caso encontre o registro pela varivel cChave ira configurar uma alteracao, caso contrario, uma inclusao.
Local nLenaInd  := Len(aIndice)  //Tamanho de aIndice

Local cOpcao    := ""            //Caso encontre o registro pela varivel cChave ira configurar uma alteracao, caso contrario, uma inclusao.

Private lMsErroAuto := .F.       //variavel de controle do execauto, retornara verdadeiro caso processou com erro.

Default cWebService := ""
Default cMetodo     := ""
Default cAlias      := ""
Default oXML        := nil
Default aPrincipal  := {}
Default aItem       := {}  
Default aIndice     := {} 
Default aMatriz     := {}
Default cXML        := ""
Default cVChave     := ""
Default cMensagem   := "" 
Default cECJob		:= ""
Default lDeleta		 := .F.

Begin Sequence

	DbSelectArea(cAlias)

	If  (nLenaInd > 0)	    
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Obtem a chave para tentar posicionar no registro da tabela.               ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cChave := xFilial(cAlias)
		
		For nA := 1 to nLenaInd
		    cChave += aIndice[nA][2]
		Next nA
		
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Grava a chave gerada na intermediaria.                                    ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MEY->MEY_ECVCHV := cChave 
		
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Tenta posicionar no registro e valida com a opcao de manutencao do metodo.³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lAchou := DbSeek(cChave)
	EndIf
	
	If  lAchou 
	     cOpcao := '4'
	Else
	     cOpcao := '3'
	EndIf	

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Processa a manutencao do cadastro.                                        ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If  (Len(aMatriz) > 0)
    
		bExecAuto := &('{|u, v, w, x, y, z, a , b| ' + Alltrim(MDY->MDY_ECEXEC) + '(u, v, w, x, y, @z, a, @b)}')

    	Eval(bExecAuto, cWebService, cMetodo, oXML, aMatriz, cXML, @cMensagem, cECJob, @lDeleta)
    	
    	If  !( Empty(cMensagem) )
    		Break
    	EndIf
    
    Else
		
		bExecAuto := &('{|x,y,z| ' + Alltrim(MDY->MDY_ECEXEC) + '(x,y,z)}')
		
	    If  (Len(aItem) > 0)
			MSExecAuto( bExecAuto, aPrincipal, aItem, Val(cOpcao) )
		Else	
			MSExecAuto( bExecAuto, aPrincipal, Val(cOpcao) )
		EndIf	
		
		MEY->( SoftLock('MEY') )  //Volta a trava logica da tabela intermediaria que o execauto() retira apos execucao.
	  
		If  lMsErroAuto
			
			If  __lSX8
				RollBackSX8()
			EndIf           
			
			aErro := GetAutoGRLog()
			cErro := ""
		    For nA := 1 To Len(aErro)
		    	cErro += aErro[nA] + CRLF
		    Next nA
	
			cMensagem := STR0014 + Alltrim(MEY->MEY_ECWS) + STR0015 + Alltrim(MEY->MEY_ECMETO) + CRLF + STR0016 + cErro   //" WebService: "##" Método: "##"Erro: "
			Break
	
		EndIf
	
		If  __lSX8
			ConfirmSX8()
		EndIf
		
	EndIf
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Grava o XML dos dados relacionando a tabela da base.                      ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lDeleta
		LJ862MF5(cOpcao, cAlias, Val(MEY->MEY_ECIND), cXML, {}, @cVChave, @cMensagem)	
    EndIf
End Sequence

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento de erro de execucao.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  !( Empty(cMensagem) )
	cMensagem := STR0024 + CRLF + cMensagem      //"Problema na gravação dos dados! "
EndIf

RestArea(aArea)
        	
Return Empty(cMensagem)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LJ862MF5   º Autor ³ Antonio C Ferreira º Data ³  03/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava o XML dos dados relacionando a tabela da base.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cOpcao - 3-Inclusao, 4-Alteracao, 5-Exclusao                 º±±
±±º          ³ cAlias - Alias principal da importacao                       º±±
±±º          ³ nIndice - indice da tabela principal                         º±±
±±º          ³ cXML - XML que gerou o cadastro, sera gravado na MF5         º±±
±±º          ³ aCampos - Campos especificos a serem gravados na MF5         º±±
±±º          ³ cVChave - Valor da chave do indice da tabela principal       º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862MF5(cOpcao, cAlias, nIndice, cXML,;
                         aCampos, cVChave, cMensagem)

Local nA                                    //Contador do comando For
Local aArea       := GetArea()             //Salva a area atual  
Local cCChave     := ""                    //Campos do indice da tabela principal
Local nLenACampos := Len(aCampos)          //Tamanho de aCampos

Default cOpcao    := ""
Default cAlias    := ""
Default nIndice   := 0
Default cXML      := "" 
Default aCampos   := {} 
Default cVChave   := "" 
Default cMensagem := ""

DbSelectArea(cAlias)
DbSetOrder(nIndice)  
    	
cCChave := IndexKey()    //Campos da Chave de Indice
cVChave := &( cCChave )  //Valores da Chave de Indice

DbSelectArea("MF5")  //XML do e-commerce
DbSetOrder(1)  //MF5_FILIAL+MF5_ECALIA+MF5_ECVCHV

If  (cOpcao $ "34") /* Inclusao ou Alteracao */

   	If  DbSeek(xFilial("MF5")+cAlias+cVChave)
   		RecLock("MF5", .F.)
   	Else
   	    RecLock("MF5", .T.)
   	    MF5->MF5_FILIAL := xFilial("MF5")	
   	EndIf
	
	MF5->MF5_ECALIA := cAlias
	MF5->MF5_ECIND  := "01"         //Indice fixo 01 - talvez mude o conceito futuramente.
	MF5->MF5_ECCCHV := cCChave
	MF5->MF5_ECVCHV := cVChave
	MF5->MF5_ECDATA := Date()
	MF5->MF5_ECHORA := Time()
	MF5->MF5_ECFLAG := "1"          //1-Ativo, Campo informativo, caso o cadastro origem seja excluido, todos os registros XML correspondentes serao configurados para inativo.

	MF5->MF5_ECXML  := cXML
	
	For nA := 1 to nLenACampos
		MF5->( FieldPut(FieldPos(aCampos[nA][1]), aCampos[nA][2]) )
	Next nA
	
	MsUnLock()
	
ElseIf  (cOpcao == "5")	 /* Exclusao */

   	DbSeek(xFilial("MF5")+cAlias+cVChave)
    	
   	While !( Eof() ) .And. (MF5_FILIAL+MF5_ECALIA+Alltrim(MF5_ECVCHV) == cVChave)
   	    If  SoftLock("MF5")
   	    	MF5->MF5_ECFLAG := "2" //Inativo 
   	    	
   	    	MsUnLock()
   	    EndIf
    	
   		DbSkip()
   	End
    		
EndIf

RestArea(aArea)
        	
Return Empty(cMensagem)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LJ862Clien º Autor ³ Antonio C Ferreira º Data ³  22/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava os dados do Cliente X Contatos X Enderecos.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cWebService - WebService para a importacao                   º±±
±±º          ³ cMetodo - Metodo para a importacao                           º±±
±±º          ³ oXML  - Objeto que contem os dados do XML da importacao      º±±
±±º          ³ aMatriz - matriz com os dados do XML para funcao especifica  º±±
±±º          ³ cXML - XML que ira gerar o cadastro, sera gravado na MF5     º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862Clien(cWebService, cMetodo, oXML, aMatriz,;
                           cXML, cMensagem)

Local nA           := 0          //Contador do comando For
Local nB           := 0          //Contador do comando For
Local cCNPJ 	   := ""         //Caso encontre o cliente ja cadastro pelo CNPJ ira passar o codigo do cliente para alteracao.
Local cCliente     := ""         //Codigo novo do cliente
Local cLoja        := "01"       //Loja do cliente
Local cMunic		:= ""		//Município
Local cEst			:= ""		//Estado

Local aCliente  := {}            //Dados do cliente

Local cLogPath      := SuperGetMV("MV_LOGPATH",,"LOGS")  //Pasta para gravacao do log de erro pela funcao Mostraerro().  
Local lAltCli		:= .F. //Alteracao do cliente
Local lCgcCpf		:= .T. //CGC CPF informado (default .T.)    
Local cMv_ValCNPJ := GetNewPar("MV_VALCNPJ","1")
Local cMv_ValCPF  := GetNewPar("MV_VALCPF","1")


Default cWebService := ""        
Default cMetodo     := ""
Default oXML        := nil
Default aMatriz     := {}
Default cXML        := ""
Default cMensagem   := ""  



Begin Sequence

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define a estrutura da Matriz aMatriz para facilitar a programacao.        ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	//aadd(aMatriz, {cAlias, nA, {Alltrim(drCmpECCAMP), xValor}})
	#Define drCmpALIAS  aMatriz[nA][1]
	#Define drCmpLINHA  aMatriz[nA][2]
	#Define drCmpCAMPO  aMatriz[nA][3][nB][1]
	#Define drCmpVALOR  aMatriz[nA][3][nB][2]
	#Define drCmpOBRIG  aMatriz[nA][3][nB][4]

	For nA := 1 to Len(aMatriz)
	
		If  (drCmpALIAS == "SA1") 
		    For nB := 1 to Len(aMatriz[nA][3])
				If  (drCmpCAMPO == "A1_CGC")
		    		cCNPJ := drCmpVALOR
		    		Exit
		    	EndIf	
			Next nB	
		EndIf

		If  !( Empty(cCNPJ) )
			Exit
		EndIf	

	Next nA
	
	If  Empty( cCNPJ )
	    cMensagem := "LOJA862: LJ862Cliente: " + STR0025     //"CNPJ não enviado no XML!"
	    Break
	EndIf

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Processa os dados do cliente.                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA1")
	dbSetOrder(3)  //A1_FILIAL+A1_CGC
    
	If  !( Empty(cCNPJ) ) .And. DbSeek(xFilial("SA1")+cCNPJ)
		cCliente := SA1->A1_COD
		cLoja	 := SA1->A1_LOJA
		LJ862AADD(aCliente, "A1_COD", cCliente	) 
		LJ862AADD(aCliente, "A1_LOJA", cLoja	)    
    Else
    	//Função de Geração do código do cliente pelo MATA030
    	cCliente := M030CGCCPF(.T., cCNPJ, lCgcCpf)
		LJ862AADD(aCliente, "A1_COD", cCliente	) 
		LJ862AADD(aCliente, "A1_LOJA", cLoja	) 
    EndIf

	
	
	For nA := 1 to Len(aMatriz)
		
		If  (drCmpALIAS == "SA1")
		    For nB := 1 to Len(aMatriz[nA][3])  
		    	If drCmpCAMPO == "A1_MUN"  
		    		drCmpVALOR := Upper(ftAcento(drCmpVALOR))  
		    		cMunic := drCmpVALOR
		    	ElseIf drCmpCAMPO == "A1_EST"
		    	    cEst := drCmpVALOR	  
		    	EndIf
				LJ862AADD(aCliente, drCmpCAMPO, drCmpVALOR, (drCmpOBRIG=="1") )
			Next nB	
		EndIf
		
	Next nA 
	

 
 	If Empty(LJ862MUN(cEst, cMunic))  
		cMensagem := "LOJA862: LJ862Cliente:" + CRLF + "Codigo do IBGE não encontrado[" + cMunic + "/" + cEst+"]"
		Break 		
 	EndIf
			
	aCliente := WsAutoOpc(aCliente)

	dbSelectArea("SA1")
	dbSetOrder(1)                   

	If  !( Empty(cCliente) ) .And. DbSeek(xFilial("SA1")+cCliente+cLoja)
		Mata030(aCliente,4)
		lAltCli := .T.   //Alteracao do Cliente
	Else
		Mata030(aCliente,3)
	EndIf

	MEY->( SoftLock('MEY') )  //Volta a trava logica da tabela intermediaria que o execauto() retira apos execucao.
	  
	If  lMsErroAuto
		cMensagem := "LOJA862: LJ862Cliente:" + CRLF + MostraErro(cLogPath)
		Break
	EndIf
	
	cCliente := SA1->A1_COD
	cLoja    := SA1->A1_LOJA

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Processa cada endereco de entrega em Contatos.                            ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nA := 1 to Len(aMatriz)
		
		If  (drCmpALIAS == "SU5") .And. (Len(aMatriz[nA][3]) > 0)
		    LJ862Contato(cCliente, cLoja, aMatriz[nA], @cMensagem, lAltCli)
		    
		    If  !( Empty(cMensagem) )
		    	Break
		    EndIf
		ElseIf (drCmpALIAS == "XA1") .And. (Len(aMatriz[nA][3]) > 0) .And. cMv_ValCNPJ == "1" .And. cMv_ValCPF  == "1"
          
				//Nova validação para Endereço de Entrega
			    LJ862ClEnt(cCliente, cLoja,aMatriz[nA], @cMensagem)
			    //MsgAlert("Endereço de entrega")
			    
			    If  !( Empty(cMensagem) )
			    	Break
			    EndIf
			
		EndIf
		
	Next nA

End Sequence

Return Empty(cMensagem)
			


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862Contatoº Autor ³ Antonio C Ferreira º Data ³  22/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava os dados do Cliente X Contatos X Enderecos.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCliente - Codigo do cliente                                 º±±
±±º          ³ cLoja - Loja do cliente                                      º±±
±±º          ³ oXML  - Objeto que contem os dados do XML da importacao      º±±
±±º          ³ aMatriz2 - matriz com os dados do XML para funcao especifica º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862Contato(cCliente, cLoja, aMatriz2, cMensagem, lAltCont)
           
Local nA           := 0          //Contador do comando For
Local nX           := 0          //3-Inclusao / 4-Alteracao
Local cContato     := ""         //Codigo do contato para verificar se o contato a ser gravado ja existe no cadastro (SU5)
Local cCEP         := ""         //Cep para verificar se o endereco a ser gravado ja existe no cadastro (AGA)
Local aContato     := {}         //Dados do contato
Local aEndereco    := {}         //Dados do Endereco
Local aEnderecos   := {}         //Matriz dos enderecos a serem gravados
Local aFone        := {}         //Dados do telefone
Local aFones       := {}         //Matriz dos telefones a serem gravados
Local aXFone       := {}         //Caso o telefone a ser gravado ja exista, ira passar o codigo do telefone no cadastro (AGB)
Local cChave       := ""         //Variavel auxiliar que ira montar a chave do cadastro para pesquisa.
Local cCodEnd      := ""         //Caso o endereco a ser gravado ja exista no cadastro, ira passar o Codigo do endereco para alteracao.
Local cAGAEnd		:= "" 		//Endereço do Cliente       


                     
Local cLogPath      := SuperGetMV("MV_LOGPATH",,"LOGS")  //Pasta para gravacao do log de erro pela funcao Mostraerro().  
Local nTamSU5Con    := SU5->(TamSx3("U5_CONTAT")[1])


Default cCliente  := ""
Default cLoja     := ""
Default aMatriz2  := {}
Default cMensagem := "" 
Default lAltCont := .F. //Alteracao de Cliente (opção .F. - Inclusão de cliente)

Begin Sequence

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define a estrutura da Matriz aMatriz2 para facilitar a programacao.       ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#Define drCmpALIAS2  aMatriz2[1]
	#Define drCmpLINHA2  aMatriz2[2]
	#Define drCmpCAMPO2  aMatriz2[3][nA][1]
	#Define drCmpVALOR2  aMatriz2[3][nA][2]
	#Define drCmpOBRIG2  aMatriz2[3][nA][4]
	#Define erCmpCAMPO2	 1
	#Define erCmpVALOR2  2


	If  ( nA :=  aSCan(aMatriz2[3], { |e| e[erCmpCAMPO2] == "U5_CONTAT" }  ) ) > 0  
		cNomeContato := Alltrim(Left(drCmpVALOR2,nTamSU5Con))
	EndIf

 
	If  ( nA :=  aSCan(aMatriz2[3], { |e| e[erCmpCAMPO2] == "AGA_CEP" }  ) ) > 0  
		cCEP := Alltrim(drCmpVALOR2)
	EndIf 
	
	
	If lAltCont //Cliente já exite, provavelmente já existe um contato amarrao

	
	     AC8->(DbSetOrder(2))//	AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT 
	     cChave :=  xFilial("AC8")+ "SA1" + xFilial("SA1") + cCliente+cLoja                                                                                                                                   
		 AC8->(DbSeek(cChave))
	     
	     While  AC8->(!Eof() ) .And. Rtrim(AC8->(AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT )) == cChave  .And. Empty(cContato)  
	    	AC8->AC8_CODCON
	    	If SU5->(DbSeek(xFilial("SU5") + AC8->AC8_CODCON)) .And. Alltrim(SU5->U5_CONTAT) == cNomeContato 
	 			cContato := SU5->U5_CODCONT
				LJ862AADD(aContato, "U5_CODCONT", cContato, .T.)   		
	    	EndIf
	    	
	    	AC8->(DbSkip(1))
	     End
     EndIf                                                                                                       


    If  !( Empty(cContato) )
	    
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Verifica se o endereco ja existe para alteracao.                          ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    DbSelectArea("AGA")
	    DbSetOrder(1)  //AGA_FILIAL+AGA_ENTIDA+AGA_CODENT+AGA_TIPO  //VALIDAR AGA_TIPO
	           
	    cChave := xFilial("AGA")+"SU5"+PadR(cContato,Len(AGA_CODENT))
	    
	    DbSeek(cChave)
	    
	    While !( Eof() ) .And. (AGA_FILIAL+AGA_ENTIDA+AGA_CODENT == xFilial("AGA")+"SU5"+PadR(cContato,Len(AGA_CODENT)))
	    
	        If  (AGA_CEP == cCEP)
	            cCodEnd := AGA_CODIGO
	            Exit
	        EndIf
	        
	        DbSkip()
	    End        
	                 
	    If  !( Empty(cCodEnd) )
	    	LJ862AADD(aEndereco, "AGA_CODIGO", cCodEnd)
	    EndIf

	EndIf
    
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Separa cada informacao em suas matrizes.                                  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nA := 1 to Len(aMatriz2[3])
		                           
		If  (Left(drCmpCAMPO2,4) == "AGA_")    
			If drCmpCAMPO2 == "AGA_MUN"
				drCmpVALOR2 := Upper(ftAcento(drCmpVALOR2))
			EndIf
		
			LJ862AADD(aEndereco, drCmpCAMPO2, drCmpVALOR2, (drCmpOBRIG2=="1") )
		ElseIf  (Left(drCmpCAMPO2,4) == "AGB_")
			LJ862AADD(aFone, drCmpCAMPO2, drCmpVALOR2, (drCmpOBRIG2=="1") )
        Else
			LJ862AADD(aContato, drCmpCAMPO2, drCmpVALOR2, (drCmpOBRIG2=="1") )
		EndIf
		
	Next nA
	
	If  (Len(aContato) <= 0)
		cMensagem := "LOJA862: fGravCont: " + STR0026   //"Contato Vazio!"
		Break
	EndIf	

	If  (Len(aEndereco) > 0)
		aadd(aEnderecos, aEndereco)
		aEnderecos := WsAutoOpc(aEnderecos)
	EndIf
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Desmembra cada registro do Telefone.                                      ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  (Len(aFone) > 0)	
	    aXFone := {}

	    For nA := 1 to Len(aFone)

	        If  (aFone[nA][1] == "AGB_TIPO")
	            If  (nA > 1)
	            	aadd(aFones, aXFone)
	            	aXFone := {}
	            EndIf
	       EndIf

           If  (aFone[nA][1] == "AGB_TELEFO")
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³ Verifica se o telefone ja existe para alteracao.                          ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    DbSelectArea("AGB")
			    DbSetOrder(1)  //AGB_FILIAL+AGB_ENTIDA+AGB_CODENT+AGB_TIPO
			           
			    cChave := xFilial("AGB")+"SU5"+PadR(cContato,Len(AGB_CODENT))
			    
			    DbSeek(cChave)
			    
			    While !( Eof() ) .And. (AGB_FILIAL+AGB_ENTIDA+AGB_CODENT == xFilial("AGB")+"SU5"+PadR(cContato,Len(AGB_CODENT)))
			    
			        If  (Alltrim(AGB_TELEFO) == Alltrim(aFone[nA][2]))
			            aadd(aXFone, {"AGB_CODIGO"	, AGB_CODIGO,} )
			            Exit
			        EndIf
			        
			        DbSkip()
			    End        
           EndIf
	       
	       aadd(aXFone, aFone[nA])
	        
	    Next nA
	    
	    If  (Len(aXFone) > 0)
           	aadd(aFones, aXFone)
           	aXFone := {}
        EndIf   	
		
		aFones := WsAutoOpc(aFones)
	EndIf	
			
	aContato   := WsAutoOpc(aContato)
	
	dbSelectArea("SU5") 
	dbSetOrder(1)  //U5_FILIAL+U5_CODCONT

	If 	Empty(cContato) .Or. !( DbSeek(xFilial("SU5")+cContato) )
		nX := 3
	Else
		nX := 4
	EndIf
                                                 
	TmkA070(aContato, nX, aEnderecos, aFones)
	
	MEY->( SoftLock('MEY') )  //Volta a trava logica da tabela intermediaria que o execauto() retira apos execucao.
	  
	If 	lMsErroAuto
		cMensagem := "LOJA862: fGravCont:" + CRLF + MostraErro(cLogPath)
		Break
	EndIf   
	
	If  Alltrim(SU5->U5_CONTAT) != Alltrim(Left(aContato[nX-2][2],nTamSU5Con))
		cMensagem := "LOJA862: fGravCont: " + STR0027       //"Problema para cadastrar o contato!"
		Break
	EndIf   

	If  __lSX8
		ConfirmSX8()
	EndIf
	                    
    cContato := SU5->U5_CODCONT	
	                    
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Amarracao Cliente X Contato.                                              ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AC8")
	dbSetOrder(1)
	If  !DbSeek(xFilial("AC8")+cContato+"SA1"+xFilial("SA1")+cCliente+cLoja)
 
		RecLock("AC8", .T.)
	
		AC8->AC8_FILIAL := xFilial("AC8")
		AC8->AC8_CODCON := cContato
		AC8->AC8_ENTIDA := "SA1"
		AC8->AC8_FILENT := xFilial("SA1")
		AC8->AC8_CODENT := cCliente+cLoja
		MsUnLock() 
	EndIf                                          
	
	                                                                                                                                                                                                               


End Sequence

Return Empty(cMensagem)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJ862MUN  ³ Autor ³   Antonio C Ferreira   ³ Data ³ 11/03/13       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Obtem o codigo municipal pela descrição do municipio.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cEstado - Codigo do Estado para obtencao do codigo municipal      ³±±
±±³          ³ cMunicipio - Nome do estado para obtencao do codigo municipal     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ862MUN(cEstado, cMunicipio)

Local aArea   := GetArea()  //Salva a area atual
Local cCodMun := ""         //Codigo municipal da tabela CC2

Default cEstado    := ""
Default cMunicipio := ""

cEstado    := Upper(cEstado)
cMunicipio := Alltrim(Upper(ftAcento(cMunicipio)))


DbSelectArea("CC2")
DbSetOrder(2)  //CC2_FILIAL+CC2_MUN        

DbSeek(xFilial("CC2")+cMunicipio)

While !( Eof() ) .And. (CC2_FILIAL == xFilial("CC2")) .And. (Alltrim(CC2_MUN) == cMunicipio)

    If  (CC2_EST == cEstado)
        cCodMun := CC2_CODMUN
        Exit
	EndIf   
	
	DbSkip()
End

DbSetOrder(1)

RestArea(aArea)

Return cCodMun

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862EndEnt º Autor ³ Antonio C Ferreira º Data ³  11/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Obtem Contato X Endereco para os campos do Orcamento em (MEL)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cFilClienteLoja - Chave para verificar amarracao com contato º±±
±±º          ³ cNomeContato - Posiciona no contato pelo Nome                º±±
±±º          ³ cEndereco - Verifica o endereco cadastrado para este contato º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                    º±±
±±º          ³ cCEP - CEP do Endereço.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS S/A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862EndEnt(cFilClienteLoja, cNomeContato, cEndereco, cMensagem,;
				 cCEP, oObjPed)
                   
Local aArea       := GetArea()  //Salva a area atual
Local cCodContato := ""         //Codigo do contato
Local nTamSU5Con    := SU5->(TamSx3("U5_CONTAT"))[1] //Tamanho do Endereço do Contato    
Local cChave		:= ""   
Local lFound		:= .F. //Encontrou o endereço 
Local cEndCont		:= "" //Endereço do Contato    
Local cCidade		:= "" 
Local cMens			:= ""

Default cFilClienteLoja := ""
Default cNomeContato    := ""
Default cEndereco       := ""
Default cMensagem       := ""  
Default cCEP			:= "" //Codigo do CEP 
Default oObjPed			:= NIL   



cNomeContato := ftAcento(Upper(cNomeContato))
cEndereco := AllTRim(ftAcento(Upper(cEndereco)))   

If oObjPed <> NIL
	cCidade := FtAcento(Upper(oObjPed:_Cidade:TEXT))
EndIf

Begin Sequence
    
	cNomeContato := AllTrim(PadR(cNomeContato, nTamSU5Con)) 

	DbSelectArea("AGA")
	DbSetOrder(1)  //AGA_FILIAL+AGA_ENTIDA+AGA_CODENT+AGA_TIPO
	DbGoBottom()
	DbSkip()       //Registro fantasma/branco do fim de arquivo
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Obtem a amarracao Cliente X Contato.                                      ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


    AC8->(DbSetOrder(2))//	AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT 
    cChave :=  xFilial("AC8")+ "SA1" + cFilClienteLoja   
    AC8->(dbSeek(cChave))                                                                                                                             
 
    SU5->(DbSetOrder(1)) //U5_CONTAT
     
 	While  AC8->(!Eof() ) .And. RTrim(AC8->(AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT )) == cChave  .And. Empty(cCodContato)  
 		AC8->AC8_CODCON
    	If SU5->(DbSeek(xFilial("SU5") + AC8->AC8_CODCON)) .And. Alltrim(ftAcento(Upper(SU5->U5_CONTAT))) == cNomeContato 
 			cCodContato := SU5->U5_CODCONT
 			Exit
		EndIf
    	
    	AC8->(DbSkip(1))
    End

    
	If Empty(cCodContato)  .And. !Empty(cEndereco)
    	cMensagem := "LOJA862: LJ862EndEnt: " + STR0028 + cFilClienteLoja + STR0029 + Alltrim(cNomeContato)  + " Endereco: " + AllTrim(cEndereco) + "CEP: " + cCep  //"Problema para obter o contato do Pedido e-commerce! Chave Cliente: "##" Contato: "
    	Break
	EndIf
	
    
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Obtem a amarracao Contato X Endereco.                                     ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("AGA")
	DbSetOrder(1)  //AGA_FILIAL+AGA_ENTIDA+AGA_CODENT+AGA_TIPO
    
    DbSeek(xFilial("AGA")+"SU5"+SU5->U5_CODCONT)	

    While !( Eof() ) .And. RTrim(AGA_FILIAL+AGA_ENTIDA+AGA_CODENT) ==  RTrim(xFilial("AGA")+"SU5"+SU5->U5_CODCONT)  .And. !lFound
    	cEndCont := AllTrim(ftAcento(Upper(AGA_END)))
    	    	
  		If  cEndCont == cEndereco .AND. ;
  			( Empty(cCidade)  .OR. (RTrim(cCidade) == RTrim(AGA_MUNDES)))
  			
    	    If !Empty(cCep := AllTrim(cCep)) .And. AllTrim(AGA_CEP) == cCep 
    	    	lFound := .T.
    	    	Exit
    	    ElseIf Empty(cCep)
    	    	lFound := .T.
    	    	Exit
    	    EndIf
    	EndIf    
    
    	DbSkip()
    End	 
 
    If !lFound .and. MF5->(FieldPos("MF5_CLIENT")) > 0 .AND. oObjPed <> NIL
    	If !(lFound := !Empty(Lj862EnPed(SA1->A1_COD, SA1->A1_LOJA, oObjPed,@cMens)   ))
    		cMensagem += cMens
    	EndIf
 		cCodContato := ""
 		DbSelectArea("AGA")
 		DbGoBottom()
		DbSkip(1)
    EndIf

   	If  !lFound
		cCodContato := ""
		DbGoBottom()
		DbSkip()       //Registro fantasma/branco do fim de arquivo

    	cMensagem := "LOJA862: LJ862EndEnt: " + STR0030 + SU5->U5_CODCONT + " "  + Alltrim(cNomeContato) + STR0031 + Alltrim(cEndereco) + " CEP: " + cCep   +  CRLF + cMensagem//"Problema para obter o endereço do contato do Pedido e-commerce! Contato: "##" Endereço: "
		Break
   	EndIf
   	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Ok Contato validado.                                                      ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	cCodContato := SU5->U5_CODCONT
    
End Sequence
                              
RestArea(aArea)

Return cCodContato
           
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862AADD º Autor ³ Antonio C Ferreira º Data ³  25/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Se nao estiver em branco adiciona o campo para gravacao.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aDados - Matriz a ter os dados adicionados                 º±±
±±º          ³ cCampo - Campo a ser adicionado na matriz de gravacao      º±±
±±º          ³ xValor - Valor a ser adicionado na matriz de gravacao      º±±
±±º          ³ lObrigatorio - se for verdadeiro sera adicionado mesmo em  º±±
±±º          ³                branco                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862AADD(aDados, cCampo, xValor, lObrigatorio)

Default aDados       := {}
Default cCampo       := ""
Default xValor       := "" 
Default lObrigatorio := .F.

If  lObrigatorio .Or. !( Empty(xValor) )
	aadd(aDados,{cCampo,xValor,})
EndIf

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LJ862Orcam º Autor ³ Antonio C Ferreira º Data ³  25/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Importacao e geracao do Orcamento X Pedido de Venda.         º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862Orcam(cWebService, cMetodo, oXML, aMatriz,;
                           cXML, cMensagem, cECJob,;
                           lDeleta)

Local nA, nB
Local aECCab   		:= {}       //Array do Cabeçalho do Orçamento
Local aECItens  	:= {}       //Array dos Itens do Orçamento
Local aECParcelas  	:= {}       //Array das Parcelas do Orçamento  
Local lStatusConf	:= ExistBlock("LJ862OSt")  
Local aStatusConf	:= {}  
Local lValida		:= .F.		//Valida o orçamento   
Local lStValida		:= .F.		//Valida o Status? 
Local cChave		:= ""


Default cWebService := ""
Default cMetodo     := ""
Default oXML        := nil
Default aMatriz     := {}
Default cXML        := ""
Default cMensagem   := ""  
Default cECJob		:= ""  
Default lDeleta		:= .F.



If lStatusConf
	aStatusConf :=  ExecBlock( "LJ862OST", .F., .F.)   
	lStatusConf := ValType(aStatusConf) == "A" .And. Len(aStatusConf) > 0
EndIf

Begin Sequence

	If  Empty(oXML)
		cMensagem := "LOJA862: LJ862Orcam: " + STR0032  //"Status não processado! Status: "
		Break
	EndIf

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define a estrutura da Matriz aMatriz para facilitar a programacao.        ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	//aadd(aMatriz, {cAlias, nA, {Alltrim(drCmpECCAMP), xValor}})
	#Define drCmpALIAS  aMatriz[nA][1]
	#Define drCmpLINHA  aMatriz[nA][2]
	#Define drCmpCAMPO  aMatriz[nA][3][nB][1]
	#Define drCmpVALOR  aMatriz[nA][3][nB][2]
	#Define drCmpOBRIG  aMatriz[nA][3][nB][4]

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Separa cada informacao em suas matrizes.                                  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nA := 1 to Len(aMatriz)                 
	
	    aDados := {}
		                       
		For nB := 1 to Len(aMatriz[nA][3])  //Campos                           
			LJ862AADD(@aDados, drCmpCAMPO, drCmpVALOR, (drCmpOBRIG=="1"))
		Next nB
		
		If  (drCmpALIAS == "SL1")
			aECCab := AClone(aDados)
		ElseIf  (drCmpALIAS == "SL2")
			aadd(aECItens, AClone(aDados))
        ElseIf  (drCmpALIAS == "SL4")
			aadd(aECParcelas, AClone(aDados))
		EndIf
		
	Next nA  
	
	lStValida		:=  lStatusConf .And.  aScan(aStatusConf, { |x|, x ==  oXML:_clsPedido:_PedidoStatus:TEXT }) > 0	//Valida o Status?
	
	If  (oXML:_clsPedido:_PedidoStatus:TEXT $ _ECSTATUS_CANCELADO) //4-Problemas / 5-Cancelado / 8-AnaliseRisco

	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Cancelamento do Orcamento e da reserva de estoque.                        ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LJ862EOrcam(oXML, aMatriz, aECCab, aECItens, aECParcelas, @cMensagem, @lDeleta)
		
	ElseIf  (oXML:_clsPedido:_PedidoStatus:TEXT == "7")  //PagamentoConfirmado

	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Confirmacao do Pagamento.                                                 ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LJ862POrcam(oXML, aMatriz, aECCab, aECItens, ;
					aECParcelas, @cMensagem, lStValida, @lValida, @cChave)
		
	   	If lStValida .And. lValida  //Se é para enviar a validação do orçamento, então zera a mensagem para enviar a validação
			 	cMensagem := ""
	   	EndIf
		
	ElseIf  (oXML:_clsPedido:_PedidoStatus:TEXT == "6")  //AguardandoPagamento

	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Inclusao e alteracao de Orcamento. Confirmacao de Pagamento.              ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LJ862GOrcam(oXML, aMatriz, aECCab, aECItens, ;
					aECParcelas, cXML, @cMensagem )
	
	Else	

		If lStValida
			//Envia a validação do Orçamento  			
			LJ862VlOrc(oXML, aMatriz, aECCab, aECItens, aECParcelas, @cMensagem, @cChave)
			
		Else
			cMensagem := "LOJA862: LJ862Orcam: " + STR0032 + oXML:_clsPedido:_PedidoStatus:TEXT   //"Status não processado! Status: "
        EndIf
	EndIf

End Sequence

Return Empty(cMensagem)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862EOrcam º Autor ³ Antonio C Ferreira º Data ³  01/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cancelamento do pedido pelo eCommerce.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oXML  - Objeto que contem os dados do XML da importacao      º±±
±±º          ³ aMatriz - matriz com os dados do XML para funcao especifica  º±±
±±º          ³ aECCab - matriz com os dados do cabecalho do orcamento       º±±
±±º          ³ aECItens - matriz com os dados dos itens do orcamento        º±±
±±º          ³ aECParcelas - matriz com os dados das parcelas do orcamento  º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862EOrcam(oXML, aMatriz, aECCab, aECItens,;
                            aECParcelas, cMensagem, lDeleta)
                     
Local nA            := 0             //Contador do comando For
Local lAuto 		:= .T.           //Passa a funcao lj140Exc() que esta sendo executado por job/autoexec().
Local cPrefixo		:= ""            //Prefixo utilizado pelo titulo do e-commerce
Local cNumTitulo	:= ""            //Numero do titulo do e-commerce
Local cLogPath      := SuperGetMV("MV_LOGPATH",,"LOGS") //Pasta para gravacao do log de erro pela funcao Mostraerro().
Local aAreaSL1      := {}            //Salva a area do SL1 no meio do processamento

Private lMsErroAuto    := .F.        //Variavel de controle caso ocorra erro no execauto.
Private lFTStartSilenc := .T.        //varivel para nao apresentar mensagem de erro em tela

Default oXML        := nil
Default aMatriz     := {}
Default aECCab      := {}
Default aECItens    := {}
Default aECParcelas := {}
Default cMensagem   := ""    
Default lDeleta		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se utiliza de um novo alias para nao desposicionar o MEY com o registro   ³
//³ travado.                                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  (Select("TempMEY") <= 0)
    ChkFile("MEY",, "TempMEY"/*Novo Alias*/)
EndIf    

TempMEY->( DbSetOrder(4) ) //MEY_FILIAL+MEY_ECFLAG+MEY_ECWS+MEY_ECMETO+MEY_ECCCHV     

lDeleta := .F.
	
Begin Sequence

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Localiza a primeira intermediaria para obter o numero do Orcamento.       ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( TempMEY->( DbSeek(xFilial("MEY") + "X" + MEY->(MEY_ECWS + MEY_ECMETO + MEY_ECCCHV)) ) )
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Tem que incluir um Orçamento para cancelar e enviar ao e-Commerce a       ³
	 //³ confirmação do cancelamento.                                              ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LJ862GOrcam(oXML, aMatriz, aECCab, aECItens, ;
					aECParcelas, , @cMensagem)
		
		If  !( Empty(cMensagem) )
    	    Break
    	EndIf    
    Else	
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Posiciona o Orcamento pelo indice e chave gravado na intermediaria.       ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    SL1->( DbSetOrder(Val(TempMEY->MEY_ECIND)) )
	    //  Verifica a chave do mf5, pois o orçamento pode ter sido cancelado pelo job de cancelamento, nesse caso ignora a rotina 
	    		
	    If  !( SL1->(DbSeek(TempMEY->MEY_ECVCHV)) )   .And. !( RTrim(Posicione("MF5",1,xFilial("MF5")+"SL1"+RTrim(TempMEY->MEY_ECVCHV),"MF5_ECSTAT")) $ _ECSTATUS_CANCELADO)

	    		cMensagem := "LOJA862: LJ862EOrcmto: " + STR0033    //"Não encontrou Orçamento com a chave da intermediária!"
	    		Break

	    ElseIf !SL1->(Found()) .And.  ( RTrim(Posicione("MF5",1,xFilial("MF5")+"SL1"+RTrim(TempMEY->MEY_ECVCHV),"MF5_ECSTAT")) $ _ECSTATUS_CANCELADO)

    		lDeleta := .T.
    		ConOut("LOJA862: LJ862EOrcmto: " + " Pedido cancelado/devolvido :" + TempMEY->MEY_ECCCHV  + " chave Orçamento " +  TempMEY->MEY_ECVCHV)
    	    Break		    
	    EndIf	
	    
    EndIf	
    
    If  Empty(Posicione("MF5",1,xFilial("MF5")+"SL1"+SL1->(L1_FILIAL+L1_NUM),"MF5_ECPEDI"))
    	cMensagem := "LOJA862: LJ862EOrcmto: " + STR0034   //"Sem o pedido e-commerce gravado na MF5!"
    	Break
    EndIf	
    
    If  (MF5->MF5_ECPAGO == "1")
    	cMensagem := "LOJA862: LJ862EOrcmto: " + STR0035 + SL1->L1_NUM     //"Orçamento já com confirmação de pagamento! Orçamento: "
    	Break
    EndIf
    
    If  !( MF5->(SoftLock("MF5")) )
    	cMensagem := "LOJA862: LJ862EOrcmto: " + STR0036 + SL1->L1_NUM    //"Não foi possível travar a MF5! Orçamento: "
    	Break
    EndIf
    
    cPrefixo   := MF5->MF5_ECPREF
    cNumTitulo := MF5->MF5_ECTITU
      
    lECLJAUTO := .T.  //Seta para execauto do ecommerce
	    
    aAreaSL1 := SL1->(GetArea())
	    
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cancela Orcamento e exclui o pedido de venda e reservas de estoque.            ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If  ( lj140Exc("SL1", SL1->(Recno()), 5,,lAuto, SL1->L1_FILIAL, SL1->L1_NUM) != 1 )
    	cMensagem := "LOJA862: LJ862EOrcmto: " + STR0037 + SL1->L1_NUM      //"Problema encontrado na exclusão do Orçamento! Orçamento: "
    	Break
    EndIf
    
   	MEY->( SoftLock('MEY') )  //Volta a trava logica retirada pela funcao lj140Exc() 

    lECLJAUTO := .F.  //Desativa para execauto do ecommerce

	RestArea(aAreaSL1) //Volta a posicao original

	If  !( SL1->( Deleted() ) )
    	cMensagem := "LOJA862: LJ862EOrcmto: " + STR0037 + SL1->L1_NUM      //"Problema encontrado na exclusão do Orçamento! Orçamento: "
    	Break
    EndIf
    
    If  MF5->( SoftLock("MF5") )
        MF5->MF5_ECFLAG := "2"  //Inativo
    	//Se o status for 5-Cancelado vindo do e-commerce nao preciso retornar para o e-commerce.
    	If  (oXML:_clsPedido:_PedidoStatus:TEXT == "5") 
    		MF5->MF5_ECSTAX := "5"
    		MF5->MF5_ECSTAT := "5"  // 5-Status e-commerce para cancelado
    	Else
	        //mantém o status do pedido e somente valida
	        MF5->MF5_ECSTAX := oXML:_clsPedido:_PedidoStatus:TEXT
	        MF5->MF5_ECSTAT := oXML:_clsPedido:_PedidoStatus:TEXT
	        MF5->MF5_ECDTEX := " "
    	EndIf
    	MF5->( MsUnLock() )
    EndIf

	If  !( Empty(cNumTitulo) )	                
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Exclui os Titulos do Orcamento.                                                ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 	DbSelectArea("SE1")
	 	DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	 	
	 	DbSeek(xFilial("SE1")+cPrefixo+cNumTitulo)
	 	
	 	While !( Eof() ) .And. (E1_FILIAL+E1_PREFIXO+E1_NUM == xFilial("SE1")+cPrefixo+cNumTitulo)
	 	
			lMsErroAuto  := .F.
				
	 		aTitulo := {}
	 		
			aAdd(aTitulo, {"E1_PREFIXO"	,E1_PREFIXO							,Nil})
			aAdd(aTitulo, {"E1_NUM"		,E1_NUM								,Nil})
			aAdd(aTitulo, {"E1_PARCELA"	,E1_PARCELA							,Nil})
			aAdd(aTitulo, {"E1_TIPO"	,E1_TIPO							,Nil})
			
	    	lECLJAUTO := .T.  //Seta para execauto do ecommerce
		    
			MSExecAuto({|x,y| Fina040(x,y) },aTitulo,5)
			
			lECLJAUTO := .F.  //Desativa para execauto do ecommerce
		
			If  lMsErroAuto
		    	cMensagem := "LOJA862: LJ862EOrcmto: " + STR0038 + cPrefixo + " - " + cNumero + " - " + cParcela + CRLF + MostraErro(cLogPath)  //"Problema na exclusão do Titulo: "
		
			    ConOut("...")
				ConOut(cMensagem)
	    		ConOut("...")
	    	
				DisarmTransaction()
				RollBackSX8()
				Exit
			Else
				ConfirmSX8()
			EndIf   
			                           
			DbSeek(xFilial("SE1")+cPrefixo+cNumTitulo) //Posiciona na proxima parcela
			
		End	
	EndIf

End Sequence       

lECLJAUTO := .F.  //Desativa para execauto do ecommerce

Return Empty(cMensagem)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862POrcam º Autor ³ Antonio C Ferreira º Data ³  01/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Confirmacao do Pagamento pelo eCommerce.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oXML  - Objeto que contem os dados do XML da importacao      º±±
±±º          ³ aMatriz - matriz com os dados do XML para funcao especifica  º±±
±±º          ³ aECCab - matriz com os dados do cabecalho do orcamento       º±±
±±º          ³ aECItens - matriz com os dados dos itens do orcamento        º±±
±±º          ³ aECParcelas - matriz com os dados das parcelas do orcamento  º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                    º±±
±±º          ³ lStatusConf - Habilita o Status da Validação                 º±±
±±º          ³ lValida  - Valida o orçamento por motivo de pagamento        º±±
±±º          ³ cChave -  Chave do Orçamento            .                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862POrcam(oXML, aMatriz, aECCab, aECItens,;
                            aECParcelas, cMensagem, lStatusConf, lValida,;
                            cChave)

Local cAlias		:= ""
Local nOrdem		:= 0
Local lAchou		:= .F. //Achou o SL1

Default oXML        := nil
Default aMatriz     := {}
Default aECCab      := {}
Default aECItens    := {}
Default aECParcelas := {}
Default cMensagem   := ""
Default lStatusConf	:= .F. //Envia a validação da confirmação para o status 7, conforme parametrização do usuário       
Default lValida		:= .F.	//Envia validação    

Default cChave		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se utiliza de um novo alias para nao desposicionar o MEY com o registro   ³
//³ travado.                                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  (Select("TempMEY") <= 0)
    ChkFile("MEY",, "TempMEY"/*Novo Alias*/)
EndIf 

cChave := ""   

TempMEY->( DbSetOrder(4) ) //MEY_FILIAL+MEY_ECFLAG+MEY_ECWS+MEY_ECMETO+MEY_ECCCHV
	
Begin Sequence  

	lValida := .F.     
	cAlias := Alltrim(MDY->MDY_ECALIA)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Localiza a primeira intermediaria para obter o numero do Orcamento.       ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( TempMEY->( DbSeek(xFilial("MEY") + "X" + MEY->(MEY_ECWS + MEY_ECMETO + MEY_ECCCHV)) ) )
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Inclusao e alteracao de Orcamento. Confirmacao de Pagamento.              ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LJ862GOrcam(oXML, aMatriz, aECCab, aECItens,;
		            aECParcelas, , @cMensagem) //FABIANA CRIAR UM PARAMETRO PRA PROSSEGURI
    	If !Empty(cMensagem) //verifica se pode prosseguir com a explos~]ao de venda
    		Break
    	Else
  
  			cAlias := Alltrim(MDY->MDY_ECALIA)    		
  
			(cAlias)->(DbSetOrder(nOrdem := Val(MEY->MEY_ECIND)))
    	
			cChave := &((cAlias)->(IndexKey()))    //Campos da Chave de Indice    
			
			If Empty(cChave) 
				ConOut("LOJA862: LJ862POrcmto: " + "Problemas na geração da chave de geração do orçamento pago. Não processado pagamento.")   //"Não encontrou Orçamento com a chave da intermediária!"   //"Não encontrou Orçamento com a chave da intermediária!"
				Break
			EndIf
    		
    	EndIf
    Else
    	cChave := TempMEY->MEY_ECVCHV   
    	nOrdem := Val(TempMEY->MEY_ECIND)
    EndIf	
    
    (cAlias)->( DbSetOrder(nOrdem) )

    If  !( (cAlias)->( DbSeek(cChave) ) )
    //Verifica se o orçamento não foi excluído para então posionar em um existem
    	lAchou := .F.
    
		Do While !lAchou .AND.  ;
			TempMEY->( MEY_FILIAL+MEY_ECFLAG+MEY_ECWS+MEY_ECMETO+MEY_ECCCHV) == ;
			 (xFilial("MEY") + "X" + MEY->(MEY_ECWS + MEY_ECMETO + MEY_ECCCHV))
			
			If !( RTrim(Posicione("MF5",1,xFilial("MF5")+"SL1"+RTrim(cChave),"MF5_ECSTAT")) $ _ECSTATUS_CANCELADO )
				cMensagem := "LOJA862: LJ862POrcmto: " + STR0033    //"Não encontrou Orçamento com a chave da intermediária!"
				Break
			Else
				TempMEY->(DbSkip(1))
				cChave := TempMEY->MEY_ECVCHV 
				lAchou := SL1->( DbSeek(cChave) )   
			EndIf
		
		EndDo

		If !lAchou .and. !Empty(cChave)	    
			cMensagem := "LOJA862: LJ862POrcmto: " + STR0033    //"Não encontrou Orçamento com a chave da intermediária!"
			Break
		ElseIf !lAchou .AND. Empty(cChave)
		//Excluído e confirmado pagamento diretamente
		
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Inclusao e alteracao de Orcamento. Confirmacao de Pagamento.              ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			LJ862GOrcam(oXML, aMatriz, aECCab, aECItens,;
			            aECParcelas, , @cMensagem) //FABIANA CRIAR UM PARAMETRO PRA PROSSEGURI
	    	If !Empty(cMensagem) //verifica se pode prosseguir com a explos~]ao de venda
	    		Break
	    	Else
	  
	  			cAlias := Alltrim(MDY->MDY_ECALIA)    		
	  	    	
				cChave := &((cAlias)->(IndexKey()))    //Campos da Chave de Indice    
				
				If Empty(cChave) 
					ConOut("LOJA862: LJ862POrcmto: " + STR0069)   //"Problemas na geração da chave de geração do orçamento pago. Não processado pagamento."
					Break
				EndIf
	    		
	    	EndIf		
		EndIf


	EndIf
    
    If  Empty(Posicione("MF5",1,xFilial("MF5")+"SL1"+SL1->(L1_FILIAL+L1_NUM),"MF5_ECPEDI"))
    	cMensagem := "LOJA862: LJ862POrcmto: " + STR0034   //"Sem o pedido e-commerce gravado na MF5!"
    	Break
    EndIf	
    
    If  (MF5->MF5_ECPAGO == "1")
    	cMensagem := "LOJA862: LJ862POrcmto: " + STR0035 + SL1->L1_NUM   //"Orçamento já com confirmação de pagamento! Orçamento: "
    	lValida := .T.
    	Break
    EndIf
    
    If  !( MF5->(SoftLock("MF5")) )
    	cMensagem := "LOJA862: LJ862POrcmto: " + STR0036 + SL1->L1_NUM   //"Não foi possível travar a MF5! Orçamento: "
    	Break
    EndIf
    
    If  !( SL1->(SoftLock("SL1")) )
    	cMensagem := "LOJA862: LJ862POrcmto: " + STR0039 + SL1->L1_NUM     //"Não foi possível travar o registro do Orçamento! Orçamento: "
    	Break
    EndIf
    
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Gravacao dos dados extras na SL4.                                              ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    LJ862GrvSL4(SL1->L1_NUM, aECParcelas)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Libera o Orcamento para gerar o Pedido para boleto bancario e para cartao pago.³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    RecLock("SL1",.F.)
    SL1->L1_SITUA  := "RX"             //Libera para o LJGRVBatch
    SL1->L1_SERPED := SuperGetMV("MV_LJECOM5",,"EC0")
    SL1->L1_DOCPED := NxtSX5Nota(SuperGetMV("MV_LJECOM5",,"EC0"),.T.,"1")  //Obtem a proxima numeracao da serie e-Commerce
    MsUnLock()

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Grava no MF5 o numero do título.                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    MF5->( RecLock("MF5",.F.) )
   	MF5->MF5_ECPREF := SL1->L1_SERPED
   	MF5->MF5_ECTITU := SL1->L1_DOCPED
   	MF5->MF5_ECSTAT := "7"  //Marca que recebeu do e-commerce o pagamento
   	MF5->MF5_ECSTAX := "7"  //Marca tambem a copia para nao enviar de volta para o e-commerce.
   	MF5->MF5_ECPAGO := "1"  //Configura como pago o pedido.
    MF5->( MsUnLock() )
		
End Sequence

Return Empty(cMensagem)        

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862GrvSL4º Autor ³ Antonio C Ferreira º Data ³  04/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gravacao dos dados extras da SL4.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cL1Num  - Numero do Orcamento                               º±±
±±º          ³ aSL4 - parcelas com os dados a serem gravados na SL4        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862GrvSL4(cL1Num, aSL4)

Local nA            //Contador do comando For
Local nB            //Contador do comando For

Default cL1Num := ""
Default aSL4   := {}
    
For nA := 1 to Len(aSL4)
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta as variaveis de memoria para analise.                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nB := 1 to Len(aSL4[nA])
	    If  (ValType(aSL4[nA][nB][2]) == "D")
			&("M->" + aSL4[nA][nB][1] + " := CtoD('" + DtoC(aSL4[nA][nB][2]) + "')")
		ElseIf (ValType(aSL4[nA][nB][2]) $ "CNL")
			&("M->" + aSL4[nA][nB][1] + " := " + ValToSQL(aSL4[nA][nB][2]))
		EndIf	 
	Next nB
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Posiciona a SL4.                                                          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	DbSelectArea("SL4")
   	DbSetOrder(1) //L4_FILIAL+L4_NUM+L4_ORIGEM
   
	If  !( DbSeek(xFilial("SL4")+cL1Num) )
    		cMensagem := "LOJA862: LJ862POrcmto: " + STR0040 + cL1Num     //"Não encontrou os Pagamentos do Orçamento (SL4)! Orçamento: "
    		Break
   	EndIf
                     
    While !( Eof() ) .And. (L4_FILIAL+L4_NUM == xFilial("SL4")+cL1Num)

	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Localiza a SL4 correspondente.                                            ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	If  (SL4->L4_FORMA != M->L4_FORMA)
    		DbSkip()
    		Loop
    	EndIf
    	
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Altera os dados de pagto na SL4 exceto os campos relacionados na condicao.³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	RecLock("SL4",.F.)
    	
    	For nB := 1 to Len(aSL4[nA])            
    	    If  !(Alltrim(aSL4[nA][nB][1]) $ "L4_FILIAL|L4_NUM|L4_DATA|L4_VALOR|L4_FORMA|L4_ADMINIS") .And. (FieldPos(aSL4[nA][nB][1]) > 0)
				FieldPut(FieldPos(aSL4[nA][nB][1]), aSL4[nA][nB][2]) 
			EndIf	
		Next nB
    	
    	MSUnLock()
    	
    	DbSkip()
    End	
   
Next nA

Return .T.
	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862GOrcamº Autor ³ Antonio C Ferreira º Data ³  25/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Importacao e geracao do Orcamento X Pedido de Venda.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oXML  - Objeto que contem os dados do XML da importacao     º±±
±±º          ³ aMatriz - matriz com os dados do XML para funcao especifica º±±
±±º          ³ aECCab - matriz com os dados do cabecalho do orcamento      º±±
±±º          ³ aECItens - matriz com os dados dos itens do orcamento       º±±
±±º          ³ aECParcelas - matriz com os dados das parcelas do orcamento º±±
±±º          ³ cXML - XML e-Commerce que ira gerar o cadastro no Protheus  º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862GOrcam(oXML, aMatriz, aECCab, aECItens,;
                            aECParcelas, cXML, cMensagem)

Local nA             := 0                        //Contador do comando For
Local nB             := 0                        //Contador do comando For
Local nLenAECCab     := Len(aECCab)              //Tamanho de aECCab
Local cLogPath       := SuperGetMV("MV_LOGPATH",,"LOGS")   //Pasta para gravacao do log de erro pela funcao Mostraerro().

Local cProdEmbalagem := SuperGetMV("MV_LJECOMP",,"000000000000001")		// Codigo de Produto para Embalagem para produto Presente
                   
Local nReg           := 0                        //Grava o ultimo recno existente para verificar depois se o registro foi incluido
Local nValor         := 0	                     //Valor do produto presente
Local nQtde          := 0	                     //Qtade do produto presente
Local cTES           := SuperGetMV("MV_LJTESPE",,"")    //TES para geracao do pedido de venda
Local cCEP           := Alltrim(oXML:_clsPedido:_CEP:TEXT)  //Cep do endereco de entrega
Local nItem          := 0                        //Numero de itens do orcamento
Local cCliente       := ""                       //Codigo do cliente
Local cLoja          := ""                       //Loja do cliente
Local cRastro		 := SuperGetMV("MV_RASTRO")			// Verifica se a rastreabilidade esta' habilitada.
Local cOrcamento     := ""                       //Codigo do Orcamento criado pelo execauto()

Local aCampos        := {}                      //campos extras para gravacao especifica.

Local aSL4Aux        := {}                      //Matriz auxiliar para obter os dados da parcela (SL4)
Local aSL4           := {}                      //Matriz com todas as parcelas do Orcamento (SL4) 
Local lNovo       := .T. 
Local cKey		:= ""
Local aAreaMEY		:= {}
Local nRegMey		:= 0   
Local cMeyEcSeq		:= ""
Local cIndice		 := ""
Local dDtEmissao	:= CtoD("") //Data de Emissão do Pedido 



Private lMsHelpAuto  := .T.      // Variavel de controle interno do ExecAuto
Private lMsErroAuto  := .F.      // Variavel que informa a ocorrencia de erros no ExecAuto

Private INCLUI 		 := .T.      // Variavel necessaria para o ExecAuto identificar que se trata de uma inclusao
Private ALTERA 		 := .F.      // Variavel necessaria para o ExecAuto identificar que se trata de uma inclusao

Default oXML        := nil
Default aMatriz     := {}
Default aECCab      := {}
Default aECItens    := {}
Default aECParcelas := {}
Default cXML        := ""
Default cMensagem   := ""

__cUserID      := SuperGetMV("MV_LJECOMU",,"000001")    //UserID do Usuario do eCommerce.
cUserName      := SuperGetMV("MV_LJECOMN",,"ECOMMERCE") //Nome do Usuario do eCommerce.
M->AUTRESERVA  := SuperGetMV("MV_LJECOM1",,"000001")    //Codigo da Loja para a reserva do estoque do Orcamento

lECLJAUTO      := .T.      //Execauto para eCommerce

cMensagem      := ""

Begin Sequence

    
	lNovo := .T. 
	LjPreparaWs(cEmpAnt, cFilAnt)

	SetFunName("LOJA701") 

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
 //³ Localiza a primeira intermediaria para obter o numero do Orcamento.       ³
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	
    cKey		:= RTrim(xFilial("MEY") + "X" + MEY->(MEY_ECWS + MEY_ECMETO + MEY_ECCCHV))
	aAreaMEY		:= MEY->(GetArea())
	nRegMey		:= MEY->(Recno())    
	cMeyEcSeq := MEY->MEY_ECSEQ 
	
 	MEY->(DbSetOrder(4))
    If MEY->( DbSeek(cKey)   )
    	Do While lNovo .And.  MEY->(!Eof()) .And. ;
    			RTrim(MEY->(MEY_FILIAL+MEY_ECFLAG+MEY_ECWS+MEY_ECMETO+MEY_ECCCHV))  ==  ;
    			cKey
    		lNovo := !(MEY->MEY_ECSEQ <> cMeyEcSeq .And. !Empty(MEY->MEY_ECVCHV) )
    		
    		If !lNovo    		  
    			cKey := MEY->MEY_ECVCHV
    			cIndice := MEY->MEY_ECIND
    			Exit
    		EndIf
    		
    		MEY->(DbSkip(1))
    	EndDo
    EndIf
    
    RestArea(aAreaMEY)
    MEY->(DbGoTo(nRegMey)) 
    
    If !lNovo
    	//conout("localizando sl1")
  		SL1->( DbSetOrder(Val(cIndice)) )

    	If  !( SL1->( DbSeek(cKey) ) )  
    		If !( RTrim(Posicione("MF5",1,xFilial("MF5")+"SL1"+RTrim(cKey),"MF5_ECSTAT")) $ _ECSTATUS_CANCELADO )
    	   		cMensagem := "LOJA862GOrcam - Não localizado orçamento - chave " + cKey        
    	   		
    	   		ConOut("LOJA862GOrcam - Não localizado orçamento - chave " + cKey)
    			//lNovo := .T.
    			Break 
   	   		Else
				DbSelectArea("SL1")
				SL1->(DbSetorder(0))
				SL1->(DbGoBottom())
   	   		EndIf
   		Else
			cOrcamento := SL1->L1_NUM
	   		Break  
    	EndIf	

    EndIf
  
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define a estrutura da Matriz aMatriz para facilitar a programacao.        ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	//aadd(aMatriz, {cAlias, nA, {Alltrim(drCmpECCAMP), xValor}})
	#Define drCmpALIAS  aMatriz[nA][1]
	#Define drCmpLINHA  aMatriz[nA][2]
	#Define drCmpCAMPO  aMatriz[nA][3][nB][1]
	#Define drCmpVALOR  aMatriz[nA][3][nB][2]
	#Define drCmpEXTRA  aMatriz[nA][4][nB][1]
	#Define drCmpVLREX  aMatriz[nA][4][nB][2]

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Obtem na Matriz Extra os dados de produto de embalagem e da MF5.          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    For nA := 1 to Len(aMatriz)
    	For nB := 1 to Len(aMatriz[nA][4])
            If  (drCmpEXTRA == "PRESENTEVL")
                nValor := drCmpVLREX
            ElseIf  (drCmpEXTRA == "PRESENTEQT")
                nQtde  += drCmpVLREX
            ElseIf  (Left(drCmpEXTRA,4) == "MF5_")
                aadd(aCampos, {drCmpEXTRA, drCmpVLREX})
            EndIf    
		Next nB
	Next nA

    If  (nQtde > 0)

	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Adiciona o produto de embalagem com a soma das qtdes dos produtos para    ³
	 //³ presente.                                                                 ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aECItens,{})
		
		nItem := Len(aECItens)
		
		aAdd(aECItens[nItem], {"LR_PRODUTO",  cProdEmbalagem 	,NIL})
		aAdd(aECItens[nItem], {"LR_ITEM"   ,  StrZero(nItem,2)	,NIL})
		aAdd(aECItens[nItem], {"LR_QUANT"  ,  nQtde 			,NIL})
		aAdd(aECItens[nItem], {"LR_VRUNIT" ,  nValor	  		,NIL})
		aAdd(aECItens[nItem], {"LR_DESC"   ,  0               	,NIL})
		aAdd(aECItens[nItem], {"LR_VALDESC",  0               	,NIL})
		aAdd(aECItens[nItem], {"LR_TES"    ,  cTES           	,NIL})
		aAdd(aECItens[nItem], {"LR_ENTREGA",  "3"              	,NIL})
		aAdd(aECItens[nItem], {"LR_VDMOST" ,  "N"              	,NIL})
		aAdd(aECItens[nItem], {"LR_DESCPRO",  0               	,NIL})
		aAdd(aECItens[nItem], {"LR_ECPRESN",  "2"              	,NIL})
		aAdd(aECItens[nItem], {"LR_ECSEDEX",  ""               	,NIL})
		aAdd(aECItens[nItem], {"LR_LOTECTL",  ""              	,NIL})
		aAdd(aECItens[nItem], {"LR_NLOTE"  ,  ""               	,NIL})
		aAdd(aECItens[nItem], {"LR_LOCAL"  ,  ""               	,NIL})

	EndIf			   
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Posiciona a Tabela de Range de CEP (MF6) para definir a reserva de estoque³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MF6")
	DbSetOrder(2)  //MF6_FILIAL+MF6_CEPATE
	
	If  Empty(cCEP)
		cMensagem := "LOJA862: LJ862GOrcmto: " + STR0041    //"CEP de entrega não definido no XML do pedido do e-commerce!"
		Break
	EndIf
	
	Set SoftSeek ON  //Busca o proximo valor maior que a chave passada, se nao encontrar o valor exato.
	DbSeek(xFilial("MF6")+cCEP)
	Set SoftSeek OFF
	
	If  Eof()  //Verifica pelo fim de arquivo e nao se encontrou o registro.
		cMensagem := "LOJA862: LJ862GOrcmto: " + STR0042 + cCEP     //"Range de CEP (MF6) não definido! Cep do Pedido: "
		Break
	EndIf
	
	SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
	
	For  nItem := 1 to Len(aECItens)
	     If  !( SB2->( DbSeek(PadR(MF6->MF6_XFILIA,Len(SB2->B2_FILIAL))+PadR(aECItens[nItem][1][2],Len(B2_COD))+MF6->MF6_LOCAL) ) )  
			 cMensagem += "LOJA862: LJ862GOrcmto: " + STR0043 + MF6->MF6_XFILIA + STR0044 + MF6->MF6_LOCAL + STR0045 + Alltrim(aECItens[nItem][1][2]) + CRLF   //"Armazém não encontrado para o produto! Filial: "##" Produto: "
	     EndIf
	Next nItem

	If  !( Empty(cMensagem) )  
		Break
	EndIf

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Verifica o codigo do cliente                                              ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    For nA := 1 to nLenAECCab
    	If  (Alltrim(aECCab[nA][1]) == "LQ_CLIENTE")
    		cCliente := aECCab[nA][2]
    	ElseIf (Alltrim(aECCab[nA][1]) == "LQ_LOJA") 
    		cLoja := aECCab[nA][2]
    	ElseIf(Alltrim(aECCab[nA][1]) == "LQ_EMISSAO") 
    		dDtEmissao := aECCab[nA][2] // Verificação da data de emissão para montagem das parcelas
    	EndIf
    	If  !( Empty(cCliente) ) .And. !( Empty(cLoja) ) .And. !Empty(dDtEmissao)
    	 	Exit
    	EndIf 	
    Next nA

    If  Empty(cCliente) .Or. Empty(cLoja)
		cMensagem := "LOJA862: LJ862GOrcmto: " + STR0061 //"Código ou Loja do Cliente não localizado na Matriz do Cabeçalho do ExecAuto!"
		Break
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MONTAGEM DOS PAGAMENTOS	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    nQtdParc  := Val(oXML:_clsPedido:_QtdeParcelas:TEXT)
    nQtdParc  := If(nQtdParc<=0, 1, nQtdParc)
	                               
	For nA := 1 to Len(aECParcelas)
	                                          
	    cL4Forma  := LJ862Vlr(aECParcela[nA], "L4_FORMA", "")
	    dL4Data	   := dDtEmissao
	    nL4Valor  := LJ862Vlr(aECParcela[nA], "L4_VALOR", 0)
	    cL4AdmFin := ""

	    cCodEComm := oXML:_clsPedido:_Operadora:TEXT

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A funcao LJ862Parcel, retorna os dados de cada parcela³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AllTrim(cL4Forma) $ "CC|CD|CO|FI"
			aParcelas := LJ862Parcel( cL4Forma, nL4Valor, dL4Data, nQtdParc, cCodEComm, @cL4AdmFin, @cMensagem )
		Else
			aParcelas := LJ862Parcel( cL4Forma, nL4Valor, dL4Data, nQtdParc,,, @cMensagem  )
		EndIf
		
		If  !( Empty(cMensagem) )
			Break
		EndIf	
	
		For nB := 1 to Len(aParcelas)
	
			aSL4Aux := {}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Alimenta aSL4Aux³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Aadd( aSL4Aux, {"L4_FORMA", cL4Forma, NIL}																  							)	// L4_FORMA
			Aadd( aSL4Aux, {"L4_VALOR", aParcelas[nB][1], NIL}																					)	// L4_VALOR
			Aadd( aSL4Aux, {"L4_CGC", LJ862Vlr(aECParcela[nA], "L4_CGC", ""), NIL}   														)	// L4_CGC
			Aadd( aSL4Aux, {"L4_SITUA", Space(0), NIL}		   											 		 								)	// L4_SITUA
			Aadd( aSL4Aux, {"L4_DATA", aParcelas[nB][3], NIL}														 							)	// L4_DATA
			Aadd( aSL4Aux, {"L4_ADMINIS", cL4AdmFin, NIL}	   														  							)	// L4_ADMINIS
			Aadd( aSL4Aux, {"L4_NUMCART", PADR(LJ862Vlr(aECParcela[nA], "L4_NUMCART", ""), TamSx3("L4_NUMCART")[1]), NIL}	  					)	// L4_NUMCART
			Aadd( aSL4Aux, {"L4_AGENCIA", PADR(LJ862Vlr(aECParcela[nA], "L4_AGENCIA", ""), TamSx3("L4_AGENCIA")[1]), NIL}						)	// L4_AGENCIA
			Aadd( aSL4Aux, {"L4_CONTA", PADR(LJ862Vlr(aECParcela[nA], "L4_CONTA", ""), TamSx3("L4_CONTA")[1]), NIL}  				        )	// L4_CONTA	
			Aadd( aSL4Aux, {"L4_TELEFON", PADR(LJ862Vlr(aECParcela[nA], "L4_TELEFON", ""), TamSx3("L4_TELEFON")[1]), NIL}						)	// L4_TELEFON
			Aadd( aSL4Aux, {"L4_DOCTEF", PADR(LJ862Vlr(aECParcela[nA], "L4_DOCTEF", ""), TamSx3("L4_DOCTEF")[1]), NIL} 					    )	// L4_DOCTEF
			Aadd( aSL4Aux, {"L4_AUTORIZ", PADR(LJ862Vlr(aECParcela[nA], "L4_AUTORIZ", ""), TamSx3("L4_AUTORIZ")[1]), NIL}						)	// L4_AUTORIZ
			Aadd( aSL4Aux, {"L4_NSUTEF", PADR(LJ862Vlr(aECParcela[nA], "L4_NSUTEF", ""), TamSx3("L4_NSUTEF")[1]), NIL}						)	// L4_NSUTEF
			Aadd( aSL4Aux, {"L4_INSTITU", PADR(LJ862Vlr(aECParcela[nA], "L4_INSTITU", ""), TamSx3("L4_INSTITU")[1]), NIL}						)	// L4_INSTITU
			Aadd( aSL4Aux, {"L4_VENDTEF", IIF(AllTrim(cL4Forma) $ "CC|CD", "S", ""), NIL}										   				)	// L4_VENDTEF
			Aadd( aSL4Aux, {"L4_ACRSFIN", 0, NIL}                                                                         						)	// L4_ACRSFIN
			Aadd( aSL4Aux, {"L4_FORMAID", "", NIL}                                                                         						)	// L4_FORMAID
			
			Aadd( aSL4, aSL4Aux )
		Next nB                     
	    
    Next nA
    
    If  !( Empty(cL4AdmFin) )
        Aadd(aECCab, {"LQ_ADMFIN", cL4AdmFin, NIL} ) //Adiciona a Administradora Financeira
    EndIf

	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Verifica se utiliza Lote, caso positivo, irá retornar mensagem de erro!   ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( Empty(cMensagem) ) .Or. (cRastro == "S") .And. !( LJ862Lote(aECItens, @cMensagem) )
		Break
	EndIf
    
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Processa o ExecAuto                                                       ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SL1")
	DbSetorder(0)
	DbGoBottom()
	nReg := Recno()
	
	DbSetorder(1)
	
	MSExecAuto({|a,b,c,d,e,f,g,h| Loja701(a,b,c,d,e,f,g,h)},.F.,3,"","",{},aECCab,aECItens,aSL4)
	
	MEY->( SoftLock('MEY') )  //Volta a trava logica da tabela intermediaria que o execauto() retira apos execucao.
	
	If  lMsErroAuto .Or. !( Empty(cMensagem) )
		If  !( Empty(cMensagem) )  //Pode retornar erro de execucao nao reportado pelo ExecAuto()
			cMensagem := "LOJA862: LJ862GOrcmto: " + STR0046 + CRLF + cMensagem       //"Erro no ExecAuto"
		Else	
	    	cMensagem := "LOJA862: LJ862GOrcmto: " + STR0046 + CRLF + MostraErro(cLogPath)    //"Erro no ExecAuto"
	    EndIf	
	
	    ConOut("...")
		ConOut(cMensagem)
    	ConOut("...")
    	
		DisarmTransaction() // Libera sequencial
		RollBackSx8()         
		Break
	EndIf    
	
	DbSelectArea("SL1")
	
    If  (nReg >= Recno()) .Or. (Alltrim(L1_CLIENTE) <> Alltrim(cCliente)) .And. (L1_LOJA <> cLoja) //Pode ocorre problema no TudoOk() e nao gerar mensagem de erro e nao gravar o Orcamento.
		cMensagem := "LOJA862: LJ862GOrcmto: " + STR0046 + CRLF + STR0062       //"Erro no ExecAuto"##" Registro não foi incluido pelo ExecAuto!"

	    ConOut("...")
		ConOut(cMensagem)
    	ConOut("...")
    	
		DisarmTransaction() // Libera sequencial
		RollBackSx8()         
		Break
    EndIf

    ConOut("...")
	cOrcamento := SL1->L1_NUM
	Conout("LOJA862: LJ862GOrcmto: " + STR0047)     //"Sucesso na execução do ExecAuto"
	ConOut(STR0048 + cOrcamento)   //"Orçamento: "
    ConOut("...")
    
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Grava o XML dos dados relacionando a tabela da base.                      ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LJ862MF5("3", "SL1", Val(MEY->MEY_ECIND), cXML, aCampos, nil, @cMensagem)	
	
	If  !( Empty(cMensagem) )
	    Break
	EndIf    

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Verifica se gerou Solicitacao de Compras para Orcamento para enviar e-mail³
 //³ de aviso para o usuario.                                                  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	SC1->( DbSetOrder(10) ) //C1_FILIAL+C1_ORCAM

    If  SC1->( DbSeek(xFilial("SC1")+cOrcamento) )
    	SC1->( LJ862SCMAIL(cOrcamento) )
    EndIf
    
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Para cartao de credito e debito que nao foi pago fica no Orcamento        ³
 //³ aguardando a confirmacao de pagamento.                                    ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If  (oXML:_clsPedido:_FormaPgto:TEXT != "2") .And. ;  //Pagamento diferente de Boleto (Cartao Debito ou Credito) ...
            ( !((oXML:_clsPedido:_PedidoStatus:TEXT == "7") .And. ("TESTE" $ GETENVSERVER())) .Or.; //... tem que ter Status 7 de pagamento e ser ambiente de TESTE para continuar ...
             (!("TESTE" $ GETENVSERVER()) .And. Empty(oXML:_clsPedido:_Cartao:_CarAutorizacaoCodigo:TEXT)) ) .Or.; // ... Ou se nao for ambiente de Teste, tem que ter a Autorizacao de pagamento do Cartao para Continuar.
    	(oXML:_clsPedido:_PedidoStatus:TEXT $ _ECSTATUS_CANCELADO) //4-Problemas / 5-Cancelado / 8-AnaliseRisco
    	Break
    EndIf
    
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Gravacao dos dados extras na SL4.                                              ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    LJ862GrvSL4(SL1->L1_NUM, aSL4)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Libera o Orcamento para gerar o Pedido para boleto bancario e para cartao pago.³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    RecLock("SL1",.F.)
    SL1->L1_SITUA  := "RX"             //Libera para o LJGRVBatch
    SL1->L1_SERPED := SuperGetMV("MV_LJECOM5",,"EC0")
    SL1->L1_DOCPED := NxtSX5Nota(SuperGetMV("MV_LJECOM5",,"EC0"),.T.,"1")  //Obtem a proxima numeracao da serie e-Commerce
    MsUnLock()

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Grava no MF5 o numero do título.                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    MF5->( RecLock("MF5",.F.) )
   	MF5->MF5_ECPREF := SL1->L1_SERPED
   	MF5->MF5_ECTITU := SL1->L1_DOCPED
   	MF5->( MsUnLock() )
   	
End Sequence

lECLJAUTO   := .F.      //Execauto para eCommerce

Return Empty(cMensagem)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862Lote  º Autor ³ Antonio C Ferreira º Data ³  03/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se os Produtos utilizam Lote e se tem saldo.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aECItens - matriz com os dados dos itens do orcamento       º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862Lote(aECItens, cMensagem)

Local aArea        := GetArea()                        //Salva a area atual

Local nA           := 0                                 //Contador do comando For
Local nB           := 0                                 //Contador do comando For
Local nLenAECItens := Len(aECItens)                     //Tamanho do aECItens
Local cRastro	   := SuperGetMV("MV_RASTRO")			// Verifica se a rastreabilidade esta' habilitada.
Local cEstNeg  	   := SuperGetMV("MV_ESTNEG")			// Verifica se e' permitido fazer movimentacoes de estoque com saldo negativo.
Local cProduto     := ""                               //Codigo do produto para verificar se possui rastreabilidade

Default aECItens   := {}
Default cMensagem  := ""

Begin Sequence
        
    // Realiza a validacao de saldo por lote (Tabela SB8).    
	If  !( (cRastro == "S") .And. (cEstNeg == "N") )
	    Break
	EndIf
	
	For nA := 1 to nLenAECItens
		                
		cProduto := ""
		
		For nB := 1 to Len(aECItens[nA])
		    
		    If  (Alltrim(aECItens[nA][nB][1]) == "LR_PRODUTO")
		        cProduto := Alltrim(aECItens[nA][nB][2])
		        Exit
		    EndIf
		    
		Next nB      

		If  !( Empty(cProduto) ) .And. Rastro(cProduto)               
			cMensagem := "LOJA862:LJ862Lote: " + STR0063 + cProduto   //"Produto e-Commerce não pode conter rastreabilidade! Produto: "
			Break
		EndIf

	Next nA				

End Sequence

RestArea(aArea)
					
Return Empty(cMensagem)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862Parcelº Autor ³ Antonio C Ferreira º Data ³  25/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica as parcelas do e-Commerce para gerar a SL4.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cFormaPgto - Forma de pagamento                             º±±
±±º          ³ nTotal - Valor total do orcamento                           º±±
±±º          ³ dData - Data com a adicao de dias da virada do recebimento  º±±
±±º          ³ nQtdParc - Quantidade de parcelas                           º±±
±±º          ³ cCodEComm - Codigo da administradora no e-commerce          º±±
±±º          ³ cL4AdmFin - Retorna o codigo da administradora no Protheus  º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862Parcel(cFormaPgto, nTotal, dData, nQtdParc,;
                            cCodEComm, cL4AdmFin, cMensagem)

Local nTamE1Dup := TamSX3("E1_PARCELA")[1]	// Tamanho do campo no SX3
Local aParcelas	:= {}						// Array de parcelas do pagamento
Local aArea		:= GetArea()				// Armazena a area ativa
Local nVlrSobra	:= 0						// Resto do total apos ter dividido as parcelas
Local nVlrParc	:= 0						// Valor de cada parcela
Local nVlrReal	:= 0						// Valor Real sem as taxas cobradas pela administradora financeira
Local nTaxa	 	:= 0						// Taxa cobrada pela Adm.Fin.
Local nDias	 	:= 0						// Data com a adicao de dias da virada do recebimento
Local cCodCli	:= SA1->A1_COD				// Codigo do cliente
Local cLojCli	:= SA1->A1_LOJA				// Loja do cliente
Local cNomeCli	:= SA1->A1_NOME				// Nome do cliente
Local nI		:= 0						// Contador do For

Default cFormaPgto := "R$"
Default nTotal	   := 0
Default dData 	   := dDataBase
Default nQtdParc   := 1
Default cCodEComm  := " "
Default cL4AdmFin  := " "
Default cMensagem  := " "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|		-ESTRUTURA aParcelas-		|
//|aParcelas[1] VALOR PARCELA		|		
//|aParcelas[2] VALOR REAL			|		
//|aParcelas[3] DATA DE VENCIMENTO	|
//|aParcelas[4] PARCELA				|
//|aParcelas[5] COD. CLIENTE		|
//|aParcelas[6] LOJA CLIENTE		|
//|aParcelas[7] NOME CLIENTE		|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    

If nQtdParc == 0
	nQtdParc := 1
EndIf

Begin Sequence

	If AllTrim(cFormaPgto) $ "CC|CD|FI|CO"

		DbSelectArea("SAE")
		DbSetOrder(1) //AE_FILIAL + AE_COD
		DbGoTop()
		
		While !( Eof() )
		
		    If  (StrZero(Val(AE_ECCODIG),Len(AE_ECCODIG)) == StrZero(Val(cCodEComm),Len(AE_ECCODIG)))
		        Exit
		    EndIf
		    
		    DbSkip()
		End    
		
		If  !( Eof() ) .And. (StrZero(Val(AE_ECCODIG),Len(AE_ECCODIG)) == StrZero(Val(cCodEComm),Len(AE_ECCODIG)))
			If  (SAE->AE_FINPRO == "N")
				nDias		:= SAE->AE_DIAS

                If SAE->( ColumnPos("AE_LOJCLI") ) > 0 .And. !Empty(SAE->AE_CODCLI) .And. !Empty(SAE->AE_LOJCLI)

                    cCodCLi := SAE->AE_CODCLI
                    cLojCli := SAE->AE_LOJCLI
                Else

                    //Inclui Administradora como cliente para geração do contas a receber
                    L070IncSA1()

                    cCodCLi := SAE->AE_COD
                    cLojCli := "01"
                EndIf

				cNomeCli	:= SAE->AE_DESC
			EndIf

			nTaxa     := SAE->AE_TAXA
			cL4AdmFin := SAE->AE_COD
		Else
			cMensagem := "LOJA862: LJ862Parcel: " + STR0059 + cCodEComm  //"Administradora não localizada referente ao código e-Commerce: "
			ConOut(cMensagem)
			Break
		EndIf
	EndIf
	
	nVlrReal	:= nTotal								// Valor Real sem as taxas cobradas pela administradora financeira
	nVlrParc 	:= Round( (nTotal / nQtdParc), 2 ) 	// Valor de cada parcela
	nVlrSobra 	:= nTotal - (nVlrParc * nQtdParc) 		// Resto do total apos ter dividido as parcelas
	dData 		+= nDias								// Data com a adicao de dias da virada do recebimento
	
	For nI := 1 To nQtdParc
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A partir da segunda parcela, adicionamos 30d a data de cada parcela³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nI > 1
			dData += 30
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adicionamos a sobra ao valor da ultima parcela³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nI == nQtdParc
			nVlrParc += nVlrSobra
		EndIf
	
		Aadd( aParcelas,	{	nVlrParc   			,;
								nVlrReal			,;
								dData				,;
								PadL(nI, nTamE1Dup)	,;
								cCodCli				,;
								cLojCli				,;
								cNomeCli			})
	
	Next nI
	
End Sequence        

RestArea(aArea)

Return aParcelas

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862Vlr    º Autor ³ Antonio C Ferreira º Data ³  25/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se retorna o valor na Matriz ou, caso nao tenha, o  º±±
±±º          ³ valor Padrao.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aMatriz - matriz que ira receber o valor passado no parametroº±±
±±º          ³ cCampo - Campo sendo verificado se existe na matriz          º±±
±±º          ³ xDefault - valor padrao caso nao encontre na matriz          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862Vlr(aMatriz, cCampo, xDefault)

Local nPos   := Ascan(aMatriz, {|x| Alltrim(x[1]) == Alltrim(cCampo)})  //Posicao do campo na matriz
Local xValor := nil          //Valor obtido da matriz ou valor padrao

Default aMatriz  := {}
Default cCampo   := ""
Default xDefault := ""

If  (nPos <= 0)
    xValor := xDefault
Else 
	xValor := aMatriz[nPos][2]
EndIf     

Return xValor

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862ECAuto º Autor ³ Antonio C Ferreira º Data ³  25/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o valor da variavel _LJECAUTO.                       º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function LJ862ECAuto()

Return lECLJAUTO

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LJ862SCMAIL³ Autor ³ Eduardo Vicente       ³ Data ³ 26/05/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de alerta de solicitação de compras.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrcamento - Numero do orcamento que esta gerando a         ³±±
±±³          ³              solicitacao de compras                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function LJ862SCMAIL(cOrcamento)
//Variaveis de Configuração de Conexão\e-mail
local cConta	:= ""   // Conta de e-mail
Local cPsw      := ""	// Senha de acesso Ex.: 123abc
Local cServer   := "" 	// Ex.: smtp.dominio.br
Local lRelauth  := .F.	// Parametro que indica se existe autenticacao no e-mail
//Variaveis de
Local cTo    	:= ""	// E-mail de destino - Resposavel
Local cFrom	    := "" 	// e-mail utilizado no campo From'MV_RELACNT' ou 'MV_RELFROM' e 'MV_RELPSW'
Local cAssunto	:= ""	// Assunto do Email
Local cBody		:= ""	// HTML com corpo do email.
//Variaveis de controle e armazenamento.
Local aArea		:= GetArea()             

Default cOrcamento := ""

//Parametros de Configuração de E-mail
cConta		:= Trim(SuperGetMv('MV_RELACNT',,""))
cPsw 		:= Trim(SuperGetMv("MV_RELAPSW",,""))
cServer		:= Trim(SuperGetMv("MV_RELSERV",,""))
lRelauth 	:= SuperGetMv("MV_RELAUTH",, .F.)

//Definição de ajustes de e-mail
cAssunto	:= STR0050 + cOrcamento       //"Solicitação de Compras Pendente do Título nº "
cFrom	:= Trim(SuperGetMv("MV_RELFROM",,""))
cTo		:= SuperGetMv("MV_RELDEST",,"")

// Carrega Corpo do Email com HTML
cBody := LJ862PMAIL(cOrcamento)
					
LjEnvEmail(.F./*lSSL*/,.F./*lTLS*/,lRelauth,cFrom,cTo,/*cCC*/,/*cBCC*/,cAssunto,cBody,cServer,cPsw,/*cPorta*/,cConta,/*nTOUT*/,/*lGeraArq*/)

RestArea(aArea)

Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LJ862PMAIL³ Autor ³ Eduardo Vicente       ³ Data ³ 02/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a montagem do corpo de e-mail em HTML.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrcamento - Numero do orcamento que esta gerando a        ³±±
±±³          ³              solicitacao de compras                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ862PMAIL(cOrcamento)

Local cHTML		:= ""       // HTML de retorno
Local lLinha	:= .T.     //Intercala a cor da linha conforme muda o valor desta varivel de verdadeiro para falso.

Default cOrcamento := ""

ConOut("", "LOJA862: LJ862PMAIL: " + STR0058,"")        //"Gerando HTML - corpo do email"

cHTML:='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
cHTML+='<html xmlns="http://www.w3.org/1999/xhtml"> '
cHTML+='<head> '
cHTML+='<meta content="text/html; charset=ISO-8859-1" http-equiv="content-type"> '
cHtml+='<title>' + STR0051 + '</title> '        //"Lista de Solicitação de Compras - e-Commerce"
cHtml+=' </HEAD>
cHtml+='<body> '
cHtml+='<table Border="1">'

cHtml+='<tr>'
cHtml+='<td colspan="8" ALIGN="center"><B><FONT COLOR="#0000CD" FACE="Tahoma, Arial, sans-serif" SIZE="3">' + STR0051 + '</B></td>'    //"Lista de Solicitação de Compras - e-Commerce"
cHtml+='</tr>'

cHtml+='<tr style="background-color: rgb(198, 119, 79);">'
cHtml+='<td><font color="#ffffff"><b>' + STR0052 + '</b></font></td>'       //"Orçamento"
cHtml+='<td><font color="#ffffff"><b>' + STR0053 + '</b></font></td>'       //"NumeroSC"
cHtml+='<td><font color="#ffffff"><b>' + STR0054 + '</b></font></td>'       //"Data Necessidade"
cHtml+='<td><font color="#ffffff"><b>' + STR0055 + '</b></font></td>'       //"Prod. Codigo"
cHtml+='<td><font color="#ffffff"><b>' + STR0056 + '</b></font></td>'       //"Descrição Prod."
cHtml+='<td><font color="#ffffff"><b>' + STR0057 + '</b></font></td>'       //"Quantidade"
cHtml+='</tr>'

While SC1->( !(Eof()) .And. (C1_FILIAL == xFilial("SC1")) .And. (C1_ORCAM == cOrcamento) )

	If lLinha
		cHtml+='    	 	<tr style="background-color: rgb(255, 204, 102);"> '
	Else
		cHtml+='    	 	<tr style="background-color: rgb(255, 255, 153);">'
	EndIf
	cHtml+='				<td>' + SC1->C1_ORCAM			    +	'</td>'	
	cHtml+='				<td>' + SC1->C1_NUM  		     	+  	'</td>'
	cHtml+='				<td>' + DtoC(SC1->C1_DATPRF)   		+ 	'</td>'
	cHtml+='				<td>' +	SC1->C1_PRODUTO			    +	'</td>'
	cHtml+='				<td>' + Posicione("SB1",1,xFilial("SB1")+SC1->C1_PRODUTO,"B1_DESC") +	'</td>'
	cHtml+='				<td>' + Alltrim(Str(SC1->C1_QUANT)) +	'</td>'
	cHtml+='	</tr>'
	
	SC1->( DbSkip() )
	
	lLinha := !lLinha
End

cHtml+='</table>'
cHtml+='</body>'

cHtml+='</html>'

Return Alltrim(cHTML)      


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862VlOrc  º Autor ³ Vendas CRM         º Data ³  20/12/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verificação da Permissão da Validação do eCommerce.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oXML  - Objeto que contem os dados do XML da importacao      º±±
±±º          ³ aMatriz - matriz com os dados do XML para funcao especifica  º±±
±±º          ³ aECCab - matriz com os dados do cabecalho do orcamento       º±±
±±º          ³ aECItens - matriz com os dados dos itens do orcamento        º±±
±±º          ³ aECParcelas - matriz com os dados das parcelas do orcamento  º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                    º±±
±±º          ³ cChave    - Chave do orcamento                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862VlOrc(oXML, aMatriz, aECCab, aECItens,;
                            aECParcelas, cMensagem, cChave)

Default oXML        := nil
Default aMatriz     := {}
Default aECCab      := {}
Default aECItens    := {}
Default aECParcelas := {}
Default cMensagem   := ""
Default cChave		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se utiliza de um novo alias para nao desposicionar o MEY com o registro   ³
//³ travado.                                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cChave := ""
If  (Select("TempMEY") <= 0)
    ChkFile("MEY",, "TempMEY"/*Novo Alias*/)
EndIf    

TempMEY->( DbSetOrder(4) ) //MEY_FILIAL+MEY_ECFLAG+MEY_ECWS+MEY_ECMETO+MEY_ECCCHV
	
Begin Sequence

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Localiza a primeira intermediaria para obter o numero do Orcamento.       ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !( TempMEY->( DbSeek(xFilial("MEY") + "X" + MEY->(MEY_ECWS + MEY_ECMETO + MEY_ECCCHV)) ) )
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Inclusao e alteracao de Orcamento. Confirmacao de Pagamento.              ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	cMensagem := "LOJA862:  LJ862VlOrc " + "Não encontrou chave da intermediária. Integração de orçamento não enviada"    //"Não encontrou Orçamento com a chave da intermediária!"
    	Break
    EndIf	
    
    SL1->( DbSetOrder(Val(TempMEY->MEY_ECIND)) )

    If  !( SL1->( DbSeek(TempMEY->MEY_ECVCHV) ) )
    	cMensagem :=  "LOJA862:  " + FunName() + STR0033    //"Não encontrou Orçamento com a chave da intermediária!"
    	Break
    EndIf	
    
    cChave := TempMEY->MEY_ECVCHV
    
    If  Empty(Posicione("MF5",1,xFilial("MF5")+"SL1"+SL1->(L1_FILIAL+L1_NUM),"MF5_ECPEDI"))
    	cMensagem :=   "LOJA862:  LJ862VlOrc " + STR0034   //"Sem o pedido e-commerce gravado na MF5!"
    	Break
    EndIf	
    
    If  (MF5->MF5_ECPAGO <> "1") .Or.  ;
    	( Empty(  MF5->MF5_ECPREF ) .Or.    Empty(MF5->MF5_ECTITU )  )  //Fabiana
    	cMensagem :=  "LOJA862:  LJ862VlOrc " + "Orçamento sem com confirmação de pagamento! Orçamento: " + SL1->L1_NUM + ". Integração de orçamento não enviada"  //"Orçamento já com confirmação de pagamento! Orçamento: "
    	Break
    EndIf
             		
End Sequence

Return Empty(cMensagem) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862ClEnt  º Autor ³ Vendas CRM         º Data ³  17/02/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verificação do cadastro do endereço de entrega do cliente.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCliente -  Codigo do Cliente Original                       º±±
±±º          ³ cLoja - Loja do Cliente Original                             º±±
±±º          ³ aMatriz2 - matriz com os dados do Endereço de Entrega        º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ862ClEnt(cCliente, cLoja,aMatriz2, cMensagem)

Local nA           := 0          //Contador do comando For
Local nB           := 0          //Contador do comando For
Local cCNPJ 	   := ""         //Caso encontre o cliente ja cadastro pelo CNPJ ira passar o codigo do cliente para alteracao.

Local aDadosEnd := {{ "A1_END", ""},;
					{ "A1_MUN", ""},;
					{ "A1_EST", ""},;
					{ "A1_BAIRRO", ""},;
					{ "A1_COMPLEM", ""},;
					{"A1_CEP", ""}}            //Dados do cliente 
Local lInsere		:= .T.		//Insere Dados do Cliente

Local cLogPath      := SuperGetMV("MV_LOGPATH",,"LOGS")  //Pasta para gravacao do log de erro pela funcao Mostraerro().  
Local lCgcCpf		:= .T. //CGC CPF informado (default .T.)          
Local lIgual		:= .F.   
Local cLojaUlt		:= "" //Ultima Loja cadastrada
Local aCliEnt		:= {} //Cliente de entrega  
Local cMunic		:= "" //Municipio do Cliente
Local cEst			:= "" //Estado do Cliente
Local cFilSA1		:= xFilial("SA1")
Local nTamLoja		:= SA1->(TamSx3("A1_LOJA")[1])


Default cCliente 	:= ""        
Default cLoja     	:= ""
Default aMatriz2    := {} 

cCliente := PadR(cCliente, SA1->(TamSx3("A1_COD")[1]))



Begin Sequence

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define a estrutura da Matriz aMatriz para facilitar a programacao.        ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#Define drCmpALIAS2  aMatriz2[1]
	#Define drCmpLINHA2  aMatriz2[2]
	#Define drCmpCAMPO2  aMatriz2[3][nA][1]
	#Define drCmpVALOR2  aMatriz2[3][nA][2]
	#Define drCmpOBRIG2  aMatriz2[3][nA][4]
	#Define erCmpCAMPO2	 1
	#Define erCmpVALOR2  2	
	
	If  ( nA :=  aSCan(aMatriz2[3], { |e| e[erCmpCAMPO2] == "A1_CGC" }  ) ) > 0  
		cCNPJ := drCmpVALOR2
	EndIf 
	
	If  Empty( cCNPJ )
	    cMensagem := "LOJA862: LJ862CliEnt: " + STR0025     //"CNPJ não enviado no XML!"
	    Break
	EndIf

	For nB := 1 to Len(aDadosEnd)
		
		  	
		If  ( nA :=  aSCan(aMatriz2[3], { |e| e[erCmpCAMPO2] == aDadosEnd[nB, 1] }  ) ) > 0  
			If drCmpCAMPO2 == "A1_MUN"  
	    		drCmpVALOR2 := Upper(ftAcento(drCmpVALOR2))  
	    	EndIf
			aDadosEnd[nB, 02] :=  drCmpVALOR2
		EndIf 
	Next
	
	lInsere := Lj862RtCl(aDadosEnd, cCliente, cLoja, @cLojaUlt)
	cLojaUlt := PadR(cLojaUlt, SA1->(TamSx3("A1_LOJA")[1]))

    If lInsere .And. !Empty(cCliente + cLojaUlt)
  
 		SA1->(DbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
 		SA1->( DbSeek( cFilSA1)) //Muda o ponteiro para o topo
 		cLojaUlt := PadR(AllTrim(cLojaUlt), nTamLoja)
    	
    	Do While SA1->( DbSeek( cFilSA1 + cCliente + cLojaUlt) )
    	
    		cLojaUlt := Soma1(cLojaUlt, nTamLoja)
    		cLojaUlt := PadR(AllTrim(cLojaUlt), nTamLoja)
    	EndDo
    	
    	
    	LJ862AADD(aCliEnt, "A1_COD", cCliente	) 
		LJ862AADD(aCliEnt, "A1_LOJA", cLojaUlt	) 

	    For nA := 1 to Len(aMatriz2[3])  
	    	If drCmpCAMPO2 == "A1_MUN"  
	    		//drCmpVALOR2 := Upper(ftAcento(drCmpVALOR2))  
	    		cMunic := drCmpVALOR2
	    	ElseIf drCmpCAMPO2 == "A1_EST"
	    	    cEst := drCmpVALOR2	  
	    	EndIf
			LJ862AADD(aCliEnt, drCmpCAMPO2, drCmpVALOR2, (drCmpOBRIG2=="1") )
		Next nB	

	 	If Empty(LJ862MUN(cEst, cMunic))  
			cMensagem := "LOJA862: LJ862CliEnt:" + CRLF + "Codigo do IBGE não encontrado[" + cMunic + "/" + cEst+"]"
			Break 		
	 	EndIf
				
		aCliEnt := WsAutoOpc(aCliEnt)
	
		dbSelectArea("SA1")
		dbSetOrder(1)                   
		DbSeek(cFilSA1)

		If  !( Empty(cCliente) ) .And. DbSeek(cFilSA1+cCliente+cLojaUlt)
			Mata030(aCliEnt,4)
		Else
			Mata030(aCliEnt,3)
		EndIf
	
	
		MEY->( SoftLock('MEY') )  //Volta a trava logica da tabela intermediaria que o execauto() retira apos execucao.
		  
		If  lMsErroAuto
			cMensagem := "LOJA862: LJ862CliEnt:" + CRLF + MostraErro(cLogPath)
			Break
		EndIf

    EndIf
    

End Sequence

Return Empty(cMensagem)            



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj862EnPed  º Autor ³ Vendas CRM         º Data ³  17/02/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorno do Endereço de entrega do cliente.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCliente -  Codigo do Cliente Original                       º±±
±±º          ³ cLoja - Loja do Cliente Original                             º±±
±±º          ³ oObjPed - Objeto do XML do Pedido                            º±±
±±º          ³ cMensagem - Mensagem de erro no processo.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Lj862EnPed( cCliente, cLoja , oObjPed, cMensagem)
Local aArea	:= GetArea()      				//WorkArea Atual
Local cCliEnt := ""           				//Loja do Cliente de entrega - retorno da rotina
Local nRecSa1 := SA1->(Recno())   			//Registro do Cliente SA1
Local aAreaSA1 := SA1->(GetArea()) 			//WorkArea SA1  
Local lDadosEnd	:= ExistBlock("LJ862DEnd")  //P.E para retorno dos dados que compõe o endereço de entrega
Local cLojaUlt := cLoja             		//Loja de Entrega


If GetNewPar("MV_VALCNPJ","1") == "1" .And. GetNewPar("MV_VALCPF","1") == "1"

	If !lDadosEnd //Ponto de entrada para dados do endereço (pois não coube na tabela de-para
	
		aDadosEnd := {{ "A1_END", Upper(FtAcento(oObjPed:_TipoLogradouro:TEXT+" "+oObjPed:_Logradouro:TEXT+","+oObjPed:_Numero:TEXT))},;
						{ "A1_MUN", ftAcento(Upper(oObjPed:_Cidade:TEXT))},;
						{ "A1_EST", Upper(ftAcento(oObjPed:_Estado:TEXT))},;
						{ "A1_BAIRRO", Upper(ftAcento(oObjPed:_Bairro:TEXT))},;
						{ "A1_COMPLEM", Upper(ftAcento(oObjPed:_Complemento:TEXT))},;
						{"A1_CEP", Upper(ftAcento(oObjPed:_CEP:TEXT)) } }
	Else 
		 
		  aDadosEnd := ExecBlock("LJ862DEnd", .F., .F., {oObjPed})
	EndIf

      
	If !Lj862RtCl(aDadosEnd, cCliente, cLoja, @cLojaUlt )
		cCliEnt := cLojaUlt
	EndIf

EndIf

RestArea(aAreaSA1)  
RestArea(aArea)

Return cCliEnt


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj862RtCl   º Autor ³ Vendas CRM         º Data ³  24/02/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna se deverá ser incluído um novo endereço de entrega   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aDadosEnd - Dados do Endereço de entrega do Cliente          º±±
±±º          ³ cCliente -  Codigo do Cliente Original                       º±±
±±º          ³ cLoja - Loja do Cliente Original                             º±±
±±º          ³ oObjPed - Objeto do XML do Pedido                            º±±
±±º          ³ cLojaUlt - Última loja cadastrada       .                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj862RtCl(aDadosEnd, cCliente, cLoja, cLojaUlt )
Local lInsere := .T.
Local cFilSA1 := xFilial("SA1")
Local lIgual := .F.  
Local nA	:= 0

DbSelectArea("SA1")
DbSetOrder(1) //A1_FILIAL + A1_COD + A1_LOJA
DbSeek(cFilSA1 + cCliente)
cLojaUlt := cLoja


Do While lInsere .And. (!Eof() .And. A1_FILIAL + A1_COD == cFilSA1 + cCliente)
	cLojaUlt := A1_LOJA   
	
	lIgual := .F. 
	nA := 0
	
	For nA := 1 to Len(aDadosEnd)
		lIgual := RTrim(FieldGet(FieldPos(aDadosEnd[nA, 01])) )  ==  RTrim(aDadosEnd[nA, 02]) 

	    If !lIgual
	    	Exit
	    EndIf
	Next
	
	lInsere := !lIgual
	
	DbSkip(1)
EndDo
                                                                     

Return lInsere
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj862ItVl   º Autor ³ Vendas CRM         º Data ³  10/03/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o preço de venda do Item (abatido o valor do IPI)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nPrecoDe - Preço De do Item                                  º±±
±±º          ³ cProduto - Código do Produto                                 º±±
±±º          ³ nPrecoVen - Preço de Venda do Item                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj862ItVl(nPrecoDe, cProduto, nPrecoVen)
Local aArea 		:= GetArea()  //workarea
Local nValIPIEn 	:= 0 //Valor IPI Embutido
Local aAreaSB1 	:= NIL //Area SB1
Local aAreaSF4 	:= NIL //Area SF4
Local lMvLjIPEn	:= SuperGetMV("MV_LJIPENP",, .F.)   //IPI Embutido?
Local cTES			:= SuperGetMV("MV_LJTESPE", NIL, "501") // TES Pedido
Local lMVRNDIPI	:= SuperGetMV("MV_RNDIPI",,.F.) //Arredonda IPI?
Local nCasasIPI	:= SLR->(TamSX3("LR_VALIPI")[2])  //Casas do IPI
Local nPrecoTab 	:= 0 //Preco de Tabela

Default nPrecoVen := 0    
Default cProduto := ""
Default nPrecoDe :=0
 

LjxeValPre(@nPrecoTab, cProduto, /*cCliente*/, /*cLoja*/,;
						 /*nMoeda*/   , /*nQtdade*/ , /*lProdON*/, @nValIPIEn, ;
					     .T.)
					     
					      
If (Round((nPrecoTab + nValIPIEn),2) <> Round(nPrecoVen,2)) .And.;
	 nPrecoDe > nPrecoVen //Incide desconto no item
	nPrecoVen := nPrecoDe
EndIf


If lMvLjIPEn
	nValIPIEn := 0
	aAreaSB1 := SB1->(GetArea())

	DbSelectArea("SB1")
	SB1->( DbSetOrder(1) )	//B1_FILIAL + B1_COD
	If SB1->( DbSeek(xFilial("SB1") + cProduto) ) 
		//Busca na TES de pedido se está sinalizado para calcular IPI				
		aAreaSF4 := SF4->(GetArea())
		//Busca a TES do Item		 				
		   
		SF4->(DbSetOrder(1)	)
		If SF4->(DbSeek(xFilial("SF4") + cTES ))  .And. SF4->(!Empty(F4_IPI) .And. F4_IPI <> "N") 

			//Abate o IPI do Preco Cheio do Produto
           						
        			nValIPIEn := ljfnEGetIpi(nPrecoVen, nCasasIPI, lMVRNDIPI)
        			
        			nPrecoVen -=  nValIPIEn
											
		
		EndIf 
		RestArea(aAreaSF4)  
	EndIf				
       

	RestArea(aAreaSB1) 
EndIf
RestArea(aArea) 

Return nPrecoVen



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj862ItVl   º Autor ³ Vendas CRM         º Data ³  10/03/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o desconto do Item (abatido o valor do IPI)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nPrecoVen - Preço de Venda do Item                           º±±
±±º          ³ nPrecoDe - Preço De do Item                                  º±±
±±º          ³ cProduto - Código do Produto                                 º±±
±±ºRetorno   ³ nValDesc - Valor do Desconto                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj862ItDsc(nPrecoVen, nPrecoDe, cProduto)
Local nValDesc := 0  //Valor do Desconto
Local nPrecoTab := 0  //Preco de Tabela
Local nValIPI := 0 //valor do IPI Embutido

Default nPrecoVen := 0   
Default nPrecoDe := 0 
Default cProduto := ""

 
LjxeValPre(@nPrecoTab, cProduto, /*cCliente*/, /*cLoja*/,;
						 /*nMoeda*/   , /*nQtdade*/ , /*lProdON*/, @nValIPI, ;
					     .T.)

If (Round((nPrecoTab + nValIPI),2) <> Round(nPrecoVen,2)) .AND.;
	 nPrecoDe > nPrecoVen //Incide desconto no item
	nValDesc := nPrecoDe - nPrecoVen
EndIf

Return nValDesc    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ862LocCli  º Autor ³ Vendas CRM        º Data ³  10/03/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Localiza o cliente e/ou exibe o log de erro                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCNPJ - CNPJ do Cliente                                      º±±
±±º          ³ cCPF - CPF do Cliente                                        º±±
±±º          ³ cMens - Mensagem de erro                                     º±±
±±ºRetorno   ³ lRet - Cliente Localizado                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ862LocCli(cCNPJ, 	cCPF, 	cNome, 	cSobreNome, ;
					cRazao, 	cMens)   
Local cCod := ""       //Código do Cliente
Local cCampo := ""     //Nome do Campo
Local cValor := ""     //Valor do Indice
Local cDesc	:= ""      //Nome/Razão do Cliente

Default cMens 		:= ""    //Mensagem de Retorno
Default cCNPJ 		:= ""   //CNPJ do Cliente
Default cCPF 		:= ""   //CPF do Cliente
Default cNome 		:= ""   //Nome do Cliente
Default cSobreNome 	:= ""   //SobreNome do Cliente
Default cRazao 		:= ""   //Razao Social do Cliente
Default cMens 		:= ""   //Mensagem do Cliente

If !Empty(cCNPJ)
	cCod := Posicione("SA1",3,xFilial("SA1")+Alltrim(cCNPJ),"A1_COD")  
	cCampo := STR0070   // "CNPJ"
	cValor := cCNPJ  
	cDesc := cRazao
Else
	cCod := Posicione("SA1",3,xFilial("SA1")+Alltrim(cCPF),"A1_COD")
	cCampo := STR0071       //"CPF"
	cValor := cCPF
	cDesc :=  cNome + cSobreNome
EndIf

lRet := !Empty(cCod) 
If  !lRet	
	cMens := STR0072 + cDesc +  " " + STR0073 + cCampo + STR0074 + cValor + STR0075 +CRLF + ;     //"Cliente " # "com " # " valor  [" # "] não localizado. " 
			 STR0076 + CRLF +; //"Para este pedido integrar, é preciso que o mesmo esteja cadastrado. "
			 STR0077  // "Realize a integração do Cliente e, após o mesmo ser incluído com sucesso, reprocesse este registro, sinalizando o status como X - Concluído."
EndIf

Return lRet  