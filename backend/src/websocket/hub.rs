use axum::extract::ws::Message;
use futures::channel::mpsc::UnboundedSender;
use parking_lot::RwLock;
use std::collections::{HashMap, HashSet};
use uuid::Uuid;

use super::messages::WsServerMessage;

pub struct WebSocketHub {
    // client_id -> sender
    clients: RwLock<HashMap<Uuid, UnboundedSender<Message>>>,
    // sos_id -> Set of client_ids
    sos_rooms: RwLock<HashMap<Uuid, HashSet<Uuid>>>,
}

impl WebSocketHub {
    pub fn new() -> Self {
        Self {
            clients: RwLock::new(HashMap::new()),
            sos_rooms: RwLock::new(HashMap::new()),
        }
    }

    pub fn register(&self, client_id: Uuid, sender: UnboundedSender<Message>) {
        self.clients.write().insert(client_id, sender);
    }

    pub fn unregister(&self, client_id: &Uuid) {
        self.clients.write().remove(client_id);
        let mut rooms = self.sos_rooms.write();
        for (_, members) in rooms.iter_mut() {
            members.remove(client_id);
        }
    }

    pub fn subscribe_sos(&self, client_id: Uuid, sos_id: Uuid) {
        let mut rooms = self.sos_rooms.write();
        rooms.entry(sos_id).or_default().insert(client_id);
    }

    pub fn unsubscribe_sos(&self, client_id: &Uuid, sos_id: &Uuid) {
        let mut rooms = self.sos_rooms.write();
        if let Some(members) = rooms.get_mut(sos_id) {
            members.remove(client_id);
        }
    }

    pub fn broadcast_sos(&self, sos_id: &Uuid, msg: &WsServerMessage) {
        let json = match serde_json::to_string(msg) {
            Ok(j) => j,
            Err(e) => {
                tracing::error!("Failed to serialize WebSocket message: {}", e);
                return;
            }
        };

        let rooms = self.sos_rooms.read();
        if let Some(subscribers) = rooms.get(sos_id) {
            let clients = self.clients.read();
            for client_id in subscribers {
                if let Some(sender) = clients.get(client_id) {
                    let _ = sender.unbounded_send(Message::Text(json.clone()));
                }
            }
        }
    }

    pub fn send_direct(&self, client_id: &Uuid, msg: &WsServerMessage) {
        let json = match serde_json::to_string(msg) {
            Ok(j) => j,
            Err(e) => {
                tracing::error!("Failed to serialize WebSocket message: {}", e);
                return;
            }
        };

        let clients = self.clients.read();
        if let Some(sender) = clients.get(client_id) {
            let _ = sender.unbounded_send(Message::Text(json));
        }
    }
}

