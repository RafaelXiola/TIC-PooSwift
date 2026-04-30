import Foundation

// ============================================================
// MARK: - DIA 1: Estruturas Base, Entidades de Negócio e Herança
// ============================================================

// MARK: - Enums (Conjuntos Fechados / Tipos de Valor)

/// Nível de experiência do aluno
enum NivelExperiencia: String, CaseIterable {
    case iniciante     = "Iniciante"
    case intermediario = "Intermediário"
    case avancado      = "Avançado"
}

/// Categorias de aulas oferecidas
enum CategoriaAula: String, CaseIterable {
    case musculacao = "Musculação"
    case spinning   = "Spinning"
    case yoga       = "Yoga"
    case funcional  = "Funcional"
    case luta       = "Luta"
}

// MARK: - Plano de Assinatura

/// Entidade que representa os planos de assinatura da academia
struct PlanoAssinatura {
    let nome: String
    let valorMensalidade: Double
    let incluiPersonalTrainer: Bool
    let limiteAulasColetivas: Int
    let duracaoEmMeses: Int

    var descricao: String {
        let limite = limiteAulasColetivas == Int.max ? "Ilimitado" : "\(limiteAulasColetivas)"
        return """
        ┌─ Plano: \(nome)
        │  Mensalidade   : R$ \(String(format: "%.2f", valorMensalidade))
        │  Personal      : \(incluiPersonalTrainer ? "✅ Incluso" : "❌ Não incluso")
        │  Aulas col.    : \(limite)
        └─ Duração       : \(duracaoEmMeses) \(duracaoEmMeses == 1 ? "mês" : "meses")
        """
    }
}

/// Catálogo em memória — simulação de banco de dados
enum CatalogoPlanos {
    static let mensal = PlanoAssinatura(
        nome: "Mensal",
        valorMensalidade: 99.90,
        incluiPersonalTrainer: false,
        limiteAulasColetivas: 8,
        duracaoEmMeses: 1
    )

    static let trimestral = PlanoAssinatura(
        nome: "Trimestral",
        valorMensalidade: 79.90,
        incluiPersonalTrainer: false,
        limiteAulasColetivas: 12,
        duracaoEmMeses: 3
    )

    static let anual = PlanoAssinatura(
        nome: "Anual",
        valorMensalidade: 59.90,
        incluiPersonalTrainer: true,
        limiteAulasColetivas: Int.max,
        duracaoEmMeses: 12
    )

    static let todos: [PlanoAssinatura] = [mensal, trimestral, anual]
}

// MARK: - Hierarquia de Pessoas

/// Entidade base genérica para pessoas
class Pessoa {
    let nome: String
    let email: String

    init(nome: String, email: String) {
        self.nome  = nome
        self.email = email
    }

    func descrever() -> String {
        return "👤 Pessoa: \(nome) | Email: \(email)"
    }
}

/// Aluno — herda de Pessoa
class Aluno: Pessoa {
    let matricula: String
    private(set) var plano: PlanoAssinatura
    private(set) var nivelExperiencia: NivelExperiencia

    init(nome: String, email: String, matricula: String,
         plano: PlanoAssinatura, nivelExperiencia: NivelExperiencia) {
        self.matricula        = matricula
        self.plano            = plano
        self.nivelExperiencia = nivelExperiencia
        super.init(nome: nome, email: email)
    }

    /// Atualiza o plano do aluno dinamicamente
    func atualizarPlano(_ novoPlano: PlanoAssinatura) {
        plano = novoPlano
        print("   ✅ Plano de '\(nome)' atualizado para: \(novoPlano.nome)")
    }

    /// Atualiza o nível de experiência do aluno dinamicamente
    func atualizarNivel(_ novoNivel: NivelExperiencia) {
        nivelExperiencia = novoNivel
        print("   ✅ Nível de '\(nome)' atualizado para: \(novoNivel.rawValue)")
    }

