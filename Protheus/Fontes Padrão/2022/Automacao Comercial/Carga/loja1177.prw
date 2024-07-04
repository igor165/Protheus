#INCLUDE "TOTVS.CH"
#INCLUDE "LOJA1177.CH"
//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjAgendaDeCargas
Classe Responsavem pela construção e manipulação do agendamento de cargas

@type       Class
@author     Lucas Novais (lnovais@)
@since      22/06/2020
@version    12.1.27

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------------------------

Class LjAgendaDeCargas

Data aGroups
Data nSelectGp

Data cCodPacote
Data aAgenda
Data aDeletado

Data cProxAgend 

Data oTela

Data oTCBrowse
Data aTCBrowse

Data oOK 
Data oNO

Data HrInicial 
Data HrFinal   

Data oGroup1

Data oSayCodAge    
Data oGetCodAge    
Data cGetCodAge    

Data oSayCodPct   
Data oGetCodPct   
Data cGetCodPct    

Data oSayCodDsc    
Data oGetCodDsc   
Data cGetCodDsc    

Data oSayCodCda   
Data oGetCodCda    
Data cGetCodCda   

Data oSayCodAtv    
Data oCmbCodAtv
Data aCmbCodAtv    
Data cCmbCodAtv   

Data oGroup2

Data oSayHrIni     
Data oSayHrFin     

Data oChkSeg   
Data lChkSeg    
Data oGetHrIni1    
Data oGetHrFin1   
Data cGetHrIni1    
Data cGetHrFin1    

Data oChkTer 
Data lChkTer       
Data oGetHrIni2    
Data oGetHrFin2    
Data cGetHrIni2    
Data cGetHrFin2    

Data oChkQua
Data lChkQua       
Data oGetHrIni3    
Data oGetHrFin3    
Data cGetHrIni3    
Data cGetHrFin3    

Data oChkQui 
Data lChkQui       
Data oGetHrIni4    
Data oGetHrFin4    
Data cGetHrIni4    
Data cGetHrFin4    

Data oChkSex  
Data lChkSex     
Data oGetHrIni5    
Data oGetHrFin5    
Data cGetHrIni5    
Data cGetHrFin5    

Data oChkSab
Data lChkSab       
Data oGetHrIni6    
Data oGetHrFin6    
Data cGetHrIni6    
Data cGetHrFin6    

Data oChkDom   
Data lChkDom     
Data oGetHrIni7    
Data oGetHrFin7    
Data cGetHrIni7    
Data cGetHrFin7

Data oBtnConf
Data oBtnCanc
Data oBtnNewAge

Data oBtnInc
Data oBtnExc

Method New()                            // -- Metodo construtor 
Method criaTelaDeAgendamento()          // -- Metodo Privado
Method limparTelaDeAgendamento()        // -- Metodo Privado
Method atualizarTelaDeAgendamento()     // -- Metodo Privado
Method recarrgaTelaDeAgendamento()      // -- Metodo Privado
Method atualizaBrowse()                 // -- Metodo Privado
Method incluirNovoAgendamento()         // -- Metodo Privado
Method excluirAgendamento()             // -- Metodo Privado
Method alteraAgendamento()              // -- Metodo Privado
Method agendamentosDisponiveis()        // -- Metodo Privado
Method validaAntesDeIncluirOuAlterar()  // -- Metodo Privado
Method validaHoraInformada()            // -- Metodo Privado
Method preparaLeituraDaAgenda()         // -- Metodo publico
Method preparaGravacaoDaAgenda()        // -- Metodo Privado
Method botaoCancelar()                  // -- Metodo Privado

EndClass

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Classe Responsavem pela construção e manipulação do agendamento de cargas

