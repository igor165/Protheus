#include 'protheus.ch'
#include "PLSMGER2.CH"

/*/{Protheus.doc}  PlsScheObj627
	Classe com dados pertinentes ao Schedule de Lote de Cobrança 

	@type class
	@author Robson Nayland
	@since 17/08/2020
/*/

Class PlsScheObj627
    Data lExitProc   AS Logical
    Data lTipPessoa  AS Logical
    Data lFiltro     AS Logical
    Data cFiltro     AS String
    Data cMesFrente  AS String
    Data aRecScheB6J AS Array Init {}


    Method new() Constructor
    Method LoadAgenda()     // Verifica se há agendamento
    Method TipoPessoa()     // Verifica se é pessoa fisica ou juridica
    Method ExisteFiltro()   // Verifica se o campo B6J_FILTRO esta preenchido, esse campk equivale ao BDC_EXPFIF
    Method CarregaDados()   // Carregas os dados antes de chamar PLSA627
    Method ExecPls627()   // Carrega  paramentros especifico para o agendamento, essa tabela equivale ao BDW do lote de faturamento e chama o PLSA627
   	Method destroy()

EndClass



Method new() Class PlsScheObj627

    Self:lExitProc  := .F.
    Self:lTipPessoa := .F.
    Self:lFiltro    := .F.
    Self:cFiltro    := ''
    Self:cMesFrente := '0' 
  
    Self:aRecScheB6J:= {}

Return self



/*/{Protheus.doc} LoadAgenda
	Methodo que verifica se há uma agendamento no dia varrendo a tebela B6k
	
	@type method
	@author Robson Nayland
	@since 20/08/2020
	@version 1.0
/*/

Method LoadAgenda(dDataref) Class PlsScheObj627

    Local cDias     := StrZero(Day(dDataref),2)
    Local cMes      := StrZero(Month(dDataref),2)
    Local cAno      := StrZero(Year(dDataref),4)
    Local cAliasTrb := GetNextAlias()

    //Procuro no cadastro de agendamento se existe uma data para ser exeutada
    BeginSql Alias cAliasTrb
        SELECT B6J.R_E_C_N_O_ RECNOB6J  FROM %table:B6J% B6J
        WHERE B6J.B6J_FILIAL = %xFilial:B6J% 
                AND   %exp:cAno% >= B6J.B6J_ANOINI 
                AND   %exp:cMes% >= B6J.B6J_MESINI
                AND   %exp:cAno% <= B6J.B6J_ANOFIN 
                AND   %exp:cMes% <= B6J.B6J_MESFIN 
                AND   B6J.B6J_DIAEXE =  %exp:cDias%
                AND   NOT EXISTS (
                      SELECT B6Q.B6Q_MESREF
                        FROM  %table:B6Q% B6Q
                        WHERE B6Q.B6Q_CODAGE    = B6J.B6J_CODAGE
                        AND B6Q.B6Q_FILIAL    = %xFilial:B6Q% 
                        AND  %exp:cMes%   = B6Q.B6Q_MESREF
                        AND B6Q.D_E_L_E_T_= ' ')
                AND   B6J.%notDel% 
  
   	EndSql

    If (cAliasTrb)->(!Eof())
        //Existe agendamento para esse dia irei executar a rotina PLSA627
        Self:lExitProc  := .T.
    Endif    

    
    //Adiciono os Recno dos Agendamentos que serão executados na rotina PLSA627
    While (cAliasTrb)->(!Eof())
        aAdd(Self:aRecScheB6J,(cAliasTrb)->RECNOB6J)
        (cAliasTrb)->(DbSkip())
    Enddo


    (cAliasTrb)->(DbCloseArea())

Return 

/*/{Protheus.doc} 
    Metodo que define o tipo de pessoal ao Schedule de Lote de Cobrança 
    lTipPessoa := .F.  // Pessoa Fisica
    lTipPessoa := .T.  // Pessoa Juridica

    @type  Function
    @author Robson Nayland
    @since 13/08/2020
/*/
Method TipoPessoa() Class PlsScheObj627
   
    If (B6J->B6J_FISJUR = "0")
        Self:lTipPessoa := .T.  // Pessoa Fisica
    Else
        Self:lTipPessoa := .F.  // Pessoa Juridica
    Endif        

Return 


/*/{Protheus.doc} 
    Metodo que verifica se existe filtro especifico no campo B6J_FILTRO que equivale ao BDC_EXPFIF 
    @type  Function
    @author Robson Nayland
    @since 13/08/2020
/*/
Method ExisteFiltro() Class PlsScheObj627
   
    If !Empty(B6J->B6J_FILTRO)
        Self:lFiltro := .T.  // Existe o Filtro específico
        Self:cFiltro := B6J->B6J_FILTRO
    Endif        

Return 



/*/{Protheus.doc} LoadAgenda
	Methodo que carrega os Itens para B6K quando o agendamento for para pessoa Juridica,
    essa tabela equivale ao BDW do lote de faturamento, após carregar chama o PLSA627
	
	@type method
	@author Robson Nayland
	@since 20/08/2020
	@version 1.0
/*/