    override func descrever() -> String {
        return "🎓 Aluno: \(nome) | Matrícula: \(matricula) | Plano: \(plano.nome) | Nível: \(nivelExperiencia.rawValue)"
    }
}

/// Instrutor — herda de Pessoa
class Instrutor: Pessoa {
    let especialidade: CategoriaAula

    init(nome: String, email: String, especialidade: CategoriaAula) {
        self.especialidade = especialidade
        super.init(nome: nome, email: email)
    }

    override func descrever() -> String {
        return "🏅 Instrutor: \(nome) | Especialidade: \(especialidade.rawValue)"
    }
}

// ============================================================
// MARK: - DIA 2: Contratos de Comportamento (Protocolos)
// ============================================================

// MARK: - Contrato de Manutenção

/// Status resultante de uma tentativa de reparo
enum StatusReparo {
    case regular
    case irregular
    case falhou(motivo: String)
}

/// Registro histórico de uma manutenção
struct RegistroReparo {
    let data: Date
    let status: StatusReparo
    let tecnico: String

    var dataFormatada: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd/MM/yyyy HH:mm"
        return fmt.string(from: data)
    }

    var descricao: String {
        let statusTexto: String
        switch status {
        case .regular:           statusTexto = "✅ Regular"
        case .irregular:         statusTexto = "⚠️ Irregular"
        case .falhou(let m):     statusTexto = "❌ Falhou — \(m)"
        }
        return "[\(dataFormatada)] Técnico: \(tecnico) | \(statusTexto)"
    }
}

/// Contrato de manutenção: exige propriedades de leitura e ação de reparo
protocol ContratoManutencao {
    /// Nome do item submetido a manutenção (somente leitura)
    var nomeItem: String { get }

    /// Histórico de todos os reparos realizados (somente leitura)
    var historicoReparos: [RegistroReparo] { get }

    /// Realiza um reparo informando data e retorna o status de regularidade
    mutating func realizarReparo(data: Date, tecnico: String) -> StatusReparo
}

// MARK: - Estado Operacional do Equipamento

enum EstadoOperacional {
    case operacional
    case defeituoso(motivo: String)
    case emManutencao
}

// MARK: - Equipamento Físico (implementa ContratoManutencao)

struct EquipamentoFisico: ContratoManutencao {
    let nomeItem: String
    private(set) var historicoReparos: [RegistroReparo] = []
    private(set) var estadoOperacional: EstadoOperacional

    init(nome: String, estado: EstadoOperacional = .operacional) {
        self.nomeItem          = nome
        self.estadoOperacional = estado
    }

    /// Tenta realizar o reparo.
    /// Se o equipamento estiver DEFEITUOSO, a manutenção OBRIGATORIAMENTE falha.
    mutating func realizarReparo(data: Date, tecnico: String) -> StatusReparo {
        switch estadoOperacional {

        case .defeituoso(let motivo):
            // Estado defeituoso → falha obrigatória
            let status = StatusReparo.falhou(motivo: "Equipamento defeituoso: \(motivo)")
            historicoReparos.append(RegistroReparo(data: data, status: status, tecnico: tecnico))
            print("   ❌ Manutenção de '\(nomeItem)' FALHOU — \(motivo)")
            return status

        case .operacional, .emManutencao:
            let status = StatusReparo.regular
            historicoReparos.append(RegistroReparo(data: data, status: status, tecnico: tecnico))
            estadoOperacional = .operacional
            print("   ✅ Manutenção de '\(nomeItem)' concluída por \(tecnico)")
            return status
        }
    }

    mutating func marcarDefeituoso(motivo: String) {
        estadoOperacional = .defeituoso(motivo: motivo)
    }

    mutating func marcarOperacional() {
        estadoOperacional = .operacional
    }