@type       Method
@author     Lucas Novais (lnovais@)
@since      22/06/2020
@version    12.1.27
@param aGroups, Array, Array com os dados do pacotes disponiveis 
@param nSelectGp, Numerico, Numero com o agendaento selecionado 
@param aTCBrowse, Array, Array com os dados de backup do display (Caso não seja informado é caregado da tabela MH1)
@param aAgenda, Array, Array com os dados de backup do display (Caso não seja informado é caregado da tabela MH1), este é um array axiliar com mais informações da tabela MH1
@param aDeletado, Array, Array com as linhas deletadas para que sejam deletadas da tabela
@param lDisplay, Logico, Indica se deverá carregar a tela ou não (é utilizado para acesso a metodos auxiliares da classe)
@return Object, Objeto da classe
/*/
//-------------------------------------------------------------------------------------------------------
Method New(aGroups,nSelectGp,aTCBrowse,aAgenda,aDeletado,lDisplay) Class LjAgendaDeCargas
    Default aTCBrowse :=  {}
    Default aAgenda   :=  {}
    Default aDeletado :=  {}
    Default lDisplay  := .T.  
    
    If lDisplay
        Self:aGroups    := aGroups
        Self:nSelectGp  := nSelectGp

        Self:HrInicial := "00:00"
        Self:HrFinal   := "23:59"

        Self:lChkSeg    := .F.
        Self:lChkTer    := .F.
        Self:lChkQua    := .F.
        Self:lChkQui    := .F.
        Self:lChkSex    := .F.
        Self:lChkSab    := .F.
        Self:lChkDom    := .F.

        Self:cCodPacote := aGroups[nSelectGp][1]
        
        If Empty(aTCBrowse) .Or. Empty(aAgenda)
            Self:agendamentosDisponiveis()
            If Empty(Self:aTCBrowse)
                Self:aTCBrowse  := {{.T.,"","",""}}
                Self:aAgenda    := {{"","","","","","","","",""}}
            EndIf
            Self:aDeletado  := {} 
        Else
            Self:aTCBrowse  := aClone(aTCBrowse)
            Self:aAgenda    := aClone(aAgenda)
            Self:aDeletado  := aClone(aDeletado)
        EndIf 

        Self:criaTelaDeAgendamento()
    Endif 
Return 

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} criaTelaDeAgendamento
Metodo responsavel pela criação da tela.

@type       Method
@author     Lucas Novais (lnovais@)
@since      22/06/2020
@version    12.1.27
@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------------------------

Method criaTelaDeAgendamento() Class LjAgendaDeCargas

Self:oOK           := LoadBitmap(GetResources(),'br_verde')
Self:oNO           := LoadBitmap(GetResources(),'br_vermelho')

Self:cProxAgend  := GETSXENUM("MH1","MH1_CODAGE")

Self:oTela    :=  TDialog():New(000,000,000,000,STR0001,,,,,0,16777215,,,.T.,,,,550,565) //-- 'Agendamento de Cargas'

Self:oTCBrowse := TCBrowse():New( 020 , 001, 275, 100,, {STR0002,STR0003,STR0004,STR0005},{20,60,120,25}, Self:oTela,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) // -- "Ativo?" // 'Cod. Agendamento' // 'Descrição' // 'Cod. Pacote'

Self:atualizaBrowse()
 
Self:oGroup1    := TGroup():New(130,001,260,125 ,STR0006,Self:oTela,,,.T.)// --'Dados do agendamento'

Self:oSayCodAge := TSay():New(140,005,{||STR0007},Self:oGroup1,,,,,,.T.,CLR_BLACK,CLR_WHITE,80,20)//-- 'Codigo do Agendamento'
Self:cGetCodAge :=  Self:cProxAgend // -- Inicializador do campo
Self:oGetCodAge := TGet():New(150,005, { | u | If( PCount() == 0, Self:cGetCodAge, Self:cGetCodAge := u ) },Self:oGroup1, 80, 11, "@X",, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"Self:cGetCodAge",,,,)
Self:oGetCodAge:Disable()

Self:oSayCodPct := TSay():New(165,005,{||STR0008 },Self:oGroup1,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,20)// -- 'Codigo do pacote'
Self:cGetCodPct := Self:cCodPacote
Self:oGetCodPct := TGet():New(175,005, { | u | If( PCount() == 0, Self:cGetCodPct, Self:cGetCodPct := u ) },Self:oGroup1, 80, 11, "@X",, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"Self:cGetCodPct",,,,)
Self:oGetCodPct:Disable()

Self:oSayCodDsc := TSay():New(190,005,{||STR0009 },Self:oGroup1,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,20) // -- 'Descrição'
Self:cGetCodDsc := Space(100)
Self:oGetCodDsc := TGet():New(200,005, { | u | If( PCount() == 0, Self:cGetCodDsc, Self:cGetCodDsc := u ) },Self:oGroup1, 115, 11, "@X",, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"Self:cGetCodDsc",,,,)

Self:oSayCodCda := TSay():New(215,005,{||STR0010 },Self:oGroup1,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,20)// -- 'Cadencia'
Self:cGetCodCda := Space(5)
Self:oGetCodCda := TGet():New(225,005, { | u | If( PCount() == 0, Self:cGetCodCda, Self:cGetCodCda := u ) },Self:oGroup1, 37, 11, "@9",, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"Self:cGetCodCda",,,,)

Self:oSayCodAtv := TSay():New(215,050,{||STR0002 },Self:oGroup1,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,11) // -- "Ativo?"
Self:cCmbCodAtv := STR0011
Self:aCmbCodAtv := {STR0011,STR0012} // -- "Ativo" // "Inativo"
Self:oCmbCodAtv := TComboBox():New(225,045,{|u|if(PCount()>0,Self:cCmbCodAtv:=u,Self:cCmbCodAtv)},Self:aCmbCodAtv,75,13,Self:oGroup1,,{||},,,,.T.,,,,,,,,,'Self:cCmbCodAtv')

Self:oBtnInc  	:= TButton():New( 240, 005, STR0013,Self:oGroup1,{|| Iif(Self:validaAntesDeIncluirOuAlterar(), Self:incluirNovoAgendamento(),Nil ) }, 35,15,,,,.T.) // -- "Incluir"
Self:oBtnInc  	:= TButton():New( 240, 045, STR0014,Self:oGroup1,{|| Iif(Self:validaAntesDeIncluirOuAlterar(), Self:alteraAgendamento(),Nil )}, 35,15,,,,.T.) // -- "Alterar"
Self:oBtnExc  	:= TButton():New( 240, 085, STR0015,Self:oGroup1,{||Self:excluirAgendamento()}, 35,15,,,,.T.) // -- "Excluir"

Self:oGroup2    := TGroup():New(130,130,260,270,STR0016,Self:oTela,,,.T.) // -- Agenda

Self:oSayHrIni  := TSay():New(140,180,{|| STR0017 },Self:oGroup2,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,20)// -- "Hora Inicial"
Self:oSayHrFin  := TSay():New(140,230,{|| STR0018 },Self:oGroup2,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,20)// -- "Hora Final"

Self:oChkSeg    := TCheckBox():New(150,135,STR0019,{ |x| If( PCount() == 0, self:lChkSeg, self:lChkSeg := x ) },Self:oGroup2,100,210,,,,,,,,.T.,,,) // -- "Segunda"
Self:oChkSeg:bLClicked  := {|| Self:oGetHrIni1:CtrlRefresh(),Self:oGetHrFin1:CtrlRefresh()}
Self:cGetHrIni1 := Self:HrInicial
Self:oGetHrIni1 := TGet():New( 150, 180, { | u | If( PCount() == 0, Self:cGetHrIni1, Self:cGetHrIni1 := u ) },Self:oGroup2, 30, 10, "@A 99:99",{|| Self:validaHoraInformada(Self:cGetHrIni1) }, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,{|| self:lChkSeg },.F.,.F.,,.F.,.F. ,,"Self:cGetHrIni1",,,,)
Self:cGetHrFin1 := Self:HrFinal
Self:oGetHrFin1 := TGet():New( 150, 230, { | u | If( PCount() == 0, Self:cGetHrFin1, Self:cGetHrFin1 := u ) },Self:oGroup2, 30, 10, "@A 99:99",{|| Self:validaHoraInformada(Self:cGetHrFin1) }, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,{|| self:lChkSeg },.F.,.F.,,.F.,.F. ,,"Self:cGetHrFin1",,,,)

Self:oChkTer    := TCheckBox():New(165,135,STR0020,{ |x| If( PCount() == 0, self:lChkTer, self:lChkTer := x ) },Self:oGroup2,100,210,,,,,,,,.T.,,,) // -- Terça
Self:oChkTer:bLClicked  := {|| Self:oGetHrIni2:CtrlRefresh(),Self:oGetHrFin2:CtrlRefresh()}
Self:cGetHrIni2 := Self:HrInicial
Self:oGetHrIni2 := TGet():New( 165, 180, { | u | If( PCount() == 0, Self:cGetHrIni2, Self:cGetHrIni2 := u ) },Self:oGroup2, 30, 10, "@A 99:99",{|| Self:validaHoraInformada(Self:cGetHrIni2) }, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,{|| self:lChkTer },.F.,.F.,,.F.,.F. ,,"Self:cGetHrIni2",,,,)
Self:cGetHrFin2 := Self:HrFinal
Self:oGetHrFin2 := TGet():New( 165, 230, { | u | If( PCount() == 0, Self:cGetHrFin2, Self:cGetHrFin2 := u ) },Self:oGroup2, 30, 10, "@A 99:99",{|| Self:validaHoraInformada(Self:cGetHrFin2) }, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,{|| self:lChkTer },.F.,.F.,,.F.,.F. ,,"Self:cGetHrFin2",,,,)

Self:oChkQua    := TCheckBox():New(180,135,STR0021,{ |x| If( PCount() == 0, self:lChkQua, self:lChkQua := x ) },Self:oGroup2,100,210,,,,,,,,.T.,,,)// -- "Quarta"
Self:oChkQua:bLClicked  := {|| Self:oGetHrIni3:CtrlRefresh(),Self:oGetHrFin3:CtrlRefresh()}
Self:cGetHrIni3 := Self:HrInicial
Self:oGetHrIni3 := TGet():New( 180, 180, { | u | If( PCount() == 0, Self:cGetHrIni3, Self:cGetHrIni3 := u ) },Self:oGroup2, 30, 10, "@A 99:99",{|| Self:validaHoraInformada(Self:cGetHrIni3) }, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,{|| self:lChkQua },.F.,.F.,,.F.,.F. ,,"Self:cGetHrIni3",,,,)
Self:cGetHrFin3 := Self:HrFinal
Self:oGetHrFin3 := TGet():New( 180, 230, { | u | If( PCount() == 0, Self:cGetHrFin3, Self:cGetHrFin3 := u ) },Self:oGroup2, 30, 10, "@A 99:99",{|| Self:validaHoraInformada(Self:cGetHrFin3) }, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,{|| self:lChkQua },.F.,.F.,,.F.,.F. ,,"Self:cGetHrFin3",,,,)

Self:oChkQui    := TCheckBox():New(195,135,STR0022,{ |x| If( PCount() == 0, self:lChkQui, self:lChkQui := x ) },Self:oGroup2,100,210,,,,,,,,.T.,,,) // -- "Quinta"
Self:oChkQui:bLClicked  := {|| Self:oGetHrIni4:CtrlRefresh(),Self:oGetHrFin4:CtrlRefresh()}
Self:cGetHrIni4 := Self:HrInicial
Self:oGetHrIni4 := TGet():New( 195, 180, { | u | If( PCount() == 0, Self:cGetHrIni4, Self:cGetHrIni4 := u ) },Self:oGroup2, 30, 10, "@A 99:99",{|| Self:validaHoraInformada(Self:cGetHrIni4) }, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,{|| self:lChkQui },.F.,.F.,,.F.,.F. ,,"Self:cGetHrIni4",,,,)
Self:cGetHrFin4 := Self:HrFinal
Self:oGetHrFin4 := TGet():New( 195, 230, { | u | If( PCount() == 0, Self:cGetHrFin4, Self:cGetHrFin4 := u ) },Self:oGroup2, 30, 10, "@A 99:99",{|| Self:validaHoraInformada(Self:cGetHrFin4) }, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,{|| self:lChkQui },.F.,.F.,,.F.,.F. ,,"Self:cGetHrFin4",,,,)

Self:oChkSex    := TCheckBox():New(210,135,STR0023,{ |x| If( PCount() == 0, self:lChkSex, self:lChkSex := x ) },Self:oGroup2,100,210,,,,,,,,.T.,,,)// -- Sexta
Self:oChkSex:bLClicked  := {|| Self:oGetHrIni5:CtrlRefresh(),Self:oGetHrFin5:CtrlRefresh()}
Self:cGetHrIni5 := Self:HrInicial
Self:oGetHrIni5 := TGet():New( 210, 180, { | u | If( PCount() == 0, Self:cGetHrIni5, Self:cGetHrIni5 := u ) },Self:oGroup2, 30, 10, "@A 99:99",{|| Self:validaHoraInformada(Self:cGetHrIni5) }, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,{|| self:lChkSex },.F.,.F.,,.F.,.F. ,,"Self:cGetHrIni5",,,,)
Self:cGetHrFin5 := Self:HrFinal
Self:oGetHrFin5 := TGet():New( 210, 230, { | u | If( PCount() == 0, Self:cGetHrFin5, Self:cGetHrFin5 := u ) },Self:oGroup2, 30, 10, "@A 99:99",{|| Self:validaHoraInformada(Self:cGetHrFin5) }, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,{|| self:lChkSex },.F.,.F.,,.F.,.F. ,,"Self:cGetHrFin5",,,,)

Self:oChkSab    := TCheckBox():New(225,135,STR0024,{ |x| If( PCount() == 0, self:lChkSab, self:lChkSab := x ) },Self:oGroup2,100,210,,,,,,,,.T.,,,)// -- "Sabado"
Self:oChkSab:bLClicked  := {|| Self:oGetHrIni6:CtrlRefresh(),Self:oGetHrFin6:CtrlRefresh()}
Self:cGetHrIni6 := Self:HrInicial
Self:oGetHrIni6 := TGet():New( 225, 180, { | u | If( PCount() == 0, Self:cGetHrIni6, Self:cGetHrIni6 := u ) },Self:oGroup2, 30, 10, "@A 99:99",{|| Self:validaHoraInformada(Self:cGetHrIni6) }, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,{|| self:lChkSab },.F.,.F.,,.F.,.F. ,,"Self:cGetHrIni6",,,,)
Self:cGetHrFin6 := Self:HrFinal
Self:oGetHrFin6 := TGet():New( 225, 230, { | u | If( PCount() == 0, Self:cGetHrFin6, Self:cGetHrFin6 := u ) },Self:oGroup2, 30, 10, "@A 99:99",{|| Self:validaHoraInformada(Self:cGetHrFin6) }, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,{|| self:lChkSab },.F.,.F.,,.F.,.F. ,,"Self:cGetHrFin6",,,,)

Self:oChkDom    := TCheckBox():New(240,135,STR0025,{ |x| If( PCount() == 0, self:lChkDom, self:lChkDom := x ) },Self:oGroup2,100,210,,,,,,,,.T.,,,)// -- "Domingo"
Self:oChkDom:bLClicked  := {|| Self:oGetHrIni7:CtrlRefresh(),Self:oGetHrFin7:CtrlRefresh()}
Self:cGetHrIni7 := Self:HrInicial
Self:oGetHrIni7 := TGet():New( 240, 180, { | u | If( PCount() == 0, Self:cGetHrIni7, Self:cGetHrIni7 := u ) },Self:oGroup2, 30, 10, "@A 99:99",{|| Self:validaHoraInformada(Self:cGetHrIni7) }, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,{|| self:lChkDom },.F.,.F.,,.F.,.F. ,,"Self:cGetHrIni7",,,,)
Self:cGetHrFin7 := Self:HrFinal
Self:oGetHrFin7 := TGet():New( 240, 230, { | u | If( PCount() == 0, Self:cGetHrFin7, Self:cGetHrFin7 := u ) },Self:oGroup2, 30, 10, "@A 99:99",{|| Self:validaHoraInformada(Self:cGetHrFin7) }, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,{|| self:lChkDom },.F.,.F.,,.F.,.F. ,,"Self:cGetHrFin7",,,,)

Self:oBtnCanc  	:= TButton():New( 265, 130, STR0026 ,Self:oTela,{||Self:botaoCancelar()}, 140,15,,,,.T.) // -- "Sair"
Self:oBtnNewAge := TButton():New( 265, 002, STR0027 ,Self:oTela,{||Self:limparTelaDeAgendamento()}, 123,15,,,,.T.) // -- "Limpar Tela"

Self:oTCBrowse:bLDblClick := {||Self:atualizarTelaDeAgendamento(),Self:recarrgaTelaDeAgendamento()}

Return

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} limparTelaDeAgendamento
Metodo responsavel pela limpeza da tela de agendamentos

@type       Method
@author     Lucas Novais (lnovais@)
@since      22/06/2020
@version    12.1.27
@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------------------------

Method limparTelaDeAgendamento() Class LjAgendaDeCargas

Self:cGetCodDsc := Space(100)
Self:cGetCodCda := Padr("1",5)
Self:cCmbCodAtv := STR0011 // -- "Ativo"
Self:cGetCodAge := Self:cProxAgend

self:lChkSeg := .F.
Self:oChkSeg:CtrlRefresh()
Self:cGetHrIni1	:= Self:HrInicial
Self:cGetHrFin1	:= Self:HrFinal

self:lChkTer := .F.
Self:oChkTer:CtrlRefresh()
Self:cGetHrIni2	:= Self:HrInicial
Self:cGetHrFin2	:= Self:HrFinal

self:lChkQua := .F.
Self:oChkQua:CtrlRefresh()
Self:cGetHrIni3	:= Self:HrInicial
Self:cGetHrFin3	:= Self:HrFinal

self:lChkQui := .F.
Self:oChkQui:CtrlRefresh()
Self:cGetHrIni4	:= Self:HrInicial
Self:cGetHrFin4	:= Self:HrFinal

self:lChkSex := .F.
Self:oChkSex:CtrlRefresh()
Self:cGetHrIni5	:= Self:HrInicial
Self:cGetHrFin5	:= Self:HrFinal

self:lChkSab := .F.
Self:oChkSab:CtrlRefresh()
Self:cGetHrIni6	:= Self:HrInicial
Self:cGetHrFin6	:= Self:HrFinal

self:lChkDom := .F.
Self:oChkDom:CtrlRefresh()
Self:cGetHrIni7	:= Self:HrInicial
Self:cGetHrFin7	:= Self:HrFinal

Return

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} atualizarTelaDeAgendamento
Metodo responsavel pela atualização da tela de agendamentos

@type       Method
@author     Lucas Novais (lnovais@)
@since      22/06/2020
@version    12.1.27
@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------------------------

Method atualizarTelaDeAgendamento() Class LjAgendaDeCargas
Local aSelect	:= {}

aSelect	:= Self:aAgenda[Self:oTCBrowse:nAt]

If Len(aSelect) >= 8
	
	Self:cGetCodAge := aSelect[2]
	Self:cGetCodDsc := aSelect[3]
	Self:cGetCodCda := Padr(Alltrim(STR(aSelect[5])),5)
	Self:cCmbCodAtv := IIF(UPPER(aSelect[6]) == "A",STR0011,STR0012) // -- "Ativo" // "Inativo"
	
	aDias := Self:preparaLeituraDaAgenda() 

	nPos := aScan(aDias,{|x| x[1] == "seg" })
	If nPos > 0
        self:lChkSeg := .T.
		Self:oChkSeg:CtrlRefresh()
		Self:cGetHrIni1	:= aDias[nPos][2][1]
		Self:cGetHrFin1	:= aDias[nPos][2][2]
		nPos := 0
	Else
        self:lChkSeg := .F. 
		Self:oChkSeg:CtrlRefresh()
		Self:cGetHrIni1	:= Self:HrInicial
		Self:cGetHrFin1	:= Self:HrFinal
	EndIf

	nPos := aScan(aDias,{|x| x[1] == "ter" })
	If nPos > 0
        self:lChkTer := .T.
		Self:oChkTer:CtrlRefresh()
		Self:cGetHrIni2	:= aDias[nPos][2][1]
		Self:cGetHrFin2	:= aDias[nPos][2][2]
		nPos := 0
	Else
        self:lChkTer := .F.    
		Self:oChkTer:CtrlRefresh()
		Self:cGetHrIni2	:= Self:HrInicial
		Self:cGetHrFin2	:= Self:HrFinal
	EndIf 

	nPos := aScan(aDias,{|x| x[1] == "qua" })
	If nPos > 0
        self:lChkQua := .T.
		Self:oChkQua:CtrlRefresh()
		Self:cGetHrIni3	:= aDias[nPos][2][1]
		Self:cGetHrFin3	:= aDias[nPos][2][2]
		nPos := 0
	Else
        self:lChkQua := .F.
		Self:oChkQua:CtrlRefresh()
		Self:cGetHrIni3	:= Self:HrInicial
		Self:cGetHrFin3	:= Self:HrFinal
	EndIf 

	nPos := aScan(aDias,{|x| x[1] == "qui" })
	If nPos > 0
        self:lChkQui := .T.
		Self:oChkQui:CtrlRefresh()
		Self:cGetHrIni4	:= aDias[nPos][2][1]
		Self:cGetHrFin4	:= aDias[nPos][2][2]
		nPos := 0
	Else
        self:lChkQui := .F.
		Self:oChkQui:CtrlRefresh()
		Self:cGetHrIni4	:= Self:HrInicial
		Self:cGetHrFin4	:= Self:HrFinal
	EndIf 

	nPos := aScan(aDias,{|x| x[1] == "sex" })
	If nPos > 0
        self:lChkSex := .T.
		Self:oChkSex:CtrlRefresh()
		Self:cGetHrIni5	:= aDias[nPos][2][1]
		Self:cGetHrFin5	:= aDias[nPos][2][2]
		nPos := 0
	Else
        self:lChkSex := .F.
		Self:oChkSex:CtrlRefresh()
		Self:cGetHrIni5	:= Self:HrInicial
		Self:cGetHrFin5	:= Self:HrFinal
	EndIf 

	nPos := aScan(aDias,{|x| x[1] == "sab" })
	If nPos > 0
        self:lChkSab := .T.
		Self:oChkSab:CtrlRefresh()
		Self:cGetHrIni6	:= aDias[nPos][2][1]
		Self:cGetHrFin6	:= aDias[nPos][2][2]
		nPos := 0
	Else
        self:lChkSab := .F.
		Self:oChkSab:CtrlRefresh()
		Self:cGetHrIni6	:= Self:HrInicial
		Self:cGetHrFin6	:= Self:HrFinal
	EndIf 

	nPos := aScan(aDias,{|x| x[1] == "dom" })
	If nPos > 0
        self:lChkDom := .T.
		Self:oChkDom:CtrlRefresh()
		Self:cGetHrIni7	:= aDias[nPos][2][1]
		Self:cGetHrFin7	:= aDias[nPos][2][2]
		nPos := 0
	Else
        self:lChkDom := .F.
		Self:oChkDom:CtrlRefresh()
		Self:cGetHrIni7	:= Self:HrInicial
		Self:cGetHrFin7	:= Self:HrFinal
	EndIf

Endif 
Return

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} limparTelaDeAgendamento
Metodo responsavel por recarregar tela de agendamento

@type       Method
@author     Lucas Novais (lnovais@)
@since      22/06/2020
@version    12.1.27
@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------------------------

Method recarrgaTelaDeAgendamento() Class LjAgendaDeCargas

Self:oCmbCodAtv:Refresh()

Self:oGetCodAge:CtrlRefresh()
Self:oGetCodPct:CtrlRefresh()
Self:oGetCodDsc:CtrlRefresh()
Self:oGetCodCda:CtrlRefresh()

If Self:lChkSeg
    Self:oGetHrIni1:Enable()
    Self:oGetHrFin1:Enable()
Else
    Self:oGetHrIni1:Disable()
    Self:oGetHrFin1:Disable()
EndIf 

Self:oGetHrIni1:CtrlRefresh()
Self:oGetHrFin1:CtrlRefresh()

If Self:lChkTer
    Self:oGetHrIni2:Enable()
    Self:oGetHrFin2:Enable()
Else
    Self:oGetHrIni2:Disable()
    Self:oGetHrFin2:Disable()
EndIf 

Self:oGetHrIni2:CtrlRefresh()
Self:oGetHrFin2:CtrlRefresh()

If Self:lChkQua
    Self:oGetHrIni3:Enable()
    Self:oGetHrFin3:Enable()
Else
    Self:oGetHrIni3:Disable()
    Self:oGetHrFin3:Disable()
EndIf 

Self:oGetHrIni3:CtrlRefresh()
Self:oGetHrFin3:CtrlRefresh()

If Self:lChkQui
    Self:oGetHrIni4:Enable()
    Self:oGetHrFin4:Enable()
Else
    Self:oGetHrIni4:Disable()
    Self:oGetHrFin4:Disable()
EndIf 

Self:oGetHrIni4:CtrlRefresh()
Self:oGetHrFin4:CtrlRefresh()

If Self:lChkSex
    Self:oGetHrIni5:Enable()
    Self:oGetHrFin5:Enable()
Else
    Self:oGetHrIni5:Disable()
    Self:oGetHrFin5:Disable()
EndIf 

Self:oGetHrIni5:CtrlRefresh()
Self:oGetHrFin5:CtrlRefresh()

If Self:lChkSab
    Self:oGetHrIni6:Enable()
    Self:oGetHrFin6:Enable()
Else
    Self:oGetHrIni6:Disable()
    Self:oGetHrFin6:Disable()
EndIf 

Self:oGetHrIni6:CtrlRefresh()
Self:oGetHrFin6:CtrlRefresh()

If Self:lChkDom
    Self:oGetHrIni7:Enable()
    Self:oGetHrFin7:Enable()
Else
    Self:oGetHrIni7:Disable()
    Self:oGetHrFin7:Disable()
EndIf 

Self:oGetHrIni7:CtrlRefresh()
Self:oGetHrFin7:CtrlRefresh()

Return

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} atualizaBrowse
Metodo responsavel por ataulizar componente de lista do agendamento

@type       Method
@author     Lucas Novais (lnovais@)
@since      22/06/2020
@version    12.1.27
@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------------------------

Method atualizaBrowse() Class LjAgendaDeCargas
Self:oTCBrowse:SetArray(Self:aTCBrowse)

If !Empty(Self:aTCBrowse)
    Self:oTCBrowse:bLine := {||{ If(Self:aTCBrowse[Self:oTCBrowse:nAt,01],Self:oOK,Self:oNO),;
                                    Self:aTCBrowse[Self:oTCBrowse:nAt,02]                   ,;
                                    Self:aTCBrowse[Self:oTCBrowse:nAt,03]                   ,;
                                    Self:aTCBrowse[Self:oTCBrowse:nAT,04]                   }}
EndIf 

Self:oTCBrowse:Refresh()
Return

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} incluirNovoAgendamento
Metodo responsavel por incluir um novo agendamento

@type       Method
@author     Lucas Novais (lnovais@)
@since      22/06/2020
@version    12.1.27
@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------------------------

Method incluirNovoAgendamento() Class LjAgendaDeCargas
Local cAgenda   := ""

Self:cGetCodAge := Self:cProxAgend

cAgenda := Self:preparaGravacaoDaAgenda()

aAdd(Self:aTCBrowse,{Iif(Self:cCmbCodAtv == STR0011,.T.,.F.),Self:cProxAgend,Self:cGetCodDsc,Self:cGetCodPct}) // -- Ativo
aAdd(Self:aAgenda,  {xFilial("MH1"),Self:cProxAgend,Self:cGetCodDsc,Self:cGetCodPct,Val(Self:cGetCodCda),Iif(Self:cCmbCodAtv == STR0011,"A","I"),cAgenda,,.F.,.T.}) // -- "Ativo"
MH1->(ConfirmSx8()) // -- Confirmo o numero reservado
Self:cProxAgend := GETSXENUM("MH1","MH1_CODAGE")

Self:atualizaBrowse()

If Empty(Self:aTCBrowse[1][2])
    Self:excluirAgendamento(1,.T.)
EndIf

Return

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} alteraAgendamento
Metodo responsavel por Alterar um agendamento existente, caso ele não existe será incluido um novo utilizando o metodo
incluirNovoAgendamento()

@type       Method
@author     Lucas Novais (lnovais@)
@since      22/06/2020
@version    12.1.27
@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------------------------

Method alteraAgendamento() Class LjAgendaDeCargas
Local cAgenda := Self:preparaGravacaoDaAgenda()

nPos := aScan(Self:aTCBrowse,{|x| x[2] == Self:cGetCodAge }) 
If nPos > 0
    Self:aTCBrowse[nPos][1] := Iif(Self:cCmbCodAtv == STR0011,.T.,.F.) // -- "Ativo"
    Self:aTCBrowse[nPos][3] := Self:cGetCodDsc
    Self:aTCBrowse[nPos][4] := Self:cGetCodPct

    Self:aAgenda[nPos][3]   := Self:cGetCodDsc
    Self:aAgenda[nPos][4]   := Self:cGetCodPct
    Self:aAgenda[nPos][5]   := Val(Self:cGetCodCda)
    Self:aAgenda[nPos][6]   := Iif(Self:cCmbCodAtv == STR0011,"A","I") // -- "Ativo"
    Self:aAgenda[nPos][7]   := cAgenda
    Self:aAgenda[nPos][10]  := .T.

    Self:atualizaBrowse()
Else
    // -- Se não encontrou inclui.
    Self:incluirNovoAgendamento()
EndIf 

MsgInfo(STR0034 + Self:cGetCodAge + STR0035,STR0036)// -- "Agendamento: " // " atualizado com sucesso." // "Atualizando..."

Return

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} excluirAgendamento
Metdodo responsavel por exluir um agendameno (logicamente)
@type       Method
@author     Lucas Novais (lnovais@)
@since      22/06/2020
@version    12.1.27
@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------------------------

Method excluirAgendamento(nLinha,lNotMsg) Class LjAgendaDeCargas
Default nLinha := Self:oTCBrowse:nAt
Default lNotMsg := .F.
If lNotMsg .Or. (nLinha > 0 .AND. Len(Self:aTCBrowse) > 0 .AND. MSGYESNO(STR0028 + Self:aTCBrowse[nLinha,2] + " ?",STR0029)) // -- "Deseja realmente excluir o Agendamento: " // "Gostaria de excluir o agendamento?"

    If !Empty(Self:aAgenda[nLinha][9]) .AND. Self:aAgenda[nLinha][9]
        aAdd(Self:aDeletado,aClone(Self:aAgenda[nLinha]))
    EndIf

    aDel(Self:aTCBrowse,nLinha)
    aDel(Self:aAgenda,nLinha)

    ASize(Self:aTCBrowse,Len(Self:aTCBrowse )-1)
    ASize(Self:aAgenda  ,Len(Self:aAgenda   )-1)

    Self:atualizaBrowse()
EndIf 
Return

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} agendamentosDisponiveis
Metdodo responsavel varrer tabela MH1 do pacote selecionado e informar os agendamentos disponiveis
@type       Method
@author     Lucas Novais (lnovais@)
@since      22/06/2020
@version    12.1.27
@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------------------------

Method agendamentosDisponiveis() Class LjAgendaDeCargas
Self:aTCBrowse := {}
Self:aAgenda   := {}

DbSelectArea("MH1")
DbSetOrder(2)//MH1_FILIAL+MH1_COD
If DBSeek(xFilial("MH1") + Self:cCodPacote)
	While !(EOf()) .And. xFilial("MH1") + Self:cCodPacote == MH1->(MH1_FILIAL + MH1_COD)
		aAdd(Self:aTCBrowse,{Iif(UPPER(MH1->MH1_STATUS) == "A",.T.,.F.),MH1->MH1_CODAGE,MH1->MH1_DESCRI,MH1->MH1_COD})
        // -- a posição 9 do array é utilizada para diferenciar registros fisicos dos logicos (se ele vinher do banco é .T.)
        // -- a posição 10 do array indica se o registro foi alterado (Neste ponto nasce como .F., caso ele seja alterado em memoria pela rotira mudar ele para .T. para q ele seja alterado no banco)
		aAdd(Self:aAgenda,{MH1->MH1_FILIAL,MH1->MH1_CODAGE,MH1->MH1_DESCRI,MH1->MH1_COD,MH1->MH1_TIME,MH1->MH1_STATUS,MH1->MH1_AGENDA,MH1->(Recno()),.T.,.F.}) 
		MH1->(DBSkip())
	End
EndIf 

Return

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} validaAntesDeIncluirOuAlterar
Metdodo responsavel validar antes da inclusão ou alteração de um agendamento
@type       Method
@author     Lucas Novais (lnovais@)
@since      22/06/2020
@version    12.1.27
@return Logico, Indica se a validação foi bem sucedida 
/*/
//-------------------------------------------------------------------------------------------------------

