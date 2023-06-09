import Principal "mo:base/Principal";

actor Crowdfunding {

  type Project = {
    promoter: Principal.Principal;
    goal: Nat; // Objetivo de financiamiento en ICP
    currentFunds: Nat; // Fondos actuales recaudados en ICP
  };

  public shared([var Project]) projects : [Project] = [];
  
  public func registerProject(goal: Nat) : async Principal.Principal {
    let promoter = msg.caller;
    
    let project : Project = {
      promoter = promoter;
      goal = goal;
      currentFunds = 0;
    };

    projects := Array.append(projects, [project]);
    promoter;
  }

  
  public func contribute(projectIndex: Nat, amount: Nat) : async Bool {
    if (projectIndex >= Array.length(projects)) {
      false; // Índice de proyecto no válido
    } else {
      let project = Array.get(projects, projectIndex);
      if (project != null) {
        // Verificar si el objetivo de financiamiento ya se alcanzó
        if (project.currentFunds + amount > project.goal) {
          false; // El objetivo ya se alcanzó, no se aceptan más contribuciones
        } else {
          let caller = msg.caller;
          // Transferir los fondos al contrato
          let transferred = ICP.transferToCanister(caller, self, amount);
          if (transferred) {
            // Actualizar los fondos del proyecto
            project.currentFunds := project.currentFunds + amount;
            true; // Contribución exitosa
          } else {
            false; // Fallo en la transferencia de fondos
          }
        }
      } else {
        false; // Proyecto no encontrado
      }
    }
  }

  
  public func getProjectProgress(projectIndex: Nat) : async (Nat, Nat) {
    if (projectIndex >= Array.length(projects)) {
      (0, 0); 
    } else {
      let project = Array.get(projects, projectIndex);
      if (project != null) {
        (project.currentFunds, project.goal);
      } else {
        (0, 0); 
      }
    }
  }
}