    var estadoDescricao: String {
        switch estadoOperacional {
        case .operacional:           return "✅ Operacional"
        case .defeituoso(let m):     return "❌ Defeituoso: \(m)"
        case .emManutencao:          return "🔧 Em manutenção"
        }
    }
}

// MARK: - Contrato Base de Aula (substitui herança clássica)

/// Contrato que toda aula deve assinar
protocol ContratoAula {
    var nomeAula: String        { get }
    var instrutor: Instrutor    { get }
    var categoria: CategoriaAula { get }
    var descricaoAula: String   { get }

    func descrever() -> String
}

// MARK: - Turma Coletiva (assina ContratoAula)

/// Erros possíveis em inscrições de turmas
enum ErroInscricao: Error, LocalizedError {
    case semVagasDisponiveis
    case alunoJaInscrito

    var errorDescription: String? {
        switch self {
        case .semVagasDisponiveis: return "Não há vagas disponíveis na turma."
        case .alunoJaInscrito:    return "Aluno já está inscrito nesta turma."
        }
    }
}

class TurmaColetiva: ContratoAula {
    let nomeAula: String
    let instrutor: Instrutor
    let categoria: CategoriaAula
    let descricaoAula: String
    let capacidadeMaxima: Int
    let capacidadeMinima: Int

    /// Alunos inscritos — chave: matrícula para busca O(1)
    private(set) var alunosInscritos: [String: Aluno] = [:]

    var vagasDisponiveis: Int  { capacidadeMaxima - alunosInscritos.count }
    var atingiuMinimo: Bool    { alunosInscritos.count >= capacidadeMinima }

    init(nome: String, instrutor: Instrutor, categoria: CategoriaAula,
         descricao: String, capacidadeMaxima: Int, capacidadeMinima: Int) {
        self.nomeAula         = nome
        self.instrutor        = instrutor
        self.categoria        = categoria
        self.descricaoAula    = descricao
        self.capacidadeMaxima = capacidadeMaxima
        self.capacidadeMinima = capacidadeMinima
    }

    /// Efetua inscrição verificando vagas e duplicidade
    func inscrever(aluno: Aluno) throws {
        guard vagasDisponiveis > 0 else {
            throw ErroInscricao.semVagasDisponiveis
        }
        guard alunosInscritos[aluno.matricula] == nil else {
            throw ErroInscricao.alunoJaInscrito
        }
        alunosInscritos[aluno.matricula] = aluno
        print("   ✅ '\(aluno.nome)' inscrito(a) em '\(nomeAula)' | Vagas: \(vagasDisponiveis)/\(capacidadeMaxima)")
    }

    func cancelarInscricao(aluno: Aluno) {
        if alunosInscritos.removeValue(forKey: aluno.matricula) != nil {
            print("   ℹ️  '\(aluno.nome)' removido(a) de '\(nomeAula)'")
        }
    }

    func descrever() -> String {
        let minOk = atingiuMinimo ? "✅ Mínimo atingido" : "⚠️ Abaixo do mínimo"
        return """
        ┌─ 🏋️ Turma Coletiva: \(nomeAula)
        │  Instrutor : \(instrutor.nome) | Categoria: \(categoria.rawValue)
        │  Descrição : \(descricaoAula)
        └─ Vagas     : \(alunosInscritos.count)/\(capacidadeMaxima) | Mín.: \(capacidadeMinima) [\(minOk)]
        """
    }
}

// MARK: - Treino com Personal (assina ContratoAula)

class TreinoPersonal: ContratoAula {
    let nomeAula: String
    let instrutor: Instrutor
    let categoria: CategoriaAula
    let descricaoAula: String
    let duracaoMinutos: Int
    private(set) var alunoAgendado: Aluno?

    init(nome: String, instrutor: Instrutor, categoria: CategoriaAula,
         descricao: String, duracaoMinutos: Int = 60) {
        self.nomeAula       = nome
        self.instrutor      = instrutor
        self.categoria      = categoria
        self.descricaoAula  = descricao
        self.duracaoMinutos = duracaoMinutos
    }