Method validaAntesDeIncluirOuAlterar() Class LjAgendaDeCargas
Local lAprovou   := .T.
Local cTitulo    := STR0030  // --"Algum campo obrigatório não foi preenchido ou o conteudo é invalido."
Local cGetCodCda := Alltrim(Self:cGetCodCda)
Local lErroCda   := .F.
Local nX         := 0

For nX := 1 to Len(cGetCodCda)
    If !ISDIGIT(SubStr(cGetCodCda,nX,1))
        lErroCda := .T.
    EndIf 
Next 

Do case
Case Empty(self:cGetCodDsc)
    lAprovou := .F.
    MSGALERT( STR0031, cTitulo ) // -- "Descrição do agendamento é obrigatoria"
Case Empty(self:cGetCodCda)
    lAprovou := .F.
    MSGALERT( STR0032, cTitulo )// -- "Cadência do agendamento é obrigatoria"
Case !(Self:lChkSeg .Or. Self:lChkTer .Or. Self:lChkQua .Or. Self:lChkQui .Or. Self:lChkSex .Or. Self:lChkSab .Or. Self:lChkDom ) 
    lAprovou := .F.
    MSGALERT( STR0033, cTitulo ) // -- "Ao menos um dia da semana precisa estar selecionado"
Case lErroCda
    lAprovou := .F.
    MSGALERT(STR0037, cTitulo ) // -- "O campo cadencia deve ser preenchido apenas com numeros."