Method ExecPls627(cCodAge) Class PlsScheObj627

    Local cAliasTrb := GetNextAlias()
    Local aItens    := {}

    Default cCodAge   := ''

    //Procuro no cadastro de agendamento se existe uma data para ser exeutada
    BeginSql Alias cAliasTrb
        SELECT *   FROM %table:B6k%
        WHERE B6K_FILIAL = %xFilial:B6K% 
                AND  B6K_NUMSEC =  %exp:cCodAge%
                AND %notDel% 
   	EndSql

    If (cAliasTrb)->(!Eof())
         
        //Adiciono os Recno dos Agendamentos que serão executados na rotina PLSA627
        While (cAliasTrb)->(!Eof())

            /*
            Modelo de De/para da tabela B6J para BDW, para os casos aonde há parametros específicos para pessoa juridica
            aItens[1]   = "BDW_CODOPE"  = B6K_CODOPE  
            aItens[2]   = "BDW_CODEMP"  = B6K_CODEMP  
            aItens[3]   = "BDW_DESCRI"  = B6K_DESEMP   
            aItens[4]   = "BDW_CONEMP"  = B6K_NUMCON   
            aItens[5]   = "BDW_VERCON"  = B6K_VERSAO  
            aItens[6]   = "BDW_SUBCON"  = B6K_SUBCON  
            aItens[7]   = "BDW_VERSUB"  = B6K_VERSUB  
            aItens[8]   = "BDW_CODEMF"  = B6K_EMPFIN  
            aItens[9]   = "BDW_DESCRF"  = B6K_DESFIN  
            aItens[10]  = "BDW_CONEMF"  = B6K_CONFIN  
            aItens[11]  = "BDW_VERCOF"  = B6K_VERFIN  
            aItens[12]  = "BDW_SUBCOF"  = B6K_SUBFIN  
            aItens[13]  = "BDW_VERSUF"  = B6K_VESUFI  
            aItens[14]  =  "D_e_l_e_t"  =   
            */
            aAdd(aItens,{(cAliasTrb)->B6K_CODOPE,(cAliasTrb)->B6K_CODEMP,(cAliasTrb)->B6K_DESEMP,(cAliasTrb)->B6K_NUMCON,(cAliasTrb)->B6K_VERSAO,(cAliasTrb)->B6K_SUBCON,(cAliasTrb)->B6K_VERSUB,(cAliasTrb)->B6K_EMPFIN,(cAliasTrb)->B6K_DESFIN,(cAliasTrb)->B6K_CONFIN,(cAliasTrb)->B6K_VERFIN,(cAliasTrb)->B6K_SUBFIN,(cAliasTrb)->B6K_VESUFI,.F.})
   
            (cAliasTrb)->(DbSkip())

        Enddo
  

    Endif 

    //Chamando a rotina para geração do lote de cobrança
    If PLS627PROC(3, 0, .F., Self:lTipPessoa,aItens,.t.) 
    	
        B6Q->(Reclock("B6Q",.T.))
        B6Q->B6Q_FILIAL := xFilial("B6Q")
        B6Q->B6Q_CODAGE := B6J->B6J_CODAGE
        B6Q->B6Q_DTEXEC := Msdate()
        B6Q->B6Q_HORA   := Time()
	    B6Q->B6Q_GERADO := "1"
        B6Q->B6Q_DESCRI := "Item Gerado com sucesso"
        B6Q->B6Q_NUMERO := BDC->BDC_NUMERO
        B6Q->B6Q_MESREF := StrZero(Month(Msdate()),2)
        B6Q->(MsUnlock())
    Else

        B6Q->(Reclock("B6Q",.T.))
        B6Q->B6Q_FILIAL := xFilial("B6Q")
        B6Q->B6Q_CODAGE := B6J->B6J_CODAGE
        B6Q->B6Q_DTEXEC := Msdate()
        B6Q->B6Q_HORA   := Time()
	    B6Q->B6Q_GERADO := "0"
        B6Q->B6Q_DESCRI := "Item não gerado, verificar os os Logs na pasta (/Logpls)"
        B6Q->B6Q_NUMERO := BDC->BDC_NUMERO
        B6Q->B6Q_MESREF := StrZero(Month(Msdate()),2)
        B6Q->(MsUnlock())

    Endif

Return 

/*/{Protheus.doc} 
    Metodo para cerregar os dados antes de chamar a PLSA627 
    @type  Function
    @author Robson Nayland
    @since 13/08/2020
/*/
Method CarregaDados(dDataRef) Class PlsScheObj627
    Local cMes      := StrZero(Month(dDataref),2)
    Local cAno      := StrZero( Year(dDataref),4)
 

  
    RegToMemory("BDC", .T., .T., .T.)  
    M->BDC_FILIAL   := xFilial("BDC")
    M->BDC_CODOPE   := B6J->B6J_CODOPE
    M->BDC_ANOINI   := cAno
    M->BDC_MESINI   := If(Self:cMesFrente =="1",StrZero(Val(cMes)+1,2),cMes)  
    M->BDC_ANOFIM   := cAno
    M->BDC_MESFIM   := If(Self:cMesFrente =="1",StrZero(Val(cMes)+1,2),cMes)
    M->BDC_EXPFIF   := B6J->B6J_FILTRO
    M->BDC_TIPO     := If(Self:lTipPessoa,'2','1')
    M->BDC_GRPCOB   := B6J->B6J_GRUCOB
    M->BDC_LOTREN   := B6J->B6J_LOTREN
    M->BDC_VENINI   := B6J->B6J_VCTINI
    M->BDC_VENFIM   := B6J->B6J_VCTFIN
    M->BDC_MODPAG   := B6J->B6J_MODCOB
    M->BDC_INTERC   := B6J->B6J_INTERC
    M->BDC_AGLUTI   := B6J->B6J_AGLUTI
    M->BDC_CARIMP   := B6J->B6J_CARIMP
    
    Self:ExecPls627(B6J->B6J_CODAGE)
 
Return 

Method destroy() Class PlsScheObj627
Return