    func agendar(para aluno: Aluno) {
        alunoAgendado = aluno
        print("   ✅ Sessão '\(nomeAula)' agendada para '\(aluno.nome)' com \(instrutor.nome)")
    }

    func descrever() -> String {
        let nomeAluno = alunoAgendado?.nome ?? "Nenhum aluno agendado"
        return """
        ┌─ 💪 Treino Personal: \(nomeAula)
        │  Instrutor : \(instrutor.nome) | Categoria: \(categoria.rawValue)
        │  Descrição : \(descricaoAula)
        └─ Aluno     : \(nomeAluno) | Duração: \(duracaoMinutos) min
        """
    }
}

// ============================================================
// MARK: - DIA 3: Gerenciamento Central (Fachada do Domínio)
// ============================================================

// MARK: - Erros do Sistema

enum ErroAcademia: Error, LocalizedError {
    case matriculaDuplicada(String)
    case emailDuplicado(String)
    case planoSemPersonal
    case alunoNaoEncontrado(String)
    case instrutorNaoEncontrado(String)

    var errorDescription: String? {
        switch self {
        case .matriculaDuplicada(let id):   return "Matrícula '\(id)' já cadastrada."
        case .emailDuplicado(let email):    return "E-mail '\(email)' já cadastrado."
        case .planoSemPersonal:             return "O plano atual do aluno não inclui personal trainer."
        case .alunoNaoEncontrado(let id):   return "Aluno com matrícula '\(id)' não encontrado."
        case .instrutorNaoEncontrado(let n):return "Instrutor '\(n)' não encontrado."
        }
    }
}

// MARK: - GerenciadorAcademia (fachada central)

class GerenciadorAcademia {
    let nomeAcademia: String

    // Chave-valor para busca rápida O(1)
    private(set) var alunos: [String: Aluno]          = [:]  // key = matrícula
    private(set) var alunosPorEmail: [String: Aluno]  = [:]  // key = email
    private(set) var instrutores: [String: Instrutor] = [:]  // key = email
    private(set) var equipamentos: [String: EquipamentoFisico] = [:]   // key = nomeItem
    private(set) var turmasColetivas: [String: TurmaColetiva] = [:]    // key = nomeAula
    private(set) var sessoesPersonal: [TreinoPersonal] = []

    init(nomeAcademia: String) {
        self.nomeAcademia = nomeAcademia
        print("🏟️ Academia '\(nomeAcademia)' inicializada com sucesso.\n")
    }

    // MARK: Admissão — protegida contra duplicidades

    func cadastrarAluno(_ aluno: Aluno) throws {
        guard alunos[aluno.matricula] == nil else {
            throw ErroAcademia.matriculaDuplicada(aluno.matricula)
        }
        guard alunosPorEmail[aluno.email] == nil else {
            throw ErroAcademia.emailDuplicado(aluno.email)
        }
        alunos[aluno.matricula]    = aluno
        alunosPorEmail[aluno.email] = aluno
        print("   ✅ Aluno '\(aluno.nome)' (matrícula: \(aluno.matricula)) cadastrado.")
    }

    func cadastrarInstrutor(_ instrutor: Instrutor) throws {
        guard instrutores[instrutor.email] == nil else {
            throw ErroAcademia.emailDuplicado(instrutor.email)
        }
        instrutores[instrutor.email] = instrutor
        print("   ✅ Instrutor '\(instrutor.nome)' cadastrado.")
    }

    func cadastrarEquipamento(_ equipamento: EquipamentoFisico) {
        equipamentos[equipamento.nomeItem] = equipamento
        print("   ✅ Equipamento '\(equipamento.nomeItem)' registrado.")
    }

    func cadastrarTurmaColetiva(_ turma: TurmaColetiva) {
        turmasColetivas[turma.nomeAula] = turma
        print("   ✅ Turma '\(turma.nomeAula)' registrada.")
    }