EndCase

Return lAprovou

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} validaHoraInformada
Metdodo responsavel validar a hora informada nos campos de hora inicial e final
@type       Method
@author     Lucas Novais (lnovais@)
@since      22/06/2020
@version    12.1.27
@param Caracter, cHora, Hora para ser validada
@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------------------------

Method validaHoraInformada(cHora) Class LjAgendaDeCargas
Local lRetorno := AtVldHora(cHora)  
Return lRetorno

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} preparaGravacaoDaAgenda
Metdodo responsavel Prepara a agenda para gravação
@type       Method
@author     Lucas Novais (lnovais@)
@since      22/06/2020
@version    12.1.27
@param Caracter, cHora, Hora para ser validada
@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------------------------

Method preparaGravacaoDaAgenda() Class LjAgendaDeCargas
Local cAgenda   := ""

If Self:lChkSeg   
    cAgenda += AllTrim("|seg=" + Self:cGetHrIni1 + "<" + Self:cGetHrFin1)
EndIf 

If Self:lChkTer
    cAgenda += AllTrim("|ter=" + Self:cGetHrIni2 + "<" + Self:cGetHrFin2)
EndIf 

If Self:lChkQua
    cAgenda += AllTrim("|qua=" + Self:cGetHrIni3 + "<" + Self:cGetHrFin3)
EndIf 

If Self:lChkqui
    cAgenda += AllTrim("|qui=" + Self:cGetHrIni4 + "<" + Self:cGetHrFin4)
EndIf 

If Self:lChkSex
    cAgenda += AllTrim("|sex=" + Self:cGetHrIni5 + "<" + Self:cGetHrFin5)
EndIf 

If Self:lChkSab
    cAgenda += AllTrim("|sab=" + Self:cGetHrIni6 + "<" + Self:cGetHrFin6)
EndIf 

If  Self:lChkDom
    cAgenda += AllTrim("|dom=" + Self:cGetHrIni7 + "<" + Self:cGetHrFin7)
EndIf 

Return cAgenda

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} preparaLeituraDaAgenda
Metdodo responsavel validar a hora informada nos campos de hora inicial e final
@type       Method
@author     Lucas Novais (lnovais@)
@since      22/06/2020
@version    12.1.27
@param Caracter, cAgenda, parametro com a informação da agenda para ser organizada em um array
@return Array, Retorna um array com os dados da agenda tratado
/*/
//-------------------------------------------------------------------------------------------------------

Method preparaLeituraDaAgenda(cAgenda) Class LjAgendaDeCargas

Local aAgenda	:= {}
Local nDias		:= 0
Local aDias		:= {}

Default cAgenda := Iif(ValType( Self:aAgenda[Self:oTCBrowse:nAt][7]) == "C", Self:aAgenda[Self:oTCBrowse:nAt][7],"")

If !Empty(cAgenda)
    aAgenda := StrTokArr(cAgenda,"|")
    For nDias := 1 To Len(aAgenda)
        aAdd(aDias,StrTokArr(aAgenda[nDias],"="))
        aDias[nDias][2] := StrTokArr(aDias[nDias][2],"<")		
    Next
EndIf 
Return aDias

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} botaoCancelar
Metdodo responsavel realziar o rollback do numero reservado e fechar a tela de agendamento.
@type       Method
@author     Lucas Novais (lnovais@)
@since      22/06/2020
@version    12.1.27
@return Nil, nulo
/*/
//-------------------------------------------------------------------------------------------------------

Method botaoCancelar() Class LjAgendaDeCargas
    MH1->(RollbackSx8())
    Self:oTela:End()
Return 