    // MARK: Manutenção em Lote

    /// Itera sobre todos os equipamentos, efetua manutenção programada
    /// e retorna apenas os nomes dos que falharam no processo.
    @discardableResult
    func realizarManutencaoEmLote(tecnico: String) -> [String] {
        var equipamentosFalhos: [String] = []
        let agora = Date()

        print("\n🔧 Manutenção em lote — Técnico: \(tecnico)")
        print(String(repeating: "─", count: 44))

        for (nome, var item) in equipamentos {
            let status = item.realizarReparo(data: agora, tecnico: tecnico)
            equipamentos[nome] = item  // atualiza o struct no dicionário

            if case .falhou(let motivo) = status {
                equipamentosFalhos.append("\(nome) → \(motivo)")
            }
        }

        print(String(repeating: "─", count: 44))
        if equipamentosFalhos.isEmpty {
            print("✅ Todos os equipamentos passaram pela manutenção.")
        } else {
            print("⚠️  \(equipamentosFalhos.count) equipamento(s) com falha:")
            equipamentosFalhos.forEach { print("   • \($0)") }
        }

        return equipamentosFalhos
    }

    // MARK: Agendamento de Personal — lógica de negócio sensível

    /// Agenda sessão de personal SOMENTE se o plano do aluno autorizar
    @discardableResult
    func agendarSessaoPersonal(
        matriculaAluno: String,
        nomeAula: String,
        instrutor: Instrutor,
        categoria: CategoriaAula,
        descricao: String,
        duracao: Int = 60
    ) throws -> TreinoPersonal {
        guard let aluno = alunos[matriculaAluno] else {
            throw ErroAcademia.alunoNaoEncontrado(matriculaAluno)
        }
        guard aluno.plano.incluiPersonalTrainer else {
            throw ErroAcademia.planoSemPersonal
        }

        let sessao = TreinoPersonal(
            nome: nomeAula,
            instrutor: instrutor,
            categoria: categoria,
            descricao: descricao,
            duracaoMinutos: duracao
        )
        sessao.agendar(para: aluno)
        sessoesPersonal.append(sessao)
        return sessao
    }

    // MARK: Relatório Completo

    func imprimirRelatorioCompleto() {
        let sep = String(repeating: "═", count: 52)
        print("\n\(sep)")
        print("  📊 RELATÓRIO COMPLETO — \(nomeAcademia)")
        print(sep)

        print("\n👥 ALUNOS (\(alunos.count)):")
        alunos.values
            .sorted { $0.matricula < $1.matricula }
            .forEach { print("  • \($0.descrever())") }

        print("\n🏅 INSTRUTORES (\(instrutores.count)):")
        instrutores.values
            .sorted { $0.nome < $1.nome }
            .forEach { print("  • \($0.descrever())") }

        print("\n🏋️ EQUIPAMENTOS (\(equipamentos.count)):")
        equipamentos.values
            .sorted { $0.nomeItem < $1.nomeItem }
            .forEach { item in
                print("  • \(item.nomeItem): \(item.estadoDescricao) | Manutenções: \(item.historicoReparos.count)")
            }

        print("\n📚 TURMAS COLETIVAS (\(turmasColetivas.count)):")
        turmasColetivas.values
            .sorted { $0.nomeAula < $1.nomeAula }
            .forEach { print($0.descrever()) }

        print("\n💪 SESSÕES DE PERSONAL (\(sessoesPersonal.count)):")
        sessoesPersonal.forEach { print($0.descrever()) }

        print("\n\(sep)\n")
    }
}

// ============================================================
// MARK: - Execução / Demonstração Completa
// ============================================================

func executarDemo() {
    print("╔══════════════════════════════════════════════════╗")
    print("║         SISTEMA DE GESTÃO DE ACADEMIA            ║")
    print("╚══════════════════════════════════════════════════╝\n")

    // ── Instrutores ──────────────────────────────────────────
    let instCarla    = Instrutor(nome: "Carla Souza",     email: "carla@gym.com",    especialidade: .yoga)
    let instRodrigo  = Instrutor(nome: "Rodrigo Lima",    email: "rodrigo@gym.com",  especialidade: .musculacao)
    let instFernanda = Instrutor(nome: "Fernanda Neves",  email: "fernanda@gym.com", especialidade: .spinning)

    // ── Alunos ───────────────────────────────────────────────
    let alunoAna    = Aluno(nome: "Ana Costa",      email: "ana@email.com",
                            matricula: "2024001", plano: CatalogoPlanos.anual,
                            nivelExperiencia: .intermediario)

    let alunoBruno  = Aluno(nome: "Bruno Martins",  email: "bruno@email.com",
                            matricula: "2024002", plano: CatalogoPlanos.mensal,
                            nivelExperiencia: .iniciante)

    let alunoCamila = Aluno(nome: "Camila Ramos",   email: "camila@email.com",
                            matricula: "2024003", plano: CatalogoPlanos.trimestral,
                            nivelExperiencia: .avancado)

    // ── Equipamentos ─────────────────────────────────────────
    let esteira  = EquipamentoFisico(nome: "Esteira 01",              estado: .operacional)
    let bicicleta = EquipamentoFisico(nome: "Bicicleta Ergométrica 01", estado: .operacional)
    var remo     = EquipamentoFisico(nome: "Remo Ergométrico 01",     estado: .defeituoso(motivo: "Motor queimado"))

    // ── Gerenciador Central ───────────────────────────────────
    let academia = GerenciadorAcademia(nomeAcademia: "FitLife Academia")

    // ── Cadastro de instrutores ───────────────────────────────
    print("─── Cadastrando Instrutores ───────────────────────")
    try? academia.cadastrarInstrutor(instCarla)
    try? academia.cadastrarInstrutor(instRodrigo)
    try? academia.cadastrarInstrutor(instFernanda)

    // ── Cadastro de alunos ────────────────────────────────────
    print("\n─── Cadastrando Alunos ────────────────────────────")
    try? academia.cadastrarAluno(alunoAna)
    try? academia.cadastrarAluno(alunoBruno)
    try? academia.cadastrarAluno(alunoCamila)

    // ── Teste de duplicidade ──────────────────────────────────
    print("\n─── Proteção contra Duplicidade ───────────────────")
    do {
        let dup = Aluno(nome: "Ana Clonada", email: "ana@email.com",
                        matricula: "9999", plano: CatalogoPlanos.mensal,
                        nivelExperiencia: .iniciante)
        try academia.cadastrarAluno(dup)
    } catch {
        print("   ⚠️  Bloqueado (esperado): \(error.localizedDescription)")
    }
    do {
        let dup2 = Aluno(nome: "Bruno Clone", email: "clone@email.com",
                         matricula: "2024002", plano: CatalogoPlanos.mensal,
                         nivelExperiencia: .iniciante)
        try academia.cadastrarAluno(dup2)
    } catch {
        print("   ⚠️  Bloqueado (esperado): \(error.localizedDescription)")
    }

    // ── Cadastro de equipamentos ──────────────────────────────
    print("\n─── Cadastrando Equipamentos ──────────────────────")
    academia.cadastrarEquipamento(esteira)
    academia.cadastrarEquipamento(bicicleta)
    academia.cadastrarEquipamento(remo)

    // ── Turmas Coletivas ──────────────────────────────────────
    print("\n─── Criando Turmas Coletivas ──────────────────────")
    let turmaYoga = TurmaColetiva(
        nome: "Yoga Matinal",
        instrutor: instCarla,
        categoria: .yoga,
        descricao: "Redução de estresse e ganho de flexibilidade",
        capacidadeMaxima: 2,
        capacidadeMinima: 1
    )
    let turmaSpinning = TurmaColetiva(
        nome: "Spinning Avançado",
        instrutor: instFernanda,
        categoria: .spinning,
        descricao: "Alta intensidade para condicionamento cardiovascular",
        capacidadeMaxima: 3,
        capacidadeMinima: 2
    )
    academia.cadastrarTurmaColetiva(turmaYoga)
    academia.cadastrarTurmaColetiva(turmaSpinning)

    // ── Inscrições em Turmas Coletivas ────────────────────────
    print("\n─── Gerenciando Inscrições ────────────────────────")
    try? turmaYoga.inscrever(aluno: alunoAna)
    try? turmaYoga.inscrever(aluno: alunoBruno)

    // Turma cheia — deve falhar
    do {
        try turmaYoga.inscrever(aluno: alunoCamila)
    } catch {
        print("   ⚠️  Bloqueado (esperado): \(error.localizedDescription)")
    }
    // Aluno já inscrito — deve falhar
    do {
        try turmaYoga.inscrever(aluno: alunoAna)
    } catch {
        print("   ⚠️  Bloqueado (esperado): \(error.localizedDescription)")
    }

    try? turmaSpinning.inscrever(aluno: alunoCamila)
    try? turmaSpinning.inscrever(aluno: alunoBruno)

    // ── Agendamento de Personal Trainer ───────────────────────
    print("\n─── Agendamento de Personal Trainer ───────────────")

    // Ana tem plano Anual (inclui personal) → deve funcionar
    do {
        try academia.agendarSessaoPersonal(
            matriculaAluno: "2024001",
            nomeAula: "Funcional Premium",
            instrutor: instRodrigo,
            categoria: .funcional,
            descricao: "Treino funcional personalizado para ganho de força"
        )
    } catch {
        print("   ⚠️  \(error.localizedDescription)")
    }

    // Bruno tem plano Mensal (sem personal) → deve ser bloqueado
    do {
        try academia.agendarSessaoPersonal(
            matriculaAluno: "2024002",
            nomeAula: "Musculação Individual",
            instrutor: instRodrigo,
            categoria: .musculacao,
            descricao: "Treino de musculação personalizado"
        )
    } catch {
        print("   ⚠️  Bloqueado (esperado): \(error.localizedDescription)")
    }

    // Atualiza plano do Bruno para Anual e tenta novamente
    print("\n─── Atualizando Plano do Bruno ────────────────────")
    alunoBruno.atualizarPlano(CatalogoPlanos.anual)
    alunoBruno.atualizarNivel(.intermediario)

    do {
        try academia.agendarSessaoPersonal(
            matriculaAluno: "2024002",
            nomeAula: "Musculação Individual",
            instrutor: instRodrigo,
            categoria: .musculacao,
            descricao: "Treino de musculação personalizado"
        )
    } catch {
        print("   ⚠️  \(error.localizedDescription)")
    }

    // ── Manutenção em lote ────────────────────────────────────
    let falhos = academia.realizarManutencaoEmLote(tecnico: "João Técnico")
    if !falhos.isEmpty {
        print("\n📋 Equipamentos que precisam de reparo urgente:")
        falhos.forEach { print("   🔴 \($0)") }
    }

    // ── Relatório Completo ────────────────────────────────────
    academia.imprimirRelatorioCompleto()

    // ── Demonstração extra: histórico de manutenção do remo ──
    print("─── Histórico do Remo Ergométrico 01 ──────────────")
    if let remoAtualizado = academia.equipamentos["Remo Ergométrico 01"] {
        remoAtualizado.historicoReparos.forEach {
            print("  • \($0.descricao)")
        }
    }
    print("")

    // ── Demonstração: verificação dos planos disponíveis ──────
    print("─── Catálogo de Planos ────────────────────────────")
    CatalogoPlanos.todos.forEach { print($0.descricao) }
}

// Ponto de entrada
executarDemo